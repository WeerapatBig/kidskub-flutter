import 'package:flame/components.dart';
import 'package:flame/game.dart';
import '../component_color_quiz/color_wheel_anchor.dart';
import '../component_color_quiz/color_wheel_component.dart';

class GameColorQuizIntro extends FlameGame {
  final List<String> imagePaths = [
    'colorgame/quiz_color/colors_wheel/empty_color_1.png',
    'colorgame/quiz_color/colors_wheel/empty_color_2.png',
    'colorgame/quiz_color/colors_wheel/empty_color_3.png',
    'colorgame/quiz_color/colors_wheel/primary_red_color.png',
    'colorgame/quiz_color/colors_wheel/primary_yellow_color.png',
    'colorgame/quiz_color/colors_wheel/primary_blue_color.png',
  ];

  @override
  Future<void> onLoad() async {
    final bg = SpriteComponent()
      ..sprite = await loadSprite('linegamelist/line_quiz/paper_bg.png')
      ..size = size // ขยายเต็มจอ
      ..position = Vector2.zero()
      ..priority = -1; // วางไว้หลังสุด

    await add(bg);

    final center = size / 2;
    final anchor = ColorWheelAnchorComponent(center: center);
    await add(anchor);

    // วางเฉพาะสีแดงไว้ด้านบน (0 องศา)
    final redSegment = ColorWheelComponent(
      imagePath: 'colorgame/quiz_color/colors_wheel/primary_red_color.png',
      position: Vector2(0, -230), // ขึ้นด้านบนจากจุดศูนย์กลาง
      angleRad: 0, // ไม่หมุน
      scaleFactor: 0.25,
    );

    // วางช่องว่างด้านซ้ายของสีแดง (ประมาณ 60 องศา)
    final empty1Segment = ColorWheelComponent(
      imagePath: 'colorgame/quiz_color/colors_wheel/empty_color_1.png',
      position: Vector2(-130, -150), // x = -r*cos(60°), y = -r*sin(60°)
      angleRad: 0, // -60° ใน radian
      scaleFactor: 0.25,
    );
    final blueSegment = ColorWheelComponent(
      imagePath: 'colorgame/quiz_color/colors_wheel/primary_blue_color.png',
      position: Vector2(-135, 85),
      angleRad: -2.0944, // -120° ใน radian
      scaleFactor: 0.18,
    );
    final empty2Segment = ColorWheelComponent(
      imagePath: 'colorgame/quiz_color/colors_wheel/empty_color_2.png',
      position: Vector2(0, 180),
      angleRad: 0, // 180°
      scaleFactor: 0.25,
    );
    final yellowSegment = ColorWheelComponent(
      imagePath: 'colorgame/quiz_color/colors_wheel/primary_yellow_color.png',
      position: Vector2(135, 85),
      angleRad: 2.0944, // 180°
      scaleFactor: 0.18,
    );
    final empty3Segment = ColorWheelComponent(
      imagePath: 'colorgame/quiz_color/colors_wheel/empty_color_3.png',
      position: Vector2(130, -110),
      angleRad: 0, // 180°
      scaleFactor: 0.25,
    );

    anchor.addAll([
      redSegment,
      empty1Segment,
      blueSegment,
      empty2Segment,
      yellowSegment,
      empty3Segment,
    ]); // วางใน anchor (จะอิง center โดยอัตโนมัติ)
  }
}
