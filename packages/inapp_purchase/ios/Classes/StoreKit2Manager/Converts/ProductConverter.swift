//
//  ProductConverter.swift
//  StoreKit2Manager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit

/// Product 转换器
/// 将 Product 对象转换为可序列化的基础数据类型（Dictionary/JSON）
public struct ProductConverter {
    
    /// 将 Product 转换为 Dictionary（可序列化为 JSON）
    /// - Parameter product: Product 对象
    /// - Returns: Dictionary 对象，包含所有产品信息
    public static func toDictionary(_ product: Product) -> [String: Any] {
        var dict: [String: Any] = [:]
        
        // 基本信息（确保都是字符串类型）
        dict["id"] = product.id
        dict["displayName"] = product.displayName
        dict["description"] = product.description
        
        // 价格信息
        let priceDecimal = product.price
        let priceDouble = NSDecimalNumber(decimal: priceDecimal).doubleValue
        dict["price"] = Double(String(format: "%.2f", priceDouble)) ?? priceDouble
        dict["displayPrice"] = product.displayPrice
        
        // 产品类型
        dict["type"] = productTypeToString(product.type)
        
        // 家庭共享
        dict["isFamilyShareable"] = product.isFamilyShareable
        
        // JSON 表示（可选，可能很大，通常用于服务器验证）
        // 注意：jsonRepresentation 是 Data 类型，转换为 Base64 字符串以便 JSON 序列化
        let jsonData = product.jsonRepresentation
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            dict["jsonRepresentation"] = jsonString
        } else {
            dict["jsonRepresentation"] = ""
        }
        
        // 订阅信息（如果有）
        if let subscription = product.subscription {
            dict["subscription"] = SubscriptionConverter.subscriptionInfoToDictionary(subscription, product: product)
        } else {
            dict["subscription"] = NSNull()
        }
        
        return dict
    }
    
    /// 将 Product 数组转换为 Dictionary 数组
    /// - Parameter products: Product 数组
    /// - Returns: Dictionary 数组
    public static func toDictionaryArray(_ products: [Product]) -> [[String: Any]] {
        return products.map { toDictionary($0) }
    }
    
    /// 将 Product 转换为 JSON 字符串
    /// - Parameter product: Product 对象
    /// - Returns: JSON 字符串
    public static func toJSONString(_ product: Product) -> String? {
        let dict = toDictionary(product)
        return dictionaryToJSONString(dict)
    }
    
    /// 将 Product 数组转换为 JSON 字符串
    /// - Parameter products: Product 数组
    /// - Returns: JSON 字符串
    public static func toJSONString(_ products: [Product]) -> String? {
        let array = toDictionaryArray(products)
        return arrayToJSONString(array)
    }
    
    // MARK: - 私有方法
    
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
    
    /// Dictionary 转 JSON 字符串
    internal static func dictionaryToJSONString(_ dict: [String: Any]) -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    /// Array 转 JSON 字符串
    internal static func arrayToJSONString(_ array: [[String: Any]]) -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: array, options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}

