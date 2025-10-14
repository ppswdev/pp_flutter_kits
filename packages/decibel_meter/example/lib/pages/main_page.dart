import 'package:flutter/material.dart';
import 'decibel_meter_page.dart';
import 'noise_dosimeter_page.dart';
import 'settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DecibelMeterPage(),
    NoiseDosimeterPage(),
    SettingsPage(),
  ];

  final List<BottomNavigationBarItem> _navigationItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.graphic_eq), label: '分贝计'),
    BottomNavigationBarItem(
      icon: Icon(Icons.health_and_safety),
      label: '噪音测量计',
    ),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('分贝测量仪'), centerTitle: true),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _navigationItems,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
