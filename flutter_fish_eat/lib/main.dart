import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fish_eat/game_page.dart';

import 'global_data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //设置为横向左右方向
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    GlobalData.screenWidth = MediaQuery.of(context).size.width;
    GlobalData.screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      title: 'Flutter Fish Eat Fish',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: GamePage(),
    );
  }
}
