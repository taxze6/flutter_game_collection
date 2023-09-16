import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'two_player_game.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // 动画持续时间
    );

    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140033),
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 78),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animation.value,
                    child: child,
                  );
                },
                child: Image.asset("assets/images/mid_autumn_festival.jpg"),
              ),
              Column(
                children: const [
                  Text(
                    "中秋 —— 五子棋",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "中秋时节赏明月，五子棋戏月饼趣。家人欢聚情更浓，中秋团圆乐无穷。",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF6B3BBF),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              OutlinedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xFF120033)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0), // 圆角半径
                    ),
                  ),
                  side: MaterialStateProperty.all<BorderSide>(
                    BorderSide(color: Colors.white, width: 2.0), // 边框样式
                  ),
                  elevation: MaterialStateProperty.all<double>(5.0),
                ),
                onPressed: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => TwoPlayerGame(),
                    )),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  child: Text(
                    "开始游戏",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
