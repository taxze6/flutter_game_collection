import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fish_eat/global_data.dart';
import 'package:flutter_fish_eat/model/fish.dart';

import '../game_utils.dart';

class MyFish extends Fish {
  int level;

  String? img;

  MyFish({
    this.level = 1,
    this.img = GameUtils.myFishLeftImg,
    Offset? offset,
    Offset? size,
    double? speed,
    double? count,
  }) : super(
          offset: Offset(
            (GlobalData.screenWidth / 2) - 25,
            (GlobalData.screenHeight / 2) - 25,
          ),
          size: const Offset(50, 50),
          speed: 20,
          score: 3,
          dir: Dir.right,
        );

  @override
  drawFish() {
    return Image.asset(
      img!,
      width: size!.dx * level,
      height: size!.dy * level,
    );
  }

  @override
  Rect getRect() {
    return Rect.fromLTWH(offset!.dx, offset!.dy, size!.dx, size!.dy);
  }
}
