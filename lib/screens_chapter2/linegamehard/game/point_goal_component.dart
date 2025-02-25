import 'dart:ui';

import 'package:firstly/screens_chapter2/linegamehard/game/hard_line_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class PointGoalComponent extends PositionComponent
    with CollisionCallbacks, HasGameRef<HardLineGame> {
  PointGoalComponent({
    required Vector2 position,
    Vector2? size,
  }) : super(
          position: position,
          size: size ?? Vector2.all(30),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // สมมติให้วาดจุดเป็นวงกลมสีแดง หรือใช้ sprite ก็ได้
    // ถ้าเอา sprite:
    // final spr = await gameRef.loadSprite('my_point.png');
    // sprite = spr;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // ถ้าไม่ใช้ sprite => วาดวงกลมเอง
    final paintStroke = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    final paintFill = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;

    final r = size.x / 2;
    // วาดเส้นขอบ
    canvas.drawCircle(Offset(r, r), r, paintStroke);
    // วาด fill
    canvas.drawCircle(Offset(r, r), r, paintFill);
  }
}
