import 'package:flutter/material.dart';
import 'chessman.dart';
import 'player.dart';

//游戏所需通用参数
//初始化一个玩家，掌握黑棋
Player firstPlayer = Player.black;
//存放所有的棋子
List<Chessman> chessmanList = [];
//存放胜利的棋子
List<Chessman> winResult = [];