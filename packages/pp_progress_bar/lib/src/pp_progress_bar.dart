import 'package:flutter/material.dart';

/// A customizable progress bar widget for Flutter.
/// This widget allows you to create a progress bar with various customization
/// options, including colors, height, border radius, and the option to show
/// percentage text. It also supports gradient colors for both the track and
/// progress sections.
/// The progress bar can be used to indicate the progress of a task or operation
/// and can be easily integrated into any Flutter application.
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

  final List<Color>? trackColors;

  /// 高亮轨道颜色
  final Color progressColor;

  final List<Color>? progressColors;

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
    this.trackColors,
    this.progressColor = const Color.fromARGB(255, 215, 73, 99),
    this.progressColors,
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
                  decoration: BoxDecoration(
                    color: trackColors != null ? null : trackColor,
                    gradient: trackColors != null
                        ? LinearGradient(
                            colors: trackColors!,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : null,
                  ),
                ),

                // 进度轨道
                FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: progressColors != null ? null : progressColor,
                      gradient: progressColors != null
                          ? LinearGradient(
                              colors: progressColors!,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
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
