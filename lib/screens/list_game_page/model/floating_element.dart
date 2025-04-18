import 'dart:math';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class FloatingImage extends StatefulWidget {
  final String imagePath;
  final double width;
  final double height;

  const FloatingImage({
    required this.imagePath,
    required this.width,
    required this.height,
  });

  @override
  _FloatingImageState createState() => _FloatingImageState();
}

class _FloatingImageState extends State<FloatingImage>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late double _startX;
  late double _startY;
  late double _dx;
  late double _dy;
  late double _elapsedTime;
  late Random _random;

  @override
  void initState() {
    super.initState();
    _random = Random();

    _elapsedTime = 0;
    _startX = _random.nextDouble() * 2 * pi;
    _startY = _random.nextDouble() * 2 * pi;
    _dx = (_random.nextDouble() - 0.5) * 2;
    _dy = (_random.nextDouble() - 0.5) * 2;

    // ใช้ Ticker แทน AnimationController เพื่อให้ทำงานต่อเนื่องจริงๆ
    _ticker = createTicker((elapsed) {
      setState(() {
        _elapsedTime = elapsed.inMilliseconds / 1000;
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    double x = 0.5 + 0.5 * sin(_elapsedTime * _dx + _startX);
    double y = 0.5 + 0.5 * cos(_elapsedTime * _dy + _startY);

    double posX = x * (screenSize.width - widget.width);
    double posY = y * (screenSize.height - widget.height);

    return Positioned(
      left: posX,
      top: posY,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Image.asset(widget.imagePath),
      ),
    );
  }
}
