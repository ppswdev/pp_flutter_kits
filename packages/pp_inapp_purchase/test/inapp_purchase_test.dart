import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pp_inapp_purchase/inapp_purchase.dart';
import 'package:pp_inapp_purchase/inapp_purchase_platform_interface.dart';
import 'package:pp_inapp_purchase/inapp_purchase_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockInappPurchasePlatform
    with MockPlatformInterfaceMixin
    implements InappPurchasePlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> configure({
    required List<String> productIds,
    required List<String> lifetimeIds,
    int nonRenewableExpirationDays = 7,
    bool autoSortProducts = true,
    bool showLog = false,
  }) => Future.value();

  @override
  Future<List<Product>> getAllProducts() => Future.value([]);

  @override
  Future<List<Product>> getNonConsumablesProducts() => Future.value([]);

  @override
  Future<List<Product>> getConsumablesProducts() => Future.value([]);

  @override
  Future<List<Product>> getNonRenewablesProducts() => Future.value([]);

  @override
  Future<List<Product>> getAutoRenewablesProducts() => Future.value([]);

  @override
  Future<Product?> getProduct({required String productId}) =>
      Future.value(null);

  @override
  Future<void> purchase({required String productId}) => Future.value();

  @override
  Future<void> restorePurchases() => Future.value();

  @override
  Future<void> refreshPurchases() => Future.value();

  @override
  Future<List<Transaction>> getValidPurchasedTransactions() => Future.value([]);

  @override
  Future<List<Transaction>> getLatestTransactions() => Future.value([]);

  @override
  Future<bool> isPurchased({required String productId}) => Future.value(false);

  @override
  Future<bool> isFamilyShared({required String productId}) =>
      Future.value(false);

  @override
  Future<bool> isEligibleForIntroOffer({required String productId}) =>
      Future.value(false);

  @override
  Future<bool> checkSubscriptionStatus() => Future.value(false);

  @override
  Future<String> getProductForVipTitle({
    required String productId,
    required String periodType,
    required String langCode,
  }) => Future.value('');

  @override
  Future<String> getProductForVipSubtitle({
    required String productId,
    required String periodType,
    required String langCode,
  }) => Future.value('');

  @override
  Future<String> getProductForVipButtonText({
    required String productId,
    required String langCode,
  }) => Future.value('');

  @override
  Future<void> showManageSubscriptionsSheet() => Future.value();

  @override
  Future<bool> presentOfferCodeRedeemSheet() => Future.value(false);

  @override
  void requestReview() {}

  @override
  Stream<Map<String, dynamic>> get onStateChanged => Stream.empty();

  @override
  Stream<List<Map<String, dynamic>>> get onProductsLoaded => Stream.empty();

  @override
  Stream<Map<String, dynamic>> get onPurchasedTransactionsUpdated =>
      Stream.empty();
}

void main() {
  final InappPurchasePlatform initialPlatform = InappPurchasePlatform.instance;

  test('$MethodChannelInappPurchase is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelInappPurchase>());
  });

  test('getPlatformVersion', () async {
    InappPurchase inappPurchasePlugin = InappPurchase.instance;
    MockInappPurchasePlatform fakePlatform = MockInappPurchasePlatform();
    InappPurchasePlatform.instance = fakePlatform;

    expect(await inappPurchasePlugin.getPlatformVersion(), '42');
  });
}
