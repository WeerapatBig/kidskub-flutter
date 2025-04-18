// lib/mechanic/draggable_shape.dart

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'tangram_game.dart';

/// DraggableShape เป็นตัวต่อ Tangram ที่ผู้เล่นสามารถลากได้
class DraggableShape extends PositionComponent
    with DragCallbacks, HasGameRef<TangramGame> {
  final String shapeName; // ตัวอย่างข้อมูลเสริม
  final String spritePath;
  Sprite? sprite;

  bool isDragging = false;

  DraggableShape({
    required Vector2 position,
    required Vector2 size,
    required this.shapeName,
    required this.spritePath,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // โหลดรูปเป็น Sprite
    sprite = await gameRef.loadSprite(spritePath);

    // (ถ้าต้องการปรับขนาด size ให้เท่าขนาดสไปรท์จริง)
    // final originalSize = sprite!.srcSize;
    // size = originalSize;

    // หรือจะเอา size จาก TangramShapeData มากำหนดสัดส่วนก็ได้
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    sprite?.render(
      canvas,
      position: Vector2.zero(),
      size: size,
    );
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    isDragging = true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (isDragging) {
      position.add(event.localDelta);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    isDragging = false;

    // เรียก checkSnap
    //_checkSnap();
  }

  // void _checkSnap() {
  //   // 1) ดึง Silhouette จาก gameRef
  //   final silhouette = gameRef.blackSilhouette;

  //   // 2) เช็คว่า shapeRect ทับ Silhouette หรือเปล่า
  //   final shapeRect = toRect();
  //   final isIn = silhouette.isInside(shapeRect);
  //   if (!isIn) return; // ไม่อยู่ในกรอบ Silhouette ก็ไม่ snap

  //   // 3) หาช่อง (slot) ที่ชื่อ shapeName ตรงกัน และใกล้ที่สุด
  //   final result = silhouette.findClosestSlotByName(shapeName, position);

  //   if (result == null) {
  //     // แปลว่าไม่มี slot ชื่อนี้ใน silhouette เลย => ไม่ snap
  //     return;
  //   }

  //   // 4) ถ้า distance < threshold => snap
  //   if (result.distance < 40) {
  //     // สมมติ threshold = 60
  //     position = result.globalPos;
  //   }
  // }
}
