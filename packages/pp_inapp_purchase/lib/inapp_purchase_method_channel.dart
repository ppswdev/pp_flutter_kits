import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'inapp_purchase_platform_interface.dart';
import 'src/product.dart';
import 'src/transaction.dart';

/// 基于MethodChannel的应用内购实现
class MethodChannelInappPurchase extends InappPurchasePlatform {
  /// 方法通道
  @visibleForTesting
  final methodChannel = const MethodChannel('inapp_purchase');

  /// 事件通道
  final stateEventChannel = const EventChannel('inapp_purchase/state_events');
  final productsEventChannel = const EventChannel(
    'inapp_purchase/products_events',
  );
  final transactionsEventChannel = const EventChannel(
    'inapp_purchase/transactions_events',
  );

  /// 是否显示日志
  bool _showLog = true;

  /// 安全日志输出方法
  void safeLog(String message, {Object? error, StackTrace? stackTrace}) {
    if (_showLog) {
      if (error != null && stackTrace != null) {
        developer.log(
          message,
          name: 'pp_inapp_purchase',
          error: error,
          stackTrace: stackTrace,
        );
      } else {
        developer.log(message, name: 'pp_inapp_purchase');
      }
    }
  }

  /// 递归转换 Map，处理嵌套的 _Map<Object?, Object?> 到 Map<String, dynamic>
  Map<String, dynamic> _deepConvertMap(dynamic map) {
    if (map is Map<String, dynamic>) {
      return map;
    }

    if (map is Map) {
      final result = <String, dynamic>{};
      map.forEach((key, value) {
        final stringKey = key.toString();
        result[stringKey] = _deepConvertValue(value);
      });
      return result;
    }

    throw ArgumentError('Expected Map but got ${map.runtimeType}');
  }

  /// 递归转换值，处理嵌套的 Map 和 List
  dynamic _deepConvertValue(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Map) {
      return _deepConvertMap(value);
    }

    if (value is List) {
      return value.map((item) => _deepConvertValue(item)).toList();
    }

    return value;
  }

  /// 构造函数
  MethodChannelInappPurchase() {
    safeLog('初始化 MethodChannelInappPurchase');
    setupMethodCallHandler();
  }

  /// 设置方法调用处理器
  void setupMethodCallHandler() {
    methodChannel.setMethodCallHandler((call) async {
      safeLog('收到方法调用: ${call.method}');
      safeLog('参数: ${call.arguments}');
      // 只处理请求-响应式的方法调用，事件处理现在通过EventChannel实现
      return null;
    });
    safeLog('方法调用处理器已设置');
  }

  @override
  Future<String?> getPlatformVersion() async {
    safeLog('调用 getPlatformVersion');
    try {
      final version = await methodChannel.invokeMethod<String>(
        'getPlatformVersion',
      );
      safeLog('✅ getPlatformVersion 成功: $version');
      return version;
    } catch (e, stackTrace) {
      safeLog('❌ getPlatformVersion 失败: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> configure({
    required List<String> productIds,
    required List<String> lifetimeIds,
    int nonRenewableExpirationDays = 7,
    bool autoSortProducts = true,
    bool showLog = true,
  }) async {
    _showLog = showLog;
    safeLog('调用 configure');
    safeLog('productIds: $productIds');
    safeLog('lifetimeIds: $lifetimeIds');
    safeLog('nonRenewableExpirationDays: $nonRenewableExpirationDays');
    safeLog('autoSortProducts: $autoSortProducts');
    safeLog('showLog: $showLog');
    try {
      await methodChannel.invokeMethod('configure', {
        'productIds': productIds,
        'lifetimeIds': lifetimeIds,
        'nonRenewableExpirationDays': nonRenewableExpirationDays,
        'autoSortProducts': autoSortProducts,
        'showLog': showLog,
      });
      safeLog('✅ configure 成功');
    } catch (e, stackTrace) {
      safeLog('❌ configure 失败: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Product>> getAllProducts() async {
    safeLog('调用 getAllProducts');
    try {
      final result = await methodChannel.invokeMethod('getAllProducts');
      safeLog(
        'getAllProducts 返回: ${result is List ? result.length : 'null'} 个产品',
      );
      if (result is List) {
        final products = result
            .whereType<Map>()
            .map((item) {
              try {
                final map = _deepConvertMap(item);
                return Product.fromMap(map);
              } catch (e) {
                safeLog('⚠️ getAllProducts 解析单个产品失败: $e');
                return null;
              }
            })
            .whereType<Product>()
            .toList();
        safeLog('✅ getAllProducts 解析成功: ${products.length} 个产品');
        return products;
      }
      safeLog('⚠️ getAllProducts 返回类型不正确: ${result.runtimeType}');
      return [];
    } catch (e, stackTrace) {
      safeLog('❌ getAllProducts 失败: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Product>> getNonConsumablesProducts() async {
    safeLog('调用 getNonConsumablesProducts');
    try {
      final result = await methodChannel.invokeMethod(
        'getNonConsumablesProducts',
      );
      safeLog(
        'getNonConsumablesProducts 返回: ${result is List ? result.length : 'null'} 个产品',
      );
      if (result is List) {
        final products = result
            .whereType<Map>()
            .map((item) {
              try {
                final map = _deepConvertMap(item);
                return Product.fromMap(map);
              } catch (e) {
                safeLog('⚠️ getNonConsumablesProducts 解析单个产品失败: $e');
                return null;
              }
            })
            .whereType<Product>()
            .toList();
        safeLog('✅ getNonConsumablesProducts 解析成功: ${products.length} 个产品');
        return products;
      }
      return [];
    } catch (e, stackTrace) {
      safeLog(
        '❌ getNonConsumablesProducts 失败: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<Product>> getConsumablesProducts() async {
    safeLog('调用 getConsumablesProducts');
    try {
      final result = await methodChannel.invokeMethod('getConsumablesProducts');
      safeLog(
        'getConsumablesProducts 返回: ${result is List ? result.length : 'null'} 个产品',
      );
      if (result is List) {
        final products = result
            .whereType<Map>()
            .map((item) {
              try {
                final map = _deepConvertMap(item);
                return Product.fromMap(map);
              } catch (e) {
                safeLog('⚠️ getConsumablesProducts 解析单个产品失败: $e');
                return null;
              }
            })
            .whereType<Product>()
            .toList();
        safeLog('✅ getConsumablesProducts 解析成功: ${products.length} 个产品');
        return products;
      }
      return [];
    } catch (e, stackTrace) {
      safeLog(
        '❌ getConsumablesProducts 失败: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<Product>> getNonRenewablesProducts() async {
    safeLog('调用 getNonRenewablesProducts');
    try {
      final result = await methodChannel.invokeMethod(
        'getNonRenewablesProducts',
      );
      safeLog(
        'getNonRenewablesProducts 返回: ${result is List ? result.length : 'null'} 个产品',
      );
      if (result is List) {
        final products = result
            .whereType<Map>()
            .map((item) {
              try {
                final map = _deepConvertMap(item);
                return Product.fromMap(map);
              } catch (e) {
                safeLog('⚠️ getNonRenewablesProducts 解析单个产品失败: $e');
                return null;
              }
            })
            .whereType<Product>()
            .toList();
        safeLog('✅ getNonRenewablesProducts 解析成功: ${products.length} 个产品');
        return products;
      }
      return [];
    } catch (e, stackTrace) {
      safeLog(
        '❌ getNonRenewablesProducts 失败: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<Product>> getAutoRenewablesProducts() async {
    safeLog('调用 getAutoRenewablesProducts');
    try {
      final result = await methodChannel.invokeMethod(
        'getAutoRenewablesProducts',
      );
      safeLog(
        'getAutoRenewablesProducts 返回: ${result is List ? result.length : 'null'} 个产品',
      );
      if (result is List) {
        final products = result
            .whereType<Map>()
            .map((item) {
              try {
                final map = _deepConvertMap(item);
                return Product.fromMap(map);
              } catch (e) {
                safeLog('⚠️ getAutoRenewablesProducts 解析单个产品失败: $e');
                return null;
              }
            })
            .whereType<Product>()
            .toList();
        safeLog('✅ getAutoRenewablesProducts 解析成功: ${products.length} 个产品');
        return products;
      }
      return [];
    } catch (e, stackTrace) {
      safeLog(
        '❌ getAutoRenewablesProducts 失败: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<Product?> getProduct({required String productId}) async {
    safeLog('调用 getProduct, productId: $productId');
    try {
      final result = await methodChannel.invokeMethod('getProduct', {
        'productId': productId,
      });
      if (result == null) {
        safeLog('⚠️ getProduct 返回 null');
        return null;
      }
      if (result is Map) {
        try {
          final map = _deepConvertMap(result);
          final product = Product.fromMap(map);
          safeLog('✅ getProduct 解析成功: ${product.id}');
          return product;
        } catch (e, stackTrace) {
          safeLog(
            '⚠️ getProduct 返回类型无法转换为 Product: ${result.runtimeType}, $e',
            error: e,
            stackTrace: stackTrace,
          );
          return null;
        }
      }
      safeLog('⚠️ getProduct 返回类型不正确: ${result.runtimeType}');
      return null;
    } catch (e, stackTrace) {
      safeLog('❌ getProduct 失败: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> purchase({required String productId}) async {
    safeLog('调用 purchase, productId: $productId');
    try {
      await methodChannel.invokeMethod('purchase', {'productId': productId});
      safeLog('✅ purchase 调用成功');
    } catch (e, stackTrace) {
      safeLog('❌ purchase 失败: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> restorePurchases() async {
    safeLog('调用 restorePurchases');
    try {
      await methodChannel.invokeMethod('restorePurchases');
      safeLog('✅ restorePurchases 调用成功');
    } catch (e, stackTrace) {
      safeLog('❌ restorePurchases 失败: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> refreshPurchases() async {
    safeLog('调用 refreshPurchases');
    try {
      await methodChannel.invokeMethod('refreshPurchases');
      safeLog('✅ refreshPurchases 调用成功');
    } catch (e, stackTrace) {
      safeLog('❌ refreshPurchases 失败: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Transaction>> getValidPurchasedTransactions() async {
    safeLog('调用 getValidPurchasedTransactions');
    try {
      final result = await methodChannel.invokeMethod(
        'getValidPurchasedTransactions',
      );
      safeLog(
        'getValidPurchasedTransactions 返回: ${result is List ? result.length : 'null'} 个交易',
      );
      if (result is List) {
        final transactions = result
            .whereType<Map>()
            .map((item) {
              try {
                final map = _deepConvertMap(item);
                return Transaction.fromMap(map);
              } catch (e) {
                safeLog('⚠️ getValidPurchasedTransactions 解析单个交易失败: $e');
                return null;
              }
            })
            .whereType<Transaction>()
            .toList();
        safeLog(
          '✅ getValidPurchasedTransactions 解析成功: ${transactions.length} 个交易',
        );
        return transactions;
      }
      return [];
    } catch (e, stackTrace) {
      safeLog(
        '❌ getValidPurchasedTransactions 失败: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<Transaction>> getLatestTransactions() async {
    safeLog('调用 getLatestTransactions');
    try {
      final result = await methodChannel.invokeMethod('getLatestTransactions');
      safeLog(
        'getLatestTransactions 返回: ${result is List ? result.length : 'null'} 个交易',
      );
      if (result is List) {
        final transactions = result
            .whereType<Map>()
            .map((item) {
              try {
                final map = _deepConvertMap(item);
                return Transaction.fromMap(map);
              } catch (e) {
                safeLog('⚠️ getLatestTransactions 解析单个交易失败: $e');
                return null;
              }
            })
            .whereType<Transaction>()
            .toList();
        safeLog('✅ getLatestTransactions 解析成功: ${transactions.length} 个交易');
        return transactions;
      }
      return [];
    } catch (e, stackTrace) {
      safeLog(
        '❌ getLatestTransactions 失败: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<bool> isPurchased({required String productId}) async {
    safeLog('调用 isPurchased, productId: $productId');
    try {
      final result =
          await methodChannel.invokeMethod('isPurchased', {
                'productId': productId,
              })
              as bool;
      safeLog('✅ isPurchased 返回: $result');
      return result;
    } catch (e, stackTrace) {
      safeLog('❌ isPurchased 失败: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> isFamilyShared({required String productId}) async {
    safeLog('调用 isFamilyShared, productId: $productId');
    try {
      final result =
          await methodChannel.invokeMethod('isFamilyShared', {
                'productId': productId,
              })
              as bool;
      safeLog('✅ isFamilyShared 返回: $result');
      return result;
    } catch (e, stackTrace) {
      safeLog('❌ isFamilyShared 失败: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> isEligibleForIntroOffer({required String productId}) async {
    safeLog('调用 isEligibleForIntroOffer, productId: $productId');
    try {
      final result =
          await methodChannel.invokeMethod('isEligibleForIntroOffer', {
                'productId': productId,
              })
              as bool;
      safeLog('✅ isEligibleForIntroOffer 返回: $result');
      return result;
    } catch (e, stackTrace) {
      safeLog(
        '❌ isEligibleForIntroOffer 失败: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<bool> isSubscribedButFreeTrailCancelled({
    required String productId,
  }) async {
    safeLog('调用 isSubscribedButFreeTrailCancelled, productId: $productId');
    try {
      final result =
          await methodChannel.invokeMethod(
                'isSubscribedButFreeTrailCancelled',
                {'productId': productId},
              )
              as bool;
      safeLog('✅ isSubscribedButFreeTrailCancelled 返回: $result');
      return result;
    } catch (e, stackTrace) {
      safeLog(
        '❌ isSubscribedButFreeTrailCancelled 失败: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<bool> checkSubscriptionStatus() async {
    safeLog('调用 checkSubscriptionStatus');
    try {
      final result =
          await methodChannel.invokeMethod('checkSubscriptionStatus') as bool;
      safeLog('✅ checkSubscriptionStatus 返回: $result');
      return result;
    } catch (e, stackTrace) {
      safeLog(
        '❌ checkSubscriptionStatus 失败: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<String> getProductForVipTitle({
    required String productId,
    required String periodType,
    required String langCode,
  }) async {
    safeLog(
      '调用 getProductForVipTitle, productId: $productId, periodType: $periodType, langCode: $langCode',
    );
    try {
      final result =
          await methodChannel.invokeMethod('getProductForVipTitle', {
                'productId': productId,
                'periodType': periodType,
                'langCode': langCode,
              })
              as String;
      safeLog('✅ getProductForVipTitle 返回: $result');
      return result;
    } catch (e, stackTrace) {
      safeLog(
        '❌ getProductForVipTitle 失败: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<String> getProductForVipSubtitle({
    required String productId,
    required String periodType,
    required String langCode,
  }) async {
    safeLog(
      '调用 getProductForVipSubtitle, productId: $productId, periodType: $periodType, langCode: $langCode',
    );
    try {
      final result =
          await methodChannel.invokeMethod('getProductForVipSubtitle', {
                'productId': productId,
                'periodType': periodType,
                'langCode': langCode,
              })
              as String;
      safeLog('✅ getProductForVipSubtitle 返回: $result');
      return result;
    } catch (e, stackTrace) {
      safeLog(
        '❌ getProductForVipSubtitle 失败: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<String> getProductForVipButtonText({
    required String productId,
    required String langCode,
  }) async {
    safeLog(
      '调用 getProductForVipButtonText, productId: $productId, langCode: $langCode',
    );
    try {
      final result =
          await methodChannel.invokeMethod('getProductForVipButtonText', {
                'productId': productId,
                'langCode': langCode,
              })
              as String;
      safeLog('✅ getProductForVipButtonText 返回: $result');
      return result;
    } catch (e, stackTrace) {
      safeLog(
        '❌ getProductForVipButtonText 失败: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> showManageSubscriptionsSheet() async {
    safeLog('调用 showManageSubscriptionsSheet');
    try {
      await methodChannel.invokeMethod('showManageSubscriptionsSheet');
      safeLog('✅ showManageSubscriptionsSheet 调用成功');
    } catch (e, stackTrace) {
      safeLog(
        '❌ showManageSubscriptionsSheet 失败: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<bool> presentOfferCodeRedeemSheet() async {
    safeLog('调用 presentOfferCodeRedeemSheet');
    try {
      final result =
          await methodChannel.invokeMethod('presentOfferCodeRedeemSheet')
              as bool;
      safeLog('✅ presentOfferCodeRedeemSheet 返回: $result');
      return result;
    } catch (e, stackTrace) {
      safeLog(
        '❌ presentOfferCodeRedeemSheet 失败: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  void requestReview() {
    safeLog('调用 requestReview');
    methodChannel
        .invokeMethod('requestReview')
        .then((_) {
          safeLog('✅ requestReview 调用成功');
        })
        .catchError((e) {
          safeLog('❌ requestReview 失败: $e');
        });
  }

  @override
  Stream<Map<String, dynamic>> get onStateChanged {
    safeLog('设置 onStateChanged 事件流监听');
    return stateEventChannel
        .receiveBroadcastStream('inapp_purchase/state_events')
        .map((event) {
          safeLog('收到状态变化事件: $event');
          if (event is Map) {
            // 使用 _deepConvertMap 递归转换嵌套的 Map，确保所有字段都被正确转换
            try {
              return _deepConvertMap(event);
            } catch (e) {
              safeLog('⚠️ onStateChanged 转换Map失败: $e，使用简单转换');
              // 如果转换失败，尝试使用简单转换
              return event.map((key, value) => MapEntry(key.toString(), value));
            }
          } else {
            throw StateError('Received event is not a Map: $event');
          }
        });
  }

  @override
  Stream<List<Map<String, dynamic>>> get onProductsLoaded {
    safeLog('设置 onProductsLoaded 事件流监听');
    return productsEventChannel
        .receiveBroadcastStream('inapp_purchase/products_events')
        .map((event) {
          safeLog('收到产品加载事件: ${event is List ? event.length : 'null'} 个产品');
          if (event is List) {
            final products = event
                .whereType<Map>()
                .map((item) {
                  try {
                    return _deepConvertMap(item);
                  } catch (e) {
                    safeLog('⚠️ onProductsLoaded 解析单个产品失败: $e');
                    return null;
                  }
                })
                .whereType<Map<String, dynamic>>()
                .toList();
            safeLog('✅ 产品加载事件解析成功: ${products.length} 个产品');
            return products;
          }
          return [];
        });
  }

  @override
  Stream<Map<String, dynamic>> get onPurchasedTransactionsUpdated {
    safeLog('设置 onPurchasedTransactionsUpdated 事件流监听');
    return transactionsEventChannel
        .receiveBroadcastStream('inapp_purchase/transactions_events')
        .map((event) {
          safeLog('收到交易更新事件: $event');
          // 安全处理event为Map<String, dynamic>的情况，递归转换嵌套的Map
          Map<String, dynamic> transactionMap = {};
          if (event is Map) {
            try {
              transactionMap = _deepConvertMap(event);
            } catch (e) {
              safeLog('⚠️ onPurchasedTransactionsUpdated 转换Map失败: $e');
              // 如果转换失败，尝试使用简单转换
              transactionMap = event.map(
                (key, value) => MapEntry(key.toString(), value),
              );
            }
          }
          final purchasedCount = transactionMap['validTransactions'] is List
              ? (transactionMap['validTransactions'] as List).length
              : 0;
          final latestCount = transactionMap['latestTransactions'] is List
              ? (transactionMap['latestTransactions'] as List).length
              : 0;
          safeLog(
            '✅ 交易更新事件解析成功: validTransactions=$purchasedCount, latestTransactions=$latestCount',
          );
          return transactionMap;
        });
  }
}
