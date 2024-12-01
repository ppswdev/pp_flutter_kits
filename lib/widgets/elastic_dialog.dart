import 'package:flutter/material.dart';

/*
//弹出一个对话框，位置在中心点向上偏移100
Get.dialog(
  Align(
    alignment: Alignment.center,
    child: Transform.translate(
      offset: const Offset(0, -100), // 水平不变，垂直向上偏移 -50
      child: ElasticDialog(
        child: const AspectRatio(
          aspectRatio: 1,
          child: GuidesVipAlert(),
        ),
      ),
    ),
  ),
  barrierDismissible: false,
  barrierColor: Colors.black.withOpacity(0.3),
);
*/
/// 弹性动画对话框
class ElasticDialog extends StatefulWidget {
  final Widget child;

  const ElasticDialog({super.key, required this.child});

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
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}
