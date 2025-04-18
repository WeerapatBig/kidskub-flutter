import 'dart:async';
import 'dart:math';
import 'package:firstly/function/background_audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

import '../screens/shared_prefs_service.dart';
import '../widgets/progressbar_dothard.dart';
import '../widgets/result_widget.dart';

class Dot {
  final Offset position;
  final double size;
  final Color color;

  Dot({required this.position, required this.size, required this.color});
}

class DotGameHard extends StatefulWidget {
  const DotGameHard({
    super.key,
  });

  @override
  State<DotGameHard> createState() => _DotGameHardState();
}

class _DotGameHardState extends State<DotGameHard>
    with TickerProviderStateMixin {
  final prefsService = SharedPrefsService();
  int timeLeft = 180;
  bool showResult = false;
  bool isWin = false;
  bool showTutorial = true; // แสดง TutorialWidget เริ่มต้น
  bool showScrollHint = true; // แสดงข้อไอคอนบอกทางไป

  late Timer _timer;
  late Timer _hintTimer;
  int starCount = 3;
  late AnimationController _hintAnimationController;
  late Animation<double> _hintAnimation;
  late ConfettiController _confettiController;

  final TransformationController _transformationController =
      TransformationController();
  bool showLeftArrow = false; // แสดงลูกศรไปทางซ้าย
  bool showRightArrow = true; // แสดงลูกศรไปทางขวา
  late AnimationController _arrowAnimationController;
  late Animation<Offset> _arrowSlideAnimation;

  late AnimationController _popupAnimationController; // Animation สำหรับ Popup
  late Animation<Offset> _popupSlideAnimation;
  List<Color> collectedDots = []; // สีของจุดที่เก็บได้

  List<Dot> seeds = [
    Dot(position: const Offset(0.165, 0.66), size: 60, color: Colors.white),
    Dot(position: const Offset(0.860, 0.920), size: 88, color: Colors.white),
    Dot(
        position: const Offset(0.16, 0.240),
        size: 90,
        color: const Color.fromARGB(255, 255, 204, 102)),
    Dot(
        position: const Offset(0.715, 0.725),
        size: 80,
        color: const Color.fromARGB(255, 255, 102, 0)),
    Dot(
        position: const Offset(0.438, 0.935),
        size: 80,
        color: const Color.fromARGB(255, 209, 53, 53)),
    Dot(
        position: const Offset(0.528, 0.85),
        size: 50,
        color: const Color.fromARGB(255, 220, 152, 128)),
    Dot(
        position: const Offset(0.27, 0.52),
        size: 90,
        color: const Color.fromARGB(255, 250, 24, 69)),
    Dot(
        position: const Offset(0.99, 0.2),
        size: 90,
        color: const Color.fromARGB(255, 102, 204, 255)),
  ];

  late List<bool> foundSeeds;
  int? hintIndex;

  // เพิ่มตัวแปรสำหรับ Widget "3 2 1 Go"
  bool _showCountdown = false;
  late AnimationController _countdownAnimationController;
  late Animation<double> _countdownAnimation;
  int _currentCountdown = 3;

  bool hasStartedCountdown = false;

  bool scrollSoundCooldown = false; // ป้องกันเสียงเล่นซ้ำถี่เกินไป

  @override
  void initState() {
    super.initState();
    // เล่นเสียง HintButtonSound ตอนที่ TutorialWidget เปิดขึ้นมาตอนแรก
    BackgroundAudioManager().playHintButtonSound();
    foundSeeds = List<bool>.filled(seeds.length, false);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    // Popup Animation
    _popupAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _popupSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0), // เริ่มจากด้านบนจอ
      end: Offset.zero, // ตำแหน่งที่แสดงผล
    ).animate(CurvedAnimation(
      parent: _popupAnimationController,
      curve: Curves.easeOut,
    ));

    _hintAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _hintAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.5)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.5, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_hintAnimationController);

    // เริ่มต้น Animation สำหรับ Countdown
    _countdownAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _countdownAnimation = Tween<double>(begin: 1.5, end: 1.0)
        .chain(CurveTween(curve: Curves.bounceOut))
        .animate(_countdownAnimationController);

    // Animation สำหรับลูกศรชี้
    _arrowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _arrowSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0), // ลูกศรเลื่อนขวาเล็กน้อย
    ).animate(
      CurvedAnimation(
        parent: _arrowAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _arrowAnimationController.repeat(reverse: true); // ทำซ้ำไป-กลับ

    // เริ่มต้น Countdown
    //_startCountdown();
  }

  @override
  void dispose() {
    _timer.cancel();
    _hintTimer.cancel();
    _confettiController.dispose();
    _hintAnimationController.dispose();
    _popupAnimationController.dispose();
    _countdownAnimationController.dispose();
    _arrowAnimationController.dispose();
    _transformationController.dispose();
    BackgroundAudioManager().stopAllSounds();
    super.dispose();
  }

  void _finishGame() async {
    // บันทึกข้อมูลของด่านปัจจุบัน
    await prefsService.saveLevelData('Dot Hard', starCount, 'yellow', true);

// ปลดล็อคด่านถัดไป
    await prefsService.updateLevelUnlockStatus('Dot Hard', 'Dot Quiz');

    // ตรวจสอบข้อมูลที่บันทึก
    final result = await prefsService.loadLevelData('Dot Hard');
    print("Saved Level Data: $result");

    // กลับไปยังหน้าเลือกเกม
    Navigator.pop(context);
  }

  void _checkScrollEdges() {
    final matrix = _transformationController.value;
    final xTranslation = matrix.getTranslation().x; // ตำแหน่งการเลื่อนในแกน X

    setState(() {
      // ตรวจสอบการเลื่อนถึงขอบซ้าย
      if (xTranslation >= 0) {
        showLeftArrow = false;
        showRightArrow = true;
      }
      // ตรวจสอบการเลื่อนถึงขอบขวา
      else if (xTranslation <= -3000) {
        // ตัวอย่าง: ความกว้างของฉาก -3000
        showRightArrow = false;
        showLeftArrow = true;
      }
      // กรณีที่ยังเลื่อนได้ทั้งสองฝั่ง
      else {
        showLeftArrow = true;
        showRightArrow = true;
      }
      // เล่นเสียง Scroll แต่ต้องรอ cooldown ก่อน
      if (!scrollSoundCooldown) {
        scrollSoundCooldown = true; // เปิด cooldown
        BackgroundAudioManager().playScrollScreenDotHSound(); // เล่นเสียง

        // ตั้งหน่วงให้เสียงเล่นได้อีกครั้งหลังจาก 500 มิลลิวินาที
        Future.delayed(const Duration(milliseconds: 800), () {
          scrollSoundCooldown = false; // ปลด cooldown
        });
      }
    });
  }

  void _startCountdown() {
    BackgroundAudioManager().playCountdownSound(); // เรียกใช้งานเสียงนับถอยหลัง

    setState(() {
      _showCountdown = true; // เริ่มแสดง Countdown
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentCountdown > 0) {
        _countdownAnimationController.forward(from: 0.0);
        setState(() {
          _currentCountdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _showCountdown = false;
        });
        _startGame();
        _showPopup();
      }
    });
  }

  void _startGame() {
    // เล่นเสียงจับเวลาตั้งแต่เริ่มต้น
    BackgroundAudioManager().playTickingClockSound();

    // เริ่มต้น Timer เพื่ออัปเดตเวลาและดาวแบบเรียลไทม์
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
          // อัปเดตจำนวนดาวแบบเรียลไทม์ตามเวลาที่เหลือ
          if (timeLeft >= 115) {
            starCount = 3;
          } else if (timeLeft >= 70) {
            starCount = 2;
          } else if (timeLeft >= 25) {
            starCount = 1;
          } else {
            starCount = 0;
          }
        });
      } else {
        _endGame(false);
      }
    });

    _startHintCooldown();
  }

  void _onTap(Offset tapPosition, double imageWidth, double imageHeight) {
    if (_showCountdown) return;
    bool hit = false;

    for (int i = 0; i < seeds.length; i++) {
      if (!foundSeeds[i]) {
        Offset seedPosition = Offset(
          seeds[i].position.dx * imageWidth,
          seeds[i].position.dy * imageHeight,
        );

        if ((tapPosition - seedPosition).distance < seeds[i].size / 2) {
          setState(() {
            foundSeeds[i] = true;
            collectedDots.add(seeds[i].color);
          });
          hit = true;

          // เพิ่มเสียงคลิกเมื่อแตะจุดสำเร็จ
          BackgroundAudioManager().playClickDotSound();

          _showPopup();
          break;
        }
      }
    }

    setState(() {
      if (!hit) {
        timeLeft -= 5;
      }

      if (foundSeeds.every((found) => found)) {
        _endGame(true);
      }
    });
  }

  void _showPopup() async {
    BackgroundAudioManager()
        .playSlideDownSound(); // เล่นเสียงเมื่อ Popup เลื่อนลงมา
    _popupAnimationController.forward(); // แสดง popup

    await Future.delayed(const Duration(seconds: 2)); // รอ 3 วินาที

    BackgroundAudioManager()
        .playSlideUpSound(); // เล่นเสียงเมื่อ Popup เลื่อนกลับขึ้นไป
    _popupAnimationController.reverse(); // ซ่อน popup
  }

  void _endGame(bool isWin) {
    _timer.cancel();
    _hintTimer.cancel();

    // หยุดเสียงทั้งหมดเมื่อจบด่าน
    BackgroundAudioManager().stopAllSounds();

    if (isWin) {
      _confettiController.play();
    }

    setState(() {
      this.isWin = isWin; // เก็บผลลัพธ์ของเกม
      showResult = true; // แสดง ResultWidget
    });
  }

  Widget _buildProcressBar(BuildContext context, int starCount) {
    Size screenSize = MediaQuery.of(context).size;

    return // ProgressBar Widget ด้านล่าง
        Positioned(
      bottom: screenSize.height * 0.05,
      left: screenSize.width * 0.01,
      child: ProgressBarDotHardWidget(
        getStars: starCount,
        remainingTime: timeLeft,
        onMissedPoint: () {
          setState(() {
            timeLeft -= 5;
          });
        },
      ),
    );
  }

  void _onPressResetButton() {
    // รีเซ็ตสถานะเกม
    _showCountdown = true;
    _currentCountdown = 3;
    timeLeft = 180;
    starCount = 3;
    foundSeeds = List<bool>.filled(seeds.length, false);
    collectedDots.clear();
    showResult = false; // ปิด ResultWidget
    _startCountdown();
    _startHintCooldown();
  }

  void _startHintCooldown() {
    _hintTimer = Timer(const Duration(seconds: 20), () async {
      List<int> availableHints = [];
      for (int i = 0; i < foundSeeds.length; i++) {
        if (!foundSeeds[i]) {
          availableHints.add(i);
        }
      }

      if (availableHints.isNotEmpty) {
        hintIndex = availableHints[Random().nextInt(availableHints.length)];

        await _showHintAnimation(hintIndex!);
        await Future.delayed(const Duration(seconds: 1));
        await _showHintAnimation(hintIndex!);

        setState(() {
          hintIndex = null;
        });
      }

      _startHintCooldown();
    });
  }

  Future<void> _showHintAnimation(int index) async {
    _hintAnimationController.reset();
    await _hintAnimationController.forward();
  }

  Widget _buildSeed(Dot seed, bool isFound, double scaleFactor,
      {bool isHint = false}) {
    return ScaleTransition(
      scale: isFound
          ? const AlwaysStoppedAnimation(1.0)
          : isHint
              ? _hintAnimation
              : const AlwaysStoppedAnimation(1.0),
      child: Container(
        width: seed.size * scaleFactor,
        height: seed.size * scaleFactor,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isFound ? Colors.transparent : seed.color,
          border: isFound ? null : Border.all(color: Colors.black, width: 2.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          // เลเยอร์พื้นหลังและเลื่อนภาพ
          LayoutBuilder(
            builder: (context, constraints) {
              double screenHeight = constraints.maxHeight;
              double imageWidth = 6500 * (screenHeight / 1000);

              return InteractiveViewer(
                constrained: false,
                transformationController: _transformationController,
                onInteractionUpdate: (details) {
                  _checkScrollEdges();
                },
                child: SizedBox(
                  width: imageWidth,
                  height: screenHeight,
                  child: GestureDetector(
                    onTapDown: (details) {
                      final tapPosition = details.localPosition;
                      _onTap(tapPosition, imageWidth, screenHeight);
                    },
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/images/dotgamehard/bgscreen.png',
                          width: imageWidth + 110,
                          height: screenHeight + 50,
                          fit: BoxFit.cover,
                        ),
                        for (int i = 0; i < seeds.length; i++)
                          Positioned(
                            left: seeds[i].position.dx * imageWidth -
                                (seeds[i].size * (screenHeight / 1200)) / 2,
                            top: seeds[i].position.dy * screenHeight -
                                (seeds[i].size * (screenHeight / 1200)) / 2,
                            child: _buildSeed(
                              seeds[i],
                              foundSeeds[i],
                              constraints.maxHeight / 1200,
                              isHint: i == hintIndex,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // ลูกศรแอนิเมชันด้านขวา
          if (showRightArrow)
            Positioned(
              right: screenWidth * 0.05,
              top: screenHeight * 0.4,
              child: SlideTransition(
                position: _arrowSlideAnimation,
                child: Icon(
                  Icons.keyboard_double_arrow_right_rounded,
                  size: screenWidth * 0.08,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          if (showLeftArrow)
            Positioned(
              left: screenWidth * 0.05,
              top: screenHeight * 0.4,
              child: SlideTransition(
                position: _arrowSlideAnimation,
                child: Icon(
                  Icons.keyboard_double_arrow_left_rounded,
                  size: screenWidth * 0.08,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          // Popup แจ้งเตือน
          SlideTransition(
            position: _popupSlideAnimation,
            child: Container(
              width: screenWidth * 3,
              height: screenHeight * 0.18,
              margin: const EdgeInsets.symmetric(horizontal: 300),
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/dotgamehard/bgpopup.png'),
                  fit: BoxFit.contain,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(8, (index) {
                  // เช็คสถานะจุดเก็บ
                  final isCollected = index < collectedDots.length;

                  return SizedBox(
                    width: 55,
                    height: 55,
                    child: isCollected
                        ? Container(
                            // ถ้าจุดถูกเก็บแล้ว ให้แสดงเป็นสีของจุดนั้น
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: collectedDots[index],
                              border: Border.all(
                                color: Colors.black,
                                width: 4.2,
                              ), // สีของจุดที่เก็บได้
                            ),
                          )
                        : CustomPaint(
                            // ถ้าจุดยังไม่ได้เก็บ แสดงเส้นปะวงกลม
                            painter: DashedCirclePainter(
                              screenWidth: MediaQuery.of(context).size.width,
                              screenHeight: MediaQuery.of(context).size.height,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent, // โปร่งใส
                                border: Border.all(
                                  color: Colors
                                      .transparent, // ขอบสีเทาสำหรับจุดที่ยังไม่ได้เก็บ
                                  width: 4.2,
                                ),
                              ),
                            ),
                          ),
                  );
                }),
              ),
            ),
          ),

          _buildProcressBar(context, starCount),

          // ปุ่ม Info สำหรับเปิด TutorialWidget
          Positioned(
            bottom: screenHeight * 0.05,
            right: screenWidth * 0.05,
            child: FloatingActionButton(
                onPressed: () {
                  BackgroundAudioManager()
                      .playHintButtonSound(); // เล่นเสียงเมื่อกดปุ่ม Hint
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
          // แสดง TutorialWidget
          if (showTutorial) _buildTutorialWidget(),

          // แสดง ResultWidget เมื่อ showResult เป็น true
          if (isWin && showResult)
            ResultWidget(
              onLevelComplete: isWin,
              starsEarned: starCount,
              onButton1Pressed: () {
                setState(() {
                  _onPressResetButton();
                });
              },
              onButton2Pressed: () {
                _finishGame();
              },
            ),
          if (!isWin && showResult)
            ResultWidget(
              onLevelComplete: isWin,
              starsEarned: starCount,
              onButton1Pressed: () {
                _finishGame();
              },
              onButton2Pressed: () {
                setState(() {
                  _onPressResetButton();
                });
              },
            ),
          // Widget "3 2 1 Go"
          if (_showCountdown) _buildCountdownWidget(),
        ],
      ),
    );
  }

  Widget _buildTutorialWidget() {
    // Widget สำหรับแสดง Tutorial
    return GestureDetector(
      onTap: () {
        BackgroundAudioManager()
            .playCloseHintButtonSound(); // เล่นเสียงเมื่อปิด Tutorial
        setState(() {
          showTutorial = false; // ปิด TutorialWidget
        });

        // ✅ ตรวจสอบว่าเคยเริ่มนับถอยหลังไปแล้วหรือยัง
        if (!hasStartedCountdown) {
          hasStartedCountdown = true;
          _startCountdown(); // เริ่มนับถอยหลังแค่ครั้งแรก
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 1,
        color: Colors.black.withOpacity(0.9), // พื้นหลังโปร่งแสง
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                'assets/images/Hint3.png', // แก้รูปภาพการสอน
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownWidget() {
    // Widget สำหรับแสดง Countdown
    return Container(
      color: Colors.white.withOpacity(0.8),
      child: Center(
        child: ScaleTransition(
          scale: _countdownAnimation,
          child: Text(
            _currentCountdown > 0 ? '$_currentCountdown' : 'Go!',
            style: TextStyle(
              fontSize: 300,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  final double screenWidth;
  final double screenHeight;

  DashedCirclePainter({
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black // สีของเส้นประ
      ..strokeWidth = screenWidth * 0.003 // ความหนาของเส้นตามขนาดหน้าจอ
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double dashWidth = screenWidth * 0.002; // ความยาวของแต่ละเส้นประ
    double dashSpace = screenWidth * 0.35; // ระยะห่างระหว่างเส้นประ
    final double radius = size.width / 2; // รัศมีของวงกลม
    final double circumference = 2 * 3.5 * radius;

    double startAngle = 0.0;
    while (startAngle < circumference) {
      final endAngle = startAngle + (dashWidth / radius);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius),
        startAngle,
        endAngle - startAngle,
        false,
        paint,
      );
      startAngle += (dashWidth + dashSpace) / radius;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
