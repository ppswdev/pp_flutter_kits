class Logger {
  static void log(String message) {
    if (const bool.fromEnvironment('dart.vm.product')) {
      //当应用编译为 release 版本时，dart.vm.product 通常被设置为 true
      return;
    }
    print(message);
  }

  static void trace(String message) {
    if (const bool.fromEnvironment('dart.vm.product')) {
      //当应用编译为 release 版本时，dart.vm.product 通常被设置为 true
      return;
    }
    String formattedDate = DateTime.now().toString();

    var currentStack = StackTrace.current;
    var formattedStack =
        currentStack.toString().split("\n")[1].trim(); // 获取调用 log 方法的位置

    // 提取文件名、方法名和行号
    var match =
        RegExp(r'^#1\s+(.+)\s\((.+):(\d+):(\d+)\)$').firstMatch(formattedStack);
    var methodName = match?.group(1) ?? 'unknown method';
    var fileName = match?.group(2) ?? 'unknown file';
    var line = match?.group(3) ?? 'unknown line';

    print('$formattedDate [$fileName:$line $methodName] $message');
  }
}
