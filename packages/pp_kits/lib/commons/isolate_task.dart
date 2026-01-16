import 'dart:async';
import 'dart:isolate';

/// IsolateTask：Dart多线程（Isolate）管理工具类
///
/// ## 说明
/// 便捷地在Flutter/Dart项目中管理多个Isolate，实现耗时任务分发与生命周期管理。
///
/// ## 示例用法
/// ```dart
/// // 1. 定义isolate入口函数
/// void isolateFunction(List<dynamic> args) {
///   SendPort sendPort = args[0];
///   dynamic taskData = args[1];
///
///   // 执行耗时或计算密集型任务
///   var result = performComputation(taskData);
///
///   // 将结果发送回主isolate
///   sendPort.send(result);
/// }
///
/// // 2. 主isolate中使用IsolateTask管理
/// void main() async {
///   // 启动新isolate
///   await IsolateTask.spawn('worker1', isolateFunction, '任务参数');
///
///   // 检查isolate是否存在
///   if (IsolateTask.exists('worker1')) {
///     print('worker1 已启动');
///   }
///
///   // 结束指定isolate
///   IsolateTask.kill('worker1');
///
///   // 结束所有isolate
///   IsolateTask.killAll();
/// }
/// ```

class IsolateTask {
  /// 活跃Isolate实例的映射表（key为isolate名字）
  static final Map<String, Isolate> _isolates = {};

  /// 每个isolate对应的接收端端口映射
  static final Map<String, ReceivePort> _receivePorts = {};

  /// 创建并启动一个新的isolate线程
  ///
  /// [name] 该isolate的标识名，作为管理和查找用
  /// [entryPoint] isolate入口函数，格式`void Function(List<dynamic>)`
  /// [message] 可选，传递给isolate的初始消息（任意类型）
  ///
  /// 返回结果: [Future<void>] 表示异步处理完成
  ///
  /// 示例：
  /// ```dart
  /// await IsolateTask.spawn('calc', myEntryPoint, 123);
  /// ```
  static Future<void> spawn(
    String name,
    void Function(List<dynamic>) entryPoint, [
    dynamic message,
  ]) async {
    if (_isolates.containsKey(name)) {
      throw Exception('Isolate "$name" 已存在，请先kill后再spawn');
    }

    final receivePort = ReceivePort();
    _receivePorts[name] = receivePort;

    final isolate = await Isolate.spawn(
      entryPoint,
      [receivePort.sendPort, message],
    );

    _isolates[name] = isolate;

    // 可自定义监听逻辑，用于处理子isolate返回主isolate的数据
    receivePort.listen((msg) {
      // TODO: 可以在此处理isolate的返回消息，如EventBus发送/回调等
    });
  }

  /// 终止指定名称的isolate
  ///
  /// [name] 要结束的isolate标识名
  ///
  /// 返回结果: 无（若不存在则无操作）
  ///
  /// 示例：
  /// ```dart
  /// IsolateTask.kill('worker1');
  /// ```
  static void kill(String name) {
    final isolate = _isolates[name];
    if (isolate != null) {
      isolate.kill(priority: Isolate.immediate);
      _isolates.remove(name);

      final receivePort = _receivePorts[name];
      if (receivePort != null) {
        receivePort.close();
        _receivePorts.remove(name);
      }
    }
  }

  /// 终止所有活跃的isolate
  ///
  /// 返回结果: 无
  ///
  /// 示例：
  /// ```dart
  /// IsolateTask.killAll();
  /// ```
  static void killAll() {
    // 必须用toList避免在遍历时修改map
    for (final name in _isolates.keys.toList()) {
      kill(name);
    }
  }

  /// 检查指定名称的isolate是否存在
  ///
  /// [name] 要检测的isolate标识名
  ///
  /// 返回结果: [bool] 是否已存在（true表示已启动）
  ///
  /// 示例：
  /// ```dart
  /// bool exists = IsolateTask.exists('workerA');
  /// ```
  static bool exists(String name) {
    return _isolates.containsKey(name);
  }

  /// 当前活跃isolate的数量
  ///
  /// 返回结果: [int] 活跃isolate数量
  ///
  /// 示例：
  /// ```dart
  /// int count = IsolateTask.activeCount;
  /// ```
  static int get activeCount => _isolates.length;
}
