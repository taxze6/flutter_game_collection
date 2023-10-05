import 'package:flutter/material.dart';

import 'game_main.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GomokuAI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameMainPage(),
    );
  }
}