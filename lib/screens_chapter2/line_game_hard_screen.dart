import 'package:firstly/screens_chapter2/linegamehard/game/hard_line_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../widgets/result_widget.dart';
import 'line_game_test.dart';

/// ------------------------------------------------------------
///
/// ส่วนของ Widget หน้าจอ (UI) - ไม่มีเวลาในเกมแล้ว
///
/// ------------------------------------------------------------

class LineGameHardScreen extends StatefulWidget {
  //final String starColor;
  //final int earnedStars;

  const LineGameHardScreen({
    super.key,
    //required this.starColor,
    //required this.earnedStars,
  });

  @override
  State<LineGameHardScreen> createState() => _LineGameHardScreenState();
}

class _LineGameHardScreenState extends State<LineGameHardScreen> {
  late HardLineGame game;
  bool showResult = false;
  bool isWin = false;
  bool showTutorial = false;

  @override
  void initState() {
    super.initState();

    // สร้างเกม
    game = HardLineGame(
      onChapterEnd: (bool win) {
        setState(() {
          showResult = true;
          isWin = win;
        });
      },
    );
    game.onUpdateUI = () {
      setState(() {});
    };

    showTutorial = true; // ถ้าต้องการแสดง Tutorial
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double imageWidth = screenSize.width;
    double imageHeight = screenSize.height;

    return Scaffold(
      body: Stack(
        children: [
          /// ตัวเกม
          Positioned.fill(
            child: GameWidget(game: game),
          ),
          if (game.isLineComplete)
            Positioned(
              right: screenSize.width * 0.08,
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
                      border: Border.all(color: Colors.black, width: 6),
                      borderRadius: BorderRadius.circular(imageWidth * 0.1),
                    ),
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: CustomThumbShape(
                          thumbRadius: imageWidth * 0.028,
                          borderColor: Colors.black, // สีของเส้นรอบนอก
                          borderWidth: 6.0, // ความหนาของเส้นรอบนอก
                        ),
                        thumbColor: const Color.fromARGB(255, 1, 208, 255),
                        //trackShape: const RectangularSliderTrackShape(),
                        //trackHeight: 80,
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 35),
                        //inactiveTrackColor: Colors.grey.shade300,
                        activeTrackColor: Colors.grey.shade300,
                      ),
                      child: RotatedBox(
                        quarterTurns: 3, // หมุนให้เป็นแนวตั้ง
                        child: Slider(
                          activeColor: Colors.grey.shade300,
                          inactiveColor: Colors.grey.shade300,
                          thumbColor: Color.fromARGB(255, 1, 208, 255),
                          value: game.currentSliderValue,
                          min: -5,
                          max: 5,
                          divisions: 10,
                          onChanged: (val) {
                            setState(() {
                              game.updateCurve(val);
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
                          game.attemptConfirmLine();
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

          // ----- ปุ่ม FloatingButton Icon ย้อนกลับ -----
          Positioned(
            top: screenSize.height * 0.05, // ระยะจากขอบบน
            right: screenSize.width * 0.04, // ระยะจากขอบซ้าย
            child: FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: true, // ปิดเมื่อกดด้านนอก
                  builder: (BuildContext context) => _buildExitPopUp(context),
                );
              },
              backgroundColor: Colors.white.withOpacity(0), // สีพื้นหลังปุ่ม
              elevation: 0, // ไม่มีเงา
              hoverElevation: 0, // ไม่มีเงาเมื่อโฮเวอร์
              focusElevation: 0, // ไม่มีเงาเมื่อโฟกัส
              highlightElevation: 0, // ไม่มีเงาเมื่อกด
              child: Icon(Icons.close_rounded,
                  size: screenSize.width * 0.058, color: Colors.black), // ไอคอน
            ),
          ),

          // ----- ปุ่ม ResetLevel  -----
          Positioned(
            top: screenSize.height * 0.09, // ระยะจากขอบบน
            left: screenSize.width * 0.04, // ระยะจากขอบซ้าย
            child: SizedBox(
              width: screenSize.width * 0.085,
              height: screenSize.height * 0.085,
              child: FloatingActionButton(
                  onPressed: () {
                    game.onResetLevel();
                  },
                  backgroundColor:
                      Colors.white.withOpacity(0), // สีพื้นหลังปุ่ม
                  elevation: 0, // ไม่มีเงา
                  hoverElevation: 0, // ไม่มีเงาเมื่อโฮเวอร์
                  focusElevation: 0, // ไม่มีเงาเมื่อโฟกัส
                  highlightElevation: 0, // ไม่มีเงาเมื่อกด
                  child: Image.asset(
                    'assets/images/reload_button.png',
                  ) // ไอคอน
                  ),
            ),
          ),

          /// UI: แสดง HP / Stars
          Positioned(
              bottom: screenSize.height * 0.05,
              left: screenSize.width * 0.05,
              child: _buildLifeBar()),
          Positioned(
              top: screenSize.height * 0.05,
              left: screenSize.width * 0.5 - (screenSize.width * 0.22) / 2,
              child: _buildStarsBar()),

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
              child: _buildTutorialWidget(),
            ),

          // ----- ถ้า showResult => แสดง ResultWidget
          if (showResult && isWin)
            ResultWidget(
              onLevelComplete: isWin, // ตัวอย่าง
              starsEarned: game.stars,
              onButton1Pressed: () {
                setState(() {
                  showResult = false; // ปิดหน้า Result
                  isWin = false; // ถ้าอยากเคลียร์สถานะ UI
                  game.resetGame();
                  game.stars = 0; // รีเซ็ตดาวที่ได้
                  showTutorial = true; // เปิด TutorialWidget
                });
              },
              onButton2Pressed: () {
                Navigator.pop(context);
              },
            ),
          if (showResult && !isWin)
            ResultWidget(
              onLevelComplete: isWin, // ตัวอย่าง
              starsEarned: game.stars = 0,
              onButton1Pressed: () {
                Navigator.pop(context);
              },
              onButton2Pressed: () {
                setState(() {
                  showResult = false; // ปิดหน้า Result
                  isWin = false; // ถ้าอยากเคลียร์สถานะ UI
                  game.resetGame();
                  game.stars = 0; // รีเซ็ตดาวที่ได้
                  showTutorial = true; // เปิด TutorialWidget
                });
              },
            ),
        ],
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
                    'assets/images/linegamelist/tutorial_hard_1.png', // แก้รูปภาพการสอน
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

  Widget _buildLifeBar() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.22,
      height: MediaQuery.of(context).size.height * 0.12,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(1),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.black, width: 5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Image.asset(
              index < game.hp
                  ? 'assets/images/linegamelist/hp.png' // Full heart
                  : 'assets/images/linegamelist/hp_empty.png', // Empty heart
              width: MediaQuery.of(context).size.width * 0.05, // Adjust size
              height: MediaQuery.of(context).size.height * 0.08,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStarsBar() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.22,
      height: MediaQuery.of(context).size.height * 0.12,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(1),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.black, width: 5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Image.asset(
              index < game.stars
                  ? 'assets/images/linegamelist/star_full.png' // Full heart
                  : 'assets/images/linegamelist/star_empty.png', // Empty heart
              width: MediaQuery.of(context).size.width * 0.05, // Adjust size
              height: MediaQuery.of(context).size.height * 0.08,
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
}
