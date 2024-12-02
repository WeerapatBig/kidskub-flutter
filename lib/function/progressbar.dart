import 'package:flutter/material.dart';

class ProgressBarWidget extends StatelessWidget {
  final int getStars; // ค่าปัจจุบันของ progress (0-3)
  final Color progressColor; // สีของ progress
  final Color progressStrokeColor; // สีของ progress
  final Color backgroundColor; // สีพื้นหลังของ progress bar
  final Alignment alignment; // การจัดตำแหน่ง ProgressBar
  final EdgeInsets padding; // ระยะห่างรอบ ProgressBar
  final List<double> starPositions; // ตำแหน่งของดาวในแนวนอน

  const ProgressBarWidget({
    Key? key,
    required this.getStars,
    this.progressColor = const Color.fromARGB(255, 255, 170, 46),
    this.progressStrokeColor = const Color.fromARGB(255, 0, 0, 0),
    this.backgroundColor = Colors.grey,
    this.alignment = Alignment.center, // Default: อยู่ตรงกลาง
    this.padding = EdgeInsets.zero, // Default: ไม่มีระยะห่าง
    required this.starPositions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // อัตราความกว้างของ progress bar
    final double progressFraction = (getStars / 3).clamp(0.0, 1.0);
    double barHeight = MediaQuery.of(context).size.height;
    double barWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: padding,
      child: Align(
        alignment: alignment,
        child: Stack(
          clipBehavior: Clip.none,
          //alignment: Alignment.center,
          children: [
            Container(
              height: barHeight * 0.052,
              width: barWidth * 0.75,
              decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(barHeight / 2),
                  border: Border.all(
                    color: Colors.black,
                    width: 5.0,
                  )),
            ),
            // Progress Indicator
            FractionallySizedBox(
              widthFactor: progressFraction,
              child: Container(
                height: barHeight * 0.038,
                width: barWidth * 0.75,
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(barHeight / 2),
                ),
              ),
            ),
            // รูปภาพดาวแสดงสถานะ
            ...List.generate(starPositions.length, (index) {
              return _buildStarImage(
                context: context,
                customLeftPosition: starPositions[index],
                isFull: getStars > index,
              );
            }),
          ],
        ),
      ),
    );
  }

// ฟังก์ชันช่วยสร้าง Widget รูปภาพ
  Widget _buildStarImage({
    required BuildContext context,
    required double customLeftPosition,
    required bool isFull,
  }) {
    final double imageSize = MediaQuery.of(context).size.height * 0.1;

    return Positioned(
      left: customLeftPosition,
      top: MediaQuery.of(context).size.height * -0.035, // ค่าความสูงของรูปภาพ
      child: Image.asset(
        isFull ? 'assets/images/starfull.png' : 'assets/images/starempty.png',
        width: imageSize,
        height: imageSize,
        fit: BoxFit.contain,
      ),
    );
  }
}
