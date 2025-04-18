// piece_button.dart

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../data/tangram_level_data.dart';
import '../mechanic/tangram_game.dart';
import 'pieces_menu.dart';

enum SnapResult {
  matched,
  inSilhouetteButWrong,
  outsideSilhouette,
}

/// `PieceButton` รับ TangramShapeData ซึ่งมี name,width,height,spritePath ครบ
class PieceButton extends PositionComponent
    with DragCallbacks, HasGameRef<TangramGame> {
  final TangramShapeData shapeData;
  final Vector2 initialOffset; // ตำแหน่งโลคัลภายในเมนู
  final VoidCallback onPressed;

  // ขนาดเมื่ออยู่ในเมนู (เล็กลง)
  late Vector2 sizeInMenu;

  // ขนาดใหญ่ ตาม shapeData
  late Vector2 sizeInWorld;
  PiecesMenu? menuParent;

  bool isDragging = false;
  bool isSnapped = false;
  Sprite? sprite;

  PieceButton({
    required this.shapeData,
    required this.initialOffset,
    required super.priority,
    required this.onPressed,
  }) {
    // กำหนด anchor เป็น center ทันที
    anchor = Anchor.center;
    position = initialOffset;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite(shapeData.spritePath);

    // ขนาดจริง จาก level_data
    sizeInWorld = Vector2(shapeData.width, shapeData.height);

    // เริ่มต้น อยู่ในเมนู => ใช้ขนาดเล็ก

    final w = shapeData.menuWidth ?? 100;
    final h = shapeData.menuHeight ?? 100;
    sizeInMenu = Vector2(w, h);
    size = sizeInMenu;

    // เก็บ reference parent เมนู
    menuParent = parent as PiecesMenu?;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    sprite?.render(canvas, position: Vector2.zero(), size: size);
  }

  @override
  void onDragStart(DragStartEvent event) {
    // ถ้า isSnapped == true -> ไม่ให้ลากแล้ว
    if (isSnapped) {
      return; // หรือ event.continuePropagation = true; เพื่อส่งต่อ event ไป component อื่น
    }
    super.onDragStart(event);
    isDragging = true;

    // ✅ ตั้ง Pivot ให้อยู่กึ่งกลางของตัวต่อ
    // ดึงตำแหน่งโลก (absolute) ก่อนถอดออกจากเมนู
    final worldPos = absolutePosition;
    parent?.remove(this);

    // 3) ปรับขนาดเป็น sizeInWorld (ขนาดจริง)
    size = sizeInWorld;

    // เปลี่ยน position เป็น worldPos
    position = worldPos;
    // เพิ่มเข้า Game หลัก
    gameRef.add(this);
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

    // สมมติว่าลากจริง -> เช็ค Snap
    if (isDragging) {
      final snapResult = _checkSnap();

      switch (snapResult) {
        case SnapResult.matched:
          // ตัวต่อ snap เรียบร้อย
          isSnapped = true;
          break;

        case SnapResult.inSilhouetteButWrong:
          // อยู่ในกรอบ silhouette แต่ไม่ตรง slot => หัก 1 หัวใจ
          gameRef.loseHeart(); // หรือ gameRef.playerHearts--
          // แล้วเด้งกลับเมนู
          _returnToMenu();
          break;

        case SnapResult.outsideSilhouette:
          // นอก silhouette => กลับเมนู “ไม่ต้องหักหัวใจ”
          _returnToMenu();
          break;
      }
    }
    isDragging = false;
  }

  SnapResult _checkSnap() {
    final silhouette = gameRef.blackSilhouette;
    if (silhouette == null) return SnapResult.outsideSilhouette;

    final shapeRect = toRect();

    // 1) เช็คว่ารูปต่ออยู่ใน silhouette ไหม
    final isIn = silhouette.isInside(shapeRect);
    if (!isIn) {
      return SnapResult.outsideSilhouette;
    }

    // 2) ถ้าอยู่ใน silhouette -> เช็คว่าใกล้ slot ที่ตรงชื่อหรือไม่
    final result = silhouette.findClosestSlotByName(shapeData.name, position);
    if (result == null) {
      // หมายความว่า silhouette รับชิ้นนี้ (หรือไม่?) แต่ไม่มี slot ชื่อ matching
      // หรือไม่มี slot เลย -> ถือว่า “ใน Silhouette แต่ไม่ตรง slot”
      return SnapResult.inSilhouetteButWrong;
    }

    // ถ้ามี slot -> เช็คระยะ
    if (result.distance < 40) {
      // SNAP สำเร็จ
      position = result.globalPos;
      isSnapped = true;

      gameRef.onShapeSnapped();

      // โหลดสไปรท์สำเร็จจาก map
      final slot = result.slot;
      final shapeName = shapeData.name;
      final newSpritePath = slot.successSpritePaths[shapeName];
      if (newSpritePath != null) {
        _loadSuccessSprite(newSpritePath);
      }

      return SnapResult.matched;
    } else {
      // อยู่ใน silhouette แต่ไม่ถึง slot
      return SnapResult.inSilhouetteButWrong;
    }
  }

  // bool _checkSnap() {
  //   if (!isDragging) return false;

  //   final silhouette = gameRef.blackSilhouette;
  //   if (silhouette == null) return false;

  //   final shapeRect = toRect();
  //   final isIn = silhouette.isInside(shapeRect);
  //   if (!isIn) return false;

  //   final result = silhouette.findClosestSlotByName(shapeData.name, position);
  //   if (result == null) return false;

  //   if (result.distance < 40) {
  //     // SNAP สำเร็จ
  //     position = result.globalPos;
  //     isSnapped = true;

  //     gameRef.onShapeSnapped();

  //     // โหลดสไปรท์สำเร็จจาก map
  //     final slot = result.slot;
  //     final shapeName = shapeData.name;
  //     final newSpritePath = slot.successSpritePaths[shapeName];
  //     if (newSpritePath != null) {
  //       _loadSuccessSprite(newSpritePath);
  //     }

  //     return true;
  //   }

  //   return false;
  // }

  /// ฟังก์ชันเด้งกลับเมนู (ถ้าลากผิด หรือไม่วางใน Silhouette)
  void _returnToMenu() {
    // 1) ลบออกจาก Game (ถ้ายังอยู่)
    parent?.remove(this);

    // 2) กลับไปสู่เมนู
    if (menuParent != null) {
      menuParent!.add(this);
    }

    // ✅ กลับมาใช้ pivot ด้านซ้ายบนเหมือนเดิม

    // 3) ใช้ขนาดเล็กเหมือนตอนแรก
    size = sizeInMenu;

    // 4) ตั้ง position เป็น initialOffset
    position = initialOffset;
    doWiggleAnimation();
  }

  void _loadSuccessSprite(String path) async {
    // โหลด sprite ใหม่
    final newSprite = await gameRef.loadSprite(path);

    // เปลี่ยน sprite ของ shape
    sprite = newSprite;
  }

  void doWiggleAnimation() {
    final wiggle = SequenceEffect([
      RotateEffect.by(
        0.2,
        EffectController(duration: 0.04),
      ),
      RotateEffect.by(
        -0.4,
        EffectController(duration: 0.08),
      ),
      RotateEffect.by(
        0.2,
        EffectController(duration: 0.04),
      ),
    ]);

    add(wiggle);
  }
}
