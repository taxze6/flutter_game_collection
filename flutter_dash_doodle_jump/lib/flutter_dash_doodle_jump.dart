import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash_doodle_jump/dash/player.dart';
import 'managers/game_manager.dart';
import 'managers/level_manager.dart';
import 'managers/object_manager.dart';
import 'world.dart';

class FlutterDashDoodleJump extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  FlutterDashDoodleJump({super.children});

  late Player player;
  final World _world = World();
  GameManager gameManager = GameManager();
  LevelManager levelManager = LevelManager();
  ObjectManager objectManager = ObjectManager();

  //游戏屏幕缓冲空间
  int screenBufferSpace = 300;

  @override
  Future<void> onLoad() async {
    await add(_world);

    // 添加游戏管理器
    await add(gameManager);

    // 添加暂停按钮和记分器的UI
    overlays.add('gameOverlay');

    // 添加关卡/难度管理器
    await add(levelManager);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameManager.isGameOver) {
      return;
    }
    //只要菜单打开，游戏就不会更新了
    if (gameManager.isMenu) {
      overlays.add('mainMenuOverlay');
      return;
    }

    if (gameManager.isPlaying) {
      final Rect worldBounds = Rect.fromLTRB(
        0,
        camera.position.y - screenBufferSpace,
        camera.gameSize.x,
        camera.position.y + _world.size.y,
      );
      camera.worldBounds = worldBounds;

      checkLevelUp();

      if (player.isMovingDown) {
        camera.worldBounds = Rect.fromLTRB(
          0,
          camera.position.y - screenBufferSpace,
          camera.gameSize.x,
          camera.position.y + _world.size.y,
        );
      }

      //相机位置只在Dash向上的时候跟踪，如果掉下来了，相机位置停在原地
      var isInTopHalfOfScreen = player.position.y <= (_world.size.y / 2);
      if (!player.isMovingDown && isInTopHalfOfScreen) {
        camera.followComponent(player);
      }

      // 如果Dash从屏幕上掉下来，游戏就结束了
      if (player.position.y >
          camera.position.y +
              _world.size.y +
              player.size.y +
              screenBufferSpace) {
        onLose();
      }
    }
  }

  ///开始游戏
  void startGame() {
    addPlayer();
    initializeGameStart();
    gameManager.gameState = GameState.playing;
    overlays.remove('mainMenuOverlay');
  }

  void addPlayer() {
    player = Player();
    player.setJumpSpeed(levelManager.jumpSpeed);
    add(player);
  }

  ///再来一次
  void resetGame() {
    startGame();
    overlays.remove('gameOverOverlay');
  }

  ///回到主页面
  void backMenu() {
    overlays.remove('gameOverOverlay');
    overlays.add('mainMenuOverlay');
  }


  void initializeGameStart() {
    //重新计分
    gameManager.reset();

    if (children.contains(objectManager)) objectManager.removeFromParent();

    levelManager.reset();
    player.reset();

    // 设置摄像机的世界边界将允许摄像机“向上移动”
    // 但要保持水平固定，这样Dash就可以从屏幕的一边走出去，然后在另一边重新出现。
    camera.worldBounds = Rect.fromLTRB(
      0,
      -_world.size.y,
      camera.gameSize.x,
      _world.size.y + screenBufferSpace, // 确保游戏的底部边界低于屏幕底部
    );
    camera.followComponent(player);

    player.position = Vector2(
      (_world.size.x - player.size.x) / 2,
      (_world.size.y - player.size.y) / 2,
    );

    objectManager = ObjectManager(
        minVerticalDistanceToNextPlatform: levelManager.minDistance,
        maxVerticalDistanceToNextPlatform: levelManager.maxDistance);

    add(objectManager);

    objectManager.configure(levelManager.level, levelManager.difficulty);
  }

  //Dash嗝屁了
  void onLose() {
    gameManager.gameState = GameState.gameOver;
    player.removeFromParent();
    overlays.add('gameOverOverlay');
  }

  void togglePauseState() {
    if (paused) {
      resumeEngine();
    } else {
      pauseEngine();
    }
  }

  void checkLevelUp() {
    if (levelManager.shouldLevelUp(gameManager.score.value)) {
      levelManager.increaseLevel();

      // 更改难度配置
      objectManager.configure(levelManager.level, levelManager.difficulty);

      // 改变Dash跳跃速度
      player.setJumpSpeed(levelManager.jumpSpeed);
    }
  }
}
