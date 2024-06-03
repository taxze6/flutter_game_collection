import 'package:flutter/material.dart';

import 'model/fish.dart';

enum GameState {
  notStart,
  inGame,
  failed,
  success,
  paused,
  restarted,
}

class GameUtils {
  //方向
  static bool up = false;
  static bool down = false;
  static bool left = false;
  static bool right = false;

  //分数
  static double score = 0;

  //关卡等级
  static int level = 0;

  //敌方鱼类集合
  static List<Fish> enemyList = [];

  //背景图
  static const String bgImg = "assets/images/background/sea.jpg";

  // 敌方鱼类
  static const String enemyLeft1Img = "assets/images/enemyFish/fish1_r.gif";
  static const String enemyRight1Img = "assets/images/enemyFish/fish1_l.gif";
  static const String enemyLeft2Img = "assets/images/enemyFish/fish2_r.gif";
  static const String enemyRight2Img = "assets/images/enemyFish/fish2_l.gif";
  static const String enemyLeft3Img = "assets/images/enemyFish/fish3_r.gif";
  static const String enemyRight3Img = "assets/images/enemyFish/fish3_l.gif";
  static const String bossImg = "assets/images/enemyFish/boss.gif";

  // 我方鱼类
  static const String myFishLeftImg = "assets/images/myFish/myfish_left.gif";
  static const String myFishRightImg = "assets/images/myFish/myfish_right.gif";
}
