//
//  StoreKit2Manager.swift
//  StoreKit2Manager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit

/// 订阅周期类型
public enum SubscriptionPeriodType: String {
    case week = "week"
    case month = "month"
    case year = "year"
    case lifetime = "lifetime"
}

/// 订阅按钮文案类型
public enum SubscriptionButtonType: String {
    case standard = "standard"        // 标准订阅
    case freeTrial = "freeTrial"      // 免费试用
    case payUpFront = "payUpFront"    // 预付
    case payAsYouGo = "payAsYouGo"    // 按需付费
    case lifetime = "lifetime"        // 终身会员
}

/// 交易类型别名
public typealias Transaction = StoreKit.Transaction

/// 订阅信息类型别名
public typealias SubscriptionInfo = StoreKit.Product.SubscriptionInfo

/// 订阅周期类型别名
public typealias SubscriptionPeriod = StoreKit.Product.SubscriptionPeriod

/// 订阅状态类型别名
public typealias SubscriptionStatus = StoreKit.Product.SubscriptionInfo.Status

/// 续订信息类型别名
public typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo

/// 续订状态类型别名
public typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

/// StoreKit 管理器
/// 提供统一的接口来管理应用内购买
public class StoreKit2Manager {
    /// 单例实例
    public static let shared = StoreKit2Manager()
    
    // MARK: - 配置和代理
    
    private var config: StoreKitConfig?
    private weak var delegate: StoreKitDelegate?
    private var service: StoreKitService?
    
    // MARK: - 闭包回调（可选，与代理二选一）
    
    /// 状态变化回调
    public var onStateChanged: ((StoreKitState) -> Void)?
    
    /// 产品加载成功回调
    public var onProductsLoaded: (([Product]) -> Void)?
    
    /// 已购买产品更新回调: 有效的交易，每个产品最新的交易
    public var onPurchasedTransactionsUpdated: (([Transaction],[Transaction]) -> Void)?
    
    // MARK: - 当前状态和数据
    
    /// 当前执行的状态
    public private(set) var currentState: StoreKitState = .idle
    
    /// 所有产品
    public private(set) var allProducts: [Product] = []
    
    /// 有效的购买订单
    public private(set) var validTransactions: [Transaction] = []
    
    /// 每个产品的最新交易记录集合
    public private(set) var latestTransactions: [Transaction] = []
    
    // MARK: - 按类型分类的产品（计算属性）
    
    /// 非消耗品
    public var nonConsumables: [Product] {
        allProducts.filter { $0.type == .nonConsumable }
    }
    
    /// 消耗品
    public var consumables: [Product] {
        allProducts.filter { $0.type == .consumable }
    }
    
    /// 非续订订阅
    public var nonRenewables: [Product] {
        allProducts.filter { $0.type == .nonRenewable }
    }
    
    /// 自动续订订阅
    public var autoRenewables: [Product] {
        allProducts.filter { $0.type == .autoRenewable }
    }
    
    // MARK: - 初始化
    
    private init() {}
    
    // MARK: - 配置和启动
    
    /// 使用代理配置管理器
    /// - Parameters:
    ///   - config: 配置对象
    ///   - delegate: 代理对象
    public func configure(with config: StoreKitConfig, delegate: StoreKitDelegate) {
        self.config = config
        self.delegate = delegate
        self.service = StoreKitService(config: config, delegate: self)
        service?.start()
    }
    
    /// 使用闭包配置管理器
    /// - Parameter config: 配置对象
    public func configure(with config: StoreKitConfig) {
        self.config = config
        self.service = StoreKitService(config: config, delegate: self)
        service?.start()
    }
    
    // MARK: - 获取产品信息
    
    /// 手动刷新产品列表
    /// - Note: 会异步从 App Store 拉取最新的产品信息，更新本地产品列表
    /// - Returns: 刷新后的产品列表，如果刷新失败返回 nil
    public func refreshProducts() async {
       let _ = await service?.loadProducts()
    }
    
    /// 获取所有产品
    /// - Returns: 当前已知的全部产品列表
    public func getAllProducts() async -> [Product] {
        if(allProducts.isEmpty){
            if let products = await service?.loadProducts() {
                allProducts = products
            }
        }
        return allProducts
    }
    
    /// 获取所有非消耗型产品
    /// - Returns: 非消耗品数组（如：永久解锁类产品）
    public func getNonConsumablesProducts() async -> [Product] {
        return nonConsumables
    }
    
    /// 获取所有消耗型产品
    /// - Returns: 消耗品数组（如：虚拟币、道具等）
    public func getConsumablesProducts() async -> [Product] {
        return consumables
    }
    
    /// 获取所有非续订型订阅产品
    /// - Returns: 非续订订阅产品数组（如：半年的订阅）
    public func getNonRenewablesProducts() async -> [Product] {
        return nonRenewables
    }
    
    /// 获取所有自动续订型订阅产品
    /// - Returns: 自动续订订阅产品数组（如：包月/包年订阅）
    public func getAutoRenewablesProducts() async -> [Product] {
        return autoRenewables
    }
    
    /// 获取产品对象
    /// - Parameter productId: 产品ID
    /// - Returns: 产品对象，如果未找到返回 nil
    public func product(for productId: String) -> Product? {
        return allProducts.first(where: { $0.id == productId })
    }
    
    /// 获取VIP订阅产品的标题
    /// - Parameter productId: 产品ID
    /// - Parameter periodType: 周期类型：周，月，年，终身
    /// - Parameter languageCode: 语言代码
    /// - Parameter isShort: 是否短标题
    /// - Returns: 本地化的产品标题
    public func productForVipTitle(for productId: String, periodType: SubscriptionPeriodType , languageCode: String, isShort: Bool = false) -> String {
        guard let _ = product(for: productId) else {
            return ""
        }
        return SubscriptionLocale.subscriptionTitle(
            periodType: periodType,
            languageCode: languageCode,
            isShort: isShort
        )
    }
    
    /// 获取VIP订阅产品的副标题
    /// - Parameter productId: 产品ID
    /// - Returns: 本地化的产品副标题
    public func productForVipSubtitle(for productId: String, periodType: SubscriptionPeriodType , languageCode: String) async -> String {
        guard let product = product(for: productId) else {
            return ""
        }
        
        // 检查是否有自动续订
        if let subscription = product.subscription {
            // 是自动续订, 且有资格享受介绍性优惠
            let isEligible = await subscription.isEligibleForIntroOffer
            if isEligible {
                // 介绍性优惠：免费试用，随用随付，提前支付
                if subscription.introductoryOffer != nil {
                    return await SubscriptionLocale.introductoryOfferSubtitle(
                        product: product,
                        languageCode: languageCode
                    )
                }
            } else {
                // 促销优惠：免费试用，随用随付，提前支付（似乎有可以有多个促销优惠，后续完善，目前暂时只考虑只有1个的情况）
                if !subscription.promotionalOffers.isEmpty {
                    return await SubscriptionLocale.promotionalOfferSubtitle(
                        product: product,
                        languageCode: languageCode
                    )
                }
            }
        }
        
        // 如果是终生购买
        if config?.lifetimeIds.contains(productId) == true {
            return SubscriptionLocale.defaultSubtitle(
                product: product,
                periodType: SubscriptionPeriodType.lifetime,
                languageCode: languageCode
            )
        }
        //常规订阅
        return SubscriptionLocale.defaultSubtitle(
            product: product,
            periodType: periodType,
            languageCode: languageCode
        )
    }
    
    /// 获取产品的按钮文案
    /// - Parameter productId: 产品ID
    /// - Returns: 本地化的按钮文案
    public func productForVipButtonText(for productId: String, languageCode: String) async -> String {
        guard let product = product(for: productId) else {
            return ""
        }
        
        // 判断按钮类型
        var buttonType: SubscriptionButtonType = .standard
        
        // 检查是否有自动续订
        if let subscription = product.subscription {
            //是自动续订, 且有资格享受介绍性优惠
            let isEligible = await subscription.isEligibleForIntroOffer
            if isEligible {
                //介绍性优惠：免费试用，随用随付，提前支付
                if let introOffer = subscription.introductoryOffer {
                    switch introOffer.paymentMode {
                    case .freeTrial:
                        buttonType = .freeTrial
                    case .payUpFront:
                        buttonType = .payUpFront
                    case .payAsYouGo:
                        buttonType = .payAsYouGo
                    default:
                        buttonType = .standard
                    }
                }
            }else{
                // 促销优惠：免费试用，随用随付，提前支付（似乎有可以有多个促销优惠，后续完善，目前暂时只考虑只有1个的情况）
                if let promotionalOffer = subscription.promotionalOffers.first {
                    switch promotionalOffer.paymentMode {
                    case .freeTrial:
                        buttonType = .freeTrial
                    case .payUpFront:
                        buttonType = .payUpFront
                    case .payAsYouGo:
                        buttonType = .payAsYouGo
                    default:
                        buttonType = .standard
                    }
                }
            }
        }
        //如果是终生购买
        if config?.lifetimeIds.contains(productId) == true {
            buttonType = .lifetime
        }
        
        return SubscriptionLocale.subscriptionButtonText(
            type: buttonType,
            languageCode: languageCode
        )
    }
   
    
    // MARK: - 购买相关
    
    /// 通过产品ID购买
    /// - Parameter productId: 产品ID
    public func purchase(productId: String) async {
        guard let product = allProducts.first(where: { $0.id == productId }) else {
            currentState = .error("StoreKit2Manager.purchase","Product not found","产品未找到: \(productId)")
            return
        }
        await service?.purchase(product)
    }

    /// 通过产品对象购买
    /// - Parameter product: 产品对象
    public func purchase(_ product: Product) async {
        guard let service = service else {
            currentState = .error("StoreKit2Manager.purchase","Service not started","服务未启动，请先调用 configure 方法")
            return
        }
        await service.purchase(product)
    }
    
    /// 恢复购买
    /// - Throws: StoreKit2Error.restorePurchasesFailed 如果恢复失败
    public func restorePurchases() async throws {
        await service?.restorePurchases()
    }
    
    /// 手动刷新已购买产品交易信息，包括：有效的订阅交易信息，每个产品的最新交易信息
    public func refreshPurchases() async {
        await service?.loadValidTransactions()
    }
    
    // MARK: - 查询方法
    
    /// 检查产品是否已购买
    /// - Parameter productId: 产品ID
    /// - Returns: 如果已购买返回 true
    public func isPurchased(productId: String) -> Bool {
        return latestTransactions.contains(where: { $0.productID == productId })
    }
    
    /// 检查产品是否通过家庭共享获得
    /// - Parameter productId: 产品ID
    /// - Returns: 如果是通过家庭共享获得返回 true，否则返回 false
    /// - Note: 只有支持家庭共享的产品才能通过家庭共享获得
    public func isFamilyShared(productId: String) -> Bool {
        guard let transaction = latestTransactions.first(where: { $0.productID == productId }) else {
            return false
        }
        return transaction.ownershipType == .familyShared
    }
    
    /// 检查是否符合享受介绍性优惠资格
    /// - Parameter productId: 产品ID
    /// - Returns: 如果有资格享受介绍性优惠返回 true，否则返回 false
    /// - Note: 仅对支持订阅的产品有效
    public func isEligibleForIntroOffer(productId: String) async -> Bool {
        guard let product = allProducts.first(where: { $0.id == productId }) else {
            return false
        }
        guard let subscription = product.subscription else {
            return false
        }
        return await subscription.isEligibleForIntroOffer
    }

    /// 检查产品是否在有效订阅期间内但在免费试用期已取消
    /// - Parameter productId: 产品ID
    /// - Returns: 如果在有效订阅期间内但在免费试用期取消返回 true，否则返回 false
    /// - Note: 仅对支持订阅的产品有效
    /// - Note: 只有在订阅状态为 .subscribed（有效订阅）且已取消（willAutoRenew == false）且在免费试用期时，才返回 true
    public func isSubscribedButFreeTrailCancelled(productId: String) async -> Bool {
        // 获取产品
        guard let product = allProducts.first(where: { $0.id == productId }) else {
            return false
        }
        
        // 检查是否是订阅产品
        guard let subscription = product.subscription else {
            return false
        }
        
        do {
            // 获取订阅状态
            let statuses = try await subscription.status
            guard let currentStatus = statuses.first(where: { $0.state == .subscribed }) else {
                // 如果没有找到 .subscribed 状态，打印所有状态用于调试
                print("❌ [isSubscribedButFreeTrailCancelled] 未找到 .subscribed 状态: \(productId)")
                print("   当前状态列表: \(statuses.map { "\($0.state)" })")
                return false
            }
            
            // 检查是否已取消（willAutoRenew == false）
            var isCancelled = false
            if case .verified(let renewalInfo) = currentStatus.renewalInfo {
                isCancelled = !renewalInfo.willAutoRenew
            }
            
            // 如果未取消，直接返回 false
            guard isCancelled else {
                return false
            }
            
            // 检查是否在免费试用期
            var isFreeTrial = false
            if case .verified(let transaction) = currentStatus.transaction {
                if(transaction.productID != productId){
                    return false;
                }
                isFreeTrial = isFreeTrialTransaction(transaction)
            }
            
            // 只有在有效订阅期间内、已取消且处于免费试用期时，才返回 true
            return isFreeTrial
        } catch {
            print("获取订阅状态失败: \(productId), 错误: \(error)")
            return false
        }
    }
    
    /// 判断 Transaction 是否在免费试用期（私有辅助方法）
    /// - Parameter transaction: Transaction 对象
    /// - Returns: 如果在免费试用期返回 true，否则返回 false
    private func isFreeTrialTransaction(_ transaction: Transaction) -> Bool {
        // iOS 17.2+ 使用新的 offer 属性
        if #available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 2.4, *) {
            if let offer = transaction.offer {
                // 检查优惠类型和支付模式
                if offer.type == .introductory,
                   offer.paymentMode == .freeTrial {
                    return true
                }
            }
        } else {
            // iOS 15.0 - iOS 17.1 使用已废弃的属性
            if let offerType = transaction.offerType,
               let paymentMode = transaction.offerPaymentModeStringRepresentation {
                if offerType == .introductory,
                   paymentMode == "freeTrial" {
                    return true
                }
            }
        }
        
        return false
    }
   
    // MARK: - 交易相关
    /// 获取有效的已购买交易
    /// - Returns: 有效（未过期、未撤销、未退款）的已购买交易数组
    public func getValidPurchasedTransactions() async -> [Transaction] {
        return validTransactions
    }

    /// 获取每个产品的最新交易
    /// - Returns: 最新交易数组，每个产品只保留最新一笔交易
    public func getLatestTransactions() async -> [Transaction] {
        return latestTransactions
    }
    
    /// 获取交易历史
    /// - Parameter productId: 可选的产品ID，如果提供则只返回该产品的交易历史
    /// - Returns: 交易历史记录数组，按购买日期倒序排列
    public func getTransactionHistory(for productId: String? = nil) async -> [TransactionHistory] {
        await service?.getTransactionHistory(for: productId) ?? []
    }
    
    /// 获取消耗品的购买历史
    /// - Parameter productId: 产品ID
    /// - Returns: 该消耗品的所有购买历史
    public func getConsumablePurchaseHistory(for productId: String) async -> [TransactionHistory] {
        await service?.getConsumablePurchaseHistory(for: productId) ?? []
    }
    
    // MARK: - 订阅相关
    
    /// 手动检查订阅状态
    /// - Note: 建议在以下时机调用：
    ///   - 应用启动时
    ///   - 应用进入前台时
    ///   - 用户打开订阅页面时
    ///   - 购买/恢复购买后
    @MainActor
    public func checkSubscriptionStatus() async {
        await service?.checkSubscriptionStatusManually()
    }
    
    
    /// 获取订阅详细信息
    /// - Parameter productId: 产品ID
    /// - Returns: 订阅信息，如果不是订阅产品则返回 nil
    public func getSubscriptionInfo(for productId: String) async -> SubscriptionInfo? {
        guard let product = allProducts.first(where: { $0.id == productId }) else {
            return nil
        }
        return product.subscription
    }
    
    /// 获取订阅续订信息
    /// - Parameter productId: 产品ID
    /// - Returns: 续订信息，如果不是订阅产品或获取失败则返回 nil
    /// - Note: RenewalInfo 包含 willAutoRenew（是否自动续订）、expirationDate（过期日期）、renewalDate（续订日期）等信息
    public func getRenewalInfo(for productId: String) async -> RenewalInfo? {
        guard let product = allProducts.first(where: { $0.id == productId }),
              let subscription = product.subscription else {
            return nil
        }
        
        do {
            let statuses = try await subscription.status
            if let status = statuses.first,
               case .verified(let renewalInfo) = status.renewalInfo {
                return renewalInfo
            }
        } catch {
            print("获取续订信息失败: \(error)")
            return nil
        }
        return nil
    }
    
    /// 打开订阅管理页面（使用 URL）
    @MainActor
    public func openSubscriptionManagement() {
        service?.openSubscriptionManagement()
    }
    
    /// 显示应用内订阅管理界面（iOS 15.0+ / macOS 12.0+）
    /// - Returns: 是否成功显示管理界面
    @MainActor
    public func showManageSubscriptionsSheet() async -> Bool {
        await service?.showManageSubscriptionsSheet() ?? false
    }
    
    /// 显示优惠代码兑换界面（iOS 16.0+）
    /// - Throws: StoreKit2Error 如果显示失败
    /// - Note: 兑换后的交易会通过 Transaction.updates 发出
    @MainActor
    @available(macOS, unavailable, message: "presentOfferCodeRedeemSheet() is unavailable in macOS")
    public func presentOfferCodeRedeemSheet() async -> Bool {
        guard let service = service else {
            return false
        }
        if #available(iOS 16.0, visionOS 1.0, *){
            do {
                try await service.presentOfferCodeRedeemSheet()
                return true
            } catch {
                return false
            }
        } else {
            return false
        }
    }
    
 
    // MARK: - 其他方法
    /// 请求应用评价
    /// - Note: 兼容 iOS 15.0+ 和 iOS 16.0+
    ///   - iOS 15.0: 使用 SKStoreReviewController.requestReview() (StoreKit 1)
    ///   - iOS 16.0+: 使用 AppStore.requestReview(in:) (StoreKit 2)
    /// - Important: 系统会根据用户的使用情况决定是否显示评价弹窗
    ///   每个应用在每个版本中最多显示 3 次评价请求
    @MainActor
    public func requestReview() {
        service?.requestReview()
    }
    
    /// 停止服务（释放资源）
    public func stop() {
        service?.stop()
        service = nil
        config = nil
        delegate = nil
        currentState = .idle
        allProducts = []
    }
}

// MARK: - StoreKitServiceDelegate

extension StoreKit2Manager: StoreKitServiceDelegate {
    @MainActor
    func service(_ service: StoreKitService, didUpdateState state: StoreKitState) {
        currentState = state
        
        // 通知代理
        delegate?.storeKit(self, didUpdateState: state)
        
        // 通知闭包回调
        onStateChanged?(state)
    }
    
    @MainActor
    func service(_ service: StoreKitService, didLoadProducts products: [Product]) {
        allProducts = products
        
        // 通知代理
        delegate?.storeKit(self, didLoadProducts: products)
        
        // 通知闭包回调
        onProductsLoaded?(products)
    }
    
    @MainActor
    func service(_ service: StoreKitService, didUpdatePurchasedTransactions validTrans: [Transaction], latestTrans: [Transaction]) {
        validTransactions = validTrans
        
        // 通知代理
        delegate?.storeKit(self, didUpdatePurchasedTransactions: validTrans, latestTrans: latestTrans)
        
        // 通知闭包回调
        onPurchasedTransactionsUpdated?(validTrans, latestTrans)
    }
}

