import 'package:flutter/material.dart';

import '../widgets/custom_button.dart';
import '../widgets/result_widget_quiz.dart';

class QuizLineGame extends StatefulWidget {
  @override
  _QuizLineGameState createState() => _QuizLineGameState();
}

class _QuizLineGameState extends State<QuizLineGame> {
  int currentLevel = 1;
  int hp = 3;

  bool showTutorial = false;
  bool showResult = false; // ควบคุมการแสดง ResultWidgetQuiz
  bool isWin = false;

  /// ตำแหน่งจุดเริ่มลาก (เป็นพิกัด pixel แล้ว)
  Offset? startPoint;

  /// ตำแหน่งระหว่างลาก (เป็นพิกัด pixel แล้ว)
  Offset? currentDrag;

  /// เก็บข้อมูลเส้นที่ลากเสร็จแล้ว
  /// จะเก็บ map: {'start': Offset, 'end': Offset, 'startIdx': int, 'endIdx': int, 'color': Color}
  List<Map<String, dynamic>> drawnLines = [];

  /// จุดซ้าย (normalized)
  final List<Offset> leftPoints = [
    Offset(0.4, 0.39),
    Offset(0.4, 0.54),
    Offset(0.4, 0.7),
  ];

  /// จุดขวา (normalized)
  final List<Offset> rightPoints = [
    Offset(0.6, 0.39),
    Offset(0.6, 0.54),
    Offset(0.6, 0.7),
  ];

  /// คำตอบที่ถูกต้อง (index ของจุดฝั่งซ้าย i ไปจุดฝั่งขวาอะไร)
  final List<List<int>> correctAnswers = [
    [1, 0, 2], // Level 1
    [2, 1, 0], // Level 2
    [2, 1, 0], // Level 3
  ];

  /// เก็บคำตอบผู้ใช้: userAnswers[i] = j
  /// หมายถึง จุดฝั่งซ้าย index i เชื่อมไปจุดฝั่งขวา index j
  List<int?> userAnswers = [null, null, null];

  /// **สีของจุดฝั่งซ้าย** (เริ่มขาว + ขอบดำ)
  List<Color> leftPointColors = [Colors.white, Colors.white, Colors.white];

  /// **สีของจุดฝั่งขวา**
  List<Color> rightPointColors = [Colors.white, Colors.white, Colors.white];

  /// แปลง Offset (normalized) -> พิกัด pixel ในจอ
  Offset _toPixelOffset(Offset normalized, Size screenSize) {
    return Offset(
      normalized.dx * screenSize.width,
      normalized.dy * screenSize.height,
    );
  }

  @override
  void initState() {
    super.initState();
    showTutorial = true;
  }

  /// เริ่มลาก (onPanStart)
  void _startDrawing(Offset tapPosition) {
    final screenSize = MediaQuery.of(context).size;

    // หาว่าแตะใกล้จุดซ้ายใดบ้าง
    int? leftIndex = _findPointIndex(tapPosition, leftPoints, screenSize);

    // ถ้าเจอจุดซ้าย
    if (leftIndex != null) {
      // เช็คก่อนว่า จุดซ้ายนี้ถูกเชื่อมเส้นไปแล้วหรือยัง
      if (userAnswers[leftIndex] != null) {
        // ถ้าถูกเชื่อมแล้ว ไม่อนุญาตให้ลากซ้ำ
        setState(() {
          startPoint = null;
          currentDrag = null;
        });
        return;
      }

      // Snap จุดซ้ายให้ตรงกลาง
      final snappedStart = _toPixelOffset(leftPoints[leftIndex], screenSize);

      setState(() {
        startPoint = snappedStart;
        currentDrag = null;
      });
    } else {
      // ไม่ได้แตะใกล้จุดซ้าย => ไม่เริ่มลาก
      setState(() {
        startPoint = null;
        currentDrag = null;
      });
    }
  }

  /// ฟังก์ชันอัปเดตเส้นระหว่างลาก (onPanUpdate)
  void _updateDrawing(Offset movePosition) {
    // ถ้ามี startPoint อยู่ แสดงว่ากำลังลาก
    if (startPoint != null) {
      setState(() {
        currentDrag = movePosition;
      });
    }
  }

  /// ปล่อยลาก (onPanEnd)
  void _endDrawing(Offset releasePosition) {
    final screenSize = MediaQuery.of(context).size;
    if (startPoint == null) return;

    // หา index จุดซ้ายจาก startPoint (พิกัด pixel ย้อนกลับเป็น index)
    int? startIdx = _findPointIndexByPixel(startPoint!, leftPoints, screenSize);

    // หา index จุดขวา จากพิกัดที่ปล่อย
    int? endIdx = _findPointIndex(releasePosition, rightPoints, screenSize);

    if (startIdx != null && endIdx != null) {
      // Snap จุดขวา
      final snappedEnd = _toPixelOffset(rightPoints[endIdx], screenSize);

      setState(() {
        userAnswers[startIdx] = endIdx;

        // บันทึกเส้น
        drawnLines.add({
          'start': startPoint!,
          'end': snappedEnd,
          'startIdx': startIdx,
          'endIdx': endIdx,
          'color': Colors.black,
        });

        // **เปลี่ยนสีจุดเป็นสีดำ** แสดงว่ามีการลากเชื่อมแล้ว
        leftPointColors[startIdx] = Colors.black;
        rightPointColors[endIdx] = Colors.black;

        // เคลียร์สถานะการลาก
        startPoint = null;
        currentDrag = null;
      });
    } else {
      // ถ้าไม่เจอจุดขวา => ยกเลิก
      setState(() {
        startPoint = null;
        currentDrag = null;
      });
    }
  }

  /// หา index ของจุด listPoints (normalized) ที่อยู่ใกล้ tapPosition (pixel) เกิน threshold หรือไม่
  int? _findPointIndex(
      Offset tapPosition, List<Offset> listPoints, Size screenSize,
      {double threshold = 40}) {
    for (int i = 0; i < listPoints.length; i++) {
      final pixelPoint = _toPixelOffset(listPoints[i], screenSize);
      if ((pixelPoint - tapPosition).distance < threshold) {
        return i;
      }
    }
    return null;
  }

  /// กรณีเรามี "startPoint" เป็นพิกัด pixel แล้ว อยาก reverse หา index ใน listPoints
  int? _findPointIndexByPixel(
      Offset pixelPosition, List<Offset> listPoints, Size screenSize,
      {double threshold = 5}) {
    for (int i = 0; i < listPoints.length; i++) {
      final pixelPoint = _toPixelOffset(listPoints[i], screenSize);
      if ((pixelPoint - pixelPosition).distance < threshold) {
        return i;
      }
    }
    return null;
  }

  /// ตรวจคำตอบ
  /// - ถ้าผิด ให้ลบเฉพาะเส้นที่ผิด
  /// - ถ้าถูกให้คงอยู่
  /// - เช็คถ้าถูกทั้งหมดหรือไม่
  void checkAnswer() {
    bool hasWrong = false;
    final correct = correctAnswers[currentLevel - 1];

    // ตรวจแต่ละจุดซ้าย i = 0..2
    for (int i = 0; i < 3; i++) {
      int? userAns = userAnswers[i];
      int correctAns = correct[i];

      if (userAns != null && userAns != correctAns) {
        hasWrong = true;
        _markLineColor(i, Colors.red);
        leftPointColors[i] = Colors.red;
        rightPointColors[userAns] = Colors.red;

        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            drawnLines.removeWhere((line) => line['startIdx'] == i);
            userAnswers[i] = null;
            leftPointColors[i] = Colors.white;
            rightPointColors[userAns] = Colors.white;
          });
        });
      } else if (userAns != null && userAns == correctAns) {
        _markLineColor(i, Colors.green);
        leftPointColors[i] = Colors.green;
        rightPointColors[userAns] = Colors.green;
      }
    }

    // ถ้าเจอเส้นผิด => หัก hp
    if (hasWrong) {
      hp--;
      if (hp <= 0) {
        // แพ้ => โชว์ ResultWidgetQuiz แบบ GameOver
        setState(() {
          isWin = false; // แพ้
          showResult = true;
        });
        return;
      }
      // ยังมี hp เหลือ => แค่ผิดแล้วลบเส้น
      return; // ไม่เช็คต่อ
    }

    // ถ้าไม่มีเส้นผิด => เช็คว่าครบ 3 จุดหรือยัง
    bool allFilled = userAnswers.every((ans) => ans != null);
    if (allFilled && !hasWrong) {
      // ถ้าครบ 3 จุด
      Future.delayed(const Duration(seconds: 1), () {
        if (currentLevel < 3) {
          _nextLevel();
        } else {
          // ผ่านเลเวล 3 => ชนะ
          setState(() {
            isWin = true; // ชนะ
            showResult = true;
          });
        }
      });
    }
  }

  /// เซ็ตสีเส้นที่ startIdx == i ให้เป็น [color]
  void _markLineColor(int i, Color color) {
    setState(() {
      for (var line in drawnLines) {
        if (line['startIdx'] == i) {
          line['color'] = color;
        }
      }
    });
  }

  // --------- ฟังก์ชันใหม่ที่ลบ "ทุกเส้น" แบบไม่สนใจถูก/ผิด ---------
  void _resetAllLinesCompletely() {
    setState(() {
      // ล้างเส้นทั้งหมด
      drawnLines.clear();

      // รีเซ็ตคำตอบ 3 จุด
      userAnswers = [null, null, null];

      // เคลียร์สถานะลาก
      startPoint = null;
      currentDrag = null;

      // จุดซ้าย-ขวา กลับเป็นสีขาว (ตาม requirement)
      for (int i = 0; i < leftPointColors.length; i++) {
        leftPointColors[i] = Colors.white;
      }
      for (int i = 0; i < rightPointColors.length; i++) {
        rightPointColors[i] = Colors.white;
      }
    });
  }

  void _onPressResetButton() {
    // รีเซ็ตกลับค่าเริ่มต้น
    currentLevel = 1;
    hp = 3;
    showResult = false;
    isWin = false;

    // เคลียร์เส้นทั้งหมด / userAnswers
    drawnLines.clear();
    userAnswers = [null, null, null];

    // รีเซ็ตสีจุด
    for (int i = 0; i < leftPointColors.length; i++) {
      leftPointColors[i] = Colors.white;
    }
    for (int i = 0; i < rightPointColors.length; i++) {
      rightPointColors[i] = Colors.white;
    }

    // อะไรอื่น ๆ ที่ต้องเคลียร์...
  }

  void _nextLevel() {
    setState(() {
      currentLevel++;
      userAnswers = [null, null, null];
      drawnLines.clear();

      // จุดกลับเป็นค่าเริ่มต้น
      leftPointColors = [Colors.white, Colors.white, Colors.white];
      rightPointColors = [Colors.white, Colors.white, Colors.white];
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onPanStart: (details) => _startDrawing(details.localPosition),
        onPanUpdate: (details) => _updateDrawing(details.localPosition),
        onPanEnd: (details) => _endDrawing(details.localPosition),
        child: Stack(
          children: [
            Positioned.fill(
                child: Image.asset(
                    'assets/images/linegamelist/line_quiz/paper_bg.png')),

            Positioned(
                top: screenSize.height * 0.18,
                left: screenSize.width * 0.15,
                child: SizedBox(
                  width: screenSize.width * 0.45,
                  child: Image.asset(
                      'assets/images/linegamelist/line_quiz/objective.png'),
                )),
            // วาดเส้น
            Positioned.fill(
              child: CustomPaint(
                painter: LinePainter(
                  drawnLines: drawnLines,
                  startPoint: startPoint,
                  currentDrag: currentDrag,
                ),
              ),
            ),

            // รูปฝั่งซ้าย
            _buildLeftColumn(screenSize),
            // รูปฝั่งขวา
            _buildRightColumn(screenSize),

            // จุด (Anchor Point) ฝั่งซ้าย/ขวา
            _buildAnchorPoints(screenSize),

            Positioned(
              bottom: screenSize.height * 0.11,
              left: 0,
              right: 0,
              child: Center(
                child: Builder(
                  builder: (context) {
                    // เช็คว่าลากครบหรือยัง
                    bool isAllMatched = userAnswers.every((ans) => ans != null);

                    return GestureDetector(
                      // ถ้ายังไม่ครบ 3 เส้น ให้เป็น null หรือไม่ทำงาน
                      onTap: checkAnswer,
                      child: Image.asset(
                        isAllMatched
                            // รูปปุ่มสีม่วง
                            ? 'assets/images/linegamelist/line_quiz/active_check_button.png'
                            // รูปปุ่มสีเทา
                            : 'assets/images/linegamelist/line_quiz/inactive_check_button.png',
                        width: screenSize.width * 0.22,
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
                top: screenSize.height * 0.05,
                left: screenSize.width * 0.05,
                child: _buildLifeBar()),

            // **** เพิ่มปุ่มรีเซ็ต (ใช้รูปแทนปุ่ม) ****
            Positioned(
              bottom: screenSize.height * 0.25,
              right: screenSize.width * 0.12,
              child: CustomButton(
                onTap: () {
                  setState(() {
                    _resetAllLinesCompletely();
                  });
                },
                child: Image.asset(
                  'assets/images/reload_button.png',
                  width: screenSize.width * 0.055,
                ),
              ),
            ),
            // ----- ปุ่ม FloatingButton Icon ย้อนกลับ -----
            Positioned(
              top: screenSize.height * 0.05,
              right: screenSize.width * 0.04,
              child: CustomButton(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) => _buildExitPopUp(context),
                  );
                },
                child: Image.asset(
                  'assets/images/close_button.png',
                  width: screenSize.width * 0.060,
                ),
              ),
            ),

            // ปุ่ม Info สำหรับเปิด TutorialWidget
            Positioned(
              bottom: screenSize.height * 0.05,
              right: screenSize.width * 0.04,
              child: CustomButton(
                onTap: () {
                  setState(() {
                    showTutorial = true; // เปิด TutorialWidget
                  });
                },
                child: Image.asset(
                  'assets/images/HintButton.png',
                  width: screenSize.width * 0.060,
                ),
              ),
            ),

            // แสดง TutorialWidget
            if (showTutorial)
              AnimatedOpacity(
                opacity: showTutorial ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 1000),
                child: _buildTutorialWidget(),
              ),

            // ---- เงื่อนไขแพ้-ชนะ ----
            if (isWin && showResult)
              ResultWidgetQuiz(
                onLevelComplete: true,
                starsEarned: 1, // ได้ดาวม่วง 1 ดวง
                onButton1Pressed: () {
                  setState(() {
                    _onPressResetButton(); // ฟังก์ชันรีเซ็ตเกมใหม่
                  });
                },
                onButton2Pressed: () {
                  // กดปุ่ม “ไปต่อ”
                  Navigator.pop(context, {
                    'earnedStars': 1,
                    'starColor': 'purple',
                  });
                },
              ),

            if (hp <= 0 && showResult)
              ResultWidgetQuiz(
                onLevelComplete: false, // สื่อว่าแพ้
                starsEarned: 0,
                onButton1Pressed: () {
                  setState(() {
                    _onPressResetButton();
                  });
                },
                onButton2Pressed: () {
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  /// วางจุด (Anchor points) ให้ผู้เล่นเห็น
  Widget _buildAnchorPoints(Size screenSize) {
    return Positioned.fill(
      child: Stack(
        children: [
          // วางจุดฝั่งซ้าย (สีแดง)
          for (int i = 0; i < leftPoints.length; i++)
            _buildOnePoint(
              _toPixelOffset(leftPoints[i], screenSize),
              i,
              isLeftSide: true,
            ),

          // วางจุดฝั่งขวา (สีน้ำเงิน)
          for (int i = 0; i < rightPoints.length; i++)
            _buildOnePoint(
              _toPixelOffset(rightPoints[i], screenSize),
              i,
              isLeftSide: false,
            ),
        ],
      ),
    );
  }

  /// สร้าง widget จุดทรงกลม
  Widget _buildOnePoint(Offset pos, int index, {required bool isLeftSide}) {
    double r = 17.0; // รัศมีจุด
    Color fillColor =
        isLeftSide ? leftPointColors[index] : rightPointColors[index];

    return Positioned(
      left: pos.dx - r,
      top: pos.dy - r,
      child: Container(
        width: r * 2,
        height: r * 2,
        decoration: BoxDecoration(
          color: fillColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 4),
        ),
      ),
    );
  }

  /// แสดงรูปฝั่งซ้าย
  Widget _buildLeftColumn(Size screenSize) {
    final List<double> imageSizes = [0.11, 0.08, 0.11]; // ขนาดของแต่ละตำแหน่ง
    return Positioned(
      left: screenSize.width * 0.2,
      top: screenSize.height * 0.05,
      bottom: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Image.asset(
              'assets/images/linegamelist/line_quiz/question_${(currentLevel - 1) * 3 + index + 1}.png',
              width: screenSize.width * imageSizes[index],
            ),
          );
        }),
      ),
    );
  }

  /// แสดงรูปฝั่งขวา
  Widget _buildRightColumn(Size screenSize) {
    final Map<int, double> imageSizeMap = {
      1: 0.1, 2: 0.13, 3: 0.14, // ขนาดของภาพในเลเวล 1 (1-3)
      4: 0.11, 5: 0.11, 6: 0.11, // ขนาดของภาพในเลเวล 2 (4-6)
      7: 0.09, 8: 0.09, 9: 0.14, // ขนาดของภาพในเลเวล 3 (7-9)
    };

    return Positioned(
      right: screenSize.width * 0.225,
      top: screenSize.height * 0.055,
      bottom: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          int imageIndex =
              (currentLevel - 1) * 3 + index + 1; // คำนวณ index ของรูป
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Image.asset(
              'assets/images/linegamelist/line_quiz/answers_$imageIndex.png',
              width: screenSize.width * (imageSizeMap[imageIndex] ?? 0.14),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildExitPopUp(BuildContext context) {
    double imageWidth = MediaQuery.of(context).size.width;
    double imageHeight = MediaQuery.of(context).size.height;

    return Container(
      //สีพื้นหลัง
      color: Colors.black.withOpacity(0.5),
      child: AlertDialog(
        backgroundColor: Colors.transparent, // สีพื้นหลัง
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ปุ่มออก
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(); // ปิด popup
                Navigator.of(context).pop(); // ออกจากหน้า
              },
              child: Image.asset('assets/images/linegamelist/exit_button.png',
                  width: imageWidth * 0.28, height: imageHeight * 0.48),
            ),
            SizedBox(width: imageWidth * 0.02),
            // ปุ่มเล่นต่อ
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(); // ปิด popup
              },
              child: Image.asset('assets/images/linegamelist/resume_button.png',
                  width: imageWidth * 0.2, height: imageHeight * 0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifeBar() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      height: MediaQuery.of(context).size.height * 0.1,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.black, width: 4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Image.asset(
              index < hp
                  ? 'assets/images/linegamelist/hp.png' // Full heart
                  : 'assets/images/linegamelist/hp_empty.png', // Empty heart
              width: MediaQuery.of(context).size.width * 0.045, // Adjust size
              height: MediaQuery.of(context).size.height * 0.075,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTutorialWidget() {
    // Widget สำหรับแสดง Tutorial
    return GestureDetector(
      onTap: () {
        setState(() {
          showTutorial = false; // ปิด TutorialWidget
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 1,
        color: Colors.black.withOpacity(0.6), // พื้นหลังโปร่งแสง
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/images/linegamelist/line_quiz/tutorial_quiz.png', // แก้รูปภาพการสอน
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'แตะเพื่อเล่นต่อ',
                  style: TextStyle(
                    fontSize: 50,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Painter วาดเส้น
class LinePainter extends CustomPainter {
  final List<Map<String, dynamic>> drawnLines;
  final Offset? startPoint;
  final Offset? currentDrag;

  LinePainter({
    required this.drawnLines,
    this.startPoint,
    this.currentDrag,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // วาดเส้นที่ผู้ใช้ลากเสร็จแล้ว
    for (var line in drawnLines) {
      final paint = Paint()
        ..color = line['color'] as Color // ใช้สีจาก line['color']
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(line['start'], line['end'], paint);
    }

    // วาดเส้นขณะลาก (สีดำชั่วคราว)
    if (startPoint != null && currentDrag != null) {
      final paint = Paint()
        ..color = Colors.black
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(startPoint!, currentDrag!, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
