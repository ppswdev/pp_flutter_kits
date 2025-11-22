import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';

/// 设备信息结构体
///
/// 包含常用的主流设备环境关键信息，
/// 以便于快速判断和分析设备类型、系统以及硬件相关数据。
class DeviceInfo {
  /// 操作系统名称，例如: 'iOS' 或 'Android'
  final String systemName;

  /// 操作系统版本号，例如: '18.5'、 '15'
  final String systemVersion;

  /// 设备型号，如 'iPhone', 'iPad', 'Pixel'
  final String model;

  /// 设备机器码，iOS为 'iPhone15,6'，Android例: 'Moto G (4)'
  final String modelMachine;

  /// 设备可读名称（如 'iPhone 14 Pro'）
  final String modelName;

  /// 是否为物理设备（非模拟器）
  final bool isPhysicalDevice;

  /// 品牌(如 'Apple', 'Moto', 'Huawei')
  final String brand;

  DeviceInfo({
    required this.systemName,
    required this.systemVersion,
    required this.model,
    required this.modelMachine,
    required this.modelName,
    required this.isPhysicalDevice,
    required this.brand,
  });

  /// 转换为JSON格式(Map)
  ///
  /// 返回值：
  ///   [Map<String, dynamic>]: 包含设备的所有主要属性。
  ///
  /// 示例：
  /// ```dart
  /// final jsonMap = deviceInfo.toJson();
  /// print(jsonMap['systemName']); // 如 'iOS'
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'systemName': systemName,
      'systemVersion': systemVersion,
      'model': model,
      'modelMachine': modelMachine,
      'modelName': modelName,
      'isPhysicalDevice': isPhysicalDevice,
      'brand': brand,
    };
  }
}

/// 设备工具类
///
/// 提供获取当前设备信息、判断设备类型、方向等方法。
class DeviceUtil {
  /// 获取当前设备的详细信息
  ///
  /// 平台支持: Android、iOS
  ///
  /// 返回值：
  ///   [Future<DeviceInfo?>]，成功则返回 [DeviceInfo]，否则为 null（如不支持平台）。
  ///
  /// 示例：
  /// ```dart
  /// DeviceInfo? info = await DeviceUtil.info();
  /// if (info != null) {
  ///   print(info.toJson());
  /// }
  /// ```
  ///
  /// 返回结果示例：
  /// ```json
  /// {
  ///   "systemName": "iOS",
  ///   "systemVersion": "17.3",
  ///   "model": "iPad",
  ///   "modelMachine": "iPad14,3",
  ///   "modelName": "iPad Pro (12.9-inch)",
  ///   "isPhysicalDevice": true,
  ///   "brand": "Apple"
  /// }
  /// ```
  static Future<DeviceInfo?> info() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      return DeviceInfo(
        systemName: 'Android',
        systemVersion: androidInfo.version.release,
        model: androidInfo.model,
        modelMachine: androidInfo.device,
        modelName: androidInfo.name,
        isPhysicalDevice: androidInfo.isPhysicalDevice,
        brand: androidInfo.brand,
      );
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      return DeviceInfo(
        systemName: iosInfo.systemName,
        systemVersion: iosInfo.systemVersion,
        model: iosInfo.model,
        modelMachine: iosInfo.utsname.machine,
        modelName: iosInfo.modelName,
        isPhysicalDevice: iosInfo.isPhysicalDevice,
        brand: 'Apple',
      );
    }
    return null;
  }

  /// 判断当前设备是否为手机
  ///
  /// 返回值：
  ///   [bool]，为手机时为 true
  ///
  /// 示例：
  /// ```dart
  /// if (DeviceUtil.isPhone()) {
  ///   print("当前为手机");
  /// }
  /// ```
  static bool isPhone() {
    return Get.context!.isPhone;
  }

  /// 判断当前设备是否为平板
  ///
  /// 返回值：
  ///   [bool]，为平板时为 true
  ///
  /// 示例：
  /// ```dart
  /// if (DeviceUtil.isTablet()) {
  ///   print("当前为平板");
  /// }
  /// ```
  static bool isTablet() {
    return Get.context!.isTablet;
  }

  /// 判断屏幕方向是否为竖屏
  ///
  /// 返回值：
  ///   [bool]，竖屏为 true
  ///
  /// 示例：
  /// ```dart
  /// if (DeviceUtil.isPortrait()) {
  ///   print("竖屏模式");
  /// }
  /// ```
  static bool isPortrait() {
    return Get.context!.isPortrait;
  }

  /// 判断屏幕方向是否为横屏
  ///
  /// 返回值：
  ///   [bool]，横屏为 true
  ///
  /// 示例：
  /// ```dart
  /// if (DeviceUtil.isLandscape()) {
  ///   print("横屏模式");
  /// }
  /// ```
  static bool isLandscape() {
    return Get.context!.isLandscape;
  }

  /// 判断当前运行环境是否为Web
  ///
  /// 返回值：
  ///   [bool]，Web则返回 true
  ///
  /// 示例：
  /// ```dart
  /// if (DeviceUtil.isWeb()) {
  ///   print("Web端运行");
  /// }
  /// ```
  static bool isWeb() {
    return GetPlatform.isWeb;
  }

  /// 判断当前运行环境是否为桌面系统（Windows/MacOS/Linux)
  ///
  /// 返回值：
  ///   [bool]，桌面端则返回 true
  ///
  /// 示例：
  /// ```dart
  /// if (DeviceUtil.isDesktop()) {
  ///   print("Desktop端运行");
  /// }
  /// ```
  static bool isDesktop() {
    return GetPlatform.isWindows || GetPlatform.isMacOS || GetPlatform.isLinux;
  }
}
