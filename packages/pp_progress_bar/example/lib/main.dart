import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pp_progress_bar/pp_progress_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double progress = 0.2;
  Timer? _timer;

  void startProgress() {
    // 取消已存在的定时器
    _timer?.cancel();
    // 重置进度
    setState(() {
      progress = 0.0;
    });

    // 创建新的定时器,每50毫秒更新一次进度
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (progress < 1.0) {
          progress += 0.01;
        } else {
          progress = 1.0;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Default'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PPProgressBar(
                value: progress,
                height: 30,
                borderRadius: 15,
                trackColor: const Color(0xff4A148C),
                progressColor: const Color(0xffAC50F9),
                progressRadius: 1.0,
                showPercentage: false,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PPProgressBar(
                value: progress,
                height: 30,
                borderRadius: 15,
                trackColor: const Color(0xff4A148C),
                progressColor: const Color(0xffAC50F9),
                progressRadius: 1.0,
                percentageStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PPProgressBar(
                value: progress,
                height: 60,
                borderRadius: 24,
                trackColor: const Color(0xff4A148C),
                progressColor: const Color(0xffAC50F9),
                progressRadius: 1.0,
                percentageStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Overlay'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PPProgressBar(
                value: progress,
                height: 60,
                borderRadius: 24,
                trackColor: const Color(0xff4A148C),
                progressColor: const Color(0xffAC50F9),
                progressRadius: 1.0,
                percentageStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                overlay: Image.asset(
                  'assets/progress_overlay.png',
                  fit: BoxFit.fill,
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: startProgress,
        child: const Icon(Icons.play_circle_fill),
      ),
    );
  }
}
