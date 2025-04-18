import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../components/grid.dart';

/// เป็น Component แสดงไอคอน/รูปบ่งบอกว่า Enemy จะไปตำแหน่งไหน
class EnemyIntentMarker extends PositionComponent {
  // ใส่สไปรต์หรือรูปที่ต้องการ (ถ้าใช้ sprite หรือรูป asset)
  late Sprite markerSprite;

  EnemyIntentMarker(Vector2 gridPos) {
    size = Vector2(50, 50); // กำหนดขนาด Marker
    anchor = Anchor.center;
    position = toPixelCenter(gridPos); // วางตามตำแหน่งตาราง
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // โหลด sprite
    markerSprite = await Sprite.load('colorgame/X.png');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    markerSprite.render(canvas, size: size);
  }
}
