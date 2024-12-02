import 'package:flutter/material.dart';

class Particle {
  final Offset start;
  final Offset end;
  double opacity;
  double width; // ความกว้างของเส้นที่เปลี่ยนแปลงได้

  Particle({
    required this.start,
    required this.end,
    required this.opacity,
    required this.width,
  });

  Particle fade() {
    return Particle(
      start: start,
      end: end,
      opacity: opacity - 0.04, // ลด opacity
      width: width * 0.8, // ค่อยๆ ลดความกว้างของเส้น
    );
  }
}

class ParticleTailPainter extends CustomPainter {
  final List<Particle> particles;

  ParticleTailPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var particle in particles) {
      // ตรวจสอบให้แน่ใจว่า opacity อยู่ในช่วง 0.0 ถึง 1.0
      double validOpacity = particle.opacity.clamp(0.0, 1.0);

      // ตรวจสอบว่าค่าของ particle ไม่เป็น null หรือ NaN ก่อนวาด
      if (particle.start != null && particle.end != null) {
        if (!particle.start.dx.isNaN &&
            !particle.start.dy.isNaN &&
            !particle.end.dx.isNaN &&
            !particle.end.dy.isNaN) {
          paint.color =
              const Color.fromARGB(255, 76, 183, 205).withOpacity(validOpacity);
          paint.strokeWidth = particle.width;
          canvas.drawLine(particle.start, particle.end, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(ParticleTailPainter oldDelegate) {
    return true; // ให้วาดใหม่ทุกครั้ง
  }
}
