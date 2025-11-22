/// Logger 日志工具类
///
/// ## 说明
/// 提供统一日志输出接口，支持开发调试环境日志打印，避免 release 环境输出敏感日志。
///
/// ## 快速示例
/// ```dart
/// Logger.log('普通日志');
/// Logger.trace('带调用堆栈信息的日志');
/// ```

class Logger {
  /// 普通日志输出，仅在debug/dev模式下生效，release版自动忽略。
  ///
  /// 参数:
  /// - [message] 要输出的日志内容。
  ///
  /// 返回结果: 无。
  ///
  /// ## 示例
  /// ```dart
  /// Logger.log('启动应用');
  /// ```
  static void log(String message) {
    if (const bool.fromEnvironment('dart.vm.product')) {
      // 当应用编译为 release 版本时，dart.vm.product 通常被设置为 true
      return;
    }
    print(message);
  }

  /// 高级跟踪日志，输出日志同时包含调用位置（文件名、行号和方法名）。
  /// 仅在debug/dev模式下生效，release版自动忽略。
  ///
  /// 参数:
  /// - [message] 要输出的日志内容。
  ///
  /// 返回结果: 无。
  ///
  /// ## 示例
  /// ```dart
  /// Logger.trace('进入某方法');
  /// ```
  static void trace(String message) {
    if (const bool.fromEnvironment('dart.vm.product')) {
      // 当应用编译为 release 版本时，dart.vm.product 通常被设置为 true
      return;
    }
    String formattedDate = DateTime.now().toString();

    var currentStack = StackTrace.current;
    var formattedStack =
        currentStack.toString().split("\n")[1].trim(); // 获取调用 log 方法的位置

    // 提取文件名、方法名和行号信息
    var match = RegExp(r'^#1\s+(.+)\s\((.+):(\d+):(\d+)\)$').firstMatch(formattedStack);
    var methodName = match?.group(1) ?? 'unknown method';
    var fileName = match?.group(2) ?? 'unknown file';
    var line = match?.group(3) ?? 'unknown line';

    print('$formattedDate [$fileName:$line $methodName] $message');
  }
}
