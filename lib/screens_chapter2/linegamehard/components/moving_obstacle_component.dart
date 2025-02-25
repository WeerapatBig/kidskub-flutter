// lib/components/moving_obstacle_component.dart

import 'package:firstly/screens_chapter2/linegamehard/game/hard_line_game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

class MovingObstacleComponent extends SpriteComponent
    with CollisionCallbacks, HasGameRef<HardLineGame> {
  bool goingDown = false; // สถานะว่าตอนนี้เคลื่อนที่ลงหรือไม่
  double speed = 100; // ความเร็ว px/s
  late double topY; // ขอบบน
  late double bottomY; // ขอบล่าง
  double elapsedTime = 0.0; // เวลาที่ผ่านไป

  MovingObstacleComponent({
    required super.position,
    required super.size,
    required super.priority,
  }) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // * แก้ path ให้ตรง asset ของคุณ *
    sprite = await gameRef.loadSprite('linegamelist/obstacle/moving_obs.png');

    add(RectangleHitbox()
      ..collisionType = CollisionType.passive
      ..size = size * 0.4
      ..debugColor = Colors.blue);

    topY = position.y - 80;
    bottomY = position.y + 20;
  }

  @override
  void update(double dt) {
    super.update(dt);
    elapsedTime += dt;

    // ถ้าครบ 10 วินาที ให้รีเซ็ตเวลา
    if (elapsedTime >= 10.0) {
      elapsedTime = 0.0;
    }

    // ถ้าถึงวินาทีที่ 3 หรือ 6 ให้เริ่มตกลงมา
    if (elapsedTime >= 1.0 && elapsedTime < 1.1) {
      goingDown = true;
    } else if (elapsedTime >= 6.0 && elapsedTime < 6.1) {
      goingDown = true;
    } else if (elapsedTime >= 6.0 && elapsedTime < 6.1) {
      goingDown = true;
    }

    // เคลื่อนที่ลง
    if (goingDown) {
      position.y += speed * dt;

      // ถ้าถึงจุดล่าง => หยุด
      if (position.y >= bottomY) {
        position.y = bottomY;
        goingDown = false;
      }
    } else {
      // เคลื่อนขึ้น
      position.y -= speed * dt;

      // ถ้าถึงจุดบน => หยุด
      if (position.y <= topY) {
        position.y = topY;
      }
    }
  }
}
