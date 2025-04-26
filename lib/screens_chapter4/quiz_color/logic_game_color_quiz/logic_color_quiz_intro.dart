import 'package:flame/components.dart';
import 'package:flame/game.dart';
import '../component_color_quiz/color_wheel_anchor.dart';
import '../component_color_quiz/color_wheel_segment_group.dart';

class GameColorQuizIntro extends FlameGame with HasCollisionDetection {
  final Set<String> completedColors = {};

  void Function()? onCompleteLevel; // ✅ Callback แจ้งจบ

  void Function()? onFirstRedDone; // ✅ Callback ไปยัง Screen

  void reset() async {
    // 1. ลบ Components ที่ไม่ใช่ Background
    final componentsToRemove =
        children.where((c) => c is! SpriteComponent).toList();
    for (final c in componentsToRemove) {
      c.removeFromParent();
    }

    // 2. เคลียร์ completedColors
    completedColors.clear();

    // 3. สร้าง ColorWheel ใหม่อีกครั้ง
    final center = size / 2;
    final anchor = ColorWheelAnchorComponent(center: center);
    await add(anchor);

    final segments = await loadColorWheelSegments(center);
    anchor.addAll(segments);
  }

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

    final segments = await loadColorWheelSegments(center);
    anchor.addAll(segments);
  }
}
