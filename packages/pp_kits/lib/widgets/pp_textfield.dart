import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 自定义文本输入框组件
class PPTextField extends StatelessWidget {
  const PPTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.labelStyle = const TextStyle(color: Colors.grey, fontSize: 18),
    this.fillColor = const Color(0xFFEEEEEE), // 默认灰色背景
    this.borderRadius = 12.0,
    this.borderSide = BorderSide.none,
    this.focusedBorderSide =
        const BorderSide(color: Colors.blue, width: 1.0), // 聚焦时的边框样式
    this.errorBorderSide =
        const BorderSide(color: Colors.red, width: 1.0), // 错误时的边框样式
    this.clearColor = const Color(0xFFBDBDBD), // 默认灰色取消按钮
    this.maxLength = 50, // 新增的最大长度属性
    this.showCounter = false, // 默认不显示计数器
  });

  /// 文本控制器，用于获取和设置文本输入框的内容
  final TextEditingController controller;

  /// 标签文本，用于显示在文本输入框上方
  final String labelText;

  /// 标签文本的样式
  final TextStyle labelStyle;

  /// 文本输入框的背景颜色
  final Color fillColor;

  /// 文本输入框的圆角半径
  final double borderRadius;

  /// 文本输入框的边框样式
  final BorderSide borderSide;

  /// 聚焦时的边框样式
  final BorderSide focusedBorderSide;

  /// 错误时的边框样式
  final BorderSide errorBorderSide;

  /// 取消按钮的颜色
  final Color clearColor;

  /// 最大输入长度
  final int maxLength;

  /// 是否显示计数器
  final bool showCounter;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      inputFormatters: [
        LengthLimitingTextInputFormatter(maxLength), // 添加输入长度限制
      ],
      decoration: InputDecoration(
        labelText: labelText, // 设置标签文本
        labelStyle: labelStyle, // 设置标签文本的样式
        filled: true, // 启用填充背景色
        fillColor: fillColor, // 设置背景色
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius), // 设置圆角
          borderSide: borderSide, // 设置边框线
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius), // 设置圆角
          borderSide: borderSide, // 设置边框线
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius), // 设置圆角
          borderSide: focusedBorderSide, // 设置聚焦时的边框线
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius), // 设置圆角
          borderSide: errorBorderSide, // 设置错误时的边框线
        ),
        suffixIcon: controller.text.isNotEmpty // 如果文本框不为空，显示取消按钮
            ? IconButton(
                icon: Icon(
                  Icons.cancel,
                  color: clearColor, // 设置取消按钮的颜色
                ),
                onPressed: () {
                  controller.clear(); // 清空文本框内容
                },
              )
            : null, // 如果文本框为空，不显示取消按钮
        counterText: showCounter
            ? '${controller.text.length}/$maxLength'
            : null, // 根据showCounter显示或隐藏计数器文本
        counterStyle: TextStyle(color: Colors.grey[400]),
      ),
    );
  }
}
