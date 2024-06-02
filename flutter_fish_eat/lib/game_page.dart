import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fish_eat/game_utils.dart';
import 'package:flutter_fish_eat/model/my_fish.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late HardwareKeyboard hardwareKeyboard;
  GameState gameState = GameState.notStart;
  bool isBoss = false;
  MyFish? myFish;

  Timer? _timer;

  void startGame() {
    myFish = MyFish();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      controllerMyFish();
      setState(() {});
    });
  }

  void controllerMyFish() {
    if (GameUtils.up) {
      myFish!.offset =
          Offset(myFish!.offset!.dx, myFish!.offset!.dy - myFish!.speed!);
    }
    if (GameUtils.down) {
      myFish!.offset =
          Offset(myFish!.offset!.dx, myFish!.offset!.dy + myFish!.speed!);
    }
    if (GameUtils.left) {
      myFish!.offset =
          Offset(myFish!.offset!.dx - myFish!.speed!, myFish!.offset!.dy);
      myFish!.img = GameUtils.myFishLeftImg;
    }
    if (GameUtils.right) {
      myFish!.offset =
          Offset(myFish!.offset!.dx + myFish!.speed!, myFish!.offset!.dy);
      myFish!.img = GameUtils.myFishRightImg;
    }
  }

  @override
  void initState() {
    super.initState();
    hardwareKeyboard = HardwareKeyboard.instance;
    hardwareKeyboard.addHandler((event) {
      print("event=${event.logicalKey.keyLabel}");
      print("event=${event.toStringShort()}");
      _handleKeyEvent(event);
      return true;
    });
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    GameUtils.bgImg,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: myFish!.offset?.dy,
              left: myFish!.offset?.dx,
              child: myFish!.drawFish(),
            ),
            Positioned(
                top: 20,
                left: 40,
                child: GestureDetector(
                  onTapDown: (c) {
                    GameUtils.up = true;
                  },
                  onTapUp: (c) {
                    GameUtils.up = false;
                  },
                  child: Icon(Icons.upgrade_sharp),
                ))
          ],
        ),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event.toStringShort().contains("KeyDownEvent")) {
      _handleKeyDown(event.logicalKey.keyLabel);
    } else if (event.toStringShort().contains("KeyUpEvent")) {
      _handleKeyUp(event.logicalKey.keyLabel);
    }
  }

  void _handleKeyDown(String key) {
    switch (key) {
      case "W":
        print("222");
        GameUtils.up = true;
        print("222");
        break;
      case "A":
        GameUtils.left = true;
        break;
      case "S":
        GameUtils.down = true;
        break;
      case "D":
        GameUtils.right = true;
        break;
      case "":
        print('space key pressed');
        break;
      default:
        break;
    }
  }

  void _handleKeyUp(String key) {
    switch (key) {
      case "W":
        GameUtils.up = false;
        break;
      case "A":
        GameUtils.left = false;
        break;
      case "S":
        GameUtils.down = false;
        break;
      case "D":
        GameUtils.right = false;
        break;
      case "":
        print('space key pressed');
        break;
      default:
        break;
    }
  }
}
