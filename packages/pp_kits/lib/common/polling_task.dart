import 'dart:async';
import 'package:flutter/foundation.dart';

/// 轮询任务管理器 [PollingTask]
///
/// ## 说明
/// 统一管理应用中的多个定时轮询型任务，适用于定时刷新、定期检查等场景。
/// 提供任务的启动、停止、全部停止、运行状态检查及任务ID获取的统一入口。
///
/// ## 单例用法
/// ```dart
/// final polling = PollingTask();
/// // 或直接 PollingTask().start(...)
/// ```
///
/// ## 常用方法
/// - [start] 启动新的轮询任务
/// - [stop] 停止指定ID的任务
/// - [stopAll] 停止所有任务
/// - [isRunning] 检查任务是否运行中
/// - [runningIds] 获取所有正在运行的任务ID列表
class PollingTask {
  /// 内部单例实现，推荐用 PollingTask() 获取全局唯一实例
  static final PollingTask _instance = PollingTask._internal();

  /// 工厂方法，确保全局唯一实例
  factory PollingTask() => _instance;

  /// 私有构造，禁止外部多实例化
  PollingTask._internal();

  /// 保存所有活跃任务的map，key为任务id
  final Map<String, Timer> _tasks = {};

  /// 启动一个新的轮询任务
  ///
  /// ### 参数：
  /// - [id] 任务唯一ID，字符串
  /// - [interval] 间隔时间，[Duration]
  /// - [onTick] 到达轮询时刻时执行的回调，[VoidCallback]
  /// - [restartIfExists] 如果ID已存在，是否重启任务（默认true，否则忽略新任务）
  ///
  /// ### 返回结果
  /// 无返回值。
  ///
  /// ### 用法示例
  /// ```dart
  /// // 启动一个5秒轮询任务
  /// PollingTask().start(
  ///   id: 'taskA',
  ///   interval: Duration(seconds: 5),
  ///   onTick: () {
  ///     print('A polling tick');
  ///   },
  /// );
  ///
  /// // 启动一个10秒轮询任务，且若已存在则不重启
  /// PollingTask().start(
  ///   id: 'taskB',
  ///   interval: Duration(seconds: 10),
  ///   onTick: () => print('B tick!'),
  ///   restartIfExists: false,
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

  /// 停止指定ID的轮询任务
  ///
  /// ### 参数
  /// - [id] 任务ID
  ///
  /// ### 返回结果
  /// 无返回值。
  ///
  /// ### 用法示例
  /// ```dart
  /// PollingTask().stop('taskA');
  /// ```
  void stop(String id) {
    _tasks[id]?.cancel();
    _tasks.remove(id);
  }

  /// 停止所有轮询任务
  ///
  /// ### 返回结果
  /// 无返回值。
  ///
  /// ### 用法示例
  /// ```dart
  /// PollingTask().stopAll();
  /// ```
  void stopAll() {
    for (var task in _tasks.values) {
      task.cancel();
    }
    _tasks.clear();
  }

  /// 检查指定ID的任务是否正在运行中
  ///
  /// ### 参数
  /// - [id] 任务ID
  ///
  /// ### 返回结果
  /// [bool]，true表示任务正在运行，false表示未运行
  ///
  /// ### 用法示例
  /// ```dart
  /// bool isActive = PollingTask().isRunning('taskA');
  /// ```
  bool isRunning(String id) {
    return _tasks.containsKey(id);
  }

  /// 获取所有当前正在运行任务的ID列表
  ///
  /// ### 返回结果
  /// [List<String>]，所有活跃任务的ID集合
  ///
  /// ### 用法示例
  /// ```dart
  /// print(PollingTask().runningIds); // 如: [taskA, taskB]
  /// ```
  List<String> get runningIds => _tasks.keys.toList();
}
