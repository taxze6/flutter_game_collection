import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/cupertino.dart';

import 'flutter_dash_doodle_jump.dart';

class World extends ParallaxComponent<FlutterDashDoodleJump> {
  @override
  Future<void> onLoad() async {
    parallax = await gameRef.loadParallax(
      [
        ParallaxImageData('game/background/background.png'),
      ],
      fill: LayerFill.width,
      repeat: ImageRepeat.repeat,
      // 视差效果
      // baseVelocity: Vector2(0, -5),
      // velocityMultiplierDelta: Vector2(0, 1.2),
    );
  }
}
