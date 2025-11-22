import 'dart:ui';
import 'package:flutter/material.dart';

/// [BlurBox] 是一个带有毛玻璃（高斯模糊）效果的透明背景容器部件，可自定义圆角、背景颜色、边框颜色和透明度。
///
/// 典型用法：
///
/// ```dart
/// BlurBox(
///   radius: 20.0,
///   color: Colors.white,
///   borderColor: Colors.blue,
///   opacity: 0.5,
///   child: Padding(
///     padding: EdgeInsets.all(16.0),
///     child: Text('Blurred Area'),
///   ),
/// )
/// ```
///
/// 参数说明：
/// - [radius]: 容器的圆角半径，默认为 30.0。
/// - [color]: 背景颜色，默认为白色。
/// - [borderColor]: 边框颜色，默认为白色。
/// - [opacity]: 背景颜色透明度，取值范围 0.0 ~ 1.0，默认为0.3。
///
/// 返回值：
///   返回一个带有毛玻璃效果和圆角、边框装饰的 [Widget]。
class BlurBox extends StatelessWidget {
  /// 圆角半径
  final double? radius;

  /// 背景颜色
  final Color? color;

  /// 边框颜色
  final Color? borderColor;

  /// 透明度
  final double? opacity;

  /// [BlurBox] 构造函数。
  ///
  /// 你可以自定义圆角半径、背景色、边框颜色和透明度。
  const BlurBox({
    super.key,
    this.radius = 30.0, // 默认圆角半径
    this.color = Colors.white, // 默认背景颜色
    this.borderColor = Colors.white, // 默认边框颜色
    this.opacity = 0.3, // 默认透明度
    this.child,
  });

  /// 毛玻璃容器内部渲染的子部件，可为空。
  final Widget? child;

  /// 构建毛玻璃效果 [Widget]。
  ///
  /// 返回: 一个包含高斯模糊效果和装饰的 [Widget]。
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius!)),
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
            child: child,
          ),
        ),
      ),
    );
  }
}
