import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';

class DeviceInfo {
  /// iOS、Android
  final String systemName;

  /// 18.5、 15
  final String systemVersion;

  /// iPhone,iPad,
  final String model;

  /// iPhone15,6 、Moto G (4)
  final String modelMachine;

  /// iPhone 14 Pro
  final String modelName;

  /// 是否是物理设备
  final bool isPhysicalDevice;

  /// 品牌: Apple、Moto
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

  /// 转换为JSON格式
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
/// 提供一些常用的设备信息获取方法
class DeviceUtil {
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

  static bool isPhone() {
    return Get.context!.isPhone;
  }

  static bool isTablet() {
    return Get.context!.isTablet;
  }

  static bool isPortrait() {
    return Get.context!.isPortrait;
  }

  static bool isLandscape() {
    return Get.context!.isLandscape;
  }

  static bool isWeb() {
    return GetPlatform.isWeb;
  }

  static bool isDesktop() {
    return GetPlatform.isWindows || GetPlatform.isMacOS || GetPlatform.isLinux;
  }
}
