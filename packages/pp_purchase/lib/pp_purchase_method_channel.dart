import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pp_purchase_platform_interface.dart';

/// An implementation of [PpPurchasePlatform] that uses method channels.
class MethodChannelPpPurchase extends PpPurchasePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pp_purchase');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
