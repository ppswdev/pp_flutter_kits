import 'dart:ui';
import 'package:flutter/material.dart';

/**
 * 
  BlurContainer(
    radius: 30.0,
    color: Colors.white,
    borderColor: Colors.blue,
    opacity: 0.3,
  )
 */
/// 毛玻璃透明背景
class BlurContainer extends StatelessWidget {
  final double? radius;
  final Color? color;
  final Color? borderColor;
  final double? opacity;

  const BlurContainer({
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
