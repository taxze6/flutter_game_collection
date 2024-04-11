import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dash_doodle_jump/flutter_dash_doodle_jump.dart';

abstract class Platform<T> extends SpriteGroupComponent<T>
    with HasGameRef<FlutterDashDoodleJump>, CollisionCallbacks {
  final hitBox = RectangleHitbox();

  bool isMoving = false;

  Platform({
    super.position,
  }) : super(
          size: Vector2.all(100),
          // 确保平台始终在Dash的后面
          priority: 2,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 添加碰撞监测
    await add(hitBox);

    // 这个平台是否会移动（大于80，代表20%的概率移动）
    final int rand = Random().nextInt(100);
    if (rand > 80) isMoving = true;
  }

  double direction = 1;
  final Vector2 velocity = Vector2.zero();

  //移动速度
  double speed = 35;

  void move(double deltaTime) {
    if (!isMoving) return;

    //获取游戏场景的宽度
    final double gameWidth = gameRef.size.x;

    // 根据平台的位置来确定移动的方向。
    // 如果平台的 x 坐标小于等于 0，说明平台到达了左边界，将 direction 设置为 1，表示向右移动；
    // 如果平台的 x 坐标大于等于游戏宽度减去平台宽度，说明平台到达了右边界，将 direction 设置为 -1，表示向左移动。
    if (position.x <= 0) {
      direction = 1;
    } else if (position.x >= gameWidth - size.x) {
      direction = -1;
    }

    velocity.x = direction * speed;

    position += velocity * deltaTime;
  }

  @mustCallSuper //这个注解是 Dart 语言中的一个元数据注解（metadata annotation），用于标记方法，表示子类在覆盖这个方法时必须调用父类的同名方法。在这里，@mustCallSuper 注解告诉子类在覆盖 update 方法时必须调用父类的 update 方法。
  @override
  void update(double dt) {
    move(dt);
    //确保调用父类的 update 方法
    super.update(dt);
  }
}

///默认的普通平台（方块）
enum NormalPlatformState { only }

class NormalPlatform extends Platform<NormalPlatformState> {
  NormalPlatform({super.position});

  final Map<String, Vector2> spriteOptions = {
    'platform1': Vector2(106, 52),
    'platform2': Vector2(106, 52),
    'platform3': Vector2(106, 52),
    'platform4': Vector2(106, 52),
  };

  @override
  Future<void> onLoad() async {
    var randSpriteIndex = Random().nextInt(spriteOptions.length);

    String randSprite = spriteOptions.keys.elementAt(randSpriteIndex);

    sprites = {
      NormalPlatformState.only: await gameRef.loadSprite('game/$randSprite.png')
    };

    current = NormalPlatformState.only;

    size = spriteOptions[randSprite]!;
    await super.onLoad();
  }
}

///只能跳一下的会破碎的平台
enum BrokenPlatformState { cracked, broken }

class BrokenPlatform extends Platform<BrokenPlatformState> {
  BrokenPlatform({super.position});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprites = <BrokenPlatformState, Sprite>{
      BrokenPlatformState.cracked:
          await gameRef.loadSprite('game/platform_cracked_monitor.png'),
      BrokenPlatformState.broken:
          await gameRef.loadSprite('game/platform_monitor_broken.png'),
    };

    current = BrokenPlatformState.cracked;
    size = Vector2(113, 48);
  }

  void breakPlatform() {
    current = BrokenPlatformState.broken;
  }
}

///弹簧床
enum SpringState { down, up }

class SpringBoard extends Platform<SpringState> {
  SpringBoard({
    super.position,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprites = <SpringState, Sprite>{
      SpringState.down:
          await gameRef.loadSprite('game/platform_trampoline_down.png'),
      SpringState.up:
          await gameRef.loadSprite('game/platform_trampoline_up.png'),
    };

    current = SpringState.up;

    size = Vector2(100, 45);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    //通过计算交点的垂直差值，判断是否发生垂直碰撞、
    //如果垂直差值小于 5，则将当前状态 current 设置为 SpringState.down，表示向下弹簧状态
    bool isCollidingVertically =
        (intersectionPoints.first.y - intersectionPoints.last.y).abs() < 5;

    if (isCollidingVertically) {
      current = SpringState.down;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    //这个方法在碰撞结束时被调用。
    //首先调用super.onCollisionEnd(other)，以确保调用父类的碰撞结束方法。
    //然后，将当前状态 current 设置为 SpringState.up，表示向上弹簧状态。
    super.onCollisionEnd(other);

    current = SpringState.up;
  }
}

///敌人
enum EnemyPlatformState { only }

class EnemyPlatform extends Platform<EnemyPlatformState> {
  EnemyPlatform({super.position});

  @override
  Future<void> onLoad() async {
    var randBool = Random().nextBool();
    var enemySprite = randBool ? 'enemy_heart' : 'enemy_e';

    sprites = <EnemyPlatformState, Sprite>{
      EnemyPlatformState.only:
          await gameRef.loadSprite('game/$enemySprite.png'),
    };

    current = EnemyPlatformState.only;

    if (enemySprite == "enemy_heart") {
      size = Vector2(100, 45);
    } else {
      //雷电
      size = Vector2(100, 32);
    }
    return super.onLoad();
  }
}
