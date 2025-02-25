import '../model/level_shape_data.dart';
import '../model/shape_model.dart';

/// Controller จัดการลอจิกของเกม
class ShapeGameController {
  /// รูปร่างทั้งหมดของด่าน/เลเวลปัจจุบัน
  late List<ShapeModel> currentSilhouettes;

  // แทนที่จะมี ShapeModel เดียว เปลี่ยนเป็นลิสต์
  late List<ShapeModel> currentOptions;

  /// เวลาสูงสุด (วินาที) ที่กำหนดให้เล่นในแต่ละด่าน – ตามที่ระบุ = 120
  final int maxTime = 120;

  /// เวลาที่เหลือ (วินาที)
  int remainingTime = 120;

  final Set<String> revealedShapes = {};

  /// ตัวแปรบอกว่า "ผู้เล่นตอบ silhouette เหล่านี้จนครบหรือยัง"
  bool get isAllRevealed => revealedShapes.length == currentSilhouettes.length;

  /// สถานะว่า silhouette ยังเป็นสีดำอยู่หรือไม่
  bool isSilhouetteActive(String shapeName) {
    // ถ้ายังไม่อยู่ใน revealedShapes => ยังเป็นสีดำ
    return !revealedShapes.contains(shapeName);
  }

  ShapeGameController();

  /// เริ่มเกมโดยรับ LevelData เข้ามา (ไม่สุ่ม)
  void startLevel(LevelShapeData data) {
    revealedShapes.clear();

    currentSilhouettes = data.silhouettes;
    currentOptions = data.options;
  }

  /// รีเซ็ตสถานะของ Controller กลับค่าเริ่มต้น
  void reset() {
    // เซตเวลาให้กลับไปเท่ากับ maxTime
    remainingTime = maxTime;

    // เคลียร์ชุด Silhouette/Option ปัจจุบัน (ถ้ามี)
    currentSilhouettes = [];
    currentOptions = [];

    // เคลียร์ชื่อรูปร่างที่ถูกเปิดเผย
    revealedShapes.clear();
  }

  /// ตรวจว่ากดรูปไหนถูกหรือไม่
  bool checkAnswer(ShapeModel chosen) {
    // ถ้ารูปอยู่ใน Silhouette => ถูก
    bool isCorrect = currentSilhouettes.any(
      (sil) => sil.name == chosen.name,
    );

    if (isCorrect) {
      // บันทึกว่า shape นี้ถูกเปิดเผย
      revealedShapes.add(chosen.name);
    }
    return isCorrect;
  }

  /// หักเวลาเมื่อตอบผิด
  void penaltyTime(int penalty) {
    remainingTime -= penalty;
    if (remainingTime < 0) remainingTime = 0;
  }

  /// คำนวณจำนวนดาวจากเวลาที่ "ใช้ไป" หรือ "เหลืออยู่"
  ///
  /// ตามเงื่อนไข:
  /// - เหลือเวลามากกว่าหรือเท่ากับ (120 - 49) => ใช้ไป <= 49 วินาที => 3 ดาว
  /// - เหลือเวลามากกว่าหรือเท่ากับ (120 - 85) => ใช้ไป <= 85 วินาที => 2 ดาว
  /// - เหลือเวลามากกว่าหรือเท่ากับ (120 - 119) => ใช้ไป <= 119 วินาที => 1 ดาว
  /// - ไม่เหลือเลย => 0 ดาว
  ///
  /// ขึ้นอยู่กับความต้องการว่าคิดจาก "เวลาที่เหลือ" หรือ "เวลาที่ใช้"
  /// สมมุติจะคิดจาก "remainingTime" ตามนี้:
  int calculateStars() {
    if (remainingTime >= 120 - 49) {
      return 3;
    } else if (remainingTime >= 120 - 85) {
      return 2;
    } else if (remainingTime >= 120 - 119) {
      return 1;
    }
    return 0;
  }

  /// ลดเวลา 1 วินาที
  void decrementTime() {
    if (remainingTime > 0) {
      remainingTime--;
    }
  }
}
