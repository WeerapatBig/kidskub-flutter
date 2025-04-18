// file: line_in_world.dart
import 'dart:ui' show lerpDouble, Offset, Path;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'package:firstly/screens_chapter2/linegamehard/components/player_component.dart';
import 'package:firstly/screens_chapter2/linegamehard/game/hard_line_game.dart';

/// --------------------------------------------------------------
///  คลาส LineInWorld: เก็บและวาดเส้นในพิกัดแบบ Offset
/// --------------------------------------------------------------
class LineInWorld extends PositionComponent {
  /// จุดเริ่มและจุดปลายเป็น Offset
  Offset start;
  Offset end;

  /// flag ว่าเส้นนี้ล็อค (ยืนยัน) แล้วหรือไม่
  bool isLocked = false;

  /// สีของเส้น
  Color color = Colors.blue;

  /// ระยะสำหรับโค้ง (handler)
  double controlOffset = 0;

  /// handler (จุด control สำหรับ Quadratic Bezier)
  Offset? handler;

  /// constructor
  LineInWorld({
    required Offset startPos,
    required Offset endPos,
    required super.priority,
  })  : start = startPos,
        end = endPos,
        super(
          size: Vector2(1, 1), // สมมติให้ขนาด component = (1,1) ไปก่อน
          anchor: Anchor.topLeft,
        );

  /// ฟังก์ชัน setEnd() ถ้าคุณจะเรียกจาก onDragUpdate
  void setEnd(Offset newEnd) {
    end = newEnd;
  }

  /// ฟังก์ชันคำนวณ handler สำหรับความโค้ง
  void calculateHandler() {
    // หา midpoint
    final midpoint = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );
    // ตรวจทิศซ้าย->ขวาหรือเปล่า
    final isLeftToRight = end.dx > start.dx;
    // direction = เวกเตอร์ตั้งฉาก
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;

    // สมมติถ้าเป็นซ้าย->ขวา ให้ใช้ (dy, -dx)
    // ถ้าเป็นขวา->ซ้าย ให้ใช้ ( -dy, dx ) ก็ได้ (แล้วแต่ logic เดิม)
    final direction = isLeftToRight ? Offset(dy, -dx) : Offset(-dy, dx);

    final dirNormalized = direction.normalize();
    handler = midpoint + dirNormalized * controlOffset;
  }

  /// การวาดเส้นโค้ง
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // ถ้ายังไม่เคยคำนวณ handler => คำนวณเบื้องต้น
    handler ??= (() {
      final midpoint = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2,
      );
      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;
      final direction = Offset(dy, -dx).normalize();
      return midpoint + direction * controlOffset;
    })();

    // สร้าง path แบบ quadratic bezier
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(
        handler!.dx,
        handler!.dy,
        end.dx,
        end.dy,
      );

    canvas.drawPath(path, paint);
  }
}

/// --------------------------------------------------------------
///  เอฟเฟกต์: LineRemoveEffect (Fade จางแล้วลบ)
/// --------------------------------------------------------------
class LineRemoveEffect extends Effect {
  final LineInWorld line;
  final Color originalColor;

  LineRemoveEffect({
    required this.line,
    required this.originalColor,
    required EffectController controller,
  }) : super(controller);

  @override
  void apply(double progress) {
    // alpha = 255*(1 - progress)
    final alphaValue = (255 * (1 - progress)).clamp(0, 255).toInt();
    line.color = originalColor.withAlpha(alphaValue);
  }

  @override
  void onFinish() {
    super.onFinish();
    line.removeFromParent();
  }
}

/// --------------------------------------------------------------
///  เอฟเฟกต์: CustomPullBackEffect (ดึงเส้นกลับ)
/// --------------------------------------------------------------
class CustomPullBackEffect extends Effect with HasGameRef<HardLineGame> {
  final LineInWorld line;
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
      // เคลื่อน end ของเส้นเข้าใกล้ start
      line.end = newPos;
      // ดึงค่าความโค้งกลับเป็น 0
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

/// --------------------------------------------------------------
/// เอฟเฟกต์: LineFollowEffect (Player ตามเส้นโค้ง)
/// --------------------------------------------------------------
class LineFollowEffect extends Effect with HasGameRef<HardLineGame> {
  final MyPlayerComponent player;
  final LineInWorld line;
  final void Function()? onFinishCallback;

  /// จุดปลายปลอม (endPseudo) = end - direction*30 (หรือ 80)
  late Offset startPseudo; // ✅ จุดเริ่มต้นจริง (ตำแหน่งผู้เล่นตอนเริ่ม)
  late Offset endPseudo;

  LineFollowEffect({
    required this.player,
    required this.line,
    required EffectController controller,
    this.onFinishCallback,
  }) : super(controller);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // คำนวณ endPseudo
    final start = line.start;
    final end = line.end;
    final dir = (end - start).normalize();
    endPseudo = end - dir * 30; // ระยะ 30 px หรือ 80 px ตามต้องการ
    startPseudo = Offset(
        player.position.x, player.position.y); // ✅ ใช้ตำแหน่งปัจจุบันของ Player
  }

  @override
  void apply(double progress) {
    // ✅ หยุด Player ทันทีหาก isGameOver เป็น true
    if (gameRef.isGameOver) {
      removeFromParent(); // ลบ effect ออกเพื่อหยุดการเคลื่อนที่
      return;
    }
    final s = startPseudo;
    final c = line.handler ?? s; // ถ้ายังไม่คำนวณ => fallback = start
    final e = endPseudo;

    final t = progress;
    final mt = (1 - t);

    // สูตร B(t) = (1-t)^2 * s + 2(1-t)t*c + t^2*e
    final x = mt * mt * s.dx + 2 * mt * t * c.dx + t * t * e.dx;
    final y = mt * mt * s.dy + 2 * mt * t * c.dy + t * t * e.dy;

    // player ใช้ Vector2 => แปลง x,y => Vector2
    player.position = Vector2(x, y);
  }

  @override
  void onFinish() {
    super.onFinish();
    onFinishCallback?.call();
  }
}

/// --------------------------------------------------------------
/// Extension: ช่วย normalize( ) ของ Offset
/// --------------------------------------------------------------
extension OffsetNormalize on Offset {
  Offset normalize() {
    final len = distance;
    return len == 0 ? this : this / len;
  }
}
