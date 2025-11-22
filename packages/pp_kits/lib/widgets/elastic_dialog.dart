import 'package:flutter/material.dart';

/// [ElasticDialog]
///
/// 弹性动画弹出对话框组件，支持自定义出现弹性动效、圆角、背景及初始偏移位置。
///
/// 调用方式示例：
///
/// ```dart
/// Get.dialog(
///   ElasticDialog(
///     offset: const Offset(0, -100),
///     backgroundColor: Colors.red,
///     radius: 20,
///     child: YourWidget(),
///   ),
///   barrierDismissible: false,
///   barrierColor: Colors.black.withOpacity(0.3),
/// );
/// ```
///
/// 构造参数说明：
/// - [child] (必填)：对话框内容Widget。
/// - [offset]：弹出初始偏移量，默认为 Offset(0, -50)。
/// - [backgroundColor]：对话框背景色，默认为白色。
/// - [radius]：圆角半径，默认为 15。
///
/// 返回值说明：
///   返回一个带弹性放大动画的 [Dialog] 组件。若用在 [Get.dialog] 等弹窗场景，可实现带弹出特效的自定义对话框体验。
class ElasticDialog extends StatefulWidget {
  /// 弹窗内容
  final Widget child;

  /// 对话框弹出时的偏移量
  final Offset offset;

  /// 对话框背景色
  final Color backgroundColor;

  /// 圆角半径
  final double radius;

  /// 创建一个弹性动画对话框
  ///
  /// [child] 作为对话框内容
  /// [offset] 控制对话框初始弹出位置
  /// [backgroundColor] 设置背景色
  /// [radius] 控制圆角大小
  const ElasticDialog({
    super.key,
    required this.child,
    this.offset = const Offset(0, -50),
    this.backgroundColor = Colors.white,
    this.radius = 15,
  });

  @override
  ElasticDialogState createState() => ElasticDialogState();
}

/// [ElasticDialogState]
///
/// 控制动画与渲染弹性弹窗内容
class ElasticDialogState extends State<ElasticDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器和弹性出场动画
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    // 释放动画控制器资源
    _controller.dispose();
    super.dispose();
  }

  /// 构建弹窗Widget
  ///
  /// 返回：对齐居中、带弹性入场动画、有自定义圆角和背景的 [Dialog] 组件
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Transform.translate(
        offset: widget.offset,
        child: Dialog(
          insetPadding: EdgeInsets.zero,
          elevation: 1,
          backgroundColor: widget.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.radius),
          ),
          child: ScaleTransition(
            scale: _animation,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
