import 'dart:math';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pp_kits/common/event_bus.dart';
import 'dart:async';

import 'package:pp_kits/common/logger.dart';
import 'package:pp_kits/extensions/extension_on_string.dart';

/// 连接的网络类型: 手机移动网络，WIFI网络、以太网、VPN网络、蓝牙网络、无网络
enum NetworkType { mobile, wifi, ethernet, vpn, bluetooth, none }

/// 网络健康状态: 网络可用且速度正常，网络可用但较慢，网络不可用
enum NetworkStatus { available, slow, unavailable }

/// 网络状态改变事件
class NetworkChangedEvent {
  final NetworkStatus status;

  NetworkChangedEvent(this.status);
}

/// 网络控制器
///
/// 获取网络状态，网络信息等
class NetworkController extends GetxController {
  /// 网络类型
  var netType = NetworkType.none.obs;

  /// 网络是否已连接
  var isConnected = false.obs;

  /// 网络健康状态
  var status = NetworkStatus.unavailable.obs;

  /// 公网IP
  var publicIP = '';

  final _testUrls = [
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

  /// IP监听器
  Timer? _ipCheckTimer;

  /// 防抖（debounce）机制，防止频繁检测,用Timer
  Timer? _healthCheckDebounceTimer;
  late final Connectivity _connectivity;
  late final StreamSubscription<List<ConnectivityResult>>
  _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _connectivity = Connectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      Logger.trace('onConnectivityChanged');
      _updateNetworkStatus(results);
    });
    Logger.log('网络初始化完成, 开启监听中...');

    // 启动定时器获取公网IP
    _ipCheckTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      getPublicIp();
    });
  }

  @override
  void onClose() {
    Logger.trace('NetworkController资源释放');
    _connectivitySubscription.cancel();
    _ipCheckTimer?.cancel();
    _ipCheckTimer = null;
    super.onClose();
  }

  void _updateNetworkStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.mobile)) {
      netType.value = NetworkType.mobile;
      Logger.trace('连接的移动网络');
    } else if (results.contains(ConnectivityResult.wifi)) {
      netType.value = NetworkType.wifi;
      Logger.trace('连接的Wifi网络');
    } else if (results.contains(ConnectivityResult.ethernet)) {
      netType.value = NetworkType.ethernet;
      Logger.trace('连接的以太网');
    } else if (results.contains(ConnectivityResult.vpn)) {
      netType.value = NetworkType.vpn;
      Logger.trace('连接的VPN网络');
    } else if (results.contains(ConnectivityResult.bluetooth)) {
      netType.value = NetworkType.bluetooth;
      Logger.trace('连接的蓝牙网络');
    } else if (results.contains(ConnectivityResult.other)) {
      netType.value = NetworkType.none;
    } else if (results.contains(ConnectivityResult.none)) {
      netType.value = NetworkType.none;
    }
    if (netType.value == NetworkType.none) {
      Logger.trace('网络已断开');
      isConnected.value = false;
      // 网络断开时，直接设置为不可用
      if (status.value != NetworkStatus.unavailable) {
        status.value = NetworkStatus.unavailable;
        EventBus().send(NetworkChangedEvent(status.value));
      }
    } else {
      Logger.trace('网络已连接: ${netType.value}');
      isConnected.value = true;

      // 防抖处理，避免频繁检测
      _healthCheckDebounceTimer?.cancel();
      _healthCheckDebounceTimer = Timer(const Duration(seconds: 2), () async {
        final oldStatus = status.value;
        final newStatus = await checkNetworkHealth();
        Logger.log('网络状态改变: $oldStatus -> $newStatus');
        if (oldStatus != newStatus) {
          status.value = newStatus;
          EventBus().send(NetworkChangedEvent(status.value));
        }
      });
    }
  }

  /// 检查网络连接状态
  void checkConnectivity() async {
    final List<ConnectivityResult> results = await (_connectivity
        .checkConnectivity());
    _updateNetworkStatus(results);
  }

  /// 检查网络健康状况
  /// 慢阈值: 1500ms
  /// 超时时间: 3000ms
  ///
  /// 返回值:
  /// - available: 网络可用且速度正常
  /// - slow: 网络可用但较慢
  /// - unavailable: 网络不可用
  ///
  /// 使用示例：
  /// ```dart
  /// final status = await networkController.checkNetworkHealth();
  /// switch (status) {
  ///   case NetworkHealthStatus.available:
  ///     // 网络畅通
  ///     break;
  ///   case NetworkHealthStatus.slow:
  ///     // 网络慢，提示用户
  ///     break;
  ///   case NetworkHealthStatus.unavailable:
  ///     // 网络不可用，提示用户
  ///     break;
  /// }
  /// //或者
  /// networkController.checkNetworkHealth().then((status) {
  ///   if (status == NetworkHealthStatus.unavailable) {
  ///     // 弹窗提示
  ///   }
  /// });
  ///
  /// //界面示例：
  /// FutureBuilder<NetworkHealthStatus>(
  ///   future: networkController.checkNetworkHealth(),
  ///   builder: (context, snapshot) {
  ///     if (!snapshot.hasData) {
  ///       return CircularProgressIndicator();
  ///     }
  ///     switch (snapshot.data) {
  ///       case NetworkHealthStatus.available:
  ///         return Text('网络畅通');
  ///       case NetworkHealthStatus.slow:
  ///         return Text('网络较慢');
  ///       case NetworkHealthStatus.unavailable:
  ///         return Text('网络不可用');
  ///       default:
  ///         return Text('未知状态');
  ///     }
  ///   },
  /// )
  /// ```
  Future<NetworkStatus> checkNetworkHealth({
    int slowThresholdMs = 3000,
    int timeoutMs = 10000,
  }) async {
    final completer = Completer<NetworkStatus>();
    bool hasSuccess = false;

    // 记录每个节点的响应时间
    final Map<String, int> responseTimes = {};

    // 为每个URL创建单独的CancelToken
    final cancelTokens = _testUrls.map((_) => CancelToken()).toList();

    for (var i = 0; i < _testUrls.length; i++) {
      final url = _testUrls[i];
      final cancelToken = cancelTokens[i];

      Logger.log('网络健康检测: 开始请求 $url');
      final stopwatch = Stopwatch()..start();

      Dio()
          .get(
            url,
            options: Options(
              receiveTimeout: Duration(milliseconds: timeoutMs),
              sendTimeout: Duration(milliseconds: timeoutMs),
            ),
            cancelToken: cancelToken,
          )
          .then((response) {
            stopwatch.stop();
            final responseTime = stopwatch.elapsedMilliseconds;
            responseTimes[url] = responseTime;

            Logger.log(
              '网络健康检测: $url 响应 statusCode=${response.statusCode}, 耗时=${responseTime}ms',
            );

            if (response.statusCode == 200) {
              hasSuccess = true;
            }
          })
          .catchError((e) {
            stopwatch.stop();
            final responseTime = stopwatch.elapsedMilliseconds;
            responseTimes[url] = responseTime;

            Logger.log('网络健康检测: $url 请求失败/超时，耗时=${responseTime}ms，错误: $e');
          });
    }

    // 超时后判断最终状态
    Future.delayed(Duration(milliseconds: timeoutMs + 500), () {
      // 取消所有未完成的请求
      for (var token in cancelTokens) {
        if (!token.isCancelled) {
          token.cancel('检测超时，取消剩余请求');
        }
      }

      // 打印所有节点的响应时间
      Logger.log('网络健康检测: 所有节点响应时间统计 >>>');
      responseTimes.forEach((url, time) {
        Logger.log('节点: $url, 耗时: ${time}ms');
      });
      Logger.log('网络健康检测: 统计结束 <<<');

      if (!completer.isCompleted) {
        if (hasSuccess) {
          // 获取最快的响应时间
          final fastestTime = responseTimes.values.reduce(min);
          if (fastestTime <= slowThresholdMs) {
            Logger.log('网络健康检测: 最快节点响应时间 ${fastestTime}ms，判定为 available');
            completer.complete(NetworkStatus.available);
          } else {
            Logger.log('网络健康检测: 最快节点响应时间 ${fastestTime}ms，判定为 slow');
            completer.complete(NetworkStatus.slow);
          }
        } else {
          Logger.log('网络健康检测: 所有节点都失败，判定为 unavailable');
          completer.complete(NetworkStatus.unavailable);
        }
      }
    });

    return completer.future;
  }

  /// 获取公网IP
  Future<String> getPublicIp() async {
    if (publicIP.isValidIP()) {
      Logger.log('网络: 已获取公网IP，跳过获取');
      return publicIP;
    }

    Logger.log('网络: 开始获取公网IP......');
    final apiEndpoints = [
      'https://api.ipify.org',
      'https://ifconfig.me/ip',
      'https://icanhazip.com',
      'https://checkip.amazonaws.com',
    ];

    // 创建CancelToken用于取消其他请求
    final cancelToken = CancelToken();

    try {
      // 并行发起所有请求
      final requests = apiEndpoints.map((endpoint) async {
        Logger.log('网络: 获取IP源> $endpoint');
        try {
          final response = await Dio().get(endpoint, cancelToken: cancelToken);
          if (response.statusCode == 200) {
            final ip = response.data.toString().trim();
            if (ip.isValidIP()) {
              return ip;
            }
          }
        } catch (e) {
          Logger.log('获取公网IP失败 $endpoint: $e');
        }
        return null;
      }).toList();

      // 等待第一个成功的请求
      final results = await Future.any(requests);

      if (results != null) {
        // 取消其他请求
        cancelToken.cancel('已获取到IP');

        publicIP = results;
        _ipCheckTimer?.cancel();
        _ipCheckTimer = null;

        Logger.log('网络: 成功获取公网IP: $publicIP');
      }
    } catch (e) {
      Logger.log('获取公网IP失败: $e');
    }

    Logger.log('网络: 当前公共IP>$publicIP');
    return publicIP;
  }
}

/*
Obx(() {
  switch (networkController.status.value) {
    case NetworkStatus.mobile:
      return Text("Mobile network available");
    case NetworkStatus.wifi:
      return Text("Wi-Fi is available");
    case NetworkStatus.ethernet:
      return Text("Ethernet connection available");
    case NetworkStatus.vpn:
      return Text("VPN connection active");
    case NetworkStatus.bluetooth:
      return Text("Bluetooth connection available");
    case NetworkStatus.none:
      return Text("No network or unknown network type");
    default:
      return Text("Checking network status...");
  }
});
*/
