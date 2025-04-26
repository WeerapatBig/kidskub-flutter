import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../logic_game_color_quiz/logic_color_quiz_intro.dart';

class ColorWheelComponent extends SpriteComponent with HasGameReference {
  final List<String> acceptedMixColors; // เช่น ['red', 'blue']
  final String? mixedColorResult;
  final Map<String, bool> filledColors = {};
  ColorWheelComponent({
    required String imagePath,
    required Vector2 position,
    required double angleRad,
    this.acceptedMixColors = const [],
    this.mixedColorResult,
    double scaleFactor = 0.35,
  }) : super(
          position: position,
          angle: angleRad,
          anchor: Anchor.center,
        ) {
    _imagePath = imagePath;
    _scaleFactor = scaleFactor;
  }

  late final String _imagePath;
  late final double _scaleFactor;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(_imagePath);

    final imgSize = sprite!.srcSize;
    size = Vector2(imgSize.x * _scaleFactor, imgSize.y * _scaleFactor);
    add(RectangleHitbox()); // ✅ สำคัญมาก

    for (final color in acceptedMixColors) {
      filledColors[color] = false;
    }
  }

  Future<void> tryFill(String colorType) async {
    debugPrint('[Slot] tryFill: $colorType | accepted: $acceptedMixColors');

    if (!acceptedMixColors.contains(colorType)) {
      debugPrint('❌ [$colorType] is not accepted by this slot');
      return;
    }

    filledColors[colorType] = true;

    debugPrint('✅ [$colorType] added. filledColors: $filledColors');

    // ถ้าครบตามคู่ผสม
    final isComplete = filledColors.values.every((v) => v == true);

    if (isComplete && mixedColorResult != null) {
      final path =
          'colorgame/quiz_color/colors_wheel/${mixedColorResult!}_color.png';
      sprite = await Sprite.load(path);
      debugPrint('🎉 สีผสมสำเร็จ → Change to $mixedColorResult!');
      if (game is GameColorQuizIntro) {
        final myGame = game as GameColorQuizIntro;
        myGame.completedColors.add(mixedColorResult!);

        if (myGame.completedColors.containsAll(['purple', 'green', 'orange'])) {
          if (myGame.onCompleteLevel != null) {
            myGame.onCompleteLevel!(); // ✅ แจ้งจบด่าน!
          }
        }
      }
    } else {
      final path = 'colorgame/quiz_color/colors_wheel/${colorType}_color.png';
      sprite = await Sprite.load(path);
      debugPrint('🟢 ยังไม่ครบ → เปลี่ยนเป็นแม่สี $colorType');
    }
  }

  // Future<void> _changeToMixedColor() async {
  //   const path = 'colorgame/quiz_color/colors_wheel/purple_color.png';
  //   sprite = await Sprite.load(path);
  // }

  @override
  Rect toRect() => Rect.fromCenter(
      center: position.toOffset(), width: size.x, height: size.y);
}
