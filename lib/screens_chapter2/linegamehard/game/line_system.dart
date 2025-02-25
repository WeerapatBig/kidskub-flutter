// lib/game/line_system.dart
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:firstly/screens_chapter2/linegamehard/components/player_component.dart';
import 'hard_line_game.dart';

/// Line (Quadratic Bezier)
class Line extends PositionComponent {
  Offset start;
  Offset end;
  bool isLocked = false;
  Offset? handler;
  double controlOffset = 0;
  Color color = Colors.blue;

  Line(this.start, this.end);

  /// ถ้าจำเป็นต้อง onLoad() อะไรก็เพิ่มได้
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // โค้ดวาดเส้นเดิมที่เคยมีใน renderLine()
    final paint = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // ตัวอย่าง quadratic bezier (สมมติ)
    final path = Path()..moveTo(start.dx, start.dy);

    // ถ้าคุณใช้ logic handler = midpoint + perpendicular * controlOffset
    // ให้คำนวณก่อน draw
    final midpoint = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );
    final direction = Offset(end.dy - start.dy, start.dx - end.dx).normalize();
    handler = midpoint + direction * controlOffset;

    path.quadraticBezierTo(
      handler!.dx,
      handler!.dy,
      end.dx,
      end.dy,
    );

    canvas.drawPath(path, paint);
  }

  void calculateHandler() {
    final midpoint = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    // ตรวจสอบว่าผู้เล่นลากจากซ้ายไปขวาหรือขวาไปซ้าย
    final isLeftToRight = end.dx > start.dx;

    // กำหนดเวกเตอร์ตั้งฉากให้สัมพันธ์กับทิศทางของเส้น
    final direction = isLeftToRight
        ? Offset(end.dy - start.dy, start.dx - end.dx) // ซ้ายไปขวา
        : Offset(start.dy - end.dy, end.dx - start.dx); // ขวาไปซ้าย
    handler = midpoint + direction.normalize() * controlOffset;
  }

  // void renderLine(Canvas canvas) {
  //   final paint = Paint()
  //     ..color = color
  //     ..strokeWidth = 10
  //     ..style = PaintingStyle.stroke
  //     ..strokeCap = StrokeCap.round;

  //   final path = Path()
  //     ..moveTo(start.dx, start.dy)
  //     ..quadraticBezierTo(
  //       handler?.dx ?? start.dx,
  //       handler?.dy ?? start.dy,
  //       end.dx,
  //       end.dy,
  //     );
  //   canvas.drawPath(path, paint);
  // }
}

// โค้ดใหม่: LineRemoveEffect
class LineRemoveEffect extends Effect {
  final Line line;
  final Color originalColor;

  LineRemoveEffect({
    required this.line,
    required this.originalColor,
    required EffectController controller,
  }) : super(controller);

  @override
  void apply(double progress) {
    // 1) คำนวณ alpha จาก (1 - progress)
    final alpha = (255 * (1 - progress)).round().clamp(0, 255);
    // 2) สร้างสีใหม่ โดยคง hue,sat,val ของ originalColor แต่ alpha ลดลง
    final newColor = originalColor.withAlpha(alpha);
    // 3) ใส่กลับไปใน line.color
    line.color = newColor;
  }

  @override
  void onFinish() {
    super.onFinish();
    // หลังแอนิเมชั่น => ลบเส้นออก
    line.removeFromParent();
  }
}

/// เอฟเฟกต์ดึงเส้นกลับ
class CustomPullBackEffect extends Effect with HasGameRef<HardLineGame> {
  final Line line;
  final Offset from;
  final Offset to;

  CustomPullBackEffect({
    required this.line,
    required this.from,
    required this.to,
    required EffectController controller,
  }) : super(controller);

  @override
  void apply(double progress) {
    final newPos = Offset.lerp(from, to, progress);
    if (newPos != null) {
      line.end = newPos;
      line.controlOffset = lerpDouble(line.controlOffset, 0, progress) ?? 0.0;
      line.calculateHandler();
    }
  }

  @override
  void onFinish() {
    super.onFinish();
    line.controlOffset = 0;
    line.calculateHandler();
  }
}

/// เอฟเฟกต์ให้ Player เคลื่อนที่ตามเส้นโค้ง (Bezier)
class LineFollowEffect extends Effect {
  final MyPlayerComponent player;
  final Line line;
  final void Function()? onFinishCallback;

  // สร้าง endPseudo ไว้เก็บ “จุดปลาย - 30 px”
  late Offset endPseudo;

  LineFollowEffect({
    required this.player,
    required this.line,
    required EffectController controller,
    this.onFinishCallback,
  }) : super(controller);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // คำนวณ endPseudo
    final start = line.start;
    final end = line.end;
    final dir = (end - start).normalize();
    // shift = dir * 30
    endPseudo = end - dir * 80;
  }

  @override
  void apply(double progress) {
    final s = line.start;
    final e = endPseudo;
    final c = line.handler ?? s;
    final t = progress;

    // B(t) = (1-t)^2*s + 2(1-t)*t*c + t^2* e
    final x =
        (1 - t) * (1 - t) * s.dx + 2 * (1 - t) * t * c.dx + (t * t) * e.dx;
    final y =
        (1 - t) * (1 - t) * s.dy + 2 * (1 - t) * t * c.dy + (t * t) * e.dy;

    player.position = Vector2(x, y);
  }

  @override
  void onFinish() {
    super.onFinish();
    // ถ้ามี callback อื่น
    onFinishCallback?.call();
  }
}

/// Extension: normalize เวกเตอร์
extension OffsetNormalize on Offset {
  Offset normalize() {
    final len = distance;
    return len == 0 ? this : this / len;
  }
}
