import 'package:flutter_test/flutter_test.dart';
import 'package:decibel_meter/decibel_meter.dart';
import 'package:decibel_meter/decibel_meter_platform_interface.dart';
import 'package:decibel_meter/decibel_meter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDecibelMeterPlatform
    with MockPlatformInterfaceMixin
    implements DecibelMeterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DecibelMeterPlatform initialPlatform = DecibelMeterPlatform.instance;

  test('$MethodChannelDecibelMeter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDecibelMeter>());
  });

  test('getPlatformVersion', () async {
    DecibelMeter decibelMeterPlugin = DecibelMeter();
    MockDecibelMeterPlatform fakePlatform = MockDecibelMeterPlatform();
    DecibelMeterPlatform.instance = fakePlatform;

    expect(await decibelMeterPlugin.getPlatformVersion(), '42');
  });
}
