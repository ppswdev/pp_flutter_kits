import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/main_page.dart';
import 'controllers/decibel_meter_controller.dart';

void main() {
  runApp(const DecibelMeterApp());
}

class DecibelMeterApp extends StatelessWidget {
  const DecibelMeterApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 初始化控制器
    Get.put(DecibelMeterController());

    return GetMaterialApp(
      title: '分贝测量仪',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
