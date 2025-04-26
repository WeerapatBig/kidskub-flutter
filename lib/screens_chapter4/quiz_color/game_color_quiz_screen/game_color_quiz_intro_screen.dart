import 'package:firstly/screens/shared_prefs_service.dart';
import 'package:firstly/screens_chapter4/quiz_color/game_color_quiz_screen/quiz_color_2_screen.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../widgets/custom_button.dart';
import '../../../widgets/hand_guide.dart';
import '../../../widgets/result_widget_quiz.dart';
import '../logic_game_color_quiz/logic_color_quiz_intro.dart';
import '../model/character/character_red.dart';
import '../model/dialog/color_quiz_dialog.dart';
import 'quiz_color_1_screen.dart';

class GameColorQuizIntroScreen extends StatefulWidget {
  const GameColorQuizIntroScreen({super.key});

  @override
  State<GameColorQuizIntroScreen> createState() =>
      _GameColorQuizIntroScreenState();
}

class _GameColorQuizIntroScreenState extends State<GameColorQuizIntroScreen> {
  bool showGame = true;
  Offset gameOffset = Offset.zero; // ตำแหน่งเริ่มต้นของเกม

  bool showQuiz = true;
  Offset quizOffset = Offset.zero;
  bool showQuiz2 = false;

  final GameColorQuizIntro game = GameColorQuizIntro();
  final GlobalKey<CharacterRedState> characterKey = GlobalKey();

  bool showResult = false;
  bool isWin = false; // ตัวแปรสำหรับเช็คว่าเล่นจบหรือยัง

  bool showDialogRed = true;
  bool showHandGuide = false; // แสดง HandGuide
  bool showSecondHandGuide = false; // แสดง HandGuide
  bool showTutorial = false;
  Vector2? globalPointer;

  final prefsService = SharedPrefsService();

  @override
  void initState() {
    super.initState();

    // เมื่อผู้เล่นลากสีแดงสำเร็จ
    game.onFirstRedDone = () {
      if (mounted) {
        setState(() {
          showHandGuide = false; // ✅ ปิดตัวแรกทันที
        });

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              showSecondHandGuide = true; // ✅ เปิดตัวที่สองหลังจาก 1 วิ
            });

            // ถ้าอยากให้ตัวที่สองหายไปเองหลังอีก 2 วิ
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  showSecondHandGuide = false;
                });
              }
            });
          }
        });
      }
    };
    game.onCompleteLevel = () {
      if (mounted) {
        setState(() {
          gameOffset = const Offset(1.5, 0); // ✅ เลื่อนขวา (1.5 เท่าจอ)
        });

        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              showGame = false; // ✅ ซ่อน Game ออกจาก Stack จริงๆ
            });
          }
        });
      }
    };
  }

  void closeDialogAndCharacter() async {
    await characterKey.currentState?.exitCharacter(); // ให้คาแรคเตอร์ slide ออก
    setState(() {
      showDialogRed = false; // ปิด dialog
      showHandGuide = true; // ปิด HandGuide
    });
  }

  void _finishGame() async {
    // บันทึกข้อมูลของด่านปัจจุบัน
    await prefsService.saveLevelData('Color Quiz', 1, 'purple', true);

    await prefsService.updateLevelUnlockStatus('Color Quiz', '');
    // ตรวจสอบข้อมูลที่บันทึก
    final result = await prefsService.loadLevelData('Color Quiz');
    print("Saved Level Data: $result");

    // กลับไปยังหน้าเลือกเกม
    Navigator.pop(context);
  }

  void resetGame() {
    setState(() {
      // รีเซ็ตสถานะ UI
      showGame = true;
      gameOffset = Offset.zero;

      showQuiz = true;
      quizOffset = Offset.zero;

      showQuiz2 = false;

      showResult = false;
      isWin = false;

      showDialogRed = true;
      showHandGuide = false;
      showSecondHandGuide = false;
      showTutorial = false;
      globalPointer = null;

      // รีเซ็ตเกมหลัก (Flame Game)
      game.reset(); // ต้องมี reset() ใน GameColorQuizIntro ด้วยนะ

      // ✅ ต้องตั้ง callback ใหม่ด้วย!
      game.onFirstRedDone = () {
        if (mounted) {
          setState(() {
            showHandGuide = false;
          });
        }
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          /*----------- ---------------- ------------*/
          /*----------- Quiz Game Screen ------------*/
          /*----------- ---------------- ------------*/
          Positioned.fill(
              child: Image.asset(
            'assets/images/linegamelist/line_quiz/paper_bg.png',
            fit: BoxFit.cover,
          )),
          if (showQuiz2)
            QuizColor2Screen(
              onGameOver: () {
                if (mounted) {
                  setState(() {
                    showResult = true;
                    isWin = false;
                  });
                }
              },
              onCompleteAllLevels: () {
                if (mounted) {
                  setState(() {
                    showResult = true;
                    isWin = true;
                  });
                }
              },
            ),

          if (showQuiz)
            AnimatedSlide(
              offset: quizOffset,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              child: QuizColor1Screen(
                onCompleteAllLevels: () {
                  if (mounted) {
                    setState(() {
                      quizOffset = const Offset(1.5, 0); // เลื่อนไปขวา
                    });

                    Future.delayed(const Duration(milliseconds: 800), () {
                      if (mounted) {
                        setState(() {
                          showQuiz = false; // ซ่อน QuizColor1Screen
                          showQuiz2 = true;
                        });
                      }
                    });
                  }
                },
                onGameOver: () {
                  setState(() {
                    showResult = true;
                    isWin = false;
                  });
                },
              ),
            ),

          /*----------- ---------------------- ------------*/
          /*----------- Color Wheel Game Flame ------------*/
          /*----------- ---------------------- ------------*/
          if (showGame)
            AnimatedSlide(
              offset: gameOffset,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              child: GameWidget(game: game),
            ),

          // คาแรคเตอร์อยู่ "ล่างกว่า"
          if (showDialogRed)
            Positioned(
              bottom: -80,
              left: 0,
              child: CharacterRed(key: characterKey),
            ),

          // Dialog อยู่ "ข้างบน"
          if (showDialogRed)
            ColorQuizDialog(
              onExit: closeDialogAndCharacter,
            ),
          // HandGuide ตัวแรก (ลาก Segment ไปยัง ColorWheel)
          if (showHandGuide)
            const HandGuide(
              angle: -0.5,
              start: Offset(520, 150),
              end: Offset(360, 240),
              duration: Duration(milliseconds: 1000),
            ),
          if (showSecondHandGuide)
            const HandGuide(
              angle: -0.22, // หมุนให้มือเอียง
              flipX: true,
              start: Offset(360, 450),
              end: Offset(360, 240),
              duration: Duration(milliseconds: 1000),
            ),

          /*----------- -------------------------- ------------*/
          /*----------- End Color Wheel Game Flame ------------*/
          /*----------- -------------------------- ------------*/

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
                  child: Lottie.asset(
                    'assets/lottie/color_lottie/color_quiz_1.json', // ก็คือ path ของไฟล์ .json
                    width: MediaQuery.of(context).size.width * 0.5,
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
