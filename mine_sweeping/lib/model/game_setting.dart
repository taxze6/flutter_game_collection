import 'package:flutter/material.dart';

class GameSetting {
  List<Color> c_5ADFD0 = [
    Color(0xFF299794),
    Color(0xFF2EC4C0),
    Color(0xFF2EC4C0)
  ];

  List<Color> c_A0BBFF = [
    Color(0xFF5067C5),
    Color(0xFF838CFF),
    Color(0xFFA0BBFF),
  ];

  Color themeColor = Color(0xFF5ADFD0);

  ///游戏的难度，默认为8*8
  int difficulty = 8;

  ///雷的数量 (格子总数 * 0.18 向下取整)，通常扫雷的雷数在0.16-0.2之间。
  int get mines => (difficulty * difficulty * 0.18).floor();

  GameSetting._();

  ///定义了一个私有的、静态的、不可变的 _default 对象，它是 GameSetting 类的默认实例
  ///该实例在第一次使用时被创建，并且只能被 GameSetting() 工厂构造函数访问
  static final GameSetting _default = GameSetting._();

  ///定义了一个 GameSetting 工厂构造函数，它通过返回 _default 对象实现了单例模式的实例化
  ///该工厂构造函数是唯一可以实例化 GameSetting 对象的方法。
  factory GameSetting() => _default;

  @override
  String toString() {
    return "themeColor=$themeColor,difficulty=$difficulty,mine=$mines";
  }
}
