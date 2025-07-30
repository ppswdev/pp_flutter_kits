// 呼吸灯动画组件
import 'package:flutter/material.dart';

/// 使用示例:
/// ```dart
/// BreathBox(
///   minScale: 0.8,
///   maxScale: 1.3,
///   size: 150,
///   glowColor: Colors.blue,
///   onBreathing: (scale) {
///     print('当前缩放比例: $scale');
///   },
///   onScaleUp: () {
///     print('放大中');
///   },
///   onScaleDown: () {
///     print('缩小中');
///   },
///   child: Image.asset('assets/images/icon.png'),
/// )
/// ```

/// 呼吸灯动画组件
/// 通过缩放动画实现呼吸灯效果
/// [child] - 需要添加呼吸效果的子组件
/// [minScale] - 最小缩放比例,默认0.6
/// [maxScale] - 最大缩放比例,默认1.6
/// [size] - 组件大小,默认180
/// [glowColor] - 发光背景颜色,默认浅蓝色
/// [onScaleUp] - 放大时的回调
/// [onScaleDown] - 缩小时的回调
/// [onBreathing] - 呼吸过程中的回调,参数为当前缩放比例
class BreathBox extends StatelessWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final double size;
  final Color glowColor;
  final VoidCallback? onScaleUp;
  final VoidCallback? onScaleDown;
  final void Function(double scale)? onBreathing;

  const BreathBox({
    super.key,
    required this.child,
    this.minScale = 0.6,
    this.maxScale = 1.6,
    this.size = 180,
    this.glowColor = Colors.lightBlue,
    this.onScaleUp,
    this.onScaleDown,
    this.onBreathing,
  });

  @override
  Widget build(BuildContext context) {
    return _BreathBoxInner(
      minScale: minScale,
      maxScale: maxScale,
      size: size,
      glowColor: glowColor,
      onScaleUp: onScaleUp,
      onScaleDown: onScaleDown,
      onBreathing: onBreathing,
      child: child,
    );
  }
}

class _BreathBoxInner extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final double size;
  final Color glowColor;
  final VoidCallback? onScaleUp;
  final VoidCallback? onScaleDown;
  final void Function(double scale)? onBreathing;

  const _BreathBoxInner({
    required this.child,
    required this.minScale,
    required this.maxScale,
    required this.size,
    required this.glowColor,
    this.onScaleUp,
    this.onScaleDown,
    this.onBreathing,
  });

  @override
  State<_BreathBoxInner> createState() => _BreathBoxInnerState();
}

class _BreathBoxInnerState extends State<_BreathBoxInner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _opacityAnimation;
  bool _isScalingUp = true;
  double _lastScale = 0.0;

  /// 初始化动画
  /// 创建一个持续2秒的动画控制器
  /// 设置动画在正向完成后反向执行,形成循环效果
  void _initAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // 调整为2秒,更符合呼吸节奏
    );

    // 设置动画循环并反向执行
    _controller.repeat(reverse: true);

    // 创建一个从minScale到maxScale的补间动画
    _animation =
        Tween<double>(begin: widget.minScale, end: widget.maxScale).animate(
          CurvedAnimation(
            parent: _controller,
            // 使用ease曲线让动画更自然
            curve: Curves.easeInOut,
          ),
        )..addListener(() {
          setState(() {});

          // 当缩放值变化超过一定阈值时触发呼吸回调
          if ((_animation.value - _lastScale).abs() > 0.1) {
            widget.onBreathing?.call(_animation.value);
            _lastScale = _animation.value;
          }

          // 检测动画方向并触发回调
          if (_controller.status == AnimationStatus.forward && !_isScalingUp) {
            _isScalingUp = true;
            widget.onScaleUp?.call();
          } else if (_controller.status == AnimationStatus.reverse &&
              _isScalingUp) {
            _isScalingUp = false;
            widget.onScaleDown?.call();
          }
        });

    // 创建一个从0到0.7的透明度动画
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      child: Transform.scale(
        scale: _animation.value,
        child: Stack(
          children: [
            Center(
              child: Container(
                width: widget.size * 0.6,
                height: widget.size * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.glowColor.withValues(
                    alpha: _opacityAnimation.value,
                  ),
                ),
              ),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}
