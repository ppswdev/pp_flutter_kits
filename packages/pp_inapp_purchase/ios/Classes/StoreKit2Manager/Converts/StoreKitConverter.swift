//
//  StoreKitConverter.swift
//  StoreKit2Manager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit

/// StoreKit 统一转换器
/// 提供统一的转换接口，方便外部调用
public struct StoreKitConverter {
    
    // MARK: - Product 转换
    
    /// 将 Product 转换为 Dictionary
    public static func productToDictionary(_ product: Product) async -> [String: Any] {
        return await ProductConverter.toDictionary(product)
    }
    
    /// 将 Product 数组转换为 Dictionary 数组
    public static func productsToDictionaryArray(_ products: [Product]) async -> [[String: Any]] {
        return await ProductConverter.toDictionaryArray(products)
    }

    /// 将 Product 转换为 JSON 字符串
    public static func productToJSONString(_ product: Product) async -> String? {
        return await ProductConverter.toJSONString(product)
    }
    
    /// 将 Product 数组转换为 JSON 字符串
    public static func productsToJSONString(_ products: [Product]) async -> String? {
        return await ProductConverter.toJSONString(products)
    }
    
    // MARK: - Transaction 转换
    
    /// 将 Transaction 转换为 Dictionary
    public static func transactionToDictionary(_ transaction: Transaction) async -> [String: Any] {
        return await TransactionConverter.toDictionary(transaction)
    }
    
    /// 将 Transaction 数组转换为 Dictionary 数组
    public static func transactionsToDictionaryArray(_ transactions: [Transaction]) async -> [[String: Any]] {
        return await TransactionConverter.toDictionaryArray(transactions)
    }
    
    /// 将 Transaction 转换为 JSON 字符串
    public static func transactionToJSONString(_ transaction: Transaction) async -> String? {
        return await TransactionConverter.toJSONString(transaction)
    }
    
    /// 将 Transaction 数组转换为 JSON 字符串
    public static func transactionsToJSONString(_ transactions: [Transaction]) async -> String? {
        return await TransactionConverter.toJSONString(transactions)
    }
    
    // MARK: - StoreKitState 转换
    
    /// 将 StoreKitState 转换为 Dictionary
    public static func stateToDictionary(_ state: StoreKitState) -> [String: Any] {
        return StoreKitStateConverter.toDictionary(state)
    }
    
    /// 将 StoreKitState 转换为 JSON 字符串
    public static func stateToJSONString(_ state: StoreKitState) -> String? {
        return StoreKitStateConverter.toJSONString(state)
    }
    
    // MARK: - RenewalInfo 转换
    
    /// 将 RenewalInfo 转换为 Dictionary
    public static func renewalInfoToDictionary(_ renewalInfo: Product.SubscriptionInfo.RenewalInfo) -> [String: Any] {
        return SubscriptionConverter.renewalInfoToDictionary(renewalInfo)
    }
    
    /// 将 RenewalInfo 转换为 JSON 字符串
    public static func renewalInfoToJSONString(_ renewalInfo: Product.SubscriptionInfo.RenewalInfo) -> String? {
        return SubscriptionConverter.renewalInfoToJSONString(renewalInfo)
    }
    
    // MARK: - RenewalState 转换
    
    /// 将 RenewalState 转换为字符串
    public static func renewalStateToString(_ state: Product.SubscriptionInfo.RenewalState) -> String {
        return SubscriptionConverter.renewalStateToString(state)
    }
    
    // MARK: - SubscriptionInfo 转换
    
    /// 将 SubscriptionInfo 转换为 Dictionary
    public static func subscriptionInfoToDictionary(_ subscription: Product.SubscriptionInfo, product: Product? = nil) async -> [String: Any] {
        return await SubscriptionConverter.subscriptionInfoToDictionary(subscription, product: product)
    }

}

