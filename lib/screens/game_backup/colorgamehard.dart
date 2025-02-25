// ignore_for_file: sort_child_properties_last

import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:confetti/confetti.dart'; // เพิ่มแพ็กเกจ Confetti

class ColorGameHard extends StatefulWidget {
  const ColorGameHard({super.key});

  @override
  _ColorGameHardState createState() => _ColorGameHardState();
}

class _ColorGameHardState extends State<ColorGameHard>
    with TickerProviderStateMixin {
  // รายการสีของไพ่ AI และผู้เล่น
  List<Color> aiCards = [Colors.red, Colors.green, Colors.blue, Colors.yellow];
  List<Color> playerCards = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow
  ];

  // ตำแหน่งของไพ่ AI
  List<int> aiCardPositions = [0, 1, 2, 3];

  // ตัวแปรควบคุมการแสดงไพ่
  bool aiCardsFaceUp = true;

  // คะแนนและจำนวนครั้งที่ผู้เล่นพยายาม
  int score = 0;
  int attempts = 0;

  // ติดตามว่าไพ่ใบไหนถูกจัดเรียงถูกต้องแล้ว
  List<bool> correctCards = [false, false, false, false];

  // ตัวแปรตรวจสอบการจบเกม
  bool gameCompleted = false;

  // ตัวควบคุม Confetti
  late ConfettiController _confettiControllerLeft;
  late ConfettiController _confettiControllerCenter;
  late ConfettiController _confettiControllerRight;

  @override
  void initState() {
    super.initState();

    // เริ่มเกม
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startGame();
    });

    // เริ่มต้น Confetti Controllers
    _confettiControllerLeft =
        ConfettiController(duration: Duration(seconds: 4));
    _confettiControllerCenter =
        ConfettiController(duration: Duration(seconds: 3));
    _confettiControllerRight =
        ConfettiController(duration: Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiControllerLeft.dispose();
    _confettiControllerCenter.dispose();
    _confettiControllerRight.dispose();
    super.dispose();
  }

  void startGame() {
    // แสดงไพ่ของ AI เป็นเวลา 3 วินาที
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        aiCardsFaceUp = false;
      });
      // รอเวลา 2 วินาทีก่อนเริ่มอนิเมชั่น
      Future.delayed(Duration(seconds: 2), () {
        shuffleAICards(3); // สับไพ่ 3 ครั้ง
      });
    });
  }

  void shuffleAICards(int times) {
    if (times <= 0) {
      return;
    }
    // สับตำแหน่งของไพ่ AI พร้อมอนิเมชั่น
    setState(() {
      aiCardPositions.shuffle();
    });

    // รอให้อนิเมชั่นเสร็จสิ้นก่อนสับครั้งต่อไป
    Future.delayed(const Duration(milliseconds: 1200), () {
      shuffleAICards(times - 1);
    });
  }

  void checkCards() {
    // ตรวจสอบว่าไพ่ของผู้เล่นตรงกับไพ่ของ AI หรือไม่
    attempts++;
    int pointsPerCard = 250 - (attempts - 1) * 50;
    int roundScore = 0;

    for (int i = 0; i < playerCards.length; i++) {
      int aiIndex = aiCardPositions.indexOf(i);
      if (!correctCards[i] && playerCards[i] == aiCards[aiIndex]) {
        correctCards[i] = true;
        roundScore += pointsPerCard;
      }
    }

    setState(() {
      score += roundScore;
    });

    // ตรวจสอบว่าผู้เล่นจัดเรียงไพ่ถูกทั้งหมดหรือไม่
    if (correctCards.every((element) => element)) {
      // รอให้ไพ่แสดงผลเสร็จ 1 วินาที
      Future.delayed(Duration(milliseconds: 200), () {
        // เริ่มอนิเมชั่น Confetti
        _confettiControllerLeft.play();
        _confettiControllerCenter.play();
        _confettiControllerRight.play();

        // รอจนอนิเมชั่น Confetti จบ (2 วินาที)
        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            gameCompleted = true;
          });
        });
      });
    }
  }

  int getStars() {
    if (score >= 1000) {
      return 3;
    } else if (score >= 700 && score <= 999) {
      return 2;
    } else {
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI หลัก
    return Scaffold(
      // ไม่ใช้ AppBar ตามที่กำหนด
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ย้อนกลับไปหน้าก่อนหน้า
          Navigator.pop(context);
        },
        child: Icon(Icons.arrow_back),
      ),
      body: Stack(
        children: [
          gameCompleted ? buildGameCompleteWidget() : buildGameWidget(),
          // Confetti Effects
          buildConfettiWidget(_confettiControllerLeft, Alignment.bottomLeft),
          buildConfettiWidget(
              _confettiControllerCenter, Alignment.bottomCenter),
          buildConfettiWidget(_confettiControllerRight, Alignment.bottomRight),
        ],
      ),
    );
  }

  Widget buildConfettiWidget(
      ConfettiController controller, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: ConfettiWidget(
        confettiController: controller,
        blastDirection: -pi / 2, // ทิศทางขึ้นบน
        emissionFrequency: 0.05,
        numberOfParticles: 20,
        maxBlastForce: 20,
        minBlastForce: 10,
        gravity: 0.1,
        shouldLoop: false,
        colors: [Colors.red, Colors.green, Colors.blue, Colors.yellow],
      ),
    );
  }

  Widget buildGameWidget() {
    return SafeArea(
      child: Column(
        children: [
          // Score Board
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Text('คะแนน: $score', style: TextStyle(fontSize: 24)),
          ),
          Padding(padding: EdgeInsets.all(50)),
          // ไพ่ของ AI
          Expanded(
            child: Center(
              child: buildAICards(),
            ),
          ),
          // ไพ่ของผู้เล่น
          Expanded(
            child: Center(
              child: buildPlayerCards(),
            ),
          ),
          // ปุ่ม Submit
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: checkCards,
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAICards() {
    // สร้างไพ่ของ AI พร้อมอนิเมชั่นการสับไพ่
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = 60;
        double spacing = 30;
        double totalWidth =
            (cardWidth * aiCards.length) + (spacing * (aiCards.length - 1));
        double startX = (constraints.maxWidth - totalWidth) / 2;

        return Stack(
          children: List.generate(aiCards.length, (index) {
            int position = aiCardPositions[index];
            return AnimatedPositioned(
              duration: Duration(milliseconds: 1200),
              curve: Curves.easeInOut,
              left: startX + position * (cardWidth + spacing),
              top: 0,
              child: Container(
                width: cardWidth,
                height: 90,
                decoration: BoxDecoration(
                  color: aiCardsFaceUp || correctCards[position]
                      ? aiCards[index]
                      : Colors.grey,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget buildPlayerCards() {
    // สร้างไพ่ของผู้เล่นที่สามารถลากได้
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(playerCards.length, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Draggable<int>(
            data: index,
            child: DragTarget<int>(
              onAccept: (fromIndex) {
                setState(() {
                  // สลับไพ่ของผู้เล่น
                  var temp = playerCards[fromIndex];
                  playerCards[fromIndex] = playerCards[index];
                  playerCards[index] = temp;
                });
              },
              builder: (context, acceptedItems, rejectedItems) {
                return Container(
                  width: 60,
                  height: 90,
                  decoration: BoxDecoration(
                    color: playerCards[index],
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
            feedback: Material(
              child: Container(
                width: 60,
                height: 90,
                decoration: BoxDecoration(
                  color: playerCards[index].withOpacity(0.7),
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            childWhenDragging: Container(
              width: 60,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget buildGameCompleteWidget() {
    // สร้าง Widget เมื่อจบเกม
    int stars = getStars();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Level Complete', style: TextStyle(fontSize: 32)),
          SizedBox(height: 20),
          // แสดงดาวตามคะแนน
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Icon(
                index < stars ? Icons.star : Icons.star_border,
                size: 40,
                color: Colors.yellow,
              );
            }),
          ),
          SizedBox(height: 20),
          Text('คะแนน: $score', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          // ปุ่มนำทาง
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // ย้อนกลับหรือเริ่มเกมใหม่
                  Navigator.pop(context);
                },
                child: Text('Back'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  // ไปยังระดับถัดไปหรือทำการอื่น
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
