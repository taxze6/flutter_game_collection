import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fish_eat/game_utils.dart';
import 'package:flutter_fish_eat/global_data.dart';
import 'package:flutter_fish_eat/model/boss.dart';
import 'package:flutter_fish_eat/model/enemy1.dart';
import 'package:flutter_fish_eat/model/enemy2.dart';
import 'package:flutter_fish_eat/model/my_fish.dart';

import 'model/enemy3.dart';
import 'model/fish.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late HardwareKeyboard hardwareKeyboard;
  GameState gameState = GameState.notStart;
  bool isBoss = false;
  MyFish? myFish;
  Timer? _timer;

  int refreshCount = 0;

  void startGame() {
    myFish = MyFish();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      controllerMyFish();
      // 每次刷新增加计数器
      refreshCount++;
      logic();
      setState(() {});
    });
  }

  double acceleration = 0.2; // 加速度
  double currentSpeed = 0.0; // 当前速度
  void controllerMyFish() {
    double fishWidth = myFish!.size!.dx;
    double fishHeight = myFish!.size!.dy;

    if (GameUtils.up) {
      currentSpeed = (currentSpeed + acceleration).clamp(-10, 10);
      double newY = myFish!.offset!.dy - currentSpeed;
      if (newY >= 0 && newY + fishHeight <= GlobalData.screenHeight) {
        myFish!.offset = Offset(myFish!.offset!.dx, newY);
      } else {
        // 边界碰撞时反弹
        currentSpeed = -currentSpeed * 0.5; // 反弹并减速
      }
    }
    if (GameUtils.down) {
      currentSpeed = (currentSpeed - acceleration).clamp(-10, 10);
      double newY = myFish!.offset!.dy + currentSpeed;
      if (newY >= 0 && newY + fishHeight <= GlobalData.screenHeight) {
        myFish!.offset = Offset(myFish!.offset!.dx, newY);
      } else {
        currentSpeed = -currentSpeed * 0.5; // 边界碰撞时反弹
      }
    }
    if (GameUtils.left) {
      currentSpeed = currentSpeed.clamp(-10.0, 10.0);
      currentSpeed -= acceleration;
      myFish!.img = GameUtils.myFishLeftImg;
      double newX = myFish!.offset!.dx + currentSpeed;
      if (newX >= 0 && newX + fishWidth <= GlobalData.screenWidth) {
        myFish!.offset = Offset(newX, myFish!.offset!.dy);
      } else {
        currentSpeed = -currentSpeed * 0.5; // 边界碰撞时反弹
      }
    }
    if (GameUtils.right) {
      currentSpeed = currentSpeed.clamp(-10.0, 10.0);
      currentSpeed += acceleration;
      myFish!.img = GameUtils.myFishRightImg;
      double newX = myFish!.offset!.dx + currentSpeed;
      if (newX >= 0 && newX + fishWidth <= GlobalData.screenWidth) {
        myFish!.offset = Offset(newX, myFish!.offset!.dy);
      } else {
        currentSpeed = -currentSpeed * 0.5; // 边界碰撞时反弹
      }
    }

    if (!GameUtils.up &&
        !GameUtils.down &&
        !GameUtils.left &&
        !GameUtils.right) {
      if (currentSpeed > 0) {
        currentSpeed = (currentSpeed - acceleration).clamp(0.0, 10.0);
      } else if (currentSpeed < 0) {
        currentSpeed = (currentSpeed + acceleration).clamp(-10.0, 0.0);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    hardwareKeyboard = HardwareKeyboard.instance;
    hardwareKeyboard.addHandler((event) {
      _handleKeyEvent(event);
      return true;
    });
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    GameUtils.bgImg,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "分数：${GameUtils.score}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              top: myFish!.offset?.dy,
              left: myFish!.offset?.dx,
              child: myFish!.drawFish(),
            ),
            for (var i in GameUtils.enemyList)
              Positioned(
                top: i.offset?.dy,
                left: i.offset?.dx,
                child: i.drawFish(),
              ),
          ],
        ),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event.toStringShort().contains("KeyDownEvent")) {
      _handleKeyDown(event.logicalKey.keyLabel);
    } else if (event.toStringShort().contains("KeyUpEvent")) {
      _handleKeyUp(event.logicalKey.keyLabel);
    }
  }

  void _handleKeyDown(String key) {
    switch (key) {
      case "W":
        GameUtils.up = true;
        break;
      case "A":
        GameUtils.left = true;
        break;
      case "S":
        GameUtils.down = true;
        break;
      case "D":
        GameUtils.right = true;
        break;
      case "":
        print('space key pressed');
        break;
      default:
        break;
    }
  }

  void _handleKeyUp(String key) {
    switch (key) {
      case "W":
        GameUtils.up = false;
        break;
      case "A":
        GameUtils.left = false;
        break;
      case "S":
        GameUtils.down = false;
        break;
      case "D":
        GameUtils.right = false;
        break;
      case "":
        print('space key pressed');
        break;
      default:
        break;
    }
  }

  void logic() {
    if (GameUtils.score < 15) {
      GameUtils.level = 0;
      myFish?.level = 1;
    } else if (GameUtils.score <= 50) {
      GameUtils.level = 1;
    } else if (GameUtils.score <= 150) {
      GameUtils.level = 2;
      myFish?.level = 2;
    } else if (GameUtils.score <= 300) {
      GameUtils.level = 3;
      myFish?.level = 3;
    } else {
      //分数大于300，玩家胜利
      gameState = GameState.success;
    }
    double random = Random().nextDouble();
    switch (GameUtils.level) {
      case 4:
      case 3:
        Fish enemy = EnemyBoss();
        GameUtils.enemyList.add(enemy);
      case 2:
        if (refreshCount % 30 == 0) {
          Fish enemy;
          if (random > 0.5) {
            enemy = EnemyLeft3();
          } else {
            enemy = EnemyRight3();
          }
          GameUtils.enemyList.add(enemy);
        }
      case 1:
        if (refreshCount % 20 == 0) {
          Fish enemy;
          if (random > 0.5) {
            enemy = EnemyLeft2();
          } else {
            enemy = EnemyRight2();
          }
          GameUtils.enemyList.add(enemy);
        }
      case 0:
        //每重绘10次生成一条敌方鱼类
        if (refreshCount % 10 == 0) {
          Fish enemy;
          if (random > 0.5) {
            enemy = EnemyLeft1();
          } else {
            enemy = EnemyRight1();
          }
          GameUtils.enemyList.add(enemy);
        }
        break;
      default:
        break;
    }

    //移动方向
    for (var enemy in GameUtils.enemyList) {
      enemy.offset = Offset(
          (enemy.offset?.dx ?? 0) +
              (dirData(enemy.dir) *
                  num.parse(
                    enemy.speed.toString(),
                  )),
          enemy.offset?.dy ?? 0);

      //我方鱼与敌方鱼的碰撞检测
      if (myFish!.getRect().overlaps(enemy.getRect())) {
        GameUtils.enemyList.remove(enemy);
        GameUtils.score += enemy.score!;
      }
      if (enemy.dir == Dir.left) {
        if (enemy.offset!.dx > (GlobalData.screenWidth + enemy.size!.dx)) {
          GameUtils.enemyList.remove(enemy);
        }
      } else if (enemy.dir == Dir.right) {
        if (enemy.offset!.dx < -enemy.size!.dx) {
          GameUtils.enemyList.remove(enemy);
        }
      }
    }
  }
}
