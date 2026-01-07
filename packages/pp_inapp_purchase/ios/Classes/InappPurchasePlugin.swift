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
        print("[pp_inapp_purchase_ios_plugin] InappPurchasePlugin 初始化")
        self.channel = channel
        self.stateEventChannel = stateEventChannel
        self.productsEventChannel = productsEventChannel
        self.transactionsEventChannel = transactionsEventChannel
        super.init()
        setupEventChannels()
        print("✅ [pp_inapp_purchase_ios_plugin] InappPurchasePlugin 初始化完成")
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        print("[pp_inapp_purchase_ios_plugin] 注册 InappPurchasePlugin")
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
        print("✅ [pp_inapp_purchase_ios_plugin] InappPurchasePlugin 注册完成")
    }
    
    // 处理方法调用
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        safeLog("[pp_inapp_purchase_ios_plugin] 收到方法调用: \(call.method)")
        if let arguments = call.arguments {
            safeLog("[pp_inapp_purchase_ios_plugin] 参数: \(arguments)")
        } else {
            safeLog("[pp_inapp_purchase_ios_plugin] 参数: 无")
        }
        switch call.method {
        case "getPlatformVersion":
            let version = "iOS " + UIDevice.current.systemVersion
            safeLog("✅ [pp_inapp_purchase_ios_plugin] getPlatformVersion 返回: \(version)")
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
        
        case "isSubscribedButFreeTrailCancelled":
            isSubscribedButFreeTrailCancelled(call, result)
        
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
            safeLog("❌ [pp_inapp_purchase_ios_plugin] 未知方法: \(call.method)")
            result(FlutterMethodNotImplemented)
        }
    }

     // 设置事件通道
    private func setupEventChannels() {
        safeLog("[pp_inapp_purchase_ios_plugin] 设置事件通道")
         // 监听状态变化
        storeKitManager.onStateChanged = { [weak self] state in
            guard let self = self else { return }
            self.safeLog("[pp_inapp_purchase_ios_plugin] StoreKit 状态变化回调")
            self.handleStateChanged(state)
        }
        
        // 监听产品加载
        storeKitManager.onProductsLoaded = { [weak self] products in
            guard let self = self else { return }
            self.safeLog("[pp_inapp_purchase_ios_plugin] StoreKit 产品加载回调: \(products.count) 个产品")
            self.handleProductsLoaded(products)
        }
        
        // 监听已购买产品更新
        storeKitManager.onPurchasedTransactionsUpdated = { [weak self] validTransactions, latestTransactions in
            guard let self = self else { return }
            self.safeLog("[pp_inapp_purchase_ios_plugin] StoreKit 交易更新回调: validTransactions=\(validTransactions.count), latestTransactions=\(latestTransactions.count)")
            self.handleTransactionsUpdated(validTransactions, latestTransactions)
        }
        safeLog("✅ [pp_inapp_purchase_ios_plugin] 事件通道设置完成")
    }
    
    // 配置StoreKit
    private func configure(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        print("[pp_inapp_purchase_ios_plugin] 开始配置 StoreKit")
        guard let arguments = call.arguments as? [String: Any],
              let productIds = arguments["productIds"] as? [String],
              let lifetimeIds = arguments["lifetimeIds"] as? [String] else {
            print("❌ [pp_inapp_purchase_ios_plugin] configure 参数无效")
            result(FlutterError(code: "invalid_arguments", message: "Invalid configuration arguments", details: nil))
            return
        }
        
        let nonRenewableExpirationDays = arguments["nonRenewableExpirationDays"] as? Int ?? 7
        let autoSortProducts = arguments["autoSortProducts"] as? Bool ?? true
        let showLog = arguments["showLog"] as? Bool ?? false
        
        _showLog = showLog
        
        safeLog("[pp_inapp_purchase_ios_plugin] 配置参数:")
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
        safeLog("✅ [pp_inapp_purchase_ios_plugin] StoreKit 配置完成")
        result(nil)
    }
    
    // 获取所有产品
    private func getAllProducts(_ result: @escaping FlutterResult) {
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 getAllProducts")
        Task {
            let products = await storeKitManager.getAllProducts()
            safeLog("[pp_inapp_purchase_ios_plugin] getAllProducts 成功: \(products.count) 个产品")
            let productsDict = await ProductConverter.toDictionaryArray(products)
            safeLog("✅ [pp_inapp_purchase_ios_plugin] getAllProducts 转换完成，返回数据")
            result(productsDict)
        }
    }
    
    // 获取非消耗性产品
    private func getNonConsumablesProducts(_ result: @escaping FlutterResult) {
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 getNonConsumablesProducts")
        Task {
            let products = await storeKitManager.getNonConsumablesProducts()
            safeLog("[pp_inapp_purchase_ios_plugin] getNonConsumablesProducts 成功: \(products.count) 个产品")
            let productsDict = await ProductConverter.toDictionaryArray(products)
            result(productsDict)
        }
    }
    
    // 获取消耗性产品
    private func getConsumablesProducts(_ result: @escaping FlutterResult) {
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 getConsumablesProducts")
        Task {
            let products = await storeKitManager.getConsumablesProducts()
            safeLog("[pp_inapp_purchase_ios_plugin] getConsumablesProducts 成功: \(products.count) 个产品")
            let productsDict = await ProductConverter.toDictionaryArray(products)
            result(productsDict)
        }
    }
    
    // 获取非续订订阅产品
    private func getNonRenewablesProducts(_ result: @escaping FlutterResult) {
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 getNonRenewablesProducts")
        Task {
            let products = await storeKitManager.getNonRenewablesProducts()
            safeLog("[pp_inapp_purchase_ios_plugin] getNonRenewablesProducts 成功: \(products.count) 个产品")
            let productsDict = await ProductConverter.toDictionaryArray(products)
            result(productsDict)
        }
    }
    
    // 获取自动续订订阅产品
    private func getAutoRenewablesProducts(_ result: @escaping FlutterResult) {
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 getAutoRenewablesProducts")
        Task {
            let products = await storeKitManager.getAutoRenewablesProducts()
            safeLog("[pp_inapp_purchase_ios_plugin] getAutoRenewablesProducts 成功: \(products.count) 个产品")
            let productsDict = await ProductConverter.toDictionaryArray(products)
            result(productsDict)
        }
    }
    
    // 获取单个产品
    private func getProduct(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String else {
            safeLog("❌ [pp_inapp_purchase_ios_plugin] getProduct 参数无效")
            result(FlutterError(code: "invalid_arguments", message: "Invalid productId", details: nil))
            return
        }
        
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 getProduct, productId: \(productId)")
        if let product = storeKitManager.product(for: productId) {
            safeLog("[pp_inapp_purchase_ios_plugin] getProduct 找到产品: \(product.id)")
            Task {
                let productDict = await ProductConverter.toDictionary(product)
                safeLog("✅ [pp_inapp_purchase_ios_plugin] getProduct 转换完成，返回数据")
                result(productDict)
            }
        } else {
            safeLog("⚠️ [pp_inapp_purchase_ios_plugin] getProduct 未找到产品: \(productId)")
            result(nil)
        }
    }
    
    // 购买产品
    private func purchase(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String else {
            safeLog("❌ [pp_inapp_purchase_ios_plugin] purchase 参数无效")
            result(FlutterError(code: "invalid_arguments", message: "Invalid productId", details: nil))
            return
        }
        
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 purchase, productId: \(productId)")
        Task {
            await storeKitManager.purchase(productId: productId)
            safeLog("✅ [pp_inapp_purchase_ios_plugin] purchase 调用成功")
            result(nil)
        }
    }
    
    // 恢复购买
    private func restorePurchases(_ result: @escaping FlutterResult) {
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 restorePurchases")
        Task {
            do {
                try await storeKitManager.restorePurchases()
                safeLog("✅ [pp_inapp_purchase_ios_plugin] restorePurchases 成功")
                result(nil)
            } catch {
                safeLog("❌ [pp_inapp_purchase_ios_plugin] restorePurchases 失败: \(error.localizedDescription)")
                result(nil)
            }
        }
    }
    
    // 刷新购买记录
    private func refreshPurchases(_ result: @escaping FlutterResult) {
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 refreshPurchases")
        Task {
            await storeKitManager.refreshPurchases()
            safeLog("✅ [pp_inapp_purchase_ios_plugin] refreshPurchases 成功")
            result(nil)
        }
    }
    
    // 获取有效的已购买交易
    private func getValidPurchasedTransactions(_ result: @escaping FlutterResult) {
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 getValidPurchasedTransactions")
        Task {
            let transactions = await storeKitManager.getValidPurchasedTransactions()
            safeLog("[pp_inapp_purchase_ios_plugin] getValidPurchasedTransactions 成功: \(transactions.count) 个交易")
            let transactionsDict = await TransactionConverter.toDictionaryArray(transactions)
            safeLog("✅ [pp_inapp_purchase_ios_plugin] getValidPurchasedTransactions 转换完成，返回数据")
            result(transactionsDict)
        }
    }
    
    // 获取最新交易
    private func getLatestTransactions(_ result: @escaping FlutterResult) {
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 getLatestTransactions")
        Task {
            let transactions = await storeKitManager.getLatestTransactions()
            safeLog("[pp_inapp_purchase_ios_plugin] getLatestTransactions 成功: \(transactions.count) 个交易")
            let transactionsDict = await TransactionConverter.toDictionaryArray(transactions)
            safeLog("✅ [pp_inapp_purchase_ios_plugin] getLatestTransactions 转换完成，返回数据")
            result(transactionsDict)
        }
    }
    
    // 检查产品是否已购买
    private func isPurchased(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String else {
            safeLog("❌ [pp_inapp_purchase_ios_plugin] isPurchased 参数无效")
            result(FlutterError(code: "invalid_arguments", message: "Invalid productId", details: nil))
            return
        }
        
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 isPurchased, productId: \(productId)")
        let isPurchased = storeKitManager.isPurchased(productId: productId)
        safeLog("✅ [pp_inapp_purchase_ios_plugin] isPurchased 返回: \(isPurchased)")
        result(isPurchased)
    }
    
    // 检查产品是否通过家庭共享获得
    private func isFamilyShared(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String else {
            safeLog("❌ [pp_inapp_purchase_ios_plugin] isFamilyShared 参数无效")
            result(FlutterError(code: "invalid_arguments", message: "Invalid productId", details: nil))
            return
        }
        
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 isFamilyShared, productId: \(productId)")
        let isFamilyShared = storeKitManager.isFamilyShared(productId: productId)
        safeLog("✅ [pp_inapp_purchase_ios_plugin] isFamilyShared 返回: \(isFamilyShared)")
        result(isFamilyShared)
    }
    
    // 检查是否符合介绍性优惠条件
    private func isEligibleForIntroOffer(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String else {
            safeLog("❌ [pp_inapp_purchase_ios_plugin] isEligibleForIntroOffer 参数无效")
            result(FlutterError(code: "invalid_arguments", message: "Invalid productId", details: nil))
            return
        }
        
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 isEligibleForIntroOffer, productId: \(productId)")
        Task {
            let isEligible = await storeKitManager.isEligibleForIntroOffer(productId: productId)
            safeLog("✅ [pp_inapp_purchase_ios_plugin] isEligibleForIntroOffer 返回: \(isEligible)")
            result(isEligible)
        }
    }
    
    // 检查产品是否在有效订阅期间内但在免费试用期已取消
    private func isSubscribedButFreeTrailCancelled(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String else {
            safeLog("❌ [pp_inapp_purchase_ios_plugin] isSubscribedButFreeTrailCancelled 参数无效")
            result(FlutterError(code: "invalid_arguments", message: "Invalid productId", details: nil))
            return
        }
        
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 isSubscribedButFreeTrailCancelled, productId: \(productId)")
        Task {
            let isCancelled = await storeKitManager.isSubscribedButFreeTrailCancelled(productId: productId)
            safeLog("✅ [pp_inapp_purchase_ios_plugin] isSubscribedButFreeTrailCancelled 返回: \(isCancelled)")
            result(isCancelled)
        }
    }
    
    // 检查订阅状态
    private func checkSubscriptionStatus(_ result: @escaping FlutterResult) {
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 checkSubscriptionStatus")
        Task { @MainActor in
            await storeKitManager.checkSubscriptionStatus()
            safeLog("✅ [pp_inapp_purchase_ios_plugin] checkSubscriptionStatus 完成")
            result(nil)
        }
    }
    
    // 获取VIP标题
    private func getProductForVipTitle(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String,
              let periodTypeStr = arguments["periodType"] as? String,
              let periodType = SubscriptionPeriodType(rawValue: periodTypeStr),
              let langCode = arguments["langCode"] as? String else {
            safeLog("❌ [pp_inapp_purchase_ios_plugin] getProductForVipTitle 参数无效")
            result(FlutterError(code: "invalid_arguments", message: "Invalid arguments", details: nil))
            return
        }
        
        let isShort = arguments["isShort"] as? Bool ?? false
        
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 getProductForVipTitle, productId: \(productId), periodType: \(periodTypeStr), langCode: \(langCode), isShort: \(isShort)")
        let title = storeKitManager.productForVipTitle(for: productId, periodType: periodType, languageCode: langCode, isShort: isShort)
        safeLog("✅ [pp_inapp_purchase_ios_plugin] getProductForVipTitle 返回: \(title)")
        result(title)
    }
    
    // 获取VIP副标题
    private func getProductForVipSubtitle(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String,
              let periodTypeStr = arguments["periodType"] as? String,
              let periodType = SubscriptionPeriodType(rawValue: periodTypeStr),
              let langCode = arguments["langCode"] as? String else {
            safeLog("❌ [pp_inapp_purchase_ios_plugin] getProductForVipSubtitle 参数无效")
            result(FlutterError(code: "invalid_arguments", message: "Invalid arguments", details: nil))
            return
        }
        
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 getProductForVipSubtitle, productId: \(productId), periodType: \(periodTypeStr), langCode: \(langCode)")
        Task {
            let subtitle = await storeKitManager.productForVipSubtitle(for: productId, periodType: periodType, languageCode: langCode)
            safeLog("✅ [pp_inapp_purchase_ios_plugin] getProductForVipSubtitle 返回: \(subtitle)")
            result(subtitle)
        }
    }
    
    // 获取VIP按钮文本
    private func getProductForVipButtonText(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String,
              let langCode = arguments["langCode"] as? String else {
            safeLog("❌ [pp_inapp_purchase_ios_plugin] getProductForVipButtonText 参数无效")
            result(FlutterError(code: "invalid_arguments", message: "Invalid arguments", details: nil))
            return
        }
        
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 getProductForVipButtonText, productId: \(productId), langCode: \(langCode)")
        Task {
            let buttonText = await storeKitManager.productForVipButtonText(for: productId, languageCode: langCode)
            safeLog("✅ [pp_inapp_purchase_ios_plugin] getProductForVipButtonText 返回: \(buttonText)")
            result(buttonText)
        }
    }
    
    // 显示管理订阅界面
    private func showManageSubscriptionsSheet(_ result: @escaping FlutterResult) {
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 showManageSubscriptionsSheet")
        Task { @MainActor in
            let success = await storeKitManager.showManageSubscriptionsSheet()
            safeLog("✅ [pp_inapp_purchase_ios_plugin] showManageSubscriptionsSheet 返回: \(success)")
            result(success)
        }
    }
    
    // 显示优惠码兑换界面
    private func presentOfferCodeRedeemSheet(_ result: @escaping FlutterResult) {
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 presentOfferCodeRedeemSheet")
        Task { @MainActor in
            let success = await storeKitManager.presentOfferCodeRedeemSheet()
            safeLog("✅ [pp_inapp_purchase_ios_plugin] presentOfferCodeRedeemSheet 返回: \(success)")
            result(success)
        }
    }
    
    // 请求应用评分
    private func requestReview() {
        safeLog("[pp_inapp_purchase_ios_plugin] 调用 requestReview")
        Task { @MainActor in
            storeKitManager.requestReview()
            safeLog("✅ [pp_inapp_purchase_ios_plugin] requestReview 调用完成")
        }
    }

    // 处理状态变化
    private func handleStateChanged(_ state: StoreKitState) {
        safeLog("[pp_inapp_purchase_ios_plugin] 处理状态变化")
        Task { @MainActor in
            let stateDict = await StoreKitStateConverter.toDictionary(state)
            safeLog("[pp_inapp_purchase_ios_plugin] 发送状态变化事件到 Flutter: \(stateDict)")
            if let stateEventSink = stateEventSink {
                stateEventSink(stateDict)
                safeLog("✅ [pp_inapp_purchase_ios_plugin] 状态变化事件已发送")
            } else {
                safeLog("⚠️ [pp_inapp_purchase_ios_plugin] stateEventSink 为 nil，无法发送状态变化事件")
            }
        }
    }
    
    // 处理产品加载
    private func handleProductsLoaded(_ products: [Product]) {
        safeLog("[pp_inapp_purchase_ios_plugin] 处理产品加载: \(products.count) 个产品")
        Task { @MainActor in
            let productsDict = await ProductConverter.toDictionaryArray(products)
            safeLog("[pp_inapp_purchase_ios_plugin] 发送产品加载事件到 Flutter: \(productsDict.count) 个产品")
            if let productsEventSink = productsEventSink {
                productsEventSink(productsDict)
                safeLog("✅ [pp_inapp_purchase_ios_plugin] 产品加载事件已发送")
            } else {
                safeLog("⚠️ [pp_inapp_purchase_ios_plugin] productsEventSink 为 nil，无法发送产品加载事件")
            }
        }
    }
    
    // 处理交易更新
    private func handleTransactionsUpdated(_ validTransactions: [Transaction], _ latestTransactions: [Transaction]) {
        safeLog("[pp_inapp_purchase_ios_plugin] 处理交易更新: validTransactions=\(validTransactions.count), latestTransactions=\(latestTransactions.count)")
        Task { @MainActor in
            let validTransactionsDict = await TransactionConverter.toDictionaryArray(validTransactions)
            let latestTransactionsDict = await TransactionConverter.toDictionaryArray(latestTransactions)
            let transactionData: [String: Any] = [
                "validTransactions": validTransactionsDict,
                "latestTransactions": latestTransactionsDict
            ]
            safeLog("[pp_inapp_purchase_ios_plugin] 发送交易更新事件到 Flutter")
            if let transactionsEventSink = transactionsEventSink {
                transactionsEventSink(transactionData)
                safeLog("✅ [pp_inapp_purchase_ios_plugin] 交易更新事件已发送")
            } else {
                safeLog("⚠️ [pp_inapp_purchase_ios_plugin] transactionsEventSink 为 nil，无法发送交易更新事件")
            }
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
        plugin?.safeLog("[pp_inapp_purchase_ios_plugin] StateEventStreamHandler onListen 被调用")
        plugin?.stateEventSink = events
        plugin?.safeLog("✅ [pp_inapp_purchase_ios_plugin] stateEventSink 已设置")
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.safeLog("[pp_inapp_purchase_ios_plugin] StateEventStreamHandler onCancel 被调用")
        plugin?.stateEventSink = nil
        plugin?.safeLog("✅ [pp_inapp_purchase_ios_plugin] stateEventSink 已取消")
        return nil
    }
}

class ProductsEventStreamHandler: NSObject, FlutterStreamHandler {
    weak var plugin: InappPurchasePlugin?
    
    init(plugin: InappPurchasePlugin) {
        self.plugin = plugin
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.safeLog("[pp_inapp_purchase_ios_plugin] ProductsEventStreamHandler onListen 被调用")
        plugin?.productsEventSink = events
        plugin?.safeLog("✅ [pp_inapp_purchase_ios_plugin] productsEventSink 已设置")
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.safeLog("[pp_inapp_purchase_ios_plugin] ProductsEventStreamHandler onCancel 被调用")
        plugin?.productsEventSink = nil
        plugin?.safeLog("✅ [pp_inapp_purchase_ios_plugin] productsEventSink 已取消")
        return nil
    }
}

class TransactionsEventStreamHandler: NSObject, FlutterStreamHandler {
    weak var plugin: InappPurchasePlugin?
    
    init(plugin: InappPurchasePlugin) {
        self.plugin = plugin
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.safeLog("[pp_inapp_purchase_ios_plugin] TransactionsEventStreamHandler onListen 被调用")
        plugin?.transactionsEventSink = events
        plugin?.safeLog("✅ [pp_inapp_purchase_ios_plugin] transactionsEventSink 已设置")
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.safeLog("[pp_inapp_purchase_ios_plugin] TransactionsEventStreamHandler onCancel 被调用")
        plugin?.transactionsEventSink = nil
        plugin?.safeLog("✅ [pp_inapp_purchase_ios_plugin] transactionsEventSink 已取消")
        return nil
    }
}