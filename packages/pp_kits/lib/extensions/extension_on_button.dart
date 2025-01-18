import 'package:flutter/material.dart';

extension ButtonExtension on ElevatedButton {
  /// 创建一个自定义的ElevatedButton。
  ///
  /// 这个方法提供了一种简便的方式來创建具有特定样式和行为的ElevatedButton。
  /// 通过指定不同的参数，可以定制按钮的文本、颜色、形状、大小等外观属性。
  ///
  /// 参数:
  ///  - text: 按钮上显示的文本。这个文本应该简短而有意义。
  ///  - onPressed: 按钮被按下时执行的回调函数。
  ///  - backgroundColor: 按钮的背景颜色，默认为蓝色。
  ///  - borderRadius: 按钮的圆角半径，默认为25.0。
  ///  - padding: 按钮内部的填充，默认为左右26.0的对称填充。
  ///  - fixedSize: 按钮的固定大小，默认高度为50。
  ///  - textStyle: 按钮文本的样式，默认字体大小为16，加粗。
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
