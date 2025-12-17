//
//  TransactionConverter.swift
//  StoreKit2Manager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit

/// Transaction 转换器
/// 将 Transaction 对象转换为可序列化的基础数据类型（Dictionary/JSON）
public struct TransactionConverter {
    
    /// 将 Transaction 转换为 Dictionary（可序列化为 JSON，自动从 productID 查询 isSubscribedButFreeTrailCancelled）
    /// - Parameter transaction: Transaction 对象
    /// - Returns: Dictionary 对象，包含所有交易信息（包括 isSubscribedButFreeTrailCancelled）
    public static func toDictionary(_ transaction: Transaction) async -> [String: Any] {
        var dict: [String: Any] = [:]
        
        // 基本信息
        dict["id"] = String(transaction.id)
        dict["productID"] = transaction.productID
        // 产品类型
        dict["productType"] = productTypeToString(transaction.productType)
        // 交易价格（如果有）
        if let price = transaction.price {
            dict["price"] = Double(String(format: "%.2f", NSDecimalNumber(decimal: price).doubleValue)) ?? NSDecimalNumber(decimal: price).doubleValue
        } else {
            dict["price"] = 0.00
        }
        // 货币代码（iOS 16.0+）
        if #available(iOS 16.0, *) {
            if let currency = transaction.currency {
                // 确保是字符串类型
                dict["currency"] = String(describing: currency)
            } else {
                dict["currency"] = NSNull()
            }
        } else {
            dict["currency"] = NSNull()
        }
        // 所有权类型
        dict["ownershipType"] = ownershipTypeToString(transaction.ownershipType)
        
        // 原始交易ID
        dict["originalID"] = String(transaction.originalID)
        
        // 原始购买日期
        dict["originalPurchaseDate"] = dateToTimestamp(transaction.originalPurchaseDate)
        
        dict["purchaseDate"] = dateToTimestamp(transaction.purchaseDate)
        // 购买数量
        dict["purchasedQuantity"] = transaction.purchasedQuantity
        
        // 交易原因（iOS 17.0+，表示购买还是续订）
        if #available(iOS 17.0, *) {
            dict["purchaseReason"] = transactionReasonToString(transaction.reason)
        } else {
            dict["purchaseReason"] = ""
        }
        
        // 订阅组ID（如果有，仅订阅产品，确保是字符串类型）
        if let subscriptionGroupID = transaction.subscriptionGroupID {
            dict["subscriptionGroupID"] = String(describing: subscriptionGroupID)
        } else {
            dict["subscriptionGroupID"] = NSNull()
        }
        
        // 过期日期（如果有）
        if let expirationDate = transaction.expirationDate {
            dict["expirationDate"] = dateToTimestamp(expirationDate)
        } else {
            dict["expirationDate"] = NSNull()
        }
        
        // 是否升级
        dict["isUpgraded"] = transaction.isUpgraded
        
        // 撤销日期（如果有）
        if let revocationDate = transaction.revocationDate {
            dict["hasRevocation"] = true
            dict["revocationDate"] = dateToTimestamp(revocationDate)
        } else {
            dict["hasRevocation"] = false
            dict["revocationDate"] = NSNull()
        }
        
        // 撤销原因
        if let revocationReason = transaction.revocationReason {
            dict["revocationReason"] = revocationReasonToString(revocationReason)
        } else {
            dict["revocationReason"] = NSNull()
        }
        
        // 环境信息（iOS 16.0+）
        if #available(iOS 16.0, *) {
            dict["environment"] = environmentToString(transaction.environment)
        } else {
            dict["environment"] = "unknown"
        }
        
        // 应用账户令牌（如果有）
        if let appAccountToken = transaction.appAccountToken {
            dict["appAccountToken"] = appAccountToken.uuidString
        } else {
            dict["appAccountToken"] = ""
        }
        
        // 应用交易ID（iOS 18.4+，确保是字符串类型）
        if #available(iOS 18.4, macOS 15.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *) {
            dict["appBundleID"] = String(describing: transaction.appBundleID)
            dict["appTransactionID"] = transaction.appTransactionID
        } else {
            dict["appTransactionID"] = NSNull()
            dict["appBundleID"] = NSNull()
        }
        
        // 签名日期
        dict["signedDate"] = dateToTimestamp(transaction.signedDate)
        
        // 商店区域（iOS 17.0+）
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *) {
            let storefront = transaction.storefront
            dict["storefrontId"] = storefront.id
            dict["storefrontCountryCode"] = storefront.countryCode
            if let currency = storefront.currency {
                dict["storefrontCurrency"] = String(describing: currency)
            } else {
                dict["storefrontCurrency"] = ""
            }
        } else {
            dict["storefrontId"] = ""
            dict["storefrontCountryCode"] = ""
            dict["storefrontCurrency"] = ""
        }
        
        // Web订单行项目ID（如果有）
        if let webOrderLineItemID = transaction.webOrderLineItemID {
            dict["webOrderLineItemID"] = webOrderLineItemID
        } else {
            dict["webOrderLineItemID"] = ""
        }
        
        // 设备验证
        dict["deviceVerification"] = transaction.deviceVerification.base64EncodedString()
        
        // 设备验证Nonce
        dict["deviceVerificationNonce"] = transaction.deviceVerificationNonce.uuidString
        
        // 优惠信息
        dict["offer"] = offerToDictionary(from: transaction)
        
        // 高级商务信息（iOS 18.4+）
        // 注意：Transaction.AdvancedCommerceInfo 的具体结构需要根据实际 API 调整
        // 暂不处理
        
        // 从 transaction.productID 查询是否在有效订阅期间内，但是在免费试用期取消了订阅
        // 只有自动续订订阅才需要查询
        // 含义：产品或交易订单是在有效订阅期间内，但是在免费试用期取消了订阅时这个值为true，默认为false
        if transaction.productType == .autoRenewable {
            dict["isSubscribedButFreeTrailCancelled"] = await isSubscribedButFreeTrailCancelledForProduct(productID: transaction.productID)
        } else {
            dict["isSubscribedButFreeTrailCancelled"] = false
        }
        
        return dict
    }
    
    /// 将 Transaction 数组转换为 Dictionary 数组
    /// - Parameter transactions: Transaction 数组
    /// - Returns: Dictionary 数组
    public static func toDictionaryArray(_ transactions: [Transaction]) async -> [[String: Any]] {
        return await withTaskGroup(of: [String: Any].self) { group in
            for transaction in transactions {
                group.addTask {
                    await toDictionary(transaction)
                }
            }
            
            var result: [[String: Any]] = []
            for await dict in group {
                result.append(dict)
            }
            return result
        }
    }
    
    /// 将 Transaction 转换为 JSON 字符串
    /// - Parameter transaction: Transaction 对象
    /// - Returns: JSON 字符串
    public static func toJSONString(_ transaction: Transaction) async -> String? {
        let dict = await toDictionary(transaction)
        return dictionaryToJSONString(dict)
    }
    
    /// 将 Transaction 数组转换为 JSON 字符串
    /// - Parameter transactions: Transaction 数组
    /// - Returns: JSON 字符串
    public static func toJSONString(_ transactions: [Transaction]) async -> String? {
        let array = await toDictionaryArray(transactions)
        return arrayToJSONString(array)
    }
    
    // MARK: - 私有方法
    
    /// 日期转时间戳（毫秒）
    private static func dateToTimestamp(_ date: Date) -> Int64 {
        return Int64(date.timeIntervalSince1970 * 1000)
    }
    
    /// 产品类型转字符串
    private static func productTypeToString(_ type: Product.ProductType) -> String {
        switch type {
        case .consumable:
            return "consumable"
        case .nonConsumable:
            return "nonConsumable"
        case .autoRenewable:
            return "autoRenewable"
        case .nonRenewable:
            return "nonRenewable"
        default:
            return "unknown"
        }
    }
    
    /// 所有权类型转字符串
    private static func ownershipTypeToString(_ type: Transaction.OwnershipType) -> String {
        switch type {
        case .purchased:
            return "purchased"
        case .familyShared:
            return "familyShared"
        default:
            return "unknown"
        }
    }
    
    /// 环境转字符串
    @available(iOS 16.0, *)
    private static func environmentToString(_ environment: AppStore.Environment) -> String {
        switch environment {
        case .production:
            return "production"
        case .sandbox:
            return "sandbox"
        case .xcode:
            return "xcode"
        default:
            return "unknown"
        }
    }
    
    /// 交易原因转字符串
    @available(iOS 17.0, *)
    private static func transactionReasonToString(_ reason: Transaction.Reason) -> String {
        switch reason {
        case .purchase:
            return "purchase"
        case .renewal:
            return "renewal"
        default:
            return "unknown"
        }
    }
    
    /// 撤销原因转字符串
    private static func revocationReasonToString(_ reason: Transaction.RevocationReason) -> String {
        return extractEnumValueName(from: reason)
    }
    
    /// 从枚举值中提取名称（移除命名空间前缀）
    /// - Parameter value: 任意类型
    /// - Returns: 枚举值名称字符串
    private static func extractEnumValueName<T>(from value: T) -> String {
        let valueString = String(describing: value)
        // 移除命名空间前缀（如 "Transaction.OfferType.introductory" -> "introductory"）
        if let lastDot = valueString.lastIndex(of: ".") {
            return String(valueString[valueString.index(after: lastDot)...])
        }
        return valueString
    }
    
    /// 交易优惠类型转字符串（已废弃，iOS 15.0-17.1）
    @available(iOS 15.0, *)
    private static func transactionOfferTypeDeprecatedToString(_ type: Transaction.OfferType) -> String {
        switch type {
        case .introductory:
            return "introductory"
        case .promotional:
            return "promotional"
        case .code:
            return "code"
        default:
            return "unknown"
        }
    }
    
    /// 支付模式转字符串（用于 Product.SubscriptionOffer.PaymentMode）
    private static func paymentModeToString(_ mode: Product.SubscriptionOffer.PaymentMode) -> String {
        switch mode {
        case .freeTrial:
            return "freeTrial"
        case .payAsYouGo:
            return "payAsYouGo"
        case .payUpFront:
            return "payUpFront"
        default:
            return "unknown"
        }
    }
    
    // MARK: - Offer 转换方法
    
    /// 交易优惠类型转字符串（用于 Transaction.Offer，iOS 17.2+）
    @available(iOS 17.2, *)
    private static func transactionOfferTypeToString(_ type: Transaction.OfferType) -> String {
        // 使用 if-else 判断，因为 switch 可能无法处理所有情况
        if type == .introductory {
            return "introductory"
        } else if type == .promotional {
            return "promotional"
        } else if type == .code {
            return "code"
        } else {
            // iOS 18.0+ 支持 winBack
            if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
                if type == .winBack {
                    return "winBack"
                }
            }
            return "unknown"
        }
    }
    
    /// 交易优惠支付模式转字符串（用于 Transaction.Offer.PaymentMode）
    @available(iOS 17.2, *)
    private static func transactionOfferPaymentModeToString(_ mode: Transaction.Offer.PaymentMode) -> String {
        switch mode {
        case .freeTrial:
            return "freeTrial"
        case .payAsYouGo:
            return "payAsYouGo"
        case .payUpFront:
            return "payUpFront"
        default:
            return "unknown"
        }
    }
    
    /// 将 Transaction 的优惠信息转换为 Dictionary
    /// - Parameter transaction: Transaction 对象
    /// - Returns: 优惠信息字典，如果没有优惠则返回 NSNull
    private static func offerToDictionary(from transaction: Transaction) -> Any {
        // iOS 17.2+ 使用新的 offer 属性
        if #available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, *) {
            return modernOfferToDictionary(from: transaction)
        }
        // iOS 15.0 - iOS 17.1 使用已废弃的属性
        else if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            return deprecatedOfferToDictionary(from: transaction)
        }
        // iOS 15.0 以下版本不支持优惠信息
        else {
            return NSNull()
        }
    }
    
    /// 使用新的 offer 属性转换优惠信息（iOS 17.2+）
    @available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, *)
    private static func modernOfferToDictionary(from transaction: Transaction) -> Any {
        guard let offer = transaction.offer else {
            return NSNull()
        }
        
        var offerDict: [String: Any] = [:]
        
        // 优惠类型
        offerDict["type"] = transactionOfferTypeToString(offer.type)
        
        // 优惠ID
        if let offerID = offer.id {
            offerDict["id"] = offerID
        } else {
            offerDict["id"] = NSNull()
        }
        
        // 支付模式（使用自定义方法）
        if let paymentMode = offer.paymentMode {
            offerDict["paymentMode"] = transactionOfferPaymentModeToString(paymentMode)
        } else {
            offerDict["paymentMode"] = NSNull()
        }
        
        // 优惠周期（iOS 18.4+）
        offerDict["periodCount"] = 0
        offerDict["periodUnit"] = ""
        if #available(iOS 18.4, macOS 15.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *) {
            if let period = offer.period {
                offerDict["periodCount"] = period.value
                offerDict["periodUnit"] = subscriptionPeriodUnitToString(period.unit)
            }
        }
        
        return offerDict
    }
    
    /// 使用已废弃的属性转换优惠信息（iOS 15.0 - iOS 17.1）
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    private static func deprecatedOfferToDictionary(from transaction: Transaction) -> Any {
        guard let offerType = transaction.offerType else {
            return NSNull()
        }
        
        var offerDict: [String: Any] = [:]
        
        // 优惠类型
        offerDict["type"] = transactionOfferTypeDeprecatedToString(offerType)
        
        // 优惠ID
        if let offerID = transaction.offerID {
            offerDict["id"] = String(describing: offerID)
        } else {
            offerDict["id"] = NSNull()
        }
        
        // 支付模式（字符串表示）
        if let paymentMode = transaction.offerPaymentModeStringRepresentation {
            offerDict["paymentMode"] = paymentMode
        } else {
            offerDict["paymentMode"] = NSNull()
        }
        
        // 优惠周期（iOS 15.0 - iOS 18.3 使用字符串，iOS 18.4+ 已废弃）
        if #available(iOS 18.4, macOS 15.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *) {
            // iOS 18.4+ 已废弃 offerPeriodStringRepresentation，返回 NSNull
            offerDict["period"] = NSNull()
        } else {
            // iOS 15.0 - iOS 18.3 使用字符串表示
            if let period = transaction.offerPeriodStringRepresentation {
                offerDict["period"] = period
            } else {
                offerDict["period"] = NSNull()
            }
        }
        
        return offerDict
    }
    
    /// 订阅周期转 Dictionary
    private static func subscriptionPeriodToDictionary(_ period: Product.SubscriptionPeriod) -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["value"] = period.value
        dict["unit"] = subscriptionPeriodUnitToString(period.unit)
        return dict
    }
    
    /// 订阅周期单位转字符串
    private static func subscriptionPeriodUnitToString(_ unit: Product.SubscriptionPeriod.Unit) -> String {
        switch unit {
        case .day:
            return "day"
        case .week:
            return "week"
        case .month:
            return "month"
        case .year:
            return "year"
        default:
            return "unknown"
        }
    }
    
    // 注意：Transaction.AdvancedCommerceProduct 类型可能不存在，已移除此方法
    // 如果需要，可以直接使用 jsonRepresentation
    
    /// Dictionary 转 JSON 字符串
    private static func dictionaryToJSONString(_ dict: [String: Any]) -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    /// Array 转 JSON 字符串
    private static func arrayToJSONString(_ array: [[String: Any]]) -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: array, options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    /// 判断指定 productID 的订阅是否在有效订阅期间内，但是在免费试用期取消了订阅
    /// - Parameter productID: 产品ID
    /// - Returns: 如果是在有效订阅期间内且在免费试用期取消返回 true，否则返回 false
    /// - Note: 只有在订阅状态为 .subscribed（有效订阅）且已取消（willAutoRenew == false）且在免费试用期时，才返回 true
    private static func isSubscribedButFreeTrailCancelledForProduct(productID: String) async -> Bool {
        do {
            // 通过 productID 获取 Product
            guard let product = try await Product.products(for: [productID]).first else {
                return false
            }
            
            // 检查是否是订阅产品
            guard let subscription = product.subscription else {
                return false
            }
            
            // 获取订阅状态
            let statuses = try await subscription.status
            guard let currentStatus = statuses.first else {
                return false
            }
            
            // 首先检查订阅状态是否为 .subscribed（有效订阅）
            // 只有在有效订阅期间内才需要判断
            guard currentStatus.state == .subscribed else {
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
                isFreeTrial = isFreeTrialTransaction(transaction)
            }
            
            // 只有在有效订阅期间内、已取消且处于免费试用期时，才返回 true
            return isFreeTrial
        } catch {
            print("查询订阅状态失败: \(productID), 错误: \(error)")
            return false
        }
    }
    
    /// 判断 Transaction 是否在免费试用期（私有辅助方法）
    private static func isFreeTrialTransaction(_ transaction: Transaction) -> Bool {
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
}

