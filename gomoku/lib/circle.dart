import 'package:flutter/material.dart';

class Dot extends StatelessWidget {
  final Color color;

  const Dot(this.color);

  @override
  Widget build(BuildContext context) {
    return color == Colors.black
        ? Image.asset("assets/images/mooncake.png")
        : Image.asset("assets/images/rabbit.png");
  }
}
