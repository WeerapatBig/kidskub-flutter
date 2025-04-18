// lib/data/tangram_data.dart

/// เก็บชื่อชิ้น -> เส้นทาง Sprite
/// ไม่ใส่ width / height ลงในนี้
class TangramSpriteRegistry {
  /// map จาก 'Triangle Small' => 'shapegame/quiz_shape/option_1_1.png'
  static const Map<String, String> spritePaths = {
    // level 1
    'Triangle Red': 'shapegame/quiz_shape/level1/option_1_1.png',
    'Triangle Yellow': 'shapegame/quiz_shape/level1/option_1_2.png',
    // level 2
    'Triangle Yellow Level 2': 'shapegame/quiz_shape/level2/option_2_1.png',
    'Square Green Level 2': 'shapegame/quiz_shape/level2/option_2_2.png',
    'Triangle Red Level 2': 'shapegame/quiz_shape/level2/option_2_3.png',
    'Triangle Blue Level 2': 'shapegame/quiz_shape/level2/option_2_4.png',
    // level 3
    'Triangle Green Level 3': 'shapegame/quiz_shape/level3/option_3_1.png',
    'Square Yellow Level 3': 'shapegame/quiz_shape/level3/option_3_2.png',
    'Triangle Blue Level 3': 'shapegame/quiz_shape/level3/option_3_3.png',
    'Rhombus Pink Level 3': 'shapegame/quiz_shape/level3/option_3_4.png',
    'Triangle Red Level 3': 'shapegame/quiz_shape/level2/option_2_3.png',
    // level 4
    'Pieces 1 Red Level 4': 'shapegame/quiz_shape/level4/option_4_1.png',
    'Pieces 2 Yellow Level 4': 'shapegame/quiz_shape/level4/option_4_2.png',
    'Pieces 3 Blue Level 4': 'shapegame/quiz_shape/level4/option_4_3.png',
    'Pieces 4 Pink 4': 'shapegame/quiz_shape/level4/option_4_4.png',
    'Pieces 5 Green 4': 'shapegame/quiz_shape/level4/option_4_5.png',
  };

  /// ฟังก์ชันอำนวยความสะดวก (optional)
  /// ดึง path ตามชื่อ (ถ้าไม่เจอ รีเทิร์น null)
  static String? getPathByName(String shapeName) {
    return spritePaths[shapeName];
  }
}
