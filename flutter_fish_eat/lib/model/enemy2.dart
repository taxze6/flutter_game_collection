import 'dart:math';

import 'package:flutter/material.dart';

import '../game_utils.dart';
import '../global_data.dart';
import 'fish.dart';

class EnemyLeft2 extends Fish {
  EnemyLeft2({
    Offset? offset,
    Offset? size,
    double? speed,
  }) : super(
          offset: Offset(
              -100,
              (Random()
                  .nextInt(GlobalData.screenHeight.toInt() - 100)
                  .toDouble())),
          size: const Offset(100, 100),
          speed: 5,
          score: 2,
          dir: Dir.left,
        );

  @override
  drawFish() {
    return Image.asset(
      GameUtils.enemyLeft2Img,
      width: size?.dx,
      height: size?.dy,
    );
  }

  @override
  Rect getRect() {
    return Rect.fromLTWH(offset!.dx, offset!.dy, size!.dx, size!.dy);
  }
}

class EnemyRight2 extends Fish {
  EnemyRight2({
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
          size: const Offset(100, 100),
          speed: 5,
          score: 2,
          dir: Dir.right,
        );

  @override
  drawFish() {
    return Image.asset(
      GameUtils.enemyRight2Img,
      width: size?.dx,
      height: size?.dy,
    );
  }

  @override
  Rect getRect() {
    return Rect.fromLTWH(offset!.dx, offset!.dy, size!.dx, size!.dy);
  }
}
