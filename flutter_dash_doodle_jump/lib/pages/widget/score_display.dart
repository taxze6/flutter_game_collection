import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash_doodle_jump/flutter_dash_doodle_jump.dart';

class ScoreDisplay extends StatelessWidget {
  const ScoreDisplay({super.key, required this.game, this.isLight = false});

  final Game game;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: (game as FlutterDashDoodleJump).gameManager.score,
      builder: (context, value, child) {
        return Text('Score: $value',
            style: Theme.of(context).textTheme.displaySmall!);
      },
    );
  }
}
