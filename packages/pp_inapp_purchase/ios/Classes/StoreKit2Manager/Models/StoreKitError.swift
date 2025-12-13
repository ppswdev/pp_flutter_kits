//
//  StoreKitError.swift
//  StoreKit2Manager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation

/// StoreKit 错误类型
public enum StoreKitError: Error, LocalizedError {
    /// 产品未找到
    case productNotFound(String)
    
    /// 购买失败
    case purchaseFailed(Error)
    
    /// 交易验证失败
    case verificationFailed
    
    /// 配置缺失
    case configurationMissing
    
    /// 服务未启动
    case serviceNotStarted
    
    /// 购买正在进行中
    case purchaseInProgress
    
    /// 取消订阅失败
    case cancelSubscriptionFailed(Error)
    
    /// 恢复购买失败
    case restorePurchasesFailed(Error)
    
    /// 未知错误
    case unknownError
    
    public var errorDescription: String? {
        switch self {
        case .productNotFound(let id):
            return "产品未找到: \(id)"
        case .purchaseFailed(let error):
            return "购买失败: \(error.localizedDescription)"
        case .verificationFailed:
            return "交易验证失败，可能是设备已越狱或交易数据被篡改"
        case .configurationMissing:
            return "配置缺失，请先调用 configure 方法进行配置"
        case .serviceNotStarted:
            return "服务未启动，请先调用 configure 方法"
        case .purchaseInProgress:
            return "购买正在进行中，请等待当前购买完成"
        case .cancelSubscriptionFailed(let error):
            return "取消订阅失败: \(error.localizedDescription)"
        case .restorePurchasesFailed(let error):
            return "恢复购买失败: \(error.localizedDescription)"
        case .unknownError:
            return "未知错误"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .productNotFound(let id):
            return "请检查产品ID是否正确，并确保在 App Store Connect 中已配置该产品"
        case .purchaseFailed(let error):
            return error.localizedDescription
        case .verificationFailed:
            return "交易数据无法通过 Apple 的验证，这可能是由于设备已越狱或交易数据被篡改"
        case .configurationMissing:
            return "在调用其他方法之前，必须先调用 configure(with:delegate:) 或 configure(with:onStateChanged:) 方法"
        case .serviceNotStarted:
            return "StoreKit2Manager 尚未初始化，请先调用 configure 方法"
        case .purchaseInProgress:
            return "当前有购买正在进行，请等待完成后再试"
        case .cancelSubscriptionFailed(let error):
            return (error as? LocalizedError)?.failureReason ?? error.localizedDescription
        case .restorePurchasesFailed(let error):
            return (error as? LocalizedError)?.failureReason ?? error.localizedDescription
        case .unknownError:
            return "发生了未预期的错误"
        }
    }
}

