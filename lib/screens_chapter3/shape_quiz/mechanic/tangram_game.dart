// lib/mechanic/tangram_game.dart

import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

// เรียกไฟล์อื่น ๆ ที่เกี่ยวข้อง
import '../data/tangram_level_data.dart';
import '../model/pieces_menu.dart';
import 'black_silhouette.dart';
import 'player_data.dart';
//import 'draggable_shape.dart';

/// TangramGame คือคลาสหลักที่สืบทอดจาก FlameGame
/// และผสม HasDraggables เพื่อกระจาย event drag ไปยัง Component ที่ implement DragCallbacks
class TangramGame extends FlameGame {
  Function()? onLevelComplete; // Callback
  Function()? onGameOver; // Callback
  Function()? onAllLevelComplete; // Callback
  final TangramLevelData levelData;

  final PlayerDataManager playerData;
  Function(int currentHP)? onHPChanged;

  late BlackSilhouette blackSilhouette;
  late SpriteComponent background;
  late SpriteComponent checkMark;
  bool checkMarkAdded = false;

  int snappedCount = 0;
  TangramGame(this.levelData, this.playerData);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // สร้าง CameraComponent พร้อมกับ ScalingViewport
    final cameraComponent = CameraComponent.withFixedResolution(
      width: 1250, // กำหนดความกว้าง
      height: 740, // กำหนดความสูง
    );

    camera = cameraComponent; // ✅ ใช้ CameraComponent แทนที่ camera.viewport
    add(cameraComponent);

    // พื้นหลัง
    final bgSprite = await loadSprite('linegamelist/line_quiz/paper_bg.png');
    background = SpriteComponent()
      ..sprite = bgSprite
      ..size = size // ขยายเต็มหน้าจอ
      ..priority = 0; // **ต่ำสุด**
    add(background);

    // สร้าง BlackSilhouette (หรือจะดัดแปลงเป็น Silhouette Sprite ก็ได้)
    blackSilhouette = BlackSilhouette(
      position: levelData.silhouettePosition,
      size: levelData.silhouetteSize,
      targetSlots: levelData.targetSlots,
      spritePath: levelData.silhouetteImagePath, // ถ้าใช้สไปรท์ Silhouette
    );
    add(blackSilhouette);

    // สร้าง PiecesMenu
    final menu = PiecesMenu(
      position: levelData.menuPosition, // เช่นแปะไว้ล่างซ้าย
      size: levelData.menuSize,
      shapeList: levelData.pieces,
      bgSpritePath: levelData.menuBgSpritePath,
      priority: 15, // <-- ส่งข้อมูลชิ้นจาก LevelData
    );
    add(menu);

    final checkSprite = await loadSprite('shapegame/check.png');
    checkMark = SpriteComponent()
      ..sprite = checkSprite
      ..size = Vector2(356 * 0.85, 284 * 0.85) // หรือขนาดที่ต้องการ
      ..anchor = Anchor.center
      // ตำแหน่ง = จุด Silhouette + ครึ่งของ size => กึ่งกลาง
      ..position = blackSilhouette.position + (blackSilhouette.size / 2)
      ..priority = 16; // ให้มากกว่าชิ้นส่วนอื่นจะได้แสดงบนสุด
  }

  void doBounce(PositionComponent target) {
    final scaleUpDown = SequenceEffect([
      ScaleEffect.to(
        Vector2(0.2, 0.2),
        EffectController(duration: 0.06),
      ),
      ScaleEffect.to(
        Vector2(1.3, 1.3),
        EffectController(duration: 0.06),
      ),
      ScaleEffect.to(
        Vector2(1.0, 1.0),
        EffectController(duration: 0.06),
      ),
      ScaleEffect.to(
        Vector2(1.1, 1.1),
        EffectController(duration: 0.06),
      ),
    ]);

    // เพิ่ม effect เข้าไปในตัว target
    target.add(scaleUpDown);
  }

  void showCheckMark() {
    if (!checkMarkAdded) {
      add(checkMark);
      checkMarkAdded = true;
      doBounce(checkMark);
    }
  }

  void hideCheckMark() {
    if (checkMarkAdded) {
      remove(checkMark);
      checkMarkAdded = false;
    }
  }

  void loseHeart() {
    playerData.loseHeart();
    // บอกหน้า Screen ว่าหัวใจเหลือเท่าไหร่แล้ว
    onHPChanged?.call(playerData.hearts);

    // ถ้าหัวใจหมด อาจจบเกม หรือแจ้งเตือน
    if (playerData.hearts <= 0) {
      print("Game Over!");
      // สามารถเขียน logic เพิ่มเติมได้
      onGameOver!();
    }
  }

  /// เรียกเมธอดนี้เมื่อชิ้นใด snap สำเร็จ
  void onShapeSnapped() {
    snappedCount++;
    // ถ้าจำนวน Snap == จำนวนชิ้นใน levelData => ด่านนี้จบ
    if (snappedCount == levelData.pieces.length) {
      Future.delayed(Duration(milliseconds: 500), () {
        showCheckMark();
        Future.delayed(const Duration(seconds: 1), () {
          _loadNextLevelOrFinish();
          hideCheckMark();
        });
      });
    }
  }

  void _loadNextLevelOrFinish() {
    // 1) เพิ่มค่าด่าน
    TangramLevelManager.currentLevelIndex++;

    // 2) ถ้าด่านปัจจุบันเลยจำนวนด่านสุดท้าย => จบเกม
    if (TangramLevelManager.currentLevelIndex >=
        TangramLevelManager.allLevels.length) {
      if (onAllLevelComplete != null) {
        onAllLevelComplete!();
      }
      // user ชนะ -> อาจโชว์ Overlay / Navigator.push
      print("All levels completed! You win!");
      // game over...
    } else {
      print("🆕 Next Level: ${TangramLevelManager.currentLevelIndex}");
      if (onLevelComplete != null) {
        onLevelComplete!(); // เรียก setState ที่ State
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawColor(Colors.white, BlendMode.srcOver); // พื้นหลังขาว
    super.render(canvas);
  }
}
