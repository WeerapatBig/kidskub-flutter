// ignore_for_file: prefer_const_constructors

//import 'package:firstly/screens/dotgamelist.dart';
//import 'package:firstly/screens/shared_prefs_service.dart';
import 'package:flutter/material.dart';

class DotGameEazy extends StatefulWidget {
  final String starColor;
  final int earnedStars;

  const DotGameEazy({
    Key? key,
    required this.starColor,
    required this.earnedStars,
  }) : super(key: key);

  @override
  State<DotGameEazy> createState() => _DotGameEazyState();
}

class _DotGameEazyState extends State<DotGameEazy> {
  // ตำแหน่งของจุดบนรูปภาพ (ใช้เป็นเปอร์เซ็นต์ของความกว้างและความสูง)
  List<Map<String, double>> dotPositions = [
    {'x': 0.35, 'y': 0.345},
    {'x': 0.59, 'y': 0.345},
    {'x': 0.24, 'y': 0.45},
    {'x': 0.475, 'y': 0.528},
    {'x': 0.72, 'y': 0.45},
    // เพิ่มจุดเพิ่มเติมตามต้องการ
  ];

  late List<bool> dotCollected;
  int stars = 0;
  bool levelComplete = false;

  // เก็บตำแหน่งของจุดที่อยู่บนจาน
  List<Offset> dotsOnPlate = [];

  @override
  void initState() {
    super.initState();
    dotCollected = List<bool>.filled(dotPositions.length, false);
  }

  // ฟังก์ชันสำหรับคำนวณจำนวนดาว
  int earnedStars() {
    if (stars >= 80) return 3;
    if (stars >= 60) return 2;
    return 1;
  }

  // ในฟังก์ชัน onGameComplete ของ _DotGameEazyState
  void onGameComplete(int earnedStars, String starColor) {
    if (dotCollected.every((collected) => collected) && !levelComplete) {
      setState(() {
        levelComplete = true; // ป้องกันการเรียกซ้ำ
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double dotWidgetSize = 24.0;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // ปุ่มลอยสำหรับย้อนกลับ
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back),
              ),
            ),
            // เนื้อหาหลักของเกม
            LayoutBuilder(builder: (context, constraints) {
              return Column(
                children: [
                  // Widget ชื่อเกม
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Chapter 1',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // เนื้อหาหลัก
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          // รูปภาพและจุด (ด้านซ้าย)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  double imageWidth = constraints.maxWidth;
                                  double imageHeight = constraints.maxHeight;

                                  double desiredImageWidth = imageWidth * 0.85;
                                  double desiredImageHeight =
                                      imageHeight * 0.85;

                                  return Stack(
                                    children: [
                                      Positioned(
                                        left: (imageWidth - desiredImageWidth) /
                                            2,
                                        top:
                                            (imageHeight - desiredImageHeight) /
                                                2,
                                        child: Image.asset(
                                          'assets/images/dotgame_easy/watermelon3.png',
                                          width: desiredImageWidth,
                                          height: desiredImageHeight,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      // แสดงจุดที่ยังไม่ได้เก็บ
                                      for (int i = 0;
                                          i < dotPositions.length;
                                          i++)
                                        if (!dotCollected[i])
                                          Positioned(
                                            left: ((imageWidth -
                                                        desiredImageWidth) /
                                                    2) +
                                                dotPositions[i]['x']! *
                                                    desiredImageWidth -
                                                dotWidgetSize / 2,
                                            top: ((imageHeight -
                                                        desiredImageHeight) /
                                                    2) +
                                                dotPositions[i]['y']! *
                                                    desiredImageHeight -
                                                dotWidgetSize / 2,
                                            child: Draggable<int>(
                                              data: i,
                                              feedback: DotWidget(),
                                              childWhenDragging: Container(),
                                              child: DotWidget(),
                                            ),
                                          ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                          // จานและตัวนับ (ด้านขวา)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(50.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 50.0),
                                  Expanded(
                                    child: PlateWidget(
                                      onAccept: (index, localPosition) {
                                        setState(() {
                                          dotCollected[index] = true;
                                          dotsOnPlate.add(localPosition);
                                          stars += 10;
                                          if (dotCollected.every(
                                              (collected) => collected)) {
                                            levelComplete = true;
                                            onGameComplete(
                                              earnedStars(),
                                              widget
                                                  .starColor, // ส่ง starColor จาก widget
                                            );
                                          }
                                        });
                                      },
                                      dotsOnPlate: dotsOnPlate,
                                      dotWidget: DotWidget(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
            // Widget แสดงเมื่อผ่านด่าน
            if (levelComplete)
              Center(
                child: LevelCompleteWidget(
                  stars: earnedStars(),
                  onBackToHome: () {},
                  onNextLevel: () {
                    print(
                        'Sending back earnedStars: ${earnedStars()}, starColor: ${widget.starColor}');
                    // ส่งข้อมูลจำนวนดาวและสีของดาวกลับไปยังหน้าที่เรียก
                    Navigator.pop(context, {
                      'starColor': widget.starColor,
                      'earnedStars': earnedStars(),
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Widget สำหรับจุด
class DotWidget extends StatelessWidget {
  final double size;

  const DotWidget({this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black87,
        shape: BoxShape.circle,
      ),
    );
  }
}

// Widget จานสำหรับเก็บจุด
class PlateWidget extends StatefulWidget {
  final Function(int index, Offset localPosition) onAccept;
  final List<Offset> dotsOnPlate;
  final Widget dotWidget;

  const PlateWidget({
    required this.onAccept,
    required this.dotsOnPlate,
    required this.dotWidget,
  });

  @override
  _PlateWidgetState createState() => _PlateWidgetState();
}

class _PlateWidgetState extends State<PlateWidget> {
  GlobalKey _plateKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double plateWidth = constraints.maxWidth;
      double plateHeight = constraints.maxHeight;

      // คุณสามารถปรับขนาดของจานที่นี่
      double desiredPlateWidth = plateWidth * 0.8; // หรือค่าที่คุณต้องการ
      double desiredPlateHeight = plateHeight * 0.8; // หรือค่าที่คุณต้องการ

      return Stack(
        alignment: Alignment.center,
        children: [
          // DragTarget ที่ห่อหุ้มจาน
          Positioned(
            left: (plateWidth - desiredPlateWidth) / 2,
            top: (plateHeight - desiredPlateHeight) / 2,
            child: DragTarget<int>(
              onAcceptWithDetails: (details) {
                RenderBox box =
                    _plateKey.currentContext?.findRenderObject() as RenderBox;
                Offset localPosition = box.globalToLocal(details.offset);
                widget.onAccept(details.data, localPosition);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  key: _plateKey,
                  width: desiredPlateWidth,
                  height: desiredPlateHeight,
                  child: Image.asset(
                    'assets/images/dotgame_easy/plate.png',
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),
          // แสดงจุดที่อยู่บนจาน
          for (Offset position in widget.dotsOnPlate)
            Positioned(
              left: (plateWidth - desiredPlateWidth) / 2 + position.dx - 12,
              top: (plateHeight - desiredPlateHeight) / 2 + position.dy - 12,
              child: widget.dotWidget,
            ),
        ],
      );
    });
  }
}

// Widget แสดงเมื่อผ่านด่าน
class LevelCompleteWidget extends StatelessWidget {
  final int stars;
  final VoidCallback onBackToHome;
  final VoidCallback onNextLevel;

  const LevelCompleteWidget({
    required this.stars,
    required this.onBackToHome,
    required this.onNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Level Complete',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // แสดงดาวตามคะแนน
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  stars,
                  (index) => Icon(Icons.star, color: Colors.yellow, size: 40),
                ),
              ),
              SizedBox(height: 20),
              // ปุ่มนำทาง
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: onBackToHome,
                    child: Icon(
                      Icons.home_rounded,
                      size: 50,
                      color: Color.fromARGB(255, 21, 21, 21),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onNextLevel,
                    child: Icon(
                      Icons.navigate_next_rounded,
                      size: 50,
                      color: Color.fromARGB(255, 21, 21, 21),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
