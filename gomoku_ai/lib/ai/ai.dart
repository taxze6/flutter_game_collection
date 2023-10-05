import 'dart:math';

import 'package:flutter/material.dart';

import '../model/chessman.dart';

import '../model/common.dart' as game;
import '../model/player.dart';
import '../util/buffer_container.dart';

enum ChildType {
  /// 标记当前节点为对手节点，会选择使我方得分最小的走势
  MIN,

  /// 标记当前节点为我方节点，会选择使我方得分最大的走势
  MAX
}

class ChessNode {
  /// 当前节点的棋子
  Chessman? current;

  /// 当前节点的父节点
  ChessNode? parentNode;

  /// 当前节点的所有子节点
  List<ChessNode> childrenNode = [];

  /// 当前节点的值
  num value = double.nan;

  /// 当前节点的类型(我方/敌方)
  late ChildType type;

  /// 当前节点值的上限
  late num maxValue;

  /// 当前节点值的下限
  late num minValue;

  /// 当前节点的层深度
  int depth = 0;

  /// 用于根节点记录选择的根下子节点
  late Chessman checked;
}

class AI {
  static const int WIN = 10000;

  //低级死二 xoox
  static const int DEEP_DEATH2 = 2;

  //死二 xoo
  static const int LOWER_DEATH2 = 4;

  //低级死三 xooox
  static const int DEEP_DEATH3 = 3;

  //死三 xooo
  static const int LOWER_DEATH3 = 6;

  //低级死四 xoooox
  static const int DEEP_DEATH4 = 4;

  //死四 xoooo
  static const int LOWER_DEATH4 = 32;

  //活二 oo
  static const int ALIVE2 = 10;

  //跳活二 o o
  static const int JUMP_ALIVE2 = 2;

  //活三 ooo
  static const int ALIVE3 = 100;

  //跳活三 oo o
  static const int JUMP_ALIVE3 = 10;

  //活四 oooo
  static const int ALIVE4 = 5000;

  //跳活四 （1跳3或者3跳1或2跳2） o ooo || ooo o || oo oo
  static const int JUMP_ALIVE4 = 90;

  //
  static const int LINE_COUNT = 14;

  Player computerPlayer;
  List<Chessman> chessmanList = [];

  AI(this.computerPlayer) {
    chessmanList = game.chessmanList;
  }

  AI.chessmanList(this.computerPlayer, this.chessmanList);

  Future<Offset> nextByAI({bool isPrintMsg = false}) async {
    //如果评分出现ALIVE4的级别，直接下
    Offset pos = needDefenses();
    if (pos != const Offset(-1, 0)) {
      return pos;
    }

    // 取我方,敌方 各5个最优点位置,
    // 防中带攻: 如果判断应该防守,则在敌方5个最优位置中找出我方优势最大的点落子
    // 攻中带防: 如果判断应该进攻,则在己方5个最优位置中找出敌方优势最大的点落子
    BufferMap<Offset> ourPositions = ourBetterPosition();
    BufferMap<Offset> enemyPositions = enemyBetterPosition();

    Offset position = bestPosition(ourPositions, enemyPositions);
    return position;
  }

  Offset needDefenses() {
    BufferMap<Offset> enemy = enemyBetterPosition();
    late Offset defensesPosition;
    for (num key in enemy.keySet) {
      print("key:${key}");
      if (key >= ALIVE4) {
        defensesPosition = enemy[key]!;
        break;
      } else {
        defensesPosition = const Offset(-1, 0);
      }
    }

    // BufferMap<Offset> our = ourBetterPosition();
    // for (num key in our.keySet) {
    //   print("key:${key}");
    //   if (key >= ALIVE4) {
    //     return our[key]!;
    //   }
    // }
    return defensesPosition;
  }

  //基础AI，没有涉及算法
  //遍历当前棋盘上的空位置，然后逐个计算该空位的得分(位置分+组合分)，然后取分数最高的点落子
  Offset bestPosition(
      BufferMap<Offset> ourPositions, BufferMap<Offset> enemyPositions) {
    late Offset position;
    double maxScore = 0;

    if (enemyPositions.maxKey() / ourPositions.maxKey() > 1.5) {
      for (num key in enemyPositions.keySet) {
        int attackScore =
            chessmanGrade(enemyPositions[key]!, ownerPlayer: computerPlayer);
        double score = key * 1.0 + attackScore * 0.8;
        if (score >= maxScore) {
          maxScore = score;
          position = enemyPositions[key]!;
        }
      }
    } else {
      for (num key in ourPositions.keySet) {
        int defenseScore =
            chessmanGrade(ourPositions[key]!, ownerPlayer: computerPlayer);
        double score = key * 1.0 + defenseScore * 0.8;
        if (score >= maxScore) {
          maxScore = score;
          position = ourPositions[key]!;
        }
      }
    }
    return position;
  }

  ///我方下一步较好的${maxCount}个位置
  BufferMap<Offset> ourBetterPosition({maxCount = 5}) {
    Offset offset = Offset.zero;
    BufferMap<Offset> ourMap = BufferMap.maxCount(maxCount);
    for (int i = 0; i <= LINE_COUNT; i++) {
      for (int j = 0; j <= LINE_COUNT; j++) {
        offset = Offset(i.toDouble(), j.toDouble());
        if (isBlankPosition(offset)) {
          int score = chessmanGrade(offset, ownerPlayer: computerPlayer);
          if (ourMap.minKey() < score) {
            ourMap.put(score, Offset(offset.dx, offset.dy));
          }
        }
      }
    }
    return ourMap;
  }

  ///敌方下一步较好的${maxCount}个位置
  BufferMap<Offset> enemyBetterPosition({maxCount = 5}) {
    Offset offset = Offset.zero;
    BufferMap<Offset> enemyMap = BufferMap.maxCount(5);
    print("查找敌方最优落子位置");

    int count = 0;
    for (int i = 0; i <= LINE_COUNT; i++) {
      for (int j = 0; j <= LINE_COUNT; j++) {
        offset = Offset(i.toDouble(), j.toDouble());
        if (isBlankPosition(offset)) {
          DateTime start = DateTime.now();
          int score = chessmanGrade(offset,
              ownerPlayer:
                  computerPlayer == Player.black ? Player.white : Player.black);
          DateTime end = DateTime.now();
          count++;
          int time = end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
          // if (time > 5) {
          print("查找敌方最优落子位置耗时：$time");
          // }
          if (enemyMap.minKey() < score) {
            print("-----${offset.dx},${offset.dy}");
            enemyMap.put(score, Offset(offset.dx, offset.dy));
          }
        }
      }
    }
    print("查找敌方最优落子位置次数：$count");
    return enemyMap;
  }

  ///计算某个棋子对于 ownerPlayer 的分值
  int chessmanGrade(Offset chessmanPosition,
      {required Player ownerPlayer, bool isCanPrintMsg = false}) {
    int score = 0;
    List<Offset> myChenssman = [];
    Offset offset;
    Offset first = chessmanPosition;
    Player player = ownerPlayer;

    ///横向
    //横向(左)
    offset = Offset(first.dx - 1, first.dy);
    myChenssman
      ..clear()
      ..add(first);
    while (existSpecificChessman(offset, player)) {
      myChenssman.add(offset);
      offset = Offset(offset.dx - 1, offset.dy);
    }

    //横向(右)
    offset = Offset(first.dx + 1, first.dy);
    while (existSpecificChessman(offset, player)) {
      myChenssman.add(offset);
      offset = Offset(offset.dx + 1, offset.dy);
    }
    myChenssman.sort((a, b) {
      return (a.dx - b.dx).toInt();
    });
    score += scoring(first, myChenssman, player,
        printMsg: "横向", isCanPrintMsg: isCanPrintMsg);

    ///竖向
    //竖向(上)
    myChenssman
      ..clear()
      ..add(first);
    offset = Offset(first.dx, first.dy - 1);
    while (existSpecificChessman(offset, player)) {
      myChenssman.add(offset);
      offset = Offset(offset.dx, offset.dy - 1);
    }

    //竖向(下)
    offset = Offset(first.dx, first.dy + 1);
    while (existSpecificChessman(offset, player)) {
      myChenssman.add(offset);
      offset = Offset(offset.dx, offset.dy + 1);
    }
    myChenssman.sort((a, b) {
      return (a.dy - b.dy).toInt();
    });
    score += scoring(first, myChenssman, player,
        printMsg: "竖向", isCanPrintMsg: isCanPrintMsg);

    ///正斜(第三象限 -> 第一象限)
    //正斜(第三象限)
    myChenssman
      ..clear()
      ..add(first);
    offset = Offset(first.dx - 1, first.dy + 1);
    while (existSpecificChessman(offset, player)) {
      myChenssman.add(offset);
      offset = Offset(offset.dx - 1, offset.dy + 1);
    }

    //正斜(第一象限)
    offset = Offset(first.dx + 1, first.dy - 1);
    while (existSpecificChessman(offset, player)) {
      myChenssman.add(offset);
      offset = Offset(offset.dx + 1, offset.dy - 1);
    }
    myChenssman.sort((a, b) {
      return (a.dx - b.dx).toInt() + (a.dy - b.dy).toInt();
    });
    score += scoring(first, myChenssman, player,
        printMsg: "正斜向", isCanPrintMsg: isCanPrintMsg);

    ///反斜(第二象限 -> 第四象限)
    //反斜(第二象限)
    myChenssman
      ..clear()
      ..add(first);
    offset = Offset(first.dx - 1, first.dy - 1);
    while (existSpecificChessman(offset, player)) {
      myChenssman.add(offset);
      offset = Offset(offset.dx - 1, offset.dy - 1);
    }

    //反斜(第四象限)
    offset = Offset(first.dx + 1, first.dy + 1);
    while (existSpecificChessman(offset, player)) {
      myChenssman.add(offset);
      offset = Offset(offset.dx + 1, offset.dy + 1);
    }
    myChenssman.sort((a, b) {
      return (a.dx - b.dx).toInt() + (a.dy + b.dy).toInt();
    });
    score += scoring(first, myChenssman, player,
        printMsg: "反斜向", isCanPrintMsg: isCanPrintMsg);

    int ss = score + scoringAloneChessman(first);
    // if (isCanPrintMsg) {
    print("该子分值为: $ss ,其中单子得分:${scoringAloneChessman(first)}, 组合得分:$score");
    // }

    int jumpAlive4Count = getJumpAlive4Count([first], player);
    int jumpAlive3Count = getJumpAlive3Count([first], player);
    int jumpAlive2Count = getJumpAlive2Count([first], player);
    score += limitMax(jumpAlive4Count) * JUMP_ALIVE4 +
        limitMax(jumpAlive3Count) * JUMP_ALIVE3 +
        limitMax(jumpAlive2Count) * JUMP_ALIVE2;

    return score + scoringAloneChessman(first);
  }

  ///孤子价值
  int scoringAloneChessman(Offset offset) {
    int score = 0;
    List<Offset> list = [
      Offset(offset.dx - 1, offset.dy),
      Offset(offset.dx + 1, offset.dy),
      Offset(offset.dx, offset.dy + 1),
      Offset(offset.dx, offset.dy - 1),
      Offset(offset.dx - 1, offset.dy - 1),
      Offset(offset.dx - 1, offset.dy + 1),
      Offset(offset.dx + 1, offset.dy - 1),
      Offset(offset.dx + 1, offset.dy + 1),
    ];
    for (offset in list) {
      if (offset.dx > 0 && offset.dy > 0 && isBlankPosition(offset)) {
        score++;
      }
    }

    return score + positionScore(offset);
  }

  ///位置得分(越靠近中心得分越高)
  int positionScore(Offset offset) {
    double z = -(pow(offset.dx - 7.5, 2) + pow(offset.dy - 7.5, 2)) + 112.5;
    z /= 10;
    return z.toInt();
  }

  //将给定的数限制在最大值为2的范围内
  int limitMax(int num) {
    return num >= 2 ? 2 : num;
  }

  int scoring(Offset first, List<Offset> myChessman, Player player,
      {required String printMsg, bool isCanPrintMsg = false}) {
    if (myChessman.length >= 5) {
      return WIN;
    }
    int score = 0;
    switch (myChessman.length) {
      case 1:
        break;
      case 2:
        if (isAlive2(myChessman)) {
          score += ALIVE2;
          score +=
              limitMax(getJumpAlive3Count(myChessman, player)) * JUMP_ALIVE3;
          score +=
              limitMax(getJumpAlive4Count(myChessman, player)) * JUMP_ALIVE4;

          if (isCanPrintMsg) {
            print("$printMsg 活2成立, 得分+$ALIVE2");
          }
        } else if (isLowerDeath2(myChessman)) {
          score += LOWER_DEATH2;
          if (isCanPrintMsg) {
            print("$printMsg 低级死2成立 ,得分+$LOWER_DEATH2");
          }
        } else {
          score += DEEP_DEATH2;
          if (isCanPrintMsg) {
            print("$printMsg 死2成立 ,得分+$DEEP_DEATH2");
          }
        }
        break;
      case 3:
        if (isAlive3(myChessman)) {
          score += ALIVE3;
          score +=
              limitMax(getJumpAlive4Count(myChessman, player)) * JUMP_ALIVE4;
          if (isCanPrintMsg) {
            print("$printMsg 活3成立, 得分+$ALIVE3");
          }
        } else if (isLowerDeath3(myChessman)) {
          score += LOWER_DEATH3;
          if (isCanPrintMsg) {
            print("$printMsg 低级死3成立 ,得分+$LOWER_DEATH3");
          }
        } else {
          score += DEEP_DEATH3;
          if (isCanPrintMsg) {
            print("$printMsg 死3成立 ,得分+$DEEP_DEATH3");
          }
        }
        break;

      case 4:
        if (isAlive4(myChessman)) {
          score += ALIVE4;
          if (isCanPrintMsg) {
            print("$printMsg 活4成立, 得分+$ALIVE4");
          }
        } else if (isLowerDeath4(myChessman)) {
          score += LOWER_DEATH4;
          if (isCanPrintMsg) {
            print("$printMsg 低级死4成立 ,得分+$LOWER_DEATH4");
          }
        } else {
          score += DEEP_DEATH4;
          if (isCanPrintMsg) {
            print("$printMsg 死4成立 ,得分+$DEEP_DEATH4");
          }
        }
        break;

      case 5:
      default:
        score += WIN;
    }
    return score;
  }

  bool isAlive2(List<Offset> list) {
    assert(list.length == 2);
    Offset offset1 = nextChessman(list[1], list[0]);
    Offset offset2 = nextChessman(list[0], list[1]);

    return isEffectivePosition(offset1) &&
        isEffectivePosition(offset2) &&
        isBlankPosition(offset1) &&
        isBlankPosition(offset2);
  }

  bool isLowerDeath2(List<Offset> list) {
    assert(list.length == 2);
    Offset offset1 = nextChessman(list[1], list[0]);
    Offset offset2 = nextChessman(list[0], list[1]);
    return (isEffectivePosition(offset1) && isBlankPosition(offset1)) ||
        (isEffectivePosition(offset2) && isBlankPosition(offset2));
  }

  bool isAlive3(List<Offset> list) {
    assert(list.length == 3);

    Offset offset1 = nextChessman(list[1], list[0]);
    Offset offset2 = nextChessman(list[1], list[2]);
    return (isEffectivePosition(offset1) && isBlankPosition(offset1)) &&
        (isEffectivePosition(offset2) && isBlankPosition(offset2));
  }

  bool isLowerDeath3(List<Offset> list) {
    assert(list.length == 3);
    Offset offset1 = nextChessman(list[1], list[0]);
    Offset offset2 = nextChessman(list[1], list[2]);
    return (isEffectivePosition(offset1) && isBlankPosition(offset1)) ||
        (isEffectivePosition(offset2) && isBlankPosition(offset2));
  }

  bool isAlive4(List<Offset> list) {
    assert(list.length == 4);
    Offset offset1 = nextChessman(list[1], list[0]);
    Offset offset2 = nextChessman(list[2], list[3]);
    return (isEffectivePosition(offset1) && isBlankPosition(offset1)) &&
        (isEffectivePosition(offset2) && isBlankPosition(offset2));
  }

  bool isLowerDeath4(List<Offset> list) {
    assert(list.length == 4);
    Offset offset1 = nextChessman(list[1], list[0]);
    Offset offset2 = nextChessman(list[2], list[3]);
    return (isEffectivePosition(offset1) && isBlankPosition(offset1)) ||
        (isEffectivePosition(offset2) && isBlankPosition(offset2));
  }

  int getJumpAlive2Count(List<Offset> list, Player player) {
    assert(list.length == 1);
    int count = 0;
    if (list.first.dx >= 3) {
      //棋盘边界
      Offset left = Offset(list.first.dx - 2, list.first.dy);
      count += existSpecificChessman(left, player) &&
              isAllBlankPosition([
                Offset(list.first.dx + 1, list.first.dy),
                Offset(left.dx - 1, left.dy)
              ])
          ? 1
          : 0;
    }

    if (list.first.dx <= LINE_COUNT - 2) {
      Offset right = Offset(list.first.dx + 2, list.first.dy);
      count += existSpecificChessman(right, player) &&
              isAllBlankPosition([
                Offset(list.first.dx - 1, list.first.dy),
                Offset(right.dx + 1, right.dy)
              ])
          ? 1
          : 0;
    }

    if (list.first.dy >= 3) {
      Offset top = Offset(list.first.dx, list.first.dy - 2);
      count += existSpecificChessman(top, player) &&
              isAllBlankPosition([
                Offset(list.first.dx, list.first.dy + 1),
                Offset(top.dx, top.dy - 1)
              ])
          ? 1
          : 0;
    }

    if (list.first.dy <= LINE_COUNT - 2) {
      Offset bottom = Offset(list.first.dx, list.first.dy + 2);
      count += existSpecificChessman(bottom, player) &&
              isAllBlankPosition([
                Offset(list.first.dx, list.first.dy - 1),
                Offset(bottom.dx, bottom.dy + 1)
              ])
          ? 1
          : 0;
    }

    if (list.first.dx >= 3 && list.first.dy >= 3) {
      Offset leftTop = Offset(list.first.dx - 2, list.first.dy - 2);
      count += existSpecificChessman(leftTop, player) &&
              isAllBlankPosition([
                Offset(list.first.dx + 1, list.first.dy + 1),
                Offset(leftTop.dx - 1, leftTop.dy - 1)
              ])
          ? 1
          : 0;
    }

    if (list.first.dx >= 3 && list.first.dy <= LINE_COUNT - 2) {
      Offset leftBottom = Offset(list.first.dx - 2, list.first.dy + 2);
      count += existSpecificChessman(leftBottom, player) &&
              isAllBlankPosition([
                Offset(list.first.dx + 1, list.first.dy - 1),
                Offset(leftBottom.dx - 1, leftBottom.dy + 1)
              ])
          ? 1
          : 0;
    }

    if (list.first.dx <= LINE_COUNT - 2 && list.first.dy >= 3) {
      Offset rightTop = Offset(list.first.dx + 2, list.first.dy - 2);
      count += existSpecificChessman(rightTop, player) &&
              isAllBlankPosition([
                Offset(list.first.dx - 1, list.first.dy + 1),
                Offset(rightTop.dx + 1, rightTop.dy - 1)
              ])
          ? 1
          : 0;
    }

    if (list.first.dx <= LINE_COUNT - 2 && list.first.dy <= LINE_COUNT - 2) {
      Offset rightBottom = Offset(list.first.dx + 2, list.first.dy + 2);
      count += existSpecificChessman(rightBottom, player) &&
              isAllBlankPosition([
                Offset(list.first.dx - 1, list.first.dy - 1),
                Offset(rightBottom.dx + 1, rightBottom.dy + 1)
              ])
          ? 1
          : 0;
    }
    return count;
  }

  int getJumpAlive3Count(List<Offset> list, Player player) {
    assert(list.length == 1 || list.length == 2);
    int count = 0;
    if (list.length == 1) {
      //1跳2 活3
      /// leftBlank left2 left1 blank list.first rightBlank
      if (list.first.dx >= 4) {
        //棋盘边界
        Offset left1 = Offset(list.first.dx - 2, list.first.dy);
        Offset left2 = Offset(left1.dx - 1, list.first.dy);
        Offset blank = Offset(list.first.dx - 1, list.first.dy);
        Offset leftBlank = Offset(left2.dx - 1, list.first.dy);
        Offset rightBlank = Offset(list.first.dx + 1, list.first.dy);

        count += existSpecificChessmanAll([left1, left2], player) &&
                isAllBlankPosition([blank, leftBlank, rightBlank])
            ? 1
            : 0;
      }

      ///leftBlank list.first  blank right1  right2 rightBlank
      if (list.first.dx <= LINE_COUNT - 4) {
        Offset leftBlank = Offset(list.first.dx - 1, list.first.dy);
        Offset blank = Offset(list.first.dx + 1, list.first.dy);
        Offset right1 = Offset(blank.dx + 1, blank.dy);
        Offset right2 = Offset(right1.dx + 1, blank.dy);
        Offset rightBlank = Offset(right2.dx + 1, blank.dy);
        count += existSpecificChessmanAll([right1, right2], player) &&
                isAllBlankPosition([leftBlank, blank, rightBlank])
            ? 1
            : 0;
      }

      /// topBlank
      /// top2
      /// top1
      /// blank
      /// list.first
      /// bottomBlank

      if (list.first.dy >= 4) {
        Offset blank = Offset(list.first.dx, list.first.dy - 1);
        Offset top1 = Offset(list.first.dx, blank.dy - 1);
        Offset top2 = Offset(list.first.dx, top1.dy - 1);
        Offset topBlank = Offset(list.first.dx, top2.dy - 1);
        Offset bottomBlank = Offset(list.first.dx, list.first.dy + 1);
        count += existSpecificChessmanAll([top1, top2], player) &&
                isAllBlankPosition([topBlank, blank, bottomBlank])
            ? 1
            : 0;
      }

      /// topBlank
      /// list.first
      /// blank
      /// top1
      /// top2
      /// bottomBlank
      if (list.first.dy <= LINE_COUNT - 4) {
        Offset topBlank = Offset(list.first.dx, list.first.dy - 1);
        Offset blank = Offset(list.first.dx, list.first.dy + 1);
        Offset top1 = Offset(list.first.dx, blank.dy + 1);
        Offset top2 = Offset(list.first.dx, top1.dy + 1);
        Offset bottomBlank = Offset(list.first.dx, top2.dy + 1);
        count += existSpecificChessmanAll([top1, top2], player) &&
                isAllBlankPosition([topBlank, blank, bottomBlank])
            ? 1
            : 0;
      }

      ///左上
      /// |leftTopBlank
      /// |          leftTop2
      /// |                   leftTop1
      /// |                           blank
      /// |                                 list.first
      /// |                                          rightBottomBlank
      if (list.first.dx >= 4 && list.first.dy >= 4) {
        Offset rightBottomBlank = Offset(list.first.dx + 1, list.first.dy + 1);
        Offset blank = Offset(list.first.dx - 1, list.first.dy - 1);
        Offset leftTop1 = Offset(blank.dx - 1, blank.dy - 1);
        Offset leftTop2 = Offset(leftTop1.dx - 1, leftTop1.dy - 1);
        Offset leftTopBlank = Offset(leftTop2.dx - 1, leftTop2.dy - 1);
        count += existSpecificChessmanAll([leftTop1, leftTop2], player) &&
                isAllBlankPosition([rightBottomBlank, blank, leftTopBlank])
            ? 1
            : 0;
      }

      ///左下
      ///  |                                                 rightTopBlank1
      ///  |                                       list.first
      ///  |                                   blank
      ///  |                        leftBottom1
      ///  |            leftBottom2
      ///  |leftBottomBlank
      if (list.first.dx >= 4 && list.first.dy <= LINE_COUNT - 4) {
        Offset rightTopBlank = Offset(list.first.dx + 1, list.first.dy - 1);
        Offset blank = Offset(list.first.dx - 1, list.first.dy + 1);
        Offset leftBottom1 = Offset(blank.dx - 1, blank.dy + 1);
        Offset leftBottom2 = Offset(leftBottom1.dx - 1, leftBottom1.dy + 1);
        Offset leftBottomBlank = Offset(leftBottom2.dx - 1, leftBottom2.dy + 1);
        count += existSpecificChessmanAll([leftBottom1, leftBottom2], player) &&
                isAllBlankPosition([rightTopBlank, blank, leftBottomBlank])
            ? 1
            : 0;
      }

      ///右上
      ///                                             rightTopBlank|
      ///                                     rightTop2            |
      ///                             rightTop1                    |
      ///                         blank                            |
      ///               list.first                                 |
      /// leftBottomBlank                                          |
      if (list.first.dx <= LINE_COUNT - 4 && list.first.dy >= 4) {
        Offset leftBottomBlank = Offset(list.first.dx - 1, list.first.dy + 1);
        Offset blank = Offset(list.first.dx + 1, list.first.dy - 1);
        Offset rightTop1 = Offset(blank.dx - 1, blank.dy + 1);
        Offset rightTop2 = Offset(rightTop1.dx - 1, rightTop1.dy + 1);
        Offset rightTopBlank = Offset(rightTop2.dx - 1, rightTop2.dy + 1);
        count += existSpecificChessmanAll([rightTop1, rightTop2], player) &&
                isAllBlankPosition([leftBottomBlank, blank, rightTopBlank])
            ? 1
            : 0;
      }

      ///右下
      /// leftTopBlank                                       |
      ///             list.first                             |
      ///                       blank                        |
      ///                          leftTop1                  |
      ///                                 leftTop2           |
      ///                                        rightBottom |
      ///
      if (list.first.dx <= LINE_COUNT - 4 && list.first.dy <= LINE_COUNT - 4) {
        Offset leftTopBlank = Offset(list.first.dx - 1, list.first.dy - 1);
        Offset blank = Offset(list.first.dx + 1, list.first.dy + 1);
        Offset leftTop1 = Offset(blank.dx + 1, blank.dy + 1);
        Offset leftTop2 = Offset(leftTop1.dx + 1, leftTop1.dy + 1);
        Offset rightBottom = Offset(leftTop2.dx + 1, leftTop2.dy + 1);
        count += existSpecificChessmanAll([leftTop1, leftTop2], player) &&
                isAllBlankPosition([leftTopBlank, blank, rightBottom])
            ? 1
            : 0;
      }
    } else if (list.length == 2) {
      //2跳1 活3
      /// next1Next1Blank next1 next1blank list[0] list[1] next2Blank next2 next2Next2Blank
      Offset next1blank = nextChessman(list[1], list[0]);
      Offset next1 = nextChessman(list[0], next1blank);
      Offset next1Next1Blank = nextChessman(next1blank, next1);
      Offset next2Blank = nextChessman(list[0], list[1]);
      Offset next2 = nextChessman(list[1], next2Blank);
      Offset next2Next2Blank = nextChessman(next2Blank, next2);

      count += existSpecificChessman(next1, player) &&
              isAllBlankPosition([next1Next1Blank, next1blank, next2Blank])
          ? 1
          : 0;
      count += existSpecificChessman(next2, player) &&
              isAllBlankPosition([next1blank, next2Blank, next2Next2Blank])
          ? 1
          : 0;
    }
    return count;
  }

  int getJumpAlive4Count(List<Offset> list, Player player) {
    assert(list.length > 0 && list.length < 4);
    int count = 0;

    if (list.length == 1) {
      ///左
      ///leftBlank left3 left2 left1 blank list.first rightBlank
      if (list.first.dx >= 5) {
        Offset rightBlank = Offset(list.first.dx + 1, list.first.dy);
        Offset blank = Offset(list.first.dx - 1, list.first.dy);
        Offset left1 = Offset(blank.dx - 1, list.first.dy);
        Offset left2 = Offset(left1.dx - 1, list.first.dy);
        Offset left3 = Offset(left2.dx - 1, list.first.dy);
        Offset leftBlank = Offset(left3.dx - 1, list.first.dy);
        count += existSpecificChessmanAll([left1, left2, left3], player) &&
                isAllBlankPosition([rightBlank, blank, leftBlank])
            ? 1
            : 0;
      }

      ///右
      ///leftBlank list.first blank right1 right2 right3 rightBlank
      if (list.first.dx <= LINE_COUNT - 5) {
        Offset leftBlank = Offset(list.first.dx - 1, list.first.dy);
        Offset blank = Offset(list.first.dx + 1, list.first.dy);
        Offset right1 = Offset(blank.dx + 1, blank.dy);
        Offset right2 = Offset(right1.dx + 1, blank.dy);
        Offset right3 = Offset(right2.dx + 1, blank.dy);
        Offset rightBlank = Offset(right3.dx + 1, blank.dy);
        count += existSpecificChessmanAll([right1, right2, right3], player) &&
                isAllBlankPosition([leftBlank, blank, rightBlank])
            ? 1
            : 0;
      }

      ///上
      /// topBlank
      /// top3
      /// top2
      /// top1
      /// blank
      /// list.first
      /// bottomBlank
      if (list.first.dy >= 5) {
        Offset bottomBlank = Offset(list.first.dx, list.first.dy + 1);
        Offset blank = Offset(list.first.dx, list.first.dy - 1);
        Offset top1 = Offset(blank.dx, blank.dy - 1);
        Offset top2 = Offset(top1.dx, blank.dy - 1);
        Offset top3 = Offset(top2.dx, blank.dy - 1);
        Offset topBlank = Offset(top3.dx, blank.dy - 1);
        count += existSpecificChessmanAll([top1, top2, top3], player) &&
                isAllBlankPosition([bottomBlank, blank, topBlank])
            ? 1
            : 0;
      }

      /// 下
      /// topBlank
      /// list.first
      /// blank
      /// bottom1
      /// bottom2
      /// bottom3
      /// bottomBlank
      if (list.first.dy <= LINE_COUNT - 5) {
        Offset topBlank = Offset(list.first.dx, list.first.dy - 1);
        Offset blank = Offset(list.first.dx, list.first.dy + 1);
        Offset bottom1 = Offset(blank.dx, blank.dy + 1);
        Offset bottom2 = Offset(bottom1.dx, bottom1.dy + 1);
        Offset bottom3 = Offset(bottom2.dx, bottom2.dy + 1);
        Offset bottomBlank = Offset(bottom3.dx, bottom3.dy + 1);
        count +=
            existSpecificChessmanAll([bottom1, bottom2, bottom3], player) &&
                    isAllBlankPosition([topBlank, blank, bottomBlank])
                ? 1
                : 0;
      }

      /// 左上
      /// leftTopBlank
      ///             leftTop3
      ///                    leftTop2
      ///                          leftTop1
      ///                                 blank
      ///                                     list.first
      ///                                             rightBottom

      if (list.first.dx >= 5 && list.first.dy >= 5) {
        Offset rightBottom = Offset(list.first.dx + 1, list.first.dy + 1);
        Offset blank = Offset(list.first.dx - 1, list.first.dy - 1);
        Offset leftTop1 = Offset(blank.dx - 1, blank.dy - 1);
        Offset leftTop2 = Offset(leftTop1.dx - 1, leftTop1.dy - 1);
        Offset leftTop3 = Offset(leftTop2.dx - 1, leftTop2.dy - 1);
        Offset leftTopBlank = Offset(leftTop3.dx - 1, leftTop3.dy - 1);
        count +=
            existSpecificChessmanAll([leftTop1, leftTop2, leftTop3], player) &&
                    isAllBlankPosition([rightBottom, blank, leftTopBlank])
                ? 1
                : 0;
      }

      ///左下
      ///                                                 rightTopBlank
      ///                                           list.first
      ///                                       blank
      ///                              leftBottom1
      ///                       leftBottom2
      ///               leftBottom3
      /// leftBottomBlank
      if (list.first.dx >= 5 && list.first.dy <= LINE_COUNT - 5) {
        Offset rightTopBlank = Offset(list.first.dx + 1, list.first.dy - 1);
        Offset blank = Offset(list.first.dx - 1, list.first.dy + 1);
        Offset leftBottom1 = Offset(blank.dx - 1, blank.dy + 1);
        Offset leftBottom2 = Offset(leftBottom1.dx - 1, leftBottom1.dy + 1);
        Offset leftBottom3 = Offset(leftBottom2.dx - 1, leftBottom2.dy + 1);
        Offset leftBottomBlank = Offset(leftBottom3.dx - 1, leftBottom3.dy + 1);
        count += existSpecificChessmanAll(
                    [leftBottom1, leftBottom2, leftBottom3], player) &&
                isAllBlankPosition([rightTopBlank, blank, leftBottomBlank])
            ? 1
            : 0;
      }

      /// 右上
      ///                                             rightTopBlank
      ///                                       rightTop3
      ///                                 rightTop2
      ///                         rightTop1
      ///                     blank
      ///             list.first
      /// leftBottomBlank
      if (list.first.dx <= LINE_COUNT - 5 && list.first.dy >= 5) {
        Offset leftBottomBlank = Offset(list.first.dx - 1, list.first.dy + 1);
        Offset blank = Offset(list.first.dx + 1, list.first.dy - 1);
        Offset rightTop1 = Offset(blank.dx + 1, blank.dy - 1);
        Offset rightTop2 = Offset(rightTop1.dx + 1, rightTop1.dy - 1);
        Offset rightTop3 = Offset(rightTop2.dx + 1, rightTop2.dy - 1);
        Offset rightTopBlank = Offset(rightTop3.dx + 1, rightTop3.dy - 1);
        count += existSpecificChessmanAll(
                    [rightTop1, rightTop2, rightTop3], player) &&
                isAllBlankPosition([leftBottomBlank, blank, rightTopBlank])
            ? 1
            : 0;
      }

      /// 右下
      /// leftTopBlank
      ///           list.first
      ///                    blank
      ///                        rightBottom1
      ///                               rightBottom2
      ///                                      rightBottom3
      ///                                            rightBottomBlank
      if (list.first.dx <= LINE_COUNT - 5 && list.first.dy <= LINE_COUNT - 5) {
        Offset leftTopBlank = Offset(list.first.dx - 1, list.first.dy - 1);
        Offset blank = Offset(list.first.dx + 1, list.first.dy + 1);
        Offset rightBottom1 = Offset(blank.dx + 1, blank.dy + 1);
        Offset rightBottom2 = Offset(rightBottom1.dx + 1, rightBottom1.dy + 1);
        Offset rightBottom3 = Offset(rightBottom2.dx + 1, rightBottom2.dy + 1);
        Offset rightBottomBlank =
            Offset(rightBottom3.dx + 1, rightBottom3.dy + 1);
        count += existSpecificChessmanAll(
                    [rightBottom1, rightBottom2, rightBottom3], player) &&
                isAllBlankPosition([leftTopBlank, blank, rightBottomBlank])
            ? 1
            : 0;
      }
    } else if (list.length == 2) {
      /// next2Blank next2 next1 next1Blank list[0] list[1]  next3Blank next3 next4 next4Blank
      Offset next1Blank = nextChessman(list[1], list[0]);
      Offset next1 = nextChessman(list[0], next1Blank);
      Offset next2 = nextChessman(next1Blank, next1);
      Offset next2Blank = nextChessman(next1, next2);
      Offset next3Blank = nextChessman(list[0], list[1]);
      Offset next3 = nextChessman(list[1], next3Blank);
      Offset next4 = nextChessman(next3Blank, next3);
      Offset next4Blank = nextChessman(next3, next4);

      count += existSpecificChessmanAll([next2, next1], player) &&
              isAllBlankPosition([next2Blank, next1Blank, next3Blank])
          ? 1
          : 0;
      count += existSpecificChessmanAll([next3, next4], player) &&
              isAllBlankPosition([next1Blank, next3Blank, next4Blank])
          ? 1
          : 0;
    } else if (list.length == 3) {
      ///next1Next1Blank next1 next1Blank list[0] list[1] list[2] next2Blank next2 next2Next2Blank
      Offset next1Blank = nextChessman(list[1], list[0]);
      Offset next1 = nextChessman(list[0], next1Blank);
      Offset next1Next1Blank = nextChessman(next1Blank, next1);
      Offset next2Blank = nextChessman(list[1], list[2]);
      Offset next2 = nextChessman(list[2], next2Blank);
      Offset next2Next2Blank = nextChessman(next2Blank, next2);

      count += existSpecificChessman(next1, player) &&
              isAllBlankPosition([next1Next1Blank, next1Blank, next2Blank])
          ? 1
          : 0;
      count += existSpecificChessman(next2, player) &&
              isAllBlankPosition([next1Blank, next2Blank, next2Next2Blank])
          ? 1
          : 0;
    }
    return count;
  }

  bool isJumpAlive3(List<Offset> list, Player player) {
    assert(list.length == 2);
    if (isAlive2(list)) {
      Offset next1 = nextChessman(list[1], list[0]);
      Offset next2 = nextChessman(list[0], list[1]);

      Offset nextNext1 = nextChessman(list[0], next1);
      Offset nextNext2 = nextChessman(list[1], next2);

      return (isBlankPosition(nextNext1) &&
              existSpecificChessman(nextNext2, player)) ||
          (isBlankPosition(nextNext2) &&
              existSpecificChessman(nextNext1, player));
    }

    return false;
  }

  //输入的first和second返回下一个棋子的位置偏移量。
  Offset nextChessman(Offset first, Offset second) {
    //检查first和second的dy值是否相等。
    //如果相等，表示棋子在水平方向上移动。那么下一个棋子的位置偏移量将在水平方向上向右或向左移动一格，取决于first的dx是否大于second的dx。
    //如果first.dx > second.dx，则向左移动一格，即second.dx - 1；否则，向右移动一格，即second.dx + 1。纵坐标保持不变，即为first.dy
    if (first.dy == second.dy) {
      return Offset(
          first.dx > second.dx ? second.dx - 1 : second.dx + 1, first.dy);
    }
    //如果first.dx和second.dx相等，表示棋子在垂直方向上移动。那么下一个棋子的位置偏移量将在垂直方向上向上或向下移动一格，取决于first的dy是否大于second的dy。如果first.dy > second.dy，则向上移动一格，即second.dy - 1；否则，向下移动一格，即second.dy + 1。横坐标保持不变，即为first.dx。
    //如果以上两种情况都不满足，那么表示棋子在斜对角线方向上移动。根据first.dx和second.dx的大小关系，以及first.dy和second.dy的大小关系，决定下一个棋子的位置偏移量。
    else if (first.dx == second.dx) {
      return Offset(
          first.dx, first.dy > second.dy ? second.dy - 1 : second.dy + 1);
    } else if (first.dx > second.dx) {
      if (first.dy > second.dy) {
        return Offset(second.dx - 1, second.dy - 1);
      } else {
        return Offset(second.dx - 1, second.dy + 1);
      }
    } else {
      if (first.dy > second.dy) {
        return Offset(second.dx + 1, second.dy - 1);
      } else {
        return Offset(second.dx + 1, second.dy + 1);
      }
    }
  }

  //判断该位置是否有效。
  bool isEffectivePosition(Offset offset) {
    return offset.dx >= 0 &&
        offset.dx <= LINE_COUNT &&
        offset.dy >= 0 &&
        offset.dy <= LINE_COUNT;
  }

  bool existSpecificChessmanAll(List<Offset> positions, Player player) {
    if (positions.isEmpty) {
      return false;
    }

    bool flag = true;
    for (Offset of in positions) {
      flag &= existSpecificChessman(of, player);
    }
    return flag;
  }

// 检查给定位置是否存在特定的棋子
  bool existSpecificChessman(Offset position, Player player) {
    //定义一个不可能生成到棋盘上的棋子
    Chessman defaultChessman = Chessman(Offset(-1, 0), Player.black);
    // 检查棋子列表是否非空
    if (chessmanList.isNotEmpty) {
      // 在棋子列表中查找匹配给定位置的棋子
      var cm = chessmanList.firstWhere((Chessman c) {
        return c.position.dx == position.dx && c.position.dy == position.dy;
      }, orElse: () {
        return defaultChessman;
      });

      // 如果找到匹配的棋子，检查其所有者是否是指定的玩家
      return cm != defaultChessman && cm.owner == player;
    }
    // 如果棋子列表为空或不存在棋子匹配给定位置，则返回false
    return false;
  }

  bool canFallChessman(Chessman chessman) {
    //定义一个不可能生成到棋盘上的棋子
    Chessman defaultChessman = Chessman(Offset(-1, 0), Player.black);
    if (chessmanList.isNotEmpty) {
      Chessman cm = chessmanList.firstWhere((Chessman c) {
        //如果找到位置相同的棋子，那么cm就等于这棋子的信息
        return c.position.dx == chessman.position.dx &&
            c.position.dy == chessman.position.dy;
      }, orElse: () {
        //没找到就把该棋子添加到列表中，然后返回一个不可能在棋盘上的棋子用作校验
        chessmanList.add(chessman);
        return defaultChessman;
      });
      // 如果找到了相同位置的棋子，这里就会返回false；否则返回true
      return cm == defaultChessman;
    } else {
      //如果为空直接添加
      chessmanList.add(chessman);
      return true;
    }
  }

  bool isAllBlankPosition(List<Offset> list) {
    for (Offset o in list) {
      if (!isBlankPosition(o)) {
        return false;
      }
    }
    return true;
  }

  ///判断某个位置上是否没有棋子
  bool isBlankPosition(Offset position) {
    if (chessmanList.isNotEmpty) {
      Chessman defaultChessman = Chessman(const Offset(-1, 0), Player.black);
      var cm = chessmanList.firstWhere((Chessman c) {
        return c.position.dx == position.dx && c.position.dy == position.dy;
      }, orElse: () {
        return defaultChessman;
      });
      return cm == defaultChessman;
    }
    return true;
  }
}

class AdvancedAI extends AI {
  int maxDepth = 5;
  late Player our, enemy;

  //统计搜索次数
  int count = 0;

  bool maxMin = true;

  AdvancedAI(Player computerPlayer, {bool? isMaxMin}) : super(computerPlayer) {
    our = computerPlayer;
    enemy = our == Player.black ? Player.white : Player.black;
    maxMin = isMaxMin ?? true;
  }

  Future<Offset> nextByAI({bool isPrintMsg = false}) async {
    Offset pos = needDefenses();
    if (pos != const Offset(-1, 0)) {
      return pos;
    }

    count = 0;
    DateTime start = DateTime.now();
    ChessNode root = createGameTree();
    DateTime create = DateTime.now();
    print(
        '创建博弈树耗时：${create.millisecondsSinceEpoch - start.millisecondsSinceEpoch}');
    if (maxMin) {
      maxMinSearch(root);
      DateTime search = DateTime.now();
      print(
          'MaxMin搜索耗时：${search.millisecondsSinceEpoch - create.millisecondsSinceEpoch}');
    } else {
      alphaBetaSearch(root);
      DateTime search = DateTime.now();
      print(
          'Alpha-Beta 搜索耗时：${search.millisecondsSinceEpoch - create.millisecondsSinceEpoch}');
      print("Alpha-Beta 搜索次数: $count");
    }

    return root.checked.position;
  }

  /// alpha-beta 剪枝算法
  num alphaBetaSearch(ChessNode current) {
    count++; // 搜索次数累加

    if (current.childrenNode.isEmpty) { // 如果当前节点没有子节点，即为叶子节点
      return current.value; // 返回该节点的值
    }

    if (current.parentNode != null && !current.parentNode!.childrenNode.contains(current)) {
      ChessNode parent = current.parentNode!;

      // 如果父节点存在且父节点的子节点不包含当前节点，说明该枝已经被剪掉，返回父节点的最大/最小值
      return parent.type == ChildType.MAX ? parent.minValue : parent.maxValue;
    }

    List<ChessNode> children = current.childrenNode; // 获取当前节点的子节点

    if (current.type == ChildType.MIN) { // 当前节点为MIN节点
      num parentMin = current.parentNode?.minValue ?? double.negativeInfinity; // 获取父节点的最小值，若不存在父节点则设置为负无穷大
      int index = 0; // 索引计数器

      for (ChessNode node in children) {
        index++; // 索引递增

        num newCurrentMax = min(current.maxValue, alphaBetaSearch(node)); // 计算当前子节点的最大值

        if (newCurrentMax <= parentMin) {
          // 如果当前子节点的最大值小于等于父节点的最小值，则说明该枝可以被完全剪掉
          current.childrenNode = current.childrenNode.sublist(0, index); // 将当前节点的子节点列表截断至当前索引位置
          return parentMin; // 返回父节点的最小值
        }

        if (newCurrentMax < current.maxValue) {
          // 如果当前子节点的最大值小于当前节点的最大值，则更新当前节点的最大值、值和经过路径的位置信息
          current.maxValue = newCurrentMax;
          current.value = node.value;
          current.checked = node.current!;
        }
      }

      if (current.maxValue > parentMin) {
        // 如果当前节点的最大值大于父节点的最小值，则更新父节点的最小值、值和经过路径的位置信息
        current.parentNode?.minValue = current.maxValue;
        current.parentNode?.value = current.value;
        current.parentNode?.checked = current.current!;
      }

      return current.maxValue; // 返回当前节点的最大值作为该节点在搜索树中的价值
    } else { // 当前节点为MAX节点
      num parentMax = current.parentNode?.maxValue ?? double.infinity; // 获取父节点的最大值，若不存在父节点则设置为正无穷大
      int index = 0; // 索引计数器

      for (ChessNode node in children) {
        index++; // 索引递增

        num newCurrentMin = max(current.minValue, alphaBetaSearch(node)); // 计算当前子节点的最小值

        if (parentMax < newCurrentMin) {
          // 如果父节点的最大值小于当前子节点的最小值，则说明该枝可以被完全剪掉
          current.childrenNode = current.childrenNode.sublist(0, index); // 将当前节点的子节点列表截断至当前索引位置
          return parentMax; // 返回父节点的最大值
        }

        if (newCurrentMin > current.minValue) {
          // 如果当前子节点的最小值大于当前节点的最小值，则更新当前节点的最小值、值和经过路径的位置信息
          current.minValue = newCurrentMin;
          current.value = node.value;
          current.checked = node.current!;
        }
      }

      if (current.minValue < parentMax) {
        // 如果当前节点的最小值小于父节点的最大值，则更新父节点的最大值、值和经过路径的位置信息
        current.parentNode?.maxValue = current.minValue;
        current.parentNode?.value = current.value;
        current.parentNode?.checked = current.current!;
      }

      return current.minValue; // 返回当前节点的最小值作为该节点在搜索树中的价值
    }
  }

  //MaxMin算法
  num maxMinSearch(ChessNode root) {
    if (root.childrenNode.isEmpty) {
      return root.value; // 返回叶子节点的估值
    }
    List<ChessNode> children = root.childrenNode;
    if (root.type == ChildType.MIN) {
      // 如果是对手执行操作
      for (ChessNode node in children) {
        if (maxMinSearch(node) < root.maxValue) {
          // 判断子节点的估值是否小于当前节点的最大值
          root.maxValue = node.value; // 更新当前节点的最大值
          root.value = node.value; // 更新当前节点的估值
          root.checked = node.current!; // 更新当前节点的选择步骤
        } else {
          continue; // 否则继续遍历下一个子节点
        }
      }
    } else {
      // 如果是自己执行操作
      for (ChessNode node in children) {
        if (maxMinSearch(node) > root.minValue) {
          // 判断子节点的估值是否大于当前节点的最小值
          root.minValue = node.value; // 更新当前节点的最小值
          root.value = node.value; // 更新当前节点的估值
          root.checked = node.current!; // 更新当前节点的选择步骤
        } else {
          continue; // 否则继续遍历下一个子节点
        }
      }
    }
    return root.value; // 返回当前节点的估值
  }

  //生成五子棋博弈树
  ChessNode createGameTree() {
    //创建根节点 root，设置其属性值：深度为0，估值为NaN，节点类型为 ChildType.MAX，最小值为负无穷，最大值为正无穷。
    ChessNode root = ChessNode()
      ..depth = 0
      ..value = double.nan
      ..type = ChildType.MAX
      ..minValue = double.negativeInfinity
      ..maxValue = double.infinity;

    //确定当前玩家 currentPlayer
    //如果棋子列表 chessmanList 为空，则当前玩家为黑色
    //否则，根据棋子列表中最后一个棋子的颜色设置当前玩家为另一个颜色。
    Player currentPlayer;
    if (chessmanList.isEmpty) {
      currentPlayer = Player.black;
    } else {
      currentPlayer =
          chessmanList.last.owner == Player.black ? Player.white : Player.black;
    }

    //查找敌方最优落子位置，并将结果存储在 enemyPosList 变量中。
    //然后，将 enemyPosList 转换为 OffsetList 对象
    //再将其转换为普通列表类型 List<Offset> 对象。这些位置将用于创建第一层子节点。
    BufferChessmanList enemyPosList =
        enemyBestPosition(chessmanList, maxCount: 5);

    OffsetList list = OffsetList()..addAll(enemyPosList.toList());
    List<Offset> result = list.toList();

    int index = 0;
    //通过遍历 result 列表，为每个位置 position 创建一个新的棋子 chessman 和一个新的子节点 node
    //然后将子节点 node 添加到根节点的子节点列表 root.childrenNode 中
    for (Offset position in result) {
      Chessman chessman = Chessman(position, currentPlayer);

      ChessNode node = ChessNode()
        ..parentNode = root
        ..depth = root.depth + 1
        ..maxValue = root.maxValue
        ..minValue = root.minValue
        ..type = ChildType.MIN
        ..current = chessman;

      root.childrenNode.add(node);
      var start = DateTime.now();
      createChildren(node);
      var create = DateTime.now();

      print(
          '创建第一层第$index个节点耗时：${create.millisecondsSinceEpoch - start.millisecondsSinceEpoch}');
      index++;
    }
    return root;
  }

  /// 生成博弈树子节点
  void createChildren(ChessNode parent) {
    if (parent == null) {
      return null;
    }

    // 判断是否达到最大深度，如果是则计算棋局估值并返回
    if (parent.depth > maxDepth) {
      List<Chessman> list = createTempChessmanList(parent);
      var start = DateTime.now();
      parent.value = statusScore(our, list);
      var value = DateTime.now();
      print(
          '棋局估值耗时：${value.millisecondsSinceEpoch - start.millisecondsSinceEpoch}');
      return;
    }

    // 确定当前玩家和子节点类型
    Player currentPlayer =
        parent.current!.owner == Player.black ? Player.white : Player.black;
    ChildType type =
        parent.type == ChildType.MAX ? ChildType.MIN : ChildType.MAX;

    // 创建临时棋子列表
    var list = createTempChessmanList(parent);

    // 查找最优落子位置
    var start = DateTime.now();
    BufferChessmanList enemyPosList = enemyBestPosition(list, maxCount: 5);
    var value = DateTime.now();
    print(
        '查找高分落子位置耗时：${value.millisecondsSinceEpoch - start.millisecondsSinceEpoch}');

    // 将最优落子位置放入列表中
    OffsetList offsetList = OffsetList()..addAll(enemyPosList.toList());
    List<Offset> result = offsetList.toList();

    // 遍历最优落子位置，生成子节点
    for (Offset position in result) {
      Chessman chessman = Chessman(position, currentPlayer);

      ChessNode node = ChessNode()
        ..parentNode = parent
        ..current = chessman
        ..type = type
        ..depth = parent.depth + 1
        ..maxValue = parent.maxValue
        ..minValue = parent.minValue;

      parent.childrenNode.add(node);

      // 递归生成子节点的子节点
      createChildren(node);
    }
  }

  /// 生成临时棋局
  List<Chessman> createTempChessmanList(ChessNode node) {
    //growable是一个可选参数，用于指定是否允许在列表中添加或删除元素。
    //当growable为false时，列表的长度是固定的，并且不能添加或删除元素；当growable为true时，列表的长度是可变的，可以随时添加或删除元素。
    List<Chessman> temp = List.from(chessmanList, growable: true);
    temp.add(node.current!);

    ChessNode? current = node.parentNode;
    while (current != null && current.current != null) {
      temp.add(current.current!);
      current = current.parentNode;
    }
    return temp;
  }

  /// 局势评估
  int situationValuation(Player player, List<Chessman> chessmanList) {
    int result = 0;
    for (Chessman c in chessmanList) {
      if (c.owner == player) {
        result += chessmanGrade(c.position, ownerPlayer: player);
      } else {
        result -= chessmanGrade(c.position,
            ownerPlayer: player == Player.black ? Player.white : Player.black);
      }
    }
    return result;
  }

  int statusScore(Player player, List<Chessman> chessmanList) {
    int score = 0;
    for (Chessman c in chessmanList) {
      score += chessmanScore(c, chessmanList);
    }
    return score;
  }

  ///对棋局中的某个棋子打分
  int chessmanScore(Chessman chessman, List<Chessman> chessmanList) {
    Offset current = chessman.position;
    List<Offset> score4 = List.empty(growable: true);
    List<Offset> score3 = List.empty(growable: true);

    //0°
    Offset right = Offset(current.dx + 1, current.dy);
    Offset right2 = Offset(current.dx + 2, current.dy);
    if (isEffectivePosition(right)) {
      score4.add(right);
    }
    if (isEffectivePosition(right2)) {
      score3.add(right2);
    }

    //45°方向
    Offset rightTop = Offset(current.dx + 1, current.dy - 1);
    Offset rightTop2 = Offset(current.dx + 2, current.dy - 2);
    if (isEffectivePosition(rightTop)) {
      score4.add(rightTop);
    }
    if (isEffectivePosition(rightTop2)) {
      score3.add(rightTop2);
    }

    //90°方向
    Offset centerTop = Offset(current.dx, current.dy - 1);
    Offset centerTop2 = Offset(current.dx, current.dy - 2);
    if (isEffectivePosition(centerTop)) {
      score4.add(centerTop);
    }
    if (isEffectivePosition(centerTop2)) {
      score3.add(centerTop2);
    }

    //135°
    Offset leftTop = Offset(current.dx - 1, current.dy - 1);
    Offset leftTop2 = Offset(current.dx - 2, current.dy - 2);
    if (isEffectivePosition(leftTop)) {
      score4.add(leftTop);
    }
    if (isEffectivePosition(leftTop2)) {
      score3.add(leftTop2);
    }

    //180°
    Offset left = Offset(current.dx - 1, current.dy);
    Offset left2 = Offset(current.dx - 2, current.dy);
    if (isEffectivePosition(left)) {
      score4.add(left);
    }
    if (isEffectivePosition(left2)) {
      score3.add(left2);
    }

    //225°
    Offset leftBottom = Offset(current.dx - 1, current.dy + 1);
    Offset leftBottom2 = Offset(current.dx - 2, current.dy + 2);
    if (isEffectivePosition(leftBottom)) {
      score4.add(leftBottom);
    }
    if (isEffectivePosition(leftBottom2)) {
      score3.add(leftBottom2);
    }

    //270°
    Offset bottom = Offset(current.dx, current.dy + 1);
    Offset bottom2 = Offset(current.dx, current.dy + 2);
    if (isEffectivePosition(bottom)) {
      score4.add(bottom);
    }
    if (isEffectivePosition(bottom2)) {
      score3.add(bottom2);
    }

    //315°
    Offset rightBottom = Offset(current.dx + 1, current.dy + 1);
    Offset rightBottom2 = Offset(current.dx + 1, current.dy + 2);
    if (isEffectivePosition(rightBottom)) {
      score4.add(rightBottom);
    }
    if (isEffectivePosition(rightBottom2)) {
      score3.add(rightBottom2);
    }

    int result = 0;
    for (Offset offset in score4) {
      //chessman
      Player? owner = getChessmanOwnerByPosition(offset, chessmanList);
      if (owner == null) {
        //是个空位置
      } else if (owner == chessman.owner) {
        //是自己的棋子
        result += 4;
      } else {
        //是对方的棋子
        result -= 4;
      }
    }

    for (Offset offset in score3) {
      Player? owner = getChessmanOwnerByPosition(offset, chessmanList);
      if (owner == null) {
        //是个空位置
      } else if (owner == chessman.owner) {
        //是自己的棋子
        result += 3;
      } else {
        //是对方的棋子
        result -= 3;
      }
    }
    return result;
  }

  BufferChessmanList highScorePosition(
      Player player, List<Chessman> currentChessmanList,
      {maxCount = 5}) {
    //高分
    BufferChessmanList list = BufferChessmanList.maxCount(maxCount: maxCount);
    for (int x = 0; x <= AI.LINE_COUNT; x++) {
      for (int y = 0; y <= AI.LINE_COUNT; y++) {
        Offset pos = Offset(x.toDouble(), y.toDouble());
        if (isBlankPosition(pos, chessmanList: currentChessmanList)) {
          Chessman chessman = Chessman(pos, player);
          int chessScore = chessmanScore(chessman, currentChessmanList);
          int posScore = positionScore(pos);
          int score = chessScore + posScore;
          if (list.minScore() < score) {
            list.add(Chessman(pos, player)..score = score);
          }
        }
      }
    }
    return list;
  }

  BufferChessmanList enemyBestPosition(List<Chessman> chessmanList,
      {maxCount = 5}) {
    return highScorePosition(enemy, chessmanList);
  }

  bool isBlankPosition(Offset position, {List<Chessman>? chessmanList}) {
    if (!isEffectivePosition(position)) {
      return false;
    }
    chessmanList ??= this.chessmanList;
    if (chessmanList.isEmpty) {
      return true;
    }
    for (Chessman chessman in chessmanList) {
      if (chessman.position.dx == position.dx &&
          chessman.position.dy == position.dy) {
        return false;
      }
    }
    return true;
  }

  bool isEffectivePosition(Offset offset) {
    return offset.dx >= 0 &&
        offset.dx <= AI.LINE_COUNT &&
        offset.dy >= 0 &&
        offset.dy <= AI.LINE_COUNT;
  }

  Player? getChessmanOwnerByPosition(
      Offset position, List<Chessman> chessmanList) {
    for (Chessman c in chessmanList) {
      if (c.position.dx == position.dx && c.position.dy == position.dy) {
        return c.owner;
      }
    }
    return null;
  }
}
