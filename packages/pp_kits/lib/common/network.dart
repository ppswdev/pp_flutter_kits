import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import 'package:pp_kits/common/logger.dart';

enum NetworkStatus { mobile, wifi, ethernet, vpn, bluetooth, none }

class NetworkController extends GetxController {
  var isConnected = false.obs;
  var status = NetworkStatus.none.obs;
  late final Connectivity _connectivity;
  late final StreamSubscription<List<ConnectivityResult>>
      _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _connectivity = Connectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      Logger.trace('pp_kits onConnectivityChanged');
      _updateNetworkStatus(results);
    });
    Logger.log('pp_kits 网络初始化完成, 开启监听中...');
  }

  void _updateNetworkStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.mobile)) {
      status.value = NetworkStatus.mobile;
      Logger.log('pp_kits 连接的移动网络');
    } else if (results.contains(ConnectivityResult.wifi)) {
      status.value = NetworkStatus.wifi;
      Logger.log('pp_kits 连接的Wifi网络');
    } else if (results.contains(ConnectivityResult.ethernet)) {
      status.value = NetworkStatus.ethernet;
      Logger.log('pp_kits 连接的以太网');
    } else if (results.contains(ConnectivityResult.vpn)) {
      status.value = NetworkStatus.vpn;
      Logger.trace('pp_kits 连接的VPN网络');
    } else if (results.contains(ConnectivityResult.bluetooth)) {
      status.value = NetworkStatus.bluetooth;
      Logger.trace('pp_kits 连接的蓝牙网络');
    } else if (results.contains(ConnectivityResult.other)) {
      status.value = NetworkStatus.none;
      Logger.trace('pp_kits 未知的网络');
    } else if (results.contains(ConnectivityResult.none)) {
      status.value = NetworkStatus.none;
      Logger.trace('pp_kits 无网络');
    }
    if (status.value == NetworkStatus.none) {
      Logger.log('pp_kits 网络已断开');
      isConnected.value = false;
    } else {
      Logger.trace('pp_kits 网络已连接: ${status.value}');
      isConnected.value = true;
    }
  }

  @override
  void onClose() {
    Logger.trace('pp_kits NetworkController资源释放');
    _connectivitySubscription.cancel();
    super.onClose();
  }

  void checkConnectivity() async {
    final List<ConnectivityResult> results =
        await (_connectivity.checkConnectivity());
    _updateNetworkStatus(results);
  }
}
