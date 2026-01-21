import 'package:flutter_test/flutter_test.dart';
import 'package:pp_keychain/pp_keychain.dart';
import 'package:pp_keychain/pp_keychain_platform_interface.dart';
import 'package:pp_keychain/pp_keychain_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPpKeychainPlatform
    with MockPlatformInterfaceMixin
    implements PPKeychainPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PPKeychainPlatform initialPlatform = PPKeychainPlatform.instance;

  test('$MethodChannelPpKeychain is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPpKeychain>());
  });

  test('getPlatformVersion', () async {
    PPKeychain ppKeychainPlugin = PPKeychain();
    MockPpKeychainPlatform fakePlatform = MockPpKeychainPlatform();
    PPKeychainPlatform.instance = fakePlatform;

    expect(await ppKeychainPlugin.getPlatformVersion(), '42');
  });
}
