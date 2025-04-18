// lib/mechanic/black_silhouette.dart

// TO DO: MAKE SNAP ON COMPONENT SILHOUETTE CHECKED HITBOX

//import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class TangramTargetSlot {
  final List<String> allowedShapeNames;
  final Vector2 localPos;
  final Map<String, String> successSpritePaths;

  TangramTargetSlot({
    required this.allowedShapeNames,
    required this.localPos,
    required this.successSpritePaths,
  });
}

/// คลาสสำหรับวาดเงาดำเป็นพื้นหลังหรือรูปร่างเป้าหมาย
class BlackSilhouette extends PositionComponent with HasGameRef {
  final List<TangramTargetSlot> targetSlots;
  final String? spritePath; // ถ้าเผื่ออยากกำหนด

  Sprite? _sprite;

  BlackSilhouette({
    required Vector2 position,
    required Vector2 size,
    required this.targetSlots,
    this.spritePath,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    if (spritePath != null) {
      _sprite = await gameRef.loadSprite(spritePath!);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (_sprite != null) {
      _sprite!.render(
        canvas,
        position: Vector2.zero(),
        size: size,
      );
    } else {
      // fallback วาดสี่เหลี่ยมถ้าไม่มี sprite
      final paint = Paint()..color = Colors.transparent;
      canvas.drawRect(size.toRect(), paint);
    }
    // ตัวอย่าง: วาดจุด targetPositions เป็นวงกลมเล็ก ๆ (Debug) ให้เห็น
    final dotPaint = Paint()..color = Colors.transparent;
    for (final slot in targetSlots) {
      // targetPos คือจุดภายใน local ของ silhouette
      // แปลงเป็น offset => (targetPos.x, targetPos.y)
      canvas.drawCircle(Offset(slot.localPos.x, slot.localPos.y), 5, dotPaint);
    }
  }

  /// ฟังก์ชันสำหรับตรวจสอบว่า Rect ของชิ้นส่วน (shapeRect)
  /// อยู่ในขอบเขต (Rect) ของ BlackSilhouette หรือไม่
  bool isInside(Rect shapeRect) {
    // สร้าง Rect ของ Silhouette โดยอิงจาก position & size
    final silhouetteRect = toRect();
    // เงื่อนไขเบื้องต้น: ตรวจว่ามีการคร่อม/ทับกันบ้างหรือไม่
    // หรือจะใช้ contains() เพื่อเช็คว่ารูปอยู่ในขอบเขตทั้งหมดก็ได้
    return silhouetteRect.overlaps(shapeRect);
  }

  /// หาจุด (globalPos) ของ Slot ที่ชื่อ shapeName ตรงกัน
  /// และให้คืนค่าที่ "ใกล้" ชิ้นต่อที่สุด
  /// ถ้าไม่มีสักอัน match ชื่อ หรือไม่มี Slot เลย => return null
  TargetResult? findClosestSlotByName(String shapeName, Vector2 shapePos) {
    TangramTargetSlot? bestSlot;
    double minDist = double.infinity;

    for (final slot in targetSlots) {
      // 1) slot นี้รองรับเฉพาะ shapeName ที่ตรงกัน
      if (slot.allowedShapeNames.contains(shapeName)) {
        // 2) แปลง localPos => globalPos
        final globalPos =
            Vector2(position.x + slot.localPos.x, position.y + slot.localPos.y);
        // 3) วัดระยะ
        final dist = globalPos.distanceTo(shapePos);
        if (dist < minDist) {
          minDist = dist;
          bestSlot = slot;
        }
      }
    }

    // ถ้าไม่เจอ slot ไหนเลย => bestSlot จะเป็น null
    if (bestSlot == null) return null;
    // สร้างผลลัพธ์เป็น class
    final globalPos = Vector2(
        position.x + bestSlot.localPos.x, position.y + bestSlot.localPos.y);
    return TargetResult(bestSlot, globalPos, minDist);
  }
}

/// คลาสสำหรับเก็บผลลัพธ์การค้นหา (ตามวิธี #1 ที่คุณเลือกใช้)
class TargetResult {
  final TangramTargetSlot slot;
  final Vector2 globalPos; // ตำแหน่งโลกของ slot
  final double distance;

  TargetResult(this.slot, this.globalPos, this.distance);
}
