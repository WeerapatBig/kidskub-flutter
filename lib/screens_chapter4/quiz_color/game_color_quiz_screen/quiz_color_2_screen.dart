import 'package:firstly/function/mediaquery_values.dart';
import 'package:firstly/widgets/custom_button.dart';
import 'package:flutter/material.dart';

import '../../model/animated_popup_template.dart';
import '../data/quiz_color_level_data_2.dart';

class QuizColor2Screen extends StatefulWidget {
  final VoidCallback onGameOver; // ✅ เพิ่มตรงนี้
  final VoidCallback onCompleteAllLevels; // ✅ เพิ่มตรงนี้

  const QuizColor2Screen({
    Key? key,
    required this.onGameOver,
    required this.onCompleteAllLevels,
  }) : super(key: key);

  @override
  State<QuizColor2Screen> createState() => _QuizColor2ScreenState();
}

class _QuizColor2ScreenState extends State<QuizColor2Screen> {
  int hp = 3; // จำนวนชีวิต
  int currentLevel = 0;
  bool isAnswered = false;
  bool isCorrect = false;
  Set<String> wrongAnswers = {};

  void _handleAnswer(String selectedColor) {
    final levelData = quizColorLevels2[currentLevel];

    if (selectedColor == levelData.answerColor) {
      // ✅ ตอบถูก
      setState(() {
        isAnswered = true;
        isCorrect = true;
      });

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _goToNextLevel();
        }
      });
    } else {
      // ❌ ตอบผิด
      setState(() {
        wrongAnswers.add(selectedColor);
        hp--;
        if (hp <= 0) {
          gameOver();
        }
        // ❌ ไม่เซ็ต isAnswered = true
      });
    }
  }

  void _goToNextLevel() {
    if (currentLevel < quizColorLevels2.length - 1) {
      // ยังไม่จบเกม ➔ ไปเลเวลถัดไป
      setState(() {
        currentLevel++;
        isAnswered = false;
        isCorrect = false;
        wrongAnswers.clear();
      });
    } else {
      // ผ่านทุกเลเวลแล้ว ➔ ไปหน้า ShowResult
      gameComplete();
    }
  }

  void gameOver() {
    widget
        .onGameOver(); // ✅ กลับไปที่ GameColorQuizIntroScreen หรือทำอย่างที่ต้องการ
  }

  void gameComplete() {
    widget.onCompleteAllLevels(); // ✅ เรียก callback ส่งกลับไปที่หน้าหลัก
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox(
        width: context.screenWidth,
        height: context.screenHeight,
        child: Stack(
          children: [
            //------ Objective Image -----
            Positioned(
                top: screenSize.height * 0.23,
                left: screenSize.width * 0.15,
                child: SizedBox(
                  width: screenSize.width * 0.35,
                  child: Image.asset(
                      'assets/images/colorgame/quiz_color/objective_3.png'),
                )),

            _mainQuestion(),
            _buildColorOption(),

            Positioned(
                top: screenSize.height * 0.08,
                left: screenSize.width * 0.05,
                child: _buildLifeBar()),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption() {
    final screenSize = MediaQuery.of(context).size;
    final levelData = quizColorLevels2[currentLevel];

    return Center(
      child: Container(
        margin: EdgeInsets.only(
            top: screenSize.height * 0.76, bottom: screenSize.height * 0.05),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.black, width: 4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(levelData.options.length, (index) {
            final color = levelData.options[index];
            return Stack(
              alignment: Alignment.center,
              children: [
                CustomButton(
                  onTap: isAnswered ? () {} : () => _handleAnswer(color),
                  child: Image.asset(
                    'assets/images/colorgame/quiz_color/blob_$color.png',
                    width: screenSize.width * 0.09,
                  ),
                ),
                if (isAnswered && isCorrect && color == levelData.answerColor)
                  Center(
                    child: AnimatedPopupTemplate(
                      child: Image.asset(
                        'assets/images/shapegame/check.png',
                        width: 80,
                      ),
                    ),
                  ),
                if (wrongAnswers.contains(color))
                  Center(
                    child: AnimatedPopupTemplate(
                      child: Image.asset(
                        'assets/images/shapegame/cross.png',
                        width: 80,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _mainQuestion() {
    final screenSize = MediaQuery.of(context).size;
    final levelData = quizColorLevels2[currentLevel];

    List<String> blobs = [levelData.color1, levelData.color2, levelData.color3];
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(150, 80, 80, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Blob สีที่ 1 หรือ Quest
            SizedBox(
              width: screenSize.width * 0.12,
              child: Image.asset(
                'assets/images/colorgame/quiz_color/blob_${levelData.questIndex == 0 ? ((isAnswered && isCorrect) ? levelData.answerColor : 'quest') : blobs[0]}.png',
              ),
            ),

            // รูปเครื่องหมาย +
            SizedBox(
              width: screenSize.width * 0.06,
              child: Image.asset(
                'assets/images/colorgame/quiz_color/plus.png',
              ),
            ),

            // Blob สีที่ 2 หรือ Quest
            SizedBox(
              width: screenSize.width * 0.12,
              child: Image.asset(
                'assets/images/colorgame/quiz_color/blob_${levelData.questIndex == 1 ? ((isAnswered && isCorrect) ? levelData.answerColor : 'quest') : blobs[1]}.png',
              ),
            ),

            // รูปเครื่องหมาย =
            SizedBox(
              width: screenSize.width * 0.06,
              child: Image.asset(
                'assets/images/colorgame/quiz_color/equal.png',
              ),
            ),

            // Blob สีที่ 3 หรือ Quest
            SizedBox(
              width: screenSize.width * 0.15,
              child: Image.asset(
                'assets/images/colorgame/quiz_color/blob_${levelData.questIndex == 2 ? ((isAnswered && isCorrect) ? levelData.answerColor : 'quest') : blobs[2]}.png',
              ),
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
}
