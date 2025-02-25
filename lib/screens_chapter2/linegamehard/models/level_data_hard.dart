// lib/models/level_data_hard.dart

import 'dart:ui';
// import 'obstacle_data.dart';
// import 'star_data.dart';
// import 'moving_object_data.dart';

/// ข้อมูลสำหรับ 1 เลเวล ในโหมด Hard
class LevelDataHard {
  /// จุด normalized (0..1)
  final List<Offset> points;

  /// ข้อมูล obstacle
  final List<ObstacleData> obstacles;

  /// ข้อมูล rectangle obstacle
  final List<RectangleObstacleData> rectangleObstacles;

  /// ข้อมูล circle obstacle
  final List<CircleObstacleData> circleObstacles;

  /// ข้อมูล moving obstacle
  final List<MovingObjectData> movingObstacles;

  /// ข้อมูล star
  final List<StarData> stars;

  /// ข้อมูล sprite “องค์ประกอบฉาก” (เช่น ต้นไม้, ก้อนหิน, ฯลฯ)
  final List<SceneryData> scenery;

  /// ถ้าต้องการ loopBack หรือไม่
  final bool loopBack;

  // /// Obstacle / Star / Moving object
  // final List<ObstacleData> obstacles;
  // final List<StarData> stars;
  // final MovingObjectData? specialObject;

  LevelDataHard({
    required this.points,
    this.obstacles = const [],
    this.rectangleObstacles = const [],
    this.circleObstacles = const [],
    this.movingObstacles = const [],
    this.stars = const [],
    this.scenery = const [],
    this.loopBack = false,
  });
}

/// ObstacleData, MovingObjectData, StarData, SceneryData
/// (คุณสร้าง data class ตามที่ต้องการ)

class ObstacleData {
  final String spritePath;
  final double offsetX;
  final double offsetY;
  final double width;
  final double height;
  final double angle;
  ObstacleData({
    required this.spritePath,
    required this.offsetX,
    required this.offsetY,
    required this.width,
    required this.height,
    required this.angle,
  });
}

class RectangleObstacleData {
  final String spritePath;
  final double offsetX;
  final double offsetY;
  final double width;
  final double height;
  final double angle;
  RectangleObstacleData({
    required this.spritePath,
    required this.offsetX,
    required this.offsetY,
    required this.width,
    required this.height,
    required this.angle,
  });
}

class CircleObstacleData {
  final String spritePath;
  final double offsetX;
  final double offsetY;
  final double width;
  final double height;
  CircleObstacleData({
    required this.spritePath,
    required this.offsetX,
    required this.offsetY,
    required this.width,
    required this.height,
  });
}

class MovingObjectData {
  final double offsetX;
  final double offsetY;
  final double width;
  final double height;
  MovingObjectData({
    required this.offsetX,
    required this.offsetY,
    required this.width,
    required this.height,
  });
}

class StarData {
  final double offsetX;
  final double offsetY;
  final double width;
  final double height;
  StarData({
    required this.offsetX,
    required this.offsetY,
    required this.width,
    required this.height,
  });
}

/// Data ของ “องค์ประกอบฉาก (Scenery)”
class SceneryData {
  final String spritePath; // path ไปยังรูป
  final double offsetX; // normalized 0..1 (หรือ pixel)
  final double offsetY;
  final double width; // ขนาด width/height เป็น pixel หรือตัวคูณ
  final double height;

  SceneryData({
    required this.spritePath,
    required this.offsetX,
    required this.offsetY,
    required this.width,
    required this.height,
  });
}
