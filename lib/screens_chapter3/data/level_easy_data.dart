// level_easy_data.dart

import '../model/level_shape_data.dart';
import '../model/shape_model.dart';

class LevelEasyData {
  /// กำหนดข้อมูลเลเวล 1-5 แบบ "ไม่สุ่ม"
  /// เพื่อให้ตรงตามเงื่อนไข:
  ///  - L1 -> 1 Silhouette + 2 Options
  ///  - L2 -> 2 Silhouette + 3 Options
  ///  - L3 -> 3 Silhouette + 4 Options
  ///  - L4-> 4 Silhouette + 5 Options
  ///  - L5-> 4 Silhouette + 5 Options
  static final List<LevelShapeData> allLevels = [
    // ---------------------
    // Level 1
    // ---------------------
    LevelShapeData(
      silhouettes: [
        ShapeModel(
          name: "Triangle",
          imagePath: "assets/images/shapegame/game_easy/shape_easy_balck_6.png",
        ),
      ],
      // ตัวเลือก = 1 ตัวที่ถูก + 1 ตัวหลอก
      options: [
        ShapeModel(
          name: "Triangle", // ตัวถูก
          imagePath: "assets/images/shapegame/game_easy/shape_easy_6.png",
        ),
        ShapeModel(
          name: "DummyX", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_easy/shape_easy_2.png",
        ),
      ],
    ),

    // ---------------------
    // Level 2
    // ---------------------
    LevelShapeData(
      silhouettes: [
        ShapeModel(
          name: "Rhombus",
          imagePath: "assets/images/shapegame/game_easy/shape_easy_balck_4.png",
        ),
        ShapeModel(
          name: "Square",
          imagePath: "assets/images/shapegame/game_easy/shape_easy_balck_2.png",
        ),
      ],
      // ตัวเลือก = 1 ตัวที่ถูก + 1 ตัวหลอก
      options: [
        ShapeModel(
          name: "Rhombus", // ตัวถูก
          imagePath: "assets/images/shapegame/game_easy/shape_easy_4.png",
        ),
        ShapeModel(
          name: "Square", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_easy/shape_easy_2.png",
        ),
        ShapeModel(
          name: "Kite", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_easy/shape_easy_7.png",
        ),
      ],
    ),

    // ---------------------
    // Level 3
    // ---------------------
    LevelShapeData(
      silhouettes: [
        ShapeModel(
          name: "Triangle",
          imagePath: "assets/images/shapegame/game_easy/shape_easy_balck_6.png",
        ),
        ShapeModel(
          name: "Circle",
          imagePath: "assets/images/shapegame/game_easy/shape_easy_balck_3.png",
        ),
        ShapeModel(
          name: "Pentagon",
          imagePath: "assets/images/shapegame/game_easy/shape_easy_balck_5.png",
        ),
      ],
      // ตัวเลือก = 1 ตัวที่ถูก + 1 ตัวหลอก
      options: [
        ShapeModel(
          name: "Triangle", // ตัวถูก
          imagePath: "assets/images/shapegame/game_easy/shape_easy_6.png",
        ),
        ShapeModel(
          name: "DummyX", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_easy/shape_easy_2.png",
        ),
        ShapeModel(
          name: "Circle", // ตัวถูก
          imagePath: "assets/images/shapegame/game_easy/shape_easy_3.png",
        ),
        ShapeModel(
          name: "Pentagon", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_easy/shape_easy_5.png",
        ),
      ],
    ),

    // ---------------------
    // Level 4
    // ---------------------

    LevelShapeData(
      silhouettes: [
        ShapeModel(
          name: "Rhombus",
          imagePath: "assets/images/shapegame/game_easy/shape_easy_balck_4.png",
        ),
        ShapeModel(
          name: "Trapezoid",
          imagePath: "assets/images/shapegame/game_easy/shape_easy_balck_1.png",
        ),
        ShapeModel(
          name: "Circle",
          imagePath: "assets/images/shapegame/game_easy/shape_easy_balck_3.png",
        ),
        ShapeModel(
          name: "Pentagon",
          imagePath: "assets/images/shapegame/game_easy/shape_easy_balck_5.png",
        ),
      ],
      // ตัวเลือก = 1 ตัวที่ถูก + 1 ตัวหลอก
      options: [
        ShapeModel(
          name: "Trapezoid", // ตัวถูก
          imagePath: "assets/images/shapegame/game_easy/shape_easy_1.png",
        ),
        ShapeModel(
          name: "DummyX", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_easy/shape_easy_2.png",
        ),
        ShapeModel(
          name: "Circle", // ตัวถูก
          imagePath: "assets/images/shapegame/game_easy/shape_easy_3.png",
        ),
        ShapeModel(
          name: "Rhombus", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_easy/shape_easy_4.png",
        ),
        ShapeModel(
          name: "Pentagon", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_easy/shape_easy_5.png",
        ),
      ],
    ),
    // ---------------------
    // Level 5
    // ---------------------
    LevelShapeData(
      silhouettes: [
        ShapeModel(
          name: "Hexagon",
          imagePath: "assets/images/shapegame/game_easy/shape_easy_balck_8.png",
        ),
        ShapeModel(
          name: "Octagon",
          imagePath: "assets/images/shapegame/game_easy/shape_easy_balck_9.png",
        ),
        ShapeModel(
          name: "Oval",
          imagePath:
              "assets/images/shapegame/game_easy/shape_easy_balck_10.png",
        ),
        ShapeModel(
          name: "Kite",
          imagePath: "assets/images/shapegame/game_easy/shape_easy_balck_7.png",
        ),
      ],
      // ตัวเลือก = 1 ตัวที่ถูก + 1 ตัวหลอก
      options: [
        ShapeModel(
          name: "DummyX", // ตัวถูก
          imagePath: "assets/images/shapegame/game_easy/shape_easy_3.png",
        ),
        ShapeModel(
          name: "Kite", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_easy/shape_easy_7.png",
        ),
        ShapeModel(
          name: "Hexagon", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_easy/shape_easy_8.png",
        ),
        ShapeModel(
          name: "Octagon", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_easy/shape_easy_9.png",
        ),
        ShapeModel(
          name: "Oval", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_easy/shape_easy_10.png",
        ),
      ],
    ),
  ];
}
