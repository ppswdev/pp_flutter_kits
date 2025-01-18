<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

It makes adding page background styles easier and the code more concise.

## Features

Supports custom solid color, gradient color, background image Scaffold

## Getting started

``` yaml
dependencies:
  custom_background_scaffold: ^1.0.0
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
