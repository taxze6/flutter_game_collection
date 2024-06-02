import 'dart:math';

import 'package:flutter/material.dart';

import '../game_utils.dart';
import '../global_data.dart';
import 'fish.dart';

class EnemyLeft3 extends Fish {
  EnemyLeft3({
    Offset? offset,
    Offset? size,
    double? speed,
  }) : super(
          offset: Offset(-300,
              (Random().nextInt(GlobalData.screenHeight.toInt() - 100) + 100)),
          size: const Offset(300, 300),
          speed: 20,
          score: 3,
          dir: Dir.left,
        );

  @override
  drawFish() {
    return Image.asset(
      GameUtils.enemyLeft3Img,
      width: size?.dx,
      height: size?.dy,
    );
  }

  @override
  Rect getRect() {
    return Rect.fromLTWH(offset!.dx, offset!.dy, size!.dx, size!.dy);
  }
}

class EnemyRight3 extends Fish {
  EnemyRight3({
    Offset? offset,
    Offset? size,
    double? speed,
    double? count,
  }) : super(
          offset: Offset(
            GlobalData.screenWidth,
            (Random().nextInt(GlobalData.screenHeight.toInt() - 100) + 100)
                .toDouble(),
          ),
          size: const Offset(300, 300),
          speed: 20,
          score: 3,
          dir: Dir.right,
        );

  @override
  drawFish() {
    return Image.asset(
      GameUtils.enemyRight3Img,
      width: size?.dx,
      height: size?.dy,
    );
  }

  @override
  Rect getRect() {
    return Rect.fromLTWH(offset!.dx, offset!.dy, size!.dx, size!.dy);
  }
}
