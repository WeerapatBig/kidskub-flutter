// lib/components/moving_obstacle_component.dart

import 'package:firstly/screens_chapter2/linegamehard/game/hard_line_game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

class RectangleObstacleComponent extends SpriteComponent
    with CollisionCallbacks, HasGameRef<HardLineGame> {
  final String spritePath;

  RectangleObstacleComponent(
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

    add(RectangleHitbox()
      ..collisionType = CollisionType.passive
      ..size = size * 0.4
      ..debugColor = Colors.blue);
  }
}
