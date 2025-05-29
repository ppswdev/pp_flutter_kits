import 'pp_asa_attribution_platform_interface.dart';

class PPAsaAttribution {
  Future<String?> getPlatformVersion() {
    return PPAsaAttributionPlatform.instance.getPlatformVersion();
  }

  /// 获取归因token
  Future<String?> attributionToken() {
    return PPAsaAttributionPlatform.instance.attributionToken();
  }

  /// 请求归因详情
  Future<Map<String, dynamic>?> requestAttributionWithToken(String token) {
    return PPAsaAttributionPlatform.instance.requestAttributionWithToken(token);
  }

  /// 请求归因详情
  Future<Map<String, dynamic>?> requestAttributionDetails() {
    return PPAsaAttributionPlatform.instance.requestAttributionDetails();
  }
}
