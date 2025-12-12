//
//  StoreKitStateConverter.swift
//  StoreKit2Manager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit

/// StoreKitState 转换器
/// 将 StoreKitState 对象转换为可序列化的基础数据类型（Dictionary/JSON）
public struct StoreKitStateConverter {
    
    /// 将 StoreKitState 转换为 Dictionary（可序列化为 JSON）
    /// - Parameter state: StoreKitState 对象
    /// - Returns: Dictionary 对象，包含状态信息
    public static func toDictionary(_ state: StoreKitState) -> [String: Any] {
        var dict: [String: Any] = [:]
        
        switch state {
        case .idle:
            dict["type"] = "idle"
            
        case .loadingProducts:
            dict["type"] = "loadingProducts"
            
//        case .productsLoaded(let products):
//            dict["type"] = "productsLoaded"
//            dict["products"] = ProductConverter.toDictionaryArray(products)
            
        case .loadingPurchases:
            dict["type"] = "loadingPurchases"
            
        case .purchasesLoaded:
            dict["type"] = "purchasesLoaded"
            
        case .purchasing(let productId):
            dict["type"] = "purchasing"
            dict["productId"] = productId
            
        case .purchaseSuccess(let productId):
            dict["type"] = "purchaseSuccess"
            dict["productId"] = productId
            
        case .purchasePending(let productId):
            dict["type"] = "purchasePending"
            dict["productId"] = productId
            
        case .purchaseCancelled(let productId):
            dict["type"] = "purchaseCancelled"
            dict["productId"] = productId
            
        case .purchaseFailed(let productId, let error):
            dict["type"] = "purchaseFailed"
            dict["productId"] = productId
            dict["error"] = String(describing: error)
            
//        case .subscriptionStatusChanged(let renewalState):
//            dict["type"] = "subscriptionStatusChanged"
//            dict["renewalState"] = renewalStateToString(renewalState)
            
        case .restoringPurchases:
            dict["type"] = "restoringPurchases"
            
        case .restorePurchasesSuccess:
            dict["type"] = "restorePurchasesSuccess"
            
        case .restorePurchasesFailed(let error):
            dict["type"] = "restorePurchasesFailed"
            dict["error"] = String(describing: error)
            
        case .purchaseRefunded(let productId):
            dict["type"] = "purchaseRefunded"
            dict["productId"] = productId
            
        case .purchaseRevoked(let productId):
            dict["type"] = "purchaseRevoked"
            dict["productId"] = productId
            
        case .subscriptionCancelled(let productId):
            dict["type"] = "subscriptionCancelled"
            dict["productId"] = productId
            
        case .error(let error):
            dict["type"] = "error"
            dict["error"] = String(describing: error)
        }
        
        return dict
    }
    
    /// 将 StoreKitState 转换为 JSON 字符串
    /// - Parameter state: StoreKitState 对象
    /// - Returns: JSON 字符串
    public static func toJSONString(_ state: StoreKitState) -> String? {
        let dict = toDictionary(state)
        return dictionaryToJSONString(dict)
    }
    
    // MARK: - 私有方法
    
    /// 续订状态转字符串
    private static func renewalStateToString(_ state: Product.SubscriptionInfo.RenewalState) -> String {
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
    
    /// Dictionary 转 JSON 字符串
    private static func dictionaryToJSONString(_ dict: [String: Any]) -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}

