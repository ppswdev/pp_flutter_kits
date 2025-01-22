import 'package:flutter/material.dart';

/// 自定义进度条
class PPProgressBar extends StatelessWidget {
  /// 当前进度值 0.0 - 1.0
  final double value;

  /// 是否显示进度文本
  final bool showPercentage;

  /// 进度条高度
  final double height;

  /// 进度条圆角
  final double borderRadius;

  /// 默认轨道颜色
  final Color trackColor;

  /// 高亮轨道颜色
  final Color progressColor;

  /// 高亮轨道颜色
  final double progressRadius;

  /// 进度文本样式
  final TextStyle? percentageStyle;

  /// 覆盖层Widget
  final Widget? overlay;

  const PPProgressBar({
    super.key,
    required this.value,
    this.showPercentage = true,
    this.height = 50,
    this.borderRadius = 25,
    this.trackColor = const Color.fromARGB(255, 113, 75, 164),
    this.progressColor = const Color.fromARGB(255, 215, 73, 99),
    this.progressRadius = 1.0,
    this.percentageStyle,
    this.overlay,
  }) : assert(value >= 0 && value <= 1, 'Value must be between 0.0 and 1.0');

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Stack(
              children: [
                // 默认轨道
                Container(
                  width: double.infinity,
                  color: trackColor,
                ),

                // 进度轨道
                FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: progressColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(
                            value == 1.0 ? borderRadius : progressRadius),
                        bottomRight: Radius.circular(
                            value == 1.0 ? borderRadius : progressRadius),
                      ),
                    ),
                  ),
                ),

                // 进度文本
                if (showPercentage)
                  Center(
                    child: Text(
                      '${(value * 100).toInt()}%',
                      style: percentageStyle ??
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // 覆盖层
        if (overlay != null)
          SizedBox(
            width: double.infinity,
            height: height,
            child: overlay!,
          ),
      ],
    );
  }
}
