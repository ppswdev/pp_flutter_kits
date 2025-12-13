import Flutter
import UIKit
import StoreKit

public class InappPurchasePlugin: NSObject, FlutterPlugin {
    // 通道名称
    private static let channelName = "inapp_purchase"
    private static let stateEventChannelName = "inapp_purchase/state_events"
    private static let productsEventChannelName = "inapp_purchase/products_events"
    private static let transactionsEventChannelName = "inapp_purchase/transactions_events"
    
    // 方法通道
    private let channel: FlutterMethodChannel
    
    // 事件通道
    private let stateEventChannel: FlutterEventChannel
    private let productsEventChannel: FlutterEventChannel
    private let transactionsEventChannel: FlutterEventChannel
    
    // 事件接收器（使用 fileprivate 以便同一文件内的 StreamHandler 类访问）
    fileprivate var stateEventSink: FlutterEventSink?
    fileprivate var productsEventSink: FlutterEventSink?
    fileprivate var transactionsEventSink: FlutterEventSink?
    
    // StreamHandler 引用（确保不被释放）
    private var stateStreamHandler: StateEventStreamHandler?
    private var productsStreamHandler: ProductsEventStreamHandler?
    private var transactionsStreamHandler: TransactionsEventStreamHandler?
    
    // StoreKit2管理器
    private let storeKitManager = StoreKit2Manager.shared
    
    // 是否显示日志
    private var _showLog = false
    
    // 安全日志输出方法
    fileprivate func safeLog(_ message: String) {
        if _showLog {
            print(message)
        }
    }
    
    // 初始化
    public init(channel: FlutterMethodChannel, stateEventChannel: FlutterEventChannel, productsEventChannel: FlutterEventChannel, transactionsEventChannel: FlutterEventChannel) {
        print("🔵 [iOS Plugin] InappPurchasePlugin 初始化")
        self.channel = channel
        self.stateEventChannel = stateEventChannel
        self.productsEventChannel = productsEventChannel
        self.transactionsEventChannel = transactionsEventChannel
        super.init()
        setupEventChannels()
        print("✅ [iOS Plugin] InappPurchasePlugin 初始化完成")
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        print("🔵 [iOS Plugin] 注册 InappPurchasePlugin")
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let stateEventChannel = FlutterEventChannel(name: stateEventChannelName, binaryMessenger: registrar.messenger())
        let productsEventChannel = FlutterEventChannel(name: productsEventChannelName, binaryMessenger: registrar.messenger())
        let transactionsEventChannel = FlutterEventChannel(name: transactionsEventChannelName, binaryMessenger: registrar.messenger())
        
        let instance = InappPurchasePlugin(channel: channel, stateEventChannel: stateEventChannel, productsEventChannel: productsEventChannel, transactionsEventChannel: transactionsEventChannel)
        
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // 为每个 EventChannel 创建独立的 StreamHandler
        instance.stateStreamHandler = StateEventStreamHandler(plugin: instance)
        instance.productsStreamHandler = ProductsEventStreamHandler(plugin: instance)
        instance.transactionsStreamHandler = TransactionsEventStreamHandler(plugin: instance)
        
        stateEventChannel.setStreamHandler(instance.stateStreamHandler)
        productsEventChannel.setStreamHandler(instance.productsStreamHandler)
        transactionsEventChannel.setStreamHandler(instance.transactionsStreamHandler)
        print("✅ [iOS Plugin] InappPurchasePlugin 注册完成")
    }
    
    // 处理方法调用
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        safeLog("🔵 [iOS Plugin] 收到方法调用: \(call.method)")
        if let arguments = call.arguments {
            safeLog("🔵 [iOS Plugin] 参数: \(arguments)")
        } else {
            safeLog("🔵 [iOS Plugin] 参数: 无")
        }
        switch call.method {
        case "getPlatformVersion":
            let version = "iOS " + UIDevice.current.systemVersion
            safeLog("✅ [iOS Plugin] getPlatformVersion 返回: \(version)")
            result(version)
        
        case "configure":
            configure(call, result)
        
        case "getAllProducts":
            getAllProducts(result)
        
        case "getNonConsumablesProducts":
            getNonConsumablesProducts(result)
        
        case "getConsumablesProducts":
            getConsumablesProducts(result)
        
        case "getNonRenewablesProducts":
            getNonRenewablesProducts(result)
        
        case "getAutoRenewablesProducts":
            getAutoRenewablesProducts(result)
        
        case "getProduct":
            getProduct(call, result)
        
        case "purchase":
            purchase(call, result)
        
        case "restorePurchases":
            restorePurchases(result)
        
        case "refreshPurchases":
            refreshPurchases(result)
        
        case "getValidPurchasedTransactions":
            getValidPurchasedTransactions(result)
        
        case "getLatestTransactions":
            getLatestTransactions(result)
        
        case "isPurchased":
            isPurchased(call, result)
        
        case "isFamilyShared":
            isFamilyShared(call, result)
        
        case "isEligibleForIntroOffer":
            isEligibleForIntroOffer(call, result)
        
        case "checkSubscriptionStatus":
            checkSubscriptionStatus(result)
        
        case "getProductForVipTitle":
            getProductForVipTitle(call, result)
        
        case "getProductForVipSubtitle":
            getProductForVipSubtitle(call, result)
        
        case "getProductForVipButtonText":
            getProductForVipButtonText(call, result)
        
        case "showManageSubscriptionsSheet":
            showManageSubscriptionsSheet(result)
        
        case "presentOfferCodeRedeemSheet":
            presentOfferCodeRedeemSheet(result)
        
        case "requestReview":
            requestReview()
            result(nil)
        
        default:
            safeLog("❌ [iOS Plugin] 未知方法: \(call.method)")
            result(FlutterMethodNotImplemented)
        }
    }

     // 设置事件通道
    private func setupEventChannels() {
        safeLog("🔵 [iOS Plugin] 设置事件通道")
         // 监听状态变化
        storeKitManager.onStateChanged = { [weak self] state in
            guard let self = self else { return }
            self.safeLog("📨 [iOS Plugin] StoreKit 状态变化回调")
            self.handleStateChanged(state)
        }
        
        // 监听产品加载
        storeKitManager.onProductsLoaded = { [weak self] products in
            guard let self = self else { return }
            self.safeLog("📨 [iOS Plugin] StoreKit 产品加载回调: \(products.count) 个产品")
            self.handleProductsLoaded(products)
        }
        
        // 监听已购买产品更新
        storeKitManager.onPurchasedTransactionsUpdated = { [weak self] purchasedTransactions, latestTransactions in
            guard let self = self else { return }
            self.safeLog("📨 [iOS Plugin] StoreKit 交易更新回调: purchasedTransactions=\(purchasedTransactions.count), latestTransactions=\(latestTransactions.count)")
            self.handleTransactionsUpdated(purchasedTransactions, latestTransactions)
        }
        safeLog("✅ [iOS Plugin] 事件通道设置完成")
    }
    
    // 配置StoreKit
    private func configure(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        print("🔵 [iOS Plugin] 开始配置 StoreKit")
        guard let arguments = call.arguments as? [String: Any],
              let productIds = arguments["productIds"] as? [String],
              let lifetimeIds = arguments["lifetimeIds"] as? [String] else {
            print("❌ [iOS Plugin] configure 参数无效")
            result(FlutterError(code: "invalid_arguments", message: "Invalid configuration arguments", details: nil))
            return
        }
        
        let nonRenewableExpirationDays = arguments["nonRenewableExpirationDays"] as? Int ?? 7
        let autoSortProducts = arguments["autoSortProducts"] as? Bool ?? true
        let showLog = arguments["showLog"] as? Bool ?? false
        
        _showLog = showLog
        
        safeLog("🔵 [iOS Plugin] 配置参数:")
        safeLog("   - productIds: \(productIds)")
        safeLog("   - lifetimeIds: \(lifetimeIds)")
        safeLog("   - nonRenewableExpirationDays: \(nonRenewableExpirationDays)")
        safeLog("   - autoSortProducts: \(autoSortProducts)")
        safeLog("   - showLog: \(showLog)")
        
        let config = StoreKitConfig(
            productIds: productIds,
            lifetimeIds: lifetimeIds,
            nonRenewableExpirationDays: nonRenewableExpirationDays,
            autoSortProducts: autoSortProducts,
            showLog: showLog
        )
        
        storeKitManager.configure(with: config)
        safeLog("✅ [iOS Plugin] StoreKit 配置完成")
        result(nil)
    }
    
    // 获取所有产品
    private func getAllProducts(_ result: @escaping FlutterResult) {
        safeLog("🔵 [iOS Plugin] 调用 getAllProducts")
        Task {
            do {
                let products = try await storeKitManager.getAllProducts()
                safeLog("📥 [iOS Plugin] getAllProducts 成功: \(products.count) 个产品")
                let productsDict = ProductConverter.toDictionaryArray(products)
                safeLog("✅ [iOS Plugin] getAllProducts 转换完成，返回数据")
                result(productsDict)
            } catch {
                safeLog("❌ [iOS Plugin] getAllProducts 失败: \(error.localizedDescription)")
                result(FlutterError(code: "get_products_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 获取非消耗性产品
    private func getNonConsumablesProducts(_ result: @escaping FlutterResult) {
        safeLog("🔵 [iOS Plugin] 调用 getNonConsumablesProducts")
        Task {
            do {
                let products = try await storeKitManager.getNonConsumablesProducts()
                safeLog("📥 [iOS Plugin] getNonConsumablesProducts 成功: \(products.count) 个产品")
                let productsDict = ProductConverter.toDictionaryArray(products)
                result(productsDict)
            } catch {
                safeLog("❌ [iOS Plugin] getNonConsumablesProducts 失败: \(error.localizedDescription)")
                result(FlutterError(code: "get_products_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 获取消耗性产品
    private func getConsumablesProducts(_ result: @escaping FlutterResult) {
        safeLog("🔵 [iOS Plugin] 调用 getConsumablesProducts")
        Task {
            do {
                let products = try await storeKitManager.getConsumablesProducts()
                safeLog("📥 [iOS Plugin] getConsumablesProducts 成功: \(products.count) 个产品")
                let productsDict = ProductConverter.toDictionaryArray(products)
                result(productsDict)
            } catch {
                safeLog("❌ [iOS Plugin] getConsumablesProducts 失败: \(error.localizedDescription)")
                result(FlutterError(code: "get_products_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 获取非续订订阅产品
    private func getNonRenewablesProducts(_ result: @escaping FlutterResult) {
        safeLog("🔵 [iOS Plugin] 调用 getNonRenewablesProducts")
        Task {
            do {
                let products = try await storeKitManager.getNonRenewablesProducts()
                safeLog("📥 [iOS Plugin] getNonRenewablesProducts 成功: \(products.count) 个产品")
                let productsDict = ProductConverter.toDictionaryArray(products)
                result(productsDict)
            } catch {
                safeLog("❌ [iOS Plugin] getNonRenewablesProducts 失败: \(error.localizedDescription)")
                result(FlutterError(code: "get_products_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 获取自动续订订阅产品
    private func getAutoRenewablesProducts(_ result: @escaping FlutterResult) {
        safeLog("🔵 [iOS Plugin] 调用 getAutoRenewablesProducts")
        Task {
            do {
                let products = try await storeKitManager.getAutoRenewablesProducts()
                safeLog("📥 [iOS Plugin] getAutoRenewablesProducts 成功: \(products.count) 个产品")
                let productsDict = ProductConverter.toDictionaryArray(products)
                result(productsDict)
            } catch {
                safeLog("❌ [iOS Plugin] getAutoRenewablesProducts 失败: \(error.localizedDescription)")
                result(FlutterError(code: "get_products_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 获取单个产品
    private func getProduct(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String else {
            safeLog("❌ [iOS Plugin] getProduct 参数无效")
            result(FlutterError(code: "invalid_arguments", message: "Invalid productId", details: nil))
            return
        }
        
        safeLog("🔵 [iOS Plugin] 调用 getProduct, productId: \(productId)")
        Task {
            do {
                if let product = storeKitManager.product(for: productId) {
                    safeLog("📥 [iOS Plugin] getProduct 找到产品: \(product.id)")
                    let productDict = ProductConverter.toDictionary(product)
                    safeLog("✅ [iOS Plugin] getProduct 转换完成，返回数据")
                    result(productDict)
                } else {
                    safeLog("⚠️ [iOS Plugin] getProduct 未找到产品: \(productId)")
                    result(nil)
                }
            } catch {
                safeLog("❌ [iOS Plugin] getProduct 失败: \(error.localizedDescription)")
                result(FlutterError(code: "get_product_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 购买产品
    private func purchase(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String else {
            safeLog("❌ [iOS Plugin] purchase 参数无效")
            result(FlutterError(code: "invalid_arguments", message: "Invalid productId", details: nil))
            return
        }
        
        safeLog("🔵 [iOS Plugin] 调用 purchase, productId: \(productId)")
        Task {
            do {
                try await storeKitManager.purchase(productId: productId)
                safeLog("✅ [iOS Plugin] purchase 调用成功")
                result(nil)
            } catch {
                safeLog("❌ [iOS Plugin] purchase 失败: \(error.localizedDescription)")
                result(FlutterError(code: "purchase_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 恢复购买
    private func restorePurchases(_ result: @escaping FlutterResult) {
        safeLog("🔵 [iOS Plugin] 调用 restorePurchases")
        Task {
            do {
                try await storeKitManager.restorePurchases()
                safeLog("✅ [iOS Plugin] restorePurchases 成功")
                result(nil)
            } catch {
                safeLog("❌ [iOS Plugin] restorePurchases 失败: \(error.localizedDescription)")
                result(nil)
            }
        }
    }
    
    // 刷新购买记录
    private func refreshPurchases(_ result: @escaping FlutterResult) {
        safeLog("🔵 [iOS Plugin] 调用 refreshPurchases")
        Task {
            do {
                try await storeKitManager.refreshPurchases()
                safeLog("✅ [iOS Plugin] refreshPurchases 成功")
                result(nil)
            } catch {
                safeLog("❌ [iOS Plugin] refreshPurchases 失败: \(error.localizedDescription)")
                result(FlutterError(code: "refresh_purchases_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 获取有效的已购买交易
    private func getValidPurchasedTransactions(_ result: @escaping FlutterResult) {
        safeLog("🔵 [iOS Plugin] 调用 getValidPurchasedTransactions")
        Task {
            do {
                let transactions = try await storeKitManager.getValidPurchasedTransactions()
                safeLog("📥 [iOS Plugin] getValidPurchasedTransactions 成功: \(transactions.count) 个交易")
                let transactionsDict = TransactionConverter.toDictionaryArray(transactions)
                safeLog("✅ [iOS Plugin] getValidPurchasedTransactions 转换完成，返回数据")
                result(transactionsDict)
            } catch {
                safeLog("❌ [iOS Plugin] getValidPurchasedTransactions 失败: \(error.localizedDescription)")
                result(FlutterError(code: "get_transactions_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 获取最新交易
    private func getLatestTransactions(_ result: @escaping FlutterResult) {
        safeLog("🔵 [iOS Plugin] 调用 getLatestTransactions")
        Task {
            do {
                let transactions = try await storeKitManager.getLatestTransactions()
                safeLog("📥 [iOS Plugin] getLatestTransactions 成功: \(transactions.count) 个交易")
                let transactionsDict = TransactionConverter.toDictionaryArray(transactions)
                safeLog("✅ [iOS Plugin] getLatestTransactions 转换完成，返回数据")
                result(transactionsDict)
            } catch {
                safeLog("❌ [iOS Plugin] getLatestTransactions 失败: \(error.localizedDescription)")
                result(FlutterError(code: "get_transactions_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 检查产品是否已购买
    private func isPurchased(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String else {
            safeLog("❌ [iOS Plugin] isPurchased 参数无效")
            result(FlutterError(code: "invalid_arguments", message: "Invalid productId", details: nil))
            return
        }
        
        safeLog("🔵 [iOS Plugin] 调用 isPurchased, productId: \(productId)")
        let isPurchased = storeKitManager.isPurchased(productId: productId)
        safeLog("✅ [iOS Plugin] isPurchased 返回: \(isPurchased)")
        result(isPurchased)
    }
    
    // 检查产品是否通过家庭共享获得
    private func isFamilyShared(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String else {
            safeLog("❌ [iOS Plugin] isFamilyShared 参数无效")
            result(FlutterError(code: "invalid_arguments", message: "Invalid productId", details: nil))
            return
        }
        
        safeLog("🔵 [iOS Plugin] 调用 isFamilyShared, productId: \(productId)")
        let isFamilyShared = storeKitManager.isFamilyShared(productId: productId)
        safeLog("✅ [iOS Plugin] isFamilyShared 返回: \(isFamilyShared)")
        result(isFamilyShared)
    }
    
    // 检查是否符合介绍性优惠条件
    private func isEligibleForIntroOffer(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String else {
            safeLog("❌ [iOS Plugin] isEligibleForIntroOffer 参数无效")
            result(FlutterError(code: "invalid_arguments", message: "Invalid productId", details: nil))
            return
        }
        
        safeLog("🔵 [iOS Plugin] 调用 isEligibleForIntroOffer, productId: \(productId)")
        Task {
            do {
                let isEligible = try await storeKitManager.isEligibleForIntroOffer(productId: productId)
                safeLog("✅ [iOS Plugin] isEligibleForIntroOffer 返回: \(isEligible)")
                result(isEligible)
            } catch {
                safeLog("❌ [iOS Plugin] isEligibleForIntroOffer 失败: \(error.localizedDescription)")
                result(FlutterError(code: "check_eligible_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 检查订阅状态
    private func checkSubscriptionStatus(_ result: @escaping FlutterResult) {
        safeLog("🔵 [iOS Plugin] 调用 checkSubscriptionStatus")
        Task {
            do {
                let isActive = try await storeKitManager.checkSubscriptionStatus()
                safeLog("✅ [iOS Plugin] checkSubscriptionStatus 返回: \(isActive)")
                result(isActive)
            } catch {
                safeLog("❌ [iOS Plugin] checkSubscriptionStatus 失败: \(error.localizedDescription)")
                result(FlutterError(code: "check_subscription_status_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 获取VIP标题
    private func getProductForVipTitle(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String,
              let periodTypeStr = arguments["periodType"] as? String,
              let periodType = SubscriptionPeriodType(rawValue: periodTypeStr),
              let langCode = arguments["langCode"] as? String else {
            safeLog("❌ [iOS Plugin] getProductForVipTitle 参数无效")
            result(FlutterError(code: "invalid_arguments", message: "Invalid arguments", details: nil))
            return
        }
        
        safeLog("🔵 [iOS Plugin] 调用 getProductForVipTitle, productId: \(productId), periodType: \(periodTypeStr), langCode: \(langCode)")
        Task {
            do {
                let title = storeKitManager.productForVipTitle(for: productId, periodType: periodType, languageCode: langCode)
                safeLog("✅ [iOS Plugin] getProductForVipTitle 返回: \(title)")
                result(title)
            } catch {
                safeLog("❌ [iOS Plugin] getProductForVipTitle 失败: \(error.localizedDescription)")
                result(FlutterError(code: "get_vip_title_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 获取VIP副标题
    private func getProductForVipSubtitle(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String,
              let periodTypeStr = arguments["periodType"] as? String,
              let periodType = SubscriptionPeriodType(rawValue: periodTypeStr),
              let langCode = arguments["langCode"] as? String else {
            safeLog("❌ [iOS Plugin] getProductForVipSubtitle 参数无效")
            result(FlutterError(code: "invalid_arguments", message: "Invalid arguments", details: nil))
            return
        }
        
        safeLog("🔵 [iOS Plugin] 调用 getProductForVipSubtitle, productId: \(productId), periodType: \(periodTypeStr), langCode: \(langCode)")
        Task {
            do {
                let subtitle = try await storeKitManager.productForVipSubtitle(for: productId, periodType: periodType, languageCode: langCode)
                safeLog("✅ [iOS Plugin] getProductForVipSubtitle 返回: \(subtitle)")
                result(subtitle)
            } catch {
                safeLog("❌ [iOS Plugin] getProductForVipSubtitle 失败: \(error.localizedDescription)")
                result(FlutterError(code: "get_vip_subtitle_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 获取VIP按钮文本
    private func getProductForVipButtonText(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String,
              let langCode = arguments["langCode"] as? String else {
            safeLog("❌ [iOS Plugin] getProductForVipButtonText 参数无效")
            result(FlutterError(code: "invalid_arguments", message: "Invalid arguments", details: nil))
            return
        }
        
        safeLog("🔵 [iOS Plugin] 调用 getProductForVipButtonText, productId: \(productId), langCode: \(langCode)")
        Task {
            do {
                let buttonText = try await storeKitManager.productForVipButtonText(for: productId, languageCode: langCode)
                safeLog("✅ [iOS Plugin] getProductForVipButtonText 返回: \(buttonText)")
                result(buttonText)
            } catch {
                safeLog("❌ [iOS Plugin] getProductForVipButtonText 失败: \(error.localizedDescription)")
                result(FlutterError(code: "get_vip_button_text_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 显示管理订阅界面
    private func showManageSubscriptionsSheet(_ result: @escaping FlutterResult) {
        safeLog("🔵 [iOS Plugin] 调用 showManageSubscriptionsSheet")
        Task {
            do {
                try await storeKitManager.showManageSubscriptionsSheet()
                safeLog("✅ [iOS Plugin] showManageSubscriptionsSheet 成功")
                result(nil)
            } catch {
                safeLog("❌ [iOS Plugin] showManageSubscriptionsSheet 失败: \(error.localizedDescription)")
                result(FlutterError(code: "show_manage_subscriptions_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 显示优惠码兑换界面
    private func presentOfferCodeRedeemSheet(_ result: @escaping FlutterResult) {
        safeLog("🔵 [iOS Plugin] 调用 presentOfferCodeRedeemSheet")
        Task {
            do {
                let success = try await storeKitManager.presentOfferCodeRedeemSheet()
                safeLog("✅ [iOS Plugin] presentOfferCodeRedeemSheet 返回: \(success)")
                result(success)
            } catch {
                safeLog("❌ [iOS Plugin] presentOfferCodeRedeemSheet 失败: \(error.localizedDescription)")
                result(FlutterError(code: "present_offer_code_redeem_sheet_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 请求应用评分
    private func requestReview() {
        safeLog("🔵 [iOS Plugin] 调用 requestReview")
        Task {
            @MainActor in
            storeKitManager.requestReview()
            safeLog("✅ [iOS Plugin] requestReview 调用完成")
        }
    }

    // 处理状态变化
    private func handleStateChanged(_ state: StoreKitState) {
        safeLog("📨 [iOS Plugin] 处理状态变化")
        let stateDict = StoreKitStateConverter.toDictionary(state)
        safeLog("📤 [iOS Plugin] 发送状态变化事件到 Flutter: \(stateDict)")
        if let stateEventSink = stateEventSink {
            stateEventSink(stateDict)
            safeLog("✅ [iOS Plugin] 状态变化事件已发送")
        } else {
            safeLog("⚠️ [iOS Plugin] stateEventSink 为 nil，无法发送状态变化事件")
        }
    }
    
    // 处理产品加载
    private func handleProductsLoaded(_ products: [Product]) {
        safeLog("📨 [iOS Plugin] 处理产品加载: \(products.count) 个产品")
        let productsDict = ProductConverter.toDictionaryArray(products)
        safeLog("📤 [iOS Plugin] 发送产品加载事件到 Flutter: \(productsDict.count) 个产品")
        if let productsEventSink = productsEventSink {
            productsEventSink(productsDict)
            safeLog("✅ [iOS Plugin] 产品加载事件已发送")
        } else {
            safeLog("⚠️ [iOS Plugin] productsEventSink 为 nil，无法发送产品加载事件")
        }
    }
    
    // 处理交易更新
    private func handleTransactionsUpdated(_ purchasedTransactions: [Transaction], _ latestTransactions: [Transaction]) {
        safeLog("📨 [iOS Plugin] 处理交易更新: purchasedTransactions=\(purchasedTransactions.count), latestTransactions=\(latestTransactions.count)")
        let purchasedTransactionsDict = TransactionConverter.toDictionaryArray(purchasedTransactions)
        let latestTransactionsDict = TransactionConverter.toDictionaryArray(latestTransactions)
        let transactionData: [String: Any] = [
            "purchasedTransactions": purchasedTransactionsDict,
            "latestTransactions": latestTransactionsDict
        ]
        safeLog("📤 [iOS Plugin] 发送交易更新事件到 Flutter")
        if let transactionsEventSink = transactionsEventSink {
            transactionsEventSink(transactionData)
            safeLog("✅ [iOS Plugin] 交易更新事件已发送")
        } else {
            safeLog("⚠️ [iOS Plugin] transactionsEventSink 为 nil，无法发送交易更新事件")
        }
    }
}

// 独立的 StreamHandler 类
class StateEventStreamHandler: NSObject, FlutterStreamHandler {
    weak var plugin: InappPurchasePlugin?
    
    init(plugin: InappPurchasePlugin) {
        self.plugin = plugin
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.safeLog("🔵 [iOS Plugin] StateEventStreamHandler onListen 被调用")
        plugin?.stateEventSink = events
        plugin?.safeLog("✅ [iOS Plugin] stateEventSink 已设置")
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.safeLog("🔵 [iOS Plugin] StateEventStreamHandler onCancel 被调用")
        plugin?.stateEventSink = nil
        plugin?.safeLog("✅ [iOS Plugin] stateEventSink 已取消")
        return nil
    }
}

class ProductsEventStreamHandler: NSObject, FlutterStreamHandler {
    weak var plugin: InappPurchasePlugin?
    
    init(plugin: InappPurchasePlugin) {
        self.plugin = plugin
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.safeLog("🔵 [iOS Plugin] ProductsEventStreamHandler onListen 被调用")
        plugin?.productsEventSink = events
        plugin?.safeLog("✅ [iOS Plugin] productsEventSink 已设置")
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.safeLog("🔵 [iOS Plugin] ProductsEventStreamHandler onCancel 被调用")
        plugin?.productsEventSink = nil
        plugin?.safeLog("✅ [iOS Plugin] productsEventSink 已取消")
        return nil
    }
}

class TransactionsEventStreamHandler: NSObject, FlutterStreamHandler {
    weak var plugin: InappPurchasePlugin?
    
    init(plugin: InappPurchasePlugin) {
        self.plugin = plugin
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.safeLog("🔵 [iOS Plugin] TransactionsEventStreamHandler onListen 被调用")
        plugin?.transactionsEventSink = events
        plugin?.safeLog("✅ [iOS Plugin] transactionsEventSink 已设置")
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.safeLog("🔵 [iOS Plugin] TransactionsEventStreamHandler onCancel 被调用")
        plugin?.transactionsEventSink = nil
        plugin?.safeLog("✅ [iOS Plugin] transactionsEventSink 已取消")
        return nil
    }
}