
It makes adding page background styles easier and the code more concise.

## Features

Supports custom solid color, gradient color, background image Scaffold

## Getting started

``` yaml
dependencies:
  custom_background_scaffold: ^1.0.2
```

## Usage

```dart
import 'package:custom_background_scaffold/custom_background_scaffold.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return  PPScaffold(
      gradient: const LinearGradient(
        colors: [Colors.blue, Colors.red],
      ),
      // backgroundColor: Colors.yellow,
      // backgroundImage: const DecorationImage(
      //   image: AssetImage('assets/background.jpg'),
      // ),
      appBar: AppBar(
        title: const Text('Custom Background Scaffold'),
      ),
      body: const Text('Hello World'),
    )
  }
}

```
