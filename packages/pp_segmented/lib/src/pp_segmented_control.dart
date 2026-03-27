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

  /// 可选：是否允许滚动，默认false
  final bool isScrollable;

  /// 可选：选项最小宽度，仅在滚动模式下有效
  final double minItemWidth;

  /// 可选：选项内边距，仅在滚动模式下有效
  final EdgeInsets itemPadding;

  /// 可选：选中项背景色，仅在滚动模式下有效
  final Color? selectedItemBackgroundColor;

  /// 可选：选中项渐变色，仅在滚动模式下有效
  final Gradient? selectedItemBackgroundGradient;

  /// 可选：选中项圆角，仅在滚动模式下有效
  final double? selectedItemBorderRadius;

  /// 可选：未选中项背景色，仅在滚动模式下有效
  final Color? unselectedItemBackgroundColor;

  /// 可选：未选中项渐变色，仅在滚动模式下有效
  final Gradient? unselectedItemBackgroundGradient;

  /// 可选：未选中项圆角，仅在滚动模式下有效
  final double? unselectedItemBorderRadius;

  /// 可选：是否启用点击时自动滚动，仅在滚动模式下有效
  final bool autoScrollOnTap;

  /// 可选：Item之间的间距，默认5
  final double itemSpacing;

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
    this.isScrollable = false,
    this.minItemWidth = 60,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.selectedItemBackgroundColor,
    this.selectedItemBackgroundGradient,
    this.selectedItemBorderRadius,
    this.unselectedItemBackgroundColor,
    this.unselectedItemBackgroundGradient,
    this.unselectedItemBorderRadius,
    this.autoScrollOnTap = true,
    this.itemSpacing = 5,
  });

  @override
  State<PPSegmentedControl<T>> createState() => _PPSegmentedControlState<T>();
}

class _PPSegmentedControlState<T> extends State<PPSegmentedControl<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _itemKeys = [];

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

    // 初始化item keys
    _itemKeys
        .addAll(List.generate(widget.items.length, (index) => GlobalKey()));
  }

  @override
  void didUpdateWidget(PPSegmentedControl<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValue != widget.selectedValue) {
      _updateSelectedIndex();
    }

    // 更新item keys数量
    if (oldWidget.items.length != widget.items.length) {
      _itemKeys.clear();
      _itemKeys
          .addAll(List.generate(widget.items.length, (index) => GlobalKey()));
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
    _scrollController.dispose();
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
                    fontSize: 16,
                  ),
              bodyLarge: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 16,
                  ),
              labelMedium: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 16,
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
        style: (isSelected
                ? widget.selectedTextStyle
                : widget.unselectedTextStyle) ??
            TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
        child: child,
      ),
    );
  }

  /// 自动滚动到指定索引
  void _autoScrollToIndex(int index) {
    if (!widget.autoScrollOnTap || !widget.isScrollable) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      // 获取当前item的位置
      final itemContext = _itemKeys[index].currentContext;
      if (itemContext == null) return;

      final renderObject = itemContext.findRenderObject();
      if (renderObject == null) return;

      final renderBox = renderObject as RenderBox;
      final itemPosition = renderBox.localToGlobal(Offset.zero);
      final itemSize = renderBox.size;

      // 获取滚动视图的尺寸
      final scrollContext =
          _scrollController.position.context.notificationContext;
      if (scrollContext == null) return;

      final scrollRenderObject = scrollContext.findRenderObject();
      if (scrollRenderObject == null) return;

      final scrollRenderBox = scrollRenderObject as RenderBox;
      final scrollPosition = scrollRenderBox.localToGlobal(Offset.zero);
      final scrollSize = scrollRenderBox.size;

      // 计算目标位置
      final itemCenter = itemPosition.dx + itemSize.width / 2;
      final scrollCenter = scrollPosition.dx + scrollSize.width / 2;
      final offsetDifference = itemCenter - scrollCenter;

      // 当前滚动偏移
      final currentScrollOffset = _scrollController.offset;

      // 目标滚动偏移
      final targetScrollOffset = currentScrollOffset + offsetDifference;

      // 边界检查
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      final minScrollExtent = _scrollController.position.minScrollExtent;

      // 边界处理：前3个和后3个不滚动到中心
      final edgeThreshold = 3;
      final isInLeftEdge = index < edgeThreshold;
      final isInRightEdge = index >= widget.items.length - edgeThreshold;

      double finalScrollOffset;

      if (isInLeftEdge) {
        // 左边边界：保持在左侧
        finalScrollOffset = minScrollExtent;
      } else if (isInRightEdge) {
        // 右边边界：保持在右侧
        finalScrollOffset = maxScrollExtent;
      } else {
        // 中间区域：滚动到中心
        finalScrollOffset =
            targetScrollOffset.clamp(minScrollExtent, maxScrollExtent);
      }

      // 执行滚动
      _scrollController.animateTo(
        finalScrollOffset,
        duration: widget.animationDuration,
        curve: widget.animationCurve,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: widget.backgroundGradient,
        color:
            widget.backgroundGradient == null ? widget.backgroundColor : null,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: widget.isScrollable
          ? _buildScrollableContent()
          : _buildFixedContent(),
    );
  }

  /// 构建固定内容（平均分配宽度）
  Widget _buildFixedContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = widget.itemSpacing * (widget.items.length - 1);
        final availableWidth = constraints.maxWidth - totalSpacing;
        final itemWidth = availableWidth / widget.items.length;
        final isRTL = Directionality.of(context) == TextDirection.rtl;
        return Stack(
          children: [
            // 选中指示器
            AnimatedPositioned(
              duration: widget.animationDuration,
              curve: widget.animationCurve,
              left: isRTL
                  ? (widget.items.length - _selectedIndex - 1) *
                      (itemWidth + widget.itemSpacing)
                  : _selectedIndex * (itemWidth + widget.itemSpacing),
              top: 0,
              bottom: 0,
              width: itemWidth,
              child: widget.indicator != null
                  ? widget.indicator!
                  : Container(
                      margin: const EdgeInsets.all(3),
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

                return Padding(
                  padding: EdgeInsets.only(
                      right: index < widget.items.length - 1
                          ? widget.itemSpacing
                          : 0),
                  child: SizedBox(
                    width: itemWidth,
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
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  /// 构建滚动内容（自适应宽度）
  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final isSelected = index == _selectedIndex;

          return Padding(
            padding: EdgeInsets.only(
                right:
                    index < widget.items.length - 1 ? widget.itemSpacing : 0),
            child: GestureDetector(
              key: _itemKeys[index],
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                _animationController.forward(from: 0);
                widget.onChanged?.call(item.value);
                _autoScrollToIndex(index);
              },
              child: Container(
                constraints: BoxConstraints(minWidth: widget.minItemWidth),
                padding: widget.itemPadding,
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? widget.selectedItemBackgroundGradient
                      : widget.unselectedItemBackgroundGradient,
                  color: (isSelected
                              ? widget.selectedItemBackgroundGradient
                              : widget.unselectedItemBackgroundGradient) ==
                          null
                      ? (isSelected
                          ? widget.selectedItemBackgroundColor
                          : widget.unselectedItemBackgroundColor)
                      : null,
                  borderRadius: BorderRadius.circular(
                    isSelected
                        ? (widget.selectedItemBorderRadius ?? 0)
                        : (widget.unselectedItemBorderRadius ?? 0),
                  ),
                ),
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
