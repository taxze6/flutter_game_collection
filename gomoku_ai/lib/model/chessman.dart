//棋子
import 'package:flutter/material.dart';
import 'package:gomoku_ai/model/player.dart';

import 'common.dart';

class Chessman {
  //坐标
  late Offset position;

  //每颗棋子的所属人
  late Player owner;

  //棋子id
  int numberId = chessmanList.length;

  //棋子的分数，默认为0
  int score = 0;

  Chessman(this.position, this.owner);

  Chessman.white(this.position) {
    owner = Player.white;
  }

  Chessman.black(this.position) {
    owner = Player.black;
  }

  @override
  String toString() {
    return 'Chessman{position: (${position.dx},${position.dy}), owner: ${owner == Player.black ? "black" : "white"}, score: $score, numberId: $numberId}';
  }
}
