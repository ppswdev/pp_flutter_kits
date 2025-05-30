import 'dart:async';

import 'package:flutter/foundation.dart';

/// 轮询任务管理器：用于统一管理多个定时任务
///
/// start 方法可以启动一个新的轮询任务，
///
/// stop 方法可以停止指定的任务，
///
/// stopAll 方法可以停止所有任务，
///
/// isRunning 方法可以检查指定任务是否正在运行，
///
/// runningIds 属性可以获取当前所有正在运行的任务 ID 列表。
class PollingTask {
  static final PollingTask _instance = PollingTask._internal();
  factory PollingTask() => _instance;
  PollingTask._internal();

  final Map<String, Timer> _tasks = {};

  /// 启动一个轮询任务
  ///
  /// 使用示例：
  ///
  /// ```dart
  /// PollingTask().start(
  ///   id: 'task1',
  ///  interval: Duration(seconds: 5),
  ///  onTick: () {
  ///    print('Task 1 is running');
  ///   },
  ///  restartIfExists: true, // 如果任务已存在，是否重启
  ///  );
  /// PollingTask().start(
  ///   id: 'task2',
  ///   interval: Duration(seconds: 10),
  ///   onTick: () {
  ///     print('Task 2 is running');
  ///   },
  ///   restartIfExists: false, // 如果任务已存在，不重启
  /// );
  /// ```
  void start({
    required String id,
    required Duration interval,
    required VoidCallback onTick,
    bool restartIfExists = true,
  }) {
    if (_tasks.containsKey(id)) {
      if (!restartIfExists) return;
      stop(id);
    }

    _tasks[id] = Timer.periodic(interval, (_) {
      onTick();
    });
  }

  /// 停止一个任务
  void stop(String id) {
    _tasks[id]?.cancel();
    _tasks.remove(id);
  }

  /// 停止全部任务
  void stopAll() {
    for (var task in _tasks.values) {
      task.cancel();
    }
    _tasks.clear();
  }

  /// 检查任务是否运行中
  bool isRunning(String id) {
    return _tasks.containsKey(id);
  }

  /// 获取所有当前任务 ID
  ///
  /// 使用示例：
  /// ```dart
  /// print(PollingTask().runningIds);
  /// ```
  List<String> get runningIds => _tasks.keys.toList();
}
