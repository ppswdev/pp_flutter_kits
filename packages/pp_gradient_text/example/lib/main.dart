import 'package:flutter/material.dart';
import 'package:pp_gradient_text/pp_gradient_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gradient Text Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GradientTextExample(),
    );
  }
}

class GradientTextExample extends StatelessWidget {
  const GradientTextExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Gradient Text Demo'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 基本用法 - 默认渐变
              GradientText(
                text: 'Hello Gradient Text!',
              ),
              const SizedBox(height: 20),

              // 自定义颜色渐变
              GradientText(
                text: 'Custom Colors',
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.pink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // 水平渐变
              GradientText(
                text: 'Horizontal Gradient',
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.green],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                textStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),

              // 垂直渐变
              GradientText(
                text: 'Vertical Gradient',
                gradient: const LinearGradient(
                  colors: [Colors.red, Colors.yellow],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                textStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),

              // 多色渐变
              GradientText(
                text: 'Rainbow Gradient',
                gradient: const LinearGradient(
                  colors: [
                    Colors.red,
                    Colors.orange,
                    Colors.yellow,
                    Colors.green,
                    Colors.blue,
                    Colors.indigo,
                    Colors.purple,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                textStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),

              // 径向渐变
              GradientText(
                text: 'Radial Gradient',
                gradient: const RadialGradient(
                  colors: [Colors.purple, Colors.blue],
                  center: Alignment.center,
                  radius: 0.5,
                ),
                textStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // 不同文本对齐方式
              GradientText(
                text: 'Left Aligned',
                gradient: const LinearGradient(
                  colors: [Colors.green, Colors.teal],
                ),
                textAlign: TextAlign.left,
                textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              GradientText(
                text: 'Center Aligned',
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.cyan],
                ),
                textAlign: TextAlign.center,
                textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              GradientText(
                text: 'Right Aligned',
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.pink],
                ),
                textAlign: TextAlign.right,
                textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),

              // 不同文本样式
              GradientText(
                text: 'Italic Style',
                gradient: const LinearGradient(
                  colors: [Colors.brown, Colors.orange],
                ),
                textStyle: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 10),
              GradientText(
                text: 'Underline Style',
                gradient: const LinearGradient(
                  colors: [Colors.teal, Colors.blue],
                ),
                textStyle: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 10),
              GradientText(
                text: 'Large Text',
                gradient: const LinearGradient(
                  colors: [Colors.red, Colors.purple],
                ),
                textStyle: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // 使用child参数
              GradientText(
                text: 'This won\'t be shown',
                gradient: const LinearGradient(
                  colors: [Colors.green, Colors.lime],
                ),
                child: const Text(
                  'Using Child Parameter',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 在容器中使用
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GradientText(
                  text: 'In Black Container',
                  gradient: const LinearGradient(
                    colors: [Colors.white, Colors.grey],
                  ),
                  textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
