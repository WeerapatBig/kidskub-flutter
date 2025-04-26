import 'package:flutter/material.dart';
import '../data/level_data_quiz_color_1.dart';

class QuizColor1Controller {
  int hp = 3;
  int currentLevel = 0;
  Set<Color> correctAnswers = {};
  Set<Color> selectedAnswers = {};

  final Function()? onLevelComplete;
  final Function()? onAllLevelComplete;
  final Function()? onHpDepleted;

  QuizColor1Controller({
    this.onLevelComplete,
    this.onAllLevelComplete,
    this.onHpDepleted,
  });

  final Map<int, Set<Color>> levelCorrectAnswers = {
    0: {
      const Color(0xFF4DA7DB), // ฟ้า
      const Color(0xFFEA4C3D), // แดง
      const Color(0xFFF8C545), // เหลือง
    },
    1: {
      const Color(0xFFB268A3), // ม่วง
      const Color(0xFFFF7B34), // ส้ม
      const Color(0xFF9AD547), // เขียว
    },
  };

  void initializeLevel() {
    correctAnswers = levelCorrectAnswers[currentLevel] ?? {};

    selectedAnswers.clear();
  }

  void goToNextLevel() {
    if (currentLevel < quizColorLevels.length - 1) {
      currentLevel++;
      initializeLevel(); // โหลดข้อมูลด่านใหม่
      onLevelComplete?.call();
    } else {
      // ถ้าผ่านครบแล้ว ให้เรียก onAllLevelComplete() ไปเลย
      onAllLevelComplete?.call();
    }
  }

  void restartGame() {
    hp = 3;
    currentLevel = 0;
    initializeLevel();
  }
}
