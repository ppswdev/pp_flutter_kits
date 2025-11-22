import 'package:flutter/material.dart';

extension ButtonExtension on ElevatedButton {
  /// 创建一个自定义的 [ElevatedButton]，用于简化具有特定样式和行为按钮的创建。
  ///
  /// 通过该方法，可以自定义按钮的文本内容、样式、颜色、尺寸和行为等属性，方便统一风格管理和代码复用。
  ///
  /// 参数说明:
  /// - [text] 按钮上显示的文本，建议简洁明了。
  /// - [onPressed] 按钮点击时的回调函数，不能为空。
  /// - [backgroundColor] 按钮背景色，默认为 [Colors.blue]。
  /// - [borderRadius] 按钮圆角半径，默认为 25.0。
  /// - [padding] 按钮内部填充，默认为左右各 26.0 的对称填充。
  /// - [fixedSize] 按钮固定尺寸，默认高度为 50。
  /// - [textStyle] 按钮文字样式，默认大小为 16，加粗。
  ///
  /// 返回值:
  /// 返回一个自定义样式的 [ElevatedButton]，其样式和功能由传入参数决定。
  ///
  /// 示例代码：
  /// ```dart
  /// ElevatedButton myBtn = ButtonExtension.normal(
  ///   text: '提交',
  ///   onPressed: () { print('按钮点击'); },
  ///   backgroundColor: Colors.green,
  /// );
  ///
  /// // 直接用于Widget树
  /// Widget build(BuildContext context) {
  ///   return Center(
  ///     child: ButtonExtension.normal(
  ///       text: '点击',
  ///       onPressed: () {
  ///         // 执行操作
  ///       },
  ///     ),
  ///   );
  /// }
  /// ```
  static ElevatedButton normal({
    required String text,
    required VoidCallback onPressed,
    Color backgroundColor = Colors.blue,
    double borderRadius = 25.0,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 26.0),
    Size fixedSize = const Size.fromHeight(50),
    TextStyle textStyle =
        const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding,
        fixedSize: fixedSize,
      ),
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }
}
