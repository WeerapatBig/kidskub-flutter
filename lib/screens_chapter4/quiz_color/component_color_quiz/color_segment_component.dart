// lib/component_color_quiz/color_segment_component.dart
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'color_blob_component.dart';

class ColorSegmentComponent extends SpriteComponent
    with DragCallbacks, HasGameReference {
  final String colorType;
  final double angleRad;
  final double scaleFactor;

  bool hasBlob = false;

  ColorSegmentComponent({
    required this.colorType,
    required Vector2 position,
    required this.angleRad,
    this.scaleFactor = 0.35,
  }) : super(
          position: position,
          anchor: Anchor.center,
          angle: angleRad,
        );

  @override
  Future<void> onLoad() async {
    final path = 'colorgame/quiz_color/colors_wheel/${colorType}_color.png';
    sprite = await Sprite.load(path);

    final imgSize = sprite!.srcSize;
    size = Vector2(imgSize.x * scaleFactor, imgSize.y * scaleFactor);

    add(RectangleHitbox()); // สำหรับให้ tap ได้
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);

    if (hasBlob) return;
    final blob = ColorBlobComponent(
      colorType: colorType,
      position: event.canvasPosition,
      onBlobRemoved: () => hasBlob = false, // ✅ callback ตอน blob ถูกลบ
    );

    hasBlob = true;
    game.add(blob); // ใช้ game จาก HasGameReference
  }
}
