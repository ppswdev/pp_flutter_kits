import 'dart:math';

import 'package:flutter/material.dart';

/// 扇形菜单
///
class PPFanMenu extends StatefulWidget {
  /// 子菜单
  final List<Widget> children;

  /// 子菜单点击事件
  final Function(int) onChildPressed;

  /// 展开状态改变事件
  final Function(bool)? onExpandChanged;

  /// 展开图标
  final Widget openIcon;

  /// 隐藏图标
  final Widget hideIcon;

  /// 对齐方式
  final AlignmentDirectional alignment;

  /// 展开半径
  final double radius;

  const PPFanMenu({
    super.key,
    required this.children,
    required this.onChildPressed,
    this.onExpandChanged,
    this.openIcon = const Icon(Icons.menu),
    this.hideIcon = const Icon(Icons.close),
    this.alignment = AlignmentDirectional.bottomEnd,
    this.radius = 100,
  });

  @override
  _PPFanMenuState createState() => _PPFanMenuState();
}

class _PPFanMenuState extends State<PPFanMenu>
    with SingleTickerProviderStateMixin {
  bool isOpen = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleMenu() {
    setState(() {
      isOpen = !isOpen;
      if (isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      widget.onExpandChanged?.call(isOpen);
    });
  }

  double _calcStartAngle() {
    switch (widget.alignment) {
      case AlignmentDirectional.topStart:
        return -120;
      case AlignmentDirectional.topCenter:
        return 0;
      case AlignmentDirectional.topEnd:
        return 120;
      case AlignmentDirectional.centerStart:
        return 135;
      case AlignmentDirectional.center:
        return 180;
      case AlignmentDirectional.centerEnd:
        return 15;
      case AlignmentDirectional.bottomStart:
        return -15;
      case AlignmentDirectional.bottomCenter:
        return 270;
      case AlignmentDirectional.bottomEnd:
        return 15;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: widget.alignment,
      children: [
        ...List.generate(widget.children.length, (index) {
          final angle = (index + 1) * 32;
          var startAngle = _calcStartAngle();
          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset.fromDirection(
                  angle * (pi / 180) + startAngle,
                  _animation.value * widget.radius,
                ),
                child: GestureDetector(
                  onTap: () => widget.onChildPressed(index),
                  child: Transform.scale(
                    scale: _animation.value,
                    child: Transform.rotate(
                      angle: _animation.value * (pi * 2),
                      child: AnimatedOpacity(
                        opacity: isOpen ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: child,
                      ),
                    ),
                  ),
                ),
              );
            },
            child: widget.children[index],
          );
        }),
        FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          focusElevation: 0,
          hoverElevation: 0,
          highlightElevation: 0,
          onPressed: toggleMenu,
          child: isOpen ? widget.hideIcon : widget.openIcon,
        ),
      ],
    );
  }
}
