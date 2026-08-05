import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pp_inapp_purchase/inapp_purchase_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelInappPurchase platform = MethodChannelInappPurchase();
  const MethodChannel channel = MethodChannel('inapp_purchase');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'getPlatformVersion') {
            return '42';
          }
          return <Object?>[];
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });

  test('completePurchaseVerification forwards safe Android decision', () async {
    MethodCall? capturedCall;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          capturedCall = methodCall;
          return null;
        });

    await platform.completePurchaseVerification(
      purchaseToken: 'purchase-token',
      approved: true,
      emitPurchaseSuccess: true,
    );

    expect(capturedCall?.method, 'completePurchaseVerification');
    expect(capturedCall?.arguments, {
      'purchaseToken': 'purchase-token',
      'approved': true,
      'emitPurchaseSuccess': true,
    });
  });

  test('getValidPurchasedTransactions parses a complete response', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return <Object?>[
            <String, Object?>{
              'id': 'transaction-1',
              'productID': 'lifetime-product',
              'productType': 'nonConsumable',
              'hasRevocation': false,
            },
          ];
        });

    final transactions = await platform.getValidPurchasedTransactions();

    expect(transactions, hasLength(1));
    expect(transactions.single.id, 'transaction-1');
  });

  test('getValidPurchasedTransactions fails on malformed items', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return <Object?>['not-a-transaction'];
        });

    expect(
      platform.getValidPurchasedTransactions(),
      throwsA(isA<FormatException>()),
    );
  });
}
