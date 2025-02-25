import 'package:firstly/screens_chapter3/model/level_shape_data.dart';

import '../model/shape_model.dart';

class LevelHardData {
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
          name: "Object01",
          imagePath: "assets/images/shapegame/game_hard/shape_hard_balck_1.png",
        ),
      ],
      // ตัวเลือก = 1 ตัวที่ถูก + 1 ตัวหลอก
      options: [
        ShapeModel(
          name: "Object02", // ตัวถูก
          imagePath: "assets/images/shapegame/game_hard/shape_hard_2.png",
        ),
        ShapeModel(
          name: "Object01", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_hard/shape_hard_1.png",
        ),
      ],
    ),

    // ---------------------
    // Level 2
    // ---------------------
    LevelShapeData(
      silhouettes: [
        ShapeModel(
          name: "Object05",
          imagePath: "assets/images/shapegame/game_hard/shape_hard_balck_5.png",
        ),
        ShapeModel(
          name: "Object03",
          imagePath: "assets/images/shapegame/game_hard/shape_hard_balck_3.png",
        ),
      ],
      // ตัวเลือก = 1 ตัวที่ถูก + 1 ตัวหลอก
      options: [
        ShapeModel(
          name: "Object05", // ตัวถูก
          imagePath: "assets/images/shapegame/game_hard/shape_hard_5.png",
        ),
        ShapeModel(
          name: "Object02", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_hard/shape_hard_2.png",
        ),
        ShapeModel(
          name: "Object03", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_hard/shape_hard_3.png",
        ),
      ],
    ),

    // ---------------------
    // Level 3
    // ---------------------
    LevelShapeData(
      silhouettes: [
        ShapeModel(
          name: "Object07",
          imagePath: "assets/images/shapegame/game_hard/shape_hard_balck_7.png",
        ),
        ShapeModel(
          name: "Object09",
          imagePath: "assets/images/shapegame/game_hard/shape_hard_balck_9.png",
        ),
        ShapeModel(
          name: "Object08",
          imagePath: "assets/images/shapegame/game_hard/shape_hard_balck_8.png",
        ),
      ],
      // ตัวเลือก = 1 ตัวที่ถูก + 1 ตัวหลอก
      options: [
        ShapeModel(
          name: "Object09", // ตัวถูก
          imagePath: "assets/images/shapegame/game_hard/shape_hard_9.png",
        ),
        ShapeModel(
          name: "Object07", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_hard/shape_hard_7.png",
        ),
        ShapeModel(
          name: "Object08", // ตัวถูก
          imagePath: "assets/images/shapegame/game_hard/shape_hard_8.png",
        ),
        ShapeModel(
          name: "Object03", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_hard/shape_hard_3.png",
        ),
      ],
    ),

    // ---------------------
    // Level 4
    // ---------------------

    LevelShapeData(
      silhouettes: [
        ShapeModel(
          name: "Object05",
          imagePath: "assets/images/shapegame/game_hard/shape_hard_balck_5.png",
        ),
        ShapeModel(
          name: "Object01",
          imagePath: "assets/images/shapegame/game_hard/shape_hard_balck_1.png",
        ),
        ShapeModel(
          name: "Object10",
          imagePath:
              "assets/images/shapegame/game_hard/shape_hard_balck_10.png",
        ),
        ShapeModel(
          name: "Object04",
          imagePath: "assets/images/shapegame/game_hard/shape_hard_balck_4.png",
        ),
      ],
      // ตัวเลือก = 1 ตัวที่ถูก + 1 ตัวหลอก
      options: [
        ShapeModel(
          name: "Object10", // ตัวถูก
          imagePath: "assets/images/shapegame/game_hard/shape_hard_10.png",
        ),
        ShapeModel(
          name: "Object05", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_hard/shape_hard_5.png",
        ),
        ShapeModel(
          name: "Object04", // ตัวถูก
          imagePath: "assets/images/shapegame/game_hard/shape_hard_4.png",
        ),
        ShapeModel(
          name: "Object06", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_hard/shape_hard_6.png",
        ),
        ShapeModel(
          name: "Object01", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_hard/shape_hard_1.png",
        ),
      ],
    ),
    // ---------------------
    // Level 5
    // ---------------------
    LevelShapeData(
      silhouettes: [
        ShapeModel(
          name: "Object02",
          imagePath: "assets/images/shapegame/game_hard/shape_hard_balck_2.png",
        ),
        ShapeModel(
          name: "Object07",
          imagePath: "assets/images/shapegame/game_hard/shape_hard_balck_7.png",
        ),
        ShapeModel(
          name: "Object08",
          imagePath: "assets/images/shapegame/game_hard/shape_hard_balck_8.png",
        ),
        ShapeModel(
          name: "Object03",
          imagePath: "assets/images/shapegame/game_hard/shape_hard_balck_3.png",
        ),
      ],
      // ตัวเลือก = 1 ตัวที่ถูก + 1 ตัวหลอก
      options: [
        ShapeModel(
          name: "Object08", // ตัวถูก
          imagePath: "assets/images/shapegame/game_hard/shape_hard_8.png",
        ),
        ShapeModel(
          name: "Object06", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_hard/shape_hard_6.png",
        ),
        ShapeModel(
          name: "Object07", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_hard/shape_hard_7.png",
        ),
        ShapeModel(
          name: "Object03", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_hard/shape_hard_3.png",
        ),
        ShapeModel(
          name: "Object02", // ตัวหลอก
          imagePath: "assets/images/shapegame/game_hard/shape_hard_2.png",
        ),
      ],
    ),
  ];
}
