import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_dash_doodle_jump/dash/player.dart';
import 'package:flutter_dash_doodle_jump/flutter_dash_doodle_jump.dart';

abstract class PowerUp extends SpriteComponent
    with HasGameRef<FlutterDashDoodleJump>, CollisionCallbacks {
  PowerUp({
    super.position,
  }) : super(
          size: Vector2.all(50),
          priority: 2,
        );
  final hitBox = RectangleHitbox();

  double get jumpSpeedMultiplier;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    // 添加碰撞检测逻辑
    await add(hitBox);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && !other.isInvincible && !other.isWearingHat) {
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }
}

///火箭
class Rocket extends PowerUp {
  @override
  double get jumpSpeedMultiplier => 3.5;

  Rocket({
    super.position,
  });

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('game/rocket.png');
    size = Vector2(50, 70);
  }
}

///起飞魔法帽
class Hat extends PowerUp {
  @override
  double get jumpSpeedMultiplier => 2.5;

  Hat({
    super.position,
  });

  final int activeLengthInMS = 5000;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('game/hat.png');
    size = Vector2(75, 50);
  }
}
