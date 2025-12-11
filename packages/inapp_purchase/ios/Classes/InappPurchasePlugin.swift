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
    
    // 事件接收器
    private var stateEventSink: FlutterEventSink?
    private var productsEventSink: FlutterEventSink?
    private var transactionsEventSink: FlutterEventSink?
    
    // StoreKit2管理器
    private let storeKitManager = StoreKit2Manager.shared
    
    // 初始化
    public init(channel: FlutterMethodChannel, stateEventChannel: FlutterEventChannel, productsEventChannel: FlutterEventChannel, transactionsEventChannel: FlutterEventChannel) {
        self.channel = channel
        self.stateEventChannel = stateEventChannel
        self.productsEventChannel = productsEventChannel
        self.transactionsEventChannel = transactionsEventChannel
        super.init()
        setupEventChannels()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let stateEventChannel = FlutterEventChannel(name: stateEventChannelName, binaryMessenger: registrar.messenger())
        let productsEventChannel = FlutterEventChannel(name: productsEventChannelName, binaryMessenger: registrar.messenger())
        let transactionsEventChannel = FlutterEventChannel(name: transactionsEventChannelName, binaryMessenger: registrar.messenger())
        
        let instance = InappPurchasePlugin(channel: channel, stateEventChannel: stateEventChannel, productsEventChannel: productsEventChannel, transactionsEventChannel: transactionsEventChannel)
        
        registrar.addMethodCallDelegate(instance, channel: channel)
        stateEventChannel.setStreamHandler(instance)
        productsEventChannel.setStreamHandler(instance)
        transactionsEventChannel.setStreamHandler(instance)
    }
    
    // 处理方法调用
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        
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
            result(FlutterMethodNotImplemented)
        }
    }

     // 设置事件通道
    private func setupEventChannels() {
         // 监听状态变化
        storeKitManager.onStateChanged = { [weak self] state in
            guard let self = self else { return }
            self.handleStateChanged(state)
        }
        
        // 监听产品加载
        storeKitManager.onProductsLoaded = { [weak self] products in
            guard let self = self else { return }
            self.handleProductsLoaded(products)
        }
        
        // 监听已购买产品更新
        storeKitManager.onPurchasedTransactionsUpdated = { [weak self] purchasedTransactions, latestTransactions in
            guard let self = self else { return }
            self.handleTransactionsUpdated(purchasedTransactions, latestTransactions)
        }
    }
    
    // 配置StoreKit
    private func configure(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productIds = arguments["productIds"] as? [String],
              let lifetimeIds = arguments["lifetimeIds"] as? [String] else {
            result(FlutterError(code: "invalid_arguments", message: "Invalid configuration arguments", details: nil))
            return
        }
        
        let nonRenewableExpirationDays = arguments["nonRenewableExpirationDays"] as? Int ?? 7
        let autoSortProducts = arguments["autoSortProducts"] as? Bool ?? true
        
        let config = StoreKitConfig(
            productIds: productIds,
            lifetimeIds: lifetimeIds,
            nonRenewableExpirationDays: nonRenewableExpirationDays,
            autoSortProducts: autoSortProducts
        )
        
        storeKitManager.configure(with: config)
        result(nil)
    }
    
    // 获取所有产品
    private func getAllProducts(_ result: @escaping FlutterResult) {
        Task {
            do {
                let products = try await storeKitManager.getAllProducts()
                let productsDict = ProductConverter.toDictionaryArray(products)
                result(productsDict)
            } catch {
                result(FlutterError(code: "get_products_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 获取非消耗性产品
    private func getNonConsumablesProducts(_ result: @escaping FlutterResult) {
        Task {
            do {
                let products = try await storeKitManager.getNonConsumablesProducts()
                let productsDict = ProductConverter.toDictionaryArray(products)
                result(productsDict)
            } catch {
                result(FlutterError(code: "get_products_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 获取消耗性产品
    private func getConsumablesProducts(_ result: @escaping FlutterResult) {
        Task {
            do {
                let products = try await storeKitManager.getConsumablesProducts()
                let productsDict = ProductConverter.toDictionaryArray(products)
                result(productsDict)
            } catch {
                result(FlutterError(code: "get_products_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 获取非续订订阅产品
    private func getNonRenewablesProducts(_ result: @escaping FlutterResult) {
        Task {
            do {
                let products = try await storeKitManager.getNonRenewablesProducts()
                let productsDict = ProductConverter.toDictionaryArray(products)
                result(productsDict)
            } catch {
                result(FlutterError(code: "get_products_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 获取自动续订订阅产品
    private func getAutoRenewablesProducts(_ result: @escaping FlutterResult) {
        Task {
            do {
                let products = try await storeKitManager.getAutoRenewablesProducts()
                let productsDict = ProductConverter.toDictionaryArray(products)
                result(productsDict)
            } catch {
                result(FlutterError(code: "get_products_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 获取单个产品
    private func getProduct(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String else {
            result(FlutterError(code: "invalid_arguments", message: "Invalid productId", details: nil))
            return
        }
        
        Task {
            do {
                if let product = try await storeKitManager.getProduct(productId: productId) {
                    let productDict = ProductConverter.toDictionary(product)
                    result(productDict)
                } else {
                    result(nil)
                }
            } catch {
                result(FlutterError(code: "get_product_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 购买产品
    private func purchase(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String else {
            result(FlutterError(code: "invalid_arguments", message: "Invalid productId", details: nil))
            return
        }
        
        Task {
            do {
                try await storeKitManager.purchase(productId: productId)
                result(nil)
            } catch {
                result(FlutterError(code: "purchase_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 恢复购买
    private func restorePurchases(_ result: @escaping FlutterResult) {
        Task {
            do {
                try await storeKitManager.restorePurchases()
                result(nil)
            } catch {
                result(FlutterError(code: "restore_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 刷新购买记录
    private func refreshPurchases(_ result: @escaping FlutterResult) {
        Task {
            do {
                try await storeKitManager.refreshPurchases()
                result(nil)
            } catch {
                result(FlutterError(code: "refresh_purchases_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 获取有效的已购买交易
    private func getValidPurchasedTransactions(_ result: @escaping FlutterResult) {
        Task {
            do {
                let transactions = try await storeKitManager.getValidPurchasedTransactions()
                let transactionsDict = TransactionConverter.toDictionaryArray(transactions)
                result(transactionsDict)
            } catch {
                result(FlutterError(code: "get_transactions_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 获取最新交易
    private func getLatestTransactions(_ result: @escaping FlutterResult) {
        Task {
            do {
                let transactions = try await storeKitManager.getLatestTransactions()
                let transactionsDict = TransactionConverter.toDictionaryArray(transactions)
                result(transactionsDict)
            } catch {
                result(FlutterError(code: "get_transactions_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 检查产品是否已购买
    private func isPurchased(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String else {
            result(FlutterError(code: "invalid_arguments", message: "Invalid productId", details: nil))
            return
        }
        
        result(storeKitManager.isPurchased(productId: productId))
    }
    
    // 检查产品是否通过家庭共享获得
    private func isFamilyShared(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String else {
            result(FlutterError(code: "invalid_arguments", message: "Invalid productId", details: nil))
            return
        }
        
        result(storeKitManager.isFamilyShared(productId: productId))
    }
    
    // 检查是否符合介绍性优惠条件
    private func isEligibleForIntroOffer(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String else {
            result(FlutterError(code: "invalid_arguments", message: "Invalid productId", details: nil))
            return
        }
        
        Task {
            do {
                let isEligible = try await storeKitManager.isEligibleForIntroOffer(productId: productId)
                result(isEligible)
            } catch {
                result(FlutterError(code: "check_eligible_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 检查订阅状态
    private func checkSubscriptionStatus(_ result: @escaping FlutterResult) {
        Task {
            do {
                let isActive = try await storeKitManager.checkSubscriptionStatus()
                result(isActive)
            } catch {
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
            result(FlutterError(code: "invalid_arguments", message: "Invalid arguments", details: nil))
            return
        }
        
        Task {
            do {
                let title = storeKitManager.productForVipTitle(for: productId, periodType: periodType, languageCode: langCode)
                result(title)
            } catch {
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
            result(FlutterError(code: "invalid_arguments", message: "Invalid arguments", details: nil))
            return
        }
        
        Task {
            do {
                let subtitle = try await storeKitManager.productForVipSubtitle(for: productId, periodType: periodType, languageCode: langCode)
                result(subtitle)
            } catch {
                result(FlutterError(code: "get_vip_subtitle_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 获取VIP按钮文本
    private func getProductForVipButtonText(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let productId = arguments["productId"] as? String,
              let langCode = arguments["langCode"] as? String else {
            result(FlutterError(code: "invalid_arguments", message: "Invalid arguments", details: nil))
            return
        }
        
        Task {
            do {
                let buttonText = try await storeKitManager.productForVipButtonText(for: productId, languageCode: langCode)
                result(buttonText)
            } catch {
                result(FlutterError(code: "get_vip_button_text_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 显示管理订阅界面
    private func showManageSubscriptionsSheet(_ result: @escaping FlutterResult) {
        Task {
            do {
                try await storeKitManager.showManageSubscriptionsSheet()
                result(nil)
            } catch {
                result(FlutterError(code: "show_manage_subscriptions_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 显示优惠码兑换界面
    private func presentOfferCodeRedeemSheet(_ result: @escaping FlutterResult) {
        Task {
            do {
                let success = try await storeKitManager.presentOfferCodeRedeemSheet()
                result(success)
            } catch {
                result(FlutterError(code: "present_offer_code_redeem_sheet_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // 请求应用评分
    private func requestReview() {
        storeKitManager.requestReview()
    }

    // 处理状态变化
    private func handleStateChanged(_ state: StoreKitState) {
        let stateDict = StoreKitStateConverter.toDictionary(state)
        stateEventSink?(stateDict)
    }
    
    // 处理产品加载
    private func handleProductsLoaded(_ products: [Product]) {
        let productsDict = ProductConverter.toDictionaryArray(products)
        productsEventSink?(productsDict)
    }
    
    // 处理交易更新
    private func handleTransactionsUpdated(_ purchasedTransactions: [Transaction], _ latestTransactions: [Transaction]) {
        let purchasedTransactionsDict = TransactionConverter.toDictionaryArray(purchasedTransactions)
        let latestTransactionsDict = TransactionConverter.toDictionaryArray(latestTransactions)
        transactionsEventSink?([
            "purchasedTransactions": purchasedTransactionsDict,
            "latestTransactions": latestTransactionsDict
        ])
    }
}

extension InappPurchasePlugin: FlutterStreamHandler {
    // FlutterStreamHandler协议实现
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if let channelName = arguments as? String {
            switch channelName {
            case InappPurchasePlugin.stateEventChannelName:
                stateEventSink = events
            case InappPurchasePlugin.productsEventChannelName:
                productsEventSink = events
            case InappPurchasePlugin.transactionsEventChannelName:
                transactionsEventSink = events
            default:
                break
            }
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if let channelName = arguments as? String {
            switch channelName {
            case InappPurchasePlugin.stateEventChannelName:
                stateEventSink = nil
            case InappPurchasePlugin.productsEventChannelName:
                productsEventSink = nil
            case InappPurchasePlugin.transactionsEventChannelName:
                transactionsEventSink = nil
            default:
                break
            }
        }
        return nil
    }
}