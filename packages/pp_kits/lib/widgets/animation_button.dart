import 'dart:math';

import 'package:flutter/material.dart';

/// 动画效果按钮组件
///
/// 提供多种动画类型（弹跳、摇摆、脉冲、抖动、缩放、组合），
/// 点击时执行动画并自动回调onTap函数。
///
/// 使用示例：
///
/// ```dart
/// AnimationButton(
///   child: Text('Tap me'),
///   onTap: () {
///     print('Button tapped');
///   },
///   type: 3, // 使用脉冲动画类型
///   delayTap: Duration(milliseconds: 200), // 点击事件延迟200ms执行
/// )
/// ```
class AnimationButton extends StatefulWidget {
  /// 要显示的子部件
  final Widget child;

  /// 点击回调函数
  final VoidCallback onTap;

  /// 动画类型
  ///
  /// 0: 无动画
  /// 1: 弹跳动画（垂直方向上下弹跳）
  /// 2: 摇摆动画（水平方向左右摇摆）
  /// 3: 脉冲动画（缩放）
  /// 4: 抖动动画（旋转抖动）
  /// 5: 缩放动画（简单缩放）
  /// 6: 组合动画（缩放+旋转）
  final int type;

  /// 点击事件延迟触发的时间，默认为0
  final Duration delayTap;

  /// 构造函数
  ///
  /// [child]：要显示的Widget内容
  /// [onTap]：点击后的回调
  /// [type]：动画类型，详见上述
  /// [delayTap]：点击事件延迟时间（可选）
  ///
  /// 返回:
  ///   AnimationButton 组件实例
  ///
  /// 示例:
  /// ```dart
  /// AnimationButton(
  ///   child: Icon(Icons.ac_unit),
  ///   onTap: () {},
  ///   type: 4,
  /// )
  /// ```
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

/// AnimationButton 的State
///
/// 控制动画的执行和Widget的渲染
class AnimationButtonState extends State<AnimationButton>
    with SingleTickerProviderStateMixin {
  /// 动画控制器
  late AnimationController _controller;

  /// 缩放动画
  Animation<double>? _scaleAnimation;

  /// 旋转动画
  Animation<double>? _rotateAnimation;

  /// 位移动画
  Animation<Offset>? _translateAnimation;

  /// 脉冲动画
  Animation<double>? _pulseAnimation;

  /// 抖动动画
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

  /// 处理按钮的按下（TapDown）事件
  ///
  /// 会先执行一次动画，然后延迟[widget.delayTap]之后触发[widget.onTap]回调
  ///
  /// 示例：
  /// ```dart
  /// _onTapDown(TapDownDetails(...));
  /// ```
  ///
  /// 返回值：无返回值
  void _onTapDown(TapDownDetails details) {
    _controller.forward().then((_) {
      _controller.reset();
    });
    Future.delayed(widget.delayTap, () {
      widget.onTap();
    });
  }

  /// 释放动画资源
  ///
  /// 返回值：无
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 渲染动画按钮Widget
  ///
  /// 返回值：
  ///   Widget（带有不同动画表现的child）
  ///
  /// 示例：
  /// ```dart
  /// Widget w = build(context);
  /// ```
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          switch (widget.type) {
            case 0:
              // 无动画，直接显示child
              return widget.child;
            case 1:
              // 弹跳动画（垂直方向移动）
              return Transform.translate(
                offset: _translateAnimation?.value ?? Offset.zero,
                child: widget.child,
              );
            case 2:
              // 摇摆动画（左右平滑移动）
              return Transform.translate(
                offset: Offset(
                  sin(_controller.value * 2 * pi) * 5,
                  0,
                ),
                child: widget.child,
              );
            case 3:
              // 脉冲动画（缩放）
              return Transform.scale(
                scale: _pulseAnimation?.value ?? 1.0,
                child: widget.child,
              );
            case 4:
              // 抖动动画（旋转抖动）
              return Transform.rotate(
                angle: _shakeAnimation?.value ?? 0.0,
                child: widget.child,
              );
            case 5:
              // 简单缩放动画
              return Transform.scale(
                scale: _scaleAnimation?.value ?? 1.0,
                child: widget.child,
              );
            case 6:
              // 组合动画（缩放+旋转）
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scale(_scaleAnimation?.value ?? 1.0)
                  ..rotateZ(_rotateAnimation?.value ?? 0.0),
                child: widget.child,
              );
            default:
              // 默认不做动画
              return widget.child;
          }
        },
      ),
    );
  }
}
