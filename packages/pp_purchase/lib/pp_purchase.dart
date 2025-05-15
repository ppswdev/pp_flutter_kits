import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
//import 'package:in_app_purchase_android/in_app_purchase_android.dart';
//import 'package:in_app_purchase_android/billing_client_wrappers.dart';

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

/// 购买结果
class PurchaseResult {
  final IAPPurchaseStatus status;
  final String? message;
  final dynamic data;

  PurchaseResult({
    required this.status,
    this.message,
    this.data,
  });

  T? getDataAs<T>() {
    return data is T ? data as T : null;
  }
}

typedef PurchaseCallback = void Function(PurchaseResult result);

/// 验证结果类
class VerificationResult {
  /// 验证类型：0-验证失败，1-验证成功，2-验证崩溃
  final int type;

  /// 验证消息
  final String? message;

  /// 验证成功凭据
  final Map<String, dynamic>? data;

  /// 验证错误
  final String? error;

  VerificationResult({
    required this.type,
    this.message,
    this.data,
    this.error,
  });
}

/// 订阅购买管理类
class SubsPurchase {
  /// 单例
  static final SubsPurchase _instance = SubsPurchase._internal();
  static SubsPurchase get instance => _instance;
  factory SubsPurchase() => _instance;
  SubsPurchase._internal();

  /// 产品信息映射
  final Map<String, ProductDetails> productDetailsMap = {};

  /// 已购买产品的最新交易记录
  /// key: 产品ID
  /// value: 最新的交易记录信息
  final Map<String, Map<String, dynamic>> latestPurchasedProducts = {};

  /// 所有已购买产品的交易记录
  /// key: 产品ID
  /// value: 所有交易记录信息
  List<Map<String, dynamic>> allPurchasedProducts = [];

  /// 订阅过期时间戳（单位毫秒）
  int expireTimeMs = 0;

  /// 最后一次订阅时间（单位毫秒）
  int lastPurchaseTimeMs = 0;

  /// 订阅购买实例
  final _iap = InAppPurchase.instance;

  /// 是否可用
  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  /// 是否显示日志
  bool _showLog = false;

  /// 产品ID列表
  List<String> _productIds = [];

  /// 一次性买断订阅产品
  List<String> _onetimeSubsIds = [];

  /// 验证共享密钥
  String _sharedSecret = '';

  /// 购买监听
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// 购买回调
  PurchaseCallback? _purchaseCallback;

  /// 初始化时传入产品ID
  ///
  /// [productIds] 产品ID列表
  /// [onetimeSubIds] 一次性买断订阅产品ID列表
  /// [sharedSecret] 验证共享密钥
  Future<void> initialize(List<String> productIds, List<String> onetimeSubIds,
      {required String sharedSecret, bool showLog = false}) async {
    _productIds = productIds;
    _sharedSecret = sharedSecret;
    _onetimeSubsIds = onetimeSubIds;
    _showLog = showLog;
    try {
      _isAvailable = await _iap.isAvailable();
      if (!_isAvailable) {
        splog('Store is not available');
        return;
      }
      if (Platform.isIOS || Platform.isMacOS) {
        final iosPlatformAddition =
            _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
      }
      // 清除已购买产品记录
      latestPurchasedProducts.clear();
      // 设置购买监听
      _subscription?.cancel();
      _subscription = null;
      _subscription = _iap.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: () {
          _subscription?.cancel();
        },
        onError: (error) {
          _notifyCallback(IAPPurchaseStatus.systemError,
              message: error.toString());
        },
      );
    } catch (e) {
      splog('Failed to initialize in-app purchase: $e');
      _isAvailable = false;
      _notifyCallback(IAPPurchaseStatus.crashes, message: e.toString());
    }
  }

  void splog(String message) {
    if (!_showLog) return;
    var currentStack = StackTrace.current;
    var formattedStack = currentStack.toString().split("\n")[1].trim();
    // 提取文件名、方法名和行号
    var match =
        RegExp(r'^#1\s+(.+)\s\((.+):(\d+):(\d+)\)$').firstMatch(formattedStack);
    var methodName = match?.group(1) ?? 'unknown method';
    var fileName = match?.group(2) ?? 'unknown file';
    var line = match?.group(3) ?? 'unknown line';
    print('[$fileName:$line $methodName]SubsPurchase $message');
  }

  /// 检查产品是否已购买
  ///
  /// [productId] 产品ID
  bool hasPurchased(String productId) {
    if (!_isAvailable) return false;
    final purchase = latestPurchasedProducts[productId];
    if (purchase == null) return false;
    return true;
  }

  /// 获取所有已购买的产品
  Future<Map<String, Map<String, dynamic>>> loadPurchasedProducts() async {
    if (Platform.isIOS || Platform.isMacOS) {
      try {
        splog('尝试获取本地凭证...');
        String receiptData = await SKReceiptManager.retrieveReceiptData();
        await _verifyIosReceipt(receiptData);
      } catch (e) {
        splog('没有获取到凭证 $e');
        try {
          splog('尝试刷新凭证...');
          await SKRequestMaker().startRefreshReceiptRequest();
          String receiptData = await SKReceiptManager.retrieveReceiptData();
          await _verifyIosReceipt(receiptData);
        } catch (refreshError) {
          splog('刷新凭证失败 $refreshError');
        }
      }
    } else if (Platform.isAndroid) {
      splog('Android 平台暂未实现改loadPurchasedProducts功能');
    }
    splog('loadPurchasedProducts: $latestPurchasedProducts');
    return latestPurchasedProducts;
  }

  // 加载产品信息
  Future<List<ProductDetails>> loadProducts() async {
    try {
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(_productIds.toSet());

      if (response.notFoundIDs.isNotEmpty) {
        splog('Products not found: ${response.notFoundIDs}');
      }
      productDetailsMap.clear();
      for (var product in response.productDetails) {
        productDetailsMap[product.id] = product;
      }
      final productIds = response.productDetails.map((p) => p.id).toList();
      splog('loadProducts: $productIds');
      return response.productDetails;
    } catch (e) {
      splog('Failed to load products: $e');
      return [];
    }
  }

  /// 购买产品
  ///
  /// [productId] 产品ID
  /// [isConsumable] 是否为消耗品
  /// [callback] 购买回调
  Future<void> purchaseProduct(
    String productId, {
    bool isConsumable = false,
    PurchaseCallback? callback,
  }) async {
    if (!_isAvailable) {
      callback?.call(PurchaseResult(
        status: IAPPurchaseStatus.purchaseFailed,
        message: 'Store is not available',
      ));
      return;
    }
    final ProductDetails? product = productDetailsMap[productId];
    if (product == null) {
      callback?.call(PurchaseResult(
        status: IAPPurchaseStatus.purchaseFailed,
        message: 'Product not found',
      ));
      return;
    }
    _purchaseCallback = callback;
    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: null,
      );

      if (isConsumable) {
        await _iap.buyConsumable(purchaseParam: purchaseParam);
      } else {
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      _notifyCallback(IAPPurchaseStatus.crashes, message: e.toString());
    }
  }

  /// 恢复购买
  ///
  /// [callback] 购买回调
  Future<void> restorePurchases({PurchaseCallback? callback}) async {
    _purchaseCallback = callback;
    try {
      if (latestPurchasedProducts.isEmpty) {
        Future.delayed(const Duration(seconds: 2), () {
          _notifyCallback(IAPPurchaseStatus.restoreFailed,
              message: 'No subscription');
        });
        return;
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      Map<String, dynamic>? validPurchase;
      for (var dict in latestPurchasedProducts.values) {
        final expiresDateMs = dict['expiresDateMs'];
        if (expiresDateMs != null && expiresDateMs > now) {
          validPurchase = dict;
          break;
        }
      }
      if (validPurchase != null) {
        Future.delayed(const Duration(seconds: 2), () {
          _notifyCallback(IAPPurchaseStatus.restored, data: validPurchase);
        });

        return;
      }
      await _iap.restorePurchases();
      _notifyCallback(IAPPurchaseStatus.canceled);
    } catch (e) {
      _notifyCallback(IAPPurchaseStatus.crashes, message: e.toString());
    }
  }

  // 处理购买更新
  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _notifyCallback(IAPPurchaseStatus.purchasing,
            message: purchaseDetails.productID);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        _notifyCallback(IAPPurchaseStatus.systemError,
            message: purchaseDetails.error?.message,
            data: purchaseDetails.error?.toString());
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        _handleSuccessfulPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        _notifyCallback(IAPPurchaseStatus.canceled);
      }
      if (purchaseDetails.pendingCompletePurchase) {
        _iap.completePurchase(purchaseDetails);
      }
    }
  }

  /// 处理成功的购买
  ///
  /// [purchase] 购买详情
  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    _notifyCallback(IAPPurchaseStatus.verifying);
    try {
      final receiptData = purchase.verificationData.serverVerificationData;
      final VerificationResult result;

      if (Platform.isIOS || Platform.isMacOS) {
        result = await _verifyIosReceipt(receiptData);
      } else {
        result = await _verifyAndroidReceipt(receiptData);
      }
      if (result.type == 1) {
        final status = purchase.status == PurchaseStatus.purchased
            ? IAPPurchaseStatus.purchased
            : IAPPurchaseStatus.restored;
        _notifyCallback(status, data: result.data);
      } else if (result.type == 2) {
        _notifyCallback(IAPPurchaseStatus.crashes,
            message: result.message, data: result.error);
      } else {
        _notifyCallback(
          IAPPurchaseStatus.verifyingFailed,
          message: result.message ?? 'Invalid purchase',
          data: result.error,
        );
      }
    } catch (e) {
      splog('Purchase verification error: $e');
      _notifyCallback(
        IAPPurchaseStatus.crashes,
        message: 'Verification error',
        data: e.toString(),
      );
    }
  }

  /// iOS 收据验证
  ///
  /// [receiptData] 收据数据
  Future<VerificationResult> _verifyIosReceipt(String receiptData) async {
    try {
      final response = await Dio().post(
        'https://buy.itunes.apple.com/verifyReceipt',
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => true,
        ),
        data: {
          'receipt-data': receiptData,
          'password': _sharedSecret,
          'exclude-old-transactions': true,
        },
      );
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == 0) {
          final List<dynamic> receiptInfos =
              responseData['latest_receipt_info'] ?? [];
          return _parseIosReceiptInfo(receiptInfos);
        } else if (responseData['status'] == 21007) {
          splog('Invalid status code: ${responseData['status']}');
          return await _verifyIosReceiptInSandbox(receiptData);
        }
        splog('Invalid status code: ${responseData['status']}');
        return VerificationResult(
          type: 0,
          message: 'Invalid status',
          error: 'Invalid status code: ${responseData['status']}',
        );
      }
      splog('HTTP Error: ${response.statusCode}');
      return VerificationResult(
        type: 0,
        message: 'HTTP Error',
        error: 'HTTP status code: ${response.statusCode}',
      );
    } catch (e) {
      splog('Receipt verification error: $e');
      return VerificationResult(
        type: 2,
        message: 'Receipt verification error',
        error: e.toString(),
      );
    }
  }

  /// iOS 沙盒环境验证
  ///
  /// [receiptData] 收据数据
  Future<VerificationResult> _verifyIosReceiptInSandbox(
      String receiptData) async {
    try {
      final response = await Dio().post(
        'https://sandbox.itunes.apple.com/verifyReceipt',
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => true,
        ),
        data: {
          'receipt-data': receiptData,
          'password': _sharedSecret,
          'exclude-old-transactions': true,
        },
      );
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == 0) {
          final List<dynamic> receiptInfos =
              responseData['latest_receipt_info'] ?? [];
          return _parseIosReceiptInfo(receiptInfos);
        }
        splog('Sandbox Invalid status code: ${responseData['status']}');
        return VerificationResult(
          type: 0,
          message: 'Sandbox Invalid status',
          error: 'Invalid status code: ${responseData['status']}',
        );
      }
      splog('HTTP Error: ${response.statusCode}');
      return VerificationResult(
        type: 0,
        message: 'HTTP Error',
        error: 'HTTP status code: ${response.statusCode}',
      );
    } catch (e) {
      splog('Sandbox receipt verification error: $e');
      return VerificationResult(
        type: 2,
        message: 'Sandbox receipt verification error',
        error: e.toString(),
      );
    }
  }

  /// Android 收据验证 (暂未开发)
  ///
  /// [receiptData] 收据数据
  Future<VerificationResult> _verifyAndroidReceipt(String receiptData) async {
    try {
      final response = await Dio().post(
        'YOUR_ANDROID_VERIFICATION_ENDPOINT',
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => true,
        ),
        data: {
          'receipt-data': receiptData,
          'package_name': 'your.package.name',
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['isValid'] == true) {
          final List<dynamic> receiptInfos = responseData['purchases'] ?? [];

          allPurchasedProducts =
              receiptInfos.map((e) => e as Map<String, dynamic>).toList();

          // 用于存储有效的购买信息
          final validPurchases = <Map<String, dynamic>>[];
          final now = DateTime.now().millisecondsSinceEpoch;

          // 按产品ID分组，只保留每个产品最新的交易记录
          final Map<String, Map<String, dynamic>> latestTransactions = {};

          for (var receipt in receiptInfos) {
            final String productId = receipt['productId'];
            final int purchaseDateMs = receipt['purchaseTimeMillis'] ?? 0;
            final int expiresDateMs = receipt['expiryTimeMillis'] ?? 0;

            // 更新最新交易记录
            final existingTransaction = latestTransactions[productId];
            if (existingTransaction == null ||
                purchaseDateMs > (existingTransaction['purchaseDateMs'] ?? 0)) {
              latestTransactions[productId] = {
                'productId': productId,
                'purchaseDateMs': purchaseDateMs,
                'expiresDateMs': expiresDateMs,
                'orderId': receipt['orderId'],
                'packageName': receipt['packageName'],
                'purchaseToken': receipt['purchaseToken'],
                'autoRenewing': receipt['autoRenewing'] ?? false,
                'acknowledged': receipt['acknowledged'] ?? false,
                'environment': responseData['environment'] ?? 'Production',
              };
            }

            // 如果未过期，添加到有效购买列表
            if (expiresDateMs > now) {
              validPurchases.add(latestTransactions[productId]!);
            }
          }

          // 更新已购买产品记录
          latestPurchasedProducts.clear();
          latestPurchasedProducts.addAll(latestTransactions);

          // 如果有有效购买，返回最新购买记录
          if (validPurchases.isNotEmpty) {
            return VerificationResult(
              type: 1,
              data: validPurchases.first,
            );
          }

          return VerificationResult(
            type: 0,
            message: 'Subscription expired',
          );
        }

        return VerificationResult(
          type: 0,
          message: 'Invalid response: ${responseData['message']}',
        );
      }

      return VerificationResult(
        type: 0,
        message: 'HTTP Error: ${response.statusCode}',
      );
    } catch (e) {
      splog('Android receipt verification error: $e');
      return VerificationResult(
        type: 2,
        message: e.toString(),
      );
    }
  }

  /// 解析收据信息
  ///
  /// [receiptInfos] 收据信息
  VerificationResult _parseIosReceiptInfo(List<dynamic> receiptInfos) {
    // 用于存储所有已购买产品的交易记录
    allPurchasedProducts =
        receiptInfos.map((e) => e as Map<String, dynamic>).toList();

    // 用于存储有效的购买信息
    final validPurchases = <Map<String, dynamic>>[];
    final now = DateTime.now().millisecondsSinceEpoch;

    // 按产品ID分组,保留每个产品最新的交易记录
    final Map<String, Map<String, dynamic>> latestTransactions = {};

    for (var receipt in receiptInfos) {
      final String productId = receipt['product_id'];
      final int purchaseDateMs =
          int.tryParse(receipt['purchase_date_ms'] ?? '0') ?? 0;

      // 检查是否为最新交易
      final existingTransaction = latestTransactions[productId];
      if (existingTransaction == null ||
          purchaseDateMs > (existingTransaction['purchaseDateMs'] ?? 0)) {
        // 构建基础交易信息
        final transaction = {
          'productId': productId,
          'purchaseDateMs': purchaseDateMs,
          'transactionId': receipt['transaction_id'],
          'originalTransactionId': receipt['original_transaction_id'],
          'originalPurchaseDateMs': receipt['original_purchase_date_ms'],
          'inAppOwnershipType': receipt['in_app_ownership_type'],
          'subscriptionGroupIdentifier':
              receipt['subscription_group_identifier'],
        };

        // 如果是订阅项目,添加订阅相关信息
        if (receipt['expires_date_ms'] != null) {
          final int expiresDateMs =
              int.tryParse(receipt['expires_date_ms'] ?? '0') ?? 0;

          transaction.addAll({
            'expiresDateMs': expiresDateMs,
            'expiresDate': receipt['expires_date'],
            'isTrialPeriod': receipt['is_trial_period'],
            'isInIntroOfferPeriod': receipt['is_in_intro_offer_period'],
          });

          // 更新最新的过期时间
          if (expiresDateMs > expireTimeMs) {
            expireTimeMs = expiresDateMs;
            lastPurchaseTimeMs = purchaseDateMs;
          }

          // 检查是否为有效订阅
          if (expiresDateMs > now) {
            validPurchases.add(transaction);
          }
        } else {
          //如果一次性买断中有这个产品,则认为是有效购买
          if (_onetimeSubsIds.contains(productId)) {
            validPurchases.add(transaction);
          }
        }

        // 更新最新交易记录
        latestTransactions[productId] = transaction;
      }
    }

    // 更新已购买产品记录
    latestPurchasedProducts.clear();
    latestPurchasedProducts.addAll(latestTransactions);

    // 如果有有效购买,返回最新购买记录
    if (validPurchases.isNotEmpty) {
      return VerificationResult(
        type: 1,
        data: validPurchases.first,
      );
    }

    splog('No subscription or expired');
    return VerificationResult(
      type: 0,
      message: 'Oops!',
      error: 'No subscription or expired',
    );
  }

  /// 通知回调
  ///
  /// [status] 购买状态
  /// [message] 消息
  /// [data] 数据
  void _notifyCallback(IAPPurchaseStatus status,
      {String? message, dynamic data}) {
    _purchaseCallback?.call(PurchaseResult(
      status: status,
      message: message,
      data: data,
    ));
  }
}

/// iOS 支付队列代理
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
