import 'package:flutter/material.dart';

class PPSegmentedControl<T> extends StatefulWidget {
  /// 必选：选项列表
  final List<SegmentItem<T>> items;

  /// 可选：当前选中的值
  final T? selectedValue;

  /// 可选：选择变化回调
  final ValueChanged<T>? onChanged;

  /// 可选：组件宽度，默认自适应
  final double? width;

  /// 可选：组件高度，默认40
  final double height;

  /// 可选：组件圆角，默认8
  final double borderRadius;

  /// 可选：纯色背景
  final Color? backgroundColor;

  /// 可选：渐变背景色
  final Gradient? backgroundGradient;

  /// 可选：指示器纯色背景
  final Color? indicatorColor;

  /// 可选：指示器渐变色背景
  final Gradient? indicatorGradient;

  /// 可选：自定义指示器
  final Widget? indicator;

  /// 可选：指示器圆角，默认6
  final double indicatorBorderRadius;

  /// 可选：指示器阴影
  final List<BoxShadow>? indicatorShadow;

  /// 可选：未选中文字颜色，默认Colors.black54
  final Color unselectedTextColor;

  /// 可选：选中文字颜色，默认Colors.white
  final Color selectedTextColor;

  /// 可选：未选中文字样式
  final TextStyle? unselectedTextStyle;

  /// 可选：选中文字样式
  final TextStyle? selectedTextStyle;

  /// 可选：指示器动画持续时间，默认200ms
  final Duration animationDuration;

  /// 可选：指示器动画曲线
  final Curve animationCurve;

  const PPSegmentedControl({
    super.key,
    required this.items,
    this.selectedValue,
    this.onChanged,
    this.width,
    this.height = 40,
    this.borderRadius = 8,
    this.backgroundColor,
    this.backgroundGradient,
    this.indicatorColor,
    this.indicatorGradient,
    this.indicator,
    this.indicatorBorderRadius = 6,
    this.indicatorShadow,
    this.unselectedTextColor = Colors.black54,
    this.selectedTextColor = Colors.white,
    this.unselectedTextStyle,
    this.selectedTextStyle,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  State<PPSegmentedControl<T>> createState() => _PPSegmentedControlState<T>();
}

class _PPSegmentedControlState<T> extends State<PPSegmentedControl<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.animationCurve,
      ),
    );

    // 初始化选中索引
    _updateSelectedIndex();
  }

  @override
  void didUpdateWidget(PPSegmentedControl<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValue != widget.selectedValue) {
      _updateSelectedIndex();
    }
  }

  void _updateSelectedIndex() {
    final index = widget.items.indexWhere(
      (item) => item.value == widget.selectedValue,
    );
    if (index != -1) {
      setState(() {
        _selectedIndex = index;
      });
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 创建带主题颜色的Widget
  Widget _buildItemWithTheme(Widget child, Color color, bool isSelected) {
    return Theme(
      data: Theme.of(context).copyWith(
        // 设置图标主题颜色
        iconTheme: IconThemeData(color: color),
        // 设置文本主题颜色
        textTheme: Theme.of(context).textTheme.copyWith(
          bodyMedium: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          bodyLarge: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          labelMedium: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        // 设置按钮主题颜色
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(foregroundColor: color),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: color),
        ),
      ),
      child: AnimatedDefaultTextStyle(
        duration: widget.animationDuration,
        style:
            (isSelected
                ? widget.selectedTextStyle
                : widget.unselectedTextStyle) ??
            TextStyle(
              color: color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: widget.backgroundGradient,
        color: widget.backgroundGradient == null
            ? widget.backgroundColor
            : null,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / widget.items.length;
          return Stack(
            children: [
              // 选中指示器
              AnimatedPositioned(
                duration: widget.animationDuration,
                curve: widget.animationCurve,
                left: _selectedIndex * itemWidth,
                top: 0,
                bottom: 0,
                width: itemWidth,
                child: widget.indicator != null
                    ? widget.indicator!
                    : Container(
                        margin: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          gradient: widget.indicatorGradient,
                          color: widget.indicatorGradient == null
                              ? widget.indicatorColor
                              : null,
                          borderRadius: BorderRadius.circular(
                            widget.indicatorBorderRadius,
                          ),
                          boxShadow: widget.indicatorShadow,
                        ),
                      ),
              ),
              // 选项列表
              Row(
                children: List.generate(widget.items.length, (index) {
                  final item = widget.items[index];
                  final isSelected = index == _selectedIndex;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        _animationController.forward(from: 0);
                        widget.onChanged?.call(item.value);
                      },
                      child: Container(
                        color: Colors.transparent,
                        width: itemWidth,
                        height: widget.height,
                        child: Center(
                          child: _buildItemWithTheme(
                            item.child,
                            isSelected
                                ? widget.selectedTextColor
                                : widget.unselectedTextColor,
                            isSelected,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 选项数据类
class SegmentItem<T> {
  /// 选项值
  final T value;

  /// 选项内容
  final Widget child;

  const SegmentItem({required this.value, required this.child});
}
