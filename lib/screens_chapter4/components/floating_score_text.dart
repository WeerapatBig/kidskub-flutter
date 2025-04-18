import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

class FloatingScoreText extends TextComponent {
  final double duration; // เวลาที่จะลอยก่อนหาย (วินาที)
  double _timer = 0;

  final double moveSpeed; // ความเร็วในการเลื่อนขึ้น
  final Color textColor;

  // เพิ่ม TextPaint สำหรับ Stroke กับ Fill แยกกัน
  late final TextPaint _strokePaint;
  late final TextPaint _fillPaint;

  FloatingScoreText({
    required String text,
    required Vector2 position,
    this.duration = 1.0,
    this.moveSpeed = 30.0,
    this.textColor = Colors.white,
  }) {
    // กำหนดข้อความและตำแหน่ง
    this.text = text;
    this.position = position;
    anchor = Anchor.bottomCenter;

    // 1) สร้าง TextPaint สำหรับ Stroke
    _strokePaint = TextPaint(
      style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w900,
        fontFamily: 'Kodchasan', // ตรงกับ family ใน pubspec
        // foreground: Paint() ใช้เป็นสีกับเส้นขอบ
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8 // อยากหนาเท่าไหร่ปรับได้
          ..color = Colors.black, // สีขอบ
      ),
    );

    // 2) สร้าง TextPaint สำหรับ Fill
    _fillPaint = TextPaint(
      style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w900,
        fontFamily: 'Kodchasan',
        color: textColor, // ใช้ color ธรรมดา
      ),
    );
  }

  @override
  Future<void> onLoad() async {
    // ปกติ TextComponent จะใช้ textRenderer ในการ render
    // แต่เราจะ override ใน render() เอง ไม่จำเป็นต้องกำหนด textRenderer ก็ได้
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    // วาด 'stroke' ก่อน
    _strokePaint.render(canvas, text, Vector2.zero());
    // วาด 'fill' ทับ
    _fillPaint.render(canvas, text, Vector2.zero());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    // เลื่อนขึ้น
    y -= moveSpeed * dt;

    // ถ้าผ่านไปเกิน duration -> ลบตัวเอง
    if (_timer >= duration) {
      removeFromParent();
    }
  }
}
