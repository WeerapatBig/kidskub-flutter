import 'dart:math';

import 'package:firstly/screens_chapter4/components/grid.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../components/controller.dart';
import '../components/enemy.dart';
import '../components/enemy_intent_marker.dart';
import '../components/floating_score_text.dart';
import '../components/goal.dart';
import '../components/player.dart';
import '../levels/levels_data.dart';

class ColorGame extends FlameGame with HasCollisionDetection {
  bool _isLoaded = false; // เพิ่มตัวแปรป้องกัน onLoad() ซ้ำ

  // ตัวแปร/คอมโพเนนต์อื่น ๆ
  late PlayerComponent player;
  late GameController controller;
  late GameGrid grid;
  EnemyComponent? enemy; // เริ่มเป็น null
  List<EnemyIntentMarker> _enemyIntentMarkers = [];

  final List<GoalComponent> goals = [];
  final Random _random = Random();

  late SpriteComponent backgroundSprite; // ใช้สำหรับพื้นหลัง

  final Level levelData;

  int totalScore = 0;
  int consecutiveCorrect = 0;

  double timeLeft = 120;
  bool isGameOver = false;
  bool _isTimePaused = false;
  final ValueNotifier<int> timeNotifier = ValueNotifier<int>(120);
  final ValueNotifier<bool> bonusNotifier = ValueNotifier(false); // NEW

  bool _enemyInGame = false;
  bool _enemySpawned = false; // ตัวแปรบอกว่าได้สร้าง Enemy หรือยัง
  bool get isWarningState => _isWarningState;
  bool _isWarningState = false;
  bool isBonusState = false;
  double _warningTimer = 0.0;
  int _playerMoveCount = 0;
  final void Function(Color)? onTargetColorChanged;
  final void Function(bool isCorrect)? onAnswerResult;
  final void Function(int)? onScoreChanged;
  final void Function(int)? onComboChanged;
  final void Function(int starCount)? onGameOver;

  ColorGame(
    this.levelData, {
    this.onGameOver,
    this.onTargetColorChanged,
    this.onScoreChanged,
    this.onComboChanged,
    this.onAnswerResult,
    void Function(int index, bool isCorrect)? onAnswerEachColorIndex,
  }) {
    debugMode = false;
  }
  @override
  Color backgroundColor() => const Color.fromARGB(255, 255, 255, 255);

  @override
  Future<void> onLoad() async {
    controller = GameController(this);
    // ถ้าเคยโหลดไปแล้ว ให้ return ทันที
    if (_isLoaded) {
      debugPrint('⚠️ onLoad() ถูกเรียกซ้ำ แต่บล็อกไว้');
      return;
    }
    _isLoaded = true;

    final bgSprite =
        await loadSprite('colorgame/grid_bg_color.png'); // โหลดพื้นหลัง
    backgroundSprite = SpriteComponent(
      sprite: bgSprite,
      size: size, // ขนาดเต็มจอ
      position: Vector2.zero(),
    ); // ตำแหน่งเริ่มต้น
    await add(backgroundSprite); // เพิ่มพื้นหลังลงในเกม

    // ... (โหลด / add คอมโพเนนต์ต่าง ๆ ตามปกติ) ...
    grid = GameGrid();
    player = PlayerComponent();
    controller = GameController(this);

    await addAll([
      grid,
      player,
      controller,
    ]);
    // ✅ สุ่มแสดง Goal
    spawnRandomGoals();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isGameOver) {
      _handleWarningAndTime(dt); // 1) จัดการ Warning + เวลาถอยหลัง
    }

    if (_enemyInGame) {
      _checkEnemyCollision();
      _checkEnemyGoalCollision();
    }

    // Manual Checking: Player (สี่เหลี่ยม) กับ Goal (วงกลม) ทุกตัว
    // ถ้าชน => ลบ goal
    checkGoalCollision();
  }

  /// ================================================================
  /// ฟังก์ชัน _handleWarningAndTime() จัดการเวลา + Warning
  /// ================================================================

  void _handleWarningAndTime(double dt) {
    if (!isGameOver && !_isTimePaused) {
      // ถ้า "ไม่" อยู่ใน warningState => นับถอยหลังปกติ
      if (!_isWarningState) {
        timeLeft -= dt;
        if (timeLeft <= 0) {
          timeLeft = 0;

          endGame();
        }
        timeNotifier.value = timeLeft.floor();

        // ถ้า timeLeft <= 35 และยังไม่ spawnEnemy => เข้าสู่ warningState
        if (!_enemySpawned && timeLeft <= 25) {
          _isWarningState = true;
          _warningTimer = 2.0; // แสดงภาพ 2 วิ
          isBonusState = true;
          Future.delayed(const Duration(milliseconds: 1000), () {
            bonusNotifier.value = true; // ✅ ส่งค่าไปแจ้ง UI
          });
          // คำสั่ง “โชว์ภาพ warning” -> แล้วแต่คุณว่าจะแสดงใน Flutter/Overlay/ตัวแปร
          debugPrint("Warning! Enemy is about to spawn...");
        }
      } else {
        // อยู่ใน warningState => ไม่ลดเวลา
        // แต่ลด warningTimer
        _warningTimer -= dt;
        if (_warningTimer <= 0) {
          // ครบ 2 วิ => ปิด warningState
          _isWarningState = false;
          // Spawn enemy ทันที
          _spawnEnemy();
        }
      }
    }
  }

  /// ฟังก์ชันหยุดเวลาชั่วคราว
  void pauseGameTime() {
    _isTimePaused = true;
    debugPrint("⏸️ Game time is paused.");
  }

  /// ฟังก์ชันเริ่มนับเวลาต่อ
  void resumeGameTime() {
    _isTimePaused = false;
    debugPrint("▶️ Game time is resumed.");
  }

  /// ================================================================
  /// ฟังก์ชัน _checkGoalCollision() เช็กการชนระหว่าง Player กับ Goal
  /// ================================================================

  void checkGoalCollision() {
    final toRemove = <GoalComponent>[];
    for (final goal in List<GoalComponent>.from(goals)) {
      if (isCollidingRectCircle(player, goal)) {
        if (goal.colorTarget == levelData.targetColor.first) {
          player.startEating();
          onAnswerResult?.call(true);

          consecutiveCorrect++;
          onComboChanged?.call(consecutiveCorrect);
          final scoreThisTime = calculateComboScore(consecutiveCorrect);
          totalScore += scoreThisTime;
          onScoreChanged?.call(totalScore);
          // จุดสร้าง FloatingScoreText
          final effectPos =
              player.position.clone() // หรือ player.position.clone()
                ..y -= 80
                ..x -= 20;
          final floatingText = FloatingScoreText(
            text: "+$scoreThisTime",
            position: effectPos, // ตำแหน่งเริ่ม
            duration: 0.5, // ลอย 1 วินาที
            moveSpeed: 50.0, // ลอยขึ้นช้าๆ
            textColor: const Color.fromARGB(255, 255, 255, 255),
          );
          add(floatingText); // เพิ่มลงใน game

          toRemove.add(goal); // ✅ เพิ่มในลิสต์ที่จะลบ
          // 1) สุ่มเป้าหมายใหม่จาก Goal อื่น ๆ ที่เหลือ

          final nextColor = pickNextColorFromGoals(goal);
          // 2) เปลี่ยนสีเป้าหมายใหม่
          Future.delayed(const Duration(milliseconds: 500), () {
            // 1 วินาทีหลังจากเก็บ
            _changeTargetColor(nextColor);
            // เปลี่ยนสีเป้าหมายใหม่
          });
          // ✅ Spawn ใหม่หลังเก็บ
          spawnNewGoal(goal.colorTarget);
        } else {
          //กินผิดสีจะเรียกใช้ฟังก์ชันต่อไปนี้
          debugPrint("🚫 เก็บผิดสี! สีที่เก็บ: ${goal.colorTarget}");
          toRemove.add(goal); // ✅ ลบ Goal สีผิด
          player.eatingWrongColor();
          consecutiveCorrect = 0;
          onComboChanged?.call(0);
          onAnswerResult?.call(false);

          spawnNewGoal(goal.colorTarget); // ✅ Spawn ใหม่หลังเก็บสีผิด
        }
      }
    }
    // ลบ Goal ที่ชนออกจากเกม
    for (final g in toRemove) {
      g.removeFromParent();
      goals.remove(g);
    }
  }

  /// ================================================================
  /// ฟังก์ชัน spawnEnemy() เรียกใช้เมื่อถึงเวลา
  /// ================================================================

  void _spawnEnemy() {
    if (_enemySpawned) return; // กันเผื่อเรียกซ้ำ
    enemy = EnemyComponent();
    // ถ้าต้องการสุ่มตำแหน่ง
    enemy!.gridPosition = _getRandomEnemyPos();
    add(enemy!);
    _enemySpawned = true;
    _enemyInGame = true; // บอกว่า enemy พร้อมเดิน
    debugPrint("Enemy Spawned after warning!");
  }

  /// ================================================================
  /// ฟังก์ชัน incrementPlayerMoveCount() เรียกใช้เมื่อ Player เคลื่อนที่
  /// ================================================================

  void incrementPlayerMoveCount() {
    _playerMoveCount++;
    debugPrint("Player moved $_playerMoveCount times");

    // 1) ถ้า enemy อยู่ในเกม
    if (_enemyInGame && enemy != null) {
      if (_playerMoveCount == 2) {
        // คำนวณ nextPos ที่ศัตรู “ตั้งใจจะไป” แต่ยังไม่เดินจริง
        final possiblePositions = _predictEnemyNextPosMultiple();

        // สร้าง Marker ไว้ที่ nextPos
        _showEnemyIntentMarkers(possiblePositions);
      }
      if (_playerMoveCount >= 3) {
        // 2) ลบ Marker (ถ้ามี) แล้วให้ Enemy เดินจริง
        _hideEnemyIntentMarkers();
        _moveEnemyOneStep(); // ศัตรูเดิน 1 ช่อง
        _playerMoveCount = 0; // reset
      }
    }
  }

  /// ================================================================
  /// ฟังก์ชัน _predictEnemyNextMove() คำนวณตำแหน่ง Enemy ถัดไป
  /// ================================================================

  List<Vector2> _predictEnemyNextPosMultiple() {
    if (enemy == null) return [];

    final px = player.gridPosition.x;
    final py = player.gridPosition.y;
    final ex = enemy!.gridPosition.x;
    final ey = enemy!.gridPosition.y;

    double dx = px - ex;
    double dy = py - ey;

    // ตัวอย่างเงื่อนไข: ถ้า abs(dx) > abs(dy) -> อาจเดินแกน X เป็นหลัก
    // แต่ถ้า abs(dx)==abs(dy) -> แสดง 2 ทาง
    // หรือถ้าต้องการ logic อื่น ก็แก้ได้ตามต้องการ

    if (dx.abs() > dy.abs()) {
      // เดินแกน X อันเดียว
      final moveX = dx > 0 ? 1.0 : -1.0;
      return [enemy!.gridPosition + Vector2(moveX, 0)];
    } else if (dx.abs() < dy.abs()) {
      // เดินแกน Y อันเดียว
      final moveY = dy > 0 ? 1.0 : -1.0;
      return [enemy!.gridPosition + Vector2(0, moveY)];
    } else {
      // dx.abs() == dy.abs() => มี 2 ทาง
      final moveX = dx > 0 ? 1.0 : -1.0;
      final moveY = dy > 0 ? 1.0 : -1.0;
      final pos1 = enemy!.gridPosition + Vector2(moveX, 0);
      final pos2 = enemy!.gridPosition + Vector2(0, moveY);
      return [pos1, pos2];
    }
  }

  /// ================================================================
  /// ฟังก์ชัน _moveEnemyOneStep() เรียกใช้เมื่อ Player เคลื่อนที่
  /// ================================================================

  void _moveEnemyOneStep() {
    // แนวคิดง่าย ๆ: เช็คตำแหน่ง Player กับ Enemy
    // ขยับ Enemy 1 ช่องไปหา Player
    if (enemy == null) return;

    _hideEnemyIntentMarkers(); // ลบ Marker (ถ้ามี) ก่อนเดิน
    final list = _predictEnemyNextPosMultiple();
    if (list.isEmpty) return;

    // เลือก 1 pos จาก list
    final chosenPos =
        list.length == 1 ? list.first : list[_random.nextInt(list.length)];

    enemy!.moveTo(chosenPos);
  }

  /// ================================================================
  /// ฟังก์ชัน _checkEnemyCollision() เช็กการชนระหว่าง Enemy กับ Player
  /// ================================================================

  void _checkEnemyCollision() {
    if (enemy == null) return; // ยังไม่ spawn
    Rect enemyRect = enemy!.toRect(); // สร้างเมธอด toRect() เหมือน player
    Rect playerRect = player.boundingBox;
    if (_isCollidingRectRect(enemyRect, playerRect)) {
      // 1) ลบผู้เล่นออกจากเกม
      player.removeFromParent();

      endGame();
    }
  }

  void _checkEnemyGoalCollision() {
    if (enemy == null) return;
    // สร้างลิสต์ goal ที่จะลบ
    final toRemove = <GoalComponent>[];

    // เอา Rect ศัตรูมา
    final enemyRect = enemy!.toRect(); // enemy!.gridPosition => toRect()

    for (final goal in List<GoalComponent>.from(goals)) {
      // ใช้เมธอดตรวจ collision ระหว่าง "Rect" vs "Goal (Circle)"
      if (_isCollidingRectCircleRect(enemyRect, goal)) {
        // ถ้า Enemy ชน Goal => ลบ Goal แล้ว spawn ใหม่
        toRemove.add(goal);
        // spawn ใหม่
        spawnNewGoal(goal.colorTarget);
      }
    }

    // ลบ Goal ที่ชนออก
    for (final g in toRemove) {
      g.removeFromParent();
      goals.remove(g);
    }
  }

  //=================================================================
  // _showEnemyIntentMarker() -> แสดง Marker บอกตำแหน่ง Enemy
  //=================================================================

  void _showEnemyIntentMarkers(List<Vector2> positions) {
    // ถ้ามี marker เก่าอยู่ ให้ลบทิ้งก่อน
    _hideEnemyIntentMarkers();

    for (final pos in positions) {
      // สร้าง marker
      final marker = EnemyIntentMarker(pos);
      add(marker);
      _enemyIntentMarkers.add(marker);
    }
    debugPrint("Showed Enemy Intent Marker at $positions");
  }

  //================================================================
  // _hideEnemyIntentMarker() -> ลบ marker
  //================================================================

  void _hideEnemyIntentMarkers() {
    for (final marker in _enemyIntentMarkers) {
      marker.removeFromParent();
    }
    _enemyIntentMarkers.clear();
    debugPrint("Removed Enemy Intent Markers");
  }

  /// ================================================================
  /// ฟังก์ชัน _changeTargetColor() เปลี่ยนสีเป้าหมาย
  /// ================================================================

  // เวลาเปลี่ยนสีเป้าหมาย
  void _changeTargetColor(Color newColor) {
    levelData.targetColor = [newColor];
    // เรียก callback ถ้ามี
    onTargetColorChanged?.call(newColor);
  }

  /// เลือก "สีเป้าหมายใหม่" จาก Goal ทั้งหมดที่ยังเหลือใน goals
  /// (สมมติเอาเฉพาะ goal คนละสีที่ยังไม่ถูกเก็บ)
  Color pickNextColorFromGoals(GoalComponent removedGoal) {
    // ก็อปปี้รายการ Goal ปัจจุบัน
    final remainingGoals = List<GoalComponent>.from(goals);

    // เอาตัวที่กำลังจะลบออก
    remainingGoals.remove(removedGoal);

    if (remainingGoals.isNotEmpty) {
      final randIndex = _random.nextInt(remainingGoals.length);
      return remainingGoals[randIndex].colorTarget;
    } else {
      // ถ้าในจอไม่มีโกลเหลือเลย ให้ fallback เป็นสีแดงหรือสีเริ่มต้น
      return Colors.red;
    }
  }

  //================================================================
  // 9) spawnNewGoal() -> สร้าง Goal ใหม่ 1 ตัว โดย "ไม่" ใช้ attempts
  //================================================================
  void spawnNewGoal(Color color) {
    // 1) หา freePositions ที่ว่าง (ไม่ซ้อนใคร)
    final freePositions = findAllFreePositions(
      minDistanceFromPlayer: 2.0, // หรือใส่ 1.0 ก็ได้
    );

    if (freePositions.isEmpty) {
      debugPrint("⚠️ spawnNewGoal: ไม่มีตำแหน่งว่างสำหรับ Goal สี $color");
      return;
    }
    // 2) เลือกสุ่ม 1 ตำแหน่ง
    final index = _random.nextInt(freePositions.length);
    final chosenPos = freePositions[index];

    // 3) สร้าง Goal
    final newGoal = GoalComponent(chosenPos, color);
    add(newGoal);
    goals.add(newGoal);

    debugPrint("✨ สร้าง Goal ใหม่สี $color ที่ตำแหน่ง $chosenPos");
  }

  //================================================================
  // 10) spawnRandomGoals() -> สร้างหลาย Goal ทีเดียว (6 สี)
  //================================================================
  void spawnRandomGoals() {
    final numGoals = levelData.numberOfGoals;
    final List<Color> colors = goalColors.take(numGoals).toList();

    // ดึงตำแหน่งว่างก่อน
    var freePositions = findAllFreePositions(minDistanceFromPlayer: 2.0);

    // ถ้าจำนวนตำแหน่งว่าง < จำนวนสีที่ต้องสร้าง => อาจจะสร้างได้ไม่ครบ
    if (freePositions.length < colors.length) {
      debugPrint("⚠️ spawnRandomGoals: ตำแหน่งว่างไม่พอจะสร้าง Goal ครบ 6");
    }

    for (final color in colors) {
      if (freePositions.isEmpty) {
        debugPrint("⚠️ ไม่มีช่องว่างเหลือ => หยุดสร้าง Goal");
        break;
      }
      final i = _random.nextInt(freePositions.length);
      final chosenPos = freePositions[i];

      final goal = GoalComponent(chosenPos, color);
      add(goal);
      goals.add(goal);
      debugPrint("🎯 Spawned Goal color=$color at $chosenPos");

      // เอาตำแหน่งที่ใช้ไปแล้ว ออกจากลิสต์
      freePositions.removeAt(i);
    }
  }

  //================================================================
  // 11) ค้นหารายการช่องว่างทั้งหมด (ไม่ทับซ้อน + ห่าง Player)
  //================================================================
  List<Vector2> findAllFreePositions({
    double minDistanceFromPlayer = 0.0,
  }) {
    // 1) สร้าง Set ของตำแหน่ง "ที่ถูกยึด"
    final occupiedPositions = <Vector2>{};

    // ใส่ player
    occupiedPositions.add(player.gridPosition.clone());

    // ถ้ามี enemy => ใส่ด้วย
    if (enemy != null) {
      occupiedPositions.add(enemy!.gridPosition.clone());
    }

    // ใส่ทุก goal
    for (final g in goals) {
      occupiedPositions.add(g.spawnPosition.clone());
    }

    // 2) สร้างลิสต์ "ตำแหน่งทั้งหมดในกริด"
    final allPositions = <Vector2>[];
    for (int x = 0; x < kGridWidth; x++) {
      for (int y = 0; y < kGridHeight; y++) {
        allPositions.add(Vector2(x.toDouble(), y.toDouble()));
      }
    }

    // 3) ลบตำแหน่งที่ถูกยึด
    allPositions.removeWhere((pos) => occupiedPositions.contains(pos));

    // 4) ถ้าต้องการกันให้ห่างจาก player
    if (minDistanceFromPlayer > 0) {
      allPositions.removeWhere((pos) {
        final dist = (pos - player.gridPosition).length;
        return dist < minDistanceFromPlayer;
      });
    }

    return allPositions;
  }

  //================================================================
  // 12) repositionGoals() -> ลบ Goal เก่า => สร้างใหม่
  //================================================================
  void repositionGoals() {
    for (final goal in goals) {
      goal.removeFromParent();
    }
    goals.clear();
    spawnRandomGoals();
  }

  //================================================================
  // 13) สุ่มตำแหน่งศัตรู Enemy
  //================================================================
  Vector2 _getRandomEnemyPos() {
    while (true) {
      final x = _random.nextInt(kGridWidth);
      final y = _random.nextInt(kGridHeight);
      final pos = Vector2(x.toDouble(), y.toDouble());
      final dist = (pos - player.gridPosition).length;
      if (dist >= 2.0) {
        return pos;
      }
      // ถ้าไม่ผ่านเงื่อนไขก็วนสุ่มต่อ
    }
  }

  //================================================================
  // 14) ฟังก์ชันตรวจสอบการชน Rect vs Rect
  //================================================================
  bool _isCollidingRectRect(Rect r1, Rect r2) {
    return r1.overlaps(r2);
  }

  //================================================================
  // 15) ฟังก์ชันคำนวณคะแนน
  //================================================================
  int calculateComboScore(int comboCount) {
    int rawScore;
    if (isBonusState) {
      rawScore = 30 + 4 * (comboCount - 1);
      if (rawScore > 40) rawScore = 40;
    } else {
      rawScore = 10 + 2 * (comboCount - 1);
      if (rawScore > 20) rawScore = 20;
    }
    return rawScore;
  }

  int calculateStars(int score) {
    if (score >= 980) return 3;
    if (score >= 680) return 2;
    if (score >= 380) return 1;
    return 0;
  }

  void endGame() {
    if (!isGameOver) {
      isGameOver = true;
      // หยุดการทำงานหลัก (update())
      final starCount = calculateStars(totalScore);
      onGameOver?.call(starCount);
    }
  }

  //================================================================
  // 16) ฟังก์ชันตรวจสอบการชน (PlayerRect vs Goal วงกลม)
  //================================================================
  bool isCollidingRectCircle(
      PlayerComponent rectComp, GoalComponent circleComp) {
    final playerRect = rectComp.boundingBox;
    final centerGoal = circleComp.getCenter();
    final cx = centerGoal.x;
    final cy = centerGoal.y;
    final r = circleComp.radius;

    final closestX = cx.clamp(playerRect.left, playerRect.right);
    final closestY = cy.clamp(playerRect.top, playerRect.bottom);

    final dx = cx - closestX;
    final dy = cy - closestY;
    final distSq = dx * dx + dy * dy;

    return distSq <= (r * r);
  }

  bool _isCollidingRectCircleRect(Rect r, GoalComponent circle) {
    final centerGoal = circle.getCenter(); // ได้ (x + radius, y + radius)
    final cx = centerGoal.x;
    final cy = centerGoal.y;
    final rGoal = circle.radius;

    // หา closestX, closestY
    final closestX = cx.clamp(r.left, r.right);
    final closestY = cy.clamp(r.top, r.bottom);

    final dx = cx - closestX;
    final dy = cy - closestY;
    final distSq = dx * dx + dy * dy;

    return distSq <= (rGoal * rGoal);
  }

  //================================================================
  // 17) แปลงตำแหน่งพิกเซล -> GridPos
  //================================================================
  Vector2 toGridPosition(Vector2 pixelPos) {
    final offsetX = kGridOffsetX;
    final offsetY = kGridOffsetY;
    final gx = ((pixelPos.x - offsetX) / kTileSize).floorToDouble();
    final gy = ((pixelPos.y - offsetY) / kTileSize).floorToDouble();
    return Vector2(gx, gy);
  }

  //================================================================
  // 18) Reset Game
  //================================================================
  void resetGame() {
    debugPrint("=== resetGame() START ===");

    // 1) ลบ Enemy (ถ้ามี)
    if (enemy != null) {
      enemy!.removeFromParent();
      enemy = null;
      debugPrint("• Removed old Enemy");
    }

    // 2) ลบ Goals
    for (final g in goals) {
      g.removeFromParent();
    }
    goals.clear();
    debugPrint("• Removed all Goals");

    // 3) ลบ Player เดิม ถ้า Player มีอนิเมชันกินอยู่ ให้เคลียร์มันก่อน
    //    เช่น Player มีฟังก์ชัน clearEatingAnimation()
    //    ถ้าไม่มี ก็ข้ามได้
    try {
      // ถ้า Player มีตัวแปร public หรือเมธอดสำหรับลบอนิเมชันกิน:
      player.clearEatingAnimation(); // สมมุติว่ามี
    } catch (e) {
      debugPrint("• No eating animation to clear: $e");
    }
    player.removeFromParent();
    debugPrint("• Removed old Player");

    // 4) สร้าง Player ใหม่ (idle)
    final newPlayer = PlayerComponent();
    // ถ้าต้องการตั้งค่าสีเริ่มต้น หรือตำแหน่ง gridPosition ก็ทำได้
    // newPlayer.currentColor = Colors.white;
    add(newPlayer);
    player = newPlayer;
    debugPrint("• Created and added new Player");

    // 5) รีเซ็ตตัวแปรสถานะต่าง ๆ
    timeLeft = 120;
    isGameOver = false;
    _playerMoveCount = 0;
    totalScore = 0;
    consecutiveCorrect = 0;

    _isWarningState = false;
    _warningTimer = 0.0;
    isBonusState = false;
    bonusNotifier.value = false;

    _enemySpawned = false;
    _enemyInGame = false;

    // ถ้าต้องการรีเซ็ต timeNotifier ด้วย:
    timeNotifier.value = 120;

    debugPrint("• Reset game states");

    // 6) สร้าง Goal ใหม่
    spawnRandomGoals();
    debugPrint("• Spawned new Goals");

    debugPrint("=== resetGame() COMPLETE ===");
  }
}
//================================================================
