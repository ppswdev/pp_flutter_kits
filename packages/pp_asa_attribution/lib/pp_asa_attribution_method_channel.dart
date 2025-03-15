import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pp_asa_attribution_platform_interface.dart';

/// An implementation of [PPAsaAttributionPlatform] that uses method channels.
class MethodChannelPPAsaAttribution extends PPAsaAttributionPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pp_asa_attribution');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  /// 获取归因token
  @override
  Future<String?> attributionToken() async {
    final token = await methodChannel.invokeMethod<String>('attributionToken');
    return token;
  }

  /// 请求归因详情
  @override
  Future<Map<String, dynamic>?> requestAttributionDetails() async {
    final Map? result =
        await methodChannel.invokeMethod<Map>('requestAttributionDetails');
    return result?.cast<String, dynamic>() ?? <String, dynamic>{};
  }
}
