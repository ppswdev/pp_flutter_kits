import 'package:inapp_purchase/src/product.dart';
import 'package:inapp_purchase/src/transaction.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'inapp_purchase_method_channel.dart';

/// 应用内购平台接口
abstract class InappPurchasePlatform extends PlatformInterface {
  InappPurchasePlatform() : super(token: _token);
  static final Object _token = Object();
  static InappPurchasePlatform _instance = MethodChannelInappPurchase();
  static InappPurchasePlatform get instance => _instance;
  static set instance(InappPurchasePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// 获取平台版本
  Future<String?> getPlatformVersion();

  /// 配置产品
  Future<void> configure({
    required List<String> productIds,
    required List<String> lifetimeIds,
    int nonRenewableExpirationDays = 7,
    bool autoSortProducts = true,
    bool showLog = true,
  });

  /// 获取所有产品信息
  Future<List<Product>> getAllProducts();

  /// 获取非消耗型产品信息
  Future<List<Product>> getNonConsumablesProducts();

  /// 获取消耗型产品信息
  Future<List<Product>> getConsumablesProducts();

  /// 获取非自动续订订阅产品信息
  Future<List<Product>> getNonRenewablesProducts();

  /// 获取自动续订订阅产品信息
  Future<List<Product>> getAutoRenewablesProducts();

  /// 获取产品信息
  Future<Product?> getProduct({required String productId});

  /// 购买产品
  Future<void> purchase({required String productId});

  /// 恢复购买
  Future<void> restorePurchases();

  /// 刷新购买交易信息
  Future<void> refreshPurchases();

  /// 获取有当前有效购买交易信息
  Future<List<Transaction>> getValidPurchasedTransactions();

  /// 获取每个产品的最新交易信息(包含已过期交易，每个ID对应一个交易)
  Future<List<Transaction>> getLatestTransactions();

  /// 检查产品是否已购买
  Future<bool> isPurchased({required String productId});

  /// 检查产品是否通过家庭共享获得
  Future<bool> isFamilyShared({required String productId});

  /// 检查是否符合享受介绍性优惠资格
  Future<bool> isEligibleForIntroOffer({required String productId});

  ///检查订阅状态
  Future<bool> checkSubscriptionStatus();

  /// 获取VIP订阅产品的副标题
  /// [productId] 产品ID
  Future<String> getProductForVipTitle({
    required String productId,
    required String periodType,
    required String langCode,
  });

  /// 获取VIP订阅产品的描述
  /// [productId] 产品ID
  Future<String> getProductForVipSubtitle({
    required String productId,
    required String periodType,
    required String langCode,
  });

  /// 获取VIP订阅产品的按钮文本
  /// [productId] 产品ID
  /// [langCode] 语言代码，例如"en"、"zh-Hans"等
  Future<String> getProductForVipButtonText({
    required String productId,
    required String langCode,
  });

  /// 打开订阅管理页面
  Future<void> showManageSubscriptionsSheet();

  /// 打开介绍性优惠码兑换页面
  Future<bool> presentOfferCodeRedeemSheet();

  /// 请求应用内评价
  void requestReview();

  /// 状态变化流
  Stream<Map<String, dynamic>> get onStateChanged;

  /// 产品加载完成流
  Stream<List<Map<String, dynamic>>> get onProductsLoaded;

  /// 交易更新流
  Stream<Map<String, dynamic>> get onPurchasedTransactionsUpdated;
}
