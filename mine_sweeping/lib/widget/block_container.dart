import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mine_sweeping/mine_sweeping_main.dart';
import 'package:mine_sweeping/model/game_setting.dart';

class BlockContainer extends StatelessWidget {
  Color backColor;
  int value;
  BlockType blockType;

  BlockContainer({
    super.key,
    required this.backColor,
    required this.value,
    required this.blockType,
  });

  static GameSetting gameSetting = GameSetting();

  @override
  Widget build(BuildContext context) {
    Widget container;
    if (blockType == BlockType.figure) {
      //点击为数字
      container = Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backColor == const Color(0xFF5ADFD0)
              ? gameSetting.c_5ADFD0[0]
              : gameSetting.c_A0BBFF[0],
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Text(
          "${value != 0 ? value : ''}",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (blockType == BlockType.mine) {
      container = Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backColor == const Color(0xFF5ADFD0)
              ? gameSetting.c_5ADFD0[1]
              : gameSetting.c_A0BBFF[1],
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Image.asset("assets/images/flag.png"),
      );
    } else if (blockType == BlockType.label) {
      container = Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backColor == const Color(0xFF5ADFD0)
              ? gameSetting.c_5ADFD0[2]
              : gameSetting.c_A0BBFF[2],
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Image.asset("assets/images/flag.png"),
      );
    } else {
      container = Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backColor,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
      );
    }
    return container;
  }
}
