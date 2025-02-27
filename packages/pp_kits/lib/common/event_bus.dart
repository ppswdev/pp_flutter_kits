import 'dart:async';

/// 自定义事件总线
/// 相当于iOS的NotificationCenter，用于发送事件通知和监听事件通知
class EventBus {
  /// 单例模式
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  /// 存储不同事件类型的 StreamController
  final Map<Type, StreamController> _streamControllers = {};

  /// 获取或创建指定事件类型的 StreamController
  StreamController<T> _getStreamController<T>() {
    if (!_streamControllers.containsKey(T)) {
      _streamControllers[T] = StreamController<T>.broadcast();
    }
    return _streamControllers[T] as StreamController<T>;
  }

  /// 发送通知事件
  ///
  /// [event] 事件对象, events.dart中的事件
  void send<T>(T event) {
    _getStreamController<T>().add(event);
  }

  /// 订阅事件
  ///
  /// [event] 事件对象, events.dart中的事件
  Stream<T> on<T>() {
    return _getStreamController<T>().stream;
  }

  /// 关闭所有 StreamController
  void dispose() {
    _streamControllers.forEach((key, controller) {
      controller.close();
    });
    _streamControllers.clear();
  }
}
