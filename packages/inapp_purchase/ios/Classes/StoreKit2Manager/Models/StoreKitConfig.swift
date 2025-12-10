//
//  StoreKitConfig.swift
//  StoreKit2Manager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation

/// StoreKit 配置模型
public struct StoreKitConfig {
    /// 产品ID数组
    public let productIds: [String]
    
    /// 终生会员ID
    public let lifetimeIds: [String]
    
    /// 非续订订阅的过期天数（从购买日期开始计算）
    /// 如果为 nil，则表示非续订订阅永不过期
    public let nonRenewableExpirationDays: Int?
    
    /// 是否自动排序产品（按价格从低到高）
    public let autoSortProducts: Bool
    
    /// 初始化配置
    /// - Parameters:
    ///   - productIds: 产品ID数组
    ///   - nonRenewableExpirationDays: 非续订订阅过期天数，默认为 365 天
    ///   - autoSortProducts: 是否自动排序产品，默认为 true
    public init(
        productIds: [String],
        lifetimeIds: [String],
        nonRenewableExpirationDays: Int? = 365,
        autoSortProducts: Bool = true
    ) {
        self.productIds = productIds
        self.lifetimeIds = lifetimeIds
        self.nonRenewableExpirationDays = nonRenewableExpirationDays
        self.autoSortProducts = autoSortProducts
    }
}
