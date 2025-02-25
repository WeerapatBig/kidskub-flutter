// lib/components/obstacle_component.dart

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../game/hard_line_game.dart';

class ObstacleComponent extends SpriteComponent
    with CollisionCallbacks, HasGameRef<HardLineGame> {
  final String spritePath;
  ObstacleComponent(
      {required this.spritePath,
      required super.position,
      required super.size,
      required super.priority,
      required super.angle})
      : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // * แก้ path ให้ตรง asset ของคุณ *
    sprite = await gameRef.loadSprite(spritePath);

    // เพิ่ม PolygonHitbox รูปร่างเอง
    add(PolygonHitbox([
      Vector2(size.x * 0.46, 0),
      Vector2(size.x * 0.54, 0),
      Vector2(size.x * 1, size.y * 0.95),
      Vector2(size.x * 1, size.y * 1),
      Vector2(size.x * 0.01, size.y * 1),
      Vector2(size.x * 0.01, size.y * 0.95),
    ])
      ..collisionType = CollisionType.passive
      ..debugColor = Colors.blue);
  }
}
