import 'dart:ui' as dart_ui;

import 'package:firstly/screens_chapter4/components/grid.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import '../logic/game_color_logic.dart';

enum EatState { idle, eatingCorrect, eatingWrong }

EatState eatState = EatState.idle;

class PlayerComponent extends PositionComponent
    with HasGameRef<ColorGame>, CollisionCallbacks {
  /// พิกัดบน Grid
  Vector2 gridPosition = Vector2(3, 2);
  Color currentColor = Colors.transparent;
  static const double cornerRadius = 0; // ✅ กำหนดขอบมน

  late Sprite idleSprite;
  late dart_ui.Image eatWrongImage;
  late dart_ui.Image eatCorrectImage;
  SpriteAnimationComponent? _activeWrongAnim;
  SpriteAnimationComponent? _activeCorrectAnim;

  /// Sprite ปัจจุบันที่จะแสดง
  late Sprite currentSprite;

  /// ตัวจับเวลาสำหรับการแสดง Eat Sprite
  double _eatTimer = 0.0;
  bool _isEating = false;
  bool isEatingWrongColor = false;
  bool isEatingCorrectColor = false;

  PlayerComponent() {
    // ขนาดของ Player เท่ากับ 1 ช่อง (50x50)
    size = Vector2(90, 90);
    anchor = Anchor.center;

    // แปลงตำแหน่งเบื้องต้น
    position = toPixelCenter(gridPosition);
    priority = 2; // ✅ วางไว้ด้านบนสุด
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    eatWrongImage =
        (await gameRef.images.load('colorgame/character/wrongColor_sheet.png'));
    eatCorrectImage =
        await gameRef.images.load('colorgame/character/correctColor_sheet.png');

    // ✅ โหลด Sprite จากรูปภาพ PNG
    idleSprite = await Sprite.load('colorgame/character/is_idle.png');

    currentSprite = idleSprite;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // อัปเดตตำแหน่ง pixel จาก gridPosition ทุกเฟรม
    position = toPixelCenter(gridPosition);

    // ถ้าอยู่ในสถานะกิน (_isEating == true) ให้นับเวลาถอยหลัง
    if (_isEating) {
      _eatTimer -= dt;

      // ✅ อัปเดตตำแหน่งให้อนิเมชันตามผู้เล่น
      _activeCorrectAnim?.position = toPixelCenter(gridPosition);
      _activeWrongAnim?.position = toPixelCenter(gridPosition);

      if (_eatTimer <= 0) {
        _isEating = false;
        eatState = EatState.idle;

        _activeWrongAnim?.removeFromParent();
        _activeCorrectAnim?.removeFromParent();
        _activeWrongAnim = null;
        _activeCorrectAnim = null;

        currentSprite = idleSprite;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = currentColor; // ✅ วาดเป็นสี่เหลี่ยมขอบมน
    final rect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(cornerRadius), // ✅ ปรับรัศมีขอบมน
    );
    canvas.drawRRect(rect, paint);
    if (eatState != EatState.idle) return; // อย่า render sprite ปกติซ้อน

    // ปกติ
    currentSprite.render(
      canvas,
      size: size + Vector2.all(1),
    );
  }

  @override
  void onRemove() {
    _activeWrongAnim?.removeFromParent();
    _activeCorrectAnim?.removeFromParent();
    _activeWrongAnim = null;
    _activeCorrectAnim = null;

    super.onRemove();
  }

  Future<SpriteAnimationComponent> createEatCorrectAnimation() async {
    final spriteSheet = SpriteSheet(
      image: eatCorrectImage,
      srcSize: Vector2(1920, 1920), // ✅ ขนาดเฟรมละ 512x512
    );

    final animation = SpriteAnimation.fromFrameData(
      eatCorrectImage,
      SpriteAnimationData([
        spriteSheet.createFrameData(0, 0, stepTime: 0.2),
        spriteSheet.createFrameData(0, 1, stepTime: 0.2),
        spriteSheet.createFrameData(0, 1, stepTime: 0.2),
        spriteSheet.createFrameData(0, 0, stepTime: 0.2),
      ]),
    );

    const scaleFactor = 120 / 1920; // ให้เท่าขนาด player grid

    return SpriteAnimationComponent()
      ..animation = animation
      ..size = Vector2(1920, 1920) * scaleFactor
      ..anchor = Anchor.center
      ..position = toPixelCenter(gridPosition);
  }

  Future<SpriteAnimationComponent> createEatWrongAnimation() async {
    final spriteSheet = SpriteSheet(
      image: eatWrongImage,
      srcSize: Vector2(1920, 1920),
    );
    final animation = SpriteAnimation.fromFrameData(
      eatWrongImage,
      SpriteAnimationData([
        spriteSheet.createFrameData(0, 0, stepTime: 0.2),
        spriteSheet.createFrameData(0, 1, stepTime: 0.2),
        spriteSheet.createFrameData(0, 1, stepTime: 0.2),
        spriteSheet.createFrameData(0, 0, stepTime: 0.2),
      ]),
    );
    const scaleFactor = 125 / 1920;

    return SpriteAnimationComponent()
      ..animation = animation
      ..size = Vector2(1920, 1920) * scaleFactor
      ..anchor = Anchor.center
      ..position = toPixelCenter(gridPosition);
  }

  /// ฟังก์ชันเรียกเมื่อ Player ขยับไปยังทิศทาง newDirection (Vector2(-1,0) เช่น)
  void move(Vector2 newDirection) {
    final nextPos = gridPosition + newDirection;
    if (isInsideGrid(nextPos)) {
      gridPosition = nextPos;
    }
  }

  /// เริ่มสถานะ "กิน" (เปลี่ยนสไปรต์เป็น eat 1.5 วินาที)
  Future<void> startEating() async {
    if (eatState == EatState.eatingWrong) {
      _activeWrongAnim?.removeFromParent();
      _activeWrongAnim = null;
    }

    _activeCorrectAnim?.removeFromParent();
    eatState = EatState.eatingCorrect;

    _isEating = true;
    _eatTimer = 1.5; // 1.5 วินาที

    final anim = await createEatCorrectAnimation();
    anim.position = toPixelCenter(gridPosition);
    _activeCorrectAnim = anim;
    gameRef.add(anim);
  }

  Future<void> eatingWrongColor() async {
    // 🔁 ลบ animation เดิม (ถ้ามี)
    if (eatState == EatState.eatingCorrect) {
      _activeCorrectAnim?.removeFromParent();
      _activeCorrectAnim = null;
    }

    _activeWrongAnim?.removeFromParent(); // ลบตัวเก่าด้วย
    eatState = EatState.eatingWrong;

    _isEating = true;
    _eatTimer = 1.5;

    final anim = await createEatWrongAnimation();
    anim.position = toPixelCenter(gridPosition);
    _activeWrongAnim = anim;
    gameRef.add(anim);
  }

  void clearEatingAnimation() {
    // 1) ลบอนิเมชันกิน (ถ้ามี)
    _activeWrongAnim?.removeFromParent();
    _activeWrongAnim = null;

    _activeCorrectAnim?.removeFromParent();
    _activeCorrectAnim = null;

    // 2) รีเซ็ตตัวแปรสถานะ
    _eatTimer = 0.0;
    _isEating = false;
    eatState = EatState.idle;

    // 3) คืนค่า Sprite เดิม
    currentSprite = idleSprite;

    // ถ้าต้องการเคลียร์สีปัจจุบันด้วย เช่น set currentColor = Colors.transparent;
    // currentColor = Colors.transparent;

    debugPrint("❌ Cleared eating animation. Player back to idle sprite.");
  }

  /// รีเซ็ตตำแหน่งผู้เล่นไปยังจุดเริ่มต้น
  Future<void> resetPosition() async {
    await Future.delayed(const Duration(milliseconds: 300));
    gridPosition = Vector2(3, 2); // ตำแหน่งเริ่มต้น (กำหนดเองตามที่ต้องการ)
    position = toPixelCenter(gridPosition); // อัปเดตตำแหน่งบนจอ
    currentSprite = idleSprite; // ล้างสีปัจจุบัน
    debugPrint("🔄 ผู้เล่นกลับไปยังจุดเริ่มต้น!");
  }

  /// หา "กรอบสี่เหลี่ยม" ของ Player ในพิกเซล
  /// ไว้ใช้ Manual Checking กับ Goal (วงกลม)
  Rect get boundingBox {
    // สมมติลดลงเหลือ 70% ของขนาดจริง
    double boxWidth = size.x * 0.7;
    double boxHeight = size.y * 0.7;

    // หา left, top โดยอิงจากจุด center (x, y) – anchor = center
    final left = x - (boxWidth / 2);
    final top = y - (boxHeight / 2);

    return Rect.fromLTWH(left, top, boxWidth, boxHeight);
  }
}
