import 'package:flutter/material.dart';
import 'package:gomoku_ai/model/chessman.dart';

import 'ai/ai.dart';
import 'chessman_paint.dart';
import 'model/common.dart';
import 'model/player.dart';

class GameMainPage extends StatefulWidget {
  const GameMainPage({Key? key}) : super(key: key);

  @override
  State<GameMainPage> createState() => _GameMainPageState();
}

class _GameMainPageState extends State<GameMainPage> {
  //AI托管
  bool hosting = false;
  String gradeOfDifficulty = "简单";

  //默认难度为简单
  var ai = AI(Player.white);

  //isMaxMin为true使用max-min算法，为false使用alpha-beta 剪枝算法
  // var ai = AdvancedAI(Player.white, isMaxMin: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("五子棋AI版"),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 30, left: 20, right: 20),
        child: Column(
          children: [
            Text(
              "当前难度：$gradeOfDifficulty",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 12,
            ),
            //棋盘
            GestureDetector(
              child: CustomPaint(
                painter: ChessmanPaint(),
                size: Size(400, 400),
              ),
              onTapDown: (details) {
                onTapDown(details);
                setState(() {});
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            chessmanList.clear();
                            winResult.clear();
                          });
                        },
                        icon: Icon(
                          Icons.restart_alt_rounded,
                        ),
                        iconSize: 36,
                        color: Colors.black,
                      ),
                      Text("重置棋盘")
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            hosting = !hosting;
                          });
                        },
                        icon: Icon(
                          Icons.laptop,
                        ),
                        iconSize: 36,
                        color: Colors.black,
                      ),
                      Text(hosting ? "取消托管" : "AI托管")
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                child: Container(
                                  width: 200,
                                  height: 300,
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            chessmanList.clear();
                                            winResult.clear();
                                            ai = AI(Player.white);
                                            gradeOfDifficulty = "简单";
                                          });
                                        },
                                        child: Text('简单难度-基础AI'),
                                      ),
                                      SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            chessmanList.clear();
                                            winResult.clear();
                                            ai = AdvancedAI(Player.white,
                                                isMaxMin: true);

                                            gradeOfDifficulty = "中等难度-Max-Min";
                                          });
                                        },
                                        child: Text('中等难度-Max-Min'),
                                      ),
                                      SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            chessmanList.clear();
                                            winResult.clear();
                                            ai = AdvancedAI(Player.white,
                                                isMaxMin: false);

                                            gradeOfDifficulty =
                                                "高难度-alpha-beta 剪枝";
                                          });
                                        },
                                        child: Text('高难度-alpha-beta 剪枝'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        icon: Icon(
                          Icons.flash_on,
                        ),
                        iconSize: 36,
                        color: Colors.black,
                      ),
                      Text("难度选择")
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  //棋盘点击事件
  void onTapDown(TapDownDetails details) {
    //游戏胜利后，再点击棋盘就无效
    if (winResult.isNotEmpty) {
      return;
    }
    double clickX = details.localPosition.dx;
    //计算点击点所在列的索引值 floorX。通过将 clickX 除以格子的宽度 cellWidth 并向下取整，可以得到点击点所处的列索引值
    int floorX = clickX ~/ cellWidth;
    //计算了当前列横坐标网格线中点的横坐标值 offsetFloorX。通过将 floorX 乘以格子的宽度 cellWidth，再加上格子宽度的一半 cellWidth / 2，可以得到当前列横坐标网格线中点的横坐标值。
    double offsetFloorX = floorX * cellWidth + cellWidth / 2;
    //判断点击点在哪一列，并将结果赋值给变量 x。如果 offsetFloorX 大于点击点的 x 坐标 clickX，则说明点击点在 floorX 列；否则，说明点击点在 floorX + 1 列。如果点击点在 floorX + 1 列，则通过 ++floorX 来获取 floorX + 1 的值。
    int x = offsetFloorX > clickX ? floorX : ++floorX;

    //y轴同理
    double clickY = details.localPosition.dy;
    int floorY = clickY ~/ cellHeight;
    double offsetFloorY = floorY * cellHeight + cellHeight / 2;
    int y = offsetFloorY > clickY ? floorY : ++floorY;

    //触发落子
    fallChessman(Offset(x.toDouble(), y.toDouble()));
  }

  void fallChessman(Offset position) {
    if (winResult.isNotEmpty) {
      return;
    }
    //创建棋子
    Chessman newChessman;
    //棋子的颜色
    if (chessmanList.isEmpty || chessmanList.length % 2 == 0) {
      newChessman = firstPlayer == Player.black
          ? Chessman.black(position)
          : Chessman.white(position);
    } else {
      newChessman = firstPlayer == Player.black
          ? Chessman.white(position)
          : Chessman.black(position);
    }
    //判断是否能落子
    bool canFall = canFallChessman(newChessman);
    if (canFall) {
      //可以落子
      printFallChessmanInfo(newChessman);
      //此处还需完成:
      //1.棋子估值、ai相关逻辑
      int score = ai.chessmanGrade(newChessman.position,
          ownerPlayer: newChessman.owner);
      int enemy =
          ai.chessmanGrade(newChessman.position, ownerPlayer: Player.black);
      print(
          "[${newChessman.owner == Player.white ? "电脑" : "玩家"}落子(${newChessman.owner == Player.white ? "白方" : "黑方"})] 该子价值评估: 己方:$score, 敌方:$enemy");

      //2.对游戏胜利的校验，对游戏和棋的校验
      bool result = checkResult(newChessman);

      if (!result && !isHaveAvailablePosition()) {
        print("和棋!");
        showDialog(
            context: context,
            builder: (c) {
              return AlertDialog(
                title: const Text("游戏结束"),
                content: Text("和棋"),
                actions: [
                  ElevatedButton(
                    child: const Text('确定'),
                    onPressed: () {
                      // 点击确定按钮后的操作
                      Navigator.of(context).pop(); // 关闭对话框
                    },
                  ),
                ],
              );
            });
        return;
      }
      //没胜利就调用ai
      if (!result && newChessman.owner != Player.white) {
        Future.delayed(Duration(milliseconds: 20), () {
          Future<Offset> position = ai.nextByAI();
          position.then((position) {
            print("----------${position}");
            fallChessman(position);
            //托管
            if (hosting) {
              trusteeship();
            }
          });
        });
      }
    } else {
      print("此处无法落子!");
    }

    setState(() {});
  }

  //AI托管
  void trusteeship() {
    Future.delayed(Duration(milliseconds: 20), () {
      Future<Offset> position = AI(Player.black).nextByAI();
      position.then((position) {
        fallChessman(position);
      });
    });
  }

  //判断棋盘是否满了
  bool isHaveAvailablePosition() {
    return chessmanList.length <= 255;
  }

  bool checkResult(Chessman newChessman) {
    int currentX = newChessman.position.dx.toInt();
    int currentY = newChessman.position.dy.toInt();

    int count = 0;

    ///横
    /// o o o o o
    /// o o o o o
    /// x x x x x
    /// o o o o o
    /// o o o o o
    winResult.clear();
    // 循环遍历当前行的前后四个位置（如果存在），检查是否有特定的棋子连成五子相连
    //判断 currentX - 4 > 0 时，它的意思是判断左侧第 4 个位置是否在棋盘内。
    //如果 currentX - 4 大于 0，则表示左侧第 4 个位置在棋盘内；
    //否则，即 currentX - 4 <= 0，表示左侧第 4 个位置已经超出了棋盘边界。
    for (int i = (currentX - 4 > 0 ? currentX - 4 : 0);
        i <= (currentX + 4 < LINE_COUNT ? currentX + 4 : LINE_COUNT);
        i++) {
      // 计算当前位置的坐标
      Offset position = Offset(i.toDouble(), currentY.toDouble());

      // 检查当前位置是否存在胜利的棋子
      if (existSpecificChessman(position, newChessman.owner)) {
        // 将该棋子添加到胜利结果列表中，并增加计数器
        winResult.add(Chessman(position, newChessman.owner));
        count++;
      } else {
        // 如果不存在特定的棋子，清空胜利结果列表，并将计数器重置为0
        winResult.clear();
        count = 0;
      }

      // 解析：如果计数器达到5，表示有五子相连，输出胜利者信息并返回true
      if (count >= 5) {
        print("胜利者产生: ${newChessman.owner == Player.white ? "白色" : "黑色"}");
        winDialog("胜利者产生: ${newChessman.owner == Player.white ? "白色" : "黑色"}");
        return true;
      }
    }

    ///竖
    /// o o x o o
    /// o o x o o
    /// o o x o o
    /// o o x o o
    /// o o x o o
    count = 0;
    winResult.clear();
    for (int j = (currentY - 4 > 0 ? currentY - 4 : 0);
        j <= (currentY + 4 > LINE_COUNT ? LINE_COUNT : currentY + 4);
        j++) {
      Offset position = Offset(currentX.toDouble(), j.toDouble());
      if (existSpecificChessman(position, newChessman.owner)) {
        winResult.add(Chessman(position, newChessman.owner));
        count++;
      } else {
        winResult.clear();
        count = 0;
      }
      if (count >= 5) {
        print("胜利者产生: ${newChessman.owner == Player.white ? "白色" : "黑色"}");
        winDialog("胜利者产生: ${newChessman.owner == Player.white ? "白色" : "黑色"}");
        return true;
      }
    }

    ///正斜
    /// o o o o x
    /// o o o x o
    /// o o x o o
    /// o x o o o
    /// x o o o o
    count = 0;
    winResult.clear();
    Offset offset2 =
        Offset((currentX - 4).toDouble(), (currentY + 4).toDouble());
    for (int i = 0; i < 10; i++) {
      Offset position = Offset(offset2.dx + i, offset2.dy - i);
      if (existSpecificChessman(position, newChessman.owner)) {
        winResult.add(Chessman(position, newChessman.owner));
        count++;
      } else {
        winResult.clear();
        count = 0;
      }
      if (count >= 5) {
        print("胜利者产生: ${newChessman.owner == Player.white ? "白色" : "黑色"}");
        winDialog("胜利者产生: ${newChessman.owner == Player.white ? "白色" : "黑色"}");
        return true;
      }
    }

    ///反斜
    /// x o o o o
    /// o x o o o
    /// o o x o o
    /// o o o x o
    /// o o o o x
    count = 0;
    winResult..clear();
    Offset offset =
        Offset((currentX - 4).toDouble(), (currentY - 4).toDouble());
    for (int i = 0; i < 10; i++) {
      Offset position = Offset(offset.dx + i, offset.dy + i);
      if (existSpecificChessman(position, newChessman.owner)) {
        winResult.add(Chessman(position, newChessman.owner));
        count++;
      } else {
        winResult.clear();
        count = 0;
      }
      if (count >= 5) {
        print("胜利者产生: ${newChessman.owner == Player.white ? "白色" : "黑色"}");
        winDialog("胜利者产生: ${newChessman.owner == Player.white ? "白色" : "黑色"}");
        return true;
      }
    }
    winResult.clear();
    return false;
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

  void printFallChessmanInfo(Chessman newChessman) {
    print(
        "[落子成功], 棋子序号:${newChessman.numberId} ,颜色:${newChessman.owner == Player.white ? "白色" : "黑色"} , 位置 :(${newChessman.position.dx.toInt()} , ${newChessman.position.dy.toInt()})");
  }

  void winDialog(String content) {
    showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            title: const Text("游戏胜利"),
            content: Text(content),
            actions: [
              ElevatedButton(
                child: const Text('确定'),
                onPressed: () {
                  // 点击确定按钮后的操作
                  Navigator.of(context).pop(); // 关闭对话框
                },
              ),
            ],
          );
        });
  }
}
