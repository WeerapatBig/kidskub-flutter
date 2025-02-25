import 'shape_model.dart';

/// ข้อมูลเลเวลแต่ละด่าน (เก็บ Silhouette + Options ในที่เดียว)
class LevelShapeData {
  /// รูปร่างที่เป็น "คำตอบที่ถูก" (Silhouette)
  final List<ShapeModel> silhouettes;

  /// รูปร่างที่เป็น "ตัวเลือกทั้งหมด" (เท่ากับ silhouettes + dummy 1 ตัว)
  final List<ShapeModel> options;

  LevelShapeData({
    required this.silhouettes,
    required this.options,
  });
}
