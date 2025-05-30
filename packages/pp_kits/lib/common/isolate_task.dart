import 'dart:async';
import 'dart:isolate';

/// Isolate线程管理工具类
///
/// 使用示例:
/// ```dart
/// // 1. 定义isolate入口函数
/// void isolateFunction(List<dynamic> args) {
///   SendPort sendPort = args[0];
///   dynamic message = args[1];
///
///   // 在这里处理耗时任务
///   var result = heavyComputation(message);
///
///   // 发送结果回主isolate
///   sendPort.send(result);
/// }
///
/// // 2. 在主isolate中使用
/// void main() async {
///   // 启动新的isolate
///   await IsolateManager.spawn('worker', isolateFunction, data);
///
///   // 检查isolate是否存在
///   if(IsolateManager.exists('worker')) {
///     print('Worker isolate is running');
///   }
///
///   // 完成后终止isolate
///   IsolateManager.kill('worker');
///
///   // 或终止所有isolate
///   IsolateManager.killAll();
/// }
/// ```
class IsolateTask {
  /// 存储活跃的isolate实例
  static final Map<String, Isolate> _isolates = {};

  /// 存储isolate的接收端口
  static final Map<String, ReceivePort> _receivePorts = {};

  /// 创建并启动一个新的isolate线程
  /// [name] - isolate名称标识
  /// [entryPoint] - isolate入口函数
  /// [message] - 传递给isolate的消息
  static Future<void> spawn(
      String name, void Function(List<dynamic>) entryPoint,
      [dynamic message]) async {
    if (_isolates.containsKey(name)) {
      throw Exception('Isolate $name already exists');
    }

    final receivePort = ReceivePort();
    _receivePorts[name] = receivePort;

    final isolate = await Isolate.spawn(
      entryPoint,
      [receivePort.sendPort, message],
    );

    _isolates[name] = isolate;

    // 监听接收端口
    receivePort.listen((message) {
      // 处理isolate返回的消息
    });
  }

  /// 终止指定名称的isolate
  static void kill(String name) {
    final isolate = _isolates[name];
    if (isolate != null) {
      isolate.kill();
      _isolates.remove(name);

      final receivePort = _receivePorts[name];
      if (receivePort != null) {
        receivePort.close();
        _receivePorts.remove(name);
      }
    }
  }

  /// 终止所有isolate
  static void killAll() {
    for (final name in _isolates.keys) {
      kill(name);
    }
  }

  /// 检查指定名称的isolate是否存在
  static bool exists(String name) {
    return _isolates.containsKey(name);
  }

  /// 获取活跃的isolate数量
  static int get activeCount => _isolates.length;
}
