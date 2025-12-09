import 'package:flutter_test/flutter_test.dart';
import 'package:pp_purchase2/pp_purchase2.dart';
import 'package:pp_purchase2/pp_purchase2_platform_interface.dart';
import 'package:pp_purchase2/pp_purchase2_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPpPurchase2Platform
    with MockPlatformInterfaceMixin
    implements PpPurchase2Platform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PpPurchase2Platform initialPlatform = PpPurchase2Platform.instance;

  test('$MethodChannelPpPurchase2 is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPpPurchase2>());
  });

  test('getPlatformVersion', () async {
    PpPurchase2 ppPurchase2Plugin = PpPurchase2();
    MockPpPurchase2Platform fakePlatform = MockPpPurchase2Platform();
    PpPurchase2Platform.instance = fakePlatform;

    expect(await ppPurchase2Plugin.getPlatformVersion(), '42');
  });
}
