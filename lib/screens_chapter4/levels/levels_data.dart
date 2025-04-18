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
  [const Color.fromARGB(255, 249, 72, 59)],
  3,
);
final level2 = Level(
  [
    const Color.fromARGB(255, 249, 72, 59), // สีแดง
    const Color.fromARGB(255, 76, 183, 205), // สีฟ้า
  ],
  6,
);
