import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 提示框工具类
/// 提供一些常用的提示框操作方法
class PPAlert {
  /// 是否显示加载中
  static var isLoading = false;

  /// 是否显示提示框
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

  /// 显示系统提示框
  static void showSysAlert(
      {String title = '提示',
      String text = '提示内容',
      String okButtonText = '确定',
      Function? onOK}) async {
    if (isAlerted) {
      return;
    }
    isAlerted = true;
    await showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            title,
            style: TextStyle(fontSize: 20.w),
          ),
          content: Text(
            text,
            style: TextStyle(fontSize: 15.w),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                isAlerted = false;
                if (onOK != null) {
                  onOK();
                }
              },
              child: Text(okButtonText, style: TextStyle(fontSize: 18.w)),
            ),
          ],
        );
      },
    );
  }

  /// 显示系统确认框
  static void showSysConfirm(
      {String title = '确认',
      String text = '你确定要继续吗？',
      String cancelButtonText = '取消',
      String okButtonText = '确定',
      Function? onCancel,
      required Function onConfirm}) async {
    if (isAlerted) {
      return;
    }
    isAlerted = true;
    await showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: 20),
          ),
          content: Text(
            text,
            style: const TextStyle(fontSize: 15),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                isAlerted = false;
                Navigator.of(context).pop();
                if (onCancel != null) {
                  onCancel();
                }
              },
              child: Text(
                cancelButtonText,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () {
                isAlerted = false;
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text(
                okButtonText,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }
}
