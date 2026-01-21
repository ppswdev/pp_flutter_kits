import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:pp_keychain/pp_keychain.dart';

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
  String _statusMessage = '';
  final _ppKeychainPlugin = PPKeychain();
  final _keyController = TextEditingController(text: 'test_key');
  final _valueController = TextEditingController(text: 'test_value');

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _ppKeychainPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _saveData() async {
    try {
      bool success = await _ppKeychainPlugin.save(
        key: _keyController.text,
        value: _valueController.text,
      );
      setState(() {
        _statusMessage = success ? '保存成功' : '保存失败';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '保存失败: $e';
      });
    }
  }

  Future<void> _readData() async {
    try {
      String? value = await _ppKeychainPlugin.read(key: _keyController.text);
      setState(() {
        _statusMessage = value != null ? '读取成功: $value' : '读取失败: 键不存在';
        if (value != null) {
          _valueController.text = value;
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = '读取失败: $e';
      });
    }
  }

  Future<void> _deleteData() async {
    try {
      bool success = await _ppKeychainPlugin.delete(key: _keyController.text);
      setState(() {
        _statusMessage = success ? '删除成功' : '删除失败';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '删除失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('pp_keychain 示例')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('运行在: $_platformVersion'),
              const SizedBox(height: 20),

              TextField(
                controller: _keyController,
                decoration: const InputDecoration(
                  labelText: '键 (Key)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: '值 (Value)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveData,
                      child: const Text('保存'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _readData,
                      child: const Text('读取'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _deleteData,
                      child: const Text('删除'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  _statusMessage,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                '使用说明:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text('1. 输入要保存的键和值'),
              const Text('2. 点击"保存"按钮将数据存入钥匙串'),
              const Text('3. 点击"读取"按钮从钥匙串读取数据'),
              const Text('4. 点击"删除"按钮从钥匙串删除数据'),
              const Text('5. 状态消息会显示操作结果'),
            ],
          ),
        ),
      ),
    );
  }
}
