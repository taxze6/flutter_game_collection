import 'package:flutter/material.dart';

enum Dir {
  left,
  right,
}

abstract class Fish {
  Offset? offset;
  Offset? size;
  double? speed;
  double? score;
  Dir dir;

  Fish({
    this.offset,
    this.size,
    this.speed,
    this.dir = Dir.left,
    this.score,
  });

  getRect();

  drawFish();
}
