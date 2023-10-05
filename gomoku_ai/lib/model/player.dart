import 'package:flutter/material.dart';
//玩家
class Player {
  static final Player black = Player(Colors.black);
  static final Player white = Player(Colors.white);
  late Color color;

  Player(this.color);

  @override
  String toString() {
    return 'Player{${this == black ? "black" : "white"}}';
  }
}
