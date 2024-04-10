import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash_doodle_jump/flutter_dash_doodle_jump.dart';

import 'widget/score_display.dart';

class GameOverlay extends StatefulWidget {
  const GameOverlay({super.key, required this.game});

  final Game game;

  @override
  State<GameOverlay> createState() => _GameOverlayState();
}

class _GameOverlayState extends State<GameOverlay> {
  bool isPaused = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned(
            top: 30,
            left: 30,
            child: ScoreDisplay(game: widget.game),
          ),
          Positioned(
            top: 30,
            right: 30,
            child: ElevatedButton(
              child: isPaused
                  ? const Icon(
                      Icons.play_arrow,
                      size: 48,
                    )
                  : const Icon(
                      Icons.pause,
                      size: 48,
                    ),
              onPressed: () {
                (widget.game as FlutterDashDoodleJump).togglePauseState();
                setState(
                  () {
                    isPaused = !isPaused;
                  },
                );
              },
            ),
          ),
          if (isPaused)
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 72.0,
              right: MediaQuery.of(context).size.width / 2 - 72.0,
              child: const Icon(
                Icons.pause_circle,
                size: 144.0,
                color: Colors.black12,
              ),
            ),
        ],
      ),
    );
  }
}
