// lib/game/hard_line_game.dart
import 'dart:ui';
import 'package:firstly/screens_chapter2/linegamehard/components/circle_obstacle.dart';
import 'package:firstly/screens_chapter2/linegamehard/game/line_in_world.dart';
import 'package:firstly/screens_chapter2/linegamehard/components/moving_obstacle_component.dart';
import 'package:firstly/screens_chapter2/linegamehard/components/obstacle_component.dart';
import 'package:firstly/screens_chapter2/linegamehard/components/player_component.dart';
import 'package:firstly/screens_chapter2/linegamehard/game/point_goal_component.dart';
import 'package:firstly/screens_chapter2/linegamehard/components/rectangle_obstacle.dart';
import 'package:firstly/screens_chapter2/linegamehard/components/star_component.dart';
import 'package:firstly/screens_chapter2/linegamehard/models/level_data_hard.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../components/screen_fade_transition.dart';
//import 'line_system.dart'; // import Line, CustomPullBackEffect, LineFollowEffect

class HardLineGame extends FlameGame
    with HasCollisionDetection, DragCallbacks, TapCallbacks {
  VoidCallback? onUpdateUI;
  final void Function(bool)? onChapterEnd;

  bool isGameOver = false;

  Map<int, int> starsPerLevel = {};

  // HP, Stars
  int hp = 3;
  int stars = 0;

  int currentLevelIndex = 0;

  // เก็บ line
  final List<LineInWorld> lines = [];
  bool isLineComplete = false;
  double currentSliderValue = 0;

  // player
  late MyPlayerComponent player;

  // pivotIndex => จุดปัจจุบันที่ผู้เล่นเพิ่งไปถึง
  int pivotIndex = 0;

  // เก็บอ้างอิง obstacle, star, movingObs, etc.
  ObstacleComponent? obstacle;
  RectangleObstacleComponent? rectangle;
  CircleObstacleComponent? circle;
  MovingObstacleComponent? movingObs;
  StarComponent? star;

  late CameraComponent cam;
  late World world;

  static const int backgroundPriority = -1;
  static const int elementPriority = 0;
  static const int playerPriority = 4;
  static const int obstraclePriority = 1;
  static const int trianglePriority = 2;
  static const int starPriority = 1;

  // เปิดโหมด Debug
  HardLineGame({required this.onChapterEnd}) {
    debugMode = false; // เปิดแสดง Hitbox Debug
  }
  // ด่าน
  final List<LevelDataHard> levels = [
    // ===== Level 1 =====
    LevelDataHard(points: [
      Offset(200, 350),
      Offset(400, 350),
      Offset(800, 350),
      Offset(1120, 350),
    ], obstacles: [
      ObstacleData(
        offsetX: 600,
        offsetY: 0.8,
        width: 500,
        height: 500,
        spritePath: 'linegamelist/obstacle/obs_1.png',
        angle: 0,
      ),
    ], rectangleObstacles: [
      RectangleObstacleData(
          spritePath: 'linegamelist/obstacle/rect_obs_1.png',
          offsetX: 80,
          offsetY: 0.96,
          width: 416,
          height: 541,
          angle: 0),
      RectangleObstacleData(
          spritePath: 'linegamelist/obstacle/rect_obs_2.png',
          offsetX: 1200,
          offsetY: 0.96,
          width: 416,
          height: 541,
          angle: 0),
    ], stars: [
      StarData(offsetX: 600, offsetY: 0.25, width: 80, height: 80)
    ], scenery: [
      SceneryData(
          spritePath: 'linegamelist/flag.png',
          offsetX: 1140,
          offsetY: 0.42,
          width: 60,
          height: 90)
    ]),
    // ===== Level 2 =====
    LevelDataHard(points: [
      Offset(160, 380),
      Offset(360, 300),
      Offset(750, 300),
      Offset(1125, 600),
      Offset(1125, 180),
      Offset(1300, 380),
      Offset(1500, 300),
      Offset(2150, 380),
    ], obstacles: [
      ObstacleData(
        spritePath: 'linegamelist/obstacle/obs_1.png',
        offsetX: 560,
        offsetY: 0.7,
        width: 530,
        height: 560,
        angle: 0,
      ),
    ], rectangleObstacles: [
      RectangleObstacleData(
          spritePath: 'linegamelist/obstacle/rect_obs_1.png', //Start Object
          offsetX: 50,
          offsetY: 0.95,
          width: 400,
          height: 500,
          angle: 0),
      RectangleObstacleData(
          spritePath: 'linegamelist/obstacle/rect_obs_2.png', //End Object
          offsetX: 2200,
          offsetY: 0.95,
          width: 400,
          height: 500,
          angle: 0),
      RectangleObstacleData(
          spritePath: 'linegamelist/obstacle/rect_obs_3.png', //Object Purple
          offsetX: 950,
          offsetY: 0.05,
          width: 220,
          height: 420,
          angle: 0),
      RectangleObstacleData(
          spritePath: 'linegamelist/obstacle/rect_obs_2.png',
          offsetX: 1400,
          offsetY: -0.02,
          width: 200,
          height: 300,
          angle: 37),
      RectangleObstacleData(
          spritePath: 'linegamelist/obstacle/rect_obs_3.png', //Object Purple
          offsetX: 1750,
          offsetY: 0.75,
          width: 220,
          height: 500,
          angle: 0),
    ], stars: [
      StarData(offsetX: 1300, offsetY: 0.25, width: 80, height: 80)
    ], movingObstacles: [
      MovingObjectData(offsetX: 1750, offsetY: 0.01, width: 220, height: 500),
    ], scenery: [
      SceneryData(
          spritePath: 'linegamelist/flag.png',
          offsetX: 2170,
          offsetY: 0.45,
          width: 60,
          height: 90),
      SceneryData(
          spritePath: 'linegamelist/obstacle/rect_obs_1.png',
          offsetX: 2800,
          offsetY: 0.5,
          width: 500,
          height: 900),
    ]),
    // ===== Level 3 =====
    LevelDataHard(points: [
      Offset(160, 400),
      Offset(500, 400),
      Offset(850, 600),
      Offset(1420, 280),
      Offset(1890, 280),
      Offset(2440, 650),
      Offset(2900, 350),
      Offset(3070, 180),
      Offset(3070, 520),
      Offset(3240, 350),
      Offset(3900, 350),
      Offset(4500, 350),
    ], circleObstacles: [
      CircleObstacleData(
          spritePath: 'linegamelist/obstacle/circle_obs_1.png',
          offsetX: 2400,
          offsetY: 0.2,
          width: 750,
          height: 750),
      CircleObstacleData(
          spritePath: 'linegamelist/obstacle/circle_obs_2.png',
          offsetX: 4000,
          offsetY: 1,
          width: 550,
          height: 550)
    ], rectangleObstacles: [
      RectangleObstacleData(
          spritePath: 'linegamelist/obstacle/rect_obs_1.png', //Start Object
          offsetX: 50,
          offsetY: 0.95,
          width: 400,
          height: 500,
          angle: 0),
      RectangleObstacleData(
          spritePath: 'linegamelist/obstacle/rect_obs_4.png', //End Object
          offsetX: 5100,
          offsetY: 0.87,
          width: 1433,
          height: 433,
          angle: 0),
      RectangleObstacleData(
          spritePath: 'linegamelist/obstacle/rect_obs_3.png', //Object Purple
          offsetX: 850,
          offsetY: 0.26,
          width: 260,
          height: 550,
          angle: 0),
      RectangleObstacleData(
          spritePath: 'linegamelist/obstacle/rect_obs_2.png',
          offsetX: 600,
          offsetY: 1,
          width: 200,
          height: 300,
          angle: 20),
      RectangleObstacleData(
          spritePath: 'linegamelist/obstacle/rect_obs_3.png', //Object Purple
          offsetX: 1650,
          offsetY: 0.78,
          width: 220,
          height: 550,
          angle: 0),
      RectangleObstacleData(
          spritePath: 'linegamelist/obstacle/rect_obs_2.png', //Object Green
          offsetX: 1950,
          offsetY: 0.01,
          width: 180,
          height: 180,
          angle: 2),
      RectangleObstacleData(
          spritePath: 'linegamelist/obstacle/rect_obs_3.png', //Object Purple
          offsetX: 3500,
          offsetY: 1.23,
          width: 220,
          height: 550,
          angle: 0),
    ], obstacles: [
      ObstacleData(
          spritePath: 'linegamelist/obstacle/obs_3.png',
          offsetX: 1400,
          offsetY: 1,
          width: 320,
          height: 300,
          angle: 4),
      ObstacleData(
          spritePath: 'linegamelist/obstacle/obs_2.png',
          offsetX: 2800,
          offsetY: 0.95,
          width: 380,
          height: 360,
          angle: 0),
      ObstacleData(
          spritePath: 'linegamelist/obstacle/obs_3.png',
          offsetX: 2780,
          offsetY: 0.04,
          width: 420,
          height: 420,
          angle: 4.8),
    ], movingObstacles: [
      MovingObjectData(offsetX: 1650, offsetY: 0.01, width: 220, height: 500),
      MovingObjectData(offsetX: 3500, offsetY: 0.35, width: 220, height: 590),
    ], stars: [
      StarData(offsetX: 3240, offsetY: 0.25, width: 80, height: 80)
    ], scenery: [
      SceneryData(
          spritePath: 'linegamelist/flag.png',
          offsetX: 4520,
          offsetY: 0.42,
          width: 60,
          height: 90),
      SceneryData(
          spritePath: 'linegamelist/obstacle/elm_02.png',
          offsetX: 5000,
          offsetY: 0.35,
          width: 568,
          height: 760.5),
      SceneryData(
          spritePath: 'linegamelist/obstacle/elm_01.png',
          offsetX: 4660,
          offsetY: 0.46,
          width: 166,
          height: 150),
    ])
  ];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // พื้นหลัง
    final bgSprite = await loadSprite('linegamelist/gridblue.png');
    final background = SpriteComponent()
      ..sprite = bgSprite
      ..size = Vector2(
          size.y * (bgSprite.originalSize.x / bgSprite.originalSize.y),
          size.y) // Fit Height
      ..position = Vector2(
          (size.x -
                  (size.y *
                      (bgSprite.originalSize.x / bgSprite.originalSize.y))) /
              2,
          0) // Centering
      ..priority = backgroundPriority;
    add(background);
  }

  @override
  Future<void> onMount() async {
    super.onMount();

    // **สร้างโลกของเกม**
    world = World();
    add(world); // เพิ่ม World เข้าไปก่อน

    // **สร้างพื้นหลังหรือขอบเขตของโลก**
    final worldBounds = PositionComponent()
      ..size = Vector2(size.x * 2, size.y); // กำหนดขนาดของโลก
    world.add(worldBounds); // เพิ่มขอบเขตลงในโลก

    // **กำหนดให้กล้องใช้โลกนี้**
    cam = CameraComponent(
      world: world,

      // ทำให้กล้องมี viewport ขนาดพอดีกับจอ
      viewport: FixedResolutionViewport(
        resolution: Vector2(size.x, size.y),
      ),
    );
    cam.viewfinder.anchor = Anchor.topLeft;
    add(cam);

    // **ให้กล้องติดตาม Player**
    // สร้าง player (ครั้งแรก)
    player = MyPlayerComponent(priority: playerPriority);
    world.add(player);

    // เริ่มจากด่าน 0
    await _loadLevel(currentLevelIndex);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // กำหนด “โซน” ที่ถ้าผู้เล่นเข้าใกล้ขอบขวาจอเกิน 70%
    // => สั่งกล้องตามผู้เล่น
    final cameraLeft = cam.viewfinder.position.x;
    //final cameraRight = cameraLeft + size.x;
    // ขอบขวาจอ = cameraLeft + width
    // หรือ cameraRight

    // เมื่อผู้เล่นเคลื่อนที่ไปทางขวาเกิน เปอร์เซ็นของหน้าจอ
    final thresholdRight = cameraLeft + size.x * 0.4;

    //เมื่อผู้เล่นเคลื่อนที่ไปทางซ้ายเกิน เปอร์เซ็นของหน้าจอ

    if (player.position.x > thresholdRight && currentLevelIndex >= 1) {
      // ให้กล้องตาม
      cam.follow(player,
          horizontalOnly: true, verticalOnly: false, maxSpeed: 220);
    }

    // สมมติถ้าต้องการ “หยุดเลื่อน” เมื่อผู้เล่นกลับมาด้านซ้าย
    // (หรือไม่ต้องหยุดก็ได้)
    // ตัวอย่างเช่น ถ้า player < cameraLeft+width*0.3 => หยุด
    final thresholdLeft = cameraLeft + size.x * 0.6;
    if (player.position.x < thresholdLeft && currentLevelIndex >= 1) {
      cam.stop();
      // ทำให้กล้องไม่ขยับตาม player หาก player กลับมาเขตซ้าย
    }
  }

  Future<void> _loadLevel(int index) async {
    print('🔄 กำลังโหลด Level: $index');
    // 1) ลบ LineInWorld เก่า ๆ ทั้งหมด
    for (final l in lines) {
      l.removeFromParent(); // ถ้าเส้นเคย add เข้า world
    }
    lines.clear();
    isLineComplete = false;

    // 2) ลบ obstacle, star, rectangle, circle, triangle, movingObs ที่อ้างอิงอยู่
    world.removeAll(world.children.whereType<ObstacleComponent>().toList());
    obstacle = null;

    world.removeAll(
        world.children.whereType<RectangleObstacleComponent>().toList());
    rectangle = null;

    world.removeAll(
        world.children.whereType<CircleObstacleComponent>().toList());
    circle = null;

    world.removeAll(
        world.children.whereType<MovingObstacleComponent>().toList());
    movingObs = null;

    world.removeAll(world.children.whereType<StarComponent>().toList());
    star = null;

    world.removeAll(
      world.children.whereType<PointGoalComponent>().toList(),
    );

    // 3) ลบ scenery เก่า ๆ ออก (SpriteComponent ที่ไม่ใช่ player)
    //   ถ้าในเกมคุณสร้าง scenery ด้วย priority == elementPriority
    //   และอยู่ใน world เหมือนกัน
    world.removeAll(
      world.children
          .where((c) =>
              c is SpriteComponent &&
              c.priority == elementPriority &&
              c != player)
          .toList(),
    );

    cam.viewfinder.position = Vector2.zero();
    await Future.delayed(
        const Duration(milliseconds: 100)); // ✅ รอให้ค่าปรับก่อน

    pivotIndex = 0;
    currentLevelIndex = index; // ตั้ง current เป็นด่านใหม่

    // 2) อ่าน level data
    final levelData = levels[currentLevelIndex];

    // 6) นำ Player กลับเข้า world (ถ้าหลุดไปแล้ว) และตั้งตำแหน่งจุดแรก
    if (player.parent == null) {
      world.add(player);
    }
    // วาง Player => ไม่ removePlayer ถ้าอยากคง HP/stars
    // แต่ถ้าคุณ removeFromParent() ก็ต้อง add(player) ใหม่
    final firstPix = levelData.points[0];
    player.position = Vector2(firstPix.dx - 60, firstPix.dy);

    // สร้างจุด
    for (final p in levelData.points) {
      final comp = PointGoalComponent(position: Vector2(p.dx, p.dy));
      world.add(comp);
    }

    // #### obstacles
    for (final obs in levelData.obstacles) {
      final obsComp = ObstacleComponent(
        position: Vector2(obs.offsetX, size.y * obs.offsetY),
        size: Vector2(obs.width, obs.height),
        priority: obstraclePriority,
        spritePath: obs.spritePath,
        angle: obs.angle,
      );
      world.add(obsComp);
      obstacle = obsComp; // ถ้าจะเก็บ ref
    }

    // #### moving obstacle
    for (final mo in levelData.movingObstacles) {
      final mov = MovingObstacleComponent(
        position: Vector2(mo.offsetX, mo.offsetY * size.y),
        size: Vector2(mo.width, mo.height),
        priority: obstraclePriority,
      );
      world.add(mov);
      movingObs = mov;
    }

    for (final recto in levelData.rectangleObstacles) {
      final rect = RectangleObstacleComponent(
          position: Vector2(recto.offsetX, recto.offsetY * size.y),
          size: Vector2(recto.width, recto.height),
          priority: obstraclePriority,
          spritePath: recto.spritePath,
          angle: recto.angle);
      world.add(rect);
      rectangle = rect;
    }

    for (final cir in levelData.circleObstacles) {
      final cirComp = CircleObstacleComponent(
        position: Vector2(cir.offsetX, cir.offsetY * size.y),
        size: Vector2(cir.width, cir.height),
        priority: obstraclePriority,
        spritePath: cir.spritePath,
      );
      world.add(cirComp);
      circle = cirComp;
    }

    // #### star
    for (final st in levelData.stars) {
      final stComp = StarComponent(
          position: Vector2(st.offsetX, st.offsetY * size.y),
          size: Vector2(st.width, st.height),
          priority: starPriority // สมมติ 0 = scenery
          );
      world.add(stComp);
      star = stComp;
    }

    // 4) สร้าง Scenery => loop sceneryData
    for (final sData in levelData.scenery) {
      await _buildAndAddScenery(sData);
    }
  }

  // Helper สร้าง sprite scenery
  Future<void> _buildAndAddScenery(SceneryData sData) async {
    final sprite = await loadSprite(sData.spritePath);
    // 1) สร้าง SpriteComponent ว่าง
    final comp = SpriteComponent()
      ..sprite = sprite
      ..size = Vector2(sData.width, sData.height)
      ..position = Vector2(sData.offsetX, sData.offsetY * size.y)
      ..anchor = Anchor.center
      ..priority = elementPriority;
    // 3) add ลงใน Game
    world.add(comp);
  }

  /// ฟังก์ชันใน HardLineGame
  Vector2 convertScreenToWorld(Offset screenPos) {
    // สมมติไม่มี scale/rotation => แค่บวก position.x, position.y
    // cam.viewfinder.position คือ มุมบนซ้ายของกล้อง
    final Vector2 camPos = cam.viewfinder.position;

    final double wx = screenPos.dx + camPos.x;
    final double wy = screenPos.dy + camPos.y;

    return Vector2(wx, wy);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (isLineComplete) return;
    final worldPos = convertScreenToWorld(
      Offset(event.localPosition.x, event.localPosition.y),
    );

    // event.localPosition เป็น Vector2 ใน Flame => ต้องแปลงเป็น Offset
    final dragPos = Offset(worldPos.x, worldPos.y);

    final levelData = levels[currentLevelIndex];
    final pivotPos = levelData.points[pivotIndex];
    // pivotPos เป็น Offset

    final dist = (dragPos - pivotPos).distance;
    if (dist < 30) {
      // สร้าง LineInWorld แทน (ด้วย Vector2)
      // 1) เราต้องการ startVector2, endVector2
      //final startV2 = Offset(dragPos.dx, dragPos.dy);
      //final endV2 = Offset(dragPos.dx, dragPos.dy);

      final newLine = LineInWorld(
        startPos: pivotPos,
        endPos: pivotPos,
        priority: 3,
      );

      // เสริม: ถ้าต้องการเลเยอร์ z-index (priority)
      //newLine.priority = 999; // หรืออะไรก็ว่าไป

      // เพิ่มลง world แทน add(this)
      world.add(newLine);

      // เก็บลง lists เพื่อใช้งานต่อ
      lines.add(newLine);
    }
  }

  /// ลากต่อ (DragUpdate)
  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (lines.isEmpty || isLineComplete) return;

    final line = lines.last; // line คือ LineInWorld
    // เช็คว่า line ถูกล็อคหรือยัง
    if (!(line.isLocked)) {
      final worldV2 = convertScreenToWorld(
        Offset(event.localStartPosition.x, event.localStartPosition.y),
      );
      // แปลงเป็น Offset
      final dragPos = Offset(worldV2.x, worldV2.y);

      line.setEnd(dragPos);
      // setEnd => ต้องเป็น Vector2
      //final v2 = Vector2(dragPos.dx, dragPos.dy);
    }
  }

  /// ปล่อยนิ้ว => เช็คว่าปลายเส้นอยู่ใกล้ "จุด" ไหม
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (lines.isEmpty) return;

    final line = lines.last; // line => LineInWorld
    if (line.isLocked) return;

    final foundPoint = _findClosestPoint(line.end, threshold: 50);

    // ดึง pivotPos ปัจจุบันมาเทียบ
    final levelData = levels[currentLevelIndex];
    final pivotPos = levelData.points[pivotIndex];

    if (foundPoint != null) {
      // หาก foundPoint == pivotPos => แปลว่าผู้เล่นลากกลับมาที่เดิม
      if (foundPoint == pivotPos) {
        // ไม่ยอมให้ล็อกเส้น => สั่ง pullBack
        line.color = Colors.red;
        add(CustomPullBackEffect(
          line: line,
          from: line.end,
          to: line.start,
          controller: EffectController(duration: 0.5),
        ));
      } else {
        // ถ้าเป็นจุดอื่น => ยอมล็อกเส้น
        line.setEnd(foundPoint);
        updateCurve(0);
        line.isLocked = true;
        isLineComplete = true;
      }
    } else {
      // หากไม่เจอจุดใด ๆ => pullBack
      line.color = Colors.red;
      add(CustomPullBackEffect(
        line: line,
        from: line.end,
        to: line.start,
        controller: EffectController(duration: 0.5),
      ));
    }

    onUpdateUI?.call();
  }

  Offset? _findClosestPoint(Offset pos, {double threshold = 50}) {
    final levelData = levels[currentLevelIndex];
    Offset? best;
    double minDist = double.infinity;

    for (int i = 0; i < levelData.points.length; i++) {
      final px = levelData.points[i];
      final dist = (pos - px).distance;
      if (dist < threshold && dist < minDist) {
        best = px;
        minDist = dist;
      }
    }
    return best;
  }

  /// เมื่อกด Confirm
  void attemptConfirmLine() {
    if (lines.isEmpty) return;
    final line = lines.last;
    if (!line.isLocked) return;

    // เปลี่ยนสี line => เขียว
    line.color = Colors.green;

    // สั่งให้ Player เดินตามเส้น

    add(LineFollowEffect(
      player: player,
      line: line,
      controller: EffectController(duration: 1.5, curve: Curves.easeInOut),
      onFinishCallback: () async {
        if (isGameOver) return; // 🛑 หยุดโหลดด่านถ้าเกมโอเวอร์
        // onFinish => หา index ของ line.end
        final playerPos = Offset(player.position.x, player.position.y);
        final idx = _whichPoint(playerPos);
        if (idx != null) {
          pivotIndex = idx;
          // pivot เป็นจุดที่เพิ่งเดินถึง (แต่หยุด 30 px ก่อนจริง)
          // ถ้า idx == points.length-1 => p3 => ชนะ
          final levelData = levels[currentLevelIndex];

          // 🏆 **เช็คว่าถึงจุดสุดท้ายของด่านสุดท้ายหรือยัง**
          final isLastLevel = currentLevelIndex == levels.length - 1;
          final isLastPoint = idx == levelData.points.length - 1;

          if (isLastLevel && isLastPoint) {
            onChapterEnd?.call(true);
            return;
          } else if (isLastPoint) {
            // เพิ่มตัว ScreenFadeTransition เต็มจอเข้าไป
            add(
              ScreenFadeTransition(
                size: Vector2(size.x, size.y),
                onFadeInComplete: () {
                  // ตรงนี้คือหลังจอดำ fade เข้ามาสุด (opacity=1)
                  // => โหลดด่านใหม่ได้
                  _loadLevel(currentLevelIndex + 1);
                },
                onFadeOutComplete: () {
                  // หลัง fade กลับ (opacity=1 -> 0)
                  // => จบการ transition พร้อมเล่นด่านใหม่
                },
              ),
            );
          }
        }
        fadeOutLine(line);
      },
    ));
    isLineComplete = false;
    onUpdateUI?.call();
  }

  void fadeOutLine(LineInWorld line) {
    final effectController =
        EffectController(duration: 0.5, curve: Curves.linear);
    final effect = LineRemoveEffect(
      line: line,
      originalColor: line.color, // เก็บสีเส้นปัจจุบัน
      controller: effectController,
    );
    add(effect);
  }

  /// ตรวจว่า line.end ตรงกับ points[index] อันไหน
  int? _whichPoint(Offset end, {double tolerance = 80.0}) {
    final levelData = levels[currentLevelIndex];

    for (int i = 0; i < levelData.points.length; i++) {
      final p = levelData.points[i];
      if ((p - end).distance < tolerance) {
        return i;
      }
    }
    return null;
  }

  void updateCurve(double val) {
    currentSliderValue = val;
    if (lines.isNotEmpty) {
      final line = lines.last;
      final offsetMap = {
        -5: -480.0,
        -4: -300.0,
        -3: -180.0,
        -2: -120.0,
        -1: -60.0,
        0: 0.0,
        1: 60.0,
        2: 120.0,
        3: 180.0,
        4: 300.0,
        5: 480.0,
      };
      line.controlOffset = offsetMap[val.toInt()] ?? 0.0;
      line.calculateHandler();
    }
    onUpdateUI?.call();
  }

  /// รีเซ็ตเกม
  void onResetLevel() {
    // 1) ลบเส้น (LineInWorld) ที่ยังค้างอยู่
    for (final l in lines) {
      l.removeFromParent(); // ถ้า lines แต่ละตัวถูก add(world) แล้ว
    }
    lines.clear();
    isLineComplete = false;
    currentSliderValue = 0;

    star?.removeFromParent();
    star = null;

    // 3) *** ลบ "จุด" (PointGoalComponent) เดิมทั้งหมด ***
    //    สมมติเราสร้างจุดเป็น PointGoalComponent ที่สืบทอดจาก PositionComponent
    world.removeAll(
      world.children.whereType<PointGoalComponent>().toList(),
    );

    // 3) ลบ spriteComponents อื่น ๆ (scenery) ใน world
    //    (ยกเว้น player ที่เรายังใช้อยู่)
    world.removeAll(
      world.children
          .where((c) =>
              c is SpriteComponent &&
              c.priority == elementPriority && // ถ้ากำหนดว่า scenery priority=0
              c.priority == obstraclePriority &&
              c != player)
          .toList(),
    );

    // 4) รีเซ็ตตัวแปรสถานะเกม
    isGameOver = false;
    currentLevelIndex = currentLevelIndex; // เริ่มใหม่ที่ด่านแรก
    pivotIndex = 0;
    hp = hp;

    starsPerLevel[currentLevelIndex] = 0;
    stars = starsPerLevel.values.fold(0, (sum, value) => sum + value);

    // 5) โหลดด่านแรกใหม่
    _loadLevel(currentLevelIndex);

    cam.stop();

    // 2) รีเซ็ตตำแหน่งกล้องเป็น (0,0) หรือจุดใดที่ต้องการ
    cam.viewfinder.position = Vector2.zero();

    // 6) แจ้ง UI หรือ State ภายนอกถ้าจำเป็น
    onUpdateUI?.call();
  }

  /// รีเซ็ตเกม
  void resetGame() {
    // 1) ลบเส้น (LineInWorld) ที่ยังค้างอยู่
    for (final l in lines) {
      l.removeFromParent(); // ถ้า lines แต่ละตัวถูก add(world) แล้ว
    }
    lines.clear();
    isLineComplete = false;
    currentSliderValue = 0;

    world.removeAll(world.children.whereType<ObstacleComponent>().toList());
    obstacle = null;

    world.removeAll(
        world.children.whereType<RectangleObstacleComponent>().toList());
    rectangle = null;

    world.removeAll(
        world.children.whereType<CircleObstacleComponent>().toList());
    circle = null;

    world.removeAll(
        world.children.whereType<MovingObstacleComponent>().toList());
    movingObs = null;

    world.removeAll(world.children.whereType<StarComponent>().toList());
    star = null;

    world.removeAll(
      world.children.whereType<PointGoalComponent>().toList(),
    );

    // 3) ลบ spriteComponents อื่น ๆ (scenery) ใน world
    //    (ยกเว้น player ที่เรายังใช้อยู่)
    world.removeAll(
      world.children
          .where((c) =>
              c is SpriteComponent &&
              c.priority == elementPriority && // ถ้ากำหนดว่า scenery priority=0
              c.priority == obstraclePriority &&
              c != player)
          .toList(),
    );
    cam.stop();
    cam.viewfinder.position = Vector2.zero();
    cam.update(0);

    // 4) รีเซ็ตตัวแปรสถานะเกม
    isGameOver = false;
    currentLevelIndex = 0; // เริ่มใหม่ที่ด่านแรก
    pivotIndex = 0;
    hp = 3;
    stars = 0;

    // 5) โหลดด่านแรกใหม่
    _loadLevel(0);

    // 2) รีเซ็ตตำแหน่งกล้องเป็น (0,0) หรือจุดใดที่ต้องการ

    // 6) แจ้ง UI หรือ State ภายนอกถ้าจำเป็น
    onUpdateUI?.call();
  }

  /// หากโดน obstacle => hp--
  /// ถ้า hp<=0 => onChapterEnd(false)
  void minusHP(int amt) {
    hp -= amt;
    if (hp <= 0) {
      isGameOver = true;
      onChapterEnd?.call(false);
    }
    onUpdateUI?.call();
  }

  /// เก็บ star => stars++
  void plusStar(int amt) {
    final currentStars = starsPerLevel[currentLevelIndex] ?? 0;
    starsPerLevel[currentLevelIndex] = currentStars + amt;

    // ✅ คำนวณดาวรวมจากทุกด่าน
    stars = starsPerLevel.values.fold(0, (sum, value) => sum + value);

    onUpdateUI?.call();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawColor(Colors.white, BlendMode.srcOver); // พื้นหลังขาว
    super.render(canvas);
  }
}
