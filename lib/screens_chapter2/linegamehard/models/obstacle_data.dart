// lib/models/obstacle_data.dart

/// เก็บพิกัด obstacle (หน่วย Pixel หรือจะใช้ normalized ก็ได้)
class ObstacleData {
  final double offsetX;
  final double offsetY;
  final double width;
  final double height;

  ObstacleData({
    required this.offsetX,
    required this.offsetY,
    required this.width,
    required this.height,
  });
}
