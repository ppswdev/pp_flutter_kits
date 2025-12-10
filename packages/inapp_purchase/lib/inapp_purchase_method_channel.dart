import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'inapp_purchase_platform_interface.dart';

/// An implementation of [InappPurchasePlatform] that uses method channels.
class MethodChannelInappPurchase extends InappPurchasePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('inapp_purchase');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
