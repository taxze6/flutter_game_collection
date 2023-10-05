import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:ui' as ui;

import 'package:gomoku_ai/model/common.dart';

import 'model/chessman.dart';
import 'model/player.dart';

//默认棋盘的行列数
const int LINE_COUNT = 14;
double cellWidth = 0, cellHeight = 0;

class ChessmanPaint extends CustomPainter {
  late Canvas canvas;
  late Paint painter;
  static const bool printLog = true;

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;
    cellWidth = size.width / LINE_COUNT;
    cellHeight = size.height / LINE_COUNT;
    painter = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = Color(0x77cdb175);
    //Offset.zero表示矩形范围的左上角坐标为原点(0,0)，size表示矩形的大小。
    //这个表达式使用&符号将两个对象合并成了一个Rect对象作为canvas.drawRect()方法的第一个参数。
    //实际上，&符号在这里是Dart语言中的语法糖，等效于使用Rect.fromLTWH(0, 0, size.width, size.height)来创建一个矩形。
    //因此，这里的语法可以通过Rect.fromLTWH(0, 0, size.width, size.height)来替代
    canvas.drawRect(Offset.zero & size, painter);

    painter
      ..style = PaintingStyle.stroke
      ..color = Colors.black87
      ..strokeWidth = 1.0;

    for (int i = 0; i <= LINE_COUNT; ++i) {
      double y = cellHeight * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), painter);
      //再棋子上绘制id
      if (printLog) {
        _drawText((i.toString()),
            Offset(-19, y - _calcTrueTextSize(i.toString(), 15.0).dy / 2));
      }
    }

    for (int i = 0; i <= LINE_COUNT; ++i) {
      double x = cellWidth * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), painter);
      if (printLog) {
        _drawText(i.toString(),
            Offset(x - _calcTrueTextSize(i.toString(), 15.0).dx / 2, -18));
      }
    }
    _drawMarkPoints();

    if (chessmanList.isNotEmpty) {
      for (Chessman c in chessmanList) {
        _drawChessman(c);
      }
    }

    //胜利的地方画横线
    if (winResult.isNotEmpty) {
      painter
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;
      Offset start = Offset(winResult.first.position.dx * cellWidth,
          winResult.first.position.dy * cellHeight);
      Offset end = Offset(winResult.last.position.dx * cellWidth,
          winResult.last.position.dy * cellHeight);
      canvas.drawLine(start, end, painter);
    }
  }

  //绘制棋盘上的5个黑点
  void _drawMarkPoints() {
    // 通过多次调用_drawMarkPoint方法来绘制标记点
    _drawMarkPoint(const Offset(7.0, 7.0));
    _drawMarkPoint(const Offset(3.0, 3.0));
    _drawMarkPoint(const Offset(3.0, 11.0));
    _drawMarkPoint(const Offset(11.0, 3.0));
    _drawMarkPoint(const Offset(11.0, 11.0));
  }

  void _drawMarkPoint(Offset offset) {
    painter
      ..style = PaintingStyle.fill
      ..color = Colors.black;

    // 计算标记点在画布上的具体位置
    Offset center = Offset(offset.dx * cellWidth, offset.dy * cellHeight);

    // 在计算得到的位置绘制一个半径为3的圆形标记点
    canvas.drawCircle(center, 3, painter);
  }

  //绘制棋子
  void _drawChessman(Chessman chessman) {
    painter
      ..style = PaintingStyle.fill
      ..color = chessman.owner.color;

    Offset center = Offset(
        chessman.position.dx * cellWidth, chessman.position.dy * cellHeight);
    //这里使用min(cellWidth / 2, cellHeight / 2) - 2计算出较小的一边长度减去2作为圆的半径，可以使得所有棋子的大小一致，并且不会越出格子范围。
    canvas.drawCircle(center, min(cellWidth / 2, cellHeight / 2) - 2, painter);

    //如果当前棋子的编号是最后一枚棋子，则使用painter绘制一个描边的蓝色圆圈，表示这是最后下的一枚棋子。
    if (chessman.numberId == chessmanList.length - 1) {
      painter
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(
          center, min(cellWidth / 2, cellHeight / 2) - 2, painter);
    }

    if (printLog) {
      double fontSize = 12.0;
      Offset textSize =
          _calcTrueTextSize(chessman.numberId.toString(), fontSize);
      _drawText(chessman.numberId.toString(),
          Offset(center.dx - (textSize.dx / 2), center.dy - (textSize.dy / 2)),
          color: chessman.owner == Player.black ? Colors.white : Colors.black,
          textSize: fontSize);
    }
  }

  void _drawText(String text, Offset offset, {Color? color, double? textSize}) {
    // 创建ParagraphBuilder对象，用于构建文本段落
    ui.ParagraphBuilder builder = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.center,
      ellipsis: '...',
      maxLines: 1,
    ));

    // 使用pushStyle方法设置文本风格，包括颜色和字体大小
    builder.pushStyle(
        ui.TextStyle(color: color ?? Colors.red, fontSize: textSize ?? 15.0));

    // 添加文本到builder对象中
    builder.addText(text);

    // 构建一个Paragraph对象
    ui.Paragraph paragraph = builder.build();

    // 对paragraph进行layout，指定宽度为无限大
    paragraph.layout(const ui.ParagraphConstraints(width: double.infinity));

    // 在Canvas上绘制paragraph对象，位置为offset
    canvas.drawParagraph(paragraph, offset);
  }

  //根据给定的文本字符串和字体大小，计算出该文本所占据的实际宽度和高度，以便在UI布局中更好地控制文本的位置和尺寸。
  Offset _calcTrueTextSize(String text, double textSize) {
    // 创建ParagraphBuilder对象，并设置字体大小
    var paragraph = ui.ParagraphBuilder(ui.ParagraphStyle(fontSize: textSize))
      ..addText(text);

    // 构建Paragraph对象，并进行layout，指定宽度为无限大
    var p = paragraph.build()
      ..layout(const ui.ParagraphConstraints(width: double.infinity));

    // 返回Paragraph对象的最小内在宽度和高度作为偏移量
    return Offset(p.minIntrinsicWidth, p.height);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return chessmanList.isNotEmpty;
  }
}
