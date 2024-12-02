import 'package:firstly/screens/dotgamelist.dart';
import 'package:flutter/material.dart';

class QuizLevel1 extends StatefulWidget {
  @override
  _QuizLevel1State createState() => _QuizLevel1State();
}

class _QuizLevel1State extends State<QuizLevel1> {
  int correctAnswer = 4;
  int? selectedAnswer;

  int starCount = 0;

  // ฟังก์ชันตรวจคำตอบ
  void checkAnswer() {
    if (selectedAnswer == correctAnswer) {
      setState(() {
        starCount = 1; // เพิ่มจำนวนดาวเมื่อคำตอบถูกต้อง
      });
      showResultDialog(true);
    } else {
      showResultDialog(false);
    }
  }

  void onBackButtonPressed() {
    Navigator.pop(context, {
      'earnedStars': starCount,
      'starColor': 'purple', // สีของดาว
    });
  }

  // ฟังก์ชันแสดงผลเมื่อผ่านด่านหรือไม่
  void showResultDialog(bool isCorrect) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? "Level Complete" : "Level Failed"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCorrect)
                const Icon(Icons.star, color: Colors.purple, size: 50),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // ปิด AlertDialog
                      onBackButtonPressed(); // ส่งค่ากลับไปยัง DotGameList เมื่อกด "ย้อนกลับ"
                    },
                    child: const Text("Back"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // ปิด AlertDialog
                      onBackButtonPressed(); // ส่งค่ากลับไปยัง DotGameList เมื่อกด "ไปต่อ"
                    },
                    child: const Text("Next"),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // สร้างตำแหน่งภาพซ้ำ
  List<Widget> buildPositionedImages() {
    List<Widget> positionedImages = [];
    List<Map<String, double>> positions = [
      {'top': -150, 'right': -100, 'width': 400, 'height': 400},
      {'top': 70, 'left': 150, 'width': 140, 'height': 140},
      {'top': 220, 'left': 550, 'width': 180, 'height': 180},
      {'bottom': -50, 'right': 30, 'width': 300, 'height': 300},
      {'bottom': -80, 'left': -60, 'width': 400, 'height': 400},
    ];

    for (var position in positions) {
      positionedImages.add(Positioned(
        top: position['top'],
        left: position['left'],
        right: position['right'],
        bottom: position['bottom'],
        child: Center(
          // child: ColorFiltered(
          //   colorFilter: ColorFilter.mode(
          //       const Color.fromARGB(255, 255, 170, 59).withOpacity(0.9),
          //       BlendMode.srcATop),
          child: Image.asset(
            'assets/images/quizdot/bg_elm.png',
            width: position['width'],
            height: position['height'],
            fit: BoxFit.contain,
          ),
          //),
        ),
      ));
    }

    return positionedImages;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // พื้นหลัง
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/dotchapter/bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // ภาพ Positioned
          ...buildPositionedImages(),
          Positioned(
            left: 16,
            top: 16,
            child: FloatingActionButton(
              onPressed: () {
                onBackButtonPressed();
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const DotGameList(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, -1.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;

                      final tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 1000),
                  ),
                );
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 50,
                color: Color.fromARGB(255, 21, 21, 21),
              ),
            ),
          ),
          // เนื้อหาหลัก
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Positioned(
                  width: screenSize.width * 0.3,
                  height: screenSize.height * 0.3,
                  child: const Padding(padding: EdgeInsets.all(15)),
                ),
                // Widget โจทย์
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      diceImage(1, screenSize),
                      SizedBox(width: screenSize.width * 0.055),
                      diceImage(2, screenSize),
                      SizedBox(width: screenSize.width * 0.055),
                      diceImage(3, screenSize),
                      SizedBox(width: screenSize.width * 0.055),
                      DragTarget<int>(
                        onAcceptWithDetails: (details) {
                          setState(() {
                            selectedAnswer = details.data;
                          });
                          checkAnswer();
                        },
                        onWillAcceptWithDetails: (details) => true,
                        builder: (context, candidateData, rejectedData) {
                          double answersBox = screenSize.width * 0.12;
                          return SizedBox(
                            width: answersBox,
                            child: Center(
                              child: selectedAnswer != null
                                  ? diceImage(selectedAnswer!, screenSize)
                                  : Image.asset(
                                      'assets/images/quizdot/dice_answers.png',
                                      width: answersBox,
                                      height: answersBox,
                                    ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Widget คำตอบ
                Container(
                  padding: const EdgeInsets.all(10.0),
                  width: screenSize.width * 0.65,
                  height: screenSize.height * 0.45,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/quizdot/bar.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      draggableDice(2),
                      draggableDice(3),
                      draggableDice(4),
                      draggableDice(5),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget สำหรับรูปลูกเต๋า
  Widget diceImage(int dots, Size screenSize) {
    double diceSize = screenSize.width * 0.115;
    return Container(
      width: diceSize,
      height: diceSize,
      child: Image.asset('assets/images/quizdot/dice_$dots.png'),
    );
  }

  // Widget สำหรับลูกเต๋าที่ลากได้
  Widget draggableDice(int dots) {
    return Draggable<int>(
      data: dots, // รูปปกติ
      feedback: Transform.rotate(
        angle: 0.2,
        child: Container(
          width: 170,
          height: 170,
          child: diceImage(dots, MediaQuery.of(context).size),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: diceImage(dots, MediaQuery.of(context).size),
      ),
      child: diceImage(dots, MediaQuery.of(context).size),
    );
  }
}
