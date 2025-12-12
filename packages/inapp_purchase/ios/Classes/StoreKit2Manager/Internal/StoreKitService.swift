//
//  StoreKitService.swift
//  StoreKit2Manager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit
import Combine
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// StoreKit 内部服务类
/// 负责与 StoreKit API 交互，处理产品加载、购买、交易监听等核心功能
internal class StoreKitService: ObservableObject {
    private let config: StoreKitConfig
    weak var delegate: StoreKitServiceDelegate?
    
    /// 所有产品
    @Published private(set) var allProducts: [Product] = []
    /// 所有有效的非消耗和订阅交易记录集合
    @Published private(set) var purchasedTransactions: [Transaction] = []
    /// 每个产品的最新交易记录集合
    @Published private(set) var latestTransactions: [Transaction] = []
    
    // 后台任务
    private var transactionListener: Task<Void, Error>?
    private var subscriberTasks: [Task<Void, Never>] = []
    private var cancellables = Set<AnyCancellable>()
    
    // 并发购买保护
    private var isPurchasing = false
    private let purchasingQueue = DispatchQueue(label: "com.storekit.purchasing")
    
    // MARK: - 订阅状态监听相关属性
    
    /// 订阅状态缓存（产品ID -> 上次的订阅状态）
    /// 
    /// 用途：
    /// - 存储每个订阅产品上次检查时的 RenewalState（已订阅/已过期/宽限期等）
    /// - 用于比较状态变化，只有变化时才触发通知
    /// - 避免重复通知相同的状态
    private var lastSubscriptionStatus: [String: Product.SubscriptionInfo.RenewalState] = [:]
    
    /// 续订信息缓存（产品ID -> 上次的续订信息）
    /// 
    /// 用途：
    /// - 存储每个订阅产品上次检查时的 RenewalInfo（包含 willAutoRenew、expirationDate 等）
    /// - 用于检测订阅取消：比较 willAutoRenew 从 true 变为 false
    /// - 避免重复通知相同的续订信息
    private var lastRenewalInfo: [String: Product.SubscriptionInfo.RenewalInfo] = [:]
    
    /// 订阅状态检查间隔（秒），默认30秒
    /// 
    /// 说明：
    /// - 自动监听任务会每隔此时间间隔检查一次订阅状态
    /// - 可以根据应用需求调整（例如：更频繁的检查需要更小的值）
    /// - 注意：过于频繁的检查可能会影响性能和电池寿命
    private let subscriptionCheckInterval: TimeInterval = 30
    
    // 当前状态
    private var currentState: StoreKitState = .idle {
        didSet {
            // 确保在主线程调用 delegate
            let state = currentState
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.notifyStateChanged(state)
            }
        }
    }
    
    init(config: StoreKitConfig, delegate: StoreKitServiceDelegate) {
        self.config = config
        self.delegate = delegate
        setupSubscribers()
    }
    
    deinit {
        stop()
    }
    
    // MARK: - 公共方法
    
    /// 启动服务
    func start() {
        guard transactionListener == nil else { return }
        
        transactionListener = transactionStatusStream()
        
        // 启动订阅状态监听
        startSubscriptionStatusListener()
        
        Task {
            await clearUnfinishedTransactions()
            await loadProducts()
            await loadPurchasedTransactions()
            
            // 初始检查订阅状态
            await checkSubscriptionStatus()
        }
    }
    
    /// 停止服务
    func stop() {
        transactionListener?.cancel()
        transactionListener = nil
        
        subscriberTasks.forEach { $0.cancel() }
        subscriberTasks.removeAll()
        
        cancellables.removeAll()
    }
    
    /// 从商店获取所有有效产品
    /// - Returns: 加载的产品列表，如果加载失败返回 nil
    @MainActor
    func loadProducts() async -> [Product]? {
        currentState = .loadingProducts
        
        do {
            let storeProducts = try await Product.products(for: config.productIds)
            
            var products: [Product] = []
            for product in storeProducts {
                products.append(product)
            }
            
            // 如果需要，按价格排序
            if config.autoSortProducts {
                products = sortByPrice(products)
            }

            self.allProducts = products
            return products
        } catch {
            currentState = .error(error)
            return nil
        }
    }
    
    /// 获取所有有效的非消耗品和订阅交易信息集合
    @MainActor
    func loadPurchasedTransactions() async {
        currentState = .loadingPurchases
        
        // 使用 TaskGroup 并行获取所有产品的最新交易记录
        var latestTransactions: [Transaction] = []
        await withTaskGroup(of: Transaction?.self) { group in
            // 为每个产品ID创建任务
            for productId in config.productIds {
                group.addTask {
                    if let latestTransaction = await Transaction.latest(for: productId) {
                        switch latestTransaction {
                        case .verified(let transaction):
                            return transaction
                        case .unverified:
                            return nil
                        }
                    }
                    return nil
                }
            }
            
            // 收集所有结果
            for await transaction in group {
                if let transaction = transaction {
                    latestTransactions.append(transaction)
                }
            }
        }
        self.latestTransactions = latestTransactions

        // 将当前有效记录并转换成 purchasedTransactions
        var purchasedTransactions: [Transaction] = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedTransactions.append(transaction)
            }
        }
        self.purchasedTransactions = purchasedTransactions
        
        currentState = .purchasesLoaded
    }

    /// 完成所有未完成的交易记录
    @MainActor
    func clearUnfinishedTransactions() async {
        for await result in Transaction.unfinished {
            do {
                // 使用统一的验证方法
                let transaction = try verifyPurchase(result)
                
                // 验证成功，完成交易
                await transaction.finish()
                print("未完成交易，完成交易处理: \(transaction.productID)")
                
            } catch {
                // 验证失败，记录错误但不完成交易
                if case .unverified(let transaction, _) = result {
                    print("未完成交易，交易验证失败，产品ID: \(transaction.productID) 错误\(error.localizedDescription)")
                    
                    // 更新状态
                    currentState = .error(StoreKitError.verificationFailed)
                }
                
                // 注意：验证失败时不要调用 finish()
            }
        }
    }
    
    /// 购买产品（带并发保护）
    func purchase(_ product: Product) async throws {
        // 并发购买保护
        return try await withCheckedThrowingContinuation { continuation in
            purchasingQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: StoreKitError.unknownError)
                    return
                }
                
                guard !self.isPurchasing else {
                    continuation.resume(throwing: StoreKitError.purchaseInProgress)
                    return
                }
                
                self.isPurchasing = true
                
                Task {
                    defer {
                        self.purchasingQueue.async {
                            self.isPurchasing = false
                        }
                    }
                    
                    await self.performPurchase(product, continuation: continuation)
                }
            }
        }
    }
    
    /// 执行购买
    private func performPurchase(_ product: Product, continuation: CheckedContinuation<Void, Error>) async {
        await MainActor.run {
            currentState = .purchasing(product.id)
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                do {
                    let transaction = try verifyPurchase(verification)
                    
                    await printProductDetails(product)
                    // 打印详细的交易信息
                    await printTransactionDetails(transaction)
                    
                    // 先完成交易
                    await transaction.finish()
                    
                    // 然后刷新购买列表（消耗品不需要）
                    if product.type != .consumable {
                        await loadPurchasedTransactions()
                    }
                    
                    await MainActor.run {
                        currentState = .purchaseSuccess(transaction.productID)
                    }
                    continuation.resume()
                } catch {
                    await MainActor.run {
                        currentState = .purchaseFailed(product.id, error)
                    }
                    continuation.resume(throwing: error)
                }
                
            case .pending:
                await MainActor.run {
                    currentState = .purchasePending(product.id)
                }
                continuation.resume()
                
            case .userCancelled:
                await MainActor.run {
                    currentState = .purchaseCancelled(product.id)
                }
                continuation.resume()
                
            @unknown default:
                let error = StoreKitError.unknownError
                await MainActor.run {
                    currentState = .purchaseFailed(product.id, error)
                }
                continuation.resume(throwing: error)
            }
        } catch {
            await MainActor.run {
                currentState = .purchaseFailed(product.id, error)
            }
            continuation.resume(throwing: error)
        }
    }
    
    /// 恢复购买
    @MainActor
    func restorePurchases() async throws {
        currentState = .restoringPurchases
        
        do {
            /// 将已签名的交易信息和续订详情与应用商店进行同步。
            /// StoreKit 会自动更新已签订单交易及续费信息，因此只有在用户表示已购买的产品无法正常使用时才应使用此功能。
            /// - 重要提示：此操作会提示用户进行身份验证，仅在用户交互时调用此函数。
            /// - 异常情况：如果用户身份验证不成功，或者 StoreKit 无法连接到 App Store。
            try await AppStore.sync()
            await loadPurchasedTransactions()
            currentState = .restorePurchasesSuccess
        } catch {
            currentState = .restorePurchasesFailed(error)
            throw StoreKitError.restorePurchasesFailed(error)
        }
    }
    
    /// 刷新同步最新的订阅信息
    @MainActor
    func refreshPurchasesSync() async {
        // 同步 App Store 的购买状态
        do {
            try await AppStore.sync()
        } catch {
            print("同步 App Store 状态失败: \(error)")
        }
        
        // 重新获取已购买产品（会更新订阅状态）
        await loadPurchasedTransactions()
    }
    
    
    /// 获取所有或指定产品ID的交易历史记录
    func getTransactionHistory(for productId: String? = nil) async -> [TransactionHistory] {
        var histories: [TransactionHistory] = []
        
        // 查询所有历史交易
        for await verificationResult in Transaction.all {
            do {
                let transaction = try verifyPurchase(verificationResult)
                
                // 如果指定了产品ID，则过滤
                if let productId = productId, transaction.productID != productId {
                    continue
                }
                
                // 查找对应的产品对象
                let product = allProducts.first(where: { $0.id == transaction.productID })
                
                let history = TransactionHistory.from(transaction, product: product)
                histories.append(history)
                
                // 检查是否退款或撤销
                // 注意：在查询交易历史时，如果发现撤销的交易，也会触发状态通知
                // 这样可以确保应用能够及时响应历史交易中的撤销事件
                if transaction.revocationDate != nil {
                    await MainActor.run {
                        if transaction.productType == .autoRenewable {
                            // 订阅产品被撤销/退款
                            // 检查是否在免费试用期（通过交易中的 offer 信息判断）
                            // 如果用户在免费试用期内退款，isFreeTrialCancelled 应该为 true
                            let isFreeTrialCancelled = self.isFreeTrialTransaction(transaction)
                            
                            // 触发订阅取消通知（虽然实际上是撤销，但使用相同的状态）
                            // 外部可以通过 isFreeTrialCancelled 来区分是否在免费试用期
                            currentState = .subscriptionCancelled(transaction.productID, isFreeTrialCancelled: isFreeTrialCancelled)
                        } else {
                            // 非订阅产品被退款
                            currentState = .purchaseRefunded(transaction.productID)
                        }
                    }
                }
            } catch {
                continue
            }
        }
        
        // 按购买日期倒序排列
        return histories.sorted(by: { $0.purchaseDate > $1.purchaseDate })
    }
    
    /// 获取消耗品的购买历史记录
    func getConsumablePurchaseHistory(for productId: String) async -> [TransactionHistory] {
        let allHistory = await getTransactionHistory(for: productId)
        return allHistory.filter { history in
            history.product?.type == .consumable
        }
    }
    
  
    // MARK: - 私有方法

    /// 设置订阅者
    private func setupSubscribers() {
        // 监听产品变化
        $allProducts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] products in
                guard let self = self else { return }
                Task { @MainActor in
                    self.notifyProductsLoaded(products)
                }
            }
            .store(in: &cancellables)
        
        // 监听已购买产品变化
        $purchasedTransactions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transactions in
                guard let self = self else { return }
                Task { @MainActor in
                    self.notifyPurchasedTransactionsUpdated(transactions, self.latestTransactions)
                }
            }
            .store(in: &cancellables)
    }
    
    /// 验证购买
    private func verifyPurchase<T>(_ verificationResult: VerificationResult<T>) throws -> T {
        switch verificationResult {
        case .unverified(_, let error):
            throw StoreKitError.verificationFailed
        case .verified(let result):
            return result
        }
    }
    
    /// 检查交易是否在免费试用期
    /// 
    /// 功能说明：
    /// - 通过检查交易中的优惠信息（offer）来判断该交易是否使用了免费试用优惠
    /// - 判断标准：优惠类型是介绍性优惠（introductory）且支付模式是免费试用（freeTrial）
    /// 
    /// 使用场景：
    /// 1. 订阅取消检测：判断用户是否在免费试用期内取消订阅
    /// 2. 订阅撤销检测：判断用户是否在免费试用期内撤销/退款订阅
    /// 3. 交易历史分析：统计免费试用期的交易数量
    /// 
    /// - Parameter transaction: 交易对象
    /// - Returns: 如果交易使用的是免费试用优惠返回 true，否则返回 false
    /// 
    /// - Note: 
    ///   - 此方法检查的是交易创建时使用的优惠，而不是当前时间点
    ///   - 如果交易使用了免费试用优惠，即使试用期已过，此方法仍返回 true
    ///   - 要判断"当前是否还在试用期内"，需要结合购买日期和试用期长度来计算
    private func isFreeTrialTransaction(_ transaction: Transaction) -> Bool {
        // iOS 17.2+ 使用新的 offer 属性
        if #available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, *) {
            if let offer = transaction.offer {
                // 检查优惠类型和支付模式
                // 判断标准：
                // 1. 优惠类型必须是介绍性优惠（introductory）
                // 2. 支付模式必须是免费试用（freeTrial）
                // 同时满足这两个条件，说明交易使用了免费试用优惠
                if offer.type == .introductory,
                   offer.paymentMode == .freeTrial {
                    return true
                }
            }
        } else {
            // iOS 15.0 - iOS 17.1 使用已废弃的属性
            if let offerType = transaction.offerType,
               let paymentMode = transaction.offerPaymentModeStringRepresentation {
                // 检查是否是介绍性优惠且支付模式是免费试用
                // 注意：paymentMode 是字符串类型，需要与 "freeTrial" 比较
                if offerType == .introductory,
                   paymentMode == "freeTrial" {
                    return true
                }
            }
        }
        
        // 没有优惠信息或不是免费试用，返回 false
        // 可能的情况：
        // 1. 交易没有使用任何优惠（正常付费订阅）
        // 2. 交易使用了其他类型的优惠（促销优惠、预付优惠等）
        // 3. 交易使用了介绍性优惠但支付模式不是免费试用（如预付优惠）
        return false
    }
    
    /// 监听交易状态流
    private func transactionStatusStream() -> Task<Void, Error> {
        return Task.detached { [weak self] in
            guard let self = self else { return }
            
            for await result in Transaction.updates {
                do {
                    let transaction = try self.verifyPurchase(result)
                    
                    await printTransactionDetails(transaction)
                    
                    // 检查是否退款或撤销
                    // 注意：revocationDate 表示撤销/退款，与订阅取消（cancellation）不同
                    // - 撤销（revocation）：通常是退款或违规导致的，会立即失效，通过 Transaction.updates 触发
                    // - 取消（cancellation）：用户主动取消，订阅仍然有效直到过期，通过定期检查 subscription.status 检测
                    if transaction.revocationDate != nil {
                        await MainActor.run {
                            if transaction.productType == .autoRenewable {
                                // 订阅产品被撤销/退款
                                // 检查是否在免费试用期（通过交易中的 offer 信息判断）
                                // 如果用户在免费试用期内退款，isFreeTrialCancelled 应该为 true
                                let isFreeTrialCancelled = self.isFreeTrialTransaction(transaction)
                                
                                // 触发订阅取消通知（虽然实际上是撤销，但使用相同的状态）
                                // 外部可以通过 isFreeTrialCancelled 来区分是否在免费试用期
                                self.currentState = .subscriptionCancelled(transaction.productID, isFreeTrialCancelled: isFreeTrialCancelled)
                            } else {
                                // 非订阅产品被退款
                                // 有撤销日期通常表示退款
                                self.currentState = .purchaseRefunded(transaction.productID)
                            }
                        }
                    }
                    
                    await self.loadPurchasedTransactions()
                    
                    await transaction.finish()
                } catch {
                    print("交易处理失败: \(error)")
                }
            }
        }
    }
    
    /// 按价格排序产品
    private func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { $0.price < $1.price })
    }
    
    // MARK: - 订阅状态监听
    
    /// 启动订阅状态监听（定期检查）
    /// 
    /// 功能说明：
    /// - 创建一个后台任务，定期检查所有已购买订阅的状态
    /// - 检查间隔：默认30秒（可通过 subscriptionCheckInterval 调整）
    /// - 检测内容：
    ///   1. 订阅取消：通过比较 willAutoRenew 从 true 变为 false
    ///   2. 订阅状态变化：通过比较 RenewalState 的变化（已订阅/已过期/宽限期等）
    ///   3. 订阅撤销：检测到 revoked 状态时触发通知
    /// - 通知机制：只有检测到变化时才触发状态通知，避免重复通知
    /// - 生命周期：任务会在服务停止时自动取消
    private func startSubscriptionStatusListener() {
        // 创建新的监听任务（使用 weak self 避免循环引用）
        let task = Task { [weak self] in
            guard let self = self else { return }
            
            // 持续监听，直到任务被取消
            while !Task.isCancelled {
                // 检查所有订阅的状态（并行检查，提高效率）
                await self.checkSubscriptionStatus()
                
                // 等待指定间隔（默认30秒）后再次检查
                // 使用 try? 忽略取消错误，因为任务取消是正常情况
                try? await Task.sleep(nanoseconds: UInt64(self.subscriptionCheckInterval * 1_000_000_000))
            }
        }
        
        // 将任务添加到任务列表，以便在停止服务时统一取消
        subscriberTasks.append(task)
    }
    
    /// 检查所有订阅的状态
    /// 功能说明：
    /// 1. 并行检查所有已购买的自动续订订阅的状态
    /// 2. 比较续订信息（willAutoRenew）的变化，检测订阅取消
    /// 3. 比较订阅状态（RenewalState）的变化，检测状态变更
    /// 4. 更新缓存，只有变化时才通知，避免重复通知
    /// 5. 触发相应的状态通知（subscriptionCancelled、subscriptionStatusChanged 等）
    @MainActor
    private func checkSubscriptionStatus() async {
        // 获取所有已购买的自动续订订阅
        let purchasedSubscriptions = allProducts.filter { product in
            product.type == .autoRenewable && 
            purchasedTransactions.contains(where: { $0.productID == product.id })
        }
        
        // 如果没有订阅，直接返回
        guard !purchasedSubscriptions.isEmpty else { return }
        
        // 使用 TaskGroup 并行检查所有订阅，提高效率
        // 返回类型：(产品ID, 订阅状态, 续订信息, 过期日期, 是否在免费试用期)
        await withTaskGroup(of: (String, Product.SubscriptionInfo.RenewalState?, Product.SubscriptionInfo.RenewalInfo?, Date?, Bool?).self) { group in
            // 为每个订阅产品创建检查任务
            for product in purchasedSubscriptions {
                group.addTask { [weak self] in
                    guard let self = self else { return (product.id, nil, nil, nil, nil) }
                    guard let subscription = product.subscription else { return (product.id, nil, nil, nil, nil) }
                    
                    do {
                        // 获取订阅状态数组（通常只有一个当前状态）
                        let statuses = try await subscription.status
                        guard let currentStatus = statuses.first else { return (product.id, nil, nil, nil, nil) }
                        
                        let currentState = currentStatus.state
                        var renewalInfo: Product.SubscriptionInfo.RenewalInfo?
                        var expirationDate: Date?
                        var isFreeTrial: Bool? = nil
                        
                        // 获取续订信息（包含 willAutoRenew、expirationDate 等）
                        if case .verified(let info) = currentStatus.renewalInfo {
                            renewalInfo = info
                        }
                        
                        // 从 Transaction 中获取过期日期和优惠信息
                        // 注意：subscription.status 中的 transaction 是当前有效的交易
                        // 如果用户取消了订阅，这个交易仍然是当前有效的，直到过期
                        if case .verified(let transaction) = currentStatus.transaction {
                            expirationDate = transaction.expirationDate
                            
                            // ========== 判断是否在免费试用期 ==========
                            // 判断逻辑：
                            // 1. 检查交易中的优惠信息（offer）
                            // 2. 如果优惠类型是介绍性优惠（introductory）且支付模式是免费试用（freeTrial）
                            // 3. 则说明当前订阅使用的是免费试用优惠，即用户在免费试用期内
                            // 
                            // 注意：
                            // - 如果用户取消了订阅，但还在免费试用期内，isFreeTrial 应该为 true
                            // - 如果用户取消了订阅，但已经过了免费试用期，isFreeTrial 应该为 false
                            // - 这个判断基于当前有效交易的优惠信息，是准确的
                            
                            // iOS 17.2+ 使用新的 offer 属性
                            if #available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, *) {
                                if let offer = transaction.offer {
                                    // 检查优惠类型和支付模式
                                    // 如果是介绍性优惠且支付模式是免费试用，则是在免费试用期
                                    if offer.type == .introductory,
                                       offer.paymentMode == .freeTrial {
                                        isFreeTrial = true
                                    } else {
                                        // 其他情况：没有优惠、促销优惠、或其他支付模式，都不算免费试用期
                                        isFreeTrial = false
                                    }
                                } else {
                                    // 没有优惠信息，说明不在免费试用期（可能是正常付费订阅）
                                    isFreeTrial = false
                                }
                            } else {
                                // iOS 15.0 - iOS 17.1 使用已废弃的属性
                                if let offerType = transaction.offerType,
                                   let paymentMode = transaction.offerPaymentModeStringRepresentation {
                                    // 检查是否是介绍性优惠且支付模式是免费试用
                                    if offerType == .introductory,
                                       paymentMode == "freeTrial" {
                                        isFreeTrial = true
                                    } else {
                                        // 其他情况：没有优惠、促销优惠、或其他支付模式，都不算免费试用期
                                        isFreeTrial = false
                                    }
                                } else {
                                    // 没有优惠信息，说明不在免费试用期（可能是正常付费订阅）
                                    isFreeTrial = false
                                }
                            }
                        } else {
                            // 如果无法获取交易信息，默认不在免费试用期
                            isFreeTrial = false
                        }
                        
                        return (product.id, currentState, renewalInfo, expirationDate, isFreeTrial)
                    } catch {
                        print("获取订阅状态失败: \(product.id), 错误: \(error)")
                        return (product.id, nil, nil, nil, nil)
                    }
                }
            }
            
            // 收集所有任务的结果并处理状态变化
            for await (productId, currentRenewalState, renewalInfo, expirationDate, isFreeTrial) in group {
                // 跳过无效结果
                guard let currentRenewalState = currentRenewalState else { continue }
                
                // 获取上次缓存的续订信息和状态
                let lastInfo = self.lastRenewalInfo[productId]
                let lastState = self.lastSubscriptionStatus[productId]
                
                // ========== 检测订阅取消 ==========
                // 订阅取消的判断标准：willAutoRenew 从 true 变为 false
                // 这表示用户主动取消了订阅，但订阅在过期日期前仍然有效
                // 注意：订阅取消后，订阅仍然可以使用直到过期日期
                if let lastInfo = lastInfo,
                   let currentInfo = renewalInfo {
                    // 检查 willAutoRenew 是否从 true 变为 false
                    if lastInfo.willAutoRenew == true && currentInfo.willAutoRenew == false {
                        // ========== 判断是否在免费试用期取消 ==========
                        // 判断逻辑：
                        // 1. isFreeTrial 为 true 表示当前有效交易使用的是免费试用优惠
                        // 2. 如果用户在免费试用期内取消订阅，isFreeTrial 应该为 true
                        // 3. 如果用户在付费订阅期内取消订阅，isFreeTrial 应该为 false
                        // 
                        // 使用场景：
                        // - isFreeTrialCancelled = true：用户在免费试用期内取消，可以：
                        //   * 显示"免费试用已取消"的提示
                        //   * 提供重新订阅的引导
                        //   * 统计免费试用取消率
                        // - isFreeTrialCancelled = false：用户在付费订阅期内取消，可以：
                        //   * 显示"订阅已取消，将在XX日期过期"的提示
                        //   * 提供续订或重新订阅的引导
                        //   * 统计付费订阅取消率
                        let isFreeTrialCancelled = isFreeTrial ?? false
                        
                        // 订阅已取消，触发通知（包含是否在免费试用期取消的信息）
                        if isFreeTrialCancelled {
                            print("🔔 检测到订阅取消（免费试用期）: \(productId)")
                            print("   说明：用户在免费试用期内取消了订阅，订阅将在试用期结束时失效")
                        } else {
                            print("🔔 检测到订阅取消（付费订阅期）: \(productId)")
                            print("   说明：用户在付费订阅期内取消了订阅，订阅将在当前周期结束时失效")
                        }
                        
                        // 触发状态通知，包含是否在免费试用期取消的信息
                        // 外部可以通过这个信息来区分不同的取消场景，提供不同的处理逻辑
                        self.currentState = .subscriptionCancelled(productId, isFreeTrialCancelled: isFreeTrialCancelled)
                        
                        // 打印过期日期信息，告知用户订阅何时失效
                        if let expirationDate = expirationDate {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            if isFreeTrialCancelled {
                                print("   免费试用将在 \(formatter.string(from: expirationDate)) 过期")
                            } else {
                                print("   订阅将在 \(formatter.string(from: expirationDate)) 过期")
                            }
                        }
                    }
                }
                
                // ========== 检测订阅状态变化 ==========
                // 比较当前状态和上次状态，如果不同则触发通知
                // 这样可以检测到订阅从已订阅 -> 已过期、已订阅 -> 宽限期等状态变化
                if let lastState = lastState, lastState != currentRenewalState {
                    // 状态发生变化，根据不同的状态类型进行处理
                    switch currentRenewalState {
                    case .subscribed:
                        // 订阅已激活（可能是新订阅或从其他状态恢复）
                        print("📱 订阅状态变化: \(productId) -> 已订阅")
                        // 注意：这里不触发状态通知，因为 subscribed 是正常状态
                        
                    case .expired:
                        // 订阅已过期（用户无法再使用订阅功能）
                        print("⏰ 订阅状态变化: \(productId) -> 已过期")
                        // 注意：过期状态通常不需要额外通知，因为用户已经知道
                        
                    case .inGracePeriod:
                        // 订阅在宽限期内（支付失败但仍在宽限期内，功能仍可用）
                        print("⚠️ 订阅状态变化: \(productId) -> 宽限期")
                        // 可以在这里触发通知，提醒用户更新支付方式
                        
                    case .inBillingRetryPeriod:
                        // 订阅在计费重试期（支付失败，正在重试，功能仍可用）
                        print("🔄 订阅状态变化: \(productId) -> 计费重试期")
                        // 可以在这里触发通知，提醒用户更新支付方式
                        
                    case .revoked:
                        // 订阅已撤销（可能是退款或违规，功能立即失效）
                        print("❌ 订阅状态变化: \(productId) -> 已撤销")
                        self.currentState = .purchaseRevoked(productId)
                        
                    default:
                        print("❓ 订阅状态变化: \(productId) -> 未知状态: \(currentRenewalState)")
                    }
                }
                
                // ========== 更新缓存 ==========
                // 更新续订信息缓存（用于下次比较 willAutoRenew 的变化）
                if let renewalInfo = renewalInfo {
                    self.lastRenewalInfo[productId] = renewalInfo
                }
                
                // 更新订阅状态缓存（用于下次比较 RenewalState 的变化）
                self.lastSubscriptionStatus[productId] = currentRenewalState
            }
        }
    }
    
    /// 手动检查订阅状态（供外部调用，在关键时机使用）
    /// 
    /// 使用场景：
    /// - 应用启动时：确保订阅状态是最新的
    /// - 应用进入前台时：检查是否有状态变化
    /// - 用户打开订阅页面时：显示最新的订阅信息
    /// - 购买/恢复购买后：立即检查订阅状态
    /// - 用户从订阅管理页面返回时：检查是否有变化
    /// 
    /// 注意：
    /// - 此方法会立即执行一次完整的订阅状态检查
    /// - 与自动监听不同，此方法不会定期重复执行
    /// - 建议在关键时机调用，避免频繁调用影响性能
    @MainActor
    func checkSubscriptionStatusManually() async {
        await checkSubscriptionStatus()
    }
    
   
}

//MARK: 订阅管理
extension StoreKitService{
    /// 打开订阅管理页面（使用 URL）
    @MainActor
    func openSubscriptionManagement() {
        guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else { return }
        
        #if os(iOS)
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        #elseif os(macOS)
        NSWorkspace.shared.open(url)
        #endif
    }
    
    /// 显示应用内订阅管理界面（iOS 15.0+ / macOS 12.0+）
    /// - Returns: 是否成功显示（如果系统不支持则返回 false）
    @MainActor
    func showManageSubscriptionsSheet() async -> Bool {
        #if os(iOS)
        if #available(iOS 15.0, *) {
            do {
                // 获取当前的 windowScene
                let windowScene = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first
                
                if let windowScene = windowScene {
                    try await AppStore.showManageSubscriptions(in: windowScene)
                    
                    await loadPurchasedTransactions()
                    
                    return true
                } else {
                    // 如果无法获取 windowScene，回退到打开 URL
                    openSubscriptionManagement()
                    return false
                }
            } catch {
                print("显示订阅管理界面失败: \(error)")
                // 如果失败，回退到打开 URL
                openSubscriptionManagement()
                return false
            }
        } else {
            // iOS 15.0 以下使用 URL
            openSubscriptionManagement()
            return false
        }
        #elseif os(macOS)
        if #available(macOS 12.0, *) {
            do {
                try await AppStore.showManageSubscriptions()
                
                // 订阅管理界面关闭后，刷新订阅状态
                await loadPurchasedTransactions()
                
                return true
            } catch {
                print("显示订阅管理界面失败: \(error)")
                openSubscriptionManagement()
                return false
            }
        } else {
            openSubscriptionManagement()
            return false
        }
        #else
        openSubscriptionManagement()
        return false
        #endif
    }
    
    /// 显示优惠代码兑换界面（iOS 16.0+）
    /// - Throws: StoreKitError 如果显示失败
    /// - Note: 兑换后的交易会通过 Transaction.updates 发出
    @MainActor
    @available(iOS 16.0, visionOS 1.0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    func presentOfferCodeRedeemSheet() async throws {
        #if os(iOS)
        // 获取当前的 windowScene
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first
        
        guard let windowScene = windowScene else {
            throw StoreKitError.unknownError
        }
        
        do {
            try await AppStore.presentOfferCodeRedeemSheet(in: windowScene)
            // 兑换后的交易会通过 Transaction.updates 自动处理
            // 这里可以刷新购买列表以确保数据同步
            await loadPurchasedTransactions()
        } catch {
            throw StoreKitError.purchaseFailed(error)
        }
        #else
        throw StoreKitError.unknownError
        #endif
    }
    
    /// 请求应用评价
    /// - Note: 兼容 iOS 15.0+ 和 iOS 16.0+
    ///   - iOS 15.0: 使用 SKStoreReviewController.requestReview() (StoreKit 1)
    ///   - iOS 16.0+: 使用 AppStore.requestReview(in:) (StoreKit 2)
    @MainActor
    func requestReview() {
        #if os(iOS)
        if #available(iOS 16.0, *) {
            // iOS 16.0+ 使用 StoreKit 2 的新 API
            if let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first {
                AppStore.requestReview(in: windowScene)
            }
        } else {
            // iOS 15.0 (以及 iOS 10.3-15.x) 使用 StoreKit 1 的 API
            // 在 iOS 15 中，StoreKit 2 存在，但 AppStore.requestReview 需要 iOS 16+
            // 所以回退到 StoreKit 1 的 SKStoreReviewController
            SKStoreReviewController.requestReview()
        }
        #elseif os(macOS)
        if #available(macOS 13.0, *) {
            // macOS 13.0+ 使用 StoreKit 2 的新 API
            if let windowScene = NSApplication.shared.windows.first?.windowScene {
                AppStore.requestReview(in: windowScene)
            }
        } else if #available(macOS 10.14, *) {
            // macOS 12.0+ (以及 macOS 10.14-12.x) 使用 StoreKit 1 的 API
            SKStoreReviewController.requestReview()
        }
        #endif
    }
}

//MARK: 代理通知
extension StoreKitService{
    /// 通知产品加载（在主线程执行）
    @MainActor
    private func notifyProductsLoaded(_ products: [Product]) {
        delegate?.service(self, didLoadProducts: products)
    }
    
    /// 通知已购买交易订单更新（在主线程执行）
    @MainActor
    private func notifyPurchasedTransactionsUpdated(_ efficient: [Transaction], _ latests: [Transaction]) {
        delegate?.service(self, didUpdatePurchasedTransactions: efficient, latests: latests)
    }
    
    /// 通知状态变化（在主线程执行）
    @MainActor
    private func notifyStateChanged(_ state: StoreKitState) {
        delegate?.service(self, didUpdateState: state)
    }
    
}

//MARK: 打印调试方法
extension StoreKitService{
    private  func printProductDetails(_ product:Product) async{
        // 时间格式化为东八区（北京时间）
        let beijingTimeZone = TimeZone(secondsFromGMT: 8 * 3600) ?? .current
        let formatter = DateFormatter()
        formatter.timeZone = beijingTimeZone
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        print("════════════════════════════════════════")
        print("✅ 购买成功 - 交易详细信息")
        print("════════════════════════════════════════")
        print("📦 产品信息:")
        print("   - 产品ID: \(product.id)")
        print("   - 产品类型: \(product.type)")
        print("   - 产品名称: \(product.displayName)")
        print("   - 产品描述: \(product.description)")
        print("   - 产品价格: \(product.displayPrice)")
        print("   - 价格数值: \(product.price)")
        print("   - 家庭共享: \(product.isFamilyShareable)")
        //print("   - 产品JSON: \(String.init(data: product.jsonRepresentation, encoding: .utf8))")
         // 如果是订阅产品，打印订阅相关信息
        if let subscription = product.subscription {
            print("📱 订阅信息:")
            print("   - 订阅组ID: \(subscription.subscriptionGroupID)")
            
            // 打印订阅周期
            let period = subscription.subscriptionPeriod
            let periodName: String
            switch period.unit {
            case .day:
                periodName = "\(period.value) 天"
            case .week:
                periodName = "\(period.value) 周"
            case .month:
                periodName = "\(period.value) 月"
            case .year:
                periodName = "\(period.value) 年"
            @unknown default:
                periodName = "未知"
            }
            print("   - 订阅周期: \(periodName)")
            
            // 检查是否有资格使用介绍性优惠（异步）
            let isEligibleForIntroOffer = await subscription.isEligibleForIntroOffer
            print("   - 是否有资格使用介绍性优惠: \(isEligibleForIntroOffer ? "是" : "否")")
            
            // 介绍性优惠详细信息
            if let introductoryOffer = subscription.introductoryOffer {
                print("   - 介绍性优惠: 有")
                printOfferDetails(introductoryOffer, indent: "     ")
            } else {
                print("   - 介绍性优惠: 无")
            }
            
            // 促销优惠列表
            if !subscription.promotionalOffers.isEmpty {
                print("   - 促销优惠: 有 (\(subscription.promotionalOffers.count) 个)")
                for (index, promotionalOffer) in subscription.promotionalOffers.enumerated() {
                    print("     [促销优惠 \(index + 1)]")
                    printOfferDetails(promotionalOffer, indent: "       ")
                }
            } else {
                print("   - 促销优惠: 无")
            }
            
            // 赢回优惠列表（iOS 18.0+）
            if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
                if !subscription.winBackOffers.isEmpty {
                    print("   - 赢回优惠: 有 (\(subscription.winBackOffers.count) 个)")
                    for (index, winBackOffer) in subscription.winBackOffers.enumerated() {
                        print("     [赢回优惠 \(index + 1)]")
                        printOfferDetails(winBackOffer, indent: "       ")
                    }
                } else {
                    print("   - 赢回优惠: 无")
                }
            }
        }
        
        let productJSON = ProductConverter.toDictionary(product)
        print("   - JSON表示: \(productJSON)")
    }
    
    /// 打印优惠详细信息
    /// - Parameters:
    ///   - offer: 优惠对象
    ///   - indent: 缩进字符串
    private func printOfferDetails(_ offer: Product.SubscriptionOffer, indent: String) {
        // 优惠ID（介绍性优惠为 nil，其他类型不为 nil）
        if let offerID = offer.id {
            print("\(indent)* 优惠ID: \(offerID)")
        } else {
            print("\(indent)* 优惠ID: 无（介绍性优惠）")
        }
        
        // 优惠类型（不是可选的）
        let typeName: String
        if offer.type == .introductory {
            typeName = "介绍性优惠"
        } else if offer.type == .promotional {
            typeName = "促销优惠"
        } else {
            if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
                if offer.type == .winBack {
                    typeName = "赢回优惠"
                } else {
                    typeName = "未知类型(\(offer.type.rawValue))"
                }
            } else {
                typeName = "未知类型(\(offer.type.rawValue))"
            }
        }
        print("\(indent)* 优惠类型: \(typeName)")
        
        // 价格信息
        print("\(indent)* 显示价格: \(offer.displayPrice)")
        print("\(indent)* 价格数值: \(offer.price)")
        
        // 支付模式（显示中文名称）
        let paymentModeName: String
        switch offer.paymentMode {
        case .freeTrial:
            paymentModeName = "免费试用"
        case .payAsYouGo:
            paymentModeName = "按需付费"
        case .payUpFront:
            paymentModeName = "预付"
        default:
            paymentModeName = "未知模式(\(offer.paymentMode.rawValue))"
        }
        print("\(indent)* 支付模式: \(paymentModeName)")
        
        // 优惠周期（不是可选的）
        let offerPeriod = offer.period
        let offerPeriodName: String
        switch offerPeriod.unit {
        case .day:
            offerPeriodName = "\(offerPeriod.value) 天"
        case .week:
            offerPeriodName = "\(offerPeriod.value) 周"
        case .month:
            offerPeriodName = "\(offerPeriod.value) 月"
        case .year:
            offerPeriodName = "\(offerPeriod.value) 年"
        @unknown default:
            offerPeriodName = "未知"
        }
        print("\(indent)* 优惠周期: \(offerPeriodName)")
        
        // 周期数量（总是 1，除了 .payAsYouGo）
        print("\(indent)* 周期数量: \(offer.periodCount)")
    }
    
    /// 打印详细的产品和交易信息
    private func printTransactionDetails(_ transaction: Transaction) async {
        // 时间格式化为东八区（北京时间）
        let beijingTimeZone = TimeZone(secondsFromGMT: 8 * 3600) ?? .current
        let formatter = DateFormatter()
        formatter.timeZone = beijingTimeZone
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
       
        print("")
        print("💳 交易信息:")
        print("   - 交易ID: \(transaction.id)") // 当前交易的唯一标识符
        print("   - 产品ID: \(transaction.productID)") // 购买的产品ID
        print("   - 产品类型: \(transaction.productType)") // 产品类型（消耗品/非消耗品/非续订订阅/自动续订订阅）
        print("   - 购买日期: \(formatter.string(from: transaction.purchaseDate))") // 购买时间（UTC时间）
        print("   - 所有权类型: \(transaction.ownershipType)") // 所有权类型（purchased/familyShared）
        print("   - 原始交易ID: \(transaction.originalID)") // 首次购买的交易ID（用于订阅续订）
        print("   - 原始购买日期: \(formatter.string(from: transaction.originalPurchaseDate))") // 首次购买时间
        
        // 过期日期（仅订阅产品有）
        if let expirationDate = transaction.expirationDate {
            let dateStr = formatter.string(from: expirationDate)
            print("   - 过期日期: \(dateStr)") // 订阅过期时间
        } else {
            print("   - 过期日期: 无")
        }
        
        // 撤销日期（如果已退款/撤销）
        if let revocationDate = transaction.revocationDate {
            let dateStr = formatter.string(from: revocationDate)
            print("   - 撤销日期: \(dateStr)") // 退款或撤销的时间
        } else {
            print("   - 撤销日期: 无")
        }
        
        // 撤销原因
        if let revocationReason = transaction.revocationReason {
            print("   - 撤销原因: \(revocationReason)") // 退款/撤销的原因代码
        }
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *){
            // 购买原因（purchased/upgraded/renewed等）
            print("   - 购买理由: \(transaction.reason)")
        }else{
            print("   - 购买理由: 无")
        }
        print("   - 是否升级: \(transaction.isUpgraded)") // 是否为升级购买
        
        // 购买数量
        print("   - 购买数量: \(transaction.purchasedQuantity)") // 购买的数量
        
        // 价格
        if let price = transaction.price {
            print("   - 交易价格: \(price)") // 实际支付的价格
        }
        
        // 货币代码
        if #available(iOS 16.0, *) {
            if let currency = transaction.currency {
                print("   - 货币代码: \(currency)") // 货币代码（如CNY、USD）
            }
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 16.0, *) {
            print("   - 环境: \(transaction.environment.rawValue)")
        } else {
            // Fallback on earlier versions
        } // 交易环境（sandbox/production）
        print("   - 应用交易ID: \(transaction.appTransactionID)") // 应用级别的交易ID
        print("   - 应用Bundle ID: \(transaction.appBundleID )") // 应用的Bundle标识符
        // 应用账户Token（用于关联用户账户）
        if let appAccountToken = transaction.appAccountToken {
            print("   - 应用账户Token: \(appAccountToken)") // 用于关联用户账户的Token
        }
        // 订阅组ID（仅订阅产品）
        if let subscriptionGroupID = transaction.subscriptionGroupID {
            print("   - 订阅组ID: \(subscriptionGroupID)") // 订阅所属的组ID
        }
        
        // 订阅状态（仅订阅产品）
        //if let subscriptionStatus = await transaction.subscriptionStatus {
        //    print("   - 订阅状态: \(subscriptionStatus)") // 订阅的当前状态
        //}
        
        print("   - 签名日期: \(formatter.string(from: transaction.signedDate))") // 交易签名的日期
        if #available(iOS 17.0, *) {
            print("   - 商店区域: \(transaction.storefront)")
        } else {
            // Fallback on earlier versions
        } // 商店区域代码
        
        // Web订单行项目ID
        if let webOrderLineItemID = transaction.webOrderLineItemID {
            print("   - Web订单行项目ID: \(webOrderLineItemID)") // Web订单的行项目ID
        }
        print("   - 设备验证: \(transaction.deviceVerification)") // 设备验证数据
        print("   - 设备验证Nonce: \(transaction.deviceVerificationNonce)") // 设备验证的Nonce值
        
        // 优惠信息
        if #available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, *) {
            // iOS 17.2+ 使用新的 offer 属性
            if let offer = transaction.offer {
                print("   - 优惠信息:")
                print("     * 优惠类型: \(offer.type)")
                if let offerID = offer.id {
                    print("     * 优惠ID: \(offerID)")
                }
                print("     * 支付模式: \(String(describing: offer.paymentMode?.rawValue))")
                if #available(iOS 18.4, *) {
                    if let period = offer.period {
                        print("     * 优惠周期: \(period)")
                    }
                } else {
                    // Fallback on earlier versions
                }
            }
        } else if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            // iOS 15.0 - iOS 17.1 使用已废弃的属性
            if let offerType = transaction.offerType {
                print("   - 优惠信息:")
                print("     * 优惠类型: \(offerType)")
                
                if let offerID = transaction.offerID {
                    print("     * 优惠ID: \(offerID)")
                }
                
                if let paymentMode = transaction.offerPaymentModeStringRepresentation {
                    print("     * 支付模式: \(paymentMode)")
                }
                
                if #available(iOS 18.4, macOS 15.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *) {
                    // iOS 18.4+ 已废弃 offerPeriodStringRepresentation，但为了兼容性仍可检查
                    // 实际上在 iOS 18.4+ 应该使用上面的 offer.period
                } else {
                    // iOS 15.0 - iOS 18.3 使用 offerPeriodStringRepresentation
                    if let period = transaction.offerPeriodStringRepresentation {
                        print("     * 优惠周期: \(period)")
                    }
                }
            }
        } else {
            // iOS 15.0 以下版本不支持优惠信息
            // 不输出任何内容
        }
        
        // 高级商务信息
        if #available(iOS 18.4, *) {
            if let advancedCommerceInfo = transaction.advancedCommerceInfo {
                print("   - 高级商务信息: \(advancedCommerceInfo)") // 高级商务相关信息
            }
        } else {
            // Fallback on earlier versions
        }
        
        // JSON表示（用于服务器验证）
        //if let jsonRepresentation = transaction.jsonRepresentation {
        //    print("   - JSON表示 (前200字符): \(String(jsonRepresentation.prefix(200)))...") // JSON格式的交易数据，可用于服务器验证
        //}
        
        // Debug描述
        print("   - Debug描述: \(transaction.debugDescription)") // 调试用的描述信息
        print("")
        
        
        print("════════════════════════════════════════")
        print("")

        let transactionJSON = TransactionConverter.toDictionary(transaction)
        print("   - JSON表示: \(transactionJSON)")
    }
}
