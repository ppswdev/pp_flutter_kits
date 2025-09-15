import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pp_segmented/pp_segmented.dart';

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
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PPSegmentedControl<int>(
              items: List.generate(
                9,
                (index) =>
                    SegmentItem(value: index + 1, child: Text('${index + 1}')),
              ),
              selectedValue: 1,
              onChanged: (count) {
                print('选中: $count');
              },
              width: double.infinity,
              height: 35,
              borderRadius: 9,
              backgroundColor: Color(0xFF807D78).withValues(alpha: 0.12),
              indicatorColor: Colors.green,
              selectedTextColor: Colors.white,
              unselectedTextColor: Colors.black,
              indicatorBorderRadius: 7,
            ),
            SizedBox(height: 15),
            PPSegmentedControl<int>(
              items: List.generate(
                9,
                (index) =>
                    SegmentItem(value: index + 1, child: Text('${index + 1}')),
              ),
              selectedValue: 1,
              onChanged: (count) {
                print('选中: $count');
              },
              width: double.infinity,
              height: 35,
              borderRadius: 9,
              backgroundColor: Color(0xFF807D78).withOpacity(0.12),
              backgroundGradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              indicatorColor: Colors.green,
              indicatorGradient: LinearGradient(
                colors: [Colors.white, Colors.green],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              selectedTextColor: Colors.white,
              unselectedTextColor: Colors.black,
              indicatorBorderRadius: 7,
            ),
            SizedBox(height: 15),
            PPSegmentedControl<int>(
              items: List.generate(
                9,
                (index) =>
                    SegmentItem(value: index + 1, child: Text('${index + 1}')),
              ),
              selectedValue: 1,
              onChanged: (count) {
                print('选中: $count');
              },
              width: double.infinity,
              height: 40,
              borderRadius: 20,
              backgroundColor: Color(0xFF807D78).withValues(alpha: 0.12),
              indicatorColor: Colors.green,
              indicatorGradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              selectedTextColor: Colors.white,
              unselectedTextColor: Colors.black,
              indicatorBorderRadius: 20,
            ),
            SizedBox(height: 15),
            PPSegmentedControl<int>(
              items: [
                SegmentItem(value: 1, child: Text('首页')),
                SegmentItem(value: 2, child: Text('发现')),
                SegmentItem(value: 3, child: Text('消息')),
                SegmentItem(value: 4, child: Text('我的')),
              ],
              selectedValue: 1,
              onChanged: (value) => print('选中: $value'),
              height: 45,
              borderRadius: 12,
              backgroundGradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.1),
                  Colors.purple.withOpacity(0.1),
                ],
              ),
              indicatorGradient:
                  LinearGradient(colors: [Colors.blue, Colors.purple]),
              indicatorBorderRadius: 10,
              indicatorShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
              selectedTextColor: Colors.white,
              unselectedTextColor: Colors.black87,
            ),
            SizedBox(height: 15),
            PPSegmentedControl<int>(
              items: [
                SegmentItem(value: 1, child: Icon(Icons.home, size: 16)),
                SegmentItem(value: 2, child: Icon(Icons.search, size: 16)),
                SegmentItem(value: 3, child: Icon(Icons.message, size: 16)),
                SegmentItem(value: 4, child: Icon(Icons.person, size: 16)),
              ],
              selectedValue: 1,
              onChanged: (value) => print('选中: $value'),
              height: 45,
              borderRadius: 12,
              backgroundGradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.1),
                  Colors.purple.withOpacity(0.1),
                ],
              ),
              indicatorGradient:
                  LinearGradient(colors: [Colors.blue, Colors.purple]),
              indicatorBorderRadius: 10,
              selectedTextColor: Colors.white,
              unselectedTextColor: Colors.black87,
            ),
            SizedBox(height: 15),
            PPSegmentedControl<int>(
              items: [
                SegmentItem(value: 1, child: Text('首页')),
                SegmentItem(
                  value: 2,
                  child: AutoSizeText(
                    '发现发现发现发现发现发现',
                    textAlign: TextAlign.center,
                    minFontSize: 8,
                  ),
                ),
                SegmentItem(
                  value: 3,
                  child: AutoSizeText(
                    'Long length word Long length word',
                    textAlign: TextAlign.center,
                    minFontSize: 8,
                    maxFontSize: 20,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                SegmentItem(value: 4, child: Text('我的')),
              ],
              selectedValue: 1,
              onChanged: (value) => print('选中: $value'),
              height: 60,
              borderRadius: 20,
              backgroundGradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.1),
                  Colors.purple.withOpacity(0.1),
                ],
              ),
              indicatorGradient:
                  LinearGradient(colors: [Colors.blue, Colors.purple]),
              indicatorBorderRadius: 20,
              selectedTextColor: Colors.white,
              unselectedTextColor: Colors.black87,
            ),
            SizedBox(height: 15),
            PPSegmentedControl<String>(
              items: [
                SegmentItem(
                  value: 'home',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home, size: 16),
                      SizedBox(width: 4),
                      Text('首页'),
                    ],
                  ),
                ),
                SegmentItem(
                  value: 'search',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search, size: 16),
                      SizedBox(width: 4),
                      Text('搜索'),
                    ],
                  ),
                ),
              ],
              selectedValue: 'home',
              onChanged: (value) => print(value),
              height: 50,
              borderRadius: 20,
              backgroundGradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.1),
                  Colors.purple.withOpacity(0.1),
                ],
              ),
              indicatorGradient:
                  LinearGradient(colors: [Colors.blue, Colors.purple]),
              indicatorBorderRadius: 20,
              selectedTextColor: Colors.white,
              unselectedTextColor: Colors.black,
            ),
            SizedBox(height: 15),
            PPSegmentedControl<String>(
              items: [
                SegmentItem(
                  value: 'easy',
                  child: Container(
                    padding: EdgeInsets.only(bottom: 5),
                    color: Colors.amber,
                    child: Text('简单'),
                  ),
                ),
                SegmentItem(
                  value: 'medium',
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 16),
                        SizedBox(width: 4),
                        Text('中等'),
                      ],
                    ),
                  ),
                ),
                SegmentItem(
                  value: 'hard',
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.diamond, size: 16),
                      Text('困难', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
              selectedValue: 'easy',
              onChanged: (value) => print('选中: $value'),
              selectedTextColor: Colors.white,
              unselectedTextColor: Colors.black54,
              backgroundColor: Colors.grey.withOpacity(0.1),
              indicatorColor: Colors.green,
              indicator: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
