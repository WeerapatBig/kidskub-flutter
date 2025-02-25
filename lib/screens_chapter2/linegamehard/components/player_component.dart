// lib/components/player_component.dart

import 'package:firstly/screens_chapter2/linegamehard/components/circle_obstacle.dart';
import 'package:firstly/screens_chapter2/linegamehard/components/moving_obstacle_component.dart';
import 'package:firstly/screens_chapter2/linegamehard/components/obstacle_component.dart';
import 'package:firstly/screens_chapter2/linegamehard/components/rectangle_obstacle.dart';
import 'package:firstly/screens_chapter2/linegamehard/components/star_component.dart';
import 'package:firstly/screens_chapter2/linegamehard/game/hard_line_game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

/// Player หลักของเกม
class MyPlayerComponent extends SpriteComponent
    with CollisionCallbacks, HasGameRef<HardLineGame> {
  bool isInvulnerable = false;
  late TimerComponent _invulnerableTimer;

  // callback เมื่อชน obstacle หรือเก็บ star
  // final VoidCallback onHitObstacle;
  // final VoidCallback onCollectStar;

  MyPlayerComponent({
    required super.priority,
  }) : super(size: Vector2(80, 90)) {
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // โหลด sprite Player
    // * แก้ path ให้ตรง asset ของคุณ *
    sprite = await gameRef.loadSprite('linegamelist/charactor_line.png');

    // เพิ่ม hitbox
    add(CircleHitbox()
      ..collisionType = CollisionType.active
      ..radius = size.x * 0.10
      ..debugColor = Colors.red);

    // ตั้ง timer สำหรับ invulnerable (กระพริบ 2 วิ)
    _invulnerableTimer = TimerComponent(
      period: 2.0,
      repeat: false,
      onTick: () {
        isInvulnerable = false;
        opacity = 1.0;
      },
    );
    add(_invulnerableTimer);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    // ชน obstacle
    // ตรวจว่าเป็น Obstacle
    if (other is ObstacleComponent ||
        other is MovingObstacleComponent ||
        other is RectangleObstacleComponent ||
        other is CircleObstacleComponent) {
      // ถ้ายังไม่ invul => กระพริบ
      if (!isInvulnerable) {
        startInvulnerability(2.0);
        gameRef.minusHP(1);
      }
    } // ถ้าโดน Star => เก็บดาว => remove star
    else if (other is StarComponent) {
      other.removeFromParent();
      gameRef.plusStar(1);
    }
  }

  /// เริ่มโหมดกันชน 2 วิ
  void startInvulnerability(double duration) {
    isInvulnerable = true;
    _invulnerableTimer.timer
      ..stop()
      ..reset()
      ..start();
    _startBlinkEffect(duration);
  }

  /// ทำกระพริบ Opacity
  void _startBlinkEffect(double duration) {
    // สลับ 0.2 -> 1.0
    final sequence = SequenceEffect(
      [
        OpacityEffect.to(0.2, EffectController(duration: 0.2)),
        OpacityEffect.to(1.0, EffectController(duration: 0.2)),
      ],
      repeatCount: (duration / 0.4).floor(),
    );
    add(sequence);
  }
}
