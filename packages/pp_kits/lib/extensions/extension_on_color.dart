import 'dart:ui';

/// 自定义16进制颜色对象
/// 
/// 颜色创建示例：
/// ```dart
/// // 1. 使用 Color 构造函数
/// final color1 = Color(0xFFFF5722);  // 不透明橙色
/// final color2 = Color(0x80FF5722);  // 半透明橙色
///
/// // 2. 使用 Color.fromARGB
/// final color3 = Color.fromARGB(255, 255, 87, 34);  // 不透明橙色
/// final color4 = Color.fromARGB(128, 255, 87, 34);  // 半透明橙色
///
/// // 3. 使用 Color.fromRGBO
/// final color5 = Color.fromRGBO(255, 87, 34, 1.0);  // 不透明橙色
/// final color6 = Color.fromRGBO(255, 87, 34, 0.5);  // 半透明橙色
///
/// // 4. 使用 HexColor
/// final color7 = HexColor('#FF5722');               // 不透明橙色
/// final color8 = HexColor('#FF5722', alpha: 0.5);   // 半透明橙色
///
/// // 5. 使用 String 扩展方法
/// final color9 = '#FF5722'.toColor();                // 不透明橙色
/// final color10 = '#FF5722'.toColor(alpha: 0.5);     // 半透明橙色
/// ```
class HexColor extends Color {
  /// 通过十六进制颜色字符串与可选透明度参数创建颜色对象
  /// 
  /// [hexColor] 一个形如 `#RRGGBB` 的16进制颜色字符串, 例如 `#CCCCCC`
  /// [alpha] 可选的透明度值, 取值范围为 0.0（完全透明）到 1.0（完全不透明）, 默认为 1.0
  /// 
  /// 返回结果: `HexColor` 实例，等效于颜色值 Color
  /// 
  /// 示例用法:
  /// ```dart
  /// final color = HexColor('#CCCCCC');
  /// final colorWithAlpha = HexColor('#CCCCCC', alpha: 0.5);
  /// ```
  HexColor(String hexColor, {double alpha = 1.0})
      : super(_getColorFromHex(hexColor, alpha));

  /// 内部方法: 将十六进制字符串与透明度参数转换为 int
  /// 
  /// [hexColor] 颜色字符串, 例如 "#FFFFFF"
  /// [alpha] 透明度 (0.0 - 1.0)
  /// 
  /// 返回结果: int 颜色值，适用于 Color 构造函数
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

/// 为 `Color` 类增加扩展方法
extension ColorExtension on Color {
  /// 获取当前颜色对象的16进制字符串表示
  ///
  /// [leadingHashSign] 是否包含 "#" 前缀，默认为 true
  /// [includeAlpha] 是否包含透明度值，默认为 false
  /// 
  /// 返回结果:
  /// String，格式如 `#RRGGBB` 或 `#AARRGGBB`
  /// 
  /// 示例：
  /// ```dart
  /// final c = Color(0xFF00FF00);
  /// String hexStr = c.toHex(); // "#00ff00"
  /// String hexWithAlpha = c.toHex(includeAlpha: true); // "#ff00ff00"
  /// ```
  String toHex({bool leadingHashSign = true, bool includeAlpha = false}) =>
      '${leadingHashSign ? '#' : ''}'
      '${includeAlpha ? alpha.toRadixString(16).padLeft(2, '0') : ''}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

/// 为 `String` 增加 16进制字符串转 Color 的扩展方法
extension String2ColorExtension on String {
  /// 将16进制颜色字符串转换为 `Color` 对象
  ///
  /// [alpha] 透明度，取值范围 0.0~1.0（默认为 1.0）
  ///
  /// 返回结果:
  /// 返回一个新的 `Color` 对象。例如，"#FF0000".toColor(alpha: 0.5) 返回半透明红色
  ///
  /// 示例：
  /// ```dart
  /// final color = '#FF0000'.toColor(); // 红色
  /// final colorWithAlpha = '#FF0000'.toColor(alpha: 0.5); // 半透明红色
  /// ```
  Color toColor({double alpha = 1.0}) {
    // 保证透明度在0-1之间
    alpha = alpha.clamp(0.0, 1.0);
    // 透明度转换为0-255
    int alphaValue = (alpha * 255).round();
    // 得到alpha部分的16进制字符串
    String alphaHex = alphaValue.toRadixString(16).padLeft(2, '0');

    final buffer = StringBuffer();
    buffer.write(alphaHex);
    buffer.write(replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
