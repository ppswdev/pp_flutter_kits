/// 订阅时长
enum SubscriptionDuration {
  week,
  month,
  year,
  lifetime,
}

/// 订阅购买状态
enum IAPPurchaseStatus {
  purchasing,
  verifying,
  verifyingFailed,
  purchased,
  canceled,
  purchaseFailed,
  restored,
  restoreFailed,
  systemError,
  crashes;

  String get text {
    switch (this) {
      case IAPPurchaseStatus.purchasing:
        return '购买中';
      case IAPPurchaseStatus.verifying:
        return '验证中';
      case IAPPurchaseStatus.verifyingFailed:
        return '验证失败';
      case IAPPurchaseStatus.purchased:
        return '购买成功';
      case IAPPurchaseStatus.canceled:
        return '取消购买';
      case IAPPurchaseStatus.purchaseFailed:
        return '购买失败';
      case IAPPurchaseStatus.restored:
        return '恢复购买成功';
      case IAPPurchaseStatus.restoreFailed:
        return '恢复购买失败';
      case IAPPurchaseStatus.systemError:
        return '系统错误';
      case IAPPurchaseStatus.crashes:
        return '崩溃';
    }
  }
}
