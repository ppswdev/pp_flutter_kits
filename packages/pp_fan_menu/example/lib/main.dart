import 'package:flutter/material.dart';
import 'package:pp_fan_menu/pp_fan_menu.dart';

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FanMenuExample(),
    );
  }
}

class FanMenuExample extends StatelessWidget {
  const FanMenuExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fan Menu Example')),
      body: SafeArea(
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Stack(
            children: [
              // Start
              Positioned.fill(
                child: PPFanMenu(
                  alignment: AlignmentDirectional.topStart,
                  openIcon: const Icon(Icons.menu),
                  hideIcon: const Icon(Icons.close),
                  onChildPressed: (index) {
                    print('Child $index pressed');
                  },
                  children: const [
                    Icon(Icons.star, size: 40),
                    Icon(Icons.camera, size: 40),
                    Icon(Icons.mail, size: 40),
                    Icon(Icons.mail, size: 40),
                  ],
                ),
              ),
              Positioned.fill(
                child: PPFanMenu(
                  alignment: AlignmentDirectional.centerStart,
                  openIcon: const Icon(Icons.menu),
                  hideIcon: const Icon(Icons.close),
                  onChildPressed: (index) {
                    print('Child $index pressed');
                  },
                  children: const [
                    Icon(Icons.star, size: 40),
                    Icon(Icons.camera, size: 40),
                    Icon(Icons.mail, size: 40),
                  ],
                ),
              ),
              Positioned.fill(
                child: PPFanMenu(
                  alignment: AlignmentDirectional.bottomStart,
                  openIcon: const Icon(Icons.menu),
                  hideIcon: const Icon(Icons.close),
                  onChildPressed: (index) {
                    print('Child $index pressed');
                  },
                  children: const [
                    Icon(Icons.star, size: 40),
                    Icon(Icons.camera, size: 40),
                    Icon(Icons.mail, size: 40),
                  ],
                ),
              ),
              // Center
              Positioned.fill(
                child: PPFanMenu(
                  alignment: AlignmentDirectional.topCenter,
                  openIcon: const Icon(Icons.menu),
                  hideIcon: const Icon(Icons.close),
                  onChildPressed: (index) {
                    print('Child $index pressed');
                  },
                  children: const [
                    Icon(Icons.star, size: 40),
                    Icon(Icons.camera, size: 40),
                    Icon(Icons.mail, size: 40),
                  ],
                ),
              ),
              Positioned.fill(
                child: PPFanMenu(
                  alignment: AlignmentDirectional.center,
                  openIcon: const Icon(Icons.menu),
                  hideIcon: const Icon(Icons.close),
                  onChildPressed: (index) {
                    print('Child $index pressed');
                  },
                  children: const [
                    Icon(Icons.star, size: 40),
                    Icon(Icons.camera, size: 40),
                    Icon(Icons.mail, size: 40),
                    Icon(Icons.star, size: 40),
                    Icon(Icons.camera, size: 40),
                    Icon(Icons.mail, size: 40),
                    Icon(Icons.star, size: 40),
                    Icon(Icons.camera, size: 40),
                  ],
                ),
              ),
              Positioned.fill(
                child: PPFanMenu(
                  alignment: AlignmentDirectional.bottomCenter,
                  openIcon: const Icon(Icons.menu),
                  hideIcon: const Icon(Icons.close),
                  onChildPressed: (index) {
                    print('Child $index pressed');
                  },
                  children: const [
                    Icon(Icons.star, size: 40),
                    Icon(Icons.camera, size: 40),
                    Icon(Icons.mail, size: 40),
                  ],
                ),
              ),
              // End
              Positioned.fill(
                child: PPFanMenu(
                  alignment: AlignmentDirectional.topEnd,
                  openIcon: const Icon(Icons.menu),
                  hideIcon: const Icon(Icons.close),
                  onChildPressed: (index) {
                    print('Child $index pressed');
                  },
                  children: const [
                    Icon(Icons.star, size: 40),
                    Icon(Icons.camera, size: 40),
                    Icon(Icons.mail, size: 40),
                  ],
                ),
              ),
              Positioned.fill(
                child: PPFanMenu(
                  alignment: AlignmentDirectional.centerEnd,
                  openIcon: const Icon(Icons.menu),
                  hideIcon: const Icon(Icons.close),
                  onChildPressed: (index) {
                    print('Child $index pressed');
                  },
                  children: const [
                    Icon(Icons.star, size: 40),
                    Icon(Icons.camera, size: 40),
                    Icon(Icons.mail, size: 40),
                    Icon(Icons.camera, size: 40),
                  ],
                ),
              ),
              Positioned.fill(
                child: PPFanMenu(
                  alignment: AlignmentDirectional.bottomEnd, //右下角建议：3-4个选项最佳
                  radius: 100,
                  openIcon: const Icon(Icons.menu),
                  hideIcon: const Icon(Icons.close),
                  onChildPressed: (index) {
                    print('Child $index pressed');
                  },
                  onExpandChanged: (isOpen) {
                    print('Menu is ${isOpen ? 'open' : 'closed'}');
                  },
                  children: const [
                    Icon(Icons.star, size: 40),
                    Icon(Icons.camera, size: 40),
                    Icon(Icons.mail, size: 40),
                    Icon(Icons.camera, size: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
