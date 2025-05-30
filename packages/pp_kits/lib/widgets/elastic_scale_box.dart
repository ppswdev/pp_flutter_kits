import 'package:flutter/material.dart';

/// 弹性缩放动画容器组件
///
/// 用法
/// ```dart
/// ElasticScaleBox(
///   child: Container(
///     width: 260.px,
///     height: 260.px,
///     decoration: const BoxDecoration(
///       color: Colors.white,
///       shape: BoxShape.circle,
///     ),
///   ),
/// )
/// ```
class ElasticScaleBox extends StatelessWidget {
  final Widget child;

  const ElasticScaleBox({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }
}
