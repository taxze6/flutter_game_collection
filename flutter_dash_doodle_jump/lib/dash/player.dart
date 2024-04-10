import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dash_doodle_jump/dash/platform.dart';
import 'package:flutter_dash_doodle_jump/flutter_dash_doodle_jump.dart';

import 'power_up.dart';

enum PlayerState { left, right, center, rocket, hatCenter, hatLeft, hatRight }

class Player extends SpriteGroupComponent<PlayerState>
    with
        HasGameRef<FlutterDashDoodleJump>,
        KeyboardHandler,
        CollisionCallbacks {
  Player({super.position, this.jumpSpeed = 600})
      : super(size: Vector2(79, 109), anchor: Anchor.center, priority: 1);

  Vector2 velocity = Vector2.zero();

  // 用于计算用户是向左(-1)还是向右(1)移动Dash;
  // 当向左移动时，x轴速度乘以-1，得到一个负数;
  // x轴上的数字从左向右增加，因此负数向左移动;
  // 当向右移动时，结果将是一个正数;
  // 如果数字是0，Dash是垂直移动的。
  int hAxisInput = 0;
  final int movingLeftInput = -1;
  final int movingRightInput = 1;

  //用于计算水平移动速度
  final double gravity = 9;

  //垂直速度
  double jumpSpeed;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(CircleHitbox());
    await _loadDashAssets();
    current = PlayerState.center;
  }

  @override
  void update(double dt) {
    //判断是否是游戏中状态
    if (gameRef.gameManager.isMenu || gameRef.gameManager.isGameOver) return;
    final double dashHorizontalCenter = size.x / 2;
    //Dash的水平速度
    velocity.x = hAxisInput * jumpSpeed;
    //Dash的垂直速度
    velocity.y += gravity;
    // 如果Dash不在屏幕上(位置从中心开始)，则无限边界线。（从另一侧出现）
    if (position.x < dashHorizontalCenter) {
      position.x = gameRef.size.x - (dashHorizontalCenter);
    }
    if (position.x > gameRef.size.x - (dashHorizontalCenter)) {
      position.x = dashHorizontalCenter;
    }

    //Dash的速度除以经过的时间
    //计算当前位置
    position += velocity * dt;
    super.update(dt);
  }

  //重置
  void reset() {
    velocity = Vector2.zero();
    current = PlayerState.center;
  }

  bool get isMovingDown => velocity.y > 0;

  //吃到了道具(火箭和起飞帽子)
  bool get hasPowerUp =>
      current == PlayerState.rocket ||
      current == PlayerState.hatLeft ||
      current == PlayerState.hatRight ||
      current == PlayerState.hatCenter;

  //处于无敌状态(在火箭里)
  bool get isInvincible => current == PlayerState.rocket;

  //是否戴着帽子(处于起飞状态)
  bool get isWearingHat =>
      current == PlayerState.hatLeft ||
      current == PlayerState.hatRight ||
      current == PlayerState.hatCenter;

  //当方向键被按下时，改变Dash的移动方向
  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    //默认情况下不向左或向右
    hAxisInput = 0;

    // 向左移动
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      if (isWearingHat) {
        current = PlayerState.hatLeft;
      } else if (!hasPowerUp) {
        current = PlayerState.left;
      }
      hAxisInput += movingLeftInput;
    }

    // 向右移动
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      if (isWearingHat) {
        current = PlayerState.hatRight;
      } else if (!hasPowerUp) {
        current = PlayerState.right;
      }
      hAxisInput += movingRightInput;
    }

    // 外挂，一直跳
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      jump();
    }

    return true;
  }

  //Dash与游戏中另一个组件碰撞的回调
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    //碰到敌人且不是无敌状态，直接嗝屁
    if (other is EnemyPlatform && !isInvincible) {
      gameRef.onLose();
      return;
    }

    //计算碰撞点的垂直差值，是否小于5
    bool isCollidingVertically =
        (intersectionPoints.first.y - intersectionPoints.last.y).abs() < 5;
    bool enablePowerUp = false;
    //是否可以激活道具
    if (!hasPowerUp && (other is Rocket || other is Hat)) {
      enablePowerUp = true;
    }

    //如果玩家正在向下移动且发生了垂直碰撞，根据碰撞的对象类型，执行相应的操作。
    if (isMovingDown && isCollidingVertically) {
      current = PlayerState.center;
      //普通平台
      if (other is NormalPlatform) {
        jump();
        return;
      }
      //弹簧板
      else if (other is SpringBoard) {
        jump(specialJumpSpeed: jumpSpeed * 2);
        return;
      }
      //起飞
      else if (other is BrokenPlatform &&
          other.current == BrokenPlatformState.cracked) {
        jump();
        other.breakPlatform();
        return;
      }

      if (other is Rocket || other is Hat) {
        enablePowerUp = true;
      }
    }

    if (!enablePowerUp) return;

    if (other is Rocket) {
      current = PlayerState.rocket;
      //基础跳跃速度 jumpSpeed 乘以火箭的跳跃速度倍数 other.jumpSpeedMultiplier
      jump(specialJumpSpeed: jumpSpeed * other.jumpSpeedMultiplier);
      return;
    } else if (other is Hat) {
      //根据Dash的当前位置，判断要显示的图标
      if (current == PlayerState.center) current = PlayerState.hatCenter;
      if (current == PlayerState.left) current = PlayerState.hatLeft;
      if (current == PlayerState.right) current = PlayerState.hatRight;
      removePowerUpAfterTime(other.activeLengthInMS);
      jump(specialJumpSpeed: jumpSpeed * other.jumpSpeedMultiplier);
      return;
    }
  }

  void jump({double? specialJumpSpeed}) {
    //因为左上角是(0,0)，所以向上是负的
    velocity.y = specialJumpSpeed != null ? -specialJumpSpeed : -jumpSpeed;
  }

  void removePowerUpAfterTime(int ms) {
    Future.delayed(Duration(milliseconds: ms), () {
      current = PlayerState.center;
    });
  }

  void setJumpSpeed(double newJumpSpeed) {
    jumpSpeed = newJumpSpeed;
  }

  ///加载静态资源
  Future<void> _loadDashAssets() async {
    final left = await gameRef.loadSprite('game/dash_left.png');
    final right = await gameRef.loadSprite('game/dash_right.png');
    final center = await gameRef.loadSprite('game/dash_center.png');
    final rocket = await gameRef.loadSprite('game/rocket_4.png');
    final hatCenter = await gameRef.loadSprite('game/dash_hat_center.png');
    final hatLeft = await gameRef.loadSprite('game/dash_hat_left.png');
    final hatRight = await gameRef.loadSprite('game/dash_hat_right.png');

    sprites = <PlayerState, Sprite>{
      PlayerState.left: left,
      PlayerState.right: right,
      PlayerState.center: center,
      PlayerState.rocket: rocket,
      PlayerState.hatCenter: hatCenter,
      PlayerState.hatLeft: hatLeft,
      PlayerState.hatRight: hatRight,
    };
  }
}
