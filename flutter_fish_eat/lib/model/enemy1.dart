import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fish_eat/global_data.dart';

import '../game_utils.dart';
import 'fish.dart';

class EnemyLeft1 extends Fish {
  EnemyLeft1({
    Offset? offset,
    Offset? size,
    double? speed,
  }) : super(
          offset: Offset(-45,
              (Random().nextInt(GlobalData.screenHeight.toInt() - 100) + 100)),
          size: const Offset(45, 69),
          speed: 10,
          score: 1,
          dir: Dir.left,
        );

  @override
  drawFish() {
    return Image.asset(
      GameUtils.enemyLeft1Img,
      width: size?.dx,
      height: size?.dy,
    );
  }

  @override
  Rect getRect() {
    return Rect.fromLTWH(offset!.dx, offset!.dy, size!.dx, size!.dy);
  }
}

class EnemyRight1 extends Fish {
  EnemyRight1({
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
          size: const Offset(45, 69),
          speed: 10,
          score: 1,
          dir: Dir.right,
        );

  @override
  drawFish() {
    return Image.asset(
      GameUtils.enemyRight1Img,
      width: size?.dx,
      height: size?.dy,
    );
  }

  @override
  Rect getRect() {
    return Rect.fromLTWH(offset!.dx, offset!.dy, size!.dx, size!.dy);
  }
}
