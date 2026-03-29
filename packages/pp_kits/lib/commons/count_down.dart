import 'dart:async';

/// 倒计时显示格式
enum CountDownFormat {
  /// HH:mm:ss 格式（如 "01:05:30"）
  hhmmss,

  /// mm:ss 格式（如 "05:30"）
  mmss,

  /// ss 格式（如 "30"）
  ss,
}

/// 倒计时实例
class CountDownInstance {
  /// 倒计时ID
  final String id;

  /// 最大时间（秒）
  final int maxSeconds;

  /// 显示格式
  final CountDownFormat format;

  /// 更新回调函数，参数为格式化后的时间字符串
  final void Function(String timeStr) onUpdate;

  /// 完成回调函数
  final void Function()? onComplete;

  /// 当前剩余时间（秒）
  int _remainingSeconds = 0;

  /// 定时器
  Timer? _timer;

  /// 是否正在运行
  bool get isRunning => _timer != null && _timer!.isActive;

  /// 获取剩余时间（秒）
  int get remainingSeconds => _remainingSeconds;

  CountDownInstance({
    required this.id,
    required this.maxSeconds,
    required this.format,
    required this.onUpdate,
    this.onComplete,
  }) {
    _remainingSeconds = maxSeconds;
  }

  /// 启动倒计时
  void start() {
    // 先取消旧的定时器，确保唯一性
    _timer?.cancel();

    // 重置剩余时间
    _remainingSeconds = maxSeconds;
    _updateDisplay();

    // 启动定时器，每秒减1
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _updateDisplay();
      } else {
        // 倒计时结束
        _timer?.cancel();
        _timer = null;
        onComplete?.call();
      }
    });
  }

  /// 停止倒计时
  void stop() {
    _timer?.cancel();
    _timer = null;
    _remainingSeconds = 0;
    _updateDisplay();
  }

  /// 暂停倒计时
  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  /// 恢复倒计时
  void resume() {
    // 如果剩余时间为0，不恢复
    if (_remainingSeconds <= 0) {
      return;
    }

    // 先取消旧的定时器，确保唯一性
    _timer?.cancel();

    // 继续倒计时
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _updateDisplay();
      } else {
        // 倒计时结束
        _timer?.cancel();
        _timer = null;
        onComplete?.call();
      }
    });
  }

  /// 重置倒计时
  void reset({int? newMaxSeconds}) {
    stop();
    if (newMaxSeconds != null) {
      _remainingSeconds = newMaxSeconds;
    } else {
      _remainingSeconds = maxSeconds;
    }
    _updateDisplay();
  }

  /// 更新显示
  void _updateDisplay() {
    final timeStr = _formatTime(_remainingSeconds, format);
    onUpdate(timeStr);
  }

  /// 格式化时间
  String _formatTime(int seconds, CountDownFormat format) {
    switch (format) {
      case CountDownFormat.hhmmss:
        final hours = (seconds / 3600).floor();
        final minutes = ((seconds % 3600) / 60).floor();
        final secs = seconds % 60;
        return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

      case CountDownFormat.mmss:
        final minutes = (seconds / 60).floor();
        final secs = seconds % 60;
        return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

      case CountDownFormat.ss:
        return seconds.toString().padLeft(2, '0');
    }
  }

  /// 销毁实例
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// 倒计时管理器（单例）
///
/// 用于管理多个倒计时实例，支持同时运行多个倒计时，每个倒计时可以设置不同的时长和显示格式。
///
/// 使用示例：
///
/// ```dart
/// class GlobalCoundDown {
///   static final GlobalCoundDown _instance = GlobalCoundDown._internal();
///   static GlobalCoundDown get instance => _instance;
///   factory GlobalCoundDown() => _instance;
///   GlobalCoundDown._internal();
///
///   final countDownManager = CountDownManager();
///
///   var homeGiftCountDownId = 'homeGiftCountDown';
///   var homeGiftCountDownStr = '00:00'.obs;
///   var homeGiftCountDownMaxTime = 10 * 60;
///
///   void startHomeGiftCountDown() {
///     countDownManager.createCountDown(
///       id: homeGiftCountDownId,
///       maxSeconds: homeGiftCountDownMaxTime,
///       format: CountDownFormat.mmss,
///       onUpdate: (timeStr) {
///         homeGiftCountDownStr.value = timeStr;
///       },
///       onComplete: () {
///         homeGiftCountDownStr.value = '00:00';
///         countDownManager.disposeCountDown(homeGiftCountDownId);
///       },
///     );
///     countDownManager.startCountDown(homeGiftCountDownId);
///   }
/// }
/// ```
class CountDownManager {
  // 单例实例
  static final CountDownManager _instance = CountDownManager._internal();
  factory CountDownManager() => _instance;
  CountDownManager._internal();

  /// 倒计时实例映射表
  final Map<String, CountDownInstance> _instances = {};

  /// 创建倒计时实例
  ///
  /// [id] 倒计时唯一标识
  /// [maxSeconds] 最大时间（秒）
  /// [format] 显示格式
  /// [onUpdate] 更新回调函数
  /// [onComplete] 完成回调函数（可选）
  ///
  /// 返回倒计时实例ID
  String createCountDown({
    required String id,
    required int maxSeconds,
    required CountDownFormat format,
    required void Function(String timeStr) onUpdate,
    void Function()? onComplete,
  }) {
    // 如果已存在，先销毁旧的
    if (_instances.containsKey(id)) {
      _instances[id]?.dispose();
    }

    // 创建新实例
    final instance = CountDownInstance(
      id: id,
      maxSeconds: maxSeconds,
      format: format,
      onUpdate: onUpdate,
      onComplete: onComplete,
    );

    _instances[id] = instance;
    return id;
  }

  /// 启动倒计时
  void startCountDown(String id) {
    _instances[id]?.start();
  }

  /// 停止倒计时
  void stopCountDown(String id) {
    _instances[id]?.stop();
  }

  /// 暂停倒计时
  void pauseCountDown(String id) {
    _instances[id]?.pause();
  }

  /// 恢复倒计时
  void resumeCountDown(String id) {
    _instances[id]?.resume();
  }

  /// 重置倒计时
  void resetCountDown(String id, {int? newMaxSeconds}) {
    _instances[id]?.reset(newMaxSeconds: newMaxSeconds);
  }

  /// 获取倒计时实例
  CountDownInstance? getCountDown(String id) {
    return _instances[id];
  }

  /// 获取剩余时间（秒）
  int? getRemainingSeconds(String id) {
    return _instances[id]?.remainingSeconds;
  }

  /// 检查倒计时是否正在运行
  bool isCountDownRunning(String id) {
    return _instances[id]?.isRunning ?? false;
  }

  /// 销毁倒计时实例
  void disposeCountDown(String id) {
    _instances[id]?.dispose();
    _instances.remove(id);
  }

  /// 销毁所有倒计时实例
  void disposeAll() {
    for (final instance in _instances.values) {
      instance.dispose();
    }
    _instances.clear();
  }
}
