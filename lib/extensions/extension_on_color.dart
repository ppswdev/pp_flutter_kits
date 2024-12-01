import 'dart:ui';

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

extension HexColorString on String {
  /// 将十六进制颜色字符串转换为 Color 对象。
  ///
  /// 可选的 [alpha] 参数表示透明度，范围从 0.0（完全透明）到 1.0（完全不透明）。
  /// 返回一个新的 Color 对象。
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
