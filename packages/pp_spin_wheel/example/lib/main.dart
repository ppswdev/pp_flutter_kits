import 'package:flutter/material.dart';
import 'package:pp_spin_wheel/pp_spin_wheel.dart';

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
      home: const GameWheelPage(),
    );
  }
}

class GameWheelPage extends StatefulWidget {
  const GameWheelPage({super.key});

  @override
  State<GameWheelPage> createState() => _GameWheelPageState();
}

class _GameWheelPageState extends State<GameWheelPage> {
  //通过这个方式可以调用PPSpinWheel中的方法, 比如代码方式控制点击某项：_wheelKey.currentState?.tapWheelItem(index);
  final GlobalKey<PPSpinWheelState> _wheelKey = GlobalKey<PPSpinWheelState>();

  var items = [
    const PPSpinWheelItem(
        title: 'Item 1',
        bgColor: Color(0xFFF44336),
        weight: 5.0,
        selected: false),
    const PPSpinWheelItem(
        title: 'Item 2',
        bgColor: Color.fromARGB(255, 131, 143, 132),
        weight: 10.0,
        selected: false),
    const PPSpinWheelItem(
        title: 'Item 3',
        bgColor: Color(0xFF2196F3),
        weight: 15.0,
        selected: false),
    const PPSpinWheelItem(
        title: 'Item 4',
        bgColor: Color(0xFFFFC107),
        weight: 20.0,
        selected: false),
    const PPSpinWheelItem(
        title: 'Item 5',
        bgColor: Color(0xFF9C27B0),
        weight: 50.0,
        selected: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: PPSpinWheel(
          key: _wheelKey,
          size: 360,
          backgroundSize: 340,
          wheelSize: 300,
          // backgroundImage: Image.asset(A.iconWheelDefaultBottom),
          // overlay: Image.asset(
          //   A.iconWheelDefaultHighlight,
          //   width: 302,
          //   height: 302,
          // ),
          // spinIcon: Image.asset(
          //   A.iconWheelDefaultSpin,
          //   width: 60,
          //   height: 60,
          // ),
          // indicator: Image.asset(
          //   A.iconWheelDefaultTopPin,
          //   width: 28,
          //   height: 47,
          // ),
          indicatorAnimateStyle: 0,
          enableWeight: false,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          items: items,
          //filterIndexs: const [0, 1],
          numberOfTurns: 10,
          onItemPressed: (index, selected) {
            print('index: $index $selected');
          },
          onItemSpinning: (index) {
            // Play spin audio & Feedback
          },
          onStartPressed: () {
            //Play start audio
          },
          onSpinFastAudio: () {
            //Play fast audio
          },
          onSpinSlowAudio: () {
            //Play slow audio
          },
          onAnimationEnd: (index) {
            //Play end audio & show result
            print('onAnimationEnd $index');
          },
        ),
      ),
    );
  }
}
