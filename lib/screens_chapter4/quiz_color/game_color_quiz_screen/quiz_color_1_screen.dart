import 'package:firstly/function/mediaquery_values.dart';
import 'package:firstly/widgets/custom_button.dart';
import 'package:flutter/material.dart';

import '../../model/animated_popup_template.dart';
import '../data/level_data_quiz_color_1.dart';
import '../logic_game_color_quiz/logic_quiz_color_1.dart';

class QuizColor1Screen extends StatefulWidget {
  final VoidCallback onCompleteAllLevels;
  final VoidCallback onGameOver;

  const QuizColor1Screen({
    Key? key,
    required this.onCompleteAllLevels,
    required this.onGameOver,
  }) : super(key: key);

  @override
  State<QuizColor1Screen> createState() => _QuizColor1ScreenState();
}

class _QuizColor1ScreenState extends State<QuizColor1Screen> {
  late QuizColor1Controller controller;
  Set<Color> wrongAnswers = {};
  Set<Color> correctAnswered = {};
  bool showPopup = false;
  Widget? popupWidget;

  @override
  void initState() {
    super.initState();
    controller = QuizColor1Controller(
      onLevelComplete: () => setState(() {}),
      onAllLevelComplete: () => _showCompleteDialog(),
      onHpDepleted: () => _handleGameOver,
    );
    controller.initializeLevel();
  }

  void _handleGameOver() {
    widget.onGameOver(); // ✅ ส่งออกไปให้ IntroScreen รู้ว่าจบแล้ว
  }

  void _handleColorTap(Color selectedColor) {
    if (controller.correctAnswers.contains(selectedColor)) {
      controller.selectedAnswers.add(selectedColor);
      correctAnswered.add(selectedColor);

      setState(() {}); // ให้ Build ใหม่เพื่อแสดง Popup

      if (controller.selectedAnswers.containsAll(controller.correctAnswers)) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _clearAnswerMarks();
            controller.goToNextLevel();
            setState(() {});
          }
        });
      }
    } else {
      controller.hp--;
      wrongAnswers.add(selectedColor);

      setState(() {});

      if (controller.hp <= 0) {
        controller.restartGame();
        setState(() {});
      }
    }
  }

  void _clearAnswerMarks() {
    correctAnswered.clear();
    wrongAnswers.clear();
  }

  void _showCompleteDialog() {
    widget
        .onCompleteAllLevels(); // ✅ เรียกส่งกลับไปให้ GameColorQuizIntroScreen จัดการเลื่อนวิดเจ็ต
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final levelData = quizColorLevels[controller.currentLevel];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox(
        width: context.screenWidth,
        height: context.screenHeight,
        child: Stack(
          children: [
            //------ Objective Image -----
            Positioned(
                top: screenSize.height * 0.25,
                left: screenSize.width * 0.15,
                child: SizedBox(
                  width: screenSize.width * 0.35,
                  child: Image.asset(levelData.objectiveImagePath),
                )),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(150, 80, 80, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: levelData.optionColors
                      .map(
                        (color) => Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomButton(
                              onTap: () => _handleColorTap(color),
                              child: Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  color: color,
                                  border:
                                      Border.all(width: 4, color: Colors.black),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                            // ✅ ถ้าตอบถูก: แสดง Popup Check ตรงปุ่ม
                            if (correctAnswered.contains(color))
                              AnimatedPopupTemplate(
                                child: Image.asset(
                                    'assets/images/shapegame/check.png',
                                    width: 150),
                              ),
                            if (wrongAnswers.contains(color))
                              Center(
                                child: AnimatedPopupTemplate(
                                  child: Image.asset(
                                    'assets/images/shapegame/cross.png',
                                    width: 150,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            Positioned(
                top: screenSize.height * 0.08,
                left: screenSize.width * 0.05,
                child: _buildLifeBar()),
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
              index < controller.hp
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
