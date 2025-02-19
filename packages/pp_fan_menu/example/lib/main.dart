import 'package:example/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pp_fan_menu/pp_fan_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      locale: const Locale('en'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: FanMenuExample(),
    );
  }
}

class FanMenuExample extends StatelessWidget {
  FanMenuExample({super.key});

  final GlobalKey<PPFanMenuState> _fanMenuKey = GlobalKey<PPFanMenuState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.appTitle),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.amber,
          // width: 300,
          // height: 300,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Stack(
            children: [
              // Start
              Positioned.fill(
                child: PPFanMenu(
                  alignment: AlignmentDirectional.topStart, //左上角建议：2-4个选项最佳
                  openIcon: const Icon(Icons.menu),
                  hideIcon: const Icon(Icons.close),
                  onChildPressed: (index) {
                    print('Child $index pressed');
                  },
                  children: const [
                    Icon(Icons.star, size: 40),
                    Icon(Icons.camera, size: 40),
                    Icon(Icons.mail, size: 40),
                    Icon(Icons.call, size: 40),
                  ],
                ),
              ),
              Positioned.fill(
                child: PPFanMenu(
                  alignment: AlignmentDirectional.centerStart, //左中建议：1-6个选项最佳
                  openIcon: const Icon(Icons.menu),
                  hideIcon: const Icon(Icons.close),
                  onChildPressed: (index) {
                    print('Child $index pressed');
                  },
                  children: const [
                    Icon(Icons.star, size: 40),
                    Icon(Icons.camera, size: 40),
                    Icon(Icons.mail, size: 40),
                    Icon(Icons.call, size: 40),
                    Icon(Icons.message, size: 40),
                    Icon(Icons.favorite, size: 40),
                  ],
                ),
              ),
              Positioned.fill(
                child: PPFanMenu(
                  alignment: AlignmentDirectional.bottomStart, //左下角建议：2-4个选项最佳
                  openIcon: const Icon(Icons.menu),
                  hideIcon: const Icon(Icons.close),
                  onChildPressed: (index) {
                    print('Child $index pressed');
                  },
                  children: const [
                    Icon(Icons.star, size: 40),
                    Icon(Icons.camera, size: 40),
                    Icon(Icons.mail, size: 40),
                    Icon(Icons.call, size: 40),
                  ],
                ),
              ),
              // Center
              Positioned.fill(
                child: PPFanMenu(
                  alignment: AlignmentDirectional.topCenter, //上中建议：1-6个选项最佳
                  openIcon: const Icon(Icons.menu),
                  hideIcon: const Icon(Icons.close),
                  onChildPressed: (index) {
                    print('Child $index pressed');
                  },
                  children: const [
                    Icon(Icons.star, size: 40),
                    Icon(Icons.camera, size: 40),
                    Icon(Icons.mail, size: 40),
                    Icon(Icons.call, size: 40),
                    Icon(Icons.message, size: 40),
                    Icon(Icons.favorite, size: 40),
                  ],
                ),
              ),
              Positioned.fill(
                child: PPFanMenu(
                  alignment: AlignmentDirectional.center, //中心建议：1-12个选项最佳
                  openIcon: const Icon(Icons.menu),
                  hideIcon: const Icon(Icons.close),
                  onChildPressed: (index) {
                    print('Child $index pressed');
                  },
                  children: const [
                    Icon(Icons.star, size: 40),
                    Icon(Icons.camera, size: 40),
                    Icon(Icons.mail, size: 40),
                    Icon(Icons.commute, size: 40),
                    Icon(Icons.face, size: 40),
                    Icon(Icons.message, size: 40),
                    // Icon(Icons.message, size: 40),
                    // Icon(Icons.message, size: 40),
                    // Icon(Icons.message, size: 40),
                    // Icon(Icons.message, size: 40),
                    // Icon(Icons.message, size: 40),
                    // Icon(Icons.message, size: 40),
                  ],
                ),
              ),
              Positioned.fill(
                child: PPFanMenu(
                  alignment: AlignmentDirectional.bottomCenter, //下中建议：1-6个选项最佳
                  openIcon: const Icon(Icons.menu),
                  hideIcon: const Icon(Icons.close),
                  onChildPressed: (index) {
                    print('Child $index pressed');
                  },
                  children: const [
                    Icon(Icons.star, size: 40),
                    Icon(Icons.camera, size: 40),
                    Icon(Icons.mail, size: 40),
                    Icon(Icons.call, size: 40),
                    Icon(Icons.message, size: 40),
                    Icon(Icons.favorite, size: 40),
                  ],
                ),
              ),
              // End
              Positioned.fill(
                child: PPFanMenu(
                  key: _fanMenuKey,
                  alignment: AlignmentDirectional.topEnd, //右上角建议：2-4个选项最佳
                  openIcon: const Icon(Icons.menu),
                  hideIcon: const Icon(Icons.close),
                  onChildPressed: (index) {
                    print('Child $index pressed');
                  },
                  children: const [
                    Icon(Icons.star, size: 40),
                    Icon(Icons.camera, size: 40),
                    Icon(Icons.mail, size: 40),
                    Icon(Icons.call, size: 40),
                  ],
                ),
              ),
              Positioned.fill(
                child: PPFanMenu(
                  alignment: AlignmentDirectional.centerEnd, //右中建议：1-6个选项最佳
                  openIcon: const Icon(Icons.menu),
                  hideIcon: const Icon(Icons.close),
                  onChildPressed: (index) {
                    print('Child $index pressed');
                  },
                  children: const [
                    Icon(Icons.star, size: 40),
                    Icon(Icons.camera, size: 40),
                    Icon(Icons.mail, size: 40),
                    Icon(Icons.call, size: 40),
                    Icon(Icons.message, size: 40),
                    Icon(Icons.favorite, size: 40),
                  ],
                ),
              ),
              Positioned.fill(
                child: PPFanMenu(
                  alignment: AlignmentDirectional.bottomEnd, //右下角建议：2-4个选项最佳
                  radius: 100,
                  // startAngle: 145,
                  // singleAngle: 32,
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
                    Icon(Icons.call, size: 40),
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
