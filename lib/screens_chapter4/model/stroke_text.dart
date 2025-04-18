import 'package:flutter/material.dart';

class StrokeText extends StatelessWidget {
  final String text;
  final double fontSize;
  final double strokeWidth;
  final FontWeight? fontWeight;
  final Color? color;

  const StrokeText({
    Key? key,
    this.color,
    required this.text,
    required this.fontSize,
    required this.strokeWidth,
    required this.fontWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // เลเยอร์แรก: Stroke
    final strokeText = Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFamily: 'Kodchasan',
        height: 0,
        // ใช้ foreground paint แบบ stroke
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..color = Colors.black,
      ),
    );

    // เลเยอร์สอง: Fill (สีขาว)
    final fillText = Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFamily: 'Kodchasan',
        height: 0,
        color: color ?? Colors.white, // ใช้สีธรรมดา
      ),
    );

    // ซ้อนกันใน Stack โดยให้ Stroke อยู่ข้างล่าง Fill อยู่ข้างบน
    return Stack(
      children: [
        strokeText,
        fillText,
      ],
    );
  }
}
