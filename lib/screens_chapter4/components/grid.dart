// lib/screens_chapter4/components/grid.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// ขนาดของ Grid (N x N) และขนาดของแต่ละ Tile
const int kGridWidth = 7; // ความกว้างมี 7 ช่อง
const int kGridHeight = 5; // ความสูงมี 5 ช่อง
const double kTileSize = 85.0;
const double kTileRadius = 15.0; // ✅ รัศมีขอบมน
const double kWhiteTileMargin = 10.0; // ✅ ลดขนาด 10 หน่วย

const double kGridOffsetX = 280.0; // ✅ เลื่อนตำแหน่งในแนวนอน
const double kGridOffsetY = 155.0; // ✅ เลื่อนตำแหน่งในแนวตั้ง

/// ตรวจสอบว่า gridPosition อยู่ในเขตตารางหรือไม่
bool isInsideGrid(Vector2 gridPos) {
  return (gridPos.x >= 0 &&
      gridPos.y >= 0 &&
      gridPos.x < kGridWidth &&
      gridPos.y < kGridHeight);
}

/// แปลงตำแหน่งใน Grid → ตำแหน่งบนจอ (พิกัดกึ่งกลางของ Tile)
Vector2 toPixelCenter(Vector2 gridPos) {
  return Vector2(
    (gridPos.x * kTileSize) + (kTileSize / 2) + kGridOffsetX,
    (gridPos.y * kTileSize) + (kTileSize / 2) + kGridOffsetY,
  );
}

/// แปลงตำแหน่งใน Grid → ตำแหน่งบนจอ (มุมบนซ้ายของ Tile)
Vector2 toPixelTopLeft(Vector2 gridPos) {
  return Vector2(
    (gridPos.x * kTileSize) + kGridOffsetX,
    (gridPos.y * kTileSize) + kGridOffsetY,
  );
}

class GameGrid extends PositionComponent {
  /// grid[x][y] เก็บข้อมูลเลย์เอาท์ต่าง ๆ ได้
  final List<List<int>> grid;

  GameGrid()
      : grid = List.generate(
          kGridWidth,
          (_) => List.generate(kGridHeight, (_) => 0),
        ) {
    size = Vector2(kGridWidth * kTileSize, kGridHeight * kTileSize);
    position = Vector2.zero();
    priority = 0; // ✅ วางไว้ด้านล่างสุด
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    const backgroundWidth = kGridWidth * kTileSize;
    const backgroundHeight = kGridHeight * kTileSize;

    // 🔥 เปลี่ยนสีพื้นหลังของ Grid
    final backgroundPaint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255); // สีฟ้าอ่อน
    final backgroundStrokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final outerRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(kGridOffsetX - 5, kGridOffsetY - 5,
          backgroundWidth + 10, backgroundHeight + 10),
      const Radius.circular(kTileRadius), // ✅ รัศมีขอบมน
    );

    canvas.drawRRect(outerRect, backgroundPaint);
    canvas.drawRRect(outerRect, backgroundStrokePaint);

    // 🔥 สีของกริดเริ่มต้น
    final startTilePaint = Paint()
      ..color =
          const Color.fromARGB(255, 235, 233, 236); // ✅ ใช้สีเริ่มต้นจากเลเวล

    // วาด Tile สีขาว ขอบมน
    final tilePaint = Paint()
      ..color = const Color.fromRGBO(235, 233, 236, 1)
      ..style = PaintingStyle.fill;

    // ขนาดของ Tile สีขาวที่เล็กกว่า Grid -10
    const whiteTileSize = kTileSize - kWhiteTileMargin;

    for (int x = 0; x < kGridWidth; x++) {
      for (int y = 0; y < kGridHeight; y++) {
        // คำนวณตำแหน่งของ Tile (มุมบนซ้าย)
        final topLeft = toPixelTopLeft(Vector2(x.toDouble(), y.toDouble())) +
            Vector2(
              (kTileSize - whiteTileSize) / 2,
              (kTileSize - whiteTileSize) / 2,
            );

        // 🔥 กำหนดสีกริดตามตำแหน่งเริ่มต้นของ Player
        final isStartTile = (x == 3 && y == 2); // ✅ จุดเริ่มต้น (3, 2)
        final paint = isStartTile ? startTilePaint : tilePaint;

        // สร้าง RRect (สี่เหลี่ยมขอบมน)
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(topLeft.x, topLeft.y, whiteTileSize, whiteTileSize),
          Radius.circular(kTileRadius), // ✅ รัศมีขอบมน
        );

        // วาด Tile
        canvas.drawRRect(rect, paint);

        // ถ้าเป็นช่องเริ่มต้น => วาดเส้นปะที่มุมทั้ง 4
        if (isStartTile) {
          _drawCornerArcs(canvas, rect);
        }
      }
    }
  }

  /// วาดเส้นโค้งมนรูปตัว L ที่มุมทั้ง 4 โดยใช้ arcToPoint + dashed
  void _drawCornerArcs(Canvas canvas, RRect rect) {
    final dashPaint = Paint()
      ..color = const Color.fromARGB(255, 217, 217, 217)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // กำหนดความยาวเส้น (ก่อนโค้งและหลังโค้ง)
    const double cornerLength = 20;
    // ใช้ kTileRadius สำหรับโค้ง
    final cornerRadius = kTileRadius;

    // -------------------------------
    // มุมบนซ้าย
    // สร้าง path เริ่มจาก bottom -> arc -> right
    // ตัวอย่าง:
    final topLeftPath = Path()
      ..moveTo(rect.left, rect.top + cornerLength)
      // ลากขึ้นไปถึงจุดที่จะเริ่ม arc
      ..lineTo(rect.left, rect.top + cornerRadius)
      // arcFrom: current (rect.left, rect.top+cornerRadius)
      // arcTo:   (rect.left + cornerRadius, rect.top)
      ..arcToPoint(
        Offset(rect.left + cornerRadius, rect.top),
        radius: Radius.circular(cornerRadius),
        clockwise: true, // หมุนทวนเข็ม (ถ้ากลับด้านก็เปลี่ยน)
      )
      // สุดท้ายลากขวา
      ..lineTo(rect.left + cornerLength, rect.top);
    _drawDashedPath(canvas, topLeftPath, dashPaint);

    // -------------------------------
    // มุมบนขวา
    final topRightPath = Path()
      ..moveTo(rect.right - cornerLength, rect.top)
      // ลากไปซ้ายที่จุดจะเริ่ม arc
      ..lineTo(rect.right - cornerRadius, rect.top)
      // arcToPoint -> (rect.right, rect.top+cornerRadius)
      ..arcToPoint(
        Offset(rect.right, rect.top + cornerRadius),
        radius: Radius.circular(cornerRadius),
        clockwise: true,
      )
      // ลากลง
      ..lineTo(rect.right, rect.top + cornerLength);
    _drawDashedPath(canvas, topRightPath, dashPaint);

    // -------------------------------
    // มุมล่างซ้าย
    final bottomLeftPath = Path()
      ..moveTo(rect.left, rect.bottom - cornerLength)
      // ลากลงไปจุดที่จะ arc
      ..lineTo(rect.left, rect.bottom - cornerRadius)
      ..arcToPoint(
        Offset(rect.left + cornerRadius, rect.bottom),
        radius: Radius.circular(cornerRadius),
        clockwise: false, // สลับตามทิศ
      )
      // ลากขวา
      ..lineTo(rect.left + cornerLength, rect.bottom);
    _drawDashedPath(canvas, bottomLeftPath, dashPaint);

    // -------------------------------
    // มุมล่างขวา
    final bottomRightPath = Path()
      ..moveTo(rect.right, rect.bottom - cornerLength)
      // ลากลงไปจุด arc
      ..lineTo(rect.right, rect.bottom - cornerRadius)
      ..arcToPoint(
        Offset(rect.right - cornerRadius, rect.bottom),
        radius: Radius.circular(cornerRadius),
        clockwise: true,
      )
      // ลากซ้าย
      ..lineTo(rect.right - cornerLength, rect.bottom);
    _drawDashedPath(canvas, bottomRightPath, dashPaint);
  }

  /// ฟังก์ชันวาด path ให้เป็นเส้นปะ (dashed)
  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLength = 25.0;
    const gapLength = 0.0;

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final end = distance + dashLength;
        final clampedEnd = end < metric.length ? end : metric.length;

        final extractedPath = metric.extractPath(distance, clampedEnd);
        canvas.drawPath(extractedPath, paint);

        distance = clampedEnd + gapLength;
      }
    }
  }
}
