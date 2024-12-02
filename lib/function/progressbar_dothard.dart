import 'package:flutter/material.dart';

class ProgressBarDotHardWidget extends StatelessWidget {
  final int remainingTime; // เวลาที่เหลือในวินาที
  final Color progressColor; // สีของ progress
  final Color backgroundColor; // สีพื้นหลังของ progress bar
  final List<double> starPositions;
  final VoidCallback onMissedPoint; // ฟังก์ชันเมื่อผู้เล่นพลาด

  const ProgressBarDotHardWidget({
    Key? key,
    required this.remainingTime,
    required this.onMissedPoint,
    this.progressColor = const Color.fromARGB(255, 252, 102, 91),
    this.backgroundColor = Colors.white,
    this.starPositions = const [270.0, 420.0, 570.0],
    required int getStars,
  }) : super(key: key);

  // ฟังก์ชันคำนวณจำนวนดาว
  int calculateStars() {
    if (remainingTime >= 115) {
      return 3;
    } else if (remainingTime >= 70) {
      return 2;
    } else if (remainingTime >= 25) {
      return 1;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int getStars = calculateStars(); // คำนวณจำนวนดาว
    final double barHeight = MediaQuery.of(context).size.height;
    final double barWidth = MediaQuery.of(context).size.width;
    final double maxBarWidth = barWidth * 0.295;
    final double progressFraction = (remainingTime / 180) * maxBarWidth;

    return Padding(
        padding: EdgeInsets.zero,
        child: Align(
          alignment: Alignment.center,
          child: Stack(
              //clipBehavior: Clip.none,
              children: [
                // Progress Bar
                Container(
                  height: barHeight * 0.22,
                  width: barWidth * 0.45,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            'assets/images/dotgamehard/bgprocress.png')),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(139, 65, 0, 0),
                        height: barHeight * 0.08,
                        width: maxBarWidth,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              width: 5,
                              color: const Color.fromARGB(255, 35, 35, 35)),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(
                                barHeight * 0.8), // โค้งมนเฉพาะมุมบนขวา
                            bottomRight: Radius.circular(
                                barHeight * 0.8), // โค้งมนเฉพาะมุมล่างขวา
                          ),
                        ),
                      ),
                      // สีของ Progress
                      // Progress สีของหลอด
                      Positioned(
                        left: 142, // ตำแหน่ง x ของหลอดสี
                        top: 69, // ตำแหน่ง y ของหลอดสี
                        child: Container(
                          height: barHeight * 0.068,
                          width: progressFraction.clamp(
                              0.0,
                              maxBarWidth -
                                  6), // จำกัดความกว้างไม่เกิน maxBarWidth
                          decoration: BoxDecoration(
                            color: progressColor,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(
                                  barHeight * 0.8), // โค้งมนเฉพาะมุมบนขวา
                              bottomRight: Radius.circular(
                                  barHeight * 0.8), // โค้งมนเฉพาะมุมล่างขวา
                            ),
                          ),
                        ),
                      ),
                      // รูปดาว
                      ...starPositions.map((position) {
                        int starIndex = starPositions.indexOf(position);
                        return Positioned(
                          left: position * 0.6,
                          top: barHeight * 0.1,
                          child: Image.asset(
                            getStars > starIndex
                                ? 'assets/images/starfull.png'
                                : 'assets/images/starempty.png',
                            width: barHeight * 0.055,
                            height: barHeight * 0.055,
                            fit: BoxFit.contain,
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                // ตัวนับเวลา
                Positioned(
                  bottom: barHeight * 0.025,
                  left: barWidth * 0.03,
                  child: Stack(clipBehavior: Clip.none, children: [
                    // เพิ่ม Image asset
                    SizedBox(
                      width: barHeight * 0.168, // กำหนดความกว้าง
                      height: barHeight * 0.168, // กำหนดความสูง
                      child: Image.asset(
                        'assets/images/dotgamehard/clock.png', // Path ของรูปภาพ

                        fit: BoxFit.contain, // ป้องกันการถูกตัด
                      ),
                    ),

                    // ตัวเลขเวลาที่เหลือ
                    Positioned(
                      top: barHeight * 0.0005,
                      left: barWidth * -0.008,
                      child: SizedBox(
                        width: barHeight * 0.2, // กำหนดความกว้างของตัวเลข
                        height: barHeight * 0.2, // กำหนดความสูงของตัวเลข
                        child: Stack(
                          alignment: Alignment.center, // จัดตัวเลขไว้ตรงกลาง
                          children: [
                            Text(
                              remainingTime > 0
                                  ? remainingTime.toString()
                                  : '0',
                              style: TextStyle(
                                fontSize: barWidth * 0.03, // กำหนดขนาดตัวเลข
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ]),
        ));
  }
}
