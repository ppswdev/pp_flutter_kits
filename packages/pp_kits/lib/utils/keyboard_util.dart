import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../commons/logger.dart';

/// 键盘工具类
///
/// 使用示例：
///
/// ``` dart
///
/// class DemoController extends BaseController {
///   @override
///   void onInit() {
///     super.onInit();
///     // 初始化键盘管理器
///     KeyboardManager().init(Get.context!);
///     // 监听键盘状态
///     ever(KeyboardManager()._isKeyboardVisible, (isVisible) {
///       if (isVisible) {
///         // 键盘显示时的处理
///         handleKeyboardShow();
///       } else {
///         // 键盘隐藏时的处理
///         handleKeyboardHide();
///       }
///     });
///   }
///   void handleKeyboardShow() {
///     // 例如：调整UI布局
///     // 滚动到特定位置
///     // 显示或隐藏某些组件
///   }
///   void handleKeyboardHide() {
///     // 键盘隐藏时的处理逻辑
///   }
///   // 在需要时主动隐藏键盘
///   void hideKeyboard() {
///     KeyboardManager().hideKeyboard();
///   }
/// }
/// ```
class KeyboardUtil {
  static final KeyboardUtil _instance = KeyboardUtil._internal();
  static KeyboardUtil get instance => _instance;
  factory KeyboardUtil() => _instance;
  KeyboardUtil._internal();

  var isKeyboardVisible = false.obs;
  var keyboardHeight = 0.0.obs;

  void init() {
    // 监听键盘变化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mediaQuery = MediaQuery.of(Get.context!);
      keyboardHeight.value = mediaQuery.viewInsets.bottom;
      isKeyboardVisible.value = keyboardHeight.value > 0;

      // 添加全局监听
      ever(keyboardHeight, (height) {
        isKeyboardVisible.value = height > 0;
        if (isKeyboardVisible.value) {
          onKeyboardShow();
        } else {
          onKeyboardHide();
        }
      });
    });
  }

  void onKeyboardShow() {
    // 键盘显示时的处理
    Logger.log('键盘显示，高度: $keyboardHeight');
  }

  void onKeyboardHide() {
    // 键盘隐藏时的处理
    Logger.log('键盘隐藏');
  }

  // 主动隐藏键盘
  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
