import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

/// PPAlert
///
/// 全局弹窗工具类，提供加载中、提示、成功、错误、信息、警告、进度、SnackBar、系统对话框等功能的静态方法。
///
/// 通常用作 App 通用弹窗提示、加载、进度条等场景。
///
/// ## 用法示例
/// ```dart
/// // 显示加载
/// PPAlert.showLoading(text: "加载中...");
///
/// // 隐藏加载
/// PPAlert.hideLoading();
///
/// // 成功提示
/// PPAlert.showSuccess("操作成功");
///
/// // 错误提示
/// PPAlert.showError("操作失败");
///
/// // 警告提示
/// PPAlert.showWarning("请注意！");
///
/// // 自定义SnackBar
/// PPAlert.showSnackBar(title: "Tip", message: "Something happened!");
///
/// // 显示系统确认对话框
/// PPAlert.showSysConfirm(
///   title: "确认操作",
///   message: "是否要继续？",
///   onConfirm: () { print("用户确认"); },
///   onCancel: () { print("用户取消"); },
/// );
/// ```
class PPAlert {
  /// 是否处于加载中状态
  static var isLoading = false;

  /// 是否已弹出系统对话框
  static var isAlerted = false;

  /// 显示加载中弹窗
  ///
  /// [text]         加载文字（可选，默认'Loading...'）
  /// [timeoutSeconds] 超时时间（秒，超时后自动隐藏并回调）
  /// [onTimeout]    超时回调
  ///
  /// ## 用法示例
  /// ```dart
  /// PPAlert.showLoading(text: "请稍候...", timeoutSeconds: 5, onTimeout: () {
  ///   print("加载超时");
  /// });
  /// ```
  static void showLoading({
    String? text,
    int? timeoutSeconds,
    Function? onTimeout,
  }) {
    isLoading = true;
    EasyLoading.show(status: text ?? 'Loading...');

    // 设置超时 (到达时间自动隐藏loading，并回调 onTimeout)
    if (timeoutSeconds != null) {
      Future.delayed(Duration(seconds: timeoutSeconds), () {
        if (isLoading) {
          dismiss();
          if (onTimeout != null) {
            onTimeout();
          }
        }
      });
    }
  }

  /// 隐藏加载弹窗
  ///
  /// ## 用法示例
  /// ```dart
  /// PPAlert.hideLoading();
  /// ```
  @Deprecated('Use dismiss() instead')
  static void hideLoading() {
    isLoading = false;
    EasyLoading.dismiss();
  }

  /// 隐藏加载弹窗
  ///
  /// ## 用法示例
  /// ```dart
  /// PPAlert.dismiss();
  /// ```
  static void dismiss() {
    isLoading = false;
    EasyLoading.dismiss();
  }

  /// 显示全局Toast提示
  ///
  /// [message] 提示内容
  ///
  /// ## 用法示例
  /// ```dart
  /// PPAlert.showToast("操作已完成");
  /// ```
  static void showToast(String message) {
    EasyLoading.showToast(message);
  }

  /// 显示全局操作成功提示
  ///
  /// [message] 成功内容
  ///
  /// ## 用法示例
  /// ```dart
  /// PPAlert.showSuccess("保存成功！");
  /// ```
  static void showSuccess(String message) {
    EasyLoading.showSuccess(message);
  }

  /// 显示全局错误提示
  ///
  /// [message] 错误内容
  ///
  /// ## 用法示例
  /// ```dart
  /// PPAlert.showError("数据提交失败");
  /// ```
  static void showError(String message) {
    EasyLoading.showError(message);
  }

  /// 显示全局信息提示
  ///
  /// [message] 信息内容
  ///
  /// ## 用法示例
  /// ```dart
  /// PPAlert.showInfo("记录已同步");
  /// ```
  static void showInfo(String message) {
    EasyLoading.showInfo(message);
  }

  /// 显示全局警告提示
  ///
  /// [message] 警告内容
  ///
  /// ## 用法示例
  /// ```dart
  /// PPAlert.showWarning("请完善信息！");
  /// ```
  static void showWarning(String message) {
    EasyLoading.showToast(
      message,
      toastPosition: EasyLoadingToastPosition.center,
    );
  }

  /// 显示带进度的弹窗
  ///
  /// [progress] 进度 （0.0 - 1.0）
  /// [status]   状态文字
  ///
  /// ## 用法示例
  /// ```dart
  /// PPAlert.showProgress(0.7, status: "正在上传...");
  /// ```
  static void showProgress(double progress, {String? status}) {
    EasyLoading.showProgress(progress, status: status);
  }

  /// SnackBar 配置项
  static SnackBarConfig snackBarConfig = SnackBarConfig();

  /// 显示自定义SnackBar
  ///
  /// [title]       SnackBar 标题
  /// [message]     SnackBar 内容
  /// [okLabelText] OK 按钮文本（可选，实际不显示按钮，仅onOK回调）
  /// [onOK]        SnackBar 被点击时回调
  ///
  /// ## 用法示例
  /// ```dart
  /// PPAlert.showSnackBar(
  ///   title: "提示",
  ///   message: "删除成功",
  ///   onOK: () { print("用户点击了SnackBar"); },
  /// );
  /// ```
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
      // 如果需要弹出时有模态全屏背景色，可以设置overlayBlur和overlayColor
      // overlayBlur: 1, // 遮罩模糊度
      // overlayColor: Colors.black.withOpacity(.5), // 遮罩颜色,
      // 边框
      borderRadius: snackBarConfig.borderRadius,

      // 间距/位置
      maxWidth: snackBarConfig.maxWidth,
      margin: snackBarConfig.margin,
      padding: snackBarConfig.padding,
      snackPosition: snackBarConfig.snackPosition,

      // 动画
      forwardAnimationCurve: Curves.linearToEaseOut,
      reverseAnimationCurve: Curves.linearToEaseOut,
      animationDuration: Duration(milliseconds: 500),

      // 其他
      duration: Duration(seconds: 3),
      isDismissible: true,
      onTap: (snack) {
        if (onOK != null) {
          onOK();
        }
      },
    );
  }

  /// 显示系统原生确认弹窗（AlertDialog）
  ///
  /// [title]       标题
  /// [message]     内容
  /// [okLabelText] OK 按钮文本
  /// [onOK]        “OK”点击后的回调
  ///
  /// 不允许同一时刻弹出多个AlertDialog
  ///
  /// ## 用法示例
  /// ```dart
  /// PPAlert.showSysAlert(
  ///   title: "系统提示",
  ///   message: "操作已完成",
  ///   onOK: () { print("点击了OK"); },
  /// );
  /// ```
  static Future<void> showSysAlert({
    String title = 'Tips',
    String message = 'Messages',
    String okLabelText = 'OK',
    Function? onOK,
  }) async {
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
    isAlerted = false;
    if (result == OkCancelResult.ok) {
      if (onOK != null) {
        onOK();
      }
    }
  }

  /// 显示系统原生确认对话框
  ///
  /// [title]           标题
  /// [message]         内容
  /// [cancelLabelText] 取消按钮文本
  /// [okLabelText]     OK按钮文本
  /// [onCancel]        取消回调
  /// [onConfirm]       确认回调（必填）
  ///
  /// ## 用法示例
  /// ```dart
  /// PPAlert.showSysConfirm(
  ///   title: "确定要删除？",
  ///   onConfirm: () { print("删除！"); },
  ///   onCancel: () { print("取消！"); },
  /// );
  /// ```
  static Future<void> showSysConfirm({
    String title = 'Confirm',
    String message = 'Do you want to do it?',
    String cancelLabelText = 'Cancel',
    String okLabelText = 'OK',
    Function? onCancel,
    required Function onConfirm,
  }) async {
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
    isAlerted = false;
    if (result == OkCancelResult.ok) {
      onConfirm();
    } else if (result == OkCancelResult.cancel) {
      if (onCancel != null) {
        onCancel();
      }
    }
  }

  /// 显示单个文本输入框弹窗
  ///
  /// [title]           标题
  /// [message]         内容
  /// [initialText]     输入框初始值
  /// [hintText]        提示文字
  /// [cancelLabelText] 取消按钮文本
  /// [okLabelText]     确认按钮文本
  ///
  /// ## 返回结果
  /// 返回用户输入的字符串，若取消返回空字符串
  ///
  /// ## 用法示例
  /// ```dart
  /// final text = await PPAlert.showSingleTextInput(
  ///   title: "反馈",
  ///   hintText: "请输入内容",
  /// );
  /// ```
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
        DialogTextField(initialText: initialText, hintText: hintText),
      ],
    );
    // 返回结果：用户输入的内容，或空字符串（取消/关闭时）
    return texts != null && texts.isNotEmpty ? texts[0] : '';
  }

  /// 显示双文本输入框弹窗
  ///
  /// [title]            标题
  /// [message]          内容
  /// [initialTexts]     两个输入框的初始值（可选）
  /// [hintTexts]        两个输入框的hint（可选）
  /// [cancelLabelText]  取消按钮文本
  /// [okLabelText]      确认按钮文本
  ///
  /// ## 返回结果
  /// 返回用户输入的字符串列表，两项（取消时 ['','']）
  ///
  /// ## 用法示例
  /// ```dart
  /// final results = await PPAlert.showDoubleTextInput(
  ///   title: "请输入账号和密码",
  ///   hintTexts: ["账号", "密码"],
  /// );
  /// ```
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
          hintText: hintTexts != null && hintTexts.isNotEmpty
              ? hintTexts[0]
              : '',
        ),
        DialogTextField(
          initialText: initialTexts != null && initialTexts.length > 1
              ? initialTexts[1]
              : '',
          hintText: hintTexts != null && hintTexts.length > 1
              ? hintTexts[1]
              : '',
        ),
      ],
    );
    // 返回结果：两项列表（如果取消，返回 ['','']）
    return texts ?? ['', ''];
  }
}

/// SnackBarConfig
///
/// 全局SnackBar样式及行为配置类
///
/// ## 用法示例
/// ```dart
/// PPAlert.snackBarConfig = SnackBarConfig(
///   backgroundColor: Colors.black87,
///   colorText: Colors.yellow,
///   borderRadius: 20,
///   maxWidth: 400,
///   margin: EdgeInsets.only(top: 30, left: 16, right: 16),
/// );
/// ```
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

  /// 位置（顶部、底部等）
  final SnackPosition snackPosition;

  /// 构造函数
  ///
  /// ## 参数说明
  /// - [backgroundGradient] 背景渐变色
  /// - [backgroundColor]    背景色，默认为Colors.black54
  /// - [colorText]          文字颜色，默认为白
  /// - [barBlur]            背景模糊度，默认7
  /// - [borderRadius]       圆角，默认15
  /// - [maxWidth]           最大宽度，默认600
  /// - [margin]             外边距，默认EdgeInsets.all(15)
  /// - [padding]            内边距，默认EdgeInsets.all(15)
  /// - [snackPosition]      弹窗位置，默认顶部
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
