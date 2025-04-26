import 'package:flame/components.dart';
import 'color_segment_component.dart';
import 'color_wheel_component.dart';

Future<List<Component>> loadColorWheelSegments(Vector2 center) async {
  return [
    // 🔴 แม่สีแดง (tap ได้)
    ColorSegmentComponent(
      colorType: 'red',
      position: Vector2(0, -200),
      angleRad: 0,
      scaleFactor: 0.215,
    ),
    ColorWheelComponent(
      imagePath: 'colorgame/quiz_color/colors_wheel/empty_color_1.png',
      position: Vector2(-168, -102.5),
      angleRad: -1.0844,
      scaleFactor: 0.22,
      acceptedMixColors: ['red', 'blue'], // ✅ รองรับแค่แดง + น้ำเงิน
      mixedColorResult: 'purple',
    ),
    ColorSegmentComponent(
      position: Vector2(-165, 90),
      angleRad: -2.0844,
      scaleFactor: 0.215,
      colorType: 'blue',
    ),
    ColorWheelComponent(
      imagePath: 'colorgame/quiz_color/colors_wheel/empty_color_2.png',
      position: Vector2(2.5, 180),
      angleRad: -3.14,
      scaleFactor: 0.22,
      acceptedMixColors: ['yellow', 'blue'], // ✅ รองรับแค่เหลือง + น้ำเงิน
      mixedColorResult: 'green',
    ),
    ColorSegmentComponent(
      position: Vector2(165, 90),
      angleRad: 2.0944,
      scaleFactor: 0.215,
      colorType: 'yellow',
    ),
    ColorWheelComponent(
      imagePath: 'colorgame/quiz_color/colors_wheel/empty_color_3.png',
      position: Vector2(165, -102.5),
      angleRad: 1.0844,
      scaleFactor: 0.215,
      acceptedMixColors: ['red', 'yellow'], // ✅ รองรับแค่แดง + เหลือง
      mixedColorResult: 'orange',
    ),
  ];
}
