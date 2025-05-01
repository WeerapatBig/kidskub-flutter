import 'package:flutter/material.dart';

class DraggableShape extends StatelessWidget {
  final String type;
  final String imagePath;
  final double left;
  final double bottom;
  final double size;

  const DraggableShape({
    super.key,
    required this.type,
    required this.imagePath,
    required this.left,
    required this.bottom,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      bottom: bottom,
      child: Draggable<String>(
        data: type,
        feedback: Image.asset(imagePath, width: size),
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: Padding(
            padding: const EdgeInsets.all(2), // 👈 hitbox ตอนลาก
            child: Image.asset(imagePath, width: size),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20), // 👈 hitbox ตอนอยู่ปกติ
          child: Image.asset(imagePath, width: size),
        ),
      ),
    );
  }
}
