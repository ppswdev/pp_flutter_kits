import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

/// 弹窗提示，加载，进度条等
class PPAlert {
  static var isLoading = false;
  static var isAlerted = false;

  /// 显示加载中
  static void showLoading(
      {String? text, int? timeoutSeconds, Function? onTimeout}) {
    isLoading = true;
    EasyLoading.show(status: text ?? 'Loading...');

    // 设置超时
    if (timeoutSeconds != null) {
      Future.delayed(Duration(seconds: timeoutSeconds), () {
        if (isLoading) {
          hideLoading();
          if (onTimeout != null) {
            onTimeout();
          }
        }
      });
    }
  }

  /// 隐藏加载
  static void hideLoading() {
    isLoading = false;
    EasyLoading.dismiss();
  }

  /// 显示提示
  static void showToast(String message) {
    EasyLoading.showToast(message);
  }

  /// 显示成功提示
  static void showSuccess(String message) {
    EasyLoading.showSuccess(message);
  }

  /// 显示错误提示
  static void showError(String message) {
    EasyLoading.showError(message);
  }

  /// 显示信息提示
  static void showInfo(String message) {
    EasyLoading.showInfo(message);
  }

  /// 显示警告提示
  static void showWarning(String message) {
    EasyLoading.showToast(message,
        toastPosition: EasyLoadingToastPosition.center);
  }

  /// 显示进度
  static void showProgress(double progress, {String? status}) {
    EasyLoading.showProgress(progress, status: status);
  }

  static SnackBarConfig snackBarConfig = SnackBarConfig();

  /// 显示自定义SnackBar
  static void showSnackBar({
    String title = 'Tips',
    String message = 'Messages',
    String okLabelText = 'OK',
    Function? onOK,
  }) {
    Get.snackbar(
      title,
      message,
      // 样式
      snackStyle: SnackStyle.FLOATING,
      backgroundGradient: snackBarConfig.backgroundGradient,
      backgroundColor: snackBarConfig.backgroundColor,
      colorText: snackBarConfig.colorText,
      barBlur: snackBarConfig.barBlur,
      //如果需要弹出时有模态全屏背景色，需要设置overlayBlur和overlayColor
      //overlayBlur: 1, // 遮罩模糊度
      //overlayColor: Colors.black.withValues(alpha: .5), // 遮罩颜色,
      //边框
      borderRadius: snackBarConfig.borderRadius,

      //间距位置
      maxWidth: snackBarConfig.maxWidth,
      margin: snackBarConfig.margin,
      padding: snackBarConfig.padding,
      snackPosition: snackBarConfig.snackPosition,

      //动画
      forwardAnimationCurve: Curves.linearToEaseOut, // 动画曲线
      reverseAnimationCurve: Curves.linearToEaseOut, // 反向动画曲线
      // forwardAnimationCurve: Curves.fastLinearToSlowEaseIn, // 动画曲线
      // reverseAnimationCurve: Curves.fastEaseInToSlowEaseOut, // 反向动画曲线
      animationDuration: Duration(milliseconds: 500), // 动画时间

      //其他
      duration: Duration(seconds: 3), // 显示时间
      isDismissible: true, // 是否可关闭
      onTap: (snack) {
        if (onOK != null) {
          onOK();
        }
      },
    );
  }

  /// 显示系统AlertDialog
  static void showSysAlert(
      {String title = 'Tips',
      String message = 'Messages',
      String okLabelText = 'OK',
      Function? onOK}) async {
    if (isAlerted) {
      return;
    }
    isAlerted = true;
    final result = await showOkAlertDialog(
      context: Get.context!,
      title: title,
      message: message,
      okLabel: okLabelText,
    );
    if (result == OkCancelResult.ok) {
      isAlerted = false;
      if (onOK != null) {
        onOK();
      }
    }
  }

  /// 显示系统确认对话框
  static void showSysConfirm(
      {String title = 'Confirm',
      String message = 'Do you want to do it?',
      String cancelLabelText = 'Cancel',
      String okLabelText = 'OK',
      Function? onCancel,
      required Function onConfirm}) async {
    if (isAlerted) {
      return;
    }
    isAlerted = true;
    final result = await showOkCancelAlertDialog(
      context: Get.context!,
      title: title,
      message: message,
      cancelLabel: cancelLabelText,
      okLabel: okLabelText,
      barrierDismissible: false,
      defaultType: OkCancelAlertDefaultType.cancel,
    );
    if (result == OkCancelResult.ok) {
      isAlerted = false;
      onConfirm();
    } else if (result == OkCancelResult.cancel) {
      isAlerted = false;
      if (onCancel != null) {
        onCancel();
      }
    }
  }

  /// 显示单个文本输入框弹窗
  static Future<String> showSingleTextInput({
    String title = 'Title',
    String message = '',
    String initialText = '',
    String hintText = '',
    String cancelLabelText = 'Cancel',
    String okLabelText = 'OK',
  }) async {
    final texts = await showTextInputDialog(
      context: Get.context!,
      title: title,
      message: message.isNotEmpty ? message : null,
      textFields: [
        DialogTextField(
          initialText: initialText,
          hintText: hintText,
        ),
      ],
    );
    return texts != null && texts.isNotEmpty ? texts[0] : '';
  }

  /// 显示2个文本输入框弹窗
  static Future<List<String>> showDoubleTextInput({
    String title = 'Title',
    String message = '',
    List<String>? initialTexts,
    List<String>? hintTexts,
    String cancelLabelText = 'Cancel',
    String okLabelText = 'OK',
  }) async {
    final texts = await showTextInputDialog(
      context: Get.context!,
      title: title,
      message: message.isNotEmpty ? message : null,
      textFields: [
        DialogTextField(
          initialText: initialTexts != null && initialTexts.isNotEmpty
              ? initialTexts[0]
              : '',
          hintText:
              hintTexts != null && hintTexts.isNotEmpty ? hintTexts[0] : '',
        ),
        DialogTextField(
          initialText: initialTexts != null && initialTexts.length > 1
              ? initialTexts[1]
              : '',
          hintText:
              hintTexts != null && hintTexts.length > 1 ? hintTexts[1] : '',
        ),
      ],
    );
    return texts ?? ['', ''];
  }
}

class SnackBarConfig {
  /// 背景渐变色
  final LinearGradient? backgroundGradient;

  /// 背景色
  final Color backgroundColor;

  /// 文字颜色
  final Color colorText;

  /// 背景模糊度
  final double barBlur;

  /// 边框圆角
  final double borderRadius;

  /// 最大宽度
  final double maxWidth;

  /// 外边距
  final EdgeInsets margin;

  /// 内边距
  final EdgeInsets padding;

  /// 位置
  final SnackPosition snackPosition;

  const SnackBarConfig({
    this.backgroundGradient,
    this.backgroundColor = Colors.black54,
    this.colorText = Colors.white,
    this.barBlur = 7,
    this.borderRadius = 15,
    this.maxWidth = 600,
    this.margin = const EdgeInsets.all(15),
    this.padding = const EdgeInsets.all(15),
    this.snackPosition = SnackPosition.TOP,
  });
}
