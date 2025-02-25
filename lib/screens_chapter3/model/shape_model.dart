/// ข้อมูลรูปร่าง (หรือรูปภาพที่จะให้ผู้เล่นเลือก)
class ShapeModel {
  final String name; // เช่น "Circle", "Rectangle", "Pentagon"...
  final String imagePath; // path ของภาพสีจริง
  ShapeModel({
    required this.name,
    required this.imagePath,
  });
}
