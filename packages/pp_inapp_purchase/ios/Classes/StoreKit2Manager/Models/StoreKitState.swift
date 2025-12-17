//
//  StoreKitState.swift
//  StoreKit2Manager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit

/// StoreKit 状态枚举
public enum StoreKitState {
    /// 空闲状态
    case idle

    /// 未完成任务已执行完成
    case unfinishedCompelted
    
    /// 正在加载产品
    case loadingProducts
    
    /// 正在加载已购买产品
    case loadingPurchases
    
    /// 已购买产品加载完成
    case purchasesLoaded
    
    /// 正在购买指定产品，返回：产品ID
    case purchasing(String)
    
    /// 购买待处理（需要用户操作），返回：产品ID
    case purchasePending(String)
    
    /// 用户取消购买，返回：产品ID
    case purchaseCancelled(String)
    
    /// 购买成功，返回：产品ID
    case purchaseSuccess(String)
    
    /// 购买失败，返回：产品ID, 错误描述
    case purchaseFailed(String, String)
    
    /// 购买已退款，返回：产品ID
    case purchaseRefunded(String)
    
    /// 购买已撤销，返回：产品ID
    case purchaseRevoked(String)
    
    /// 正在恢复购买
    case restoringPurchases
    
    /// 恢复购买成功
    case restorePurchasesSuccess
    
    /// 恢复购买失败，返回：错误描述
    case restorePurchasesFailed(String)
    
    /// 订阅已取消，返回：产品ID, 是否在有效订阅期间内但在免费试用期取消
    /// - Note: isSubscribedButFreeTrailCancelled 为 true 表示产品或交易订单是在有效订阅期间内，但是在免费试用期取消了订阅
    case subscriptionCancelled(String, isSubscribedButFreeTrailCancelled: Bool)
    
    /// 发生错误，返回：触发位置，描述说明，错误对战详情
    case error(String, String, String)
}

