import 'dart:async';
import 'dart:math';
import 'package:firstly/function/mediaquery_values.dart';
import 'package:firstly/screens/shared_prefs_service.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_button.dart';
import '../widgets/progressbar_lineeasy.dart';
import '../widgets/result_widget.dart';
import '../widgets/star_congrate.dart';
import 'data/Level_hard_data.dart';
import 'game_mechanic/shape_game_controller.dart';
import 'model/level_shape_data.dart';
import 'model/shape_model.dart';
import 'model/silhouette_item.dart';

enum ButtonState { none, correct, incorrect }

class GameShapeHardScreen extends StatefulWidget {
  // สมมุติว่าเราจะส่งลิสต์รูปร่างของ “เลเวลปัจจุบัน” เข้ามา

  const GameShapeHardScreen({Key? key}) : super(key: key);

  @override
  State<GameShapeHardScreen> createState() => _GameShapeHardScreenState();
}

class _GameShapeHardScreenState extends State<GameShapeHardScreen>
    with TickerProviderStateMixin {
  final List<LevelShapeData> allLevels = LevelHardData.allLevels;
  int _currentLevelIndex = 0; // ด่านปัจจุบัน

  late ShapeGameController _gameController;
  late ValueNotifier<int> _timeNotifier;
  final prefsService = SharedPrefsService();

  Timer? _timer; // ประกาศตัวแปรเก็บ Timer ที่ระดับ State
  final Map<String, ButtonState> _buttonStates = {};

  bool showTutorial = false;
  bool showResult = false;
  bool isWin = false;

  // เพิ่มตัวแปรสำหรับ Widget "3 2 1 Go"
  bool showCountdown = false;
  late AnimationController _countdownAnimationController;
  late Animation<double> _countdownAnimation;
  int _currentCountdown = 3;

  int earnedStars = 0; // จำนวนดาวที่ได้จากการเล่น
  bool _isLevelTransitioning = false;

  bool showStarCongrate = false; // เพิ่มตัวแปรระดับ State

  @override
  void initState() {
    super.initState();

    // สร้างตัว Controller game
    _gameController = ShapeGameController();
    earnedStars = _gameController.calculateStars(); // รีเซ็ตดาวที่ได้

    // เริ่มต้น Animation สำหรับ Countdown
    _countdownAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _countdownAnimation = Tween<double>(begin: 1.5, end: 1.0)
        .chain(CurveTween(curve: Curves.bounceOut))
        .animate(_countdownAnimationController);

    // เรียกเริ่ม Flow เกม (Tutorial -> Countdown -> เล่นเกม)
    _startGameFlow();
  }

  /// ฟังก์ชันเริ่ม Flow เกมใหม่
  void _startGameFlow() {
    setState(() {
      // เคลียร์ตัวแปรต่าง ๆ
      _timer?.cancel();
      _buttonStates.clear();
      _currentLevelIndex = 0;
      isWin = false;
      showResult = false;

      // รีเซ็ต GameController ด้วย (ถ้าจำเป็น)
      _gameController
          .reset(); // สมมุติคุณสร้างเมธอด reset() ใน ShapeGameController

      // รีเซ็ตเวลา
      _timeNotifier = ValueNotifier<int>(120);
      _gameController.remainingTime = 120;

      // เปิด Tutorial
      showTutorial = true;
      showCountdown = false;
      _currentCountdown = 3;
    });
  }

  /// (B) เมื่อปิด Tutorial -> เริ่ม Countdown
  void _onCloseTutorial() {
    setState(() {
      showTutorial = false;
      showCountdown = true;
    });
    _startCountDown();
  }

  /// (C) ฟังก์ชันเริ่มนับถอยหลัง 3..2..1..Go
  /// พอจบ -> initLevel(0)
  void _startCountDown() {
    // รีเซ็ตค่าตัวเลข
    _currentCountdown = 3;

    // เริ่มจับเวลานับถอยหลัง
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentCountdown > 0) {
        _countdownAnimationController.forward(from: 0.0);
        setState(() {
          _currentCountdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          showCountdown = false;
        });
        // เมื่อจบ countdown -> เริ่มเลเวลแรก
        _initLevel(0);
      }
    });
  }

  /// เริ่มเลเวลตาม index
  void _initLevel(int levelIndex) {
    // ถ้าเลยเลเวลหมดแล้ว -> แสดง Dialog ว่าจบเกม
    if (levelIndex >= allLevels.length) {
      _timer?.cancel();
      showStarCongrate = true;
      isWin = true;
      showResult = true;
      return;
    }
    showStarCongrate = false; // เพิ่มบรรทัดนี้
    final levelData = allLevels[levelIndex];
    // เรียก controller ให้ load silhouettes + options ของเลเวลนี้
    _gameController.startLevel(levelData);

    // ผูก ProgressBar
    _timeNotifier = ValueNotifier<int>(_gameController.remainingTime);

    // เริ่มจับเวลา
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    // เคลียร์ Timer เก่าหากต้องการ
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _gameController.decrementTime();
      _timeNotifier.value = _gameController.remainingTime;

      if (_gameController.remainingTime <= 0) {
        timer.cancel();
        isWin = false;
        showResult = true;
        setState(() {});
      }
    });
  }

  void _onAnswerChosen(ShapeModel chosen) {
    bool isCorrect = _gameController.checkAnswer(chosen);

    // ถ้ารูปนี้ยังไม่ถูกเปิด + กดผิด => หักเวลา
    if (!_gameController.revealedShapes.contains(chosen.name) && !isCorrect) {
      _gameController.penaltyTime(5);
    }

    setState(() {
      if (isCorrect) {
        _buttonStates[chosen.name] = ButtonState.correct;

        // เช็คว่าเผยครบหรือยัง
        if (_gameController.isAllRevealed && !_isLevelTransitioning) {
          _isLevelTransitioning = true;

          showStarCongrate = true; // เพิ่มบรรทัดนี้

          // รอ 1 วินาทีก่อนเคลียร์
          Future.delayed(const Duration(milliseconds: 2500), () {
            setState(() {
              _buttonStates.clear();
            });
          });

          // รอ 1.8 วินาที -> ไปด่านต่อไป
          Future.delayed(const Duration(milliseconds: 3500), () {
            _goNextLevel();
            _isLevelTransitioning = false;
          });
        }
      } else {
        // ตอบผิด -> incorrect 1.5 วิ
        _buttonStates[chosen.name] = ButtonState.incorrect;
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          if (_buttonStates[chosen.name] == ButtonState.incorrect) {
            setState(() {
              _buttonStates[chosen.name] = ButtonState.none;
            });
          }
        });
      }
    });
  }

  /// เปลี่ยนไปด่านถัดไป หรือสรุปผล
  void _goNextLevel() {
    setState(() {
      _buttonStates.clear(); // เคลียร์ทุกปุ่มให้กดได้อีกครั้ง
      _currentLevelIndex++;
      _initLevel(_currentLevelIndex);
    });
  }

  //รีเซ้ตเกมเริ่มใหม่
  void _resetGame() {
    _startGameFlow();
  }

  @override
  void dispose() {
    _timer?.cancel(); // ยกเลิก Timer เมื่อปิดหน้าจอ
    _countdownAnimationController.dispose();
    super.dispose();
  }

  /// เมธอดสร้าง Widget Silhouette
  Widget _buildSilhouetteArea() {
    // ถ้าเลยเลเวลหมดแล้ว -> ไม่โชว์
    //if (_currentLevelIndex >= allLevels.length) return SizedBox.shrink();

    final silhouettes = _gameController.currentSilhouettes;

    final screenW = context.screenWidth;
    final screenH = context.screenHeight;

    //int levelIndex = _currentLevelIndex;
    // กำหนดสูตรคำนวณความเร็ว
    //const int baseSpeed = 380;
    //const int incrementPerLevel = 150;

    // สร้าง List สักอันเพื่อเก็บ Widget ของ Silhouette
    List<Widget> silhouetteWidgets = [];

    for (int i = 0; i < _gameController.currentSilhouettes.length; i++) {
      final random = Random();

      // Ramdom ทิศทางเริ่มต้น
      double startX = random.nextDouble() * (screenW * 0.45);
      double startY = random.nextDouble() * (screenH * 0.45);

      double vx = 150 + random.nextDouble() * 200;
      double vy = 150 + random.nextDouble() * 200;
      if (random.nextBool()) vx = -vx;
      if (random.nextBool()) vy = -vy;
      // คำนวณความเร็วตามเลเวล
      //int speedForThisLevel = baseSpeed + (incrementPerLevel * levelIndex);

      // เอามาใช้ทั้ง vx, vy
      // หรือถ้าต้องการ random ก็สุ่มสักนิด
      //double vx = speedForThisLevel.toDouble();
      //double vy = speedForThisLevel.toDouble();

      // สร้าง widget BouncingRotatingSilhouetteItem (ตัวอย่างว่าหมุนด้วย)
      silhouetteWidgets.add(
        SilhouetteItem(
          gameController: _gameController,
          shape: silhouettes[i],
          // แก้ตามตำแหน่งเริ่มที่ต้องการ
          initialX: startX,
          initialY: startY,
          initialVX: 500,
          initialVY: 500,
          itemSize: 120 + 5 * i.toDouble(), // ขนาดรูป 80 px
          rotationSpeed: 0.5 * pi, // หมุน 360 องศาต่อวินาที
        ),
      );
    }

    // ใส่ Stack + ClipRect เพื่อไม่ให้ลอยออกนอกพื้นที่
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.1,
      left: 0,
      right: 0,
      child: Center(
        child: Stack(
          children: [
            // ฉากหลัง
            Center(
              child: SizedBox(
                width: context.screenWidth * 0.6,
                height: context.screenHeight * 0.5,
                child: Image.asset(
                  "assets/images/shapegame/BG_shape_game.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // ClipRect + Stack สำหรับลอย
            // เรียกใช้ SilhouetteAnimationArea
            // ClipRect + Stack สำหรับลอย
            Padding(
              padding: EdgeInsets.only(
                  left: context.screenWidth * 0.275,
                  top: context.screenHeight * 0.015,
                  right: context.screenWidth * 0.275),
              child: SizedBox(
                width: context.screenWidth * 0.45,
                height: context.screenWidth * 0.28,
                child: ClipRect(
                  child: Stack(
                    children: silhouetteWidgets,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// -----------------------------
  // ส่วนแสดงตัวเลือก
  // -----------------------------
  Widget _buildOptions() {
    //if (_currentLevelIndex >= allLevels.length) return SizedBox.shrink();

    final options = _gameController.currentOptions;

    // วางใกล้ ๆ ขอบล่าง 20%
    return Positioned(
      bottom: context.screenHeight * 0.25,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: options.map((shape) {
          return _buildOptionButton(shape);
        }).toList(),
      ),
    );
  }

  /// สร้างปุ่มตัวเลือก (Option) เป็น Stack เพื่อซ้อน Overlay
  Widget _buildOptionButton(ShapeModel shape) {
    final ButtonState state = _buttonStates[shape.name] ?? ButtonState.none;

    // ถ้าต้องการปิดการกดปุ่มเมื่อ correct:
    final bool isAnsweredCorrect = (state == ButtonState.correct);

    return CustomButton(
      onTap: isAnsweredCorrect ? null : () => _onAnswerChosen(shape),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ชั้นล่าง: กล่อง + รูป
          Container(
            width: context.screenWidth * 0.1,
            height: context.screenHeight * 0.15,
            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Image.asset(
              shape.imagePath,
              fit: BoxFit.contain,
            ),
          ),
          Container(
            width: context.screenWidth * 0.095,
            height: context.screenHeight * 0.15,
            decoration: BoxDecoration(
              color: isAnsweredCorrect
                  ? Colors.white.withOpacity(0.8)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300), // ระยะเวลาอนิเมชัน
              switchInCurve: Curves.bounceInOut,
              switchOutCurve: Curves.elasticOut,
              transitionBuilder: (child, animation) {
                // เลือกรูปแบบอนิเมชัน: เช่น ScaleTransition หรือ FadeTransition
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                );
              },
              // child = widget ที่จะเปลี่ยนไปตาม state
              child: _buildStateIcon(state),
            ),
          ),
        ],
      ),
    );
  }

  /// สร้าง Widget แสดงเครื่องหมายตาม state
  Widget _buildStateIcon(ButtonState state) {
    switch (state) {
      case ButtonState.correct:
        return Image.asset(
          "assets/images/shapegame/check.png",
          width: 80,
          height: 80,
          fit: BoxFit.contain,
          key: const ValueKey('correct'), // ใส่ key ให้ AnimatedSwitcher แยกได้
        );
      case ButtonState.incorrect:
        return Image.asset(
          "assets/images/shapegame/cross.png",
          width: 80,
          height: 80,
          fit: BoxFit.contain,
          key: const ValueKey('incorrect'),
        );
      default:
        // none => ไม่แสดงอะไร
        return const SizedBox(
          key: ValueKey('none'),
        );
    }
  }

  Widget _buildCountdownWidget() {
    // Widget สำหรับแสดง Countdown
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: ScaleTransition(
          scale: _countdownAnimation,
          child: Text(
            _currentCountdown > 0 ? '$_currentCountdown' : 'Go!',
            style: TextStyle(
              fontSize: 300,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// สร้าง Widget สำหรับ ProgressBar (บนสุด)
  Widget _buildProgressBar() {
    return ProgressBarLineEasyWidget(
      remainingTime: _timeNotifier,
      maxTime: _gameController.maxTime,
      // จำนวนดาวที่เราจะโชว์เป็นตำแหน่ง -> ส่วนว่าเต็มกี่ดวง อาจคำนวณนอกนี้
      // หรือจะแก้ไข ProgressBarLineEasyWidget ให้รับฟังก์ชันคำนวณดาวก็ได้
      starCount: 3,
    );
  }

  Widget _buildTutorialWidget() {
    // Widget สำหรับแสดง Tutorial
    return GestureDetector(
      onTap: () {
        // (B) เมื่อผู้ใช้ปิด Tutorial -> เริ่ม Countdown
        _onCloseTutorial();
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

  @override
  Widget build(BuildContext context) {
    // ใช้ Stack วาง ProgressBar บนสุด, Silhouette กลางจอ, ปุ่มด้านล่าง, และ Overlay check/cross
    return Scaffold(
      body: Stack(
        children: [
          // ================== ฉากหลัง ==================
          Positioned.fill(
            child: Image.asset(
              'assets/images/shapegame/grid_green.png',
              fit: BoxFit.cover,
            ),
          ),

          // ================== เกม ==================

          _buildProgressBar(),
          _buildProgressBar(),
          if (showStarCongrate)
            AnimatedOpacity(
                opacity: showStarCongrate ? 1.0 : 0.0,
                duration: Duration(milliseconds: 3000),
                child: StarCongrate()),
          _buildSilhouetteArea(),
          _buildOptions(),

          // =========== Exit Button =================
          Positioned(
            top: context.screenSize.height * 0.05,
            right: context.screenSize.width * 0.04,
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
                });
              },
              child: Image.asset(
                'assets/images/HintButton.png',
                width: context.screenSize.width * 0.060,
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

          // ----- ถ้า showResult => แสดง ResultWidget
          if (showResult && isWin)
            ResultWidget(
              onLevelComplete: isWin, // ตัวอย่าง
              starsEarned: _gameController.calculateStars(),
              onButton1Pressed: () {
                setState(() {
                  _resetGame();
                });
              },
              onButton2Pressed: () {
                _finishGame();
              },
            ),
          if (showResult && !isWin)
            ResultWidget(
              onLevelComplete: isWin, // ตัวอย่าง
              starsEarned: 0,
              onButton1Pressed: () {
                _finishGame();
              },
              onButton2Pressed: () {
                setState(() {
                  _resetGame();
                });
              },
            ),

          if (showCountdown) _buildCountdownWidget(),
        ],
      ),
    );
  }

  void _finishGame() async {
    // บันทึกข้อมูลของด่านปัจจุบัน
    await prefsService.saveLevelData('Shape Hard', earnedStars, 'yellow', true);

// ปลดล็อคด่านถัดไป
    await prefsService.updateLevelUnlockStatus('Shape Hard', 'Shape Quiz');

    // ตรวจสอบข้อมูลที่บันทึก
    final result = await prefsService.loadLevelData('Shape Hard');
    print("Saved Level Data: $result");

    // กลับไปยังหน้าเลือกเกม
    Navigator.pop(context);
  }
}
