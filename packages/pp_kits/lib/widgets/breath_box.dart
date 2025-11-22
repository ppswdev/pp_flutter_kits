import 'package:flutter/material.dart';

/// 呼吸灯动画组件，用于为指定的子组件添加呼吸缩放发光效果。
///
/// 该组件通过循环缩放及透明度动画，模拟“呼吸”特效，可自定义最小/最大缩放、发光色、大小，并在动画过程中获取缩放比例等信息。
///
/// ### 参数说明
/// - [child]: 需要添加呼吸效果的子组件（必填）
/// - [minScale]: 最小缩放比例，默认0.6
/// - [maxScale]: 最大缩放比例，默认1.6
/// - [size]: 呼吸组件的像素尺寸，默认180
/// - [glowColor]: 发光背景颜色，默认[Colors.lightBlue]
/// - [onScaleUp]: 放大动画方向回调
/// - [onScaleDown]: 缩小动画方向回调
/// - [onBreathing]: 呼吸过程缩放比例变化回调，参数为当前缩放比例
///
/// ### 使用示例
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
///
/// ### 返回
/// 返回一个带有呼吸特效的Widget。
class BreathBox extends StatelessWidget {
  /// 需要添加呼吸效果的子组件
  final Widget child;
  /// 最小缩放比例
  final double minScale;
  /// 最大缩放比例
  final double maxScale;
  /// 组件像素大小
  final double size;
  /// 发光背景颜色
  final Color glowColor;
  /// 放大动画方向回调
  final VoidCallback? onScaleUp;
  /// 缩小动画方向回调
  final VoidCallback? onScaleDown;
  /// 呼吸过程缩放比例变化时的回调
  final void Function(double scale)? onBreathing;

  /// 构造方法
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

  /// 构建呼吸灯动画组件。
  ///
  /// 返回：带呼吸缩放动画和发光背景效果的Widget。
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

/// 内部实现StatefulWidget，驱动呼吸动画及回调处理
class _BreathBoxInner extends StatefulWidget {
  /// 需要添加呼吸效果的子组件
  final Widget child;
  /// 最小缩放比例
  final double minScale;
  /// 最大缩放比例
  final double maxScale;
  /// 组件像素大小
  final double size;
  /// 发光背景颜色
  final Color glowColor;
  /// 放大动画方向回调
  final VoidCallback? onScaleUp;
  /// 缩小动画方向回调
  final VoidCallback? onScaleDown;
  /// 呼吸过程缩放比例变化时的回调
  final void Function(double scale)? onBreathing;

  /// 构造方法
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

/// State实现，控制动画和回调
class _BreathBoxInnerState extends State<_BreathBoxInner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _opacityAnimation;
  bool _isScalingUp = true;
  double _lastScale = 0.0;

  /// 初始化动画及回调监听
  ///
  /// 创建一个持续2秒的往返动画，缩放范围[minScale,maxScale]。
  /// 补间动画和透明度动画同步进行，并支持外部回调监听。
  ///
  /// 无返回值
  void _initAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // 呼吸时长2秒
    );

    // 动画往返循环
    _controller.repeat(reverse: true);

    // 缩放动画
    _animation =
        Tween<double>(begin: widget.minScale, end: widget.maxScale).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut,
          ),
        )..addListener(() {
            setState(() {});
            // 当缩放值变化超过一定阈值时触发呼吸回调
            if ((_animation.value - _lastScale).abs() > 0.1) {
              widget.onBreathing?.call(_animation.value);
              _lastScale = _animation.value;
            }
            // 动画方向控制对应回调
            if (_controller.status == AnimationStatus.forward && !_isScalingUp) {
              _isScalingUp = true;
              widget.onScaleUp?.call();
            } else if (_controller.status == AnimationStatus.reverse &&
                _isScalingUp) {
              _isScalingUp = false;
              widget.onScaleDown?.call();
            }
        });

    // 发光透明度动画
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  /// State 初始化时启动动画
  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  /// 销毁时释放动画控制器
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建呼吸灯核心UI。
  ///
  /// 返回：具有发光圆+呼吸动画的Widget（Container嵌套Transform+Stack）
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
            // 发光背景圆
            Center(
              child: Container(
                width: widget.size * 0.6,
                height: widget.size * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.glowColor.withOpacity(_opacityAnimation.value),
                ),
              ),
            ),
            // 主要子组件
            widget.child,
          ],
        ),
      ),
    );
  }
}
