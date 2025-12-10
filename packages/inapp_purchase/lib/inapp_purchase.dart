import 'inapp_purchase_platform_interface.dart';
import 'src/product.dart';
import 'src/transaction.dart';

/// 应用内购插件主类
class InappPurchase {
  /// 获取平台版本
  Future<String?> getPlatformVersion() {
    return InappPurchasePlatform.instance.getPlatformVersion();
  }

  /// 配置应用内购
  ///
  /// [productIds] - 所有产品ID列表
  /// [lifetimeIds] - 终身会员产品ID列表
  /// [nonRenewableExpirationDays] - 非续订订阅的过期天数，默认7天
  /// [autoSortProducts] - 是否自动按价格排序产品
  Future<void> configure({
    required List<String> productIds,
    required List<String> lifetimeIds,
    int nonRenewableExpirationDays = 7,
    bool autoSortProducts = true,
  }) {
    return InappPurchasePlatform.instance.configure(
      productIds: productIds,
      lifetimeIds: lifetimeIds,
      nonRenewableExpirationDays: nonRenewableExpirationDays,
      autoSortProducts: autoSortProducts,
    );
  }

  /// 获取所有产品信息
  Future<List<Product>> getAllProducts() {
    return InappPurchasePlatform.instance.getAllProducts();
  }

  /// 获取非消耗型产品信息
  Future<List<Product>> getNonConsumablesProducts() {
    return InappPurchasePlatform.instance.getNonConsumablesProducts();
  }

  /// 获取消耗型产品信息
  Future<List<Product>> getConsumablesProducts() {
    return InappPurchasePlatform.instance.getConsumablesProducts();
  }

  /// 获取非自动续订订阅产品信息
  Future<List<Product>> getNonRenewablesProducts() {
    return InappPurchasePlatform.instance.getNonRenewablesProducts();
  }

  /// 获取自动续订订阅产品信息
  Future<List<Product>> getAutoRenewablesProducts() {
    return InappPurchasePlatform.instance.getAutoRenewablesProducts();
  }

  /// 获取产品信息
  Future<Product?> getProduct({required String productId}) {
    return InappPurchasePlatform.instance.getProduct(productId: productId);
  }

  /// 购买指定产品
  ///
  /// [productId] - 要购买的产品ID
  Future<void> purchase({required String productId}) {
    return InappPurchasePlatform.instance.purchase(productId: productId);
  }

  /// 恢复购买
  Future<void> restorePurchases() {
    return InappPurchasePlatform.instance.restorePurchases();
  }

  /// 刷新购买交易信息
  Future<void> refreshPurchases() {
    return InappPurchasePlatform.instance.refreshPurchases();
  }

  /// 获取有当前有效购买交易信息
  Future<List<Transaction>> getValidPurchasedTransactions() {
    return InappPurchasePlatform.instance.getValidPurchasedTransactions();
  }

  /// 获取每个产品的最新交易信息(包含已过期交易，每个ID对应一个交易)
  Future<List<Transaction>> getLatestTransactions() {
    return InappPurchasePlatform.instance.getLatestTransactions();
  }

  /// 检查产品是否已购买
  ///
  /// [productId] - 要检查的产品ID
  /// 返回 true 表示已购买，false 表示未购买
  Future<bool> isPurchased({required String productId}) {
    return InappPurchasePlatform.instance.isPurchased(productId: productId);
  }

  /// 检查产品是否通过家庭共享获得
  ///
  /// [productId] - 要检查的产品ID
  /// 返回 true 表示通过家庭共享获得，false 表示不是
  Future<bool> isFamilyShared({required String productId}) {
    return InappPurchasePlatform.instance.isFamilyShared(productId: productId);
  }

  /// 检查是否符合享受介绍性优惠资格
  Future<bool> isEligibleForIntroOffer({required String productId}) {
    return InappPurchasePlatform.instance.isEligibleForIntroOffer(
      productId: productId,
    );
  }

  /// 检查订阅状态
  Future<bool> checkSubscriptionStatus() {
    return InappPurchasePlatform.instance.checkSubscriptionStatus();
  }

  /// 获取VIP订阅产品的标题
  ///
  /// [productId] - 产品ID
  /// [periodType] - 周期类型
  /// [langCode] - 语言代码
  Future<String> getProductForVipTitle({
    required String productId,
    required SubscriptionPeriodType periodType,
    required String langCode,
  }) {
    return InappPurchasePlatform.instance.getProductForVipTitle(
      productId: productId,
      periodType: periodType.name,
      langCode: langCode,
    );
  }

  /// 获取VIP订阅产品的副标题
  ///
  /// [productId] - 产品ID
  /// [periodType] - 周期类型
  /// [langCode] - 语言代码
  Future<String> getProductForVipSubtitle({
    required String productId,
    required SubscriptionPeriodType periodType,
    required String langCode,
  }) {
    return InappPurchasePlatform.instance.getProductForVipSubtitle(
      productId: productId,
      periodType: periodType.name,
      langCode: langCode,
    );
  }

  /// 获取VIP订阅产品的按钮文本
  ///
  /// [productId] - 产品ID
  /// [langCode] - 语言代码
  Future<String> getProductForVipButtonText({
    required String productId,
    required String langCode,
  }) {
    return InappPurchasePlatform.instance.getProductForVipButtonText(
      productId: productId,
      langCode: langCode,
    );
  }

  /// 打开订阅管理页面
  Future<void> showManageSubscriptionsSheet() {
    return InappPurchasePlatform.instance.showManageSubscriptionsSheet();
  }

  /// 打开介绍性优惠码兑换页面
  Future<bool> presentOfferCodeRedeemSheet() {
    return InappPurchasePlatform.instance.presentOfferCodeRedeemSheet();
  }

  /// 请求应用内评价
  void requestReview() {
    InappPurchasePlatform.instance.requestReview();
  }

  /// 状态变化流
  Stream<Map<String, dynamic>> get onStateChanged {
    return InappPurchasePlatform.instance.onStateChanged;
  }

  /// 产品加载完成流
  Stream<List<Map<String, dynamic>>> get onProductsLoaded {
    return InappPurchasePlatform.instance.onProductsLoaded;
  }

  /// 交易更新流
  Stream<Map<String, dynamic>> get onPurchasedTransactionsUpdated {
    return InappPurchasePlatform.instance.onPurchasedTransactionsUpdated;
  }
}

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
