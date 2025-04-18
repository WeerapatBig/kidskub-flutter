import 'package:flame/components.dart';

class ColorWheelComponent extends SpriteComponent {
  ColorWheelComponent({
    required String imagePath,
    required Vector2 position,
    required double angleRad,
    double scaleFactor = 0.35,
  }) : super(
          position: position,
          angle: angleRad,
          anchor: Anchor.center,
        ) {
    _imagePath = imagePath;
    _scaleFactor = scaleFactor;
  }

  late final String _imagePath;
  late final double _scaleFactor;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(_imagePath);

    final imgSize = sprite!.srcSize;
    size = Vector2(imgSize.x * _scaleFactor, imgSize.y * _scaleFactor);
  }
}
