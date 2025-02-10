import 'package:flutter_test/flutter_test.dart';
import 'package:pp_purchase/pp_purchase.dart';
import 'package:pp_purchase/pp_purchase_platform_interface.dart';
import 'package:pp_purchase/pp_purchase_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPpPurchasePlatform
    with MockPlatformInterfaceMixin
    implements PpPurchasePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PpPurchasePlatform initialPlatform = PpPurchasePlatform.instance;

  test('$MethodChannelPpPurchase is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPpPurchase>());
  });

  test('getPlatformVersion', () async {
    PpPurchase ppPurchasePlugin = PpPurchase();
    MockPpPurchasePlatform fakePlatform = MockPpPurchasePlatform();
    PpPurchasePlatform.instance = fakePlatform;

    expect(await ppPurchasePlugin.getPlatformVersion(), '42');
  });
}
