import 'dart:ui';
import 'package:firstly/widgets/result_widget_quiz.dart';
import 'package:firstly/screens/dotgamelist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../function/background_audio_manager.dart';

class DotQuizGame extends StatefulWidget {
  final String starColor;
  final int earnedStars;
  const DotQuizGame({
    super.key,
    required this.starColor,
    required this.earnedStars,
  });

  @override
  _DotQuizGameState createState() => _DotQuizGameState();
}

class _DotQuizGameState extends State<DotQuizGame>
    with TickerProviderStateMixin {
  int currentLevel = 1;
  int hearts = 3;
  int? selectedAnswer;
  List<int?> selectedAnswers = [null, null];
  final PageController _pageController = PageController();
  double _buttonScale = 1.0;
  bool showResult = false;
  bool isWin = false;
  bool showTutorial = true;
  bool showGreenFlash = false;
  bool showRedFlash = false;

  bool isWarningVisible = false;

  @override
  void initState() {
    super.initState();

    // เล่นเสียง HintButtonSound ทันทีที่เกมเริ่ม
    Future.delayed(Duration(milliseconds: 500), () {
      BackgroundAudioManager().playHintButtonSound();
    });
  }

  final List<Map<String, dynamic>> levels = [
    {
      'questionDices': [1],
      'correctAnswer': [2],
      'diceNumbers': [2],
    },
    {
      'questionDices': [1, 2],
      'correctAnswer': [3],
      'diceNumbers': [2, 3],
    },
    {
      'questionDices': [1, 2, 3],
      'correctAnswer': [4],
      'diceNumbers': [3, 4, 5],
    },
    {
      'backgroundImage': 'assets/images/quizdot/question_4.png',
      'correctAnswer': [400],
      'diceNumbers': [400, 900],
      'margin': EdgeInsets.fromLTRB(300, 90, 0, 0),
    },
    {
      'backgroundImage': 'assets/images/quizdot/question_5.png',
      'correctAnswer': [42],
      'diceNumbers': [40, 50, 42],
      'margin': EdgeInsets.fromLTRB(70, 90, 0, 0),
    },
    {
      'backgroundImage': 'assets/images/quizdot/question_6.png',
      'correctAnswer': [240, 270],
      'diceNumbers': [240, 250, 260, 270],
      'margins': [
        EdgeInsets.fromLTRB(40, 40, 0, 0),
        EdgeInsets.fromLTRB(40, 40, 0, 0),
      ],
    },
  ];

  void showWarning(BuildContext context) {
    // ถ้ากำลังแสดง popup อยู่ ไม่ต้องแสดงซ้ำ
    if (isWarningVisible) return;

    // ตั้งค่าสถานะให้กำลังแสดง popup
    setState(() {
      isWarningVisible = true; // ตั้งค่าว่าแอนิเมชันกำลังทำงาน
    });

    // สร้าง AnimationController สำหรับอนิเมชันการเลื่อนเข้าและออก
    final animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // สร้าง OverlayEntry สำหรับ Pop-up
    late OverlayEntry overlayEntry;

    // ฟังก์ชันสำหรับลบ OverlayEntry
    void removeOverlay() {
      animationController.reverse().then((value) {
        overlayEntry.remove();
        animationController.dispose();
        setState(() {
          isWarningVisible = false; // รีเซ็ตสถานะเมื่อแอนิเมชันเสร็จสิ้น
        });
      });
    }

    // สร้าง OverlayEntry
    overlayEntry = OverlayEntry(
      builder: (context) {
        // สร้างอนิเมชันการเลื่อน
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, -1.0), // เริ่มจากนอกหน้าจอด้านบน
          end: const Offset(0.0, 0.0), // เลื่อนเข้ามาในหน้าจอ
        ).animate(CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOut,
        ));

        return Positioned(
          top: MediaQuery.of(context).size.height * 0, // ตำแหน่งบนหน้าจอ
          right:
              MediaQuery.of(context).size.width * 0.35, // ตำแหน่งขวาของหน้าจอ
          child: SlideTransition(
            position: slideAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.3,
                height: MediaQuery.of(context).size.height * 0.2,
                child: Image.asset(
                  'assets/images/dotchapter/unlock_notification.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );

    // แสดง OverlayEntry
    Overlay.of(context).insert(overlayEntry);

    // เริ่มอนิเมชันเลื่อนเข้า
    animationController.forward();

    // ตั้งเวลาให้ Pop-up แสดงผล 2 วินาที แล้วเลื่อนออก
    Future.delayed(const Duration(seconds: 2), () {
      removeOverlay();
    });
  }

  // ฟังก์ชันเช็คคำตอบของด่าน 1-5
  void checkAnswer() {
    final correctAnswers =
        levels[currentLevel - 1]['correctAnswer'] as List<int>;
    if (currentLevel <= 5) {
      if (selectedAnswer != null && correctAnswers.contains(selectedAnswer)) {
        // เล่นเสียงเมื่อผู้เล่นตอบถูก
        BackgroundAudioManager().playCorrectAnswerQuizDotSound();
        moveToNextLevel();
      } else {
        _onWrongAnswer();
      }
    } else if (currentLevel == 6) {
      if (selectedAnswers[0] == correctAnswers[0] &&
          selectedAnswers[1] == correctAnswers[1]) {
        // เล่นเสียงเมื่อผู้เล่นตอบถูก
        BackgroundAudioManager().playCorrectAnswerQuizDotSound();
        moveToNextLevel();
      } else {
        _onWrongAnswer();
      }
    }
  }

  void moveToNextLevel() {
    setState(() {
      // แสดงเอฟเฟกต์สั่น
      HapticFeedback.mediumImpact();
      // แสดงแสงสีเขียว
      showGreenFlash = true;
    });

    // ตั้งเวลาให้แสงสีเขียวหายไปหลังจาก 300ms
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        showGreenFlash = false;
      });
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (currentLevel < levels.length) {
        setState(() {
          currentLevel++;
          selectedAnswer = null;
          if (currentLevel == 6) {
            selectedAnswers = [null, null];
          }
        });
        _pageController.animateToPage(
          currentLevel - 1,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } else {
        _endGame(true);
      }
    });
  }

  void _onWrongAnswer() {
    setState(() {
      // เล่นเสียงเมื่อตอบผิด
      BackgroundAudioManager().playWrongAnswerQuizDotSound();
      // สั่นเบาๆ
      HapticFeedback.mediumImpact();
      // แสดงไฟสีแดง
      showRedFlash = true;
    });

    // ตั้งเวลาให้แสงสีแดงหายไปหลังจาก 300ms
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        showRedFlash = false;
      });
      decreaseHearts();
    });
  }

  void _onPressResetButton() {
    // รีเซ็ตสถานะเกม
    setState(() {
      // รีเซ็ตค่าที่จำเป็น
      selectedAnswer = null;
      selectedAnswers = [null, null];
      hearts = 3; // คืนค่าหัวใจ
      currentLevel = 1; // กลับไปเริ่มต้นที่ด่านแรก
      _pageController.jumpToPage(0); // กลับไปที่หน้าด่านแรก
      showResult = false;
    });
  }

  void decreaseHearts() {
    setState(() {
      hearts--;
      if (hearts <= 0) {
        _endGame(true);
      }
    });
  }

  void _endGame(bool isWin) {
    setState(() {
      this.isWin = isWin; // เก็บผลลัพธ์ของเกม
      showResult = true; // แสดง ResultWidget
    });
  }

  Widget draggableDice(int diceNumber) {
    double imageWidth = MediaQuery.of(context).size.width;
    double imageHeight = MediaQuery.of(context).size.height;

    return Draggable<int>(
      data: diceNumber,
      onDragStarted: () {
        // เล่นเสียงลากลูกเต๋าเมื่อเริ่มลาก (แค่ครั้งเดียว)
        BackgroundAudioManager().playDragDiceSound();
      },
      onDragEnd: (details) {
        // หยุดเสียงเมื่อปล่อยลูกเต๋า
        BackgroundAudioManager().stopDragDiceSound();
      },
      onDragCompleted: () {
        // หยุดเสียงเมื่อวางสำเร็จ
        BackgroundAudioManager().stopDragDiceSound();
      },
      feedback: Transform.rotate(
        angle: 0.2,
        child: Image.asset(
          'assets/images/quizdot/dice_$diceNumber.png',
          width: imageWidth * 0.15,
          height: imageHeight * 0.225,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: Image.asset(
          'assets/images/quizdot/dice_$diceNumber.png',
          width: imageWidth * 0.1,
          height: imageHeight * 0.2,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          // เล่นเสียงคลิกเมื่อลูกเต๋าถูกแตะ
          BackgroundAudioManager().playClickDiceSound();
        },
        child: Image.asset(
          'assets/images/quizdot/dice_$diceNumber.png',
          width: imageWidth * 0.125,
          height: imageHeight * 0.2,
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    Size buttonSize = MediaQuery.of(context).size;
    double buttonWidth = MediaQuery.of(context).size.width * 0.028;
    double buttonHeight = MediaQuery.of(context).size.height * 0.028;
    return Positioned(
      width: buttonSize.width * 0.045,
      height: buttonSize.height * 0.085,
      left: buttonWidth,
      top: buttonHeight,
      child: FloatingActionButton(
        onPressed: () {
          BackgroundAudioManager()
              .playButtonBackSound(); // เล่นเสียงเมื่อสัมผัสหน้าจ
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const DotGameList(),
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
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: buttonSize.width * 0.05,
          color: const Color.fromARGB(255, 21, 21, 21),
        ),
      ),
    );
  }

  Widget buildHearts() {
    double imageWidth = MediaQuery.of(context).size.width;
    double imageHeight = MediaQuery.of(context).size.height;
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/images/quizdot/hearts_bg.png',
          width: imageWidth * 0.25,
          height: imageHeight * 0.25,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Image.asset(
                index < hearts
                    ? 'assets/images/quizdot/full_heart.png'
                    : 'assets/images/quizdot/empty_heart.png',
                width: imageWidth * 0.05,
                height: imageHeight * 0.08,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTutorialWidget() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        BackgroundAudioManager().playCloseHintButtonSound();
        setState(() {
          showTutorial = false; // ปิดวิดเจ็ตเมื่อผู้ใช้คลิก
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 1,
        color: Colors.black.withOpacity(0.7), // พื้นหลังโปร่งแสง
        child: Center(
          child: SizedBox(
            width: screenWidth * 0.6,
            height: screenHeight * 0.7,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                'assets/images/Hint4.png', // แก้รูปภาพการสอน
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double imageWidth = MediaQuery.of(context).size.width * 0.2;
    double imageHeight = MediaQuery.of(context).size.height * 0.35;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final levelData = levels[index];
              final questionDices = levelData['questionDices'] as List<int>?;
              final diceNumbers = levelData['diceNumbers'] as List<int>;
              final backgroundImage = levelData['backgroundImage'] as String?;

              return Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/images/quizdot/bg_grid_quizdot.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  // รูปโปร่งขนาดเต็มจอ
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/quizdot/transparent_overlay.png', // ไฟล์รูปภาพที่โปร่ง
                      fit: BoxFit.cover,
                    ),
                  ),

                  // เพิ่มรูปดาว 3 รูป
                  Positioned(
                    top: screenHeight * 0.01,
                    left: screenWidth * 0.01,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: 3.0, // ค่าความฟุ้งในแกน X
                        sigmaY: 3.0, // ค่าความฟุ้งในแกน Y
                      ),
                      child: Transform.rotate(
                        angle: 45 *
                            3.14159 /
                            180, // หมุนภาพ 45 องศา (แปลงเป็นเรเดียน)
                        child: Image.asset(
                          'assets/images/quizdot/bg_elm.png', // รูปภาพ
                          width: screenWidth * 0.18, // ปรับขนาด
                          height: screenHeight * 0.3, // ปรับขนาด
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: screenHeight * -0.22,
                    left: screenWidth * -0.1,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: 3.0, // ค่าความฟุ้งในแกน X
                        sigmaY: 3.0, // ค่าความฟุ้งในแกน Y
                      ),
                      child: Transform.rotate(
                        angle: 35 *
                            3.14159 /
                            180, // หมุนภาพ 45 องศา (แปลงเป็นเรเดียน)
                        child: Image.asset(
                          'assets/images/quizdot/bg_elm.png', // รูปภาพ
                          width: screenWidth * 0.4, // ปรับขนาด
                          height: screenHeight * 0.7, // ปรับขนาด
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: screenHeight * 0.035,
                    right: screenWidth * 0.01,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: 3.0, // ค่าความฟุ้งในแกน X
                        sigmaY: 3.0, // ค่าความฟุ้งในแกน Y
                      ),
                      child: Transform.rotate(
                        angle: 25 *
                            3.14159 /
                            180, // หมุนภาพ 45 องศา (แปลงเป็นเรเดียน)
                        child: Image.asset(
                          'assets/images/quizdot/bg_elm.png', // รูปภาพ
                          width: screenWidth * 0.25, // ปรับขนาด
                          height: screenHeight * 0.35, // ปรับขนาด
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (questionDices != null && index <= 3)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // กลุ่มลูกเต๋าโจทย์
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: questionDices.map((dice) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Image.asset(
                                      'assets/images/quizdot/dice_$dice.png',
                                      width: imageWidth - 50,
                                      height: imageHeight - 50,
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(
                                  width:
                                      20), // เว้นระยะระหว่างกลุ่มลูกเต๋าและ DragTarget
                              // ช่องว่างสำหรับใส่คำตอบ
                              Row(
                                children: [
                                  DragTarget<int>(
                                    onAcceptWithDetails: (detail) {
                                      setState(() {
                                        selectedAnswer = detail.data;
                                      });

                                      // เล่นเสียง pasteDice เมื่อวางลูกเต๋าลงช่องสำเร็จ
                                      BackgroundAudioManager()
                                          .playPasteDiceSound();
                                    },
                                    builder:
                                        (context, candidateData, rejectedData) {
                                      return Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // รูปภาพแทนช่องว่าง
                                          Image.asset(
                                            'assets/images/quizdot/dice_answers.png',
                                            width: imageWidth - 50,
                                            height: imageWidth - 50,
                                          ),
                                          // ถ้าผู้เล่นเลือกคำตอบจะแสดงคำตอบที่เลือก
                                          if (selectedAnswer != null)
                                            Image.asset(
                                              'assets/images/quizdot/dice_$selectedAnswer.png', // แสดงรูปคำตอบ
                                              width: imageWidth - 50,
                                              height: imageHeight - 50,
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        if (backgroundImage != null &&
                            (currentLevel == 4 || currentLevel == 5))
                          Stack(
                            children: [
                              // รูปโจทย์
                              Image.asset(
                                backgroundImage,
                                width: screenWidth * 0.45,
                                height: screenHeight * 0.45,
                              ),

                              // DragTarget สำหรับช่องว่าง
                              if (currentLevel == 4)
                                Positioned(
                                  top: screenHeight *
                                      0.15, // ตำแหน่งแนวตั้งสำหรับด่าน 4
                                  left: screenWidth *
                                      0.28, // ตำแหน่งแนวนอนสำหรับด่าน 4
                                  child: DragTarget<int>(
                                    onAcceptWithDetails: (detail) {
                                      setState(() {
                                        selectedAnswer = detail.data;
                                        BackgroundAudioManager()
                                            .playPasteDiceSound();
                                      });
                                    },
                                    builder:
                                        (context, candidateData, rejectedData) {
                                      return Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/quizdot/pattern_answers.png', // รูป empty ที่ต้องการเพิ่ม
                                            width:
                                                imageWidth - 50, // ขนาดของช่อง
                                            height: imageHeight - 50,
                                          ),
                                          if (selectedAnswer != null)
                                            Image.asset(
                                              'assets/images/quizdot/dice_$selectedAnswer.png',
                                              width: imageWidth - 50,
                                              height: imageHeight - 50,
                                            )
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              if (currentLevel == 5)
                                Positioned(
                                  top: screenHeight *
                                      0.12, // ตำแหน่งแนวตั้งสำหรับด่าน 5
                                  left: screenWidth *
                                      0.025, // ตำแหน่งแนวนอนสำหรับด่าน 5
                                  child: DragTarget<int>(
                                    onAcceptWithDetails: (detail) {
                                      setState(() {
                                        selectedAnswer = detail.data;
                                        BackgroundAudioManager()
                                            .playPasteDiceSound();
                                      });
                                    },
                                    builder:
                                        (context, candidateData, rejectedData) {
                                      return Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/quizdot/pattern_answers.png', // รูป empty ที่ต้องการเพิ่ม
                                            width:
                                                imageWidth - 30, // ขนาดของช่อง
                                            height: imageHeight - 30,
                                          ),
                                          if (selectedAnswer != null)
                                            Image.asset(
                                              'assets/images/quizdot/dice_$selectedAnswer.png',
                                              width: imageWidth - 30,
                                              height: imageHeight - 30,
                                            )
                                        ],
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        if (backgroundImage != null && currentLevel == 6)
                          Stack(
                            children: [
                              Image.asset(
                                backgroundImage,
                                width: screenWidth * 0.5,
                                height: screenHeight * 0.5,
                                fit: BoxFit.contain,
                              ),
                              // DragTarget ช่องที่ 1
                              Positioned(
                                left: screenWidth * 0.057, // ตำแหน่ง X
                                top: screenHeight * 0.03, // ตำแหน่ง Y
                                child: DragTarget<int>(
                                  onAcceptWithDetails: (detail) {
                                    setState(() {
                                      selectedAnswers[0] = detail.data;
                                      BackgroundAudioManager()
                                          .playPasteDiceSound(); // เพิ่มเสียง
                                    });
                                  },
                                  builder:
                                      (context, candidateData, rejectedData) {
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/quizdot/pattern_answers.png', // รูป empty ที่ต้องการเพิ่ม
                                          width: imageWidth - 50, // ขนาดของช่อง
                                          height: imageHeight - 50,
                                        ),
                                        if (selectedAnswers[0] != null)
                                          Image.asset(
                                            'assets/images/quizdot/dice_${selectedAnswers[0]}.png',
                                            width: imageHeight - 50,
                                            height: imageHeight - 50,
                                          )
                                        else
                                          const Icon(Icons.help_outline,
                                              size: 50, color: Colors.grey),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              // DragTarget ช่องที่ 2
                              Positioned(
                                left: screenWidth * 0.33, // ตำแหน่ง X
                                top: screenHeight * 0.2, // ตำแหน่ง Y
                                child: DragTarget<int>(
                                  onAcceptWithDetails: (detail) {
                                    setState(() {
                                      selectedAnswers[1] = detail.data;
                                      BackgroundAudioManager()
                                          .playPasteDiceSound(); // เพิ่มเสียง
                                    });
                                  },
                                  builder:
                                      (context, candidateData, rejectedData) {
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/quizdot/pattern_answers.png', // รูป empty ที่ต้องการเพิ่ม
                                          width: imageWidth - 50, // ขนาดของช่อง
                                          height: imageHeight - 50,
                                        ),
                                        if (selectedAnswers[1] != null)
                                          Image.asset(
                                            'assets/images/quizdot/dice_${selectedAnswers[1]}.png',
                                            width: imageWidth - 50,
                                            height: imageHeight - 50,
                                          )
                                        else
                                          const Icon(Icons.help_outline,
                                              size: 50, color: Colors.grey),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 50),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IntrinsicWidth(
                              child: IntrinsicHeight(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(
                                      screenWidth * 0.135, 0, 0, 0),
                                  padding:
                                      const EdgeInsets.fromLTRB(40, 20, 40, 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                        color: Colors.black, width: 8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: diceNumbers.map((dice) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: draggableDice(dice),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 30),
                            AnimatedScale(
                              scale: _buttonScale,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: GestureDetector(
                                onTapDown: (_) {
                                  setState(() {
                                    _buttonScale = 0.9;
                                  });
                                },
                                onTapUp: (_) {
                                  setState(() {
                                    _buttonScale = 1.0;
                                  });
                                  if (currentLevel < 6 &&
                                      selectedAnswer != null) {
                                    checkAnswer();
                                  } else if (currentLevel == 6 &&
                                      selectedAnswers[0] != null &&
                                      selectedAnswers[1] != null) {
                                    checkAnswer();
                                  } else {
                                    // หากยังไม่มีคำตอบ ไม่ทำอะไร หรืออาจจะโชว์ข้อความแจ้งเตือน
                                    showWarning(context);
                                  }
                                },
                                onTapCancel: () {
                                  setState(() {
                                    _buttonScale = 1.0;
                                  });
                                },
                                child: Container(
                                  width: screenWidth * 0.15,
                                  height: screenHeight * 0.3,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/quizdot/send.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          // เลเยอร์แสงสีเขียว (จะถูกแสดงก็ต่อเมื่อ showGreenFlash = true)
          if (showGreenFlash)
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center, // จุดศูนย์กลางของ gradient
                  radius: 0.99, // รัศมีของ gradient
                  colors: [
                    Colors.transparent, // สีที่ตรงกลางเป็นโปร่งใส
                    const Color.fromARGB(255, 7, 255, 57)
                        .withOpacity(0.5), // สีที่ขอบ
                  ],
                  stops: [0.0, 1.0], // จุดที่เปลี่ยนสี
                ),
              ),
            ),
          if (showRedFlash)
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center, // จุดศูนย์กลางของ gradient
                  radius: 0.99, // รัศมีของ gradient
                  colors: [
                    Colors.transparent, // สีที่ตรงกลางเป็นโปร่งใส
                    const Color.fromARGB(255, 255, 40, 40)
                        .withOpacity(0.5), // สีที่ขอบ
                  ],
                  stops: [0.0, 1.0], // จุดที่เปลี่ยนสี
                ),
              ),
            ),
          _buildBackButton(context),
          Positioned(
            top: screenWidth * 0.01,
            right: screenHeight * 0.02,
            child: buildHearts(),
          ),
          Positioned(
            bottom: screenHeight * 0.05,
            right: screenWidth * 0.05,
            child: FloatingActionButton(
                onPressed: () {
                  BackgroundAudioManager().playHintButtonSound();
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
          // แสดง ResultWidget เมื่อ showResult เป็น true
          if (isWin && showResult)
            ResultWidgetQuiz(
              onLevelComplete: true,
              starsEarned: 1,
              onButton1Pressed: () {
                setState(() {
                  _onPressResetButton();
                });
              },
              onButton2Pressed: () {
                // กดปุ่มไปต่อ
                Navigator.pop(context, {
                  'earnedStars': 1,
                  'starColor': 'purple',
                });
              },
            ),
          if (hearts <= 0 && showResult)
            ResultWidgetQuiz(
              onLevelComplete: false,
              starsEarned: 0,
              onButton1Pressed: () {
                setState(() {
                  _onPressResetButton();
                });
              },
              onButton2Pressed: () {
                // กดปุ่มไปต่อ
                Navigator.pop(
                  context,
                );
              },
            ),
        ],
      ),
    );
  }
}
