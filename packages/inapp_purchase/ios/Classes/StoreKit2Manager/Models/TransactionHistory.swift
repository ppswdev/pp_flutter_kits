//
//  TransactionHistory.swift
//  StoreKit2Manager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit

/// 交易历史记录
public struct TransactionHistory {
    /// 产品ID
    public let productId: String
    
    /// 产品对象
    public let product: Product?
    
    /// 交易对象
    public let transaction: StoreKit.Transaction
    
    /// 购买日期
    public let purchaseDate: Date
    
    /// 过期日期（如果是订阅）
    public let expirationDate: Date?
    
    /// 是否已退款
    public let isRefunded: Bool
    
    /// 是否已撤销
    public let isRevoked: Bool
    
    /// 所有权类型
    public let ownershipType: StoreKit.Transaction.OwnershipType
    
    /// 交易ID
    public let transactionId: UInt64
    
    public init(
        productId: String,
        product: Product?,
        transaction: StoreKit.Transaction,
        purchaseDate: Date,
        expirationDate: Date? = nil,
        isRefunded: Bool = false,
        isRevoked: Bool = false,
        ownershipType: StoreKit.Transaction.OwnershipType,
        transactionId: UInt64
    ) {
        self.productId = productId
        self.product = product
        self.transaction = transaction
        self.purchaseDate = purchaseDate
        self.expirationDate = expirationDate
        self.isRefunded = isRefunded
        self.isRevoked = isRevoked
        self.ownershipType = ownershipType
        self.transactionId = transactionId
    }
}

// MARK: - 从 Transaction 创建
extension TransactionHistory {
    /// 从 Transaction 创建交易历史
    public static func from(_ transaction: StoreKit.Transaction, product: Product? = nil) -> TransactionHistory {
        return TransactionHistory(
            productId: transaction.productID,
            product: product,
            transaction: transaction,
            purchaseDate: transaction.purchaseDate,
            expirationDate: transaction.expirationDate,
            isRefunded: transaction.revocationDate != nil,
            isRevoked: transaction.revocationDate != nil,
            ownershipType: transaction.ownershipType,
            transactionId: transaction.id
        )
    }
}

