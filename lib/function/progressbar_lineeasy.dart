import 'package:flutter/material.dart';

class ProgressBarLineEasyWidget extends StatelessWidget {
  final ValueNotifier<int> remainingTime; // เวลาที่เหลือ
  final int maxTime; // เวลาสูงสุด
  final int starCount; // จำนวนดาว (สามารถคำนวณได้)

  ProgressBarLineEasyWidget({
    Key? key,
    required this.remainingTime,
    required this.maxTime,
    this.starCount = 3, // ค่าเริ่มต้นเป็น 3 ดาว
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return ValueListenableBuilder<int>(
      valueListenable: remainingTime,
      builder: (_, time, __) {
        double progress = time / maxTime; // คำนวณเปอร์เซ็นต์ Progress
        double barHeight = screenSize.height; // ความสูงของ ProgressBar
        double barWidth = screenSize.width; // ความกว้างของ ProgressBar
        List<double> starPositions = [
          0.115,
          0.3,
          0.5,
        ]; // ตำแหน่งดาวแบบเปอร์เซ็นต์

        return Stack(
          children: [
            // --- พื้นหลัง ---
            Positioned(
              left: barWidth * 0.08, // ตำแหน่งด้านซ้าย
              bottom: barHeight * 0.05, // ตำแหน่งด้านบน
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: barHeight * 0.24, // เว้นระยะด้านซ้าย
                    width: barHeight * 1.18, // จัดให้อยู่ตรงกลาง
                    child: Image.asset(
                      'assets/images/linegamelist/time_bar.png', // รูปนาฬิกา
                      width: barHeight * 0.8, // ขนาดของไอคอน
                      height: barHeight * 0.8,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // --- แถบ Progress สีแดง ---
                  Positioned(
                    top: barHeight * 0.122, // ตำแหน่งด้านบน
                    right: barWidth * 0.015, // ตำแหน่งด้านขวา
                    height: barHeight * 0.03,
                    width: barWidth * 0.6,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress, // ใช้ progress
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black, // สีขอบของ ProgressBar
                            width: 5,
                          ),
                          shape: BoxShape.rectangle,
                          color: Colors.red, // สีแดงของ ProgressBar
                          borderRadius: BorderRadius.circular(barHeight * 0.5),
                        ),
                      ),
                    ),
                  ),
                  // --- รูปดาว ---
                  ...starPositions.map((position) {
                    int starIndex = starPositions.indexOf(position);
                    return Positioned(
                      left: (barWidth * 0.9) *
                          position, // คำนวณตำแหน่งตามเปอร์เซ็นต์
                      bottom: barHeight * 0.085, // เลื่อนขึ้นเล็กน้อย
                      child: Image.asset(
                        starIndex < starCount
                            ? 'assets/images/linegamelist/star_full.png' // รูปดาวเต็ม
                            : 'assets/images/linegamelist/star_empty.png', // รูปดาวว่าง
                        width: barHeight * 0.04, // ขนาดของดาว
                        height: barHeight * 0.04,
                        fit: BoxFit.contain,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            // --- Icon นาฬิกา ---
            Positioned(
              bottom: barHeight * 0.083, // ตำแหน่งด้านบน
              left: barWidth * 0.08, // ตำแหน่งด้านบน
              child: SizedBox(
                height: barHeight * 0.18, // เว้นระยะด้านซ้าย
                width: barHeight * 0.18, // จัดให้อยู่ตรงกลาง
                child: Image.asset(
                  'assets/images/linegamelist/clock.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
