/// 订阅周期类型
enum SubscriptionPeriodType { week, month, year, lifetime }

/// 订阅按钮文案类型
enum SubscriptionButtonType {
  standard, // 标准订阅
  freeTrial, // 免费试用
  payUpFront, // 预付
  payAsYouGo, // 按需付费
  lifetime, // 终身会员
}

/// StoreKit状态枚举
class StoreKitState {
  static const idle = 'idle';
  static const loadingProducts = 'loadingProducts';
  static const productsLoaded = 'productsLoaded';
  static const loadingPurchases = 'loadingPurchases';
  static const purchasesLoaded = 'purchasesLoaded';
  static const purchasing = 'purchasing';
  static const purchaseSuccess = 'purchaseSuccess';
  static const purchasePending = 'purchasePending';
  static const purchaseCancelled = 'purchaseCancelled';
  static const purchaseFailed = 'purchaseFailed';
  static const subscriptionStatusChanged = 'subscriptionStatusChanged';
  static const restoringPurchases = 'restoringPurchases';
  static const restorePurchasesSuccess = 'restorePurchasesSuccess';
  static const restorePurchasesFailed = 'restorePurchasesFailed';
  static const purchaseRefunded = 'purchaseRefunded';
  static const purchaseRevoked = 'purchaseRevoked';
  static const subscriptionCancelled = 'subscriptionCancelled';
  static const error = 'error';
}

/// 订阅周期单位枚举
enum SubscriptionPeriodUnit { day, week, month, year, unknown }

/// 订阅优惠类型枚举
enum SubscriptionOfferType { introductory, promotional, winBack, unknown }

/// 订阅优惠支付模式枚举
enum SubscriptionOfferPaymentMode { payAsYouGo, payUpFront, freeTrial, unknown }

/// 产品类型枚举
enum ProductType {
  autoRenewable,
  nonRenewable,
  consumable,
  nonConsumable,
  unknown,
}

/// 所有权类型枚举
enum OwnershipType { purchased, familyShared, unknown }

/// 购买原因枚举
enum PurchaseReason { purchase, restore, unknown }

/// 订阅周期单位转换工具类
class SubscriptionPeriodUnitConverter {
  static SubscriptionPeriodUnit? fromString(String? unit) {
    switch (unit) {
      case 'day':
        return SubscriptionPeriodUnit.day;
      case 'week':
        return SubscriptionPeriodUnit.week;
      case 'month':
        return SubscriptionPeriodUnit.month;
      case 'year':
        return SubscriptionPeriodUnit.year;
      default:
        return SubscriptionPeriodUnit.unknown;
    }
  }

  static String? toStringValue(SubscriptionPeriodUnit? unit) {
    switch (unit) {
      case SubscriptionPeriodUnit.day:
        return 'day';
      case SubscriptionPeriodUnit.week:
        return 'week';
      case SubscriptionPeriodUnit.month:
        return 'month';
      case SubscriptionPeriodUnit.year:
        return 'year';
      default:
        return 'unknown';
    }
  }
}

/// 订阅优惠类型转换工具类
class SubscriptionOfferTypeConverter {
  static SubscriptionOfferType? fromString(String? type) {
    switch (type) {
      case 'introductory':
        return SubscriptionOfferType.introductory;
      case 'promotional':
        return SubscriptionOfferType.promotional;
      case 'winBack':
        return SubscriptionOfferType.winBack;
      default:
        return SubscriptionOfferType.unknown;
    }
  }

  static String? toStringValue(SubscriptionOfferType? type) {
    switch (type) {
      case SubscriptionOfferType.introductory:
        return 'introductory';
      case SubscriptionOfferType.promotional:
        return 'promotional';
      case SubscriptionOfferType.winBack:
        return 'winBack';
      default:
        return 'unknown';
    }
  }
}

/// 订阅优惠支付模式转换工具类
class SubscriptionOfferPaymentModeConverter {
  static SubscriptionOfferPaymentMode? fromString(String? mode) {
    switch (mode) {
      case 'payAsYouGo':
        return SubscriptionOfferPaymentMode.payAsYouGo;
      case 'payUpFront':
        return SubscriptionOfferPaymentMode.payUpFront;
      case 'freeTrial':
        return SubscriptionOfferPaymentMode.freeTrial;
      default:
        return SubscriptionOfferPaymentMode.unknown;
    }
  }

  static String? toStringValue(SubscriptionOfferPaymentMode? mode) {
    switch (mode) {
      case SubscriptionOfferPaymentMode.payAsYouGo:
        return 'payAsYouGo';
      case SubscriptionOfferPaymentMode.payUpFront:
        return 'payUpFront';
      case SubscriptionOfferPaymentMode.freeTrial:
        return 'freeTrial';
      default:
        return 'unknown';
    }
  }
}

/// 产品类型转换工具类
class ProductTypeConverter {
  static ProductType? fromString(String? type) {
    switch (type) {
      case 'autoRenewable':
        return ProductType.autoRenewable;
      case 'nonRenewable':
        return ProductType.nonRenewable;
      case 'consumable':
        return ProductType.consumable;
      case 'nonConsumable':
        return ProductType.nonConsumable;
      default:
        return ProductType.unknown;
    }
  }

  static String? toStringValue(ProductType? type) {
    switch (type) {
      case ProductType.autoRenewable:
        return 'autoRenewable';
      case ProductType.nonRenewable:
        return 'nonRenewable';
      case ProductType.consumable:
        return 'consumable';
      case ProductType.nonConsumable:
        return 'nonConsumable';
      default:
        return 'unknown';
    }
  }
}

/// 所有权类型转换工具类
class OwnershipTypeConverter {
  static OwnershipType? fromString(String? type) {
    switch (type) {
      case 'purchased':
        return OwnershipType.purchased;
      case 'familyShared':
        return OwnershipType.familyShared;
      default:
        return OwnershipType.unknown;
    }
  }

  static String? toStringValue(OwnershipType? type) {
    switch (type) {
      case OwnershipType.purchased:
        return 'purchased';
      case OwnershipType.familyShared:
        return 'familyShared';
      default:
        return 'unknown';
    }
  }
}

/// 购买原因转换工具类
class PurchaseReasonConverter {
  static PurchaseReason? fromString(String? reason) {
    switch (reason) {
      case 'purchase':
        return PurchaseReason.purchase;
      case 'restore':
        return PurchaseReason.restore;
      default:
        return PurchaseReason.unknown;
    }
  }

  static String? toStringValue(PurchaseReason? reason) {
    switch (reason) {
      case PurchaseReason.purchase:
        return 'purchase';
      case PurchaseReason.restore:
        return 'restore';
      default:
        return 'unknown';
    }
  }
}
