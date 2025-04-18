import 'package:firstly/screens_chapter4/components/grid.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../logic/game_color_logic.dart';

class EnemyComponent extends PositionComponent with HasGameRef<ColorGame> {
  Vector2 gridPosition = Vector2(1, 1); // จุดเริ่มต้น Enemy (เช่น (1,1))
  // ขนาด/สไปรต์ของ Enemy
  late Sprite idleSprite;
  late Sprite currentSprite;

  EnemyComponent() {
    size = Vector2(85, 90);
    anchor = Anchor.center;
    // แปลงตำแหน่งจาก Grid -> Pixel
    position = toPixelCenter(gridPosition);
    priority = 2;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // โหลด sprite ถ้ามี
    idleSprite = await Sprite.load('colorgame/character/enemy.png');
    currentSprite = idleSprite;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // อัปเดตตำแหน่งบนจอให้ตรงกับ gridPosition
    position = toPixelCenter(gridPosition);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    currentSprite.render(canvas, size: size);
  }

  /// ขยับ 1 ช่องไปยัง nextPos ถ้าไม่เกินขอบ
  void moveTo(Vector2 nextPos) {
    if (isInsideGrid(nextPos)) {
      gridPosition = nextPos;
    }
  }

  @override
  Rect toRect() {
    double boxWidth = size.x * 0.7; // 70% เช่นกัน
    double boxHeight = size.y * 0.7;

    final left = x - (boxWidth / 2);
    final top = y - (boxHeight / 2);
    return Rect.fromLTWH(left, top, boxWidth, boxHeight);
  }
}
