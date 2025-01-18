import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:ndt7_service/ndt7_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _ndtService = Ndt7Service();
  StreamSubscription? _ndtserviceSubscription;

  final _serverList = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();

    _ndtserviceSubscription = _ndtService.onNDTServiceEvents.listen((event) {
      final eventType = event.$1;
      final eventData = event.$2;

      if (eventType == 'onServersLoaded') {
        final servers = eventData["servers"];
        print('onServersLoaded $servers');
      } else if (eventType == 'onTestUpdate') {
        final kind = eventData["kind"] as String;
        final running = eventData["running"] as bool;
        print('onTestUpdate kind $kind, running $running');
      } else if (eventType == 'onMeasurementUpdate') {
        final origin = eventData["origin"] as String;
        final kind = eventData["kind"] as String;
        //final measurement = eventData["measurement"] as String;
        final measurement = eventData["measurement"] as String;
        final measurementMap = jsonDecode(measurement) as Map<String, dynamic>;
        final rawData = measurementMap["rawData"];
        final rawDataMap = jsonDecode(rawData) as Map<String, dynamic>;
        //print("rawData: $rawDataMap");
        print(
            'onMeasurementUpdate origin: $origin kind: $kind measurement: $measurement');
      } else if (eventType == 'onError') {
        final kind = eventData["kind"] as String;
        final str = eventData["str"] as String;
        print('onError kind $kind, running $str');
      }
    });
  }

  @override
  void dispose() {
    _ndtserviceSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  _ndtService.loadServers();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 26.0),
                  fixedSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'Load Servers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _ndtService.startTest(index: 0);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 26.0),
                  fixedSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'Start Test',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _ndtService.stopTest();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 26.0),
                  fixedSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'Stop Test',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
