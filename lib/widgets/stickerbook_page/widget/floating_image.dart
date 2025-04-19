import 'dart:math';
import 'package:flutter/material.dart';

class FloatingImage extends StatefulWidget {
  final String imagePath;
  final double width;
  final double height;

  const FloatingImage({
    Key? key,
    required this.imagePath,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  _FloatingImageState createState() => _FloatingImageState();
}

class _FloatingImageState extends State<FloatingImage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double _startX, _startY, _dx, _dy;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 50 + _random.nextInt(10)),
      vsync: this,
    )..repeat();

    _startX = _random.nextDouble() * 2 * pi;
    _startY = _random.nextDouble() * 2 * pi;
    _dx = (_random.nextDouble() - 0.5) * 2 * pi;
    _dy = (_random.nextDouble() - 0.5) * 2 * pi;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double t = _controller.value * 5 * pi;
        double x = 0.5 + 0.5 * sin(t * _dx + _startX);
        double y = 0.5 + 0.5 * cos(t * _dy + _startY);
        double posX = x * (screenSize.width - widget.width);
        double posY = y * (screenSize.height - widget.height);
        return Positioned(
          left: posX,
          top: posY,
          child: SizedBox(width: widget.width, height: widget.height, child: child!),
        );
      },
      child: Image.asset(widget.imagePath),
    );
  }
}
