import 'package:flutter/material.dart';

/// 渐变文本组件
///
/// 一个简单易用的自定义文本渐变组件，支持各种渐变类型和文本样式设置。
class GradientText extends StatefulWidget {
  /// 要显示的文本内容
  ///
  /// 如果同时提供了[child]参数，则此参数将被忽略。
  final String text;

  /// 应用于文本的渐变效果
  ///
  /// 支持LinearGradient、RadialGradient、SweepGradient等所有Flutter渐变类型。
  final Gradient gradient;

  /// 文本样式
  ///
  /// 注意：无论设置什么颜色，都会被强制转换为白色以确保渐变效果正确显示。
  final TextStyle textStyle;

  /// 文本对齐方式
  final TextAlign textAlign;

  /// 自定义Text组件（优先级最高）
  ///
  /// 如果提供了此参数，将使用此Text组件并应用渐变效果，而忽略[text]参数。
  /// 同样，此Text组件的颜色也会被强制转换为白色。
  final Text? child;

  const GradientText({
    super.key,
    this.child,
    this.text = '',
    this.gradient = const LinearGradient(
      colors: [Colors.red, Colors.blue],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.textStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white, // 默认白色文本以便渐变显示
    ),
    this.textAlign = TextAlign.center,
  });

  @override
  State<GradientText> createState() => _GradientTextState();
}

class _GradientTextState extends State<GradientText> {
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => widget.gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: widget.child != null
          ? Text(
              widget.child!.data ?? '',
              style:
                  widget.child!.style?.copyWith(color: Colors.white) ??
                  const TextStyle(color: Colors.white),
              textAlign: widget.child!.textAlign ?? widget.textAlign,
            )
          : Text(
              widget.text,
              textAlign: widget.textAlign,
              style: widget.textStyle.copyWith(
                color: Colors.white,
              ), // 确保文本为白色以便渐变显示
            ),
    );
  }
}
