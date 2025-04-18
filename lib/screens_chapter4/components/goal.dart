import 'dart:ui';
import 'package:firstly/screens_chapter4/components/grid.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// สีทั้งหมดของ Goal (ใช้ 3 สีแรกก่อน)
final List<Color> goalColors = [
  const Color.fromARGB(255, 249, 72, 59),
  const Color.fromARGB(255, 76, 183, 205),
  const Color.fromARGB(255, 255, 170, 46),
  Colors.green,
  Colors.purple,
  const Color.fromARGB(255, 255, 109, 52),
];

class GoalComponent extends PositionComponent with CollisionCallbacks {
  final Color colorTarget;
  final Vector2 spawnPosition;

  GoalComponent(this.spawnPosition, this.colorTarget) {
    // ตั้งขนาด Goal (วงกลม) และให้ anchor = topLeft
    size = Vector2(40, 40);
    anchor = Anchor.center;

    // แปลงพิกัดในตารางเป็นตำแหน่งบนจอ
    position = toPixelCenter(spawnPosition);
    priority = 1;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 1) ระยะรัศมี
    final r = size.x / 2;

    // 2) วาดวงกลมสี (Fill)
    final paintFill = Paint()..color = colorTarget;
    canvas.drawCircle(Offset(r, r), r, paintFill);

    // 3) วาดขอบ (Stroke) หนา 6
    final paintStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.black; // ปรับสีขอบได้ตามต้องการ
    canvas.drawCircle(Offset(r, r), r, paintStroke);
  }

  /// รัศมีของวงกลม (สมมติเส้นผ่านศูนย์กลาง = 40)
  double get radius => size.x / 2;

// ฟังก์ชันย้ายตำแหน่ง
  void moveTo(Vector2 newPosition) {
    position = toPixelCenter(newPosition);
  }

  /// หา "จุดศูนย์กลาง" ของ Goal ในพิกเซล
  /// เพราะ anchor = topLeft => center = (x + 20, y + 20)
  Vector2 getCenter() {
    return Vector2(x + radius, y + radius);
  }
}
