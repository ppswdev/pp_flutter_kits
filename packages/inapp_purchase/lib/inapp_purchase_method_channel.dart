import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:inapp_purchase/src/product.dart';
import 'package:inapp_purchase/src/transaction.dart';

import 'inapp_purchase_platform_interface.dart';

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

  /// 构造函数
  MethodChannelInappPurchase() {
    setupMethodCallHandler();
  }

  /// 设置方法调用处理器
  void setupMethodCallHandler() {
    methodChannel.setMethodCallHandler((call) async {
      // 只处理请求-响应式的方法调用，事件处理现在通过EventChannel实现
      return null;
    });
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<void> configure({
    required List<String> productIds,
    required List<String> lifetimeIds,
    int nonRenewableExpirationDays = 7,
    bool autoSortProducts = true,
  }) async {
    await methodChannel.invokeMethod('configure', {
      'productIds': productIds,
      'lifetimeIds': lifetimeIds,
      'nonRenewableExpirationDays': nonRenewableExpirationDays,
      'autoSortProducts': autoSortProducts,
    });
  }

  @override
  Future<List<Product>> getAllProducts() async {
    final result = await methodChannel.invokeMethod('getAllProducts');
    if (result is List) {
      return result
          .whereType<Map<String, dynamic>>()
          .map((item) => Product.fromMap(item))
          .toList();
    }
    return [];
  }

  @override
  Future<List<Product>> getNonConsumablesProducts() async {
    final result = await methodChannel.invokeMethod(
      'getNonConsumablesProducts',
    );
    if (result is List) {
      return result
          .whereType<Map<String, dynamic>>()
          .map((item) => Product.fromMap(item))
          .toList();
    }
    return [];
  }

  @override
  Future<List<Product>> getConsumablesProducts() async {
    final result = await methodChannel.invokeMethod('getConsumablesProducts');
    if (result is List) {
      return result
          .whereType<Map<String, dynamic>>()
          .map((item) => Product.fromMap(item))
          .toList();
    }
    return [];
  }

  @override
  Future<List<Product>> getNonRenewablesProducts() async {
    final result = await methodChannel.invokeMethod('getNonRenewablesProducts');
    if (result is List) {
      return result
          .whereType<Map<String, dynamic>>()
          .map((item) => Product.fromMap(item))
          .toList();
    }
    return [];
  }

  @override
  Future<List<Product>> getAutoRenewablesProducts() async {
    final result = await methodChannel.invokeMethod(
      'getAutoRenewablesProducts',
    );
    if (result is List) {
      return result
          .whereType<Map<String, dynamic>>()
          .map((item) => Product.fromMap(item))
          .toList();
    }
    return [];
  }

  @override
  Future<Product?> getProduct({required String productId}) async {
    final result = await methodChannel.invokeMethod('getProduct', {
      'productId': productId,
    });
    if (result == null) return null;
    if (result is Map<String, dynamic>) {
      return Product.fromMap(result);
    }
    return null;
  }

  @override
  Future<void> purchase({required String productId}) async {
    await methodChannel.invokeMethod('purchase', {'productId': productId});
  }

  @override
  Future<void> restorePurchases() async {
    await methodChannel.invokeMethod('restorePurchases');
  }

  @override
  Future<void> refreshPurchases() async {
    await methodChannel.invokeMethod('refreshPurchases');
  }

  @override
  Future<List<Transaction>> getValidPurchasedTransactions() async {
    final result = await methodChannel.invokeMethod(
      'getValidPurchasedTransactions',
    );
    if (result is List) {
      return result
          .whereType<Map<String, dynamic>>()
          .map((item) => Transaction.fromMap(item))
          .toList();
    }
    return [];
  }

  @override
  Future<List<Transaction>> getLatestTransactions() async {
    final result = await methodChannel.invokeMethod('getLatestTransactions');
    if (result is List) {
      return result
          .whereType<Map<String, dynamic>>()
          .map((item) => Transaction.fromMap(item))
          .toList();
    }
    return [];
  }

  @override
  Future<bool> isPurchased({required String productId}) async {
    return await methodChannel.invokeMethod('isPurchased', {
          'productId': productId,
        })
        as bool;
  }

  @override
  Future<bool> isFamilyShared({required String productId}) async {
    return await methodChannel.invokeMethod('isFamilyShared', {
          'productId': productId,
        })
        as bool;
  }

  @override
  Future<bool> isEligibleForIntroOffer({required String productId}) async {
    return await methodChannel.invokeMethod('isEligibleForIntroOffer', {
          'productId': productId,
        })
        as bool;
  }

  @override
  Future<bool> checkSubscriptionStatus() async {
    return await methodChannel.invokeMethod('checkSubscriptionStatus') as bool;
  }

  @override
  Future<String> getProductForVipTitle({
    required String productId,
    required String periodType,
    required String langCode,
  }) async {
    return await methodChannel.invokeMethod('getProductForVipTitle', {
          'productId': productId,
          'periodType': periodType,
          'langCode': langCode,
        })
        as String;
  }

  @override
  Future<String> getProductForVipSubtitle({
    required String productId,
    required String periodType,
    required String langCode,
  }) async {
    return await methodChannel.invokeMethod('getProductForVipSubtitle', {
          'productId': productId,
          'periodType': periodType,
          'langCode': langCode,
        })
        as String;
  }

  @override
  Future<String> getProductForVipButtonText({
    required String productId,
    required String langCode,
  }) async {
    return await methodChannel.invokeMethod('getProductForVipButtonText', {
          'productId': productId,
          'langCode': langCode,
        })
        as String;
  }

  @override
  Future<void> showManageSubscriptionsSheet() async {
    await methodChannel.invokeMethod('showManageSubscriptionsSheet');
  }

  @override
  Future<bool> presentOfferCodeRedeemSheet() async {
    return await methodChannel.invokeMethod('presentOfferCodeRedeemSheet')
        as bool;
  }

  @override
  void requestReview() {
    methodChannel.invokeMethod('requestReview');
  }

  @override
  Stream<Map<String, dynamic>> get onStateChanged {
    return stateEventChannel.receiveBroadcastStream().map((event) {
      return event as Map<String, dynamic>;
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> get onProductsLoaded {
    return productsEventChannel.receiveBroadcastStream().map((event) {
      if (event is List) {
        return event
            .whereType<Map<String, dynamic>>()
            .map((item) => item)
            .toList();
      }
      return [];
    });
  }

  @override
  Stream<Map<String, dynamic>> get onPurchasedTransactionsUpdated {
    return transactionsEventChannel.receiveBroadcastStream().map((event) {
      return event as Map<String, dynamic>;
    });
  }
}
