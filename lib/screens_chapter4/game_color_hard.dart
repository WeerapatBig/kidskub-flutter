import 'dart:async';

import 'package:firstly/function/mediaquery_values.dart';
import 'package:firstly/screens/shared_prefs_service.dart';
import 'package:firstly/screens_chapter4/logic/game_color_hard_logic.dart';
import 'package:firstly/screens_chapter4/model/progress_star_bar.dart';
import 'package:firstly/screens_chapter4/model/time_progressbar.dart';
import 'package:firstly/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../widgets/result_widget.dart';
import 'levels/levels_data.dart';
import 'logic/game_color_logic.dart';
import 'model/animated_popup_template.dart';
import 'model/combo_popup.dart';
import 'model/controller_pad.dart';
import 'model/stroke_text.dart';
import 'model/waring_enemy_popup.dart'; // Import ไฟล์ logic

enum AnswerResult { correct, wrong }

class GameColorHardScreen extends StatefulWidget {
  const GameColorHardScreen({super.key});

  @override
  State<GameColorHardScreen> createState() => _GameColorHardScreenState();
}

class _GameColorHardScreenState extends State<GameColorHardScreen> {
  static ColorGame? _game;
  late Level levelData;
  final prefsService = SharedPrefsService();
  static Future<void>? _gameLoaded; // เก็บ Future ที่โหลดเกมไว้

  int currentScore = 0;
  int lastComboCount = 0;
  bool showComboPopup = false;
  bool isBonus = false;
  bool _showResult = false; // บอกว่าแสดง ResultWidget หรือไม่
  int _starCount = 0; // เก็บจำนวนดาวตอนเกมจบ

  bool showTutorial = false;
  bool showWarningImage = false;
  Timer? _pollWarningTimer;
  bool _gameStarted = false; // บอกว่าเริ่มเกมหรือยัง
  int _targetSpawnCount = 0; // ใน State
  Color _currentTargetColor = Colors.blue;
  List<AnswerResult?> targetColorResults = [null, null];

  @override
  void initState() {
    super.initState();
    // ตรวจสอบว่า _gameLoaded เป็น null ไหม ถ้าเป็น null แสดงว่ายังไม่เคยโหลด

    if (_gameLoaded == null) {
      levelData = level2;
      // สร้างเกมด้วย level1
      _game = ColorGameHard(
        levelData,
        onTargetColorChanged: _onTargetColorChanged,
        onScoreChanged: _onScoreChanged, // ใหม่
        onComboChanged: _onComboChanged, // ✅ เพิ่ม
        onGameOver: _handleGameOver, // เพิ่ม callback
        onAnswerEachColorIndex: onAnswerEachColorIndex,
      );
      _gameLoaded = _game!.onLoad();
    }
    if (!_gameStarted) {
      setState(() {
        _game?.pauseGameTime();
        _onGameStarted();
      });
    }
    _game!.bonusNotifier.addListener(_onBonusStateChanged);

    // สร้าง Timer เพื่อเช็กสถานะ _isWarningState เป็นระยะ
    _pollWarningTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted && _game != null) {
        setState(() {
          // สมมติเรามี getter isWarningState => return _isWarningState ใน ColorGame
          // หรือจะเข้าถึงผ่าน _game!._isWarningState ก็ได้ ถ้าตัวแปรเป็น public
          showWarningImage = _game!.isWarningState;
        });
      }
    });
  }

// เมื่อได้รับ onGameOver จาก ColorGame => แสดง ResultWidget
  void _handleGameOver(int starCount) {
    setState(() {
      _showResult = true;
      _starCount = starCount; // ถ้าโดน Enemy => 0
    });
  }

  void _onBonusStateChanged() {
    final isBonusNow = _game!.bonusNotifier.value;
    // เพิ่ม setState เพื่อ trigger UI update
    setState(() {
      isBonus = isBonusNow;
    });
  }

  // ฟังก์ชัน callback ที่จะเรียกเมื่อสีเป้าหมายเปลี่ยน
  void _onTargetColorChanged(Color newColors) {
    setState(() {
      _spawnNewTarget(newColors);
    });
  }

  void onAnswerEachColorIndex(int index, bool isCorrect) {
    Future.microtask(() {
      if (isCorrect) {
        targetColorResults[index] = AnswerResult.correct;
        // กรณีอยากค้าง => ไม่เซต timer ลบ
      } else {
        if (targetColorResults[index] != AnswerResult.correct) {
          targetColorResults[index] = AnswerResult.wrong;
          // ตั้ง Timer 1 วิ ให้กลับเป็น null (ลบภาพ)
          Future.delayed(const Duration(seconds: 1), () {
            if (!mounted) return;
            setState(() {
              // รีเซตเฉพาะถ้าไม่ได้ถูกมาก่อน
              if (targetColorResults[index] != AnswerResult.correct) {
                targetColorResults[index] = null;
              }
            });
          });
        }
      }
    });
  }

  void _spawnNewTarget(Color color) {
    setState(() {
      _targetSpawnCount++;
      _currentTargetColor = color;

      targetColorResults = List.filled(levelData.targetColor.length, null);
    });
  }

  void _onScoreChanged(int newScore) {
    setState(() {
      currentScore = newScore;
    });
  }

  void _onComboChanged(int comboCount) {
    setState(() {
      if (comboCount >= 2) {
        showComboPopup = true;
        lastComboCount = comboCount;

        // ซ่อน popup หลังจาก 1 วินาที
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              showComboPopup = false;
            });
          }
        });
      } else {
        showComboPopup = false;
      }
    });
  }

  void _finishGame() async {
    // บันทึกข้อมูลของด่านปัจจุบัน
    await prefsService.saveLevelData('Color Hard', _starCount, 'yellow', true);

// ปลดล็อคด่านถัดไป
    await prefsService.updateLevelUnlockStatus('Color Hard', '');

    // ตรวจสอบข้อมูลที่บันทึก
    final result = await prefsService.loadLevelData('Color Hard');
    print("Saved Level Data: $result");

    // กลับไปยังหน้าเลือกเกม
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _pollWarningTimer?.cancel();
    _game?.bonusNotifier.removeListener(_onBonusStateChanged); // ✅
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: GameWidget(game: _game!)),
          // ใช้ Positioned แสดง UI ปุ่มควบคุม
          Positioned(
            bottom: context.screenWidth * 0.13,
            right: context.screenHeight * 0.07,
            child: FutureBuilder(
              future: _gameLoaded,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return _buildControllerUI();
                } else {
                  // ระหว่างโหลดเกม ยังไม่ต้องแสดงปุ่ม
                  return const SizedBox();
                }
              },
            ),
          ),
          Positioned(
            top: context.screenHeight * 0.2,
            right: context.screenWidth * 0.03,
            child: _buildTwoTargetColorUI(),
          ),
          // =========== Exit Button =================
          Positioned(
            top: context.screenSize.height * 0.05,
            right: context.screenSize.width * 0.04,
            child: CustomButton(
              onTap: () {
                _game?.pauseGameTime();
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) => _buildExitPopUp(context),
                );
              },
              child: Image.asset(
                'assets/images/close_button.png',
                width: context.screenSize.width * 0.060,
              ),
            ),
          ),

          // ปุ่ม Info สำหรับเปิด TutorialWidget
          Positioned(
            bottom: context.screenSize.height * 0.05,
            right: context.screenSize.width * 0.04,
            child: CustomButton(
              onTap: () {
                setState(() {
                  showTutorial = true; // เปิด TutorialWidget
                  _game?.pauseGameTime();
                });
              },
              child: Image.asset(
                'assets/images/HintButton.png',
                width: context.screenSize.width * 0.060,
              ),
            ),
          ),

          Positioned(
            top: 50,
            left: -10,
            child: _buildScoreUI(),
          ),

          // ตำแหน่งของ ProgressBar
          Positioned(
            bottom: -20,
            left: 0,
            right: 0,
            // ให้ลองปรับแต่งขนาด/ตำแหน่งตามเหมาะสม
            child: Container(
              clipBehavior: Clip.none,
              width: 200,
              height: 280,
              child: TimeProgreesBarWidget(
                remainingTime: _game!.timeNotifier,
                maxTime: 120,
                isAlertNotifier: _game!.bonusNotifier,
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(
                clipBehavior: Clip.none,
                width: 150,
                height: 200,
                child: ProgressStarBar(
                    progress: currentScore / 1000,
                    starCount: _game!.calculateStars(currentScore))),
          ),

          if (showComboPopup)
            Positioned(
              top: context.screenHeight * 0.28,
              left: context.screenWidth * 0.01,
              child: ComboPopup(comboCount: lastComboCount),
            ),

          // ถ้ากำลัง warning => แสดงรูป
          if (showWarningImage)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5), // พื้นหลังมืดเล็กน้อย
                child: const Center(
                  child: PulseWarningImage(
                    imagePath: 'assets/images/colorgame/popup_enemy.png',
                    beginScale: 1.0, // เริ่ม
                    endScale: 1.2, // ขยาย
                    duration: Duration(milliseconds: 400),
                  ),
                ),
              ),
            ),

          if (isBonus && !showWarningImage)
            Positioned(
              top: context.screenHeight * 0.1,
              left: context.screenWidth * 0.16,
              child: Transform.rotate(
                angle: -0.2, // Angle in radians, negative for counterclockwise
                child: const AnimatedPopupTemplate(
                  child: StrokeText(
                    text: "x2",
                    fontSize: 70,
                    strokeWidth: 12,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 249, 72, 59),
                  ),
                ),
              ),
            ),
          //============= Tutorial ================
          if (showTutorial)
            AnimatedOpacity(
              opacity: showTutorial ? 1.0 : 0.0,
              duration: Duration(milliseconds: 1000),
              child: _buildTutorialWidget(),
            ),
          if (_showResult)
            Positioned.fill(
              child: ResultWidget(
                onLevelComplete: true, // สมมติว่าจบเลเวล
                starsEarned: _starCount,
                // ปุ่มใน ResultWidget
                onButton1Pressed: _onRetryPressed,
                onButton2Pressed: _finishGame,
              ),
            ),

          if (_gameStarted)
            Positioned.fill(
              child: _countdownWidget(),
            ),
        ],
      ),
    );
  }

  void _onGameStarted() {
    setState(() {
      _gameStarted = true; // เริ่มเกม
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          _gameStarted = false; // เริ่มเกม
          _game?.resumeGameTime(); // เริ่มเกมจริง
        });
      });
    });
  }

  Widget _countdownWidget() {
    return Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
        ),
        child: Image.asset('assets/images/colorgame/countdown.gif'));
  }

  Widget _buildTutorialWidget() {
    // Widget สำหรับแสดง Tutorial
    return GestureDetector(
      onTap: () {
        setState(() {
          _game?.resumeGameTime(); // หยุดเกมชั่วคราว
          showTutorial = false; // ปิด TutorialWidget
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 1.5,
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
                    'assets/images/shapegame/tutorial_shape_easy.gif', // แก้รูปภาพการสอน
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

  void _onRetryPressed() {
    setState(() {
      _showResult = false;
      currentScore = 0;
      _starCount = 0;
    });

    // เรียกให้เกมรีเซ็ต
    _game?.resetGame();
  }

  Widget _buildTwoTargetColorUI() {
    final key = ValueKey<String>(
        "$_targetSpawnCount-${_currentTargetColor.value.toRadixString(16)}");

    final colors = levelData.targetColor;
    if (colors.length < 2) {
      return const SizedBox();
    }

    return
        //กรอบUI ขาว
        Container(
      width: context.screenWidth * 0.21,
      height: context.screenHeight * 0.21,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black, width: 6),
      ),
      //Object ที่แสดงสีเป้าหมายพร้อม Animation
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1) AnimatedPopupTemplate สำหรับเปลี่ยนสี
          AnimatedPopupTemplate(
            key: key,
            duration: const Duration(milliseconds: 1250),
            beginScale: 0.1,
            endScale: 1.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Circle ด้านซ้าย (index 0)
                Stack(
                  children: [
                    _buildCircleColor(colors[0]),
                    if (targetColorResults[0] == AnswerResult.correct)
                      // แสดงภาพ check.png ทับ
                      _buildCheckWidget(),
                    if (targetColorResults[0] == AnswerResult.wrong)
                      // แสดงภาพ cross.png ทับ
                      _buildCrossWidget(),
                  ],
                ),
                // Circle ด้านขวา (index 1)
                Stack(
                  children: [
                    _buildCircleColor(colors[1]),
                    if (targetColorResults[1] == AnswerResult.correct)
                      _buildCheckWidget(),
                    if (targetColorResults[1] == AnswerResult.wrong)
                      _buildCrossWidget(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleColor(Color color) {
    return Container(
      width: context.screenWidth * 0.1,
      height: context.screenHeight * 0.1,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.black, width: 4),
      ),
    );
  }

// ตัวอย่าง widget check/cross
  Widget _buildCheckWidget() {
    return Positioned(
      child: AnimatedPopupTemplate(
        key: const ValueKey<int>(1),
        duration: const Duration(milliseconds: 1000),
        beginScale: 0.1,
        endScale: 1.0,
        child: Image.asset(
          'assets/images/shapegame/check.png',
          width: context.screenWidth * 0.1,
          height: context.screenHeight * 0.1,
        ),
      ),
    );
  }

  Widget _buildCrossWidget() {
    return Positioned(
      child: AnimatedPopupTemplate(
        key: const ValueKey<int>(2),
        duration: const Duration(milliseconds: 1000),
        beginScale: 0.1,
        endScale: 1.0,
        child: Image.asset(
          'assets/images/shapegame/cross.png',
          width: context.screenWidth * 0.1,
          height: context.screenHeight * 0.1,
        ),
      ),
    );
  }

  Widget _buildScoreUI() {
    return Container(
      width: 250,
      height: 150,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 170, 46, 100).withOpacity(1),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(80),
          bottomRight: Radius.circular(80),
        ),
        border: Border.all(color: Colors.black, width: 6),
      ),
      child: Row(
        children: [
          const SizedBox(width: 50), // ระยะห่างจากขอบ
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const StrokeText(
                text: "คะแนน",
                fontSize: 30,
                strokeWidth: 8,
                fontWeight: FontWeight.w600,
              ),
              StrokeText(
                text: "$currentScore",
                fontSize: 55,
                strokeWidth: 12,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExitPopUp(BuildContext context) {
    double imageWidth = context.screenWidth;
    double imageHeight = context.screenHeight;

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
                _game?.resumeGameTime(); // หยุดเกมชั่วคราว
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

  Widget _buildControllerUI() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            TwoStateImageButton(
              onTap: _game!.controller.onLeftPressed,
              childNormal: Image.asset(
                  'assets/images/colorgame/controller/arrow_left.png',
                  width: 100,
                  height: 100),
              childPressed: Image.asset(
                  'assets/images/colorgame/controller/arrow_left_hover.png',
                  width: 100,
                  height: 100),
              scaleFactor: 0.9, // ปรับได้เหมือนเดิม
              duration: const Duration(milliseconds: 100),
            ),
            const SizedBox(width: 20),
            TwoStateImageButton(
              onTap: _game!.controller.onRightPressed,
              childNormal: Image.asset(
                  'assets/images/colorgame/controller/arrow_right.png',
                  width: 100,
                  height: 100),
              childPressed: Image.asset(
                  'assets/images/colorgame/controller/arrow_right_hover.png',
                  width: 100,
                  height: 100),
              scaleFactor: 0.9, // ปรับได้เหมือนเดิม
              duration: const Duration(milliseconds: 100),
            ),
          ],
        ),
        Column(
          children: [
            TwoStateImageButton(
              onTap: _game!.controller.onUpPressed,
              childNormal: Image.asset(
                'assets/images/colorgame/controller/arrow_up.png',
                width: 100,
                height: 100,
              ),
              childPressed: Image.asset(
                  'assets/images/colorgame/controller/arrow_up_hover.png',
                  width: 100,
                  height: 100),
              scaleFactor: 0.9, // ปรับได้เหมือนเดิม
              duration: const Duration(milliseconds: 100),
            ),
            const SizedBox(height: 20),
            TwoStateImageButton(
              onTap: _game!.controller.onDownPressed,
              childNormal: Image.asset(
                'assets/images/colorgame/controller/arrow_down.png',
                width: 100,
                height: 100,
              ),
              childPressed: Image.asset(
                  'assets/images/colorgame/controller/arrow_down_hover.png',
                  width: 100,
                  height: 100),
              scaleFactor: 0.9, // ปรับได้เหมือนเดิม
              duration: const Duration(milliseconds: 100),
            ),
          ],
        ),
      ],
    );
  }
}
