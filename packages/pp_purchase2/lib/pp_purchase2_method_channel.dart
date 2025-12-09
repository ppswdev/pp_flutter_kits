import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pp_purchase2_platform_interface.dart';

/// An implementation of [PpPurchase2Platform] that uses method channels.
class MethodChannelPpPurchase2 extends PpPurchase2Platform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pp_purchase2');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
