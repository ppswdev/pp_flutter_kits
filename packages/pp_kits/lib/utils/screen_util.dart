import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 设备屏幕工具类
/// 提供获取当前屏幕宽度、高度、像素密度、设备类型判定、安全区、高度相关常用方法等
class DScreenUtil {
  /// 获取屏幕宽度
  ///
  /// 返回结果: [double] 屏幕宽度（单位: dp）
  ///
  /// 示例：
  /// ```dart
  /// double w = DScreenUtil.width();
  /// print(w); // 例如: 375.0
  /// ```
  static double width() {
    return Get.width;
  }

  /// 获取屏幕高度
  ///
  /// 返回结果: [double] 屏幕高度（单位: dp）
  ///
  /// 示例：
  /// ```dart
  /// double h = DScreenUtil.height();
  /// print(h); // 例如: 812.0
  /// ```
  static double height() {
    return Get.height;
  }

  /// 获取屏幕像素密度
  ///
  /// 返回结果: [double] 屏幕像素密度（devicePixelRatio）
  ///
  /// 示例：
  /// ```dart
  /// double ratio = DScreenUtil.pixelRatio();
  /// print(ratio); // 例如: 3.0
  /// ```
  static double pixelRatio() {
    return Get.mediaQuery.devicePixelRatio;
  }

  /// 判断是否是手机尺寸（宽度小于600dp）
  ///
  /// 返回结果: [bool] 是否为手机尺寸
  ///
  /// 示例：
  /// ```dart
  /// if (DScreenUtil.isPhone()) print('当前设备为手机');
  /// ```
  static bool isPhone() {
    return Get.width < 600;
  }

  /// 判断是否是平板尺寸（宽度大于等于600dp且小于1200dp）
  ///
  /// 返回结果: [bool] 是否为平板尺寸
  ///
  /// 示例：
  /// ```dart
  /// if (DScreenUtil.isTablet()) print('当前设备为平板');
  /// ```
  static bool isTablet() {
    final width = Get.width;
    return width >= 600 && width < 1200;
  }

  /// 判断是否是桌面尺寸（宽度大于等于1200dp）
  ///
  /// 返回结果: [bool] 是否为桌面(PC)尺寸
  ///
  /// 示例：
  /// ```dart
  /// if (DScreenUtil.isDesktop()) print('当前为桌面设备');
  /// ```
  static bool isDesktop() {
    return Get.width >= 1200;
  }

  /// 获取顶部安全距离高度（状态栏高度）
  ///
  /// 返回结果: [double] 顶部安全区高度（单位: dp）
  /// 使用 viewPadding 解决Android平台padding不准确的经典问题
  ///
  /// 示例：
  /// ```dart
  /// double safeTop = DScreenUtil.topSafeHeight();
  /// ```
  static double topSafeHeight() {
    final topPadding = Get.mediaQuery.viewPadding.top;
    if (Platform.isAndroid) {
      return topPadding > 0 ? topPadding : 24.0;
    }
    return topPadding;
  }

  /// 获取底部安全距离高度
  ///
  /// 返回结果: [double] 底部安全区高度（单位: dp）
  /// 使用 viewPadding 解决Android平台padding不准确的经典问题
  ///
  /// 示例：
  /// ```dart
  /// double safeBottom = DScreenUtil.bottomSafeHeight();
  /// ```
  static double bottomSafeHeight() {
    final bottomPadding = Get.mediaQuery.viewPadding.bottom;
    if (Platform.isAndroid) {
      return bottomPadding > 0 ? bottomPadding : 0.0;
    }
    return bottomPadding;
  }

  /// 获取AppBar默认高度
  ///
  /// 返回结果: [double] AppBar高度（单位: dp）
  /// - iOS: 状态栏高度 + kToolbarHeight
  /// - Android: 自适应状态栏高度 + kToolbarHeight
  ///
  /// 示例：
  /// ```dart
  /// double appBar = DScreenUtil.appBarHeight();
  /// ```
  static double appBarHeight() {
    return topSafeHeight() + kToolbarHeight;
  }

  /// 获取底部导航栏高度
  ///
  /// 返回结果: [double] BottomNavigationBar高度（单位: dp，默认为56.0）
  ///
  /// 示例：
  /// ```dart
  /// double navBarH = DScreenUtil.bottomNavigationBarHeight();
  /// ```
  static double bottomNavigationBarHeight() {
    return kBottomNavigationBarHeight;
  }

  /// 获取底部TabBar高度+底部安全距离高度
  ///
  /// 返回结果: [double] TabBar高度 + 底部安全区（单位: dp）
  /// - iOS: kBottomNavigationBarHeight + 底部安全区
  /// - Android: kBottomNavigationBarHeight + 自适应底部安全区
  ///
  /// 示例：
  /// ```dart
  /// double tabBarTotal = DScreenUtil.bottomBarTotalHeight();
  /// ```
  static double bottomBarTotalHeight() {
    return kBottomNavigationBarHeight + bottomSafeHeight();
  }

  /// 获取屏幕方向
  ///
  /// 返回结果: [Orientation] 屏幕方向，取值为 [Orientation.portrait] 或 [Orientation.landscape]
  ///
  /// 示例：
  /// ```dart
  /// Orientation orientation = DScreenUtil.orientation();
  /// ```
  static Orientation orientation() {
    return Get.mediaQuery.orientation;
  }

  /// 判断是否是横屏
  ///
  /// 返回结果: [bool] 是否为横屏
  ///
  /// 示例：
  /// ```dart
  /// if (DScreenUtil.isLandscape()) print('当前为横屏模式');
  /// ```
  static bool isLandscape() {
    return Get.mediaQuery.orientation == Orientation.landscape;
  }

  /// 判断是否是竖屏
  ///
  /// 返回结果: [bool] 是否为竖屏
  ///
  /// 示例：
  /// ```dart
  /// if (DScreenUtil.isPortrait()) print('当前为竖屏模式');
  /// ```
  static bool isPortrait() {
    return Get.mediaQuery.orientation == Orientation.portrait;
  }

  /// 获取状态栏高度
  ///
  /// 返回结果: [double] 状态栏高度（单位: dp）
  /// - iOS: 使用系统padding.top（动态获取刘海屏等）
  /// - Android: 在低版本中可能有不同的表现，保底24dp
  ///
  /// 示例：
  /// ```dart
  /// double statusH = DScreenUtil.statusBarHeight();
  /// ```
  static double statusBarHeight() {
    return topSafeHeight();
  }

  /// 获取可用屏幕高度（减去状态栏和底部安全区域）
  ///
  /// 返回结果: [double] 可用屏幕高度（单位: dp）
  /// - iOS: 减去系统顶部和底部安全区
  /// - Android: 减去自适应顶部和底部安全区
  ///
  /// 示例：
  /// ```dart
  /// double available = DScreenUtil.availableScreenHeight();
  /// ```
  static double availableScreenHeight() {
    return Get.height - topSafeHeight() - bottomSafeHeight();
  }
}
