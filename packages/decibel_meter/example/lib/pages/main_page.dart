import 'package:flutter/material.dart';
import 'decibel_meter_page.dart';
import 'noise_dosimeter_page.dart';
import 'settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分贝测量仪'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.graphic_eq), text: '分贝计'),
            Tab(icon: Icon(Icons.health_and_safety), text: '噪音测量计'),
            Tab(icon: Icon(Icons.settings), text: '设置'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DecibelMeterPage(),
          NoiseDosimeterPage(),
          SettingsPage(),
        ],
      ),
    );
  }
}
