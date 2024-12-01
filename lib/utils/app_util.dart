import 'package:package_info_plus/package_info_plus.dart';

class AppUtil {
  /// 获取应用信息
  /// 返回 (应用名称, 包名, 版本号, 构建号)
  static Future<
      ({
        String appName,
        String packageName,
        String version,
        String buildNumber
      })> getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return (
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber
    );
  }
}
