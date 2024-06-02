import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fish_eat/model/fish.dart';

import '../game_utils.dart';
import '../global_data.dart';

class EnemyBoss extends Fish{
  EnemyBoss({
    Offset? offset,
    Offset? size,
    double? speed,
  }) : super(
    offset: Offset(-200,
        (Random().nextInt(GlobalData.screenHeight.toInt() - 100) + 100)),
    size: const Offset(200, 200),
    speed: 80,
    score: 0,
    dir: Dir.left,
  );

  @override
  drawFish() {
    return Image.asset(
      GameUtils.bossImg,
      width: size?.dx,
      height: size?.dy,
    );
  }

  @override
  Rect getRect() {
    return Rect.fromLTWH(offset!.dx, offset!.dy, size!.dx, size!.dy);
  }
}