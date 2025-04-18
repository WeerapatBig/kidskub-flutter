// pieces_menu.dart

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import '../data/tangram_level_data.dart';
import '../mechanic/tangram_game.dart';
import 'pieces_button.dart';

class PiecesMenu extends PositionComponent with HasGameRef<TangramGame> {
  final List<TangramShapeData> shapeList; // ดึงมาจาก LevelData
  final String bgSpritePath;
  Sprite? bgSprite;

  PiecesMenu({
    required Vector2 position,
    required Vector2 size,
    required this.shapeList,
    required this.bgSpritePath,
    required super.priority,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // โหลด sprite พื้นหลัง
    bgSprite = await gameRef.loadSprite(bgSpritePath);

    // ✅ ใช้ customPositions จาก LevelData
    for (int i = 0; i < shapeList.length; i++) {
      final data = shapeList[i];
      final positionOffset = i < gameRef.levelData.customPositions.length
          ? gameRef.levelData.customPositions[i]
          : Vector2(50 + i * 120, 50); // fallback default spacing

      final button = PieceButton(
        shapeData: data,
        initialOffset: positionOffset,
        onPressed: () {
          print('Pressed ${data.name}');
        },
        priority: 16,
      );
      add(button);
    }

    // สมมติอยากวางเป็นแนวนอน โดยแต่ละชิ้นห่างกัน 100px
    // double xOffset = 50;
    // for (final data in shapeList) {
    //   final button = PieceButton(
    //     shapeData: data,
    //     initialOffset: Vector2(xOffset, 34),
    //     onPressed: () {
    //       print('Pressed ${data.name}');
    //     },
    //   );
    //   add(button);

    //   xOffset += data.width / 3.1;
    //   // หรือกำหนด formula อื่นได้
    // }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (bgSprite != null) {
      bgSprite!.render(canvas, position: Vector2.zero(), size: size);
    } else {
      final rectPaint = Paint()..color = Colors.white.withOpacity(0.5);
      canvas.drawRect(size.toRect(), rectPaint);
    }
  }
}
