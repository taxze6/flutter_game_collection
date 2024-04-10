import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'flutter_dash_doodle_jump.dart';
import 'pages/game_over_overlay.dart';
import 'pages/game_overlay.dart';
import 'pages/main_menu_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter dash doodle jump',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

final Game game = FlutterDashDoodleJump();

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LayoutBuilder(builder: (context, constraints) {
          return Container(
            constraints: const BoxConstraints(
              maxWidth: 800,
              minWidth: 550,
            ),
            child: GameWidget(
              game: game,
              overlayBuilderMap: <String, Widget Function(BuildContext, Game)>{
                "gameOverlay": (context, game) => GameOverlay(game: game),
                "mainMenuOverlay": (context, game) =>
                    MainMenuOverlay(game: game),
                "gameOverOverlay": (context, game) =>
                    GameOverOverlay(game: game),
              },
            ),
          );
        }),
      ),
    );
  }
}
