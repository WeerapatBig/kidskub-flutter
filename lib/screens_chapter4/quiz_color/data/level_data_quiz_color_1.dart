import 'package:flutter/material.dart';

class QuizColorLevelData {
  final String objectiveImagePath;
  final List<Color> optionColors;

  QuizColorLevelData({
    required this.objectiveImagePath,
    required this.optionColors,
  });
}

// ข้อมูลสำหรับแต่ละเลเวล
final List<QuizColorLevelData> quizColorLevels = [
  QuizColorLevelData(
    objectiveImagePath: 'assets/images/colorgame/quiz_color/objective_1.png',
    optionColors: [
      const Color(0xFF4DA7DB), // ฟ้า
      const Color(0xFFEA4C3D), // แดง
      const Color(0xFF93D34F), // เขียว
      const Color(0xFFF8C545), // เหลือง
    ],
  ),
  QuizColorLevelData(
    objectiveImagePath: 'assets/images/colorgame/quiz_color/objective_2.png',
    optionColors: [
      const Color(0xFFB268A3), // ม่วง
      const Color(0xFFF8C545), // เหลือง
      const Color(0xFFFF7B34), // ส้ม
      const Color(0xFF9AD547), // เขียว
    ],
  ),
  // ถ้ามี Level 3, Level 4 ก็เพิ่มตรงนี้ได้เรื่อยๆ
];
