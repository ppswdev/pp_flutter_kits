import 'dart:math';

import 'package:flutter/material.dart';

/// 动画效果按钮
///
/// 使用示例：
///
/// ```dart
/// void example() {
///   AnimationButton(
///     child: Text('Tap me'),
///     onTap: () {},
///   );
/// }
/// ```
class AnimationButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  /// 动画类型
  /// 0: 无动画
  /// 1: 弹跳动画 - 垂直方向上下弹跳
  /// 2: 摇摆动画 - 水平方向左右摇摆
  /// 3: 脉冲动画 - 缩放效果
  /// 4: 抖动动画 - 旋转抖动
  /// 5: 缩放动画 - 简单缩放
  /// 6: 组合动画 - 缩放+旋转
  final int type;

  final Duration delayTap;

  const AnimationButton({
    super.key,
    required this.child,
    required this.onTap,
    this.type = 0,
    this.delayTap = const Duration(milliseconds: 0),
  });

  @override
  AnimationButtonState createState() => AnimationButtonState();
}

class AnimationButtonState extends State<AnimationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<double>? _scaleAnimation;
  Animation<double>? _rotateAnimation;
  Animation<Offset>? _translateAnimation;
  Animation<double>? _pulseAnimation;
  Animation<double>? _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    switch (widget.type) {
      case 0:
        // 无动画,不需要初始化任何动画
        break;

      case 1:
        // 弹跳动画 - 垂直方向
        _translateAnimation =
            TweenSequence<Offset>([
              TweenSequenceItem(
                tween: Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(0, -10),
                ),
                weight: 1.0,
              ),
              TweenSequenceItem(
                tween: Tween<Offset>(
                  begin: const Offset(0, -10),
                  end: Offset.zero,
                ),
                weight: 1.0,
              ),
            ]).animate(
              CurvedAnimation(parent: _controller, curve: Curves.bounceOut),
            );
        break;

      case 2:
        // 摇摆动画 - 水平方向
        // 使用sin函数实现平滑的左右摇摆
        break;

      case 3:
        // 脉冲动画 - 缩放效果
        _pulseAnimation =
            TweenSequence<double>([
              TweenSequenceItem(
                tween: Tween<double>(begin: 1.0, end: 1.2),
                weight: 1.0,
              ),
              TweenSequenceItem(
                tween: Tween<double>(begin: 1.2, end: 0.8),
                weight: 1.0,
              ),
              TweenSequenceItem(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                weight: 1.0,
              ),
            ]).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            );
        break;

      case 4:
        // 抖动动画 - 旋转抖动
        _shakeAnimation =
            TweenSequence<double>([
              TweenSequenceItem(
                tween: Tween<double>(begin: 0, end: 0.1),
                weight: 1.0,
              ),
              TweenSequenceItem(
                tween: Tween<double>(begin: 0.1, end: -0.1),
                weight: 2.0,
              ),
              TweenSequenceItem(
                tween: Tween<double>(begin: -0.1, end: 0.1),
                weight: 2.0,
              ),
              TweenSequenceItem(
                tween: Tween<double>(begin: 0.1, end: 0),
                weight: 1.0,
              ),
            ]).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            );
        break;

      case 5:
        // 缩放动画
        _scaleAnimation =
            TweenSequence<double>([
              TweenSequenceItem(
                tween: Tween<double>(begin: 1.0, end: 0.8),
                weight: 1.0,
              ),
              TweenSequenceItem(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                weight: 1.0,
              ),
            ]).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            );
        break;

      case 6:
        // 组合动画 - 缩放+旋转
        _scaleAnimation =
            TweenSequence<double>([
              TweenSequenceItem(
                tween: Tween<double>(begin: 1.0, end: 0.8),
                weight: 1.0,
              ),
              TweenSequenceItem(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                weight: 1.0,
              ),
            ]).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            );

        _rotateAnimation =
            TweenSequence<double>([
              TweenSequenceItem(
                tween: Tween<double>(begin: 0, end: 0.1),
                weight: 1.0,
              ),
              TweenSequenceItem(
                tween: Tween<double>(begin: 0.1, end: 0),
                weight: 1.0,
              ),
            ]).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            );
        break;
    }
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward().then((_) {
      _controller.reset();
    });
    Future.delayed(widget.delayTap, () {
      widget.onTap();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          switch (widget.type) {
            case 0:
              return widget.child;
            case 1:
              return Transform.translate(
                offset: _translateAnimation?.value ?? Offset.zero,
                child: widget.child,
              );
            case 2:
              return Transform.translate(
                offset: Offset(sin(_controller.value * 2 * 3.14159) * 5, 0),
                child: widget.child,
              );
            case 3:
              return Transform.scale(
                scale: _pulseAnimation?.value ?? 1.0,
                child: widget.child,
              );
            case 4:
              return Transform.rotate(
                angle: _shakeAnimation?.value ?? 0.0,
                child: widget.child,
              );
            case 5:
              return Transform.scale(
                scale: _scaleAnimation?.value ?? 1.0,
                child: widget.child,
              );
            case 6:
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scale(_scaleAnimation?.value ?? 1.0)
                  ..rotateZ(_rotateAnimation?.value ?? 0.0),
                child: widget.child,
              );
            default:
              return widget.child;
          }
        },
      ),
    );
  }
}
