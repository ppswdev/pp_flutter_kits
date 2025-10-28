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

/// 网络位置信息
class NetworkGeoInfo {
  String ip = '';
  String country = '';
  String countryCode = '';
  String region = '';
  String regionName = '';
  String city = '';
  double lat = 0.0;
  double lon = 0.0;
  String timezone = '';
}

/// 网络控制器
///
/// 获取网络状态，网络信息等
class NetworkUtil extends GetxController {
  /// 网络类型
  var netType = NetworkType.none.obs;

  /// 网络是否已连接
  var isConnected = false.obs;

  /// 网络健康状态
  var status = NetworkStatus.unavailable.obs;

  /// 公网IP
  var publicIP = '';

  NetworkGeoInfo? geoInfo;

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
    'https://www.tiktok.com/robots.txt'
  ];

  List<String> extraUrls = [];

  /// 是否启用网络健康检查
  bool enableHealthCheck = false;
  //防抖延迟时间（秒）
  int healthCheckDebounceSeconds = 2;
  Timer? _healthCheckTimer;
  bool _isGettingPublicIP = false;
  static const int maxRetryCount = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  //防抖（debounce）机制，防止频繁检测,用Timer
  Timer? _healthCheckDebounceTimer;
  //检查网络健康状态的间隔时间，单位：分钟
  int checkMinutesInterval = 8;
  //网络健康检测的最快响应时间，单位：毫秒
  int fastResponseTime = 0;

  late final Connectivity _connectivity;
  late final StreamSubscription<List<ConnectivityResult>>
      _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _connectivity = Connectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      Logger.trace('onConnectivityChanged');
      _updateNetworkStatus(results);
    });
    Logger.log('网络初始化完成, 开启监听中...');
  }

  @override
  void onClose() {
    Logger.trace('NetworkUtil资源释放');
    _connectivitySubscription.cancel();
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
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

      // 只有在启用健康检查时才进行防抖处理
      if (enableHealthCheck) {
        _healthCheckDebounceTimer?.cancel();
        _healthCheckDebounceTimer =
            Timer(Duration(seconds: healthCheckDebounceSeconds), () async {
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
  }

  /// 检查网络连接状态
  void checkConnectivity() async {
    final List<ConnectivityResult> results =
        await (_connectivity.checkConnectivity());
    _updateNetworkStatus(results);
  }

  /// 获取公网IP
  Future<String> loadIPAddress() async {
    // 如果正在执行，直接返回默认IP
    if (_isGettingPublicIP) {
      Logger.log('网络: 正在获取公网IP中，返回默认IP: 127.0.0.1');
      return '127.0.0.1';
    }

    // 如果已有有效IP，直接返回
    if (publicIP.isValidIP()) {
      Logger.log('网络: 已获取公网IP，跳过获取: $publicIP');
      return publicIP;
    }

    // 设置执行状态
    _isGettingPublicIP = true;

    try {
      Logger.log('网络: 开始获取公网IP......');

      final apiEndpoints = [
        'https://api.ipify.org',
        'https://ifconfig.me/ip',
        'https://icanhazip.com',
        'https://checkip.amazonaws.com',
        'https://ipapi.co/ip',
        'https://ipinfo.io/ip',
      ];

      int retryCount = 0;
      String? resultIP;

      // 重试循环
      while (retryCount < maxRetryCount && resultIP == null) {
        Logger.log('网络: 第 ${retryCount + 1} 次尝试获取公网IP');

        try {
          resultIP = await _attemptGetPublicIP(apiEndpoints);

          publicIP = resultIP ?? '127.0.0.1';
          Logger.log('网络: 成功获取公网IP: $publicIP');
          return publicIP;
        } catch (e) {
          Logger.log('网络: 第 ${retryCount + 1} 次获取公网IP失败: $e');
        }

        retryCount++;

        // 如果不是最后一次重试，等待后继续
        if (retryCount < maxRetryCount) {
          Logger.log('网络: 等待 ${retryDelay.inSeconds} 秒后重试...');
          await Future.delayed(retryDelay);
        }
      }

      // 所有重试都失败，返回默认IP
      Logger.log('网络: 获取公网IP失败，已达到最大重试次数 ($maxRetryCount)，返回默认IP');
      return '127.0.0.1';
    } catch (e) {
      Logger.log('网络: 获取公网IP过程中发生异常: $e');
      return '127.0.0.1';
    } finally {
      // 重置执行状态
      _isGettingPublicIP = false;
    }
  }

  /// 单次尝试获取公网IP
  Future<String?> _attemptGetPublicIP(List<String> apiEndpoints) async {
    // 创建CancelToken用于取消其他请求
    final cancelToken = CancelToken();

    try {
      // 并行发起所有请求
      final requests = apiEndpoints.map((endpoint) async {
        Logger.log('网络: 获取IP源> $endpoint');
        try {
          final response = await Dio().get(
            endpoint,
            cancelToken: cancelToken,
            options: Options(
              receiveTimeout: Duration(seconds: 10),
              sendTimeout: Duration(seconds: 10),
            ),
          );

          if (response.statusCode == 200) {
            final ip = response.data.toString().trim();
            if (ip.isValidIP()) {
              Logger.log('网络: 从 $endpoint 成功获取IP: $ip');
              return ip;
            } else {
              Logger.log('网络: 从 $endpoint 获取的IP格式无效: $ip');
            }
          } else {
            Logger.log('网络: 从 $endpoint 获取IP失败，状态码: ${response.statusCode}');
          }
        } catch (e) {
          Logger.log('网络: 获取公网IP失败 $endpoint: $e');
        }
        return null;
      }).toList();

      // 等待第一个成功的请求
      final results = await Future.any(requests);

      if (results != null) {
        // 取消其他请求
        cancelToken.cancel('已获取到IP');
        return results;
      }

      return null;
    } catch (e) {
      Logger.log('网络: 单次尝试获取公网IP失败: $e');
      return null;
    }
  }

  /// 获取网络位置信息
  Future<NetworkGeoInfo?> loadNetworkGeoInfo() async {
    // 如果已经有信息，直接返回
    if (geoInfo != null) {
      publicIP = geoInfo!.ip;
      return geoInfo!;
    }

    // 定义多个服务商的 url 和解析方法
    final List<_ProviderDefinition> providers = [
      //开源免费
      _ProviderDefinition(
        url:
            'http://ip-api.com/json/?lang=zh-CN&fields=status,message,country,countryCode,region,regionName,city,lat,lon,timezone,query,mobile',
        parser: (data) {
          try {
            if (data is Map && data['status'] == 'success') {
              return NetworkGeoInfo()
                ..ip = data['query'] ?? ''
                ..country = data['country'] ?? ''
                ..countryCode = data['countryCode'] ?? ''
                ..region = data['region'] ?? ''
                ..regionName = data['regionName'] ?? ''
                ..city = data['city'] ?? ''
                ..lat = (data['lat'] ?? 0.0).toDouble()
                ..lon = (data['lon'] ?? 0.0).toDouble()
                ..timezone = data['timezone'] ?? '';
            }
            return null;
          } catch (_) {
            return null;
          }
        },
      ),
      // 免费：每分钟60次
      _ProviderDefinition(
        url: 'https://free.freeipapi.com/api/json/',
        parser: (data) {
          try {
            if (data is Map) {
              var timeZones = data['timeZones'] ?? [];
              var timezone = timeZones.isNotEmpty ? timeZones.first : '';
              return NetworkGeoInfo()
                ..ip = data['ipAddress'] ?? ''
                ..country = data['countryName'] ?? ''
                ..countryCode = data['countryCode'] ?? ''
                ..region = data['regionName'] ?? ''
                ..regionName = data['regionName'] ?? ''
                ..city = data['cityName'] ?? ''
                ..lat = (data['latitude'] ?? 0.0).toDouble()
                ..lon = (data['longitude'] ?? 0.0).toDouble()
                ..timezone = timezone;
            }
            return null;
          } catch (_) {
            return null;
          }
        },
      ),
      //https://ipinfo.io/developers使用最新API，KEY方式无限制https://api.ipinfo.io/lite/me?token=2bbec5864d5271
      _ProviderDefinition(
        url: 'https://ipinfo.io/json',
        parser: (data) {
          try {
            if (data is Map) {
              return NetworkGeoInfo()
                ..ip = data['ip'] ?? ''
                ..country = data['country'] ?? ''
                ..countryCode = data['country'] ?? ''
                ..region = data['region'] ?? ''
                ..regionName = data['region'] ?? ''
                ..city = data['city'] ?? ''
                ..lat = 0.0
                ..lon = 0.0
                ..timezone = data['timezone'] ?? '';
            }
          } catch (_) {
            return null;
          }
          return null;
        },
      ),
      // 免费
      _ProviderDefinition(
        url: 'https://ipv4-check-perf.radar.cloudflare.com/api/info',
        parser: (data) {
          try {
            if (data is Map) {
              return NetworkGeoInfo()
                ..ip = data['ip_address'] ?? ''
                ..country = data['country'] ?? ''
                ..countryCode = data['country'] ?? ''
                ..region = data['region'] ?? ''
                ..regionName = data['region'] ?? ''
                ..city = data['city'] ?? ''
                ..lat = 0.0
                ..lon = 0.0
                ..timezone = '';
            }
          } catch (_) {
            return null;
          }
          return null;
        },
      ),
      // 每天免费30000次
      _ProviderDefinition(
        url: 'https://ipapi.co/json/',
        parser: (data) {
          try {
            if (data is Map) {
              return NetworkGeoInfo()
                ..ip = data['ip'] ?? ''
                ..country = data['country'] ?? ''
                ..countryCode = data['country_code'] ?? ''
                ..region = data['region'] ?? ''
                ..regionName = data['region_code'] ?? ''
                ..city = data['city'] ?? ''
                ..lat = 0.0
                ..lon = 0.0
                ..timezone = data['timezone'] ?? '';
            }
          } catch (_) {
            return null;
          }
          return null;
        },
      ),
      //每天1500次
      _ProviderDefinition(
        url:
            'https://api.ipdata.co?api-key=8d79f088ef95545378ef877ef2ecdff9ed4909d5e213e5a8a9a71b97&fields=ip,is_eu,city,region,region_code,country_name,country_code,continent_name,continent_code,latitude,longitude',
        parser: (data) {
          try {
            if (data is Map) {
              return NetworkGeoInfo()
                ..ip = data['ip'] ?? ''
                ..country = data['country_name'] ?? ''
                ..countryCode = data['country_code'] ?? ''
                ..region = data['region'] ?? ''
                ..regionName = data['region_code'] ?? ''
                ..city = data['city'] ?? ''
                ..lat = 0.0
                ..lon = 0.0
                ..timezone = data['timezone'] ?? '';
            }
          } catch (_) {
            return null;
          }
          return null;
        },
      ),
      //每月30000次
      _ProviderDefinition(
        url:
            'https://api.ipgeolocation.io/v2/ipgeo?apiKey=50c00e5864934ed7869d22ce078bcfb9',
        parser: (data) {
          try {
            if (data is Map &&
                data['ip'] != null &&
                data['ip'].toString().isNotEmpty) {
              var lat = 0.0;
              var lon = 0.0;
              if (data['location'] is Map) {
                var locationMap = data['location'] as Map;
                return NetworkGeoInfo()
                  ..ip = data['ip'] ?? ''
                  ..country = locationMap['country_name'] ?? ''
                  ..countryCode = locationMap['country_code2'] ?? ''
                  ..region = data['state_prov'] ?? ''
                  ..regionName = data['state_code'] ?? ''
                  ..city = data['city'] ?? ''
                  ..lat = lat
                  ..lon = lon
                  ..timezone = data['timezone'] ?? '';
              }
            }
          } catch (_) {
            return null;
          }
          return null;
        },
      ),
    ];

    // 串行请求各服务商
    for (final provider in providers) {
      try {
        final response = await Dio().get(provider.url);
        final data = response.data;
        final info = provider.parser(data);
        if (info != null) {
          publicIP = info.ip;
          geoInfo = info;
          break;
        }
      } catch (e) {
        // ignore, 尝试下一个
        Logger.log('IP定位服务失败: ${provider.url} 错误: $e');
      }
    }

    return geoInfo;
  }

  /// 设置网络健康检查开关
  void setHealthCheckEnabled(bool enabled) {
    enableHealthCheck = enabled;
    if (!enabled) {
      _healthCheckTimer?.cancel();
      _healthCheckTimer = null;
      _healthCheckDebounceTimer?.cancel();
      _healthCheckDebounceTimer = null;
    } else {
      // 启动定时器获取公网IP
      _healthCheckTimer =
          Timer.periodic(Duration(minutes: checkMinutesInterval), (timer) {
        checkNetworkHealth();
      });
    }
  }

  /// 设置防抖延迟时间
  void setHealthCheckDebounceSeconds(int seconds) {
    healthCheckDebounceSeconds = seconds;
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
  /// final status = await NetworkUtil.checkNetworkHealth();
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
  /// NetworkUtil.checkNetworkHealth().then((status) {
  ///   if (status == NetworkHealthStatus.unavailable) {
  ///     // 弹窗提示
  ///   }
  /// });
  ///
  /// //界面示例：
  /// FutureBuilder<NetworkHealthStatus>(
  ///   future: NetworkUtil.checkNetworkHealth(),
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

    final urls = _testUrls + extraUrls;

    // 为每个URL创建单独的CancelToken
    final cancelTokens = urls.map((_) => CancelToken()).toList();

    for (var i = 0; i < urls.length; i++) {
      final url = urls[i];
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
            '网络健康检测: $url 响应 statusCode=${response.statusCode}, 耗时=${responseTime}ms');

        if (response.statusCode == 200) {
          hasSuccess = true;
        }
      }).catchError((e) {
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
          fastResponseTime = fastestTime;
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
}

/*
Obx(() {
  switch (NetworkUtil.status.value) {
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
// Provider解析辅助类（可放在文件末尾或类外部）
class _ProviderDefinition {
  final String url;
  final NetworkGeoInfo? Function(dynamic data) parser;

  _ProviderDefinition({required this.url, required this.parser});
}
