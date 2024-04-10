import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash_doodle_jump/flutter_dash_doodle_jump.dart';

import 'main_menu_overlay.dart';
import 'widget/score_display.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child:
                  Image.asset("assets/images/game/background/background.png",fit: BoxFit.cover,),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Game Over',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        fontFamily: "DaveysDoodleface",
                      ),
                    ),
                    const WhiteSpace(height: 50),
                    ScoreDisplay(
                      game: game,
                      isLight: true,
                    ),
                    const WhiteSpace(
                      height: 50,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        (game as FlutterDashDoodleJump).resetGame();
                      },
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(
                          const Size(200, 75),
                        ),
                        textStyle: MaterialStateProperty.all(
                            Theme.of(context).textTheme.titleLarge),
                      ),
                      child: const Text('再来一次'),
                    ),
                    const WhiteSpace(
                      height: 50,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        (game as FlutterDashDoodleJump).backMenu();
                      },
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(
                          const Size(200, 75),
                        ),
                        textStyle: MaterialStateProperty.all(
                            Theme.of(context).textTheme.titleLarge),
                      ),
                      child: const Text('回到主页面'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
