import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 设备屏幕工具类
/// 获取屏幕宽度、高度、像素密度、是否是手机、平板、桌面、获取顶部安全距离高度、底部安全距离高度、AppBar默认高度、底部导航栏高度、底部TabBar高度+底部安全距离高度、屏幕方向、是否是横屏、是否是竖屏、获取状态栏高度、获取可用屏幕高度
class DScreenUtil {
  /// 获取屏幕宽度
  static double width() {
    return Get.width;
  }

  /// 获取屏幕高度
  static double height() {
    return Get.height;
  }

  /// 获取屏幕像素密度
  static double pixelRatio() {
    return Get.mediaQuery.devicePixelRatio;
  }

  /// 判断是否是手机尺寸（宽度小于600dp）
  static bool isPhone() {
    return Get.width < 600;
  }

  /// 判断是否是平板尺寸（宽度大于等于600dp且小于1200dp）
  static bool isTablet() {
    final width = Get.width;
    return width >= 600 && width < 1200;
  }

  /// 判断是否是桌面尺寸（宽度大于等于1200dp）
  static bool isDesktop() {
    return Get.width >= 1200;
  }

  /// 获取顶部安全距离高度（状态栏高度）
  static double topSafeHeight() {
    return Get.mediaQuery.padding.top;
  }

  /// 获取底部安全距离高度
  static double bottomSafeHeight() {
    return Get.mediaQuery.padding.bottom;
  }

  /// 获取AppBar默认高度
  static double appBarHeight() {
    return Get.mediaQuery.padding.top + kToolbarHeight;
  }

  /// 获取底部导航栏高度
  static double bottomNavigationBarHeight() {
    return kBottomNavigationBarHeight;
  }

  /// 获取底部TabBar高度+底部安全距离高度
  static double bottomBarTotalHeight() {
    return kBottomNavigationBarHeight + Get.mediaQuery.padding.bottom;
  }

  /// 获取屏幕方向
  static Orientation orientation() {
    return Get.mediaQuery.orientation;
  }

  /// 判断是否是横屏
  static bool isLandscape() {
    return Get.mediaQuery.orientation == Orientation.landscape;
  }

  /// 判断是否是竖屏
  static bool isPortrait() {
    return Get.mediaQuery.orientation == Orientation.portrait;
  }

  /// 获取状态栏高度
  static double statusBarHeight() {
    return Get.mediaQuery.padding.top;
  }

  /// 获取可用屏幕高度（减去状态栏和底部安全区域）
  static double availableScreenHeight() {
    final mediaQuery = Get.mediaQuery;
    return mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
  }
}
