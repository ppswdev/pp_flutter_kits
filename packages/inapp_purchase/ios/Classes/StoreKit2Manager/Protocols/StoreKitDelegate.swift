//
//  StoreKitDelegate.swift
//  StoreKit2Manager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit

/// StoreKit 代理协议
/// 所有方法都在主线程调用
public protocol StoreKitDelegate: AnyObject {
    /// 状态更新回调
    /// - Parameters:
    ///   - manager: StoreKit2Manager 实例
    ///   - state: 新的状态
    func storeKit(_ manager: StoreKit2Manager, didUpdateState state: StoreKitState)
    
    /// 产品加载成功回调
    /// - Parameters:
    ///   - manager: StoreKit2Manager 实例
    ///   - products: 加载的产品列表
    func storeKit(_ manager: StoreKit2Manager, didLoadProducts products: [Product])
    
    /// 已购买交易订单更新回调
    /// - Parameters:
    ///   - manager: StoreKit2Manager 实例
    ///   - efficient: 已购买的交易订单（有效的交易）
    ///   - latests: 每个产品的最新交易记录
    func storeKit(_ manager: StoreKit2Manager, didUpdatePurchasedTransactions efficient: [Transaction], latests: [Transaction])
}

// MARK: - 可选方法默认实现
extension StoreKitDelegate {
    public func storeKit(_ manager: StoreKit2Manager, didUpdateState state: StoreKitState) {
        // 默认实现为空，子类可以选择性实现
    }
    
    public func storeKit(_ manager: StoreKit2Manager, didLoadProducts products: [Product]) {
        // 默认实现为空，子类可以选择性实现
    }
    
    public func storeKit(_ manager: StoreKit2Manager, didUpdatePurchasedTransactions efficient: [Transaction], latests: [Transaction]) {
        // 默认实现为空，子类可以选择性实现
    }
}

