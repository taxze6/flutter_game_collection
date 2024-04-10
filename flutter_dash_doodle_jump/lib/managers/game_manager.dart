import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dash_doodle_jump/flutter_dash_doodle_jump.dart';

enum GameState { menu, playing, gameOver }

class GameManager extends Component with HasGameRef<FlutterDashDoodleJump> {
  GameManager();

  ValueNotifier<int> score = ValueNotifier(0);

  GameState gameState = GameState.menu;

  bool get isPlaying => gameState == GameState.playing;

  bool get isGameOver => gameState == GameState.gameOver;

  bool get isMenu => gameState == GameState.menu;

  ///重置、 初始化
  void reset() {
    score.value = 0;
    gameState = GameState.menu;
  }

  ///增加分数
  void increaseScore() {
    score.value++;
  }
}
