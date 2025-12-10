//
//  TransactionHistoryConverter.swift
//  StoreKit2Manager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit

/// TransactionHistory 转换器
/// 将 TransactionHistory 对象转换为可序列化的基础数据类型（Dictionary/JSON）
public struct TransactionHistoryConverter {
    
    /// 将 TransactionHistory 转换为 Dictionary（可序列化为 JSON）
    /// - Parameter history: TransactionHistory 对象
    /// - Returns: Dictionary 对象，包含所有交易历史信息
    public static func toDictionary(_ history: TransactionHistory) -> [String: Any] {
        var dict: [String: Any] = [:]
        
        // 基本信息
        dict["productId"] = history.productId
        dict["transactionId"] = String(history.transactionId)
        dict["purchaseDate"] = dateToTimestamp(history.purchaseDate)
        
        // 过期日期（如果有）
        if let expirationDate = history.expirationDate {
            dict["expirationDate"] = dateToTimestamp(expirationDate)
        } else {
            dict["expirationDate"] = NSNull()
        }
        
        // 退款和撤销状态
        dict["isRefunded"] = history.isRefunded
        dict["isRevoked"] = history.isRevoked
        
        // 所有权类型
        dict["ownershipType"] = ownershipTypeToString(history.ownershipType)
        
        // 产品信息（如果有）
        if let product = history.product {
            dict["product"] = ProductConverter.toDictionary(product)
        } else {
            dict["product"] = NSNull()
        }
        
        // 交易信息
        dict["transaction"] = TransactionConverter.toDictionary(history.transaction)
        
        return dict
    }
    
    /// 将 TransactionHistory 数组转换为 Dictionary 数组
    /// - Parameter histories: TransactionHistory 数组
    /// - Returns: Dictionary 数组
    public static func toDictionaryArray(_ histories: [TransactionHistory]) -> [[String: Any]] {
        return histories.map { toDictionary($0) }
    }
    
    /// 将 TransactionHistory 转换为 JSON 字符串
    /// - Parameter history: TransactionHistory 对象
    /// - Returns: JSON 字符串
    public static func toJSONString(_ history: TransactionHistory) -> String? {
        let dict = toDictionary(history)
        return dictionaryToJSONString(dict)
    }
    
    /// 将 TransactionHistory 数组转换为 JSON 字符串
    /// - Parameter histories: TransactionHistory 数组
    /// - Returns: JSON 字符串
    public static func toJSONString(_ histories: [TransactionHistory]) -> String? {
        let array = toDictionaryArray(histories)
        return arrayToJSONString(array)
    }
    
    // MARK: - 私有方法
    
    /// 日期转时间戳（毫秒）
    private static func dateToTimestamp(_ date: Date) -> Int64 {
        return Int64(date.timeIntervalSince1970 * 1000)
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

