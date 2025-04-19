// lib/screen/screen_game_shape_quiz.dart

import 'package:firstly/function/mediaquery_values.dart';
import 'package:firstly/screens/shared_prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/result_widget_quiz.dart';
import '../data/tangram_level_data.dart';
import '../mechanic/player_data.dart';
import '../mechanic/tangram_game.dart';

class ScreenGameShapeQuiz extends StatefulWidget {
  const ScreenGameShapeQuiz({
    Key? key,
  }) : super(key: key);

  @override
  State<ScreenGameShapeQuiz> createState() => _ScreenGameShapeQuizState();
}

class _ScreenGameShapeQuizState extends State<ScreenGameShapeQuiz> {
  final PlayerDataManager _playerData = PlayerDataManager(hearts: 3);
  final prefsService = SharedPrefsService();

  late TangramGame? _game;

  int playerCallbackHP = 3;
  bool showTutorial = false;
  bool showResult = false;
  bool isWin = false;

  @override
  void initState() {
    super.initState();
    //showTutorial = true;

    // ตัวอย่าง: ถ้ามีระบบหลายด่าน
    final levelData = TangramLevelManager.currentLevel;
    // _game = TangramGame(levelData);

    // หรือถ้าเกมแบบง่าย:
    _game = TangramGame(levelData, _playerData)
      ..onLevelComplete = loadNextLevel
      ..onAllLevelComplete = onGameWin
      ..onGameOver = onGameOver
      ..onHPChanged = (currentHP) {
        setState(() {
          playerCallbackHP = currentHP;
        });
      };
    // (ปรับแก้ตามโค้ดของคุณเอง ถ้าต้องการสร้าง TangramGame แบบมี levelData)
  }

  void _finishGame() async {
    // บันทึกข้อมูลของด่านปัจจุบัน
    await prefsService.saveLevelData('Shape Quiz', 1, 'purple', true);

    await prefsService.updateLevelUnlockStatus('Shape Quiz', 'Color Motion');
    // ตรวจสอบข้อมูลที่บันทึก
    final result = await prefsService.loadLevelData('Shape Quiz');
    print("Saved Level Data: $result");

    // กลับไปยังหน้าเลือกเกม
    Navigator.pop(context);
  }

  void onGameOver() {
    setState(() {
      showResult = true;
      isWin = false;
    });
  }

  void onGameWin() {
    setState(() {
      showResult = true;
      isWin = true;
    });
  }

  void loadNextLevel() {
    //setState(() {
    // ทำให้ _game กลายเป็น null ก่อนแล้วสร้างใหม่
    //_game = null;

    // ใช้ Future.delayed(0) เพื่อให้ Flutter มีโอกาส Rebuild
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        final nextLevel = TangramLevelManager.currentLevel;
        print(
            "🔄 Reloading Game: Level ${TangramLevelManager.currentLevelIndex}");
        _game = TangramGame(nextLevel, _playerData)
          ..onLevelComplete = loadNextLevel
          ..onAllLevelComplete = onGameWin
          ..onGameOver = onGameOver
          ..onHPChanged = (currentHP) {
            setState(() {
              playerCallbackHP = currentHP;
            });
          };
      });
    });
    //});
  }

  void resetGame() {
    // (1) รีเซ็ตด่านให้เริ่มใหม่
    TangramLevelManager.currentLevelIndex = 0;

    // (2) รีเซ็ตหัวใจ
    _playerData.hearts = 3;
    playerCallbackHP = 3; // ถ้ามีตัวแปรโชว์ค่าใน UI

    // (3) ปิด result, ตั้งสถานะอื่นๆ
    setState(() {
      showResult = false;
      isWin = false;
      showTutorial = true; // ถ้าอยากเปิด tutorial ใหม่

      // (4) สร้าง TangramGame ใหม่เหมือนตอนเริ่มเกม
      final levelData = TangramLevelManager.currentLevel;
      _game = TangramGame(levelData, _playerData)
        ..onLevelComplete = loadNextLevel
        ..onAllLevelComplete = onGameWin
        ..onGameOver = onGameOver
        ..onHPChanged = (currentHP) {
          setState(() {
            playerCallbackHP = currentHP;
          });
        };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_game != null)
            GameWidget(
              // key: ValueKey(TangramLevelManager
              //     .currentLevelIndex), // ✅ บังคับให้ Flutter โหลดใหม่
              game: _game!,
            ),
          Positioned(
              top: context.screenHeight * 0.07,
              left: context.screenWidth * 0.05,
              child: _buildLifeBar()),
          Positioned(
            top: context.screenHeight * 0.05,
            right: context.screenWidth * 0.04,
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
                width: context.screenWidth * 0.060,
              ),
            ),
          ),
          // ปุ่ม Info สำหรับเปิด TutorialWidget
          Positioned(
            bottom: context.screenHeight * 0.05,
            right: context.screenWidth * 0.04,
            child: CustomButton(
              onTap: () {
                setState(() {
                  showTutorial = true; // เปิด TutorialWidget
                });
              },
              child: Image.asset(
                'assets/images/HintButton.png',
                width: context.screenWidth * 0.060,
              ),
            ),
          ),

          if (showTutorial)
            AnimatedOpacity(
              opacity: showTutorial ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 1000),
              child: _buildTutorialWidget(),
            ),

          // ----- ถ้า showResult => แสดง ResultWidget
          if (showResult && isWin)
            ResultWidgetQuiz(
              onLevelComplete: isWin, // ตัวอย่าง
              starsEarned: 1,
              onButton1Pressed: () {
                resetGame();
              },
              onButton2Pressed: () {
                _finishGame();
              },
            ),
          if (showResult && !isWin)
            ResultWidgetQuiz(
              onLevelComplete: isWin, // ตัวอย่าง
              starsEarned: 0,
              onButton1Pressed: () {
                resetGame();
              },
              onButton2Pressed: () {
                _finishGame();
              },
            ),
        ],
      ), // ✅ ใช้ _game! เพื่อบอกว่าไม่เป็น null
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
              index < playerCallbackHP
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
