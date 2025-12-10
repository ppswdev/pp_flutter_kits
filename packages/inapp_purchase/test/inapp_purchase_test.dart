import 'package:flutter_test/flutter_test.dart';
import 'package:inapp_purchase/inapp_purchase.dart';
import 'package:inapp_purchase/inapp_purchase_platform_interface.dart';
import 'package:inapp_purchase/inapp_purchase_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockInappPurchasePlatform
    with MockPlatformInterfaceMixin
    implements InappPurchasePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final InappPurchasePlatform initialPlatform = InappPurchasePlatform.instance;

  test('$MethodChannelInappPurchase is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelInappPurchase>());
  });

  test('getPlatformVersion', () async {
    InappPurchase inappPurchasePlugin = InappPurchase();
    MockInappPurchasePlatform fakePlatform = MockInappPurchasePlatform();
    InappPurchasePlatform.instance = fakePlatform;

    expect(await inappPurchasePlugin.getPlatformVersion(), '42');
  });
}
