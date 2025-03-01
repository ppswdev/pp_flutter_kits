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

  /// 展开状态图标
  final Widget openIcon;

  /// 隐藏状态图标
  final Widget hideIcon;

  /// 对齐方式
  final AlignmentDirectional alignment;

  /// 展开半径
  final double radius;

  /// 自定义起始角度
  final double? startAngle;

  /// 自定义单个选项角度
  final double? singleAngle;

  const PPFanMenu({
    super.key,
    required this.children,
    required this.onChildPressed,
    this.onExpandChanged,
    this.openIcon = const Icon(Icons.menu),
    this.hideIcon = const Icon(Icons.close),
    this.alignment = AlignmentDirectional.bottomEnd,
    this.radius = 100,
    this.startAngle,
    this.singleAngle,
  });

  @override
  PPFanMenuState createState() => PPFanMenuState();
}

class PPFanMenuState extends State<PPFanMenu>
    with SingleTickerProviderStateMixin {
  bool isOpen = false;
  var startAngle = 0.0;
  var singleAngle = 40.0;
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

  void hideMenu() {
    if (isOpen) {
      setState(() {
        isOpen = false;
        _controller.reverse();
        widget.onExpandChanged?.call(false);
      });
    }
  }

  void initData(BuildContext context) {
    final count = widget.children.length;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    if (widget.startAngle != null && widget.singleAngle != null) {
      startAngle = widget.startAngle!;
      singleAngle = widget.singleAngle!;
    } else {
      switch (widget.alignment) {
        case AlignmentDirectional.topStart:
          startAngle = isRtl ? 55.0 : -35.0;
          singleAngle = _cornerSingleAngle(count);
          break;
        case AlignmentDirectional.topCenter:
          startAngle = -15;
          singleAngle = _sideCenterSingleAngle(count);
          break;
        case AlignmentDirectional.topEnd:
          startAngle = isRtl ? -35.0 : 55.0;
          singleAngle = _cornerSingleAngle(count);
          break;
        case AlignmentDirectional.centerStart:
          startAngle = isRtl ? 74 : -106;
          singleAngle = _sideCenterSingleAngle(count);
          break;
        case AlignmentDirectional.center:
          startAngle = 0;
          singleAngle = 360 / count;
          break;
        case AlignmentDirectional.centerEnd:
          startAngle = isRtl ? -106 : 74;
          singleAngle = _sideCenterSingleAngle(count);
          break;
        case AlignmentDirectional.bottomStart:
          startAngle = isRtl ? 145.0 : -125.0;
          singleAngle = _cornerSingleAngle(count);
          break;
        case AlignmentDirectional.bottomCenter:
          startAngle = 165;
          singleAngle = _sideCenterSingleAngle(count);
          break;
        case AlignmentDirectional.bottomEnd:
          startAngle = isRtl ? -125.0 : 145.0;
          singleAngle = _cornerSingleAngle(count);
          break;
      }
    }
  }

  double _cornerSingleAngle(int count) {
    if (count == 2) return 50.0;
    if (count == 3) return 40.0;
    if (count == 4) return 32.0;
    return 40.0;
  }

  double _sideCenterSingleAngle(int count) {
    if (count == 2) return 70.0;
    if (count == 3) return 52.0;
    if (count == 4) return 42.0;
    if (count == 5) return 35.0;
    if (count == 6) return 30.0;
    return 105.0;
  }

  @override
  Widget build(BuildContext context) {
    initData(context);
    return Stack(
      alignment: widget.alignment,
      children: [
        ...List.generate(widget.children.length, (index) {
          final angle = (index + 1) * singleAngle + startAngle;
          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset.fromDirection(
                  angle * (pi / 180),
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
