import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:pp_asa_attribution/pp_asa_attribution.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    fetchASAData1();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> fetchASAData1() async {
    Map<String, dynamic>? attributionJson =
        await PPAsaAttribution().requestAttributionDetails();
    int retryCount = 0;
    while (attributionJson == null && retryCount < 3) {
      print('uploadASAData attributionJson is null, retry count: $retryCount');
      // 延迟5秒后重试
      await Future.delayed(const Duration(seconds: 5));
      attributionJson = await PPAsaAttribution().requestAttributionDetails();
      retryCount++;
    }
    if (attributionJson == null) {
      print('uploadASAData json null after 3 retries');
      return;
    }
    print('uploadASAData attributionJson: $attributionJson');
    setState(() {
      _platformVersion = attributionJson.toString();
    });
  }

  Future<void> fetchASAData2() async {
    String? token = await PPAsaAttribution().attributionToken();
    if (token == null) {
      print('uploadASAData token is null');
      return;
    }
    print('uploadASAData token: $token');
    // 延迟500毫秒后再请求
    await Future.delayed(const Duration(milliseconds: 500));
    Map<String, dynamic>? attributionJson =
        await PPAsaAttribution().requestAttributionWithToken(token);
    int retryCount = 0;
    while (attributionJson == null && retryCount < 3) {
      print('uploadASAData attributionJson is null, retry count: $retryCount');
      // 延迟5秒后重试
      await Future.delayed(const Duration(seconds: 5));
      attributionJson =
          await PPAsaAttribution().requestAttributionWithToken(token);
      retryCount++;
    }
    if (attributionJson == null) {
      print('uploadASAData json null after 3 retries');
      return;
    }
    print('uploadASAData attributionJson: $attributionJson');
    setState(() {
      _platformVersion = attributionJson.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
