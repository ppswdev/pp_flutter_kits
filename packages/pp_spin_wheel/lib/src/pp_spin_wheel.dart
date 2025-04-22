import 'dart:math';
import 'package:flutter/material.dart';

import 'pp_spin_wheel_item.dart';
import 'pp_spin_wheel_painters.dart';

class PPSpinWheel extends StatefulWidget {
  final List<PPSpinWheelItem> items;
  final double size;
  final double backgroundSize;
  final double wheelSize;
  final Widget? backgroundImage;
  final Widget? overlay;
  final Widget? spinIcon;
  final Widget? indicator;
  final int indicatorAnimateStyle;
  final bool enableWeight;
  final TextStyle? textStyle;
  final int numberOfTurns;
  final List<int>? filterIndexs;
  final Function(int)? onItemPressed;
  final VoidCallback? onStartPressed;
  final Function(int)? onAnimationEnd;
  final VoidCallback? onSpinFastAudio;
  final VoidCallback? onSpinSlowAudio;
  final Function(int)? onItemSpinning;

  const PPSpinWheel({
    super.key,
    required this.items,
    this.size = 350,
    this.wheelSize = 320,
    this.backgroundSize = 350,
    this.backgroundImage,
    this.overlay,
    this.spinIcon,
    this.indicator,
    this.indicatorAnimateStyle = 0,
    this.enableWeight = false,
    this.textStyle,
    this.numberOfTurns = 12,
    this.filterIndexs,
    this.onItemPressed,
    this.onStartPressed,
    this.onAnimationEnd,
    this.onSpinFastAudio,
    this.onSpinSlowAudio,
    this.onItemSpinning,
  });

  @override
  State<PPSpinWheel> createState() => PPSpinWheelState();
}

class PPSpinWheelState extends State<PPSpinWheel>
    with TickerProviderStateMixin {
  //转盘动画
  late AnimationController _animationController;
  Animation<double>? _spinAnimation;

  //指示器默认动画
  AnimationController? _indicatorController;

  //指示器抖动动画
  AnimationController? _shakeController;
  Animation<double>? _shakeAnimation;

  List<double> _itemAngles = [];
  // 存储每个item的中心点位置
  final List<Offset> _itemCenters = [];
  var _isSpinning = false;
  var _currentAngle = 0.0;
  var _currentItemIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animationController.addListener(() {
      // 可以在这里添加声音效果
      if (_animationController.value < 0.3) {
        // 快速旋转音效
        widget.onSpinFastAudio?.call();
      } else if (_animationController.value > 0.7) {
        // 减速音效
        widget.onSpinSlowAudio?.call();
      }
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
        });

        if (widget.indicatorAnimateStyle == 0) {
          _indicatorController?.reverse();
        } else {
          stopShaking();
        }

        widget.onAnimationEnd?.call(_currentItemIndex);
      }
    });

    if (widget.indicatorAnimateStyle == 0) {
      initIndicatorAnimation();
    } else {
      initShakeAnimation();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _indicatorController?.dispose();
    _shakeController?.dispose();
    super.dispose();
  }

  /// 指示器默认动画
  void initIndicatorAnimation() {
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      reverseDuration: const Duration(milliseconds: 500),
      value: 0,
      lowerBound: 0.0,
      upperBound: 0.52,
    );

    _indicatorController?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _indicatorController?.reverse();
      }
    });
  }

  /// 指示器抖动动画
  void initShakeAnimation() {
    // 1. 初始化抖动动画控制器
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // 一次抖动的时长
    );

    // 2. 创建抖动动画
    _shakeAnimation = TweenSequence<double>([
      // 向左摇摆
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -0.13) // -15度
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25.0,
      ),
      // 向右摇摆
      TweenSequenceItem(
        tween: Tween(begin: -0.13, end: 0.13) // +15度
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50.0,
      ),
      // 回到中间
      TweenSequenceItem(
        tween: Tween(begin: 0.13, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25.0,
      ),
    ]).animate(_shakeController!);

    // 3. 设置动画循环
    _shakeController?.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isSpinning) {
        _shakeController?.reset();
        _shakeController?.forward();
      }
    });
  }

  void stopShaking() {
    _shakeController?.stop();
    // 平滑回到中间位置
    _shakeController?.animateTo(
      0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _startSpinAnimation() {
    if (_isSpinning) return;

    // 保持当前角度,避免突然跳转
    List<int> availableIndexs = List.generate(widget.items.length, (i) => i);
    if (widget.filterIndexs != null) {
      availableIndexs.removeWhere((i) => widget.filterIndexs!.contains(i));
    }
    print('availableIndexs: $availableIndexs');
    if (availableIndexs.isEmpty) {
      _isSpinning = false;
      return;
    }

    setState(() {
      _isSpinning = true;
    });

    _currentItemIndex =
        availableIndexs[Random().nextInt(availableIndexs.length)];
    _currentAngle = 0.0;
    // 计算目标角度时考虑当前角度,基础旋转圈数 + 调整到目标位置所需的额外角度
    final targetAngle = widget.numberOfTurns * 2 * pi +
        (-pi / 2 - _itemAngles[_currentItemIndex]);

    // print('_itemAngles: $_itemAngles');
    // print(
    //     'currentAngle: $_currentAngle, itemAngle: ${_itemAngles[_currentItemIndex]}, targetAngle: $targetAngle, _currentItemIndex: $_currentItemIndex');

    _spinAnimation = Tween<double>(
      begin: _currentAngle,
      end: targetAngle,
    ).animate(CurvedAnimation(
      parent: _animationController,
      // 使用缓动曲线让结束更平滑
      curve: Curves.easeOutCubic,
    ));

    _animationController.reset();
    _animationController.forward();

    if (widget.indicatorAnimateStyle == 0) {
      _indicatorController?.reset();
      _indicatorController?.repeat(reverse: true);
    } else {
      _shakeController?.reset();
      _shakeController?.forward();
    }
  }

  void tapWheelItem(int index) {
    _onTapWheel(_itemCenters[index]);
  }

  void _onTapWheel(Offset localPosition) {
    if (_isSpinning) return;

    final center = Size(widget.wheelSize, widget.wheelSize).center(Offset.zero);

    // 计算点击位置相对于圆心的角度
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    // 从12点方向开始计算角度
    final angle = atan2(dx, -dy);

    // 将角度转换为0-2π范围
    final normalizedAngle = angle < 0 ? angle + 2 * pi : angle;

    // 计算总权重
    final totalWeight = widget.enableWeight
        ? widget.items.fold(0.0, (sum, item) => sum + item.weight)
        : widget.items.length.toDouble();

    // 找出点击的扇形区域
    double startAngle = 0;
    for (var i = 0; i < widget.items.length; i++) {
      final sweepAngle = widget.enableWeight
          ? 2 * pi * (widget.items[i].weight / totalWeight)
          : 2 * pi / widget.items.length;
      if (normalizedAngle >= startAngle &&
          normalizedAngle < startAngle + sweepAngle) {
        setState(() {
          final List<PPSpinWheelItem> newItems = List.of(widget.items);
          newItems[i] = widget.items[i].copyWith(
            selected: !widget.items[i].selected,
          );
          widget.items.clear();
          widget.items.addAll(newItems);
        });
        widget.onItemPressed?.call(i);
        break;
      }
      startAngle += sweepAngle;
    }
  }

  void startSpin() {
    widget.onStartPressed?.call();
    _isSpinning = false;
    _startSpinAnimation();
  }

  @override
  Widget build(BuildContext context) {
    // 计算总权重
    final totalWeight = widget.enableWeight
        ? widget.items.fold(0.0, (sum, item) => sum + item.weight)
        : widget.items.length.toDouble();

    // 计算每个item的中心点位置
    _itemCenters.clear();
    double startAngle = 0;
    final radius = widget.wheelSize / 2;
    final center = Size(widget.wheelSize, widget.wheelSize).center(Offset.zero);

    for (var i = 0; i < widget.items.length; i++) {
      final sweepAngle = widget.enableWeight
          ? 2 * pi * (widget.items[i].weight / totalWeight)
          : 2 * pi / widget.items.length;

      // 计算扇形中心点的角度
      final centerAngle = startAngle + sweepAngle / 2;

      // 计算中心点坐标
      final centerX = center.dx + radius * 0.7 * cos(centerAngle);
      final centerY = center.dy + radius * 0.7 * sin(centerAngle);

      _itemCenters.add(Offset(centerX, centerY));
      startAngle += sweepAngle;
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(children: [
        // 背景
        Center(
          child: SizedBox(
            width: widget.backgroundSize,
            height: widget.backgroundSize,
            child:
                widget.backgroundImage ?? Container(color: Colors.transparent),
          ),
        ),
        // 轮盘
        Center(
          child: ClipOval(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                _currentAngle = _spinAnimation?.value ?? _currentAngle;
                // 计算当前指向的item
                if (_itemAngles.isNotEmpty) {
                  final normalizedAngle =
                      (_currentAngle % (2 * pi) + 2 * pi) % (2 * pi);
                  for (var i = 0; i < _itemAngles.length; i++) {
                    final startAngle = i == 0 ? 0 : _itemAngles[i - 1];
                    final endAngle = _itemAngles[i];
                    if (normalizedAngle >= startAngle &&
                        normalizedAngle < endAngle) {
                      widget.onItemSpinning?.call(i);
                      break;
                    }
                  }
                }
                return Transform.rotate(
                  angle: _currentAngle,
                  child: GestureDetector(
                    onTapDown: (details) => _onTapWheel(details.localPosition),
                    child: CustomPaint(
                      size: Size(widget.wheelSize, widget.wheelSize),
                      painter: WheelPainter(
                        items: widget.items,
                        totalWeight: totalWeight,
                        enableWeight: widget.enableWeight,
                        textStyle: widget.textStyle ??
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                        onItemAnglesUpdated: (angles) {
                          _itemAngles = angles;
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // 轮盘覆盖图层
        if (widget.overlay != null)
          Center(
            child: IgnorePointer(
              child: widget.overlay!,
            ),
          ),
        // 轮盘指示器
        Align(
          alignment: Alignment.topCenter,
          child: AnimatedBuilder(
            animation: widget.indicatorAnimateStyle == 0
                ? _indicatorController!
                : _shakeAnimation!,
            builder: (context, child) {
              return Transform.rotate(
                angle: widget.indicatorAnimateStyle == 0
                    ? -_indicatorController!.value
                    : _shakeAnimation!.value,
                child: widget.indicator ??
                    CustomPaint(
                      size: const Size(30, 30),
                      painter: TrianglePainter(),
                    ),
              );
            },
          ),
        ),
        // 开始按钮
        widget.spinIcon != null
            ? Center(
                child: IconButton(
                  onPressed: () => startSpin(),
                  icon: widget.spinIcon!,
                ),
              )
            : Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: TextButton(
                    onPressed: () => startSpin(),
                    child: const Text('GO'),
                  ),
                ),
              ),
      ]),
    );
  }
}
