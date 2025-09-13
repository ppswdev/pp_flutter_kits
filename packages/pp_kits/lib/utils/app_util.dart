import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pp_kits/common/logger.dart';
import 'package:pp_kits/utils/keychain_util.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

/// 应用工具类
/// 提供一些常用的应用信息获取方法
class AppUtil {
  /// 获取钥匙串中存储的应用UUID
  static Future<String> getAppUUID() async {
    final appInfo = await getAppInfo();
    String? value =
        await KeychainUtil.read(key: '${appInfo.packageName}.appUUID');
    if (value == null) {
      value = const Uuid().v7();
      await KeychainUtil.write(
          key: '${appInfo.packageName}.appUUID', value: value);
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

  /// 设置状态栏样式
  ///
  /// @param isDark 是否为深色模式
  ///
  /// @param isTransparent 是否透明
  static void setStatusBarStyle(
      {bool isDark = false, bool isTransparent = true}) {
    if (GetPlatform.isAndroid) {
      if (isTransparent) {
        // 设置状态栏透明
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ));
      }

      // 设置状态栏内容颜色
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ));
    } else if (GetPlatform.isIOS) {}
  }

  /// 打开链接或者跳转到其他App
  /// @param url 链接
  ///
  /// 使用示例
  /// ``` dart
  /// void example() {
  ///   AppUtil.openLink('https://www.apple.com');
  /// }
  /// ```
  static void openLink(String url) async {
    if (GetUtils.isURL(url)) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          throw 'Could not launch $url';
        }
      } catch (e) {
        Logger.log('ppkits openLink error: $e');
      }
    }
  }

  /// 打开应用设置
  static void openAppSettings() {
    AppSettings.openAppSettings();
  }

  /// 方向是否是rtl
  /// 从右向左的语言：阿拉伯语、希伯来语(以色列)、波斯语、乌尔都语（巴基斯坦、印度）、叙利亚语、库尔德语(伊拉克)
  /// 默认为false
  static bool isRTL() {
    return Directionality.of(Get.context!) == TextDirection.rtl;
  }

  /// 分享
  ///
  /// @param subject 主题, 邮箱标题
  ///
  /// @param title 标题
  ///
  /// @param text 文本
  ///
  /// @param url 链接 https://www.apple.com
  ///
  /// @param files 文件 [XFile('${directory.path}/image1.jpg')...]
  ///
  static Future<bool> share(
      {String subject = '',
      String title = '',
      String text = '',
      String url = '',
      List<XFile> files = const []}) async {
    EasyLoading.show();
    ShareResult shareResult;
    ShareParams shareParams;
    if (files.isNotEmpty) {
      shareParams = ShareParams(files: files);
    } else if (url.isNotEmpty) {
      shareParams = ShareParams(
        title: title,
        uri: Uri.parse(url),
      );
    } else {
      shareParams = ShareParams(
        subject: subject,
        title: title,
        text: text,
      );
    }
    //检查是否是iPad
    if (GetPlatform.isIOS && Get.context?.isTablet == true) {
      // 获取屏幕尺寸
      final Size screenSize = MediaQuery.of(Get.context!).size;
      // 自定义固定值的 sharePositionOrigin
      final Rect sharePositionOrigin = Rect.fromCenter(
        center: Offset(screenSize.width / 2, screenSize.height / 2), // 屏幕中心点
        width: screenSize.width / 2, // 屏幕宽度的一半
        height: screenSize.height / 2, // 屏幕高度的一半
      );
      if (files.isNotEmpty) {
        shareParams = ShareParams(files: files);
      } else if (url.isNotEmpty) {
        shareParams = ShareParams(
          title: title,
          uri: Uri.parse(url),
          sharePositionOrigin: sharePositionOrigin,
        );
      } else {
        shareParams = ShareParams(
          subject: subject,
          title: title,
          text: text,
          sharePositionOrigin: sharePositionOrigin,
        );
      }
    }
    shareResult = await SharePlus.instance.share(shareParams);
    EasyLoading.dismiss();
    if (shareResult.status == ShareResultStatus.dismissed) {
      return false;
    }
    Logger.log('Thank you for sharing my website!');
    return true;
  }
}
