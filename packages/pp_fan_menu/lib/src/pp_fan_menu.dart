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
  var startAngle = 0.0;
  var singleAngle = 40.0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    initData();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(covariant PPFanMenu oldWidget) {
    initData();
    super.didUpdateWidget(oldWidget);
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

  void initData() {
    final count = widget.children.length;
    switch (widget.alignment) {
      case AlignmentDirectional.topStart:
        startAngle = -35.0;
        if (count == 2) {
          singleAngle = 50.0;
        } else if (count == 3) {
          singleAngle = 40.0;
        } else if (count == 4) {
          singleAngle = 32.0;
        }
      case AlignmentDirectional.topCenter:
        startAngle = count * 270;
        if (count == 2) {
          startAngle = count * 337.5;
        } else if (count == 3) {
          startAngle = count * 350.0;
        } else if (count == 4) {
          startAngle = count * 354.0;
        } else if (count == 5) {
          startAngle = count * 356.5;
        } else if (count == 6) {
          startAngle = count * 357.5;
        }
        singleAngle = 180 / count;
      case AlignmentDirectional.topEnd:
        startAngle = 55.0;
        if (count == 2) {
          singleAngle = 50.0;
        } else if (count == 3) {
          singleAngle = 40.0;
        } else if (count == 4) {
          singleAngle = 32.0;
        }
      case AlignmentDirectional.centerStart:
        startAngle = count * 180;
        if (count == 2) {
          startAngle = count * 292.5;
        } else if (count == 3) {
          startAngle = count * 320.0;
        } else if (count == 4) {
          startAngle = count * 332.0;
        } else if (count == 5) {
          startAngle = count * 338.0;
        } else if (count == 6) {
          startAngle = count * 342.5;
        }
        singleAngle = 180 / count;
      case AlignmentDirectional.center:
        startAngle = 0;
        singleAngle = 360 / count;
      case AlignmentDirectional.centerEnd:
        startAngle = count * 0;
        if (count == 2) {
          startAngle = count * 23.0;
        } else if (count == 3) {
          startAngle = count * 20.0;
        } else if (count == 4) {
          startAngle = count * 17.0;
        } else if (count == 5) {
          startAngle = count * 14.5;
        } else if (count == 6) {
          startAngle = count * 12.5;
        }
        singleAngle = 180 / count;
      case AlignmentDirectional.bottomStart:
        startAngle = -125.0;
        if (count == 2) {
          singleAngle = 50.0;
        } else if (count == 3) {
          singleAngle = 40.0;
        } else if (count == 4) {
          singleAngle = 32.0;
        }
      case AlignmentDirectional.bottomCenter:
        startAngle = count * 90.0;
        if (count == 2) {
          startAngle = count * 67.5;
        } else if (count == 3) {
          startAngle = count * 50.0;
        } else if (count == 4) {
          startAngle = count * 39.5;
        } else if (count == 5) {
          startAngle = count * 32.5;
        } else if (count == 6) {
          startAngle = count * 27.5;
        }
        singleAngle = 180 / count;
      case AlignmentDirectional.bottomEnd:
        startAngle = 145.0;
        if (count == 2) {
          singleAngle = 50.0;
        } else if (count == 3) {
          singleAngle = 40.0;
        } else if (count == 4) {
          singleAngle = 32.0;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
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
