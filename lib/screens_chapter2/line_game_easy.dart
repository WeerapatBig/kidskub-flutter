import 'dart:ui';
import 'dart:async' as async;
import 'package:firstly/widgets/progressbar_lineeasy.dart';
import 'package:firstly/widgets/result_widget.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../screens/shared_prefs_service.dart';

class DrawLineGameScreen extends StatefulWidget {
  final MinimalLineGame game = MinimalLineGame();

  DrawLineGameScreen({
    super.key,
  });

  @override
  State<DrawLineGameScreen> createState() => _DrawLineGameScreenState();
}

class _DrawLineGameScreenState extends State<DrawLineGameScreen>
    with TickerProviderStateMixin {
  late LineGameController gameController;
  final prefsService = SharedPrefsService();

  bool showResult = false;
  bool isGameWin = false;
  bool showTutorial = false;
  bool hasShownTutorialForLevel2 = false; // เช็คว่าด่าน 2 Tutorial
  bool isHintButtonCooldown = false;
  int cooldownTimeLeft = 5; // ตัวแปรเก็บเวลาคูลดาวน์เริ่มต้น

  double sliderValue = 0; // ค่าเริ่มต้นของ Slider

  late final AnimationController _hintAnimController;
  late Animation<double> _hintScaleAnim;

  void _finishGame() async {
    // บันทึกข้อมูลของด่านปัจจุบัน
    await prefsService.saveLevelData(
        'Line Easy', gameController.starEarned, 'yellow', true);

// ปลดล็อคด่านถัดไป
    await prefsService.updateLevelUnlockStatus('Line Easy', 'Line Hard');

    // ตรวจสอบข้อมูลที่บันทึก
    final result = await prefsService.loadLevelData('Line Easy');
    print("Saved Level Data: $result");

    // กลับไปยังหน้าเลือกเกม
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

    // รีเซ็ต currentLevelIndex ให้เริ่มที่ด่าน 0 ทุกครั้งที่เข้ามาใหม่
    widget.game.currentLevelIndex.value = 0;
    widget.game.targetIndex = 1;
    widget.game.lines.clear(); // เผื่อกรณีเส้นค้าง

    // โหลด hint ของเลเวลใหม่
    widget.game.loadHintImagesForCurrentLevel();
    widget.game.isHintActive = true;
    async.Future.delayed(const Duration(milliseconds: 3500), () {
      widget.game.isHintActive = false;
    });

    widget.game.onUpdateUI = () {
      setState(() {}); // อัปเดต UI
    };
    // สร้าง controller
    gameController = LineGameController(
      onChapterEnd: _onChapterEnd,
    );
    widget.game.gameController = gameController;
    showTutorial = true; // เริ่มด้วยการแสดง Tutorial

    _hintAnimController = AnimationController(
      vsync: this, // ต้องเพิ่ม TickerProviderStateMixin ที่คลาส
      duration: const Duration(milliseconds: 800),
    );

    _hintScaleAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _hintAnimController,
        curve: Curves.easeInOut,
      ),
    );
    _hintAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // ถ้าขยายสุด -> reverse (หด)
        _hintAnimController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        // ถ้าหดสุด -> forward (ขยาย)
        _hintAnimController.forward();
      }
    });

    // เริ่มอนิเมชัน
    _hintAnimController.forward();
  }

  void _onChapterEnd(bool hasWin) {
    print("UI => _onChapterEnd => setState => showResult=true");
    // เรียกเมื่อเกมจบ (timeUp หรือผ่านเงื่อนไข)
    setState(() {
      showResult = true;
      isGameWin = hasWin;
    });
  }

  @override
  void dispose() {
    _hintAnimController.dispose();
    gameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double imageWidth = screenSize.width;
    double imageHeight = screenSize.height;
    double fontSize = screenSize.width * 0.015;

    return ValueListenableBuilder<int>(
        valueListenable: widget.game.currentLevelIndex,
        builder: (context, currentLevel, cjild) {
          int tutorialIndex = (currentLevel == 0 || currentLevel == 1) ? 0 : 1;

          // เช็คว่าถึง Level 2 หรือยัง ถ้าใช่ให้เปิด Tutorial อีกรอบ
          if (currentLevel == 2 && !hasShownTutorialForLevel2) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  showTutorial = true;
                  hasShownTutorialForLevel2 = true;
                });
              }
            });
          }

          return Scaffold(
            body: Stack(
              clipBehavior: Clip.none,
              children: [
                // ----- GameWidget -----
                Positioned.fill(
                  child: GestureDetector(
                    onPanStart: (details) {
                      // เริ่มวาดเส้นใหม่
                      widget.game.startNewLine(details.localPosition);
                    },
                    onPanUpdate: (details) {
                      if (!widget.game.isLineComplete) {
                        // อัปเดตปลายเส้นตามการลากนิ้ว
                        widget.game.updateStraightLine(details.localPosition);
                      }
                    },
                    onPanEnd: (details) {
                      // สิ้นสุดการวาดเส้น
                      if (!widget.game.isLineComplete) {
                        widget.game.finishLine();
                        setState(() {
                          // รีเซ็ต Slider กลับเป็น 0
                          sliderValue = 0;
                        });
                      }
                    },
                    child: GameWidget(
                      game: widget.game,
                    ),
                  ),
                ),

                if (widget.game.isLineComplete)
                  Positioned(
                    right: screenSize.width * 0.13,
                    top: screenSize.height * 0.16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- Slider ---
                        Container(
                          width: imageWidth * 0.05,
                          height: imageHeight * 0.5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            border: Border.all(color: Colors.black, width: 8),
                            borderRadius:
                                BorderRadius.circular(imageWidth * 0.1),
                          ),
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              thumbShape: CustomThumbShape(
                                thumbRadius: imageWidth * 0.028,
                                borderColor: Colors.black, // สีของเส้นรอบนอก
                                borderWidth: 6.0, // ความหนาของเส้นรอบนอก
                              ),
                              thumbColor:
                                  const Color.fromARGB(255, 1, 208, 255),
                              //trackShape: const RectangularSliderTrackShape(),
                              //trackHeight: 80,
                              overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 35),
                              //inactiveTrackColor: Colors.grey.shade300,
                              activeTrackColor: Colors.grey.shade300,
                            ),
                            child: RotatedBox(
                              quarterTurns: 3, // หมุนให้เป็นแนวตั้ง
                              child: Slider(
                                activeColor: Colors.grey.shade300,
                                inactiveColor: Colors.grey.shade300,
                                thumbColor: Color.fromARGB(255, 1, 208, 255),
                                value: sliderValue,
                                min: -5,
                                max: 5,
                                divisions: 10,
                                onChanged: (value) {
                                  setState(() {
                                    sliderValue = value;
                                    widget.game.updateCurve(sliderValue);
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // --- ปุ่มยืนยัน (วงกลม+เครื่องหมายถูก) ---
                        SizedBox(
                          width: imageWidth * 0.09,
                          height: imageHeight * 0.11,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                              shape:
                                  const CircleBorder(), // สีไอคอน/ตัวหนังสือเมื่อกด
                              side: const BorderSide(
                                color: Colors.black,
                                width: 6, // ถ้าต้องการเงา/ขอบเพิ่มเติม ปรับได้
                              ),
                              // ถ้าต้องการเงา/ขอบเพิ่มเติม ปรับได้
                            ),
                            onPressed: () {
                              setState(() {
                                // โค้ดกดปุ่ม => ตรวจเส้น
                                widget.game
                                    .attemptConfirmLine(sliderValue.round());
                              });
                            },
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: screenSize.width * 0.05, // ไอคอนใหญ่หน่อย
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // ----- ปุ่ม Hint (ตัวอย่าง) -----
                Positioned(
                  top: screenSize.height * 0.55, // เว้นระยะจากขอบบน
                  right: screenSize.width * 0.27, // เว้นระยะจากขอบขวา
                  child: GestureDetector(
                    onTap: isHintButtonCooldown
                        ? null
                        : () {
                            setState(() {
                              // สั่งให้ game.isHintActive = true
                              widget.game.showHint();
                              isHintButtonCooldown = true;
                            });
                            // ตั้งเวลาคูลดาวน์
                            async.Timer.periodic(const Duration(seconds: 1),
                                (timer) {
                              setState(() {
                                cooldownTimeLeft -= 1; // ลดเวลาถอยหลัง
                                if (cooldownTimeLeft <= 0) {
                                  timer.cancel(); // หยุดตัวจับเวลา
                                  isHintButtonCooldown = false; // ปลดล็อคปุ่ม
                                  cooldownTimeLeft = 5; // รีเซ็ตเวลาคูลดาวน์
                                }
                              });
                            }); // หลังจาก 5 วินาที -> ปลดล็อคปุ่ม
                          },
                    child: Column(
                      children: [
                        if (isHintButtonCooldown)
                          Text(
                            '$cooldownTimeLeft', // ตัวเลขเวลาถอยหลัง
                            style: TextStyle(
                              color: Colors.white, // สีตัวอักษร
                              fontSize: fontSize, // ขนาดตัวอักษร
                              fontWeight: FontWeight.bold, // ทำตัวอักษรหนา
                            ),
                          ),
                        SizedBox(height: 0),
                        // --- ตรงนี้ปรับเป็น Animated/Pulse ---
                        if (isHintButtonCooldown)
                          // ถ้าอยู่คูลดาวน์ => ใช้รูป inactive ปกติ (ไม่มี animation)
                          Image.asset(
                            'assets/images/linegamelist/hint_button_inactive.png',
                            width: imageWidth * 0.08,
                            height: imageHeight * 0.08,
                          )
                        else
                          // ถ้าไม่คูลดาวน์ => ใส่ ScaleTransition + animation
                          ScaleTransition(
                            scale: _hintScaleAnim, // ใช้อนิเมชันขยาย/หด
                            child: Image.asset(
                              'assets/images/linegamelist/hint_button_active.png',
                              width: imageWidth * 0.08,
                              height: imageHeight * 0.08,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // ----- ปุ่ม FloatingButton Icon ย้อนกลับ -----
                Positioned(
                  top: screenSize.height * 0.05, // ระยะจากขอบบน
                  right: screenSize.width * 0.04, // ระยะจากขอบซ้าย
                  child: FloatingActionButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true, // ปิดเมื่อกดด้านนอก
                        builder: (BuildContext context) =>
                            _buildExitPopUp(context),
                      );
                      gameController.pauseCountdown();
                    },
                    backgroundColor:
                        Colors.white.withOpacity(0), // สีพื้นหลังปุ่ม
                    elevation: 0, // ไม่มีเงา
                    hoverElevation: 0, // ไม่มีเงาเมื่อโฮเวอร์
                    focusElevation: 0, // ไม่มีเงาเมื่อโฟกัส
                    highlightElevation: 0, // ไม่มีเงาเมื่อกด
                    child: Icon(Icons.close_rounded,
                        size: screenSize.width * 0.040,
                        color: Colors.black), // ไอคอน
                  ),
                ),

                ProgressBarLineEasyWidget(
                    remainingTime: gameController.currentTime,
                    maxTime: 120,
                    starCount: gameController.starEarned),

                // ปุ่ม Info สำหรับเปิด TutorialWidget
                Positioned(
                  bottom: screenSize.height * 0.03,
                  right: screenSize.width * 0.03,
                  child: SizedBox(
                    width: screenSize.width * 0.08,
                    height: screenSize.height * 0.11,
                    child: FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            showTutorial = true; // เปิด TutorialWidget
                            gameController.pauseCountdown();
                          });
                        },
                        backgroundColor: Colors.white.withOpacity(0),
                        elevation: 0,
                        hoverElevation: 0,
                        focusElevation: 0,
                        highlightElevation: 0,
                        child: Image.asset(
                          'assets/images/HintButton.png',
                        )),
                  ),
                ),
                // แสดง TutorialWidget
                if (showTutorial)
                  AnimatedOpacity(
                    opacity: showTutorial ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 1000),
                    child: _buildTutorialWidget(tutorialIndex),
                  ),

                // ----- ถ้า showResult => แสดง ResultWidget
                if (showResult && isGameWin)
                  ResultWidget(
                    onLevelComplete: isGameWin, // ตัวอย่าง
                    starsEarned: gameController.starEarned,
                    onButton1Pressed: () {
                      setState(() {
                        showResult = false; // ปิดหน้า Result
                        isGameWin = false; // ถ้าอยากเคลียร์สถานะ UI
                        widget.game.resetGame();
                        gameController.starEarned = 3; // รีเซ็ตดาวที่ได้
                        showTutorial = true; // เปิด TutorialWidget
                        gameController.pauseCountdown();
                      });
                    },
                    onButton2Pressed: () {
                      _finishGame();
                    },
                  ),
                if (showResult && !isGameWin)
                  ResultWidget(
                    onLevelComplete: isGameWin, // ตัวอย่าง
                    starsEarned: gameController.starEarned,
                    onButton1Pressed: () {
                      Navigator.pop(context);
                    },
                    onButton2Pressed: () {
                      setState(() {
                        showResult = false; // ปิดหน้า Result
                        isGameWin = false; // ถ้าอยากเคลียร์สถานะ UI
                        widget.game.resetGame();
                        gameController.starEarned = 3; // รีเซ็ตดาวที่ได้
                        showTutorial = true; // เปิด TutorialWidget
                        gameController.pauseCountdown();
                      });
                    },
                  ),
              ],
            ),
          );
        });
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
                gameController.resumeCountdown();
              },
              child: Image.asset('assets/images/linegamelist/resume_button.png',
                  width: imageWidth * 0.2, height: imageHeight * 0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialWidget(int index) {
    List<String> tutorialImages = [
      'assets/images/linegamelist/tutorial_easy_1.png',
      'assets/images/linegamelist/tutorial_easy_2.png',
    ];
    // Widget สำหรับแสดง Tutorial
    return GestureDetector(
      onTap: () {
        setState(() {
          showTutorial = false; // ปิด TutorialWidget
        });
        gameController.startCountdown(); // เริ่มนับถอยหลัง

        gameController
            .resumeCountdown(); // เริ่มแสดง Countdown หลังปิด Tutorial
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 1,
        color: Colors.black.withOpacity(0.6), // พื้นหลังโปร่งแสง
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.8,
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
                    tutorialImages[index], // แก้รูปภาพการสอน
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

class LineGameController {
  final void Function(bool hasWin) onChapterEnd;
  // ValueNotifier สำหรับเวลาถอยหลัง
  static const int initialTime = 120;
  final ValueNotifier<int> currentTime = ValueNotifier<int>(initialTime);

  // ตัวจับเวลา
  async.Timer? _countdownTimer;
  int remainingTime = initialTime; // เก็บเวลาเมื่อ pause
  bool isPaused = false; // เช็คสถานะ pause

  // ดาวที่ได้
  int starEarned = 3;

  // Callback เรียกเมื่อจบเกม (เพื่อให้ UI จัดการแสดงผล)
  //final VoidCallback onChapterEnd;

  LineGameController({required this.onChapterEnd});

  void startCountdown() {
    if (isPaused) return; // ถ้า paused -> ไม่ต้องเริ่มใหม่
    stopCountdown(); // กันกรณี start ซ้ำ
    _countdownTimer = async.Timer.periodic(const Duration(seconds: 1), (t) {
      if (currentTime.value <= 1) {
        // หมดเวลา
        t.cancel();
        currentTime.value = 0;
        handleEndChapter(isTimeUp: true);
      } else {
        currentTime.value--;
      }
    });
  }

  void stopCountdown() {
    _countdownTimer?.cancel();
  }

  // pause การนับถอยหลัง
  void pauseCountdown() {
    if (_countdownTimer != null) {
      isPaused = true;
      stopCountdown();
      remainingTime = currentTime.value; // เก็บเวลาที่เหลือ
    }
  }

  // resume การนับถอยหลัง
  void resumeCountdown() {
    if (isPaused) {
      isPaused = false;
      currentTime.value = remainingTime; // ดึงค่าที่เหลือกลับมา
      startCountdown();
    }
  }

  // ฟังก์ชันจบ Chapter
  void handleEndChapter({bool isTimeUp = false, int? timeUsed}) {
    print("handleEndChapter => onChapterEnd");
    stopCountdown();
    bool hasWin = !isTimeUp; // ถ้าไม่หมดเวลา => ชนะ

    if (isTimeUp) {
      starEarned = 0;
    } else {
      final used = timeUsed ?? (initialTime - currentTime.value);
      if (used <= 49)
        starEarned = 3;
      else if (used <= 85)
        starEarned = 2;
      else if (used <= 119) starEarned = 1;
    }

    // เรียก callback -> บอกว่าเกมจบแล้ว
    onChapterEnd(hasWin);
  }

  void onAllLevelComplete() {
    print("LineGameController => onAllLevelComplete");
    handleEndChapter(
        isTimeUp: false, timeUsed: initialTime - currentTime.value);
  }

  void dispose() {
    stopCountdown();
    currentTime.dispose();
  }
}

// ---------------------- ตัวเกมที่ลดเหลือเท่าที่จำเป็น ----------------------
class MinimalLineGame extends FlameGame {
  LineGameController? gameController; // เปลี่ยนให้ nullable
  late SpriteComponent background;
  late SpriteComponent hintImage;
  late SpriteComponent hiddenImage;
  ValueNotifier<int> currentLevelIndex = ValueNotifier<int>(0);
  bool isHintActive = false;

  // --- ข้อมูลเลเวลทั้งหมด ---
  final List<LevelData> levels = [
    LevelData(
      points: [
        const Offset(0.4, 0.224), // จุด 0
        const Offset(0.6025, 0.224), // จุด 1
        const Offset(0.6025, 0.558), // จุด 2
        const Offset(0.4, 0.558), // จุด 3
      ],
      requiredCurves: [0, 0, 0, 0], // สมมติว่ามี 2 เส้น => ควรมี 2 ค่าความโค้ง
      loopBack: true, // ยังไม่ปิดลูป
    ),
    LevelData(
      points: [
        const Offset(0.43, 0.571),
        const Offset(0.44, 0.45),
        const Offset(0.39, 0.36),
        const Offset(0.465, 0.32),
        const Offset(0.501, 0.22),
        const Offset(0.54, 0.32),
        const Offset(0.612, 0.36),
        const Offset(0.562, 0.45),
        const Offset(0.575, 0.571),
        const Offset(0.501, 0.52),
      ],
      requiredCurves: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      loopBack: true, // รอบนี้ให้จุดท้ายลากกลับจุดแรก
    ),
    LevelData(
      points: [
        const Offset(0.39, 0.58), // จุด 0
        const Offset(0.39, 0.37), // จุด 1
        const Offset(0.4975, 0.205), // จุด 2
        const Offset(0.6, 0.376), // จุด 3
        const Offset(0.6, 0.58), // จุด 4
      ],
      requiredCurves: [
        0,
        2,
        2,
        0,
        0
      ], // สมมติว่ามี 2 เส้น => ควรมี 2 ค่าความโค้ง
      loopBack: true, // ยังไม่ปิดลูป
    ),
    LevelData(
      points: [
        const Offset(0.473, 0.60), // จุด 0
        const Offset(0.488, 0.53), // จุด 1
        const Offset(0.394, 0.54), // จุด 2
        const Offset(0.395, 0.398), // จุด 3
        const Offset(0.5, 0.205), // จุด 4
        const Offset(0.605, 0.398), // จุด 5
        const Offset(0.608, 0.54), // จุด 6
        const Offset(0.512, 0.53), // จุด 7
        const Offset(0.527, 0.6), // จุด 8
      ],
      requiredCurves: [
        0,
        1,
        1,
        0,
        0,
        1,
        1,
        0,
        0
      ], // สมมติว่ามี 2 เส้น => ควรมี 2 ค่าความโค้ง
      loopBack: true, // ยังไม่ปิดลูป
    ),
  ];
  int targetIndex = 1; // เป้าหมายแรก: จากจุด 0 ไปจุด 1
  final List<Line> lines = []; // เก็บลิสต์ของเส้นทั้งหมด
  bool isLineComplete = false; // สถานะของเส้นที่ "สมบูรณ์" (ลากนิ้วจบแล้ว)
  List<SpriteComponent> congratsStars = []; // เก็บ sprite ดาว

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // พื้นหลัง
    final bgSprite = await loadSprite('linegamelist/gridblue1.png');
    background = SpriteComponent()
      ..sprite = bgSprite
      ..size = size
      ..priority = 0; // **ต่ำสุด**
    add(background);

    // เตรียม spriteComponent
    hintImage = SpriteComponent();
    hiddenImage = SpriteComponent();

    // โหลดรูป hint/hide ของเลเวลแรก
    await loadHintImagesForCurrentLevel();

    // แสดง hintImage ตอนเริ่มเกม
    isHintActive = true;
    async.Future.delayed(const Duration(milliseconds: 3500), () {
      isHintActive = false;
    });
  }

  Future<void> showCongratsSimple() async {
    // 1) คำนวณ "กึ่งกลางจอ"
    final center = Vector2(size.x / 2, size.y / 2);

    // 2) โหลด sprite star (รูป starfull.png)
    final starSprite = await loadSprite('linegamelist/starcongrats.png');

    // 3) สร้าง star component 4 ดวง:
    //    เช่น starSmallLeft, starSmallRight, starBigLeft, starBigRight
    //    เริ่ม position = center
    final smallSize = Vector2(50, 50); // ขนาดรูปเล็ก
    final bigSize = Vector2(80, 80); // ขนาดรูปใหญ่

    final starSmallLeft = SpriteComponent()
      ..sprite = starSprite
      ..size = smallSize
      ..position = center.clone() // เริ่มจากกึ่งกลาง
      ..angle = 0.25
      ..priority = 1; // ให้อยู่ด้านหลัง hintImage (priority=2)

    final starSmallRight = SpriteComponent()
      ..sprite = starSprite
      ..size = smallSize
      ..position = center.clone()
      ..angle = 0.49
      ..priority = 1;

    final starBigLeft = SpriteComponent()
      ..sprite = starSprite
      ..size = bigSize
      ..position = center.clone()
      ..priority = 1;

    final starBigRight = SpriteComponent()
      ..sprite = starSprite
      ..size = bigSize
      ..position = center.clone()
      ..priority = 1;

    // 4) เพิ่มลงในเกม
    add(starSmallLeft);
    add(starSmallRight);
    add(starBigLeft);
    add(starBigRight);
    // **เก็บอ้างอิง** ไว้ใน congratsStars
    congratsStars.add(starSmallLeft);
    congratsStars.add(starSmallRight);
    congratsStars.add(starBigLeft);
    congratsStars.add(starBigRight);

    // 5) คำนวณจุดปลาย:
    //    สมมติ “รูปเล็กกว่าอยู่ด้านบน 3%” และ “ใหญ่กว่าอยู่ล่าง 5%”
    //    left => x - 3%/5%, right => x + 3%/5%
    //    top => y - 3%/5%, bottom => y + 3%/5%
    final starSmallLeftPos = center + Vector2(-size.x * 0.27, -size.y * 0.46);
    final starSmallRightPos = center + Vector2(size.x * 0.25, -size.y * 0.46);
    final starBigLeftPos = center + Vector2(-size.x * 0.34, -size.y * 0.4);
    final starBigRightPos = center + Vector2(size.x * 0.28, -size.y * 0.4);

    // 6) สร้าง MoveEffect ให้เคลื่อนไปตำแหน่ง
    final dur = 1.0; // 1 วินาที

    starSmallLeft.add(MoveEffect.to(
      starSmallLeftPos,
      EffectController(duration: dur, curve: Curves.easeOut),
    ));
    starSmallRight.add(MoveEffect.to(
      starSmallRightPos,
      EffectController(duration: dur, curve: Curves.easeOut),
    ));
    starBigLeft.add(MoveEffect.to(
      starBigLeftPos,
      EffectController(duration: dur, curve: Curves.easeOut),
    ));
    starBigRight.add(MoveEffect.to(
      starBigRightPos,
      EffectController(duration: dur, curve: Curves.easeOut),
    ));

    // ผล: ดาวสี่ดวงจะวิ่งจาก center => ตำแหน่ง => หยุด
  }

  Future<void> loadHintImagesForCurrentLevel() async {
    final levelNum = currentLevelIndex.value + 1;
    // ตัวอย่างชื่อไฟล์ => "linegamelist/level1.png"
    final hintFile = "linegamelist/level$levelNum.png";
    final hideFile = "linegamelist/level${levelNum}_hide.png";

    // ลบของเก่า
    hintImage.removeFromParent();
    hiddenImage.removeFromParent();

    final hintSprite = await loadSprite(hintFile);
    final hideSprite = await loadSprite(hideFile);

    // คำนวณขนาด
    final desiredWidth = size.x * 0.5;
    final ratio = 762 / 531;
    final newWidth = desiredWidth;
    final newHeight = newWidth / ratio;
    final posX = (size.x - newWidth) / 2;
    final posY = size.y * 0.115;

    hintImage
      ..sprite = hintSprite
      ..size = Vector2(newWidth, newHeight)
      ..position = Vector2(posX, posY)
      ..priority = 2;

    hiddenImage
      ..sprite = hideSprite
      ..size = Vector2(newWidth, newHeight)
      ..position = Vector2(posX, posY)
      ..priority = 2;

    // // เริ่มต้นแสดง hintImage
    // add(hintImage);

    // // ถ้าต้องการสลับเป็น hide หลัง 5 วิ:
    // async.Future.delayed(const Duration(seconds: 5), () {
    //   hintImage.removeFromParent();
    //   add(hiddenImage);
    // });
  }

  @override
  void update(double dt) {
    super.update(dt);
    // ควบคุมการแสดงผลของ hintImage และ hiddenImage
    if (isHintActive) {
      if (hintImage.parent == null) {
        add(hintImage);
        hiddenImage.removeFromParent();
      }
    } else {
      if (hiddenImage.parent == null) {
        add(hiddenImage);
        hintImage.removeFromParent();
      }
    }
  }

  Future<void> showHint() async {
    // เรียกใช้เมื่อกดปุ่ม Hint
    isHintActive = true;
    await Future.delayed(const Duration(milliseconds: 5400), () {
      isHintActive = false;
    });
  }

  List<Offset> getScaledPoints(Size screenSize, List<Offset> points) {
    return points
        .map((point) =>
            Offset(point.dx * screenSize.width, point.dy * screenSize.height))
        .toList();
  }

  double currentSliderValue = 0;

  LevelData get currentLevel => levels[currentLevelIndex.value];
  List<Offset> get points => currentLevel.points;
  List<int> get requiredCurves => currentLevel.requiredCurves;
  bool get loopBack => currentLevel.loopBack;

  void pullBackLine(Line line) {
    if (line.isLocked) {
      print("Line locked => cannot pullBack");
      return;
    }
    final effect = CustomPullBackEffect(
      line: line,
      from: line.end,
      to: line.start,
      controller: EffectController(duration: 1.0, curve: Curves.linear),
    );

    line.add(effect);
    print("PullBackEffect added to line");
  }

  // เริ่มเส้นใหม่
  void startNewLine(Offset screenPoint) {
    // *** ถ้า isPullingBack ยังเป็น true => ไม่อนุญาตให้ลากเส้นใหม่ ***
    if (isLineComplete) return;

    final w = size.x;
    final h = size.y;

    // กรณี loopBack == true และ targetIndex == points.length
    // => จุดเริ่มคือ (points.length -1) [จุดสุดท้าย]
    // => เพื่อจะลากกลับไป point[0]
    final startIndex = (loopBack && targetIndex == points.length)
        ? points.length - 1
        : targetIndex - 1;

    final normalizedPos = points[startIndex];
    final localPos = Offset(normalizedPos.dx * w, normalizedPos.dy * h);

    // ถ้าลากใกล้จุดเริ่มต้น => สร้างเส้นใหม่
    if ((screenPoint - localPos).distance < 40) {
      final newLine = Line(localPos, localPos);
      add(newLine); // เพิ่มเส้นลงในเกม
      lines.add(newLine);
    } else {
      // ถ้าแตะที่อื่น => ไม่ทำอะไร
      // ป้องกันการเริ่ม line ที่ไม่ใช่จุด
    }
  }

  // ระหว่างลาก ขยับปลายเส้น
  void updateStraightLine(Offset dragPoint) {
    if (lines.isNotEmpty && !isLineComplete) {
      final lastLine = lines.last;
      // ถ้าเส้นล่าสุด "locked" => ไม่ยอมให้ปรับ end
      if (lastLine.isLocked) {
        return; // ไม่แก้ไข
      }
      // ถ้าไม่ locked => อัปเดตปลายเส้นปกติ
      lastLine.end = dragPoint;
    }
  }

  // เมื่อปล่อยนิ้ว => เช็คทันทีว่าตรงจุดเป้าหมายไหม
  void finishLine() {
    if (lines.isEmpty) return;

    final line = lines.last;

    if (line.isLocked) return;
    final w = size.x;
    final h = size.y;
    final endPixel = line.end;

    if (targetIndex >= points.length + 1) {
      print("All lines connected - finishLine not needed");
      return;
    }

    // กำหนด "จุดเป้าหมาย"
    // ถ้า loopBack=true และ targetIndex == points.length => points[0]
    // ถ้าไม่ใช่ => points[targetIndex]
    Offset? targetPixel;
    if (targetIndex < points.length) {
      // ยังเป็นจุดถัดไปในลิสต์
      final norm = points[targetIndex];
      targetPixel = Offset(norm.dx * w, norm.dy * h);
    } else if (loopBack && targetIndex == points.length) {
      // ลากกลับมายังจุดแรก
      final norm = points[0];
      targetPixel = Offset(norm.dx * w, norm.dy * h);
    } else {
      // เกินจากนี้ => ไม่มีเป้าหมาย
      return;
    }

    // ถ้าลากใกล้เป้าหมาย => ถือว่าถูก
    if ((endPixel - targetPixel).distance < 40) {
      // ลากถึงเป้าหมาย
      line.end = targetPixel;

      // **เช็คความโค้งที่ต้องการ** ถ้า=0 => ยืนยันเลย
      final neededCurve = requiredCurves[targetIndex - 1];
      if (neededCurve == 0) {
        // ข้ามการโชว์ Slider
        print("No curvature required => auto confirm line with 0");
        // เรียก attemptConfirmLine(0) โดยไม่โชว์ slider
        attemptConfirmLine(0);
      } else {
        // ยังต้องปรับโค้ง => ให้ผู้เล่นเห็น slider
        isLineComplete = true;
      }
    } else {
      // ไม่ถึง => pullBack
      line.color = Colors.red;
      pullBackLine(line);
    }
  }

  void Function()? onUpdateUI;

  void attemptConfirmLine(int sliderValue) {
    if (lines.isEmpty) return;
    final currentLine = lines.last;

    // ถ้า line ถูก lock ไปแล้ว -> ไม่ทำอะไร
    if (currentLine.isLocked) return;

    // **ป้องกัน range error**
    // ถ้า targetIndex-1 >= requiredCurves.length => ออกไปเลย
    if (targetIndex - 1 >= requiredCurves.length) return;

    final requiredValue = requiredCurves[targetIndex - 1];

    // ตรวจ
    if (sliderValue == requiredValue) {
      print("Correct curve");
      // correct
      currentLine.color = const Color.fromARGB(255, 153, 235, 72);
      currentLine.isLocked = true; // <--- ล็อกเส้นนี้
      isLineComplete = false;

      // ✅ ถ้าเป็นเส้นสุดท้าย -> หยุดเวลา
      if (targetIndex == points.length) {
        gameController?.pauseCountdown();
      }
      targetIndex++;
      // ตรวจว่านี่เป็นเลเวลสุดท้ายไหม
      if (targetIndex > points.length) {
        gameController?.pauseCountdown;
        if (currentLevelIndex == levels.length - 1) {
          showCongratsSimple();
          async.Future.delayed(const Duration(seconds: 1), () {
            gameController?.onAllLevelComplete();
          });
        } else {
          showCongratsSimple(); //แสดงความยินดีกับผู้เล่น //ใส่เสียงตรงนี้ให้หน่อย
          async.Future.delayed(const Duration(seconds: 3), () {
            // สั่งให้ลบดาว congrat
            for (final star in congratsStars) {
              star.removeFromParent();
            }
            congratsStars.clear();
          });
          async.Future.delayed(const Duration(seconds: 1), () {
            add(FadeOutEffectComponent());
          });
        }
      }
    } else {
      // incorrect
      // เปลี่ยนสี line => แดง
      currentLine.color = Colors.red;
      // ดึงกลับด้วย effect
      pullBackLine(currentLine);
      // ซ่อนสไลด์บาร์
      isLineComplete = false; // รีเซ็ตสถานะ
    }
  }

  // ไปเลเวลถัดไป
  void goToNextLevel() async {
    currentLevelIndex.value++;
    if (currentLevelIndex.value >= levels.length) {
      // จบทุกเลเวล
      print("All Levels are complete!");

      // ถ้า gameController ไม่ใช่ null -> เรียก onAllLevelComplete()
      gameController?.onAllLevelComplete();

      return;
    }

    // ลบเส้นทั้งหมดออกจาก FlameGame
    for (var line in lines) {
      line.removeFromParent(); // ลบ Line ออกจากเกม
    }

    // รีเซ็ตค่าต่าง ๆ เพื่อเริ่มเลเวลใหม่
    lines.clear();
    isLineComplete = false;
    targetIndex = 1;
// โหลดรูป hint/hide ใหม่
    gameController?.resumeCountdown();
    loadHintImagesForCurrentLevel(); // เรียกฟังก์ชันที่เราสร้าง

    await showHint(); // แสดง hint ใหม่

    print("Now start Level ${currentLevelIndex.value + 1}");
  }

  // รีเซ็ตเกมทั้งหมด
  void resetGame() {
    // 1) ลบทุกเส้นที่มี
    for (final line in lines) {
      line.removeFromParent();
    }
    lines.clear();

    //รีเซ็ตการแสดงผลของ starSmallLeft, starSmallRight, starBigLeft, starBigRight
    // 2) ลบดาว congrat
    for (final star in congratsStars) {
      star.removeFromParent();
    }
    congratsStars.clear();

    // 2) รีเซ็ตตัวแปรเกมกลับด่านแรก
    currentLevelIndex.value = 0;
    targetIndex = 1;
    isLineComplete = false;
    isHintActive = false;

    // 3) รีเซ็ต/หยุดนับถอยหลังในตัว controller
    gameController?.stopCountdown();
    gameController?.currentTime.value = LineGameController.initialTime;
    gameController?.startCountdown();

    // 4) โหลดรูป hint/hide ใหม่ของด่านแรก
    loadHintImagesForCurrentLevel(); // => จะโหลด level1.png, level1_hide.png

    // อื่น ๆ เช่น: starEarned = 3, etc.

    print("All game reset => start from level 1");
  }

  // ปรับความโค้งของ "เส้นล่าสุด" ด้วยค่า Slider
  void updateCurve(double sliderValue) {
    currentSliderValue = sliderValue; // จำค่าล่าสุด
    if (lines.isNotEmpty) {
      final currentLine = lines.last;

      // แม็ปค่า -5..5 -> Offset สำหรับความโค้ง
      final offsetMap = {
        -5: -250,
        -4: -200,
        -3: -150,
        -2: -75,
        -1: -50,
        0: 0,
        1: 50,
        2: 75,
        3: 150,
        4: 200,
        5: 250
      };

      currentLine.controlOffset =
          offsetMap[sliderValue.toInt()]?.toDouble() ?? 0;
      currentLine.calculateHandler();
    }
  }

  // ฟังก์ชัน render ของ FlameGame
  @override
  void render(Canvas canvas) {
    final screenSize = size.toSize();

    // แปลงจุดในเลเวลปัจจุบันให้สัมพันธ์กับหน้าจอ
    // วาดพื้นหลังโปร่งใส
    canvas.drawColor(Colors.white, BlendMode.src);
    super.render(canvas);

    final scaledPoints = getScaledPoints(screenSize, currentLevel.points);

    final strokePaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 7;

    // วาดจุดสีแดงทั้ง 3 จุด
    final pointPaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;

    for (var p in scaledPoints) {
      canvas.drawCircle(p, 20, strokePaint);
      canvas.drawCircle(p, 20, pointPaint);
    }

    // วาดเส้น
    for (var line in lines) {
      line.render(canvas);
    }
  }
}

// ---------------------- คลาส Line (Quadratic Bezier) ----------------------
class Line extends PositionComponent {
  bool isLocked = false; // <--- เส้นถูกล็อกเมื่อยืนยัน
  Offset start;
  Offset end;
  Offset? handler; // จุดควบคุมสำหรับ bezier
  double controlOffset = 0; // ระยะ offset จาก midpoint

  // สีเริ่มต้น (ปรับตามต้องการ)
  Color color = Colors.blue;

  Line(this.start, this.end);
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    //print("Line loaded");
  }

  @override
  void onMount() {
    super.onMount();
    //print("Line added to game");
  }

  @override
  void update(double dt) {
    super.update(dt);

    //print("Line updated in game");
  }

  // คำนวณจุด handler ให้อยู่ตั้งฉากเส้นที่ midpoint
  void calculateHandler() {
    final midpoint = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    // เวกเตอร์ตั้งฉาก: (dy, -dx) หรือ (-dy, dx) ก็ได้
    final direction = Offset(end.dy - start.dy, start.dx - end.dx).normalize();
    handler = midpoint + direction * controlOffset;
  }

  // วาดเส้นแบบโค้ง (quadratic bezier) ลงบน canvas
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(
        handler?.dx ?? start.dx,
        handler?.dy ?? start.dy,
        end.dx,
        end.dy,
      );
    canvas.drawPath(path, paint);
  }
}

class PullBackEffect extends Effect with HasGameRef<MinimalLineGame> {
  final Line line;
  final Offset from;
  final Offset to;

  PullBackEffect({
    required this.line,
    required this.from,
    required this.to,
    required EffectController controller,
  }) : super(controller);

  /// **apply(progress)** คือเมธอดบังคับที่ต้อง implement
  /// โดยจะถูกเรียกทุกเฟรม เพื่ออัปเดตสภาพตามค่า progress (0..1)
  @override
  void apply(double progress) {
    print("PullBackEffect progress: $progress"); // Debug
    // คำนวณตำแหน่งใหม่จาก from -> to ตาม progress
    final newEnd = Offset.lerp(from, to, progress);
    if (newEnd != null) {
      line.end = newEnd;
      line.controlOffset = lerpDouble(line.controlOffset, 0, progress) ?? 0;
      line.calculateHandler();
    }
  }

  /// **onFinish()** จะถูกเรียกเมื่อ Effect ทำงานจบ (progress = 1.0)
  @override
  void onFinish() {
    super.onFinish();
    final game = gameRef;
    if (game != null) {
      game.isLineComplete = false; // รีเซ็ตสถานะ
      print("PullBackEffect finished and line removed");
    }
  }
}

class CustomPullBackEffect extends PullBackEffect {
  CustomPullBackEffect({
    required Line line,
    required Offset from,
    required Offset to,
    required EffectController controller,
  }) : super(line: line, from: from, to: to, controller: controller);

  @override
  void onFinish() {
    super.onFinish();
    // Custom logic when the effect finishes
    line.controlOffset = 0;
    line.calculateHandler();
  }
}

// ---------------------- Extension สำหรับ normalize() ----------------------
extension OffsetExtension on Offset {
  Offset normalize() {
    final length = distance;
    return length == 0 ? this : this / length;
  }
}

/// คลาสเก็บข้อมูลของเลเวลแต่ละด่าน
class LevelData {
  final List<Offset> points; // ตำแหน่งจุดทั้งหมดในเลเวล
  final List<int> requiredCurves; // ค่าความโค้งที่ต้องการให้ตรงกับจุด (ออปชัน)
  final bool loopBack; // ถ้า true แปลว่าจุดสุดท้ายต้องลากกลับไปหาจุดแรก

  LevelData({
    required this.points,
    required this.requiredCurves,
    this.loopBack = false,
  });
}

class FadeOutEffectComponent extends RectangleComponent
    with HasGameRef<MinimalLineGame> {
  FadeOutEffectComponent();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ตั้งขนาดให้เต็ม Game
    size = gameRef.size;
    position = Vector2.zero();
    anchor = Anchor.topLeft;
    priority = 3; // สูงสุด

    // เริ่มด้วยสีดำแบบใส
    paint = Paint()..color = Colors.white.withOpacity(0);

    // สร้างเอฟเฟกต์ OpacityEffect
    final fadeOutEffect = OpacityEffect.to(
      1.0, // ค่า opacity สุดท้าย (1 = ทึบสนิท)
      EffectController(
        duration: 1.1, // ระยะเวลา 1 วินาที (ปรับตามต้องการ)
        curve: Curves.easeInOut,
        reverseDuration: 1.25, // ถ้าไม่ต้องการ reverse
      ),
      onComplete: () {
        // เมื่อจบเอฟเฟกต์ -> เปลี่ยนเลเวล
        gameRef.goToNextLevel();

        // ถ้าไม่ต้องการให้สี่เหลี่ยมนี้ค้าง -> ลบทิ้ง
        removeFromParent();
      },
    );

    add(fadeOutEffect);
  }
}

class CustomThumbShape extends RoundSliderThumbShape {
  final double thumbRadius;
  final Color borderColor;
  final double borderWidth;

  CustomThumbShape({
    required this.thumbRadius,
    this.borderColor = Colors.black,
    this.borderWidth = 2.0,
  });

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter? labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // วาดเส้นรอบนอก
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawCircle(center, thumbRadius + (borderWidth / 2), paint);

    // วาด thumb ด้านใน
    final fillPaint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, thumbRadius, fillPaint);
  }
}
