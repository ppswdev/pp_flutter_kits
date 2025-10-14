import 'package:flutter/material.dart';
import 'pages/main_page.dart';

void main() {
  runApp(const DecibelMeterApp());
}

class DecibelMeterApp extends StatelessWidget {
  const DecibelMeterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
