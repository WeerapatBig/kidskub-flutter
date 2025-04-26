import 'package:flutter/material.dart';

class HorizontalProgressBar extends StatelessWidget {
  final double width;
  final double height;
  final double progress;
  final Color backgroundColor;
  final Color fillColor;
  final double borderRadius;

  const HorizontalProgressBar({
    super.key,
    required this.progress,
    this.width = 250,
    this.height = 15,
    this.backgroundColor = const Color.fromARGB(255, 237, 237, 237),
    this.fillColor = Colors.red,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // พื้นหลัง (โค้ง)
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
              ),
            ),
          ),

          // หลอดสี (วางซ้อน ไม่ถูกตัดซ้ำ)
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: ClipRRect(
                // ให้โค้งเท่ากัน
                borderRadius: BorderRadius.circular(borderRadius),
                child: Container(
                  decoration: BoxDecoration(
                    color: fillColor,
                    border: Border.all(color: Colors.black, width: 3),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
