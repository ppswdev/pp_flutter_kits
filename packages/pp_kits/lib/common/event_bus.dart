import 'dart:async';

/// EventBus
///
/// ## 说明
/// 全局自定义事件总线，实现类似 iOS NotificationCenter 的事件分发机制，
/// 用于在应用内跨 Widget/模块之间发送和监听事件通知。
///
/// 适用于解耦各个模块间的事件通信需求。
///
/// ## 单例用法
/// 通过 `EventBus()` 获取单例对象。
///
/// ## 快速示例
/// ```dart
/// // 发送事件
/// EventBus().send(ThemeChangedEvent('follow system : darkTheme'));
///
/// // 订阅事件（一般在 initState）
/// late StreamSubscription sub;
/// sub = EventBus().on<ThemeChangedEvent>().listen((event) {
///   print('收到主题变更事件: ${event.theme}');
/// });
///
/// // 取消订阅（一般在 dispose）
/// sub.cancel();
/// ```
class EventBus {
  /// 单例实现，访问方式 EventBus()
  static final EventBus _instance = EventBus._internal();

  /// 工厂构造函数，返回同一个实例。
  factory EventBus() => _instance;

  /// 私有构造，禁止外部多实例化
  EventBus._internal();

  /// 存储每种事件类型对应的 StreamController
  final Map<Type, StreamController> _streamControllers = {};

  /// 获取或创建指定事件类型的 StreamController
  ///
  /// - 类型参数 [T] 为事件类型。
  ///
  /// 返回值: 对应类型的 [StreamController<T>]
  StreamController<T> _getStreamController<T>() {
    if (!_streamControllers.containsKey(T)) {
      _streamControllers[T] = StreamController<T>.broadcast();
    }
    return _streamControllers[T] as StreamController<T>;
  }

  /// 发送事件通知
  ///
  /// [event]：需要广播的事件对象（泛型，建议为自定义类）
  ///
  /// ## 用法示例
  /// ```dart
  /// EventBus().send(UserLoginEvent('userUID'));
  /// ```
  ///
  /// 返回值: 无
  void send<T>(T event) {
    _getStreamController<T>().add(event);
  }

  /// 订阅指定类型事件
  ///
  /// 类型参数 [T]：要监听的事件类型
  ///
  /// 返回值: [Stream<T>] 事件流，可调用 listen 订阅
  ///
  /// ## 用法示例
  /// ```dart
  /// late StreamSubscription sub;
  /// sub = EventBus().on<MyCustomEvent>().listen((event) {
  ///   print('监听到自定义事件: ${event.msg}');
  /// });
  /// ```
  /// 需在不再监听时主动调用 [cancel()] 取消订阅，避免内存泄漏。
  Stream<T> on<T>() {
    return _getStreamController<T>().stream;
  }

  /// 释放所有事件流（StreamController）
  ///
  /// 用于全局退出时资源回收（通常无需手动调用）
  ///
  /// 返回值: 无
  void dispose() {
    _streamControllers.forEach((_, controller) {
      controller.close();
    });
    _streamControllers.clear();
  }
}
