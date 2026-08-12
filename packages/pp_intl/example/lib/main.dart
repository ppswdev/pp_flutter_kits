import 'package:flutter/material.dart';
import 'package:pp_intl/pp_intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  initState() {
    super.initState();
    _initLanguage();
  }

  Future<void> _initLanguage() async {
    print('=== PPIntl 功能测试 ===');

    // 1. 设置默认语言（中文）
    print('\n1. 设置默认语言为中文');
    await PPIntl.instance.setLanguage('zh_Hans');
    print('默认语言设置完成');

    // 2. 测试同步方法（缓存存在时）
    print('\n2. 测试同步方法');
    String hello = PPIntl.textSync(PPIntlKey.hello);
    print('同步获取中文: $hello');

    String welcome = PPIntl.textSync(PPIntlKey.welcome);
    print('同步获取中文欢迎: $welcome');

    // 3. 测试异步方法（自动检查缓存）
    print('\n3. 测试异步方法');
    String helloAsync = await PPIntl.text(PPIntlKey.hello);
    print('异步获取中文: $helloAsync');

    // 4. 测试多语言支持
    print('\n4. 测试多语言支持');

    // 英语
    String helloEn = await PPIntl.text(PPIntlKey.hello, 'en');
    print('英语: $helloEn');

    // 日语
    String helloJa = await PPIntl.text(PPIntlKey.hello, 'ja');
    print('日语: $helloJa');

    // 韩语
    String helloKo = await PPIntl.text(PPIntlKey.hello, 'ko');
    print('韩语: $helloKo');

    // 法语
    String helloFr = await PPIntl.text(PPIntlKey.hello, 'fr');
    print('法语: $helloFr');

    // 5. 测试参数化字符串
    print('\n5. 测试参数化字符串');

    String helloJohn = await PPIntl.text(PPIntlKey.helloName, 'en', {
      'name': 'John',
    });
    print('英语带参数: $helloJohn');

    String helloZhang = await PPIntl.text(PPIntlKey.helloName, 'zh_Hans', {
      'name': '张三',
    });
    print('中文带参数: $helloZhang');

    String welcomeAlice = await PPIntl.text(PPIntlKey.welcomeName, 'ja', {
      'name': 'アリス',
    });
    print('日语带参数: $welcomeAlice');

    // 6. 测试同步方法获取已缓存的其他语言
    print('\n6. 测试同步方法获取已缓存的其他语言');
    String helloEnSync = PPIntl.textSync(PPIntlKey.hello, 'en');
    print('同步获取英语: $helloEnSync');

    String helloJaSync = PPIntl.textSync(PPIntlKey.hello, 'ja');
    print('同步获取日语: $helloJaSync');

    // 7. 测试错误处理（不存在的语言）
    print('\n7. 测试错误处理');
    String helloUnknown = await PPIntl.text(PPIntlKey.hello, 'xx');
    print('不存在的语言: $helloUnknown');

    // 8. 测试切换默认语言
    print('\n8. 测试切换默认语言');
    await PPIntl.instance.setLanguage('en');
    String helloDefaultEn = PPIntl.textSync(PPIntlKey.hello);
    print('切换默认语言为英语: $helloDefaultEn');

    print('\n=== 测试完成 ===');
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
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
