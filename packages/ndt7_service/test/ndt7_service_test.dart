import 'package:flutter_test/flutter_test.dart';
import 'package:ndt7_service/ndt7_service.dart';
import 'package:ndt7_service/ndt7_service_platform_interface.dart';
import 'package:ndt7_service/ndt7_service_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNdt7ServicePlatform
    with MockPlatformInterfaceMixin
    implements Ndt7ServicePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final Ndt7ServicePlatform initialPlatform = Ndt7ServicePlatform.instance;

  test('$MethodChannelNdt7Service is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNdt7Service>());
  });

  test('getPlatformVersion', () async {
    Ndt7Service ndt7ServicePlugin = Ndt7Service();
    MockNdt7ServicePlatform fakePlatform = MockNdt7ServicePlatform();
    Ndt7ServicePlatform.instance = fakePlatform;

    expect(await ndt7ServicePlugin.getPlatformVersion(), '42');
  });
}
