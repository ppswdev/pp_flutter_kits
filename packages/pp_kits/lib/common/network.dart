import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import 'package:pp_kits/common/logger.dart';
import 'package:pp_kits/extensions/extension_on_string.dart';

enum NetworkStatus { mobile, wifi, ethernet, vpn, bluetooth, none }

/// 网络控制器
///
/// 获取网络状态，网络信息等
class NetworkController extends GetxController {
  /// 网络是否已连接
  var isConnected = false.obs;

  /// 网络状态
  var status = NetworkStatus.none.obs;

  /// 公网IP
  var publicIP = '';

  /// IP监听器
  Timer? _ipCheckTimer;
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

    // 启动定时器获取公网IP
    _ipCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      getPublicIp();
    });
  }

  void _updateNetworkStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.mobile)) {
      status.value = NetworkStatus.mobile;
      Logger.trace('连接的移动网络');
    } else if (results.contains(ConnectivityResult.wifi)) {
      status.value = NetworkStatus.wifi;
      Logger.trace('连接的Wifi网络');
    } else if (results.contains(ConnectivityResult.ethernet)) {
      status.value = NetworkStatus.ethernet;
      Logger.trace('连接的以太网');
    } else if (results.contains(ConnectivityResult.vpn)) {
      status.value = NetworkStatus.vpn;
      Logger.trace('连接的VPN网络');
    } else if (results.contains(ConnectivityResult.bluetooth)) {
      status.value = NetworkStatus.bluetooth;
      Logger.trace('连接的蓝牙网络');
    } else if (results.contains(ConnectivityResult.other)) {
      status.value = NetworkStatus.none;
    } else if (results.contains(ConnectivityResult.none)) {
      status.value = NetworkStatus.none;
    }
    if (status.value == NetworkStatus.none) {
      Logger.trace('网络已断开');
      isConnected.value = false;
    } else {
      Logger.trace('网络已连接: ${status.value}');
      isConnected.value = true;
    }
  }

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
      'https://checkip.amazonaws.com'
    ];
    for (var endpoint in apiEndpoints) {
      Logger.log('网络: 获取IP源> $endpoint');
      try {
        final response = await Dio().get(endpoint);
        if (response.statusCode == 200) {
          publicIP = response.data.toString().trim();
          if (publicIP.isValidIP()) {
            _ipCheckTimer?.cancel();
            _ipCheckTimer = null;
          }
          Logger.log('网络: 成功获取公网IP: $publicIP');
          break;
        }
      } catch (e) {
        Logger.log('获取公网IP失败 $endpoint: $e');
      }
    }

    Logger.log('网络: 当前公共IP>$publicIP');
    return publicIP;
  }

  @override
  void onClose() {
    Logger.trace('NetworkController资源释放');
    _connectivitySubscription.cancel();
    _ipCheckTimer?.cancel();
    _ipCheckTimer = null;
    super.onClose();
  }

  void checkConnectivity() async {
    final List<ConnectivityResult> results =
        await (_connectivity.checkConnectivity());
    _updateNetworkStatus(results);
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
