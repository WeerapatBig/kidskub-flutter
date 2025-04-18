// lib/data/tangram_level_data.dart

import 'package:flame/components.dart';
import 'tangram_data.dart'; // อ้างอิง TangramShapeData, TangramShapeType
import '../mechanic/black_silhouette.dart';
// (อาจต้อง import ถ้าจะใช้ TangramTargetSlot หรือคลาสที่เกี่ยวข้องใน black_silhouette.dart)

/// ใช้โครงสร้าง class TangramShapeData ที่รวมข้อมูล "1 ชิ้นต่อ"
class TangramShapeData {
  final String name; // เช่น 'Triangle Small'
  final double width;
  final double height;
  final String spritePath; // ดึงจาก Registry
  final double? menuWidth;
  final double? menuHeight;

  TangramShapeData({
    required this.name,
    required this.width,
    required this.height,
    required this.spritePath,
    this.menuWidth,
    this.menuHeight,
  });
}

/// โครงสร้างข้อมูลของ 1 ด่าน (Level)
class TangramLevelData {
  final String levelName; // ชื่อด่าน เช่น 'Level 1'
  final String silhouetteImagePath; // ถ้าอยากใช้ภาพ Silhouette แบบระบุไฟล์
  final Vector2 silhouettePosition; // ตำแหน่ง Silhouette บนจอ
  final Vector2 silhouetteSize; // ขนาด Silhouette

  /// ชิ้นส่วนตัวต่อที่ด่านนี้จะให้ผู้เล่นลาก
  /// (เอาข้อมูลจาก tangramShapesList มาประกอบ หรือนิยามเอง)
  final List<TangramShapeData> pieces;

  /// จุดเป้าหมาย (slot) ที่ระบุว่า ตำแหน่งไหน, รองรับตัวต่อชื่ออะไร
  /// เช่นเดียวกับตัวอย่างที่เคยใช้ TangramTargetSlot
  final List<TangramTargetSlot> targetSlots;
  final String menuBgSpritePath;
  final Vector2 menuSize; //เพิ่มขนาดของเมนู
  final Vector2 menuPosition;
  final List<Vector2> customPositions;

  TangramLevelData({
    required this.levelName,
    required this.silhouetteImagePath,
    required this.silhouettePosition,
    required this.silhouetteSize,
    required this.pieces,
    required this.targetSlots,
    required this.menuBgSpritePath,
    required this.menuSize,
    required this.menuPosition,
    required this.customPositions,
  });
}

/// ตัวอย่าง: รวมข้อมูล "ทุกด่าน" ไว้ใน List
/// คุณสามารถแก้ไข/เพิ่มได้ตามต้องการ
class TangramLevelManager {
  //ตัวแปรความกว้างของชิ้นส่วน

  static final List<TangramLevelData> allLevels = [
    //=================
    //Level 1,
    //=================
    TangramLevelData(
      levelName: 'Level 1',
      silhouetteImagePath: 'shapegame/quiz_shape/silhouette_1.png',
      silhouettePosition: Vector2((1250 - 310) / 2 - 25, 155),
      silhouetteSize: Vector2(310, 310),
      pieces: [
        TangramShapeData(
          name: 'Triangle Red',
          width: 290,
          height: 290,
          spritePath: TangramSpriteRegistry.getPathByName('Triangle Red') ??
              'shapegame/default.png',
          menuWidth: 100, // ใส่ค่าที่ต้องการ
          menuHeight: 100,
        ),
        TangramShapeData(
          name: 'Triangle Yellow',
          width: 290,
          height: 290,
          spritePath: TangramSpriteRegistry.getPathByName('Triangle Yellow') ??
              'shapegame/default.png',
          menuWidth: 100, // ใส่ค่าที่ต้องการ
          menuHeight: 100,
        ),
      ],
      targetSlots: [
        TangramTargetSlot(
          allowedShapeNames: ['Triangle Red'],
          localPos: Vector2(157, 152),
          successSpritePaths: {
            'Triangle Red': 'shapegame/quiz_shape/level1/isSnap_1_1.png'
          },
        ),
        TangramTargetSlot(
          allowedShapeNames: ['Triangle Yellow'],
          localPos: Vector2(152, 157),
          successSpritePaths: {
            'Triangle Yellow': 'shapegame/quiz_shape/level1/isSnap_1_2.png'
          },
        ),
      ],
      menuBgSpritePath: 'shapegame/quiz_shape/level1/choice_bar_1.png',
      menuSize: Vector2(468 / 1.5, 273 / 1.5),
      menuPosition: Vector2((800 - (468 / 1.5) - 45), 515),
      customPositions: [
        Vector2(100, 83.5),
        Vector2(214, 87),
      ],
    ),
    //=================
    //Level 2,
    //=================
    TangramLevelData(
      levelName: 'Level 2',
      silhouetteImagePath: 'shapegame/quiz_shape/silhouette_2.png',
      silhouettePosition: Vector2((1250 - 310) / 2 - 25, 160),
      silhouetteSize: Vector2(310, 310),
      pieces: [
        TangramShapeData(
          name: 'Triangle Yellow Level 2',
          width: 290,
          height: 290,
          spritePath:
              TangramSpriteRegistry.getPathByName('Triangle Yellow Level 2') ??
                  'shapegame/default.png',
          menuWidth: 100, // ใส่ค่าที่ต้องการ
          menuHeight: 100,
        ),
        TangramShapeData(
          name: 'Square Green Level 2',
          width: 146,
          height: 146,
          spritePath:
              TangramSpriteRegistry.getPathByName('Square Green Level 2') ??
                  'shapegame/default.png',
          menuWidth: 100, // ใส่ค่าที่ต้องการ
          menuHeight: 100,
        ),
        TangramShapeData(
          name: 'Triangle Red Level 2',
          width: 146,
          height: 146,
          spritePath:
              TangramSpriteRegistry.getPathByName('Triangle Red Level 2') ??
                  'shapegame/default.png',
          menuWidth: 100, // ใส่ค่าที่ต้องการ
          menuHeight: 100,
        ),
        TangramShapeData(
          name: 'Triangle Blue Level 2',
          width: 146,
          height: 146,
          spritePath:
              TangramSpriteRegistry.getPathByName('Triangle Blue Level 2') ??
                  'shapegame/default.png',
          menuWidth: 100, // ใส่ค่าที่ต้องการ
          menuHeight: 100,
        ),
      ],
      targetSlots: [
        TangramTargetSlot(
          allowedShapeNames: ['Triangle Yellow Level 2'],
          localPos: Vector2(157, 154),
          successSpritePaths: {
            'Triangle Yellow Level 2':
                'shapegame/quiz_shape/level2/isSnap_2_1.png'
          },
        ),
        TangramTargetSlot(
          allowedShapeNames: ['Square Green Level 2'],
          localPos: Vector2(82, 228.5),
          successSpritePaths: {
            'Square Green Level 2': 'shapegame/quiz_shape/level2/isSnap_2_4.png'
          },
        ),
        TangramTargetSlot(
          allowedShapeNames: ['Triangle Red Level 2', 'Triangle Blue Level 2'],
          localPos: Vector2(82, 84),
          successSpritePaths: {
            'Triangle Red Level 2':
                'shapegame/quiz_shape/level2/isSnap_2_3.png',
            'Triangle Blue Level 2':
                'shapegame/quiz_shape/level2/isSnap_2_3_2.png'
          },
        ),
        TangramTargetSlot(
          allowedShapeNames: ['Triangle Red Level 2', 'Triangle Blue Level 2'],
          localPos: Vector2(226.7, 228.5),
          successSpritePaths: {
            'Triangle Blue Level 2':
                'shapegame/quiz_shape/level2/isSnap_2_2.png',
            'Triangle Red Level 2':
                'shapegame/quiz_shape/level2/isSnap_2_2_1.png',
          },
        ),
      ],
      menuBgSpritePath: 'shapegame/quiz_shape/level2/choice_bar_2.png',
      menuSize: Vector2(825 / 1.5, 273 / 1.5),
      menuPosition: Vector2(((1250 - (825 / 1.5)) / 2 - 25), 515),
      customPositions: [
        Vector2(100, 83.5),
        Vector2(216, 85),
        Vector2(333, 87),
        Vector2(451, 87),
      ],
    ),
    //=================
    // Level 3
    //=================
    TangramLevelData(
      levelName: 'level 3',
      silhouetteImagePath: 'shapegame/quiz_shape/silhouette_3.png',
      silhouettePosition: Vector2((1250 - 644 * 0.95) / 2 - 25, 150),
      silhouetteSize: Vector2(644 * 0.95, 348 * 0.95),
      pieces: [
        TangramShapeData(
          name: 'Triangle Green Level 3',
          width: 150 * 1.08,
          height: 150 * 1.08,
          spritePath:
              TangramSpriteRegistry.getPathByName('Triangle Green Level 3') ??
                  'shapegame/default.png',
          menuWidth: 100, // ใส่ค่าที่ต้องการ
          menuHeight: 100,
        ),
        TangramShapeData(
          name: 'Square Yellow Level 3',
          width: 150 * 1.08,
          height: 150 * 1.08,
          spritePath:
              TangramSpriteRegistry.getPathByName('Square Yellow Level 3') ??
                  'shapegame/default.png',
          menuWidth: 100, // ใส่ค่าที่ต้องการ
          menuHeight: 100,
        ),
        TangramShapeData(
          name: 'Triangle Blue Level 3',
          width: 295 * 1.1,
          height: 150 * 1.04,
          spritePath:
              TangramSpriteRegistry.getPathByName('Triangle Blue Level 3') ??
                  'shapegame/default.png',
          menuWidth: 190, // ใส่ค่าที่ต้องการ
          menuHeight: 100,
        ),
        TangramShapeData(
          name: 'Rhombus Pink Level 3',
          width: 276 * 1.08,
          height: 150 * 1.08,
          spritePath:
              TangramSpriteRegistry.getPathByName('Rhombus Pink Level 3') ??
                  'shapegame/default.png',
          menuWidth: 190, // ใส่ค่าที่ต้องการ
          menuHeight: 105,
        ),
        TangramShapeData(
          name: 'Triangle Red Level 3', // 1 : 1.188
          width: 126 * 1.08,
          height: 150 * 1.08,
          spritePath:
              TangramSpriteRegistry.getPathByName('Triangle Red Level 3') ??
                  'shapegame/default.png',
          menuWidth: 100, // ใส่ค่าที่ต้องการ
          menuHeight: 100,
        ),
      ],
      targetSlots: [
        TangramTargetSlot(
          allowedShapeNames: ['Triangle Green Level 3'],
          localPos: Vector2(225, 243),
          successSpritePaths: {
            'Triangle Green Level 3':
                'shapegame/quiz_shape/level3/isSnap_3_1.png'
          },
        ),
        TangramTargetSlot(
          allowedShapeNames: ['Square Yellow Level 3'],
          localPos: Vector2(386, 243),
          successSpritePaths: {
            'Square Yellow Level 3':
                'shapegame/quiz_shape/level3/isSnap_3_2.png'
          },
        ),
        TangramTargetSlot(
          allowedShapeNames: ['Triangle Blue Level 3'],
          localPos: Vector2(305, 85),
          successSpritePaths: {
            'Triangle Blue Level 3':
                'shapegame/quiz_shape/level3/isSnap_3_3.png'
          },
        ),
        TangramTargetSlot(
          allowedShapeNames: ['Rhombus Pink Level 3'],
          localPos: Vector2(157, 243),
          successSpritePaths: {
            'Rhombus Pink Level 3': 'shapegame/quiz_shape/level3/isSnap_3_4.png'
          },
        ),
        TangramTargetSlot(
          allowedShapeNames: ['Triangle Red Level 3'],
          localPos: Vector2(535, 243),
          successSpritePaths: {
            'Triangle Red Level 3': 'shapegame/quiz_shape/level3/isSnap_3_5.png'
          },
        ),
      ],
      menuBgSpritePath: 'shapegame/quiz_shape/level3/choice_bar_3.png',
      menuSize: Vector2(1286 / 1.5, 273 / 1.5),
      menuPosition: Vector2((800 - (1286 / 1.5) + 220), 515),
      customPositions: [
        Vector2(100, 86),
        Vector2(216, 85),
        Vector2(381, 84),
        Vector2(595, 85),
        Vector2(758, 86),
      ],
    ),
    //=================
    // Level 4
    //=================
    TangramLevelData(
      levelName: 'level 4',
      silhouetteImagePath: 'shapegame/quiz_shape/silhouette_4.png',
      silhouettePosition: Vector2((1250 - 355) / 2 - 25, 150),
      silhouetteSize: Vector2(504 * 0.7, 484 * 0.7),
      pieces: [
        TangramShapeData(
          name: 'Pieces 1 Red Level 4',
          width: 127 * 1.8,
          height: 103 * 1.8,
          spritePath:
              TangramSpriteRegistry.getPathByName('Pieces 1 Red Level 4') ??
                  'shapegame/default.png',
          menuWidth: 127, // ใส่ค่าที่ต้องการ
          menuHeight: 103,
        ),
        TangramShapeData(
          name: 'Pieces 2 Yellow Level 4',
          width: 106 * 1.318,
          height: 104 * 1.318,
          spritePath:
              TangramSpriteRegistry.getPathByName('Pieces 2 Yellow Level 4') ??
                  'shapegame/default.png',
          menuWidth: 106, // ใส่ค่าที่ต้องการ
          menuHeight: 103,
        ),
        TangramShapeData(
          name: 'Pieces 3 Blue Level 4',
          width: 106 * 1.898,
          height: 104 * 1.898,
          spritePath:
              TangramSpriteRegistry.getPathByName('Pieces 3 Blue Level 4') ??
                  'shapegame/default.png',
          menuWidth: 106, // ใส่ค่าที่ต้องการ
          menuHeight: 103,
        ),
        TangramShapeData(
          name: 'Pieces 4 Pink 4',
          width: 52 * 1.8,
          height: 103 * 1.8,
          spritePath: TangramSpriteRegistry.getPathByName('Pieces 4 Pink 4') ??
              'shapegame/default.png',
          menuWidth: 69, // ใส่ค่าที่ต้องการ
          menuHeight: 103,
        ),
        TangramShapeData(
          name: 'Pieces 5 Green 4',
          width: 161 * 1.52,
          height: 108 * 1.51,
          spritePath: TangramSpriteRegistry.getPathByName('Pieces 5 Green 4') ??
              'shapegame/default.png',
          menuWidth: 161, // ใส่ค่าที่ต้องการ
          menuHeight: 108,
        ),
      ],
      targetSlots: [
        TangramTargetSlot(
          allowedShapeNames: ['Pieces 1 Red Level 4'],
          localPos: Vector2(198, 149),
          successSpritePaths: {
            'Pieces 1 Red Level 4': 'shapegame/quiz_shape/level4/isSnap_4_1.png'
          },
        ),
        TangramTargetSlot(
          allowedShapeNames: ['Pieces 2 Yellow Level 4'],
          localPos: Vector2(243, 264.5),
          successSpritePaths: {
            'Pieces 2 Yellow Level 4':
                'shapegame/quiz_shape/level4/isSnap_4_2.png'
          },
        ),
        TangramTargetSlot(
          allowedShapeNames: ['Pieces 3 Blue Level 4'],
          localPos: Vector2(117, 235),
          successSpritePaths: {
            'Pieces 3 Blue Level 4':
                'shapegame/quiz_shape/level4/isSnap_4_3.png'
          },
        ),
        TangramTargetSlot(
          allowedShapeNames: ['Pieces 4 Pink 4'],
          localPos: Vector2(297, 149),
          successSpritePaths: {
            'Pieces 4 Pink 4': 'shapegame/quiz_shape/level4/isSnap_4_4.png'
          },
        ),
        TangramTargetSlot(
          allowedShapeNames: ['Pieces 5 Green 4'],
          localPos: Vector2(130, 87),
          successSpritePaths: {
            'Pieces 5 Green 4': 'shapegame/quiz_shape/level4/isSnap_4_5.png'
          },
        ),
      ],
      menuBgSpritePath: 'shapegame/quiz_shape/level4/choice_bar_4.png',
      menuSize: Vector2(1061 / 1.5, 273 / 1.5),
      menuPosition: Vector2(((800 - (1061 / 1.5)) + 150), 515),
      customPositions: [
        Vector2(113, 86),
        Vector2(244, 85),
        Vector2(365, 85),
        Vector2(465, 85),
        Vector2(580, 85),
      ],
    ),
  ];

  /// เก็บ "ด่านปัจจุบัน" แบบ static
  static int currentLevelIndex = 0;

  /// Getter คืนค่า LevelData ของด่านปัจจุบัน
  static TangramLevelData get currentLevel {
    // ป้องกัน index เกิน
    if (currentLevelIndex < 0 || currentLevelIndex >= allLevels.length) {
      currentLevelIndex = 0;
    }
    return allLevels[currentLevelIndex];
  }
}
