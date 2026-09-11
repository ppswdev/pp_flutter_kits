import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pp_kits/commons/event_bus.dart';
import 'package:pp_kits/commons/logger.dart';

import '../commons/events.dart';

/// 连接的网络类型：移动网络、Wi-Fi、以太网、VPN、蓝牙或无网络。
enum NetworkType { mobile, wifi, ethernet, vpn, bluetooth, none }

/// 网络健康状态：可用、较慢或不可用。
enum NetworkStatus { available, slow, unavailable }

/// 网络健康状态改变事件。
class NetworkHealthStatusEvent {
  final NetworkStatus status;

  NetworkHealthStatusEvent(this.status);
}

/// 网络连接状态控制器。
///
/// 提供当前网络类型、连接状态和可选的网络健康检查；不包含公网 IP 或
/// 地理位置查询功能。
class NetworkUtil extends GetxController {
  /// 当前网络类型。
  final netType = NetworkType.none.obs;

  /// 当前是否存在网络连接。
  final isConnected = false.obs;

  /// 当前网络健康状态。
  final status = NetworkStatus.unavailable.obs;

  final _testUrls = <String>[
    'https://www.apple.com/library/test/success.html',
    'https://www.cloudflare.com/cdn-cgi/trace',
    'https://www.amazon.com/robots.txt',
    'https://github.com/robots.txt',
    'https://www.aliyun.com/robots.txt',
    'https://cloud.tencent.com/robots.txt',
    'https://www.baidu.com/robots.txt',
    'https://www.huaweicloud.com/robots.txt',
    'https://www.oracle.com/robots.txt',
    'https://www.tiktok.com/robots.txt',
  ];

  /// 参与网络健康检查的额外地址。
  final List<String> extraUrls = [];

  /// 是否启用网络健康检查。
  bool enableHealthCheck = false;

  /// 连接变化后执行健康检查前的防抖时间（秒）。
  int healthCheckDebounceSeconds = 2;

  /// 定时健康检查的间隔（分钟）。
  int checkMinutesInterval = 8;

  /// 最近一次健康检查中最快节点的响应时间（毫秒）。
  int fastResponseTime = 0;

  Timer? _healthCheckTimer;
  Timer? _healthCheckDebounceTimer;
  late final Connectivity _connectivity;
  late final StreamSubscription<List<ConnectivityResult>>
  _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _connectivity = Connectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateNetworkStatus,
    );
    checkConnectivity();
    Logger.log('网络初始化完成，开启监听中...');
  }

  @override
  void onClose() {
    Logger.trace('NetworkUtil 资源释放');
    _connectivitySubscription.cancel();
    _healthCheckTimer?.cancel();
    _healthCheckDebounceTimer?.cancel();
    super.onClose();
  }

  void _updateNetworkStatus(List<ConnectivityResult> results) {
    final type = _networkTypeFrom(results);
    final connected = type != NetworkType.none;
    final wasConnected = isConnected.value;

    netType.value = type;
    isConnected.value = connected;

    if (!connected) {
      Logger.trace('网络已断开');
      EventBus().send(NetworkConnectStatusEvent(false, '网络已断开'));
      _healthCheckDebounceTimer?.cancel();
      if (status.value != NetworkStatus.unavailable) {
        status.value = NetworkStatus.unavailable;
        EventBus().send(NetworkHealthStatusEvent(status.value));
      }
      return;
    }

    Logger.trace('网络已连接: $type');
    if (!wasConnected) {
      EventBus().send(NetworkConnectStatusEvent(true, '网络已连接'));
    }
    if (enableHealthCheck) {
      _scheduleHealthCheck();
    }
  }

  NetworkType _networkTypeFrom(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.mobile)) {
      return NetworkType.mobile;
    }
    if (results.contains(ConnectivityResult.wifi)) {
      return NetworkType.wifi;
    }
    if (results.contains(ConnectivityResult.ethernet)) {
      return NetworkType.ethernet;
    }
    if (results.contains(ConnectivityResult.vpn)) {
      return NetworkType.vpn;
    }
    if (results.contains(ConnectivityResult.bluetooth)) {
      return NetworkType.bluetooth;
    }
    return NetworkType.none;
  }

  void _scheduleHealthCheck() {
    _healthCheckDebounceTimer?.cancel();
    _healthCheckDebounceTimer = Timer(
      Duration(seconds: healthCheckDebounceSeconds),
      _runHealthCheck,
    );
  }

  /// 获取并更新当前网络连接状态。
  Future<void> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateNetworkStatus(results);
  }

  /// 设置网络健康检查开关。
  void setHealthCheckEnabled(bool enabled) {
    enableHealthCheck = enabled;
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    _healthCheckDebounceTimer?.cancel();
    _healthCheckDebounceTimer = null;

    if (!enabled) {
      return;
    }

    _healthCheckTimer = Timer.periodic(
      Duration(minutes: checkMinutesInterval),
      (_) => _runHealthCheck(),
    );
    if (isConnected.value) {
      _scheduleHealthCheck();
    }
  }

  /// 设置连接变化后健康检查的防抖时间（秒）。
  void setHealthCheckDebounceSeconds(int seconds) {
    healthCheckDebounceSeconds = seconds;
  }

  Future<void> _runHealthCheck() async {
    final previousStatus = status.value;
    final currentStatus = await checkNetworkHealth();
    if (previousStatus != currentStatus) {
      status.value = currentStatus;
      EventBus().send(NetworkHealthStatusEvent(currentStatus));
    }
  }

  /// 检查网络是否可访问，并以最快成功请求的响应时间判定健康状态。
  ///
  /// [slowThresholdMs] 为判定网络较慢的阈值；[timeoutMs] 为单个请求超时。
  Future<NetworkStatus> checkNetworkHealth({
    int slowThresholdMs = 3000,
    int timeoutMs = 10000,
  }) async {
    final urls = [..._testUrls, ...extraUrls];
    if (urls.isEmpty) return NetworkStatus.unavailable;

    final responseTimes = <int>[];
    final client = Dio();
    final requests = urls.map((url) async {
      final stopwatch = Stopwatch()..start();
      try {
        final response = await client.get(
          url,
          options: Options(
            receiveTimeout: Duration(milliseconds: timeoutMs),
            sendTimeout: Duration(milliseconds: timeoutMs),
          ),
        );
        if (response.statusCode == 200) {
          responseTimes.add(stopwatch.elapsedMilliseconds);
        }
      } catch (error) {
        Logger.log('网络健康检测失败: $url, 错误: $error');
      } finally {
        stopwatch.stop();
      }
    });

    await Future.wait(requests);
    if (responseTimes.isEmpty) return NetworkStatus.unavailable;

    fastResponseTime = responseTimes.reduce(min);
    return fastResponseTime <= slowThresholdMs
        ? NetworkStatus.available
        : NetworkStatus.slow;
  }
}
