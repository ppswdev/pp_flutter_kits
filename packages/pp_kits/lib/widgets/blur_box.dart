import 'dart:ui';
import 'package:flutter/material.dart';

/// 毛玻璃透明背景
class BlurBox extends StatelessWidget {
  /// 圆角半径
  final double? radius;

  /// 背景颜色
  final Color? color;

  /// 边框颜色
  final Color? borderColor;

  /// 透明度
  final double? opacity;

  const BlurBox({
    super.key,
    this.radius = 30.0, // 默认圆角半径
    this.color = Colors.white, // 默认背景颜色
    this.borderColor = Colors.white, // 默认边框颜色
    this.opacity = 0.3, // 默认透明度
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // 毛玻璃效果
          child: Container(
            decoration: BoxDecoration(
              color: color!.withOpacity(opacity!), // 半透明效果
              borderRadius: BorderRadius.circular(radius!),
              border: Border.all(
                width: 2.0,
                style: BorderStyle.solid,
                color: borderColor!, // 边框颜色
              ),
            ),
          ),
        ),
      ),
    );
  }
}
