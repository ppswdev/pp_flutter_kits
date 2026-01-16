import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/elastic_dialog.dart';

/// 居中弹窗
///
/// 居中弹窗是一种弹窗类型，它会在屏幕中央显示一个弹窗，而不是顶部或底部。
/// 居中弹窗通常用于显示重要的提示信息或要求用户确认的操作。
///
/// ```dart
/// PPCenterDialog.show(
///   barrierColor: Colors.transparent,
///   backgroundColor: Colors.white,
///   child:SubsPersuageAlert(),
/// );
/// ```
class PPCenterDialog {
  /// 显示居中弹窗
  ///
  /// 参数：
  /// - [barrierColor]：弹窗背景颜色
  /// - [barrierDismissible]：是否点击背景关闭弹窗
  /// - [backgroundColor]：内容背景颜色
  /// - [offset]：弹窗偏移量
  /// - [child]：弹窗标题
  static void show({
    Color? barrierColor,
    bool barrierDismissible = false,
    Color backgroundColor = Colors.transparent,
    Offset offset = const Offset(0, 0),
    Widget? child,
  }) {
    Get.dialog(
      ElasticDialog(
        backgroundColor: backgroundColor,
        offset: offset,
        child: child ?? const SizedBox(),
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.8),
    );
  }
}
