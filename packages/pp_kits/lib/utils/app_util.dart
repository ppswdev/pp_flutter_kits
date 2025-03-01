import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pp_kits/utils/keychain_util.dart';
import 'package:uuid/uuid.dart';

/// 应用工具类
/// 提供一些常用的应用信息获取方法
class AppUtil {
  /// 获取钥匙串中存储的应用UUID
  static Future<String> getAppUUID(String packageName) async {
    String? value = await KeychainUtil.read(key: '$packageName.appUUID');
    if (value == null) {
      value = const Uuid().v7();
      await KeychainUtil.write(key: '$packageName.appUUID', value: value);
    }
    return value;
  }

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

  /// 方向是否是rtl
  /// 从右向左的语言：阿拉伯语、希伯来语(以色列)、波斯语、乌尔都语（巴基斯坦、印度）、叙利亚语、库尔德语(伊拉克)
  /// 默认为false
  static bool isRTL() {
    return Directionality.of(Get.context!) == TextDirection.rtl;
  }
}
