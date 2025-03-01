import 'dart:ui';
import 'package:flutter/material.dart' show Colors, HSLColor, MaterialColor;

/// Flutter 中创建颜色的方法:
///
/// 1. 使用 Color 类:
///    ```dart
///    // 使用 ARGB 值创建颜色 (0xAARRGGBB)
///    Color(0xFF2196F3)  // 蓝色，完全不透明
///
///    // 使用 ARGB 分量创建颜色
///    Color.fromARGB(255, 33, 150, 243)  // 蓝色，完全不透明
///
///    // 使用 RGBA 分量创建颜色
///    Color.fromRGBO(33, 150, 243, 1.0)  // 蓝色，完全不透明
///    ```
///
/// 2. 使用预定义颜色:
///    ```dart
///    // 使用 Colors 类中的预定义颜色
///    Colors.blue
///    Colors.red
///    Colors.green
///
///    // 使用带有色调的预定义颜色
///    Colors.blue.shade500  // 标准蓝色
///    Colors.blue.shade900  // 深蓝色
///    Colors.blue.shade200  // 浅蓝色
///    ```
///
/// 3. 使用 MaterialColor:
///    ```dart
///    // 使用 MaterialColor 类创建颜色
///    MaterialColor(0xFF2196F3, <int, Color>{
///      50: Color(0xFFE3F2FD),
///      100: Color(0xFFBBDEFB),
///      200: Color(0xFF90CAF9),
///      300: Color(0xFF64B5F6),
///      400: Color(0xFF42A5F5),
///      500: Color(0xFF2196F3),
///      600: Color(0xFF1E88E5),
///      700: Color(0xFF1976D2),
///      800: Color(0xFF1565C0),
///      900: Color(0xFF0D47A1),
///    })
///    ```
///
/// 4. 使用 HSL/HSV 颜色模型:
///    ```dart
///    // 使用 HSL 颜色模型
///    HSLColor.fromAHSL(1.0, 210.0, 0.8, 0.5).toColor()
///
///    // 使用 HSV 颜色模型
///    HSVColor.fromAHSV(1.0, 210.0, 0.8, 0.9).toColor()
///    ```
///
/// 5. 颜色操作方法:
///    ```dart
///    // 透明度调整
///    Colors.blue.withOpacity(0.5)  // 半透明蓝色
///    Colors.blue.withAlpha(128)    // 半透明蓝色
///    ```
///
/// 6. 主题颜色:
///    ```dart
///    // 从主题中获取颜色
///    Theme.of(context).colorScheme.primary
///    Theme.of(context).colorScheme.secondary
///
///    // 使用 ColorScheme 创建颜色方案
///    ColorScheme.fromSeed(seedColor: Colors.blue)
///    ```
///
/// 7. 使用 HexColor 类:
///    ```dart
///    // 使用十六进制字符串创建颜色
///    HexColor('#2196F3')  // 蓝色，完全不透明
///
///    // 使用简写格式
///    HexColor('#F00')  // 红色
///
///    // 带透明度
///    HexColor('#2196F380')  // 蓝色，半透明
///
///    // 自定义透明度
///    HexColor('#2196F3', alpha: 0.5)  // 蓝色，半透明
///
///    // 不带#前缀
///    HexColor.fromStringWithoutHash('2196F3')
///
///    // 从RGB值创建
///    HexColor.fromRGBO(33, 150, 243, 255)
///    ```
///
/// 16进制颜色类
///
/// 提供从十六进制字符串创建颜色的功能
sealed class HexColor extends Color {
  /// 从十六进制字符串创建颜色
  ///
  /// [hexString] 十六进制颜色字符串，支持以下格式:
  /// - RGB (#RGB)
  /// - RGBA (#RGBA)
  /// - RRGGBB (#RRGGBB)
  /// - RRGGBBAA (#RRGGBBAA)
  ///
  /// [alpha] 可选的透明度值，范围从 0.0（完全透明）到 1.0（完全不透明）
  /// 当提供此参数时，会覆盖十六进制字符串中的透明度值
  factory HexColor(String hexString, {double? alpha}) {
    return _HexColorImpl(hexString, alpha: alpha);
  }

  /// 从十六进制字符串创建颜色，不带#前缀
  ///
  /// [hexString] 十六进制颜色字符串，不带#前缀
  /// [alpha] 可选的透明度值
  factory HexColor.fromStringWithoutHash(String hexString, {double? alpha}) {
    return _HexColorImpl('#$hexString', alpha: alpha);
  }

  /// 从RGB值创建十六进制颜色
  ///
  /// [r] 红色分量 (0-255)
  /// [g] 绿色分量 (0-255)
  /// [b] 蓝色分量 (0-255)
  /// [a] 透明度分量 (0-255)，默认为255（完全不透明）
  factory HexColor.fromRGBO(int r, int g, int b, [int a = 255]) {
    return _HexColorImpl.fromRGBO(r, g, b, a);
  }

  /// 构造函数
  const HexColor._(super.value);
}

/// 十六进制颜色实现类
final class _HexColorImpl extends HexColor {
  _HexColorImpl(String hexString, {double? alpha})
      : super._(_parseHexString(hexString, alpha));

  _HexColorImpl.fromRGBO(int r, int g, int b, [int a = 255])
      : super._(
            (a & 0xff) << 24 | (r & 0xff) << 16 | (g & 0xff) << 8 | (b & 0xff));

  /// 解析十六进制颜色字符串
  static int _parseHexString(String hexString, double? alpha) {
    // 移除前缀并转换为大写
    final cleanHex = hexString.toUpperCase().replaceAll("#", "").trim();

    // 处理不同长度的十六进制颜色
    final (String colorHex, int alphaValue) = switch (cleanHex.length) {
      3 => (
          // RGB -> RRGGBB
          cleanHex.split('').map((e) => '$e$e').join(''),
          alpha != null ? (alpha.clamp(0.0, 1.0) * 255).round() : 255
        ),
      4 => (
          // RGBA -> RRGGBB
          cleanHex.substring(0, 3).split('').map((e) => '$e$e').join(''),
          alpha != null
              ? (alpha.clamp(0.0, 1.0) * 255).round()
              : int.parse(cleanHex.substring(3, 4) * 2, radix: 16)
        ),
      6 => (
          cleanHex,
          alpha != null ? (alpha.clamp(0.0, 1.0) * 255).round() : 255
        ),
      8 => (
          cleanHex.substring(0, 6),
          alpha != null
              ? (alpha.clamp(0.0, 1.0) * 255).round()
              : int.parse(cleanHex.substring(6, 8), radix: 16)
        ),
      _ => throw ArgumentError(
          '无效的十六进制颜色格式: $hexString，支持的格式: #RGB, #RGBA, #RRGGBB, #RRGGBBAA')
    };

    final alphaHex = alphaValue.toRadixString(16).padLeft(2, '0');
    return int.parse('$alphaHex$colorHex', radix: 16);
  }

  @override
  Color withAlpha(int alpha) => _HexColorImpl.fromRGBO(red, green, blue, alpha);
}

/// 8. 使用 ColorExtension 扩展方法:
///    ```dart
///    // 转为十六进制字符串
///    Colors.blue.toHex()                     // #2196f3
///    Colors.blue.toHex(leadingHashSign: false)  // 2196f3
///    Colors.blue.toHex(includeAlpha: true)   // #ff2196f3
///    Colors.blue.toHex(uppercase: true)      // #2196F3
///
///    // 调整亮度
///    Colors.blue.adjustBrightness(0.2)   // 变亮
///    Colors.blue.adjustBrightness(-0.2)  // 变暗
///
///    // 调整饱和度
///    Colors.blue.adjustSaturation(0.3)   // 增加饱和度
///    Colors.blue.adjustSaturation(-0.3)  // 减少饱和度
///
///    // 调整色相
///    Colors.blue.adjustHue(60)  // 色相偏移60度
///
///    // 混合颜色
///    Colors.blue.mix(Colors.red, 0.5)  // 蓝色和红色的混合
///
///    // 颜色属性
///    Colors.blue.isDark        // 是否为深色
///    Colors.blue.isLight       // 是否为浅色
///    Colors.blue.contrastColor // 对比色（黑色或白色）
///
///    // 创建 Material 色板
///    Colors.blue.toMaterialColor()  // 生成包含不同明暗度的MaterialColor
///    ```
///
/// 颜色扩展方法
extension ColorExtension on Color {
  /// 返回十六进制字符串表示的颜色
  ///
  /// [leadingHashSign] 是否添加#前缀
  /// [includeAlpha] 是否包含透明度值
  /// [uppercase] 是否使用大写字母
  String toHex({
    bool leadingHashSign = true,
    bool includeAlpha = false,
    bool uppercase = false,
  }) {
    final hexString = StringBuffer();

    if (leadingHashSign) {
      hexString.write('#');
    }

    if (includeAlpha) {
      final alphaHex = alpha.toRadixString(16).padLeft(2, '0');
      hexString.write(uppercase ? alphaHex.toUpperCase() : alphaHex);
    }

    final components = [red, green, blue].map((component) {
      final hex = component.toRadixString(16).padLeft(2, '0');
      return uppercase ? hex.toUpperCase() : hex;
    });

    hexString.writeAll(components);
    return hexString.toString();
  }

  /// 创建一个亮度调整后的颜色
  ///
  /// [amount] 正值使颜色变亮，负值使颜色变暗
  /// 返回调整后的新颜色
  Color adjustBrightness(double amount) {
    final hsl = HSLColor.fromColor(this);
    final adjustedLightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(adjustedLightness).toColor();
  }

  /// 创建一个饱和度调整后的颜色
  ///
  /// [amount] 正值增加饱和度，负值减少饱和度
  /// 返回调整后的新颜色
  Color adjustSaturation(double amount) {
    final hsl = HSLColor.fromColor(this);
    final adjustedSaturation = (hsl.saturation + amount).clamp(0.0, 1.0);
    return hsl.withSaturation(adjustedSaturation).toColor();
  }

  /// 创建一个色相调整后的颜色
  ///
  /// [amount] 色相调整量，范围 0-360
  /// 返回调整后的新颜色
  Color adjustHue(double amount) {
    final hsl = HSLColor.fromColor(this);
    final adjustedHue = (hsl.hue + amount) % 360;
    return hsl.withHue(adjustedHue).toColor();
  }

  /// 创建一个与当前颜色混合的新颜色
  ///
  /// [other] 要混合的颜色
  /// [amount] 混合比例，0.0 表示完全使用当前颜色，1.0 表示完全使用 other 颜色
  /// 返回混合后的新颜色
  Color mix(Color other, double amount) {
    final ratio = amount.clamp(0.0, 1.0);

    return Color.fromARGB(
      _lerpInt(alpha, other.alpha, ratio),
      _lerpInt(red, other.red, ratio),
      _lerpInt(green, other.green, ratio),
      _lerpInt(blue, other.blue, ratio),
    );
  }

  /// 线性插值计算整数值
  static int _lerpInt(int a, int b, double t) => (a + (b - a) * t).round();

  /// 创建一个透明度调整后的颜色
  ///
  /// [opacity] 新的透明度值，范围 0.0-1.0
  /// 返回调整后的新颜色
  Color withOpacity(double opacity) =>
      Color.fromRGBO(red, green, blue, opacity.clamp(0.0, 1.0));

  /// 检查颜色是否为暗色
  ///
  /// 根据颜色的亮度判断，返回 true 表示暗色，false 表示亮色
  bool get isDark => computeLuminance() < 0.5;

  /// 检查颜色是否为亮色
  ///
  /// 根据颜色的亮度判断，返回 true 表示亮色，false 表示暗色
  bool get isLight => !isDark;

  /// 获取与当前颜色对比的颜色（黑色或白色）
  ///
  /// 根据当前颜色的亮度，返回黑色或白色，以确保良好的对比度
  Color get contrastColor => isDark ? Colors.white : Colors.black;

  /// 创建一个MaterialColor色板
  ///
  /// 基于当前颜色生成一个包含不同明暗度的MaterialColor
  /// 返回MaterialColor对象
  MaterialColor toMaterialColor() {
    final strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    final Map<int, Color> swatch = {};

    for (final strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = ds > 0
          ? adjustBrightness(ds)
          : adjustBrightness(ds * -1).adjustSaturation(ds * -0.5);
    }

    return MaterialColor(value, swatch);
  }
}
