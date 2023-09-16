import 'package:flutter/material.dart';
import 'circle.dart';

/**
 * @Author: Taxze
 * @GitHub: https://github.com/taxze6
 * @Email: taxze.xiaoyan@gmail.com
 * @Date: 2023/9/16
 */


enum GameState {
  Blank,
  Black,
  White,
}

class TwoPlayerGame extends StatefulWidget {
  @override
  _TwoPlayerGameState createState() => _TwoPlayerGameState();
}

class _TwoPlayerGameState extends State<TwoPlayerGame>
    with SingleTickerProviderStateMixin {
  var activePlayer = GameState.Black;
  var winner = GameState.Blank;
  var boardState = List<List<GameState>>.generate(
    15,
    (i) => List<GameState>.generate(
      15,
      (j) => GameState.Blank,
    ),
  );

  double _boardOpacity = 1.0;
  bool _showWinnerDisplay = false;
  int _moveCount = 0;
  late Animation<double> _boardAnimation;
  late AnimationController _boardController;
  int _blackWins = 0;
  int _whiteWins = 0;
  int _draws = 0;

  @override
  void initState() {
    _boardController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _boardAnimation = Tween(begin: 1.0, end: 0.0).animate(_boardController)
      ..addListener(() {
        setState(() {
          _boardOpacity = _boardAnimation.value;
        });
      });
    super.initState();
  }

  @override
  void dispose() {
    _boardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print(boardState.length);
    return Scaffold(
        body: Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.asset(
            "assets/images/game_back.jpg",
            fit: BoxFit.cover,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 48),
              height: MediaQuery.of(context).size.height * .2,
              child: scoreBoard,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .5,
              child: Stack(
                children: <Widget>[
                  board,
                  winnerDisplay,
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.08,
              child: bottomBar,
            ),
          ],
        ),
      ],
    ));
  }

  Widget get scoreBoard => Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            blackScore,
            drawScore,
            whiteScore,
          ],
        ),
      );

  Widget get blackScore => Column(
        children: <Widget>[
          const Chip(
            label: FittedBox(
              child: Text(
                '月饼队',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            backgroundColor: Colors.blue,
          ),
          Chip(
            label: FittedBox(
              child: Text(
                '$_blackWins',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
        ],
      );

  Widget get whiteScore => Column(
        children: <Widget>[
          Chip(
            label: FittedBox(
              child: Text(
                '玉兔队',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            backgroundColor: Colors.blue,
          ),
          Chip(
            label: FittedBox(
              child: Text(
                '$_whiteWins',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20.0),
              ),
            ),
          )
        ],
      );

  Widget get drawScore => Column(
        children: <Widget>[
          Chip(
            label: FittedBox(
              child: Text(
                '平局',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            backgroundColor: Colors.blue,
          ),
          Chip(
            label: FittedBox(
              child: Text(
                '$_draws',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20.0),
              ),
            ),
          )
        ],
      );

  Widget get board => Opacity(
        opacity: _boardOpacity,
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              color: Colors.grey[300],
              child: GridView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: boardState.length,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 1.0,
                  mainAxisSpacing: 1.0,
                ),
                itemCount: 225,
                itemBuilder: (context, index) {
                  int row = index ~/ 15;
                  int col = index % 15;
                  return gameButton(row, col);
                },
              ),
            ),
          ),
        ),
      );

  Widget get winnerDisplay => Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        child: Visibility(
          visible: _showWinnerDisplay,
          child: Opacity(
            opacity: 1.0 - _boardOpacity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // if (winner == GameState.Black)
                winner == GameState.Black
                    ? Text(
                        '月饼队',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 56.0,
                        ),
                      )
                    : winner == GameState.White
                        ? Text(
                            '玉兔队',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 56.0,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text('No WINNER'),
                          ),

                // if (winner == GameState.White)
                //   SizedBox(
                //     width: 80.0,
                //     height: 80.0,
                //     child: Dot(Colors.white),
                //   ),
                Text(
                  (winner == GameState.Blank) ? "这是一场平局！" : '胜利!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 56.0,
                  ),
                ),
                // if (winner != GameState.Blank)
                //   Padding(
                //     padding: const EdgeInsets.only(left: 8.0),
                //     child: Text('No WINNER'),
                //   ),
              ],
            ),
          ),
        ),
      );

  Widget gameButton(int row, int col) {
    return GestureDetector(
      onTap:
          (boardState[row][col] == GameState.Blank && winner == GameState.Blank)
              ? () {
                  _moveCount++;
                  boardState[row][col] = activePlayer;
                  checkWinningCondition(row, col, activePlayer);
                  toggleActivePlayer();
                  setState(() {});
                }
              : null,
      child: Container(
        color: Colors.blue,
        child: Center(
          child: gamePiece(row, col),
        ),
      ),
    );
  }

  Widget get bottomBar => Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FloatingActionButton(
              heroTag: 'back',
              child: Icon(Icons.arrow_back),
              // backgroundColor: accentColor,
              mini: true,
              onPressed: () => Navigator.pop(context),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FittedBox(
                  child: Text(
                    '2 Players',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            FloatingActionButton(
              heroTag: 'reset',
              child: Icon(Icons.cached),
              // backgroundColor: accentColor,
              mini: true,
              onPressed: () => reset(),
            ),
          ],
        ),
      );

  void reset() {
    for (int i = 0; i < 15; i++) {
      for (int j = 0; j < 15; j++) {
        boardState[i][j] = GameState.Blank;
      }
    }
    activePlayer = GameState.Black;
    winner = GameState.Blank;
    _moveCount = 0;
    setState(() {
      _showWinnerDisplay = false;
    });
    _boardController.reverse();
  }

  // 检查游戏胜利条件
  void checkWinningCondition(int row, int col, GameState gameState) {
    // 如果移动次数小于5，不可能有获胜者，直接返回
    if (_moveCount < 5) {
      return;
    }

    // 检查当前位置是否包含当前玩家的标记
    if (boardState[row][col] == gameState) {
      // 检查从底部左侧到顶部右侧的对角线
      if (countConsecutiveStones(row, col, 1, -1) +
          countConsecutiveStones(row, col, -1, 1) >=
          4) {
        setWinner(gameState); // 设置获胜者
        return;
      }
      // 检查从顶部左侧到底部右侧的对角线
      if (countConsecutiveStones(row, col, -1, -1) +
          countConsecutiveStones(row, col, 1, 1) >=
          4) {
        setWinner(gameState); // 设置获胜者
        return;
      }
      // 检查水平方向
      if (countConsecutiveStones(row, col, 0, 1) +
          countConsecutiveStones(row, col, 0, -1) >=
          4) {
        setWinner(gameState); // 设置获胜者
        return;
      }
      // 检查垂直方向
      if (countConsecutiveStones(row, col, 1, 0) +
          countConsecutiveStones(row, col, -1, 0) >=
          4) {
        setWinner(gameState); // 设置获胜者
        return;
      }
    }

    // 如果移动次数达到225，表示平局
    if (_moveCount == 225) {
      print('平局');
      setWinner(GameState.Blank); // 设置平局
      return;
    }
  }

  // 检查索引是否在有效范围内
  bool inBounds(int index) {
    return index >= 0 && index < boardState.length;
  }

  // 计算在给定位置开始，特定方向上连续相同棋子类型的数量
  int countConsecutiveStones(int row, int col, int rowIncrement, int colIncrement) {
    // 初始化一个计数器
    int count = 0;
    // 获取起始位置的棋子类型
    GameState index = boardState[row][col];

    // 遍历最多四个相邻格子，以查找连续相同的棋子类型
    for (int i = 1; i <= 4; i++) {
      // 检查下一个要检查的格子是否在游戏棋盘的有效范围内
      if (inBounds(row + (rowIncrement * i)) && inBounds(col + (colIncrement * i))) {
        // 检查下一个格子上的棋子类型是否与起始位置上的棋子类型相同
        if (boardState[row + (rowIncrement * i)][col + (colIncrement * i)] == index) {
          // 如果相同，增加计数
          count++;
        } else {
          // 如果不同，中断循环，因为我们只关心连续相同棋子类型的数量
          break;
        }
      }
    }
    // 返回在指定方向上连续相同棋子类型的数量
    return count;
  }

  void setWinner(GameState gameState) {
    print('$gameState wins');
    winner = gameState;
    switch (gameState) {
      case GameState.Blank:
        {
          _draws++;
          break;
        }
      case GameState.Black:
        {
          _blackWins++;
          break;
        }
      case GameState.White:
        {
          _whiteWins++;
          break;
        }
    }
    toggleBoardOpacity();
  }

  void toggleBoardOpacity() {
    if (_boardOpacity == 0.0) {
      setState(() {
        _showWinnerDisplay = false;
      });
      _boardController.reverse();
    } else if (_boardOpacity == 1.0) {
      _boardController.forward();
      setState(() {
        _showWinnerDisplay = true;
      });
    }
  }

  void toggleActivePlayer() {
    if (activePlayer == GameState.Black)
      activePlayer = GameState.White;
    else
      activePlayer = GameState.Black;
  }

  gamePiece(int row, int col) {
    if (boardState[row][col] == GameState.Black)
      return Dot(Colors.black);
    else if (boardState[row][col] == GameState.White)
      return Dot(Colors.white);
    else
      return null;
  }
}
