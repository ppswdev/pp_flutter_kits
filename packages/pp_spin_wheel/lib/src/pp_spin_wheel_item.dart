import 'package:flutter/material.dart';

/// 旋转盘的item
class PPSpinWheelItem {
  final String title;
  final Color bgColor;
  final double weight;
  final bool selected;

  const PPSpinWheelItem({
    required this.title,
    required this.bgColor,
    required this.weight,
    this.selected = false,
  });

  /// 复制一个item
  PPSpinWheelItem copyWith({
    String? title,
    Color? bgColor,
    double? weight,
    bool? selected,
  }) {
    return PPSpinWheelItem(
      title: title ?? this.title,
      bgColor: bgColor ?? this.bgColor,
      weight: weight ?? this.weight,
      selected: selected ?? this.selected,
    );
  }
}
