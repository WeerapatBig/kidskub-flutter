// lib/components/star_component.dart

import 'package:firstly/screens_chapter2/linegamehard/game/hard_line_game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

class StarComponent extends SpriteComponent
    with CollisionCallbacks, HasGameRef<HardLineGame> {
  StarComponent({
    required super.position,
    required super.priority,
    required super.size,
  }) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // * แก้ path ให้ตรง asset ของคุณ *
    sprite = await gameRef.loadSprite('linegamelist/star_elm.png');

    add(CircleHitbox()
      ..radius = size.x * 0.15
      ..collisionType = CollisionType.passive
      ..debugColor = Colors.blue);
  }
}
