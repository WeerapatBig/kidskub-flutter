import 'package:flutter/material.dart';

class Level {
  List<Color> targetColor; // ✅ สีที่ต้องเก็บ
  int numberOfGoals;

  Level(
    this.targetColor,
    this.numberOfGoals,
  );
}

/// ตัวอย่างเลเวลที่ 1
final level1 = Level(
  [
    const Color(0xFFF9483B),
  ],
  3,
);
final level2 = Level(
  [
    const Color(0xFFF9483B), // สีแดง
    const Color(0xFF4CA6CD), // สีฟ้า
  ],
  6,
);
