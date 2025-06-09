import 'package:flutter/material.dart';

/// 弹性动画对话框
/// 使用示例
/// void example() {
// Get.dialog(
//   ElasticDialog(
//     offset: const Offset(0, -100),
//     backgroundColor: Colors.red,
//     radius: 20,
//     child: YourWidget(),
//   ),
//   barrierDismissible: false,
//   barrierColor: Colors.black.withOpacity(0.3),
// );
/// }
class ElasticDialog extends StatefulWidget {
  final Widget child;

  /// 偏移量
  final Offset offset;

  /// 背景颜色
  final Color backgroundColor;

  /// 圆角
  final double radius;

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

class ElasticDialogState extends State<ElasticDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
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
    _controller.dispose();
    super.dispose();
  }

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
