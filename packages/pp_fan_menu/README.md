
Highly and easily customizable fan menu in Stack widget, you can place components anywhere in the screen.

## Getting started

``` bash
flutter pub add pp_fan_menu
```

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
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

```
