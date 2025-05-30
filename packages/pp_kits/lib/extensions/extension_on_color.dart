import 'dart:ui';

/// 自定义16进制颜色对象
/// 颜色创建示例:
/// ```dart
/// // 1. 使用Color构造函数
/// final color1 = Color(0xFFFF5722);  // 不透明橙色
/// final color2 = Color(0x80FF5722);  // 半透明橙色
///
/// // 2. 使用Color.fromARGB
/// final color3 = Color.fromARGB(255, 255, 87, 34);  // 不透明橙色
/// final color4 = Color.fromARGB(128, 255, 87, 34);  // 半透明橙色
///
/// // 3. 使用Color.fromRGBO
/// final color5 = Color.fromRGBO(255, 87, 34, 1.0);  // 不透明橙色
/// final color6 = Color.fromRGBO(255, 87, 34, 0.5);  // 半透明橙色
///
/// // 4. 使用HexColor
/// final color7 = HexColor('#FF5722');  // 不透明橙色
/// final color8 = HexColor('#FF5722', alpha: 0.5);  // 半透明橙色
///
/// // 5. 使用String扩展方法
/// final color9 = '#FF5722'.toColor();  // 不透明橙色
/// final color10 = '#FF5722'.toColor(alpha: 0.5);  // 半透明橙色
/// ```
class HexColor extends Color {
  /// 从十六进制字符串和透明度创建颜色
  /// hexColor: 十六进制字符串，如：#CCCCCC
  /// alpha: 透明度值，范围从 0.0（完全透明）到 1.0（完全不透明）
  ///
  /// 使用示例：
  /// ```dart
  /// final color = HexColor('#CCCCCC');
  /// final colorWithAlpha = HexColor('#CCCCCC', alpha: 0.5);
  /// ```
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

/// 字符串转颜色
extension String2ColorExtension on String {
  /// 将十六进制颜色字符串转换为 Color 对象。
  ///
  /// hexColor: 十六进制颜色字符串，如：#CCCCCC
  ///
  /// 可选的 [alpha] 参数表示透明度，范围从 0.0（完全透明）到 1.0（完全不透明）。
  ///
  /// 返回一个新的 Color 对象。
  ///
  /// 使用示例：
  /// ```dart
  /// final color = '#FF0000'.toColor(); // 红色
  /// final colorWithAlpha = '#FF0000'.toColor(alpha: 0.5); // 半透明红色
  /// ```
  Color toColor({double alpha = 1.0}) {
    // 确保透明度在0.0到1.0之间
    alpha = alpha.clamp(0.0, 1.0);
    // 将透明度从0.0-1.0转换为0-255
    int alphaValue = (alpha * 255).round();
    // 转换为十六进制字符串
    String alphaHex = alphaValue.toRadixString(16).padLeft(2, '0');

    final buffer = StringBuffer();
    buffer.write(alphaHex); // 使用计算得到的透明度值
    buffer.write(replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
