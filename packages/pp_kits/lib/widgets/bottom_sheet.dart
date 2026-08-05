import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 底部弹出框
///
/// ```dart
/// PPBottomSheet.show(
///   height: 0.3,
///   backgroundColor: HexColor('#F0FED8'),
///   borderRadius: BorderRadius.circular(16.w),
///   child: Text(
///     '这是一个底部弹出框',
///     style: TextStyle(
///       fontSize: 16.sp,
///       fontWeight: FontWeight.w700,
///       fontFamily: FontName.nunito,
///       color: Colors.black,
///     ),
///   ),
/// );
/// ```
class PPBottomSheet {
  /// 显示底部弹出框
  ///
  /// 一个封装了Flutter原生showModalBottomSheet的便捷组件，提供简洁的API和默认样式。
  ///
  /// 参数：
  /// - [height]：弹出框的高度
  ///   * 如果大于1：表示绝对像素高度
  ///   * 如果小于等于1：表示屏幕高度的比例
  ///   * 默认值：300像素
  /// - [child]：弹出框的自定义内容，如果为null，将显示默认文本"这是一个底部弹出框"
  /// - [barrierColor]：背景遮罩的颜色，默认值：透明色
  /// - [backgroundColor]：弹出框的背景颜色
  /// - [borderRadius]：弹出框的圆角设置，默认值：顶部左右16px圆角
  /// - [isScrollControlled]：是否使用全屏高度，设置为true时，弹出框可以通过拖拽覆盖整个屏幕
  /// - [isDismissible]：点击背景是否可以关闭弹出框
  /// - [enableDrag]：是否允许通过拖拽关闭弹出框
  /// - [clipBehavior]：裁剪行为
  static void show({
    double height = 300,
    Widget? child,
    Color barrierColor = Colors.transparent,
    Color backgroundColor = Colors.white,
    BorderRadius? borderRadius,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Clip? clipBehavior,
  }) {
    showModalBottomSheet(
      context: Get.context!,
      barrierColor: barrierColor,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius:
            borderRadius ??
            BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
      ),
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      clipBehavior: clipBehavior,
      builder: (BuildContext context) {
        var sHeight = 0.3;
        if (height > 1) {
          sHeight = height;
        } else {
          sHeight = MediaQuery.of(context).size.height * height;
        }
        return SizedBox(
          height: sHeight,
          child: Center(
            child:
                child ??
                Text(
                  '这是一个底部弹出框',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
          ),
        );
      },
    );
  }
}
