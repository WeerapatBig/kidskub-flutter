import 'package:flutter/material.dart';

import 'time_alert_anim.dart';

class TimeProgreesBarWidget extends StatefulWidget {
  final ValueNotifier<int> remainingTime; // เวลาที่เหลือ
  final int maxTime; // เวลาสูงสุด
  final ValueNotifier<bool> isAlertNotifier;

  const TimeProgreesBarWidget({
    Key? key,
    required this.remainingTime,
    required this.maxTime,
    required this.isAlertNotifier,
  }) : super(key: key);

  @override
  State<TimeProgreesBarWidget> createState() => _TimeProgreesBarWidgetState();
}

class _TimeProgreesBarWidgetState extends State<TimeProgreesBarWidget> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return ValueListenableBuilder<bool>(
      valueListenable: widget.isAlertNotifier,
      builder: (_, isAlert, __) {
        return ValueListenableBuilder<int>(
          valueListenable: widget.remainingTime,
          builder: (_, time, __) {
            double progress =
                time / widget.maxTime; // คำนวณเปอร์เซ็นต์ Progress
            double barHeight = screenSize.height; // ความสูงของ ProgressBar
            double barWidth = screenSize.width; // ความกว้างของ ProgressBar

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
                      Positioned(
                        top: barHeight * 0.122, // ตำแหน่งด้านบน
                        right: barWidth * 0.015, // ตำแหน่งด้านขวา
                        height: barHeight * 0.03,
                        width: barWidth * 0.6,
                        child: Stack(
                          children: [
                            // ✅ พื้นหลังสีเข้ม
                            Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(
                                    255, 33, 33, 33), // สีพื้นหลัง
                                border: Border.all(
                                  color: Colors.black,
                                  width: 5,
                                ),
                                borderRadius:
                                    BorderRadius.circular(barHeight * 0.5),
                              ),
                            ),
                            FractionallySizedBox(
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
                                  borderRadius:
                                      BorderRadius.circular(barHeight * 0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                          top: barHeight * 0.075,
                          left: barWidth * 0.22,
                          child: Container(
                            width: barWidth * 0.01,
                            height: barHeight * 0.12,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                  255, 242, 242, 242), // สีพื้นหลัง
                              border: Border.all(
                                color: const Color.fromARGB(255, 33, 33, 33),
                                width: 3.5,
                              ),
                              borderRadius:
                                  BorderRadius.circular(barHeight * 0.5),
                            ),
                          )),
                    ],
                  ),
                ),

                // 👈 รูปเตือนฝั่งซ้าย (เยื้องซ้ายบน)
                if (isAlert) const TimeAlertImage(),
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
      },
    );
  }
}
