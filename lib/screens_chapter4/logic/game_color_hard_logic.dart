// game_color_hard_logic.dart
import 'package:firstly/screens_chapter4/components/goal.dart';
import 'package:flutter/material.dart';
import '../components/floating_score_text.dart';
import '../levels/levels_data.dart';
import 'game_color_logic.dart';

class ColorGameHard extends ColorGame {
  // เก็บสถานะว่าผู้เล่นเก็บสีอะไรไปแล้วบ้าง (ในรอบปัจจุบัน)
  // จนกว่าจะครบ 2 สีค่อยให้คะแนน
  final List<Color> _collectedThisRound = [];
  final void Function(int index, bool isCorrect)? onAnswerEachColorIndex;

  ColorGameHard(
    Level levelData, {
    this.onAnswerEachColorIndex,
    Function(int)? onScoreChanged,
    Function(Color)? onTargetColorChanged,
    Function(int)? onComboChanged,
    Function(bool)? onAnswerResult,
    Function(int)? onGameOver,
  }) : super(
          levelData,
          onScoreChanged: onScoreChanged,
          onTargetColorChanged: onTargetColorChanged,
          onComboChanged: onComboChanged,
          onAnswerResult: onAnswerResult,
          onGameOver: onGameOver,
        );
  @override
  void checkGoalCollision() {
    // ทำเป็นว่างเพื่อไม่ให้ parent's logic มาแทรก
  }
  @override
  void update(double dt) {
    super.update(dt);
    checkGoalCollisionHard();
    // ยังคงใช้ระบบ Enemy + เวลา เหมือนเดิมได้
  }

  void checkGoalCollisionHard() {
    final toRemove = <GoalComponent>[];

    for (final goal in List<GoalComponent>.from(goals)) {
      if (!isCollidingRectCircle(player, goal)) continue;

      final goalColor = goal.colorTarget;
      final targetIndex = levelData.targetColor.indexOf(goalColor);
      final isCorrect = levelData.targetColor.contains(goalColor);

      if (isCorrect) {
        // ✅ กรณีเก็บสีถูก
        if (!_collectedThisRound.contains(goalColor)) {
          _collectedThisRound.add(goalColor);
          if (targetIndex != -1) {
            onAnswerEachColorIndex?.call(targetIndex, true);
          }
        }

        player.startEating();
        onAnswerResult?.call(true);

        // ลบ goal ที่ชนออก
        toRemove.add(goal);
        goals.remove(goal);

        if (_collectedAll2Colors()) {
          _handleScoring();
          _collectedThisRound.clear();
          final newColors = _randomUniqueTargetColors(2);

          Future.delayed(const Duration(milliseconds: 500), () {
            _changeTargetColors(newColors);
          });
        }
      } else {
        // ❌ กรณีเก็บผิด
        player.eatingWrongColor();
        onAnswerResult?.call(false);
        consecutiveCorrect = 0;
        onComboChanged?.call(0);

        // ✅ แจ้งว่าทุกเป้าหมายผิด (ยกเว้นช่องที่เคยถูกแล้ว)
        for (int i = 0; i < levelData.targetColor.length; i++) {
          final color = levelData.targetColor[i];
          if (!_collectedThisRound.contains(color)) {
            onAnswerEachColorIndex?.call(i, false);
          }
        }

        // ลบ goal
        toRemove.add(goal);
        goals.remove(goal);
      }

      spawnNewGoal(goalColor);
    }

    // ลบทุก goal ที่ต้องลบ
    for (final g in toRemove) {
      g.removeFromParent();
    }
  }

  bool _collectedAll2Colors() {
    // เก็บให้ได้ 2 สีไม่ซ้ำ
    return _collectedThisRound.toSet().length == 2;
  }

  List<Color> _randomUniqueTargetColors(int count) {
    final uniquePool = List<Color>.from(goalColors)..shuffle();
    return uniquePool.take(count).toList();
  }

  // ฟังก์ชันเปลี่ยนเป้าหมาย (2 สี) แล้วเรียก callback
  void _changeTargetColors(List<Color> newColors) {
    levelData.targetColor = newColors;
    // สมมติแก้ callback ให้รองรับ List<Color>
    // หรือถ้ายังมีแค่ onTargetColorChanged(Color)
    // ก็ส่งไปแค่สีแรก หรือไม่ส่งเลย
    if (onTargetColorChanged != null && newColors.isNotEmpty) {
      onTargetColorChanged!(newColors.first);
    }
  }

  void _handleScoring() {
    // ครั้งแรกใน combo => +20, ถ้า combo ต่อ => +4
    // ถ้าช่วง bonus => *2
    consecutiveCorrect++;
    onComboChanged?.call(consecutiveCorrect);

    // คิดคะแนนพื้นฐาน
    int baseScore =
        (consecutiveCorrect == 1) ? 20 : (20 + 4 * (consecutiveCorrect - 1));

    // ถ้าอยู่ในโหมด bonus => คูณ 2
    if (isBonusState) {
      baseScore *= 2;
    }

    totalScore += baseScore;
    onScoreChanged?.call(totalScore);

    // สร้าง FloatingScoreText แบบเดียวกับ parent
    final effectPos = player.position.clone()
      ..y -= 80
      ..x -= 20;
    final floatingText = FloatingScoreText(
      text: "+$baseScore",
      position: effectPos,
      duration: 0.5,
      moveSpeed: 50.0,
      textColor: const Color.fromARGB(255, 255, 255, 255),
    );
    add(floatingText);
  }
}
