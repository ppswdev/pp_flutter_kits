//
//  SubscriptionConverter.swift
//  StoreKit2Manager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit

/// 订阅相关转换器
/// 将订阅相关的对象转换为可序列化的基础数据类型（Dictionary/JSON）
public struct SubscriptionConverter {
    
    // MARK: - SubscriptionInfo
    
    /// 将 SubscriptionInfo 转换为 Dictionary（自动从 subscription 中获取 isSubscribedButFreeTrailCancelled）
    /// - Parameters:
    ///   - subscription: SubscriptionInfo 对象
    ///   - product: 关联的 Product 对象（可选，用于日志）
    /// - Returns: Dictionary 对象，包含所有订阅信息（包括 isSubscribedButFreeTrailCancelled）
    public static func subscriptionInfoToDictionary(_ subscription: Product.SubscriptionInfo, product: Product? = nil) async -> [String: Any] {
        var dict: [String: Any] = [:]
        
        // 订阅组ID
        dict["subscriptionGroupID"] = subscription.subscriptionGroupID
        
        // 订阅周期
        dict["subscriptionPeriodCount"] = subscription.subscriptionPeriod.value
        dict["subscriptionPeriodUnit"] = subscriptionPeriodUnitToString(subscription.subscriptionPeriod.unit)
        
        // 介绍性优惠（如果有）
        if let introOffer = subscription.introductoryOffer {
            dict["introductoryOffer"] = subscriptionOfferToDictionary(introOffer)
        } else {
            dict["introductoryOffer"] = NSNull()
        }
        
        // 促销优惠列表
        dict["promotionalOffers"] = subscription.promotionalOffers.map { subscriptionOfferToDictionary($0) }
        
        // 赢回优惠列表（iOS 18.0+）
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
            dict["winBackOffers"] = subscription.winBackOffers.map { subscriptionOfferToDictionary($0) }
        } else {
            dict["winBackOffers"] = []
        }
        
        // 从 subscription 中获取 isSubscribedButFreeTrailCancelled
        // 含义：产品或交易订单是在有效订阅期间内，但是在免费试用期取消了订阅时这个值为true，默认为false
        dict["isSubscribedButFreeTrailCancelled"] = await isSubscribedButFreeTrailCancelled(subscription, product: product)
        
        return dict
    }
    
    /// 判断订阅是否在有效订阅期间内，但是在免费试用期取消了订阅
    /// - Parameters:
    ///   - subscription: SubscriptionInfo 对象
    ///   - product: 关联的 Product 对象（可选，用于日志）
    /// - Returns: 如果是在有效订阅期间内且在免费试用期取消返回 true，否则返回 false
    /// - Note: 只有在订阅状态为 .subscribed（有效订阅）且已取消（willAutoRenew == false）且在免费试用期时，才返回 true
    private static func isSubscribedButFreeTrailCancelled(_ subscription: Product.SubscriptionInfo, product: Product? = nil) async -> Bool {
        do {
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
            let productId = product?.id ?? "unknown"
            print("获取订阅状态失败: \(productId), 错误: \(error)")
            return false
        }
    }
    
    // MARK: - RenewalInfo
    
    /// 将 RenewalInfo 转换为 Dictionary
    /// - Parameter renewalInfo: RenewalInfo 对象
    /// - Returns: Dictionary 对象
    public static func renewalInfoToDictionary(_ renewalInfo: Product.SubscriptionInfo.RenewalInfo) -> [String: Any] {
        var dict: [String: Any] = [:]
        
        // 是否自动续订
        dict["willAutoRenew"] = renewalInfo.willAutoRenew
        
        // 续订日期（如果有）
        if let renewalDate = renewalInfo.renewalDate {
            dict["renewalDate"] = dateToTimestamp(renewalDate)
        } else {
            dict["renewalDate"] = NSNull()
        }
        
        // 过期原因（如果有）
        if let expirationReason = renewalInfo.expirationReason {
            dict["expirationReason"] = expirationReasonToString(expirationReason)
        } else {
            dict["expirationReason"] = NSNull()
        }
        
        // 注意：过期日期（expirationDate）不在 RenewalInfo 中，需要从 Transaction 中获取
        
        return dict
    }
    
    /// 将 RenewalInfo 转换为 JSON 字符串
    /// - Parameter renewalInfo: RenewalInfo 对象
    /// - Returns: JSON 字符串
    public static func renewalInfoToJSONString(_ renewalInfo: Product.SubscriptionInfo.RenewalInfo) -> String? {
        let dict = renewalInfoToDictionary(renewalInfo)
        return dictionaryToJSONString(dict)
    }
    
    // MARK: - RenewalState
    
    /// 将 RenewalState 转换为字符串
    /// - Parameter state: RenewalState 对象
    /// - Returns: 字符串
    public static func renewalStateToString(_ state: Product.SubscriptionInfo.RenewalState) -> String {
        switch state {
        case .subscribed:
            return "subscribed"
        case .expired:
            return "expired"
        case .inBillingRetryPeriod:
            return "inBillingRetryPeriod"
        case .inGracePeriod:
            return "inGracePeriod"
        case .revoked:
            return "revoked"
        default:
            return "unknown"
        }
    }
    
    // MARK: - SubscriptionPeriod
    
    /// 将 SubscriptionPeriod 转换为 Dictionary
    /// - Parameter period: SubscriptionPeriod 对象
    /// - Returns: Dictionary 对象
    public static func subscriptionPeriodToDictionary(_ period: Product.SubscriptionPeriod) -> [String: Any] {
        var dict: [String: Any] = [:]
        
        dict["value"] = period.value
        dict["unit"] = subscriptionPeriodUnitToString(period.unit)
        
        return dict
    }
    
    // MARK: - SubscriptionOffer
    
    /// 将 SubscriptionOffer 转换为 Dictionary
    /// - Parameter offer: SubscriptionOffer 对象
    /// - Returns: Dictionary 对象
    private static func subscriptionOfferToDictionary(_ offer: Product.SubscriptionOffer) -> [String: Any] {
        var dict: [String: Any] = [:]
        
        // 优惠ID（介绍性优惠为 nil，确保是字符串类型）
        if let offerID = offer.id {
            dict["id"] = offerID
        } else {
            dict["id"] = NSNull()
        }
        
        // 优惠类型
        dict["type"] = subscriptionOfferTypeToString(offer.type)
        
        // 价格信息（确保是字符串类型）
        dict["displayPrice"] = String(describing: offer.displayPrice)
        dict["price"] = Double(String(format: "%.2f", NSDecimalNumber(decimal: offer.price).doubleValue)) ?? NSDecimalNumber(decimal: offer.price).doubleValue
        
        // 支付模式
        dict["paymentMode"] = paymentModeToString(offer.paymentMode)
        
        // 优惠周期
        dict["periodCount"] = offer.period.value
        dict["periodUnit"] = subscriptionPeriodUnitToString(offer.period.unit)
        
        // 周期数量
        dict["offerPeriodCount"] = offer.periodCount
        
        return dict
    }
    
    // MARK: - 私有方法
    
    /// 日期转时间戳（毫秒）
    private static func dateToTimestamp(_ date: Date) -> Int64 {
        return Int64(date.timeIntervalSince1970 * 1000)
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
        @unknown default:
            return "unknown"
        }
    }
    
    /// 优惠类型转字符串
    private static func subscriptionOfferTypeToString(_ type: Product.SubscriptionOffer.OfferType) -> String {
        switch type {
        case .introductory:
            return "introductory"
        case .promotional:
            return "promotional"
        default:
            if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
                if type == .winBack {
                    return "winBack"
                }
            }
            return "unknown"
        }
    }
    
    /// 支付模式转字符串
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
    
    /// 过期原因转字符串
    private static func expirationReasonToString(_ reason: Product.SubscriptionInfo.RenewalInfo.ExpirationReason) -> String {
        // ExpirationReason 的具体枚举值可能因 iOS 版本而异
        // 使用 String(describing:) 作为后备方案
        let reasonString = String(describing: reason)
        // 移除命名空间前缀，只保留枚举值名称
        if let lastDot = reasonString.lastIndex(of: ".") {
            let value = String(reasonString[reasonString.index(after: lastDot)...])
            return value
        }
        return reasonString
    }
    
    /// Dictionary 转 JSON 字符串
    private static func dictionaryToJSONString(_ dict: [String: Any]) -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
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

