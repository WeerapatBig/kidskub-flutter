import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ColorWheelAnchorComponent extends PositionComponent {
  ColorWheelAnchorComponent({required Vector2 center})
      : super(position: center, size: Vector2.zero(), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    // ไม่ต้องวาดอะไรเพราะเป็น pivot เฉยๆ
  }
}
