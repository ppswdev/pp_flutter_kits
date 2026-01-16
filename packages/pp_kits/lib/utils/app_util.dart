import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pp_kits/commons/logger.dart';
import 'package:pp_kits/utils/keychain_util.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

/// 应用工具类
/// 提供一些常用的应用信息获取、设置和分享等方法
class AppUtil {
  /// 获取钥匙串中存储的应用唯一UUID，如果没有则自动生成并写入
  ///
  /// 返回值:
  ///   [Future<String>]: 应用的唯一标识UUID字符串
  ///
  /// 示例:
  /// ```dart
  /// String uuid = await AppUtil.getAppUUID();
  /// print('App UUID: $uuid');
  /// ```
  ///
  /// 返回示例:
  /// '018fc816-330b-7dab-b1f4-61109d8e9bc6'
  static Future<String> getAppUUID() async {
    final appInfo = await getAppInfo();
    String? value;
    try {
      value = await KeychainUtil.read(key: '${appInfo.packageName}.appUUID');
    } catch (e) {
      Logger.trace('Failed to read UUID from keychain: $e');
    }
    if (value == null) {
      value = const Uuid().v7();
      try {
        //防止触发安全机制崩溃
        Future.delayed(const Duration(milliseconds: 500));
        KeychainUtil.write(
          key: '${appInfo.packageName}.appUUID',
          value: value,
        ).then((bool success) {
          if (success) {
            Logger.trace('Write UUID to keychain success: $value');
          }
        });
      } catch (writeError) {
        Logger.trace('Failed to write UUID to keychain: $writeError');
      }
    }
    return value;
  }

  /// 获取应用的基础信息
  ///
  /// 返回值:
  ///   [Future<({String appName, String packageName, String version, String buildNumber})>]
  ///     应用的名称、包名、版本号和构建号
  ///
  /// 示例:
  /// ```dart
  /// final info = await AppUtil.getAppInfo();
  /// print('${info.appName} ${info.packageName} ${info.version} ${info.buildNumber}');
  /// ```
  ///
  /// 返回示例:
  /// (
  ///   appName: "My App",
  ///   packageName: "com.example.myapp",
  ///   version: "1.0.0",
  ///   buildNumber: "1"
  /// )
  static Future<
    ({String appName, String packageName, String version, String buildNumber})
  >
  getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return (
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
    );
  }

  /// 设置状态栏样式
  ///
  /// 参数:
  ///   [isDark] 是否使用深色主题，默认为false。
  ///   [isTransparent] 状态栏是否透明，默认为true。
  ///
  /// 示例:
  /// ```dart
  /// // 设置深色且透明状态栏
  /// AppUtil.setStatusBarStyle(isDark: true, isTransparent: true);
  /// ```
  static void setStatusBarStyle({
    bool isDark = false,
    bool isTransparent = true,
  }) {
    if (GetPlatform.isAndroid) {
      if (isTransparent) {
        // 设置状态栏透明
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        );
      }
      // 设置状态栏内容颜色
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
      );
    } else if (GetPlatform.isIOS) {
      // iOS暂未实现
    }
  }

  /// 打开链接或跳转到指定App
  ///
  /// 参数:
  ///   [url] 必填，目标链接（如"https://www.apple.com"）。
  ///
  /// 示例:
  /// ```dart
  /// AppUtil.openLink('https://www.apple.com');
  /// ```
  ///
  /// 返回:
  ///   无返回值，打开失败则在日志输出异常
  static void openLink(String url) async {
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

  /// 打开系统的应用设置页面
  ///
  /// 示例:
  /// ```dart
  /// AppUtil.openAppSettings();
  /// ```
  ///
  /// 返回:
  ///   无返回值，直接调用原生应用设置
  static void openAppSettings() {
    AppSettings.openAppSettings();
  }

  /// 判断当前环境是否为从右向左（RTL）方向语言
  ///
  /// 支持RTL的常用语种：阿拉伯语、希伯来语、波斯语、乌尔都语、叙利亚语等
  ///
  /// 示例:
  /// ```dart
  /// bool isRtl = AppUtil.isRTL();
  /// print(isRtl ? "RTL" : "LTR");
  /// ```
  ///
  /// 返回:
  ///   [bool] true表示RTL语言环境，否则为false
  static bool isRTL() {
    return Directionality.of(Get.context!) == TextDirection.rtl;
  }

  /// 分享内容到系统分享面板（文本、链接、图片等）
  ///
  /// 参数:
  ///   [subject] 分享主题或邮件主题，默认空字符串
  ///   [title] 分享标题，默认空字符串
  ///   [text] 分享文本，默认空字符串
  ///   [url] 分享链接，默认空字符串
  ///   [files] 要分享的文件列表，通常为图片，默认空
  ///
  /// 示例:
  /// ```dart
  /// // 分享文本
  /// await AppUtil.share(text: "Hello, world!");
  ///
  /// // 分享链接
  /// await AppUtil.share(url: "https://www.apple.com", title: "苹果官网");
  ///
  /// // 分享文件
  /// List<XFile> images = [XFile('/path/to/image.jpg')];
  /// await AppUtil.share(files: images);
  /// ```
  ///
  /// 返回值:
  ///   [Future<bool>] 分享是否被正常弹出（仅窗口关闭会返回false）
  ///
  /// 返回示例:
  ///   true  // 用户点击"分享"
  ///   false // 用户主动关闭分享面板
  static Future<bool> share({
    String subject = '',
    String title = '',
    String text = '',
    String url = '',
    List<XFile> files = const [],
  }) async {
    EasyLoading.show();
    ShareResult shareResult;
    ShareParams shareParams;
    if (files.isNotEmpty) {
      shareParams = ShareParams(files: files);
    } else if (url.isNotEmpty) {
      shareParams = ShareParams(title: title, uri: Uri.parse(url));
    } else {
      shareParams = ShareParams(subject: subject, title: title, text: text);
    }
    // 检查是否是iPad并调整分享浮窗位置
    if (GetPlatform.isIOS && Get.context?.isTablet == true) {
      final Size screenSize = MediaQuery.of(Get.context!).size;
      // 屏幕中心位置的一半宽/高的矩形区域
      final Rect sharePositionOrigin = Rect.fromCenter(
        center: Offset(screenSize.width / 2, screenSize.height / 2),
        width: screenSize.width / 2,
        height: screenSize.height / 2,
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
