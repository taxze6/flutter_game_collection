import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter_dash_doodle_jump/flutter_dash_doodle_jump.dart';

import '../dash/platform.dart';
import '../dash/power_up.dart';
import '../utils/num_utils.dart';
import 'level_manager.dart';

final Random random = Random();

class ObjectManager extends Component with HasGameRef<FlutterDashDoodleJump> {
  ObjectManager({
    this.minVerticalDistanceToNextPlatform = 200,
    this.maxVerticalDistanceToNextPlatform = 300,
  });

  //到下一个平台的最小垂直距离
  double minVerticalDistanceToNextPlatform;

  //到下一个平台的最大垂直距离
  double maxVerticalDistanceToNextPlatform;

  final probGen = ProbabilityGenerator();

  //存放Dash可以踩的平台
  final List<Platform> platforms = [];

  final List<PowerUp> powerUps = [];

  final List<EnemyPlatform> enemies = [];

  //平台的高度
  final double tallestPlatformHeight = 50;

  //对应关卡出现的道具
  final Map<String, bool> specialPlatforms = {
    'spring': true, // level 1
    'broken': false, // level 2
    'hat': false, // level 3
    'rocket': false, // level 4
    'enemy': false, // level 5
  };

  @override
  void onMount() {
    super.onMount();
    var currentX = (gameRef.size.x.floor() / 2).toDouble() - 50;
    //第一个平台总是在初始屏幕的底部三分之一处
    var currentY =
        gameRef.size.y - (random.nextInt(gameRef.size.y.floor()) / 3) - 50;

    //生成10个随机x, y位置的平台，并添加到平台列表。
    for (var i = 0; i < 9; i++) {
      if (i != 0) {
        currentX = _generateNextX(100);
        currentY = _generateNextY();
      }
      platforms.add(
        _semiRandomPlatform(
          Vector2(
            currentX,
            currentY,
          ),
        ),
      );

      // Add Component to Flame tree
      add(platforms[i]);
    }
  }

  @override
  void update(double dt) {
    //增加平台高度可以确保两个平台不会重叠。
    final topOfLowestPlatform =
        platforms.first.position.y + tallestPlatformHeight;
    final screenBottom = gameRef.player.position.y +
        (gameRef.size.x / 2) +
        gameRef.screenBufferSpace;

    //当平台往下移动离开屏幕时，可以将其移除并放置一个新平台
    if (topOfLowestPlatform > screenBottom) {
      // 生成一个新跳板
      var newPlatformX = _generateNextX(100);
      var newPlatformY = _generateNextY();
      final nextPlatform =
          _semiRandomPlatform(Vector2(newPlatformX, newPlatformY));
      add(nextPlatform);
      platforms.add(nextPlatform);
      //移除屏幕外的平台
      final lowestPlat = platforms.removeAt(0);
      lowestPlat.removeFromParent();
      //增加分数，移除一个屏幕加一分
      gameRef.gameManager.increaseScore();
      _maybeAddPowerUp();
      _maybeAddEnemy();
    }
    super.update(dt);
  }

  // 在游戏中改变难度
  void configure(int nextLevel, Difficulty config) {
    minVerticalDistanceToNextPlatform = gameRef.levelManager.minDistance;
    maxVerticalDistanceToNextPlatform = gameRef.levelManager.maxDistance;

    for (int i = 1; i <= nextLevel; i++) {
      enableLevelSpecialty(i);
    }
  }

  void enableLevelSpecialty(int level) {
    switch (level) {
      case 1:
        enableSpecialty('spring');
        break;
      case 2:
        enableSpecialty('broken');
        break;
      case 3:
        enableSpecialty('hat');
        break;
      case 4:
        enableSpecialty('rocket');
        break;
      case 5:
        enableSpecialty('enemy');
        break;
    }
  }

  void enableSpecialty(String specialty) {
    specialPlatforms[specialty] = true;
  }

  double _generateNextX(int platformWidth) {
    // 确保下一个平台不会重叠
    final previousPlatformXRange = Range(
      platforms.last.position.x,
      platforms.last.position.x + platformWidth,
    );

    double nextPlatformAnchorX;

    // 如果前一个平台和下一个平台重叠，尝试一个新的随机X
    do {
      nextPlatformAnchorX =
          random.nextInt(gameRef.size.x.floor() - platformWidth).toDouble();
    } while (previousPlatformXRange.overlaps(
        Range(nextPlatformAnchorX, nextPlatformAnchorX + platformWidth)));

    return nextPlatformAnchorX;
  }

  // 用于确定下一个平台应该放置的位置
  // 它返回minVerticalDistanceToNextPlatform和maxVerticalDistanceToNextPlatform之间的随机距离
  double _generateNextY() {
    // 添加platformHeight可以防止平台重叠。
    final currentHighestPlatformY =
        platforms.last.center.y + tallestPlatformHeight;

    final distanceToNextY = minVerticalDistanceToNextPlatform.toInt() +
        random
            .nextInt((maxVerticalDistanceToNextPlatform -
                    minVerticalDistanceToNextPlatform)
                .floor())
            .toDouble();

    return currentHighestPlatformY - distanceToNextY;
  }

  // 返回随机类型的平台
  // 各类平台出现的概率都是不同的
  Platform _semiRandomPlatform(Vector2 position) {
    if (specialPlatforms['spring'] == true &&
        probGen.generateWithProbability(15)) {
      // 15%的机会得到跳板
      return SpringBoard(position: position);
    }

    if (specialPlatforms['broken'] == true &&
        probGen.generateWithProbability(10)) {
      // 10%的机会出现只能跳一次的平台
      return BrokenPlatform(position: position);
    }

    // 默认为普通平台
    return NormalPlatform(position: position);
  }

  void _maybeAddPowerUp() {
    //20%的概率出现起飞魔法帽
    if (specialPlatforms['hat'] == true &&
        probGen.generateWithProbability(20)) {
      // 生成起飞道具
      var hat = Hat(
        position: Vector2(_generateNextX(75), _generateNextY()),
      );
      add(hat);
      powerUps.add(hat);
      return;
    }

    // 15%的概率出现火箭
    if (specialPlatforms['rocket'] == true &&
        probGen.generateWithProbability(15)) {
      var rocket = Rocket(
        position: Vector2(_generateNextX(50), _generateNextY()),
      );
      add(rocket);
      powerUps.add(rocket);
    }
  }

  void _maybeAddEnemy() {
    // 判断有没有到能生成怪物的游戏难度
    if (specialPlatforms['enemy'] != true) {
      return;
    }
    if (probGen.generateWithProbability(20)) {
      var enemy = EnemyPlatform(
        position: Vector2(_generateNextX(100), _generateNextY()),
      );
      add(enemy);
      enemies.add(enemy);
      _cleanup();
    }
  }

  //删除道具（此处可优化）
  //因为道具和敌人的生成依赖于概率，不存在将它们从游戏中移除的最佳时机。
  //所以需要定期检查是否有可以移除的。
  void _cleanup() {
    final screenBottom = gameRef.player.position.y +
        (gameRef.size.x / 2) +
        gameRef.screenBufferSpace;

    while (enemies.isNotEmpty && enemies.first.position.y > screenBottom) {
      remove(enemies.first);
      enemies.removeAt(0);
    }

    while (powerUps.isNotEmpty && powerUps.first.position.y > screenBottom) {
      if (powerUps.first.parent != null) {
        remove(powerUps.first);
      }
      powerUps.removeAt(0);
    }
  }
}
