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
///
/// // 在页面的 onInit 中
/// @override
/// void onInit() {
///   super.onInit();
///   // 方式1：安全的调用（不传参数，内部会尝试自动获取 context）
///   KeyboardUtil.instance.init();
///   // 方式2：在 onReady 中调用更安全
///   // KeyboardUtil.instance.init(context);
/// }
/// // 或者在 build 中更新状态（最可靠）
/// @override
/// Widget build(BuildContext context) {
///   // 在 build 中更新，确保键盘状态准确
///   KeyboardUtil.instance.updateState(context);
///   return ...;
/// }
/// ```
class KeyboardUtil {
  static final KeyboardUtil _instance = KeyboardUtil._internal();
  static KeyboardUtil get instance => _instance;
  factory KeyboardUtil() => _instance;
  KeyboardUtil._internal();

  var isKeyboardVisible = false.obs;
  var keyboardHeight = 0.0.obs;

  // 标记是否已经初始化
  bool _isInitialized = false;
  // 保存监听器
  Worker? _keyboardListener;

  /// 带可选 context 参数的安全初始化
  void init([BuildContext? context]) {
    if (_isInitialized) {
      Logger.log('KeyboardUtil 已经初始化过，跳过重复初始化');
      return;
    }

    // 安全获取 context
    final safeContext = context ?? Get.context;
    if (safeContext == null) {
      Logger.log('警告: KeyboardUtil 无法获取 context，推迟初始化');
      // 尝试延迟初始化
      _delayInit();
      return;
    }

    _doInit(safeContext);
  }

  /// 延迟初始化
  void _delayInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final safeContext = Get.context;
      if (safeContext != null) {
        _doInit(safeContext);
      } else {
        Logger.log('错误: KeyboardUtil 仍然无法获取 context');
      }
    });
  }

  /// 真正的初始化逻辑
  void _doInit(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    keyboardHeight.value = mediaQuery.viewInsets.bottom;
    isKeyboardVisible.value = keyboardHeight.value > 0;

    // 只添加一次监听
    _keyboardListener?.dispose();
    _keyboardListener = ever(keyboardHeight, (height) {
      isKeyboardVisible.value = height > 0;
      if (isKeyboardVisible.value) {
        onKeyboardShow();
      } else {
        onKeyboardHide();
      }
    });

    _isInitialized = true;
    Logger.log('KeyboardUtil 初始化成功');
  }

  /// 更新键盘状态（在页面 build 时调用可确保状态准确）
  void updateState(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final newHeight = mediaQuery.viewInsets.bottom;
    // 只有当值变化时才更新，避免不必要的重建
    if (newHeight != keyboardHeight.value) {
      keyboardHeight.value = newHeight;
    }
  }

  void onKeyboardShow() {
    Logger.log('键盘显示，高度: ${keyboardHeight.value}');
  }

  void onKeyboardHide() {
    Logger.log('键盘隐藏');
  }

  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// 清理资源
  void dispose() {
    _keyboardListener?.dispose();
    _keyboardListener = null;
    _isInitialized = false;
  }
}
