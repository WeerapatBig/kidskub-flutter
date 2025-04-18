import 'dart:math';
import 'package:flutter/material.dart';

import 'stroke_text.dart';

class ComboPopup extends StatefulWidget {
  final int comboCount;

  const ComboPopup({
    Key? key,
    required this.comboCount,
  }) : super(key: key);

  @override
  State<ComboPopup> createState() => _ComboPopupState();
}

class _ComboPopupState extends State<ComboPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final double _rotationAngle;

  @override
  void initState() {
    super.initState();

    // สุ่มเอียง: -30°, 0°, 30°
    final angles = [-10.0, 0.0, 10.0];
    _rotationAngle = angles[Random().nextInt(angles.length)] * pi / 180;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.1, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward(); // เริ่มแอนิเมชัน
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAngle,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: StrokeText(
          text: "${widget.comboCount} คอมโบ",
          color: const Color.fromRGBO(255, 170, 46, 100).withOpacity(1),
          fontSize: 50,
          strokeWidth: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
