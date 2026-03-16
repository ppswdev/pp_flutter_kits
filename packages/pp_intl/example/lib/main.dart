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
    await PPIntl.instance.setLanguage('zh_Hans');

    String hello = await PPIntl.text(PPIntlKey.hello);
    print(hello);

    String welcome = await PPIntl.text(PPIntlKey.welcome, 'en');
    print(welcome);

    String welcome2 = await PPIntl.text(PPIntlKey.welcome, 'de');
    print(welcome2);

    String helloJohn = await PPIntl.text(PPIntlKey.helloName, 'en', {
      'name': 'John',
    });
    print(helloJohn);
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
