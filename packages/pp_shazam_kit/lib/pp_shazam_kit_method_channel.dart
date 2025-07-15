import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pp_shazam_kit_platform_interface.dart';

/// An implementation of [PPShazamKitPlatform] that uses method channels.
class MethodChannelPpShazamKit extends PPShazamKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pp_shazam_kit');
  final _eventChannel = EventChannel('pp_shazam_kit_events');

  Stream<Map<String, dynamic>>? _eventStream;

  @override
  Stream<Map<String, dynamic>> get onEventStream {
    _eventStream ??= _eventChannel.receiveBroadcastStream().map(
      (event) => Map<String, dynamic>.from(event),
    );
    return _eventStream!;
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<void> startRecognize() async {
    await methodChannel.invokeMethod<void>('startRecognize');
  }

  @override
  Future<void> stopRecognize() async {
    await methodChannel.invokeMethod<void>('stopRecognize');
  }
}
