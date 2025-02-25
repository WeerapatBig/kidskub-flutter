import 'package:firstly/screens/strickerbook.dart';
import 'package:flutter/material.dart';

class ShowStickerPage extends StatefulWidget {
  final String stickerKey; // พารามิเตอร์สำหรับรูปภาพ
  const ShowStickerPage({
    Key? key,
    required this.stickerKey,
  }) : super(key: key);

  @override
  State<ShowStickerPage> createState() => _ShowStickerPageState();
}

class _ShowStickerPageState extends State<ShowStickerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // ตั้งค่า AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // ระยะเวลาของอนิเมชัน 1 รอบ
    );

    // สร้าง Tween สำหรับหมุนไปมาระหว่าง -5 องศา ถึง 5 องศา
    _rotationAnimation =
        Tween<double>(begin: -0.06, end: 0.06).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    // ทำให้การหมุนวนลูปไปมา
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ฟังก์ชันสำหรับแสดงวิดเจ็ตที่มีอนิเมชัน
  Widget buildRotatingSticker(
      String selectedImage, double screenWidth, double screenHeight) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value, // ใช้มุมจากอนิเมชัน
          child: Container(
            width: screenWidth * 0.4,
            height: screenHeight * 0.5,
            decoration: BoxDecoration(
              //shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(selectedImage), // Path ของสติ๊กเกอร์
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    // ลิสต์รูปภาพทั้งหมด
    final Map<String, String> stickerImages = {
      'sticker1': 'assets/images/strickerbook/sticker1.png',
      'sticker2': 'assets/images/strickerbook/sticker2.png',
      'sticker3': 'assets/images/strickerbook/sticker3.png',
      'sticker4': 'assets/images/strickerbook/sticker4.png', // รูปภาพเริ่มต้น
      'sticker5': 'assets/images/strickerbook/sticker5.png', // รูปภาพเริ่มต้น
      'sticker6': 'assets/images/strickerbook/sticker6.png', // รูปภาพเริ่มต้น
      'default': 'assets/images/strickerbook/sticker5.png', // รูปภาพเริ่มต้น
    };

    // เลือกรูปภาพตามพารามิเตอร์
    final String selectedImage =
        stickerImages[widget.stickerKey] ?? stickerImages['default']!;

    return Container(
      color: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            // แสดงสติ๊กเกอร์พร้อมอนิเมชัน
            buildRotatingSticker(selectedImage, screenWidth, screenHeight),
            const SizedBox(height: 20),
            // Button to Claim the Sticker
            GestureDetector(
              onTap: () async {
                await StickerBookPrefsService.saveIsCollected(
                    widget.stickerKey, true);

                print(
                    'Sticker collected: ${widget.stickerKey} saved successfully.');
                Navigator.pop(context,
                    {'stickerKey': widget.stickerKey}); // กลับไปหน้าก่อนหน้า
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: screenWidth * 0.38,
                    height: screenHeight * 0.2,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 35),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                              'assets/images/strickerbook/receivedbutton.png')),
                    ),
                  ),
                  Positioned(
                    top: screenHeight * -0.68,
                    left: screenWidth * -0.048,
                    child: Container(
                        width: screenWidth * 0.5,
                        height: screenHeight * 0.5,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/strickerbook/elmstk.png')))),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
