import 'package:firstly/screens/gameselectionpage.dart';
import 'package:flutter/material.dart';

class LineGameList extends StatelessWidget {
  const LineGameList({super.key});

  Widget buildBackButton(BuildContext context) {
    return Positioned(
      left: 16,
      top: 16,
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const GameSelectionPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(-1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                final tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 1000),
            ),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        hoverColor: Colors.transparent,
        hoverElevation: 0,
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 50,
          color: Color.fromARGB(255, 21, 21, 21),
        ),
      ),
    );
  }

  // สร้างตำแหน่งภาพซ้ำ
  List<Widget> buildPositionedImages() {
    List<Widget> positionedImages = [];

    List<Map<String, double>> positions = [
      {'top': 50, 'right': 60, 'width': 400, 'height': 400, 'rotation': 0.6},
      {
        'bottom': -40,
        'right': 150,
        'width': 300,
        'height': 300,
        'rotation': -0.2
      },
      {'top': 80, 'left': 80, 'width': 200, 'height': 200, 'rotation': -0.3},
    ];

    for (var position in positions) {
      positionedImages.add(Positioned(
        top: position['top'],
        left: position['left'],
        right: position['right'],
        bottom: position['bottom'],
        child: Transform.rotate(
          angle: position['rotation'] ?? 0.0, // ใช้ค่าการหมุนจาก position
          child: Image.asset(
            'assets/images/line.png',
            width: position['width'],
            height: position['height'],
            fit: BoxFit.contain,
          ),
        ),
      ));
    }

    return positionedImages;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // วิดเจ็ดพื้นหลัง
          Positioned.fill(
            child: Image.asset(
              'assets/images/homepage/grid.png', // รูปพื้นหลัง
              fit: BoxFit.cover,
            ),
          ),

          // วิดเจ็ดภาพองค์ประกอบพื้นหลัง
          ...buildPositionedImages(),

          buildBackButton(context),

          // วิดเจ็ดเนื้อหาหลักกลางจอ
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SizedBox ฝั่งซ้าย
                SizedBox(width: screenSize.width * 0.1),
                // รูปที่ต้องการแสดง โดยใช้ BoxFit.contain เพื่อป้องกันการตัด
                Container(
                  width: screenSize.width * 0.6,
                  height: screenSize.height * 0.5,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/comingsoon.png'),
                      fit: BoxFit.scaleDown, // ป้องกันการตัดของรูป
                    ),
                  ),
                ),
                // SizedBox ฝั่งขวา
                SizedBox(width: screenSize.width * 0.1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
