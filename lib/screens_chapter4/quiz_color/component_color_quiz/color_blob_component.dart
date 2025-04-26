import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../logic_game_color_quiz/logic_color_quiz_intro.dart';
import 'color_wheel_component.dart';

class ColorBlobComponent extends CircleComponent
    with DragCallbacks, HasGameReference {
  final String colorType;
  final double radius;
  final void Function()? onBlobRemoved;

  static bool redTriggered = false; // ✅ สำหรับ "ส่งครั้งเดียว"

  late final Paint fillPaint;
  final Paint strokePaint = Paint()
    ..color = const Color(0xFF212121)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 6.0;

  ColorBlobComponent({
    required this.colorType,
    required Vector2 position,
    this.radius = 30,
    this.onBlobRemoved,
  }) : super(
          position: position,
          radius: 30,
          paint: Paint()..color = _colorFromType(colorType),
          anchor: Anchor.center,
        );

  /// Map ชื่อไปเป็นสีจริง
  static Color _colorFromType(String type) {
    switch (type) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    fillPaint = Paint()..color = _colorFromType(colorType);
    add(CircleHitbox());
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    final slots = game.descendants().whereType<ColorWheelComponent>();

    debugPrint('--- Drag End ---');
    debugPrint('Blob pos: ${position.toOffset()}');
    for (final slot in slots) {
      final slotPos = slot.absolutePosition;
      final distance = position.distanceTo(slotPos);

      debugPrint(
          'Slot at: $slotPos | Blob at: $position | Distance: $distance');

      if (distance < 80) {
        debugPrint('✅ Match by distance < 80');
        slot.tryFill(colorType);
        if (colorType == 'red' &&
            !redTriggered &&
            game is GameColorQuizIntro &&
            (game as GameColorQuizIntro).onFirstRedDone != null) {
          redTriggered = true; // ❗️ล็อคไม่ให้ส่งอีก
          (game as GameColorQuizIntro).onFirstRedDone!();
        }
        removeFromParent();
        return;
      }
    }

    debugPrint('❌ ไม่มี slot ตรงกับตำแหน่ง blob → ลบทิ้ง');
    removeFromParent();
  }

  @override
  void onRemove() {
    super.onRemove();
    onBlobRemoved?.call(); // ✅ แจ้ง segment ว่า blob หายแล้ว
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final center = size / 2;
    canvas.drawCircle(center.toOffset(), radius, fillPaint); // วาดวงกลมหลัก
    canvas.drawCircle(center.toOffset(), radius, strokePaint); // วาดขอบสีขาว
  }
}
