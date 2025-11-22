import 'package:flutter/material.dart';

/// `ElasticScaleBox` 是一个带有弹性缩放动画的容器组件，
/// 可用于包裹任意子组件，使其在显示时呈现弹性缩放效果。
///
/// 用法示例：
/// ```dart
/// ElasticScaleBox(
///   child: Container(
///     width: 260,
///     height: 260,
///     decoration: const BoxDecoration(
///       color: Colors.white,
///       shape: BoxShape.circle,
///     ),
///   ),
/// )
/// ```
///
/// 返回结果：
/// 返回一个 [TweenAnimationBuilder<double>] 包裹的 [Transform.scale] 组件，
/// 在指定动画周期内，child 从缩放比例 0 逐渐增长到 1，并带有 [Curves.elasticOut] 弹性动效。
class ElasticScaleBox extends StatelessWidget {
  /// 需要包裹实现弹性缩放动画的子组件
  final Widget child;

  /// 构造函数
  ///
  /// [child] 不能为空，必须指定。
  const ElasticScaleBox({
    super.key,
    required this.child,
  });

  /// 构建方法
  ///
  /// 返回一个包含弹性缩放动画的组件。
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
