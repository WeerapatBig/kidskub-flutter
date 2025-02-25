import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class ScreenFadeTransition extends RectangleComponent {
  final void Function()? onFadeInComplete;
  final void Function()? onFadeOutComplete;
  bool hasFadedIn = false;

  ScreenFadeTransition({
    required Vector2 size,
    Color color = Colors.white,
    this.onFadeInComplete,
    this.onFadeOutComplete,
  }) : super(
          size: size,
          position: Vector2.zero(),
          anchor: Anchor.topLeft,
          paint: Paint()..color = color.withOpacity(0.0),
          priority: 10, // ให้อยู่บนสุด
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // เริ่มด้วยการ Fade เข้ามา (0 -> 1)
    add(
      OpacityEffect.to(
        1.0,
        EffectController(duration: 2), // ระยะเวลาที่ใช้ fade in
        onComplete: () {
          hasFadedIn = true;
          onFadeInComplete?.call();
          // หลัง Fade In เสร็จ เราอาจจะโหลดด่านใหม่ หรืออะไรต่อได้

          // ต่อด้วย fade out (1 -> 0)
          add(
            OpacityEffect.to(
              0.0,
              EffectController(duration: 2), // ระยะเวลาที่ fade out
              onComplete: () {
                onFadeOutComplete?.call();
                // เสร็จเฟสด์เอาท์
                removeFromParent(); // เอา component ตัวนี้ออก
              },
            ),
          );
        },
      ),
    );
  }
}
