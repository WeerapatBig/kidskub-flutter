import 'dart:ui' as ui;
import 'package:firstly/screens/list_game_page/list_game_dot_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firstly/function/background_audio_manager.dart';

import '../screens/shared_prefs_service.dart';
import '../widgets/drawing_effect.dart';
import '../widgets/progressbar.dart';
import '../widgets/result_widget.dart';

class DotGameEasy extends StatefulWidget {
  const DotGameEasy({
    super.key,
  });
  @override
  _DotGameEasyState createState() => _DotGameEasyState();
}

class _DotGameEasyState extends State<DotGameEasy> {
  int currentLevel = 1; // ระดับเริ่มต้น
  int earnedStars = 0;

  String starColor = 'yellow';
  bool showEndWidget = false; // สถานะสำหรับแสดง ResultWidget

  final prefsService = SharedPrefsService();

  void _endGame() {
    setState(() {
      showEndWidget = true; // แสดง ResultWidget แทนการนำทาง
    });
  }

  Future<void> _completeLevel() async {
    setState(() {
      currentLevel++;
      earnedStars++;
      if (earnedStars == 3 || currentLevel == 4) {
        _endGame();
      }
    });
  }

  void _finishGame() async {
    // บันทึกข้อมูลของด่านปัจจุบัน
    await prefsService.saveLevelData('Dot Easy', earnedStars, 'yellow', true);

// ปลดล็อคด่านถัดไป
    await prefsService.updateLevelUnlockStatus('Dot Easy', 'Dot Hard');

    // ตรวจสอบข้อมูลที่บันทึก
    final result = await prefsService.loadLevelData('Dot Easy');
    print("Saved Level Data: $result");

    // กลับไปยังหน้าเลือกเกม
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double barHeight = MediaQuery.of(context).size.height;
    double barWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/dotchapter/bg.png'),
            fit: BoxFit.cover, // ขยายรูปให้เต็มพื้นที่หน้าจอ
          ),
        ),
        child: Stack(
          children: [
            // Progress Bar อยู่ด้านบนสุด
            Positioned(
              top: barHeight * 0.1, // ระยะห่างจากด้านบน
              left: barWidth * 0.32, // ระยะห่างจากด้านซ้าย
              right: barWidth * 0.38, // ระยะห่างจากด้านขวา
              child: ProgressBarWidget(
                getStars: earnedStars, // กำหนดค่า Progress Bar ตามระดับ Level
                starPositions: [
                  barWidth * 0.06,
                  barWidth * 0.16,
                  barWidth * 0.26
                ], // กำหนดตำแหน่งดาว
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(
                  milliseconds: 800), // ตั้งค่าความเร็วในการเปลี่ยน
              transitionBuilder: (Widget child, Animation<double> animation) {
                // ใช้ ScaleTransition และ FadeTransition พร้อมกัน
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0).animate(animation),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  ),
                );
              },
              child: currentLevel == 1
                  ? Level1Widget(
                      key: const ValueKey(1),
                      onLevelComplete: _completeLevel,
                    )
                  : currentLevel == 2
                      ? Level2Widget(
                          key: const ValueKey(2),
                          onLevelComplete: _completeLevel,
                        )
                      : Level3Widget(
                          key: const ValueKey(3),
                          onLevelComplete: _completeLevel,
                        ),
            ),
            if (showEndWidget)
              Center(
                // ฉากหลังโปร่งใส
                child: ResultWidget(
                  onLevelComplete: true,
                  starsEarned: earnedStars,
                  onButton1Pressed: () {
                    // ฟังก์ชันเมื่อปุ่มที่ 1 ถูกกด (เล่นอีกครั้ง)
                    setState(() {
                      showEndWidget = false;
                      currentLevel = 1;
                      earnedStars = 0;
                    });
                  },
                  onButton2Pressed: () {
                    _finishGame();
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}

// คลาสแม่สำหรับเลเวลต่าง ๆ
abstract class BaseLevelWidget extends StatefulWidget {
  final VoidCallback onLevelComplete;
  const BaseLevelWidget({super.key, required this.onLevelComplete});
}

abstract class BaseLevelWidgetState<T extends BaseLevelWidget>
    extends State<T> {
  List<Particle> particles = [];
  Offset? previousPosition;
  Timer? _timer;
  bool isCut = false;
  List<bool> dashedLinesCrossed = [];
  late ui.Size screenSize;
  bool hasTriggeredNextLevel = false;
  bool showDashedLines = true;
  bool isSoundPlaying = false; // เพิ่มตัวแปรควบคุมเสียง

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  @override
  void initState() {
    super.initState();

    // เช็คระดับก่อนเล่นเสียง Hint Button
    if (widget is Level1Widget || widget is Level3Widget) {
      BackgroundAudioManager().playButtonClickSound();
    }
    BackgroundAudioManager().stopAllSounds();
    _startFadeTimer();
    dashedLinesCrossed = List<bool>.filled(2, false);
  }

  void _startFadeTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        particles =
            particles.where((p) => p.opacity > 0).map((p) => p.fade()).toList();
      });
    });
  }

  // เมธอด `_buildCutPiece` สำหรับใช้ใน Level1Widget และ Level2Widget
  Widget _buildCutPiece(String assetPath, double top, double left, double angle,
      double width, double height) {
    return Positioned(
      top: top,
      left: left,
      child: Transform.rotate(
        angle: angle,
        child: Image.asset(
          assetPath,
          width: width, // ขนาดที่ใช้ในแต่ละเลเวล
          height: height,
        ),
      ),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      particles.clear();
      previousPosition = details.localPosition;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      Offset currentPosition = details.localPosition;
      if (previousPosition != null) {
        particles.add(Particle(
          start: previousPosition!,
          end: currentPosition,
          opacity: 1.0,
          width: screenSize.width * 0.018,
        ));

        // เล่นเสียงเมื่อวาดเส้น
        if (!isSoundPlaying) {
          isSoundPlaying = true;
          BackgroundAudioManager().playCutFruitSound();

          // ตั้งเวลาให้เสียงสามารถเล่นได้อีกครั้ง
          Future.delayed(const Duration(milliseconds: 500), () {
            isSoundPlaying = false;
          });
        }

        _isCuttingThroughDashedLine(previousPosition!, currentPosition);

        if (dashedLinesCrossed.every((crossed) => crossed) &&
            !hasTriggeredNextLevel) {
          hasTriggeredNextLevel = true;
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              isCut = true; // เริ่มแอนิเมชันการตัดแตงโม
              showDashedLines = false; // ซ่อนเส้นปะ
            });

            //  เพิ่มเสียงเมื่อตัดแตงโม
            BackgroundAudioManager().playCuttingMelonSound();

            // หน่วงเวลาเพิ่มเติมก่อนเริ่มเลเวลถัดไป
            Future.delayed(const Duration(seconds: 2), widget.onLevelComplete);
          });
        }
      }
      previousPosition = currentPosition;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    previousPosition = null;
  }

  bool _isCuttingThroughDashedLine(Offset start, Offset end);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildDashedLines();
  Widget _buildWatermelon();
  Widget _buildCutWatermelon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildBackground(),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: isCut ? _buildCutWatermelon() : _buildWatermelon(),
        ),

        //_buildDebugRects(), // แสดงตำแหน่ง Rect บนหน้าจอ
        //_buildDebugRectsLv2(), // แสดงตำแหน่ง Rect บนหน้าจอ
        if (showDashedLines) _buildDashedLines(),
        GestureDetector(
          onPanStart: _handlePanStart,
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          child: CustomPaint(
            painter: ParticleTailPainter(particles),
            size: MediaQuery.of(context).size,
          ),
        ),
        _buildBackButton(),
      ],
    );
  }

  Widget _buildBackground() {
    return Positioned(
      top: screenSize.height * 0.15,
      left: screenSize.width * 0.13,
      child: Transform.rotate(
        angle: 1.57,
        child: Image.asset(
          'assets/images/dotgame_easy/board.png',
          width: screenSize.width * 0.8,
          height: screenSize.height * 0.8,
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      left: screenSize.width * 0.028,
      top: screenSize.height * 0.038,
      child: FloatingActionButton(
        onPressed: () {
          BackgroundAudioManager().playButtonBackSound(); // เล่นเสียงกดปุ่ม
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const ListGameDotScreen(),
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
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: screenSize.width * 0.05,
          color: const Color.fromARGB(255, 21, 21, 21),
        ),
      ),
    );
  }

  // Widget _buildDebugRects() {
  //   List<Rect> rects = [];
  //   //double centerY = screenSize.height;
  //   double centerX = screenSize.width;

  //   for (int i = 0; i < dashedLinesCrossed.length; i++) {
  //     double offset;
  //     double left;
  //     double top = screenSize.height * 0.45;
  //     double width = screenSize.width * 0.01;
  //     double height = screenSize.height * 0.65;

  //     if (i == 1) {
  //       // กำหนดค่าเฉพาะสำหรับเส้นที่สอง
  //       offset = i * 120.0; // ตัวอย่าง: เปลี่ยนระยะห่าง
  //       left = centerX / 2.21 + offset - 5; // หรือปรับค่าตามต้องการ
  //       height = height / 4;
  //       top = top;
  //       // คุณสามารถปรับค่า top, width, height ได้ตามต้องการ
  //     } else {
  //       // ค่าเริ่มต้นสำหรับเส้นอื่น ๆ
  //       offset = i * 100.0;
  //       left = centerX / 2.21 + offset - 5;
  //       height = height / 4;
  //     }

  //     rects.add(Rect.fromLTWH(left, top, width, height));
  //   }

  //   return CustomPaint(
  //     painter: DebugDashedLineRectPainter(rects),
  //     size: screenSize,
  //   );
  // }

  // Widget _buildDebugRectsLv2() {
  //   List<Rect> rects = [];

  //   // Center X and Y based on the screen size
  //   double centerX = screenSize.width;
  //   double centerY = screenSize.height;

  //   // Define the debug rectangles exactly as in `_isCuttingThroughDashedLine`
  //   Rect verticalLineRect = Rect.fromLTWH(
  //       centerX / 2 - 24, centerY / 1.6, centerX * 0.015, centerY * 0.1);
  //   Rect horizontalLineRect = Rect.fromLTWH(
  //       centerX / 1.9, centerY / 1.91, centerX * 0.05, centerY * 0.028);

  //   // Add these rectangles to the list
  //   rects.add(verticalLineRect);
  //   rects.add(horizontalLineRect);

  //   // Return a CustomPaint widget with the debug painter
  //   return CustomPaint(
  //     painter: DebugDashedLineRectPainter(rects),
  //     size: screenSize,
  //   );
  // }
}

// คลาสสำหรับ Level 1
class Level1Widget extends BaseLevelWidget {
  const Level1Widget({super.key, required VoidCallback onLevelComplete})
      : super(onLevelComplete: onLevelComplete);

  @override
  _Level1WidgetState createState() => _Level1WidgetState();
}

class _Level1WidgetState extends BaseLevelWidgetState<Level1Widget> {
  bool showTutorial = true; // ตัวแปรสถานะแสดงวิดเจ็ตการสอนเล่น

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        super.build(context), // วิดเจ็ตหลักของเกมเลเวล
        Positioned(
          bottom: screenSize.height * 0.05,
          right: screenSize.width * 0.05,
          child: FloatingActionButton(
              onPressed: () {
                BackgroundAudioManager().playButtonClickSound();
                setState(() {
                  showTutorial = true; // เปิด TutorialWidget
                });
              },
              backgroundColor: Colors.white.withOpacity(0),
              elevation: 0,
              hoverElevation: 0,
              focusElevation: 0,
              highlightElevation: 0,
              child: Image.asset('assets/images/HintButton.png')),
        ),
        if (showTutorial) _buildTutorialWidget(), // วิดเจ็ตการสอนเล่น
      ],
    );
  }

  // ฟังก์ชันสร้างวิดเจ็ตการสอนเล่น
  Widget _buildTutorialWidget() {
    return GestureDetector(
      onTap: () {
        BackgroundAudioManager().playButtonClickSound();
        setState(() {
          showTutorial = false; // ปิดวิดเจ็ตเมื่อผู้ใช้คลิก
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 1,
        color: Colors.black.withOpacity(0.5), // พื้นหลังโปร่งแสง
        child: Center(
          child: SizedBox(
            width: screenSize.width * 0.6,
            height: screenSize.height * 0.7,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                'assets/images/Hint1.png', // แก้รูปภาพการสอน
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool _isCuttingThroughDashedLine(Offset start, Offset end) {
    List<Rect> rects = [];
    double centerX = screenSize.width;

    for (int i = 0; i < dashedLinesCrossed.length; i++) {
      double offset = i * 120;
      double left;
      double top = screenSize.height * 0.45;
      double width = screenSize.width * 0.01;
      double height = screenSize.height * 0.65;

      if (i == 1) {
        // กำหนดค่าเฉพาะสำหรับเส้นที่สอง
        offset = i * 120.0; // ตัวอย่าง: เปลี่ยนระยะห่าง
        left = centerX / 2.21 + offset - 5; // หรือปรับค่าตามต้องการ
        height = height / 4;
        top = top;
        // คุณสามารถปรับค่า top, width, height ได้ตามต้องการ
      } else {
        // ค่าเริ่มต้นสำหรับเส้นอื่น ๆ
        offset = i * 100.0;
        left = centerX / 2.21 + offset - 5;
        height = height / 4;
      }
      Rect dashedLineRect = Rect.fromLTWH(left, top, width, height);
      rects.add(dashedLineRect);

      // Debugging: ดูว่าตำแหน่งของ Rect และจุดลากอยู่ที่ไหน
      print("Checking rect: $dashedLineRect with start: $start and end: $end");

      // ตรวจสอบการลากผ่านเส้นปะ
      if (dashedLineRect.overlaps(Rect.fromPoints(start, end)) &&
          !dashedLinesCrossed[i]) {
        setState(() {
          dashedLinesCrossed[i] = true; // บันทึกว่าเส้นปะถูกตัด
        }); // บันทึกว่าเส้นปะถูกตัด
        print("Line $i marked as cut");
      }
    }
    return false;
  }

  @override
  Widget _buildDashedLines() {
    return CustomPaint(
      painter: DashedLinePainter(
        isVertical: true,
        lineCount: 2,
        verticalLinePosition: Offset(screenSize.width * 0.455, 580),
        horizontalLinePosition: const Offset(0, 0), // ไม่มีการใช้ใน Level 1
        dashLength: screenSize.height * 0.03,
        dashSpacing: screenSize.height * 0.03,
        strokeWidth: screenSize.width * 0.0042,
        color: Colors.white,
        startY: screenSize.height * 0.3, // กำหนดจุดเริ่มต้นในแนว Y
        endY: screenSize.height * 0.8, // กำหนดจุดสิ้นสุดในแนว Y
        dashedLinesCrossed: dashedLinesCrossed, // เปลี่ยนสีเมื่อโดนลากเส้นผ่าน
      ),
      size: MediaQuery.of(context).size,
    );
  }

  @override
  Widget _buildWatermelon() {
    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isCut ? 0 : 1,
        child: Transform.rotate(
          angle: 1.55,
          child: Container(
            margin: EdgeInsets.fromLTRB(
                screenSize.width * 0.05, 0, screenSize.width * 0.01, 0),
            child: Image.asset(
              'assets/images/dotgame_easy/watermelon.png',
              width: screenSize.width * 0.28,
              height: screenSize.height * 0.6,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget _buildCutWatermelon() {
    return Stack(
      children: [
        _buildCutPiece(
            'assets/images/dotgame_easy/watermelon_top.png',
            screenSize.height * 0.42,
            screenSize.width * 0.48,
            1.57,
            screenSize.width * 0.26,
            screenSize.height * 0.26),
        _buildCutPiece(
            'assets/images/dotgame_easy/watermelon_middle.png',
            screenSize.height * 0.425,
            screenSize.width * 0.36,
            1.57,
            screenSize.width * 0.25,
            screenSize.height * 0.25),
        _buildCutPiece(
            'assets/images/dotgame_easy/watermelon_bottom.png',
            screenSize.height * 0.425,
            screenSize.width * 0.234,
            1.57,
            screenSize.width * 0.25,
            screenSize.height * 0.25),
      ],
    );
  }
}

// คลาสสำหรับ Level 2
class Level2Widget extends BaseLevelWidget {
  const Level2Widget({super.key, required VoidCallback onLevelComplete})
      : super(onLevelComplete: onLevelComplete);

  @override
  _Level2WidgetState createState() => _Level2WidgetState();
}

class _Level2WidgetState extends BaseLevelWidgetState<Level2Widget> {
  @override
  void initState() {
    super.initState();
    dashedLinesCrossed = List<bool>.filled(2, false);
  }

  @override
  bool _isCuttingThroughDashedLine(Offset start, Offset end) {
    double centerX = screenSize.width;
    double centerY = screenSize.height;

    // ตรวจสอบเส้นปะแนวตั้ง
    Rect verticalLineRect = Rect.fromLTWH(
        centerX / 2 - 24, centerY / 1.6, centerX * 0.015, centerY * 0.1);
    if (verticalLineRect.contains(start) && verticalLineRect.contains(end)) {
      setState(() {
        dashedLinesCrossed[0] = true; // บันทึกว่าเส้นปะถูกตัด
      });
    }

    // ตรวจสอบเส้นปะแนวนอน
    Rect horizontalLineRect = Rect.fromLTWH(
        centerX / 1.9, centerY / 1.91, centerX * 0.05, centerY * 0.028);
    if (horizontalLineRect.contains(start) &&
        horizontalLineRect.contains(end)) {
      setState(() {
        dashedLinesCrossed[1] = true; // บันทึกว่าเส้นปะถูกตัด
      });
    }

    return dashedLinesCrossed.every((crossed) => crossed == true);
  }

  @override
  Widget _buildDashedLines() {
    return CustomPaint(
      painter: DashedLinePainter(
        isVertical: true,
        isHorizontal: true,
        lineCount: 1,
        verticalLinePosition:
            Offset(screenSize.width / 2.05, screenSize.height / 4),
        horizontalLinePosition:
            Offset(screenSize.width / 3, screenSize.height / 1.86),
        dashLength: screenSize.height * 0.03,
        dashSpacing: screenSize.height * 0.0245,
        strokeWidth: screenSize.width * 0.0042,
        color: Colors.white,
        startX:
            screenSize.width * 0.33, // กำหนดจุดเริ่มต้นในแนว X สำหรับเส้นแนวนอน
        endX:
            screenSize.width * 0.65, // กำหนดจุดสิ้นสุดในแนว X สำหรับเส้นแนวนอน
        startY: screenSize.height *
            0.278, // กำหนดจุดเริ่มต้นในแนว Y สำหรับเส้นแนวตั้ง
        endY: screenSize.height *
            0.84, // กำหนดจุดสิ้นสุดในแนว Y สำหรับเส้นแนวตั้ง
        dashedLinesCrossed: dashedLinesCrossed, // เปลี่ยนสีเมื่อโดนลากเส้นผ่าน
      ),
      size: MediaQuery.of(context).size / 1.2,
    );
  }

  @override
  Widget _buildWatermelon() {
    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isCut ? 0 : 1,
        child: Transform.rotate(
          angle: 0.0,
          child: Container(
            margin: EdgeInsets.fromLTRB(0, screenSize.height * 0.1,
                screenSize.height * 0.05, screenSize.height * 0),
            child: Image.asset(
              'assets/images/dotgame_easy/watermelon2.png',
              width: screenSize.width * 0.42,
              height: screenSize.height * 0.58,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget _buildCutWatermelon() {
    return Stack(
      children: [
        _buildCutPiece(
            'assets/images/dotgame_easy/watermelon2_1.png',
            screenSize.height * 0.235,
            screenSize.width * 0.295,
            0,
            screenSize.width * 0.19,
            screenSize.height * 0.29),
        _buildCutPiece(
            'assets/images/dotgame_easy/watermelon2_2.png',
            screenSize.height * 0.235,
            screenSize.width * 0.49,
            0,
            screenSize.width * 0.19,
            screenSize.height * 0.29),
        _buildCutPiece(
            'assets/images/dotgame_easy/watermelon2_3.png',
            screenSize.height * 0.558,
            screenSize.width * 0.295,
            0,
            screenSize.width * 0.19,
            screenSize.height * 0.29),
        _buildCutPiece(
            'assets/images/dotgame_easy/watermelon2_4.png',
            screenSize.height * 0.558,
            screenSize.width * 0.49,
            0,
            screenSize.width * 0.19,
            screenSize.height * 0.29),
      ],
    );
  }
}

class Level3Widget extends StatefulWidget {
  final VoidCallback onLevelComplete;

  const Level3Widget({Key? key, required this.onLevelComplete})
      : super(key: key);

  @override
  _Level3WidgetState createState() => _Level3WidgetState();
}

class _Level3WidgetState extends State<Level3Widget> {
  bool showTutorial = true;

  late List<Offset?> dots;
  List<Offset?> draggedDots = [];
  late Size screenSize;
  late Rect watermelonBounds;
  late Rect ellipseBounds; // พื้นที่วงรีสำหรับลากจุดลงไป
  final GlobalKey plateKey = GlobalKey();
  bool hasCompletedLevel = false; // ตัวตรวจสอบสถานะว่าเลเวลนี้จบหรือยัง

// เพิ่มรายการตำแหน่งของจุดเป็นค่าสัดส่วน
  final List<Offset> dotPositions = [
    const Offset(0.271, -0.06), // ตัวอย่างค่า x และ y เป็นสัดส่วนของหน้าจอ
    const Offset(0.52, -0.06),
    const Offset(0.15, 0.070),
    const Offset(0.39, 0.15),
    const Offset(0.64, 0.070),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;

    // กำหนดพื้นที่ของแตงโม
    double watermelonWidth = screenSize.width * 0.53;
    double watermelonHeight = screenSize.height * 0.8;
    watermelonBounds = Rect.fromLTWH(
      screenSize.width * 0.025, // left
      screenSize.height * 0.25, // top
      watermelonWidth, // width
      watermelonHeight, // height
    );

    // คำนวณตำแหน่งจริงของจุดบนแตงโม
    dots = List<Offset?>.generate(dotPositions.length, (index) {
      return Offset(
        watermelonBounds.left + watermelonBounds.width * dotPositions[index].dx,
        watermelonBounds.top + watermelonBounds.height * dotPositions[index].dy,
      );
    });

    // กำหนดขนาดของจุดและจุดขณะลาก
    dotRadius = screenSize.width * 0.03;
    feedbackDotRadius = screenSize.width * 0.04;

    // กำหนดรายการ draggedDots ให้มีขนาดเท่ากับ dots
    draggedDots = List<Offset?>.filled(dots.length, null);
    // กำหนดพื้นที่วงรีให้ครอบคลุมจาน
    ellipseBounds = Rect.fromLTWH(
      screenSize.width * 0.48, // left
      screenSize.height * 0.43, // top
      screenSize.width * 0.45, // width
      screenSize.height * 0.23, // height
    );
  }

  late double dotRadius;
  late double feedbackDotRadius;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // รูปภาพจานที่อยู่ด้านขวา
        Positioned(
          right: screenSize.width * 0.03,
          bottom: screenSize.height * 0.23,
          child: SizedBox(
            width: screenSize.width * 0.5,
            height: screenSize.height * 0.4,
            child: DragTarget<int>(
              key: plateKey,
              onAcceptWithDetails: (details) {
                setState(() {
                  final Offset droppedPosition = details.offset;
                  final int? index = details.data;
                  debugPrint('Accepted index: $index at $droppedPosition');

                  if (index != null &&
                      index >= 0 &&
                      index < dots.length &&
                      _isWithinEllipse(droppedPosition)) {
                    // ✅ เล่นเสียงเมื่อนำ dot ไปวางบนจานสำเร็จ
                    BackgroundAudioManager().playBackMelonSeedSound();

                    // คำนวณตำแหน่งใหม่ให้อยู่ในขอบเขตวงรี
                    final RenderBox renderBox = plateKey.currentContext!
                        .findRenderObject() as RenderBox;
                    final Offset localPosition =
                        renderBox.globalToLocal(details.offset);
                    debugPrint('Dropped at: $localPosition');
                    debugPrint('Ellipse bounds: $ellipseBounds');

                    // คำนวณตำแหน่งสัมพัทธ์ในพื้นที่วงรี
                    final double relativeX =
                        (localPosition.dx - ellipseBounds.left) /
                            ellipseBounds.width;
                    final double relativeY =
                        (localPosition.dy - ellipseBounds.top) /
                            ellipseBounds.height;

                    // อัปเดตตำแหน่งของจุดที่ลากไปวาง
                    draggedDots[index] = Offset(
                      ellipseBounds.left + relativeX * ellipseBounds.width,
                      ellipseBounds.top + relativeY * ellipseBounds.height,
                    );

                    debugPrint(
                        'Calculated position in ellipse bounds for dot $index: ${draggedDots[index]}');

                    dots[index] = null;
                  }

                  if (!draggedDots.contains(null) && !hasCompletedLevel) {
                    hasCompletedLevel = true;
                    widget.onLevelComplete();
                  }
                });
              },
              builder: (context, candidateData, rejectedData) {
                debugPrint('Current draggedDots: $draggedDots');
                return Stack(
                  children: [
                    Image.asset(
                      'assets/images/dotgame_easy/plate.png',
                      width: screenSize.width * 0.7,
                      height: screenSize.height * 0.7,
                      fit: BoxFit.contain,
                    ),
                    ..._buildDroppedDots(),
                  ],
                );
              },
            ),
          ),
        ),
        // CustomPaint(
        //   painter: EllipseDebugPainter(bounds: ellipseBounds),
        //   size: Size(screenSize.width, screenSize.height),
        // ),

        // รูปภาพแตงโมที่มุมซ้ายล่าง
        Positioned(
          left: watermelonBounds.left,
          top: watermelonBounds.top,
          child: SizedBox(
            width: watermelonBounds.width,
            height: watermelonBounds.height,
            child: Stack(
              children: [
                IgnorePointer(
                  ignoring: true,
                  child: Image.asset(
                    'assets/images/dotgame_easy/watermelon3.png',
                    fit: BoxFit.contain,
                  ),
                ),
                ..._buildDraggableDots(),
              ],
            ),
          ),
        ),
        // ปุ่ม Info สำหรับเปิด TutorialWidget
        Positioned(
          bottom: screenSize.height * 0.05,
          right: screenSize.width * 0.05,
          child: FloatingActionButton(
              onPressed: () {
                BackgroundAudioManager().playButtonClickSound();
                setState(() {
                  showTutorial = true; // เปิด TutorialWidget
                });
              },
              backgroundColor: Colors.white.withOpacity(0),
              elevation: 0,
              hoverElevation: 0,
              focusElevation: 0,
              highlightElevation: 0,
              child: Image.asset('assets/images/HintButton.png')),
        ),
        if (showTutorial) _buildTutorialWidget(), // แสดงวิดเจ็ตการสอนเล่น
      ],
    );
  }

  // ตรวจสอบว่าตำแหน่งอยู่ในพื้นที่วงรีหรือไม่
  bool _isWithinEllipse(Offset position) {
    final Offset center = Offset(
      ellipseBounds.left + ellipseBounds.width / 2,
      ellipseBounds.top + ellipseBounds.height / 2,
    );

    final double dx = (position.dx - center.dx) / (ellipseBounds.width / 2);
    final double dy = (position.dy - center.dy) / (ellipseBounds.height / 2);

    return (dx * dx + dy * dy) <= 1.0;
  }

  Widget _buildTutorialWidget() {
    BackgroundAudioManager().playButtonClickSound();
    return GestureDetector(
      onTap: () {
        setState(() {
          BackgroundAudioManager().playButtonClickSound();
          showTutorial = false; // ปิดวิดเจ็ตเมื่อผู้ใช้คลิก
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 1,
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.7,
              child: Image.asset(
                //แก้รูปภาพการสอน
                'assets/images/Hint2.png', // รูปภาพการสอน
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // สร้างจุดที่ลากได้บนแตงโม พร้อมตรวจสอบให้อยู่ในขอบเขต
  List<Widget> _buildDraggableDots() {
    return List<Widget>.generate(dots.length, (index) {
      if (dots[index] != null) {
        return Positioned(
          left: dots[index]!.dx,
          top: dots[index]!.dy,
          child: Draggable<int>(
            data: index,
            feedback: CircleAvatar(
              radius: feedbackDotRadius,
              backgroundColor: Colors.black.withOpacity(0.8),
            ),
            childWhenDragging: CircleAvatar(
              radius: dotRadius,
              backgroundColor:
                  const Color.fromARGB(255, 255, 159, 152).withOpacity(0.4),
            ),
            child: CircleAvatar(
              radius: dotRadius,
              backgroundColor: Colors.black,
            ),

            // ✅ เล่นเสียงเมื่อลาก dot
            onDragStarted: () {
              BackgroundAudioManager().playMelonSeedSound();
            },

            // ✅ เล่นเสียงเมื่อลากเมล็ดแตงโมแล้ว "ปล่อยผิดที่" (นอกจาน)
            onDragEnd: (details) {
              if (!_isWithinEllipse(details.offset)) {
                BackgroundAudioManager().playBackMelonSeedSound();
              }
            },
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  // สร้างจุดที่ถูกลากและวางบนจาน
  List<Widget> _buildDroppedDots() {
    return List<Widget>.generate(draggedDots.length, (index) {
      if (draggedDots[index] != null) {
        debugPrint('Dragged dot $index: ${draggedDots[index]}');
        return Positioned(
          left: draggedDots[index]!.dx,
          top: draggedDots[index]!.dy,
          child: CircleAvatar(
            radius: dotRadius - 2,
            backgroundColor: Colors.black,
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}

// Painter สำหรับ Debug พื้นที่วงรี
class EllipseDebugPainter extends CustomPainter {
  final Rect bounds;

  EllipseDebugPainter({required this.bounds});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawOval(bounds, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DashedLinePainter extends CustomPainter {
  final bool isVertical;
  final bool isHorizontal;
  final int lineCount;
  final Offset verticalLinePosition;
  final Offset horizontalLinePosition;
  final double dashLength;
  final double dashSpacing;
  final double strokeWidth;
  final Color color;
  final Color strokeColor;
  final double startX;
  final double endX;
  final double startY;
  final double endY;
  final List<bool> dashedLinesCrossed;

  DashedLinePainter({
    required this.isVertical,
    this.isHorizontal = false,
    this.lineCount = 1,
    required this.verticalLinePosition,
    required this.horizontalLinePosition,
    this.dashLength = 10.0,
    this.dashSpacing = 8.0,
    this.strokeWidth = 3.0,
    this.color = Colors.white,
    this.strokeColor = Colors.black,
    this.startX = 0.0,
    this.endX = 0.0,
    this.startY = 0.0,
    this.endY = 0.0,
    required this.dashedLinesCrossed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isVertical) {
      for (int i = 0; i < lineCount; i++) {
        // ใช้ dashedLinesCrossed[i] สำหรับเส้นแนวตั้งแต่ละเส้น
        Color currentLineColor = dashedLinesCrossed[i] ? Colors.green : color;

        final paint = Paint()
          ..color = currentLineColor
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        final strokePaint = Paint()
          ..color = strokeColor
          ..strokeWidth = strokeWidth + 6.0
          ..strokeCap = StrokeCap.round;

        double offsetX = verticalLinePosition.dx +
            i * 120.0; // ปรับระยะห่างระหว่างเส้นตามต้องการ
        double currentY = startY;

        while (currentY < endY) {
          // วาด Stroke สีดำก่อน
          canvas.drawLine(
            Offset(offsetX, currentY),
            Offset(offsetX, currentY + dashLength),
            strokePaint,
          );
          // วาดเส้นปะ
          canvas.drawLine(
            Offset(offsetX, currentY),
            Offset(offsetX, currentY + dashLength),
            paint,
          );
          currentY += dashLength + dashSpacing;
        }
      }
    }

    if (isHorizontal) {
      for (int i = 0; i < lineCount; i++) {
        // ใช้ dashedLinesCrossed[i] สำหรับเส้นแนวนอนแต่ละเส้น
        // ในกรณีนี้ คุณอาจต้องปรับดัชนีของ dashedLinesCrossed ให้ถูกต้อง
        int index = isVertical ? i + lineCount : i;
        Color currentLineColor =
            dashedLinesCrossed[index] ? Colors.green : color;

        final paint = Paint()
          ..color = currentLineColor
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        final strokePaint = Paint()
          ..color = strokeColor
          ..strokeWidth = strokeWidth + 6.0
          ..strokeCap = StrokeCap.round;

        double offsetY = horizontalLinePosition.dy +
            i * 50.0; // ปรับระยะห่างระหว่างเส้นตามต้องการ
        double currentX = startX;

        while (currentX < endX) {
          // วาด Stroke สีดำก่อน
          canvas.drawLine(
            Offset(currentX, offsetY),
            Offset(currentX + dashLength, offsetY),
            strokePaint,
          );
          // วาดเส้นปะ
          canvas.drawLine(
            Offset(currentX, offsetY),
            Offset(currentX + dashLength, offsetY),
            paint,
          );
          currentX += dashLength + dashSpacing;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DebugDashedLineRectPainter extends CustomPainter {
  final List<Rect> rects;

  DebugDashedLineRectPainter(this.rects);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const ui.Color.fromARGB(255, 8, 255, 45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (var rect in rects) {
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
