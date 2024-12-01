import 'dart:ui';

/// 16进制颜色
class HexColor extends Color {
  /// 从十六进制字符串和透明度创建颜色
  /// hexColor: 十六进制字符串，如：#CCCCCC
  /// alpha: 透明度值，范围从 0.0（完全透明）到 1.0（完全不透明）
  HexColor(String hexColor, {double alpha = 1.0})
      : super(_getColorFromHex(hexColor, alpha));

  static int _getColorFromHex(String hexColor, double alpha) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      int alphaValue = (alpha.clamp(0.0, 1.0) * 255).round();
      String alphaHex = alphaValue.toRadixString(16).padLeft(2, '0');
      hexColor = alphaHex + hexColor; // 将透明度值添加到颜色代码前
    }
    return int.parse(hexColor, radix: 16);
  }
}

extension ColorExtension on Color {
  /// 返回十六进制字符串表示的颜色。
  ///
  /// 可选的 [leadingHashSign] 参数表示是否添加 "#" 前缀。
  /// 可选的 [includeAlpha] 参数表示是否包含透明度值。
  /// 返回一个十六进制字符串。
  String toHex({bool leadingHashSign = true, bool includeAlpha = false}) =>
      '${leadingHashSign ? '#' : ''}'
      '${includeAlpha ? alpha.toRadixString(16).padLeft(2, '0') : ''}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
