
Custom spin wheel. Makes it easier for code to implement wheel effects.

## Features

![Sample1](screenshots/sample1.png)
![Sample2](screenshots/sample2.png)

## Getting started

```yaml
dependencies:
  pp_spin_wheel: ^1.0.8
```

## Usage

```dart
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
          onItemPressed: (index) {
            print('index: $index');
          },
          onItemSpinning: (index) {
            // Play spin audio
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
```
