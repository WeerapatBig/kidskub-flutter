import 'package:flutter/material.dart';

import '../components/star_ui_animated.dart';

class ProgressStarBar extends StatelessWidget {
  final double progress; // 0.0 ถึง 1.0
  final int starCount; // ดาวที่ได้รับตอนนี้ (0-3)

  const ProgressStarBar({
    Key? key,
    required this.progress,
    required this.starCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double barHeight = MediaQuery.of(context).size.height;
    double barWidth = MediaQuery.of(context).size.width;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. พื้นหลังสีส้ม
        Positioned(
          top: barHeight * 0.11,
          left: barWidth * 0.227,
          child: SizedBox(
            height: barHeight * 0.04,
            width: barWidth * 0.5,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 33, 33, 33),
                    borderRadius: BorderRadius.circular(barHeight / 2),
                    border: Border.all(color: Colors.black, width: 6),
                  ),
                ),
                if (progress > 0.05)
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 170, 46),
                        borderRadius: BorderRadius.circular(barHeight / 2),
                        border: Border.all(color: Colors.black, width: 6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // 3. ดาว 3 ดวง (กลางซ้าย กลาง ขวา)
        Positioned(
          top: barHeight * 0.03,
          left: barWidth * 0.33,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 70),
                    child: AnimatedStar(
                      isFilled: index < starCount,
                      filledAsset:
                          'assets/images/colorgame/color_game_star_full.png',
                      emptyAsset:
                          'assets/images/colorgame/color_game_star_empty.png',
                    ),
                  );
                }),
              ),

              const SizedBox(height: 8), // ระยะห่างระหว่างดาวกับขีด

              // แถวที่ 2: ขีดแบ่งช่วง
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 85),
                    child: Container(
                      width: barWidth * 0.01,
                      height: barHeight * 0.07,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 242, 242, 242),
                        border: Border.all(
                          color: const Color.fromARGB(255, 33, 33, 33),
                          width: 3.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
