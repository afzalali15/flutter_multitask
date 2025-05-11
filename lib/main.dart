import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/gifs/bouncing-ball.gif', scale: 0.5),
              ElevatedButton.icon(
                onPressed: () async {
                  var json = await fetchData(1000);
                  debugPrint('JSON  parsed: length - ${json.length}');
                },
                label: Text('Async Await'),
                icon: Icon(Icons.star),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  var json = await compute(fetchData, 1000);
                  debugPrint('Compute  result: length - ${json.length}');
                },
                label: Text('Compute'),
                icon: Icon(Icons.star),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  var receivePort = ReceivePort();
                  await Isolate.spawn(fetchDataIsolate, (
                    iteration: 1000,
                    sendPort: receivePort.sendPort,
                  ));
                  receivePort.listen((message) {
                    debugPrint('Isolate progress: $message');
                  });
                },
                label: Text('Isolates'),
                icon: Icon(Icons.star),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> fetchData(int iteration) async {
    final jsonData = jsonEncode(
      List.generate(10000, (i) => {'id': i, 'value': 'value of $i'}),
    );

    for (var i = 0; i < iteration; i++) {
      jsonDecode(jsonData);
    }

    return jsonData;
  }
}

//========> outside the main app
fetchDataIsolate(({int iteration, SendPort sendPort}) data) async {
  final jsonData = jsonEncode(
    List.generate(10000, (i) => {'id': i, 'value': 'value of $i'}),
  );

  for (var i = 1; i <= data.iteration; i++) {
    jsonDecode(jsonData);
    var percentage = (i / data.iteration) * 100;
    if (percentage % 10 == 0) {
      data.sendPort.send(percentage);
    }
  }
}
