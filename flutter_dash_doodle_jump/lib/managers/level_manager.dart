import 'package:flame/components.dart';
import 'package:flutter_dash_doodle_jump/flutter_dash_doodle_jump.dart';

class Difficulty {
  final double minDistance;
  final double maxDistance;
  final double jumpSpeed;
  final int score;

  const Difficulty({
    required this.minDistance,
    required this.maxDistance,
    required this.jumpSpeed,
    required this.score,
  });
}

class LevelManager extends Component with HasGameRef<FlutterDashDoodleJump> {
  LevelManager({this.selectedLevel = 1, this.level = 1});

  //玩家在一开始选择的难度
  int selectedLevel;

  //游戏中，当前难度
  int level;

  //不同难度的配置,当达到对应分数，则启用对应难度
  final Map<int, Difficulty> levelsConfig = {
    1: const Difficulty(
        minDistance: 200, maxDistance: 300, jumpSpeed: 600, score: 0),
    2: const Difficulty(
        minDistance: 200, maxDistance: 400, jumpSpeed: 650, score: 20),
    3: const Difficulty(
        minDistance: 200, maxDistance: 500, jumpSpeed: 700, score: 40),
    4: const Difficulty(
        minDistance: 200, maxDistance: 600, jumpSpeed: 750, score: 80),
    5: const Difficulty(
        minDistance: 200, maxDistance: 700, jumpSpeed: 800, score: 100),
  };

  double get minDistance {
    return levelsConfig[level]!.minDistance;
  }

  double get maxDistance {
    return levelsConfig[level]!.maxDistance;
  }

  double get jumpSpeed {
    return levelsConfig[level]!.jumpSpeed;
  }

  Difficulty get difficulty {
    return levelsConfig[level]!;
  }

  ///判断是否还能加大难度（最高5级）
  bool shouldLevelUp(int score) {
    int nextLevel = level + 1;

    if (levelsConfig.containsKey(nextLevel)) {
      return levelsConfig[nextLevel]!.score == score;
    }

    return false;
  }

  List<int> get levels {
    return levelsConfig.keys.toList();
  }

  ///难度增加
  void increaseLevel() {
    if (level < levelsConfig.keys.length) {
      level++;
    }
  }

  /// 开始游戏前，设置难度
  void setLevel(int newLevel) {
    if (levelsConfig.containsKey(newLevel)) {
      level = newLevel;
    }
  }

  void selectLevel(int selectLevel) {
    if (levelsConfig.containsKey(selectLevel)) {
      selectedLevel = selectLevel;
    }
  }

  ///重置难度为刚开始的难度
  void reset() {
    level = selectedLevel;
  }
}
