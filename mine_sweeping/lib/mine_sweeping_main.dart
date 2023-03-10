import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mine_sweeping/model/game_setting.dart';
import 'package:mine_sweeping/widget/block_container.dart';

enum BlockType {
  //数字
  figure,
  //雷
  mine,
  //标记
  label,
  //未标记（未被翻开）
  unlabeled,
}

class MineSweeping extends StatefulWidget {
  const MineSweeping({Key? key}) : super(key: key);

  @override
  State<MineSweeping> createState() => _MineSweepingState();
}

class _MineSweepingState extends State<MineSweeping> {
  static GameSetting gameSetting = GameSetting();
  late List<List<int>> board; // 棋盘
  late List<List<bool>> revealed; // 记录格子是否被翻开
  late List<List<bool>> flagged; // 记录格子是否被标记
  late bool gameOver; // 游戏是否结束
  late bool win; // 是否获胜

  late int numRows; // 行数
  late int numCols; // 列数
  late int numMines; // 雷数

  //游戏时间
  late int _playTime;

  String get playTime {
    int minutes = (_playTime ~/ 60);
    int seconds = (_playTime % 60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Timer? _timer;

  ///重置游戏
  void reset() {
    setState(() {
      numRows = gameSetting.difficulty;
      numCols = gameSetting.difficulty;
      numMines = gameSetting.mines;
      // 初始化棋盘
      board = List.generate(numRows, (_) => List.filled(numCols, 0));
      // 初始化格子是否被翻开
      revealed = List.generate(numRows, (_) => List.filled(numCols, false));
      // 初始化格子是否被标记
      flagged = List.generate(numRows, (_) => List.filled(numCols, false));
      // 将游戏定义为未结束
      gameOver = false;
      // 将游戏定义为还未获胜
      win = false;

      //在棋盘上随机放置地雷，直到放置的地雷数量达到预定的 numMines
      int numMinesPlaced = 0;
      while (numMinesPlaced < numMines) {
        //使用 Random().nextInt 方法生成两个随机数 i 和 j
        //分别用于表示棋盘中的行和列
        int i = Random().nextInt(numRows);
        int j = Random().nextInt(numCols);
        //通过 board[i][j] != -1 的判断语句，检查这个位置是否已经放置了地雷。如果没有
        //则将 board[i][j] 的值设置为 -1，表示在这个位置放置了地雷，并将 numMinesPlaced 的值加 1。
        if (board[i][j] != -1) {
          board[i][j] = -1;
          numMinesPlaced++;
        }
      }

      //计算每个非地雷格子周围的地雷数量
      //然后将计算得到的数量保存在对应的格子上。
      //通过两个嵌套的 for 循环遍历整个棋盘
      //内层的两个嵌套循环会计算这个格子周围的所有格子中地雷的数量
      //并将这个数量保存在 count 变量中
      for (int i = 0; i < numRows; i++) {
        for (int j = 0; j < numCols; j++) {
          //在每个单元格上，如果它不是地雷（值不为-1）
          //则内部嵌套两个循环遍历当前单元格周围的所有单元格
          //计算地雷数量并存储在当前单元格中。
          if (board[i][j] != -1) {
            int count = 0;
            //max(0, i - 1) 和 max(0, j - 1)
            //用于确保 i2 和 j2 不会小于 0，即不会越界到数组的负数索引。
            //min(numRows - 1, i + 1) 和 min(numCols - 1, j + 1) 用于确保 i2 和 j2 不会超出数组的边界
            // ·不会越界到数组的行列索引大于等于 numRows 和 numCols。
            for (int i2 = max(0, i - 1); i2 <= min(numRows - 1, i + 1); i2++) {
              for (int j2 = max(0, j - 1);
                  j2 <= min(numCols - 1, j + 1);
                  j2++) {
                if (board[i2][j2] == -1) {
                  count++;
                }
              }
            }
            board[i][j] = count;
          }
        }
      }
      //开始计时
      startTimer();
    });
  }

  void reveal(int i, int j) {
    if (!revealed[i][j]) {
      setState(() {
        //将该格子设置为翻开
        revealed[i][j] = true;

        //如果翻开的是地雷
        if (board[i][j] == -1) {
          //结束动画，将所有的地雷翻开
          for (int i2 = 0; i2 < numRows; i2++) {
            for (int j2 = 0; j2 < numCols; j2++) {
              if (board[i2][j2] == -1) {
                revealed[i2][j2] = true;
              }
            }
          }
          //游戏结束
          gameOver = true;
          _timer?.cancel();
          //结束动画
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('O!'),
              content: Text('You lose!'),
              actions: [
                TextButton(
                  onPressed: reset,
                  child: Text('Play Again'),
                ),
              ],
            ),
          );
        }

        // 如果点击的格子周围都没有雷就自动翻开相邻的空格
        if (board[i][j] == 0) {
          for (int i2 = max(0, i - 1); i2 <= min(numRows - 1, i + 1); i2++) {
            for (int j2 = max(0, j - 1); j2 <= min(numCols - 1, j + 1); j2++) {
              if (!revealed[i2][j2]) {
                reveal(i2, j2);
              }
            }
          }
        }

        // 检查胜利条件
        if (checkWin()) {
          win = true;
          gameOver = true;
          _timer?.cancel();
          //成功动画
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Congratulations!'),
              content: Text('You win!'),
              actions: [
                TextButton(
                  onPressed: reset,
                  child: Text('Play Again'),
                ),
              ],
            ),
          );
        }
      });
    }
  }

  //这段代码是用来检查游戏是否获胜的。
  //具体来说，它会遍历整个棋盘，检查每一个未被翻开的格子是否都是地雷，
  //如果有任何一个未翻开的格子不是地雷，就说明游戏还没有获胜，返回false。
  //如果所有未翻开的格子都是地雷，就说明游戏已经获胜了，返回true。
  //
  //这个函数被用于在用户点击一个格子后检查游戏是否获胜，以及在重置游戏时重新初始化游戏状态。
  //通过这样的方式，可以实现自动检查游戏是否获胜的功能，并且让用户能够清楚地知道游戏是否已经结束。
  bool checkWin() {
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < numCols; j++) {
        if (board[i][j] != -1 && !revealed[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  ///标记雷
  void toggleFlag(int i, int j) {
    if (!gameOver) {
      setState(() {
        flagged[i][j] = !flagged[i][j];
      });
    }
  }

  void changeDifficulty(int difficulty) {
    setState(() {
      gameSetting.difficulty = difficulty;
    });
    reset();
  }

  void changeThemeColor(Color color) {
    setState(() {
      gameSetting.themeColor = color;
    });
    reset();
  }

  void setting() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Game Setting!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24, child: Text('游戏主题颜色：')),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => changeThemeColor(Color(0xFF5ADFD0)),
                      child: const SizedBox(
                        width: 50,
                        height: 50,
                        child: ColoredBox(
                          color: Color(0xFF5ADFD0),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    GestureDetector(
                      onTap: () => changeThemeColor(Color(0xFFA0BBFF)),
                      child: const SizedBox(
                        width: 50,
                        height: 50,
                        child: ColoredBox(
                          color: Color(0xFFA0BBFF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24, child: Text('游戏难度：')),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => changeDifficulty(8),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Color(0xFFA0BBFF)),
                        width: 50,
                        height: 50,
                        child: Text("新手"),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => changeDifficulty(12),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Color(0xFFEF9A0D)),
                        width: 50,
                        height: 50,
                        child: Text("熟练"),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => changeDifficulty(16),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Color(0xFFCE3C39)),
                        width: 50,
                        height: 50,
                        child: Text("专家"),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  ///游戏计时器
  void startTimer() {
    const duration = Duration(seconds: 1);
    _playTime = 0;
    _timer = Timer.periodic(duration, (timer) {
      setState(() {
        _playTime = _playTime + 1;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mine Sweeping & Taxze"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () => setting(), icon: const Icon(Icons.settings))
        ],
      ),
      backgroundColor: gameSetting.themeColor == const Color(0xFF5ADFD0)
          ? const Color(0xFF09484E)
          : const Color(0xFF1F2E7F),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 84,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(
                  height: 50,
                  child: Row(
                    children: [
                      Image.asset("assets/images/bomb.png"),
                      Text(
                        "$numMines",
                        style:
                            const TextStyle(fontSize: 28, color: Colors.white),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: Row(
                    children: [
                      Image.asset("assets/images/clock.png"),
                      Text(
                        "$playTime",
                        style:
                            const TextStyle(fontSize: 28, color: Colors.white),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: numCols,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (BuildContext context, int index) {
                int i = index ~/ numCols;
                int j = index % numCols;
                BlockType blockType;
                //格子被翻开
                if (revealed[i][j]) {
                  //是地雷
                  if (board[i][j] == -1) {
                    blockType = BlockType.mine;
                  } else {
                    blockType = BlockType.figure;
                  }
                } else {
                  //被用户标记
                  if (flagged[i][j]) {
                    blockType = BlockType.label;
                  } else {
                    blockType = BlockType.unlabeled;
                  }
                }
                return GestureDetector(
                  onTap: () => reveal(i, j),
                  onDoubleTap: () => toggleFlag(i, j),
                  child: BlockContainer(
                    backColor: gameSetting.themeColor,
                    value: revealed[i][j] && board[i][j] != 0 ? board[i][j] : 0,
                    blockType: blockType,
                  ),
                );
              },
              itemCount: numRows * numCols,
            ),
          ),
        ],
      ),
    );
  }
}
