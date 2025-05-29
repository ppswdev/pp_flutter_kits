import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pp_asa_attribution_method_channel.dart';

abstract class PPAsaAttributionPlatform extends PlatformInterface {
  /// Constructs a PpAsaAttributionPlatform.
  PPAsaAttributionPlatform() : super(token: _token);

  static final Object _token = Object();

  static PPAsaAttributionPlatform _instance = MethodChannelPPAsaAttribution();

  /// The default instance of [PPAsaAttributionPlatform] to use.
  ///
  /// Defaults to [MethodChannelPPAsaAttribution].
  static PPAsaAttributionPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PPAsaAttributionPlatform] when
  /// they register themselves.
  static set instance(PPAsaAttributionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// 获取归因token
  Future<String?> attributionToken() {
    throw UnimplementedError('attributionToken() has not been implemented.');
  }

  /// 使用token请求归因详情
  Future<Map<String, dynamic>?> requestAttributionWithToken(String token) {
    throw UnimplementedError(
        'requestAttributionDetails() has not been implemented.');
  }

  /// 请求归因详情
  Future<Map<String, dynamic>?> requestAttributionDetails() {
    throw UnimplementedError(
        'requestAttributionDetails() has not been implemented.');
  }
}
