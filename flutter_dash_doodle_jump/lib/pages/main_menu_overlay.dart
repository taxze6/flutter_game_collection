import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dash_doodle_jump/flutter_dash_doodle_jump.dart';

class MainMenuOverlay extends StatefulWidget {
  const MainMenuOverlay({Key? key, required this.game}) : super(key: key);

  final Game game;

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay> {
  @override
  Widget build(BuildContext context) {
    FlutterDashDoodleJump game = widget.game as FlutterDashDoodleJump;
      return Material(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child:
                  Image.asset("assets/images/game/background/background.png"),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Image.asset(
                              "assets/images/game/dash_hat_center.png",
                              height: 50,
                              width: 50,
                            ),
                            const Text(
                              'Flutter Dash Doodle Jump',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                fontFamily: "DaveysDoodleface",
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const WhiteSpace(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '难度选择:',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            LevelPicker(
                              level: game.levelManager.selectedLevel.toDouble(),
                              label: game.levelManager.selectedLevel.toString(),
                              onChanged: ((value) {
                                setState(() {
                                  game.levelManager.selectLevel(value.toInt());
                                });
                              }),
                            ),
                          ],
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              game.startGame();
                            },
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(
                                const Size(100, 50),
                              ),
                              textStyle: MaterialStateProperty.all(
                                  Theme.of(context).textTheme.titleLarge),
                            ),
                            child: const Text(
                              'Start',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                fontFamily: "DaveysDoodleface",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }
}

class LevelPicker extends StatelessWidget {
  const LevelPicker({
    super.key,
    required this.level,
    required this.label,
    required this.onChanged,
  });

  final double level;
  final String label;
  final Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Slider(
      value: level,
      max: 5,
      min: 1,
      divisions: 4,
      label: label,
      onChanged: onChanged,
    ));
  }
}

class WhiteSpace extends StatelessWidget {
  const WhiteSpace({super.key, this.height = 100});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
    );
  }
}
