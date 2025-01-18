import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ndt7_service_platform_interface.dart';

/// An implementation of [Ndt7ServicePlatform] that uses method channels.
class MethodChannelNdt7Service extends Ndt7ServicePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ndt7_service');

  static const EventChannel _eventChannel = EventChannel('ndt7_service_events');

  Stream<Map<String, dynamic>>? _eventStream;

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> loadServers() async {
    await methodChannel.invokeMethod('loadServers');
  }

  @override
  Future<void> startTest(int index) async {
    await methodChannel.invokeMethod('startTest', {'index': index});
  }

  @override
  Future<void> stopTest() async {
    await methodChannel.invokeMethod('stopTest');
  }

  @override
  Stream<Map<String, dynamic>> get onEventStream {
    _eventStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event));
    return _eventStream!;
  }
}
