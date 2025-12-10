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
    
    /// 将 Transaction 转换为 Dictionary（可序列化为 JSON）
    /// - Parameter transaction: Transaction 对象
    /// - Returns: Dictionary 对象，包含所有交易信息
    public static func toDictionary(_ transaction: Transaction) -> [String: Any] {
        var dict: [String: Any] = [:]
        
        // 基本信息
        dict["id"] = String(transaction.id)
        dict["productID"] = transaction.productID
        dict["purchaseDate"] = dateToTimestamp(transaction.purchaseDate)
        
        // 过期日期（如果有）
        if let expirationDate = transaction.expirationDate {
            dict["expirationDate"] = dateToTimestamp(expirationDate)
        } else {
            dict["expirationDate"] = NSNull()
        }
        
        // 撤销日期（如果有）
        if let revocationDate = transaction.revocationDate {
            dict["revocationDate"] = dateToTimestamp(revocationDate)
            dict["isRefunded"] = true
            dict["isRevoked"] = true
        } else {
            dict["revocationDate"] = NSNull()
            dict["isRefunded"] = false
            dict["isRevoked"] = false
        }
        
        // 产品类型
        dict["productType"] = productTypeToString(transaction.productType)
        
        // 所有权类型
        dict["ownershipType"] = ownershipTypeToString(transaction.ownershipType)
        
        // 原始购买日期
        dict["originalPurchaseDate"] = dateToTimestamp(transaction.originalPurchaseDate)
    
        // 环境信息
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
        
        // 交易原因
        if #available(iOS 17.0, *) {
            dict["reason"] = transactionReasonToString(transaction.reason)
        } else {
            dict["reason"] = ""
        }
        
        return dict
    }
    
    /// 将 Transaction 数组转换为 Dictionary 数组
    /// - Parameter transactions: Transaction 数组
    /// - Returns: Dictionary 数组
    public static func toDictionaryArray(_ transactions: [Transaction]) -> [[String: Any]] {
        return transactions.map { toDictionary($0) }
    }
    
    /// 将 Transaction 转换为 JSON 字符串
    /// - Parameter transaction: Transaction 对象
    /// - Returns: JSON 字符串
    public static func toJSONString(_ transaction: Transaction) -> String? {
        let dict = toDictionary(transaction)
        return dictionaryToJSONString(dict)
    }
    
    /// 将 Transaction 数组转换为 JSON 字符串
    /// - Parameter transactions: Transaction 数组
    /// - Returns: JSON 字符串
    public static func toJSONString(_ transactions: [Transaction]) -> String? {
        let array = toDictionaryArray(transactions)
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
}

