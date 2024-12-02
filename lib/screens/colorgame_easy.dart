import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart'; // สำหรับอนิเมชั่น confetti

// คลาสสำหรับเก็บข้อมูลรูปภาพและค่าสี
class ColorItem {
  final String imagePath; // เส้นทางของรูปภาพ
  final Color color; // ค่าสีของรูปภาพ

  // Constructor สำหรับสร้างวัตถุ ColorItem
  ColorItem({required this.imagePath, required this.color});
}

// StatefulWidget หลักของเกม
class GameColorEasyScreen extends StatefulWidget {
  const GameColorEasyScreen({Key? key}) : super(key: key);

  @override
  _GameColorEasyScreenState createState() => _GameColorEasyScreenState();
}

// สถานะของ GameColorEasyScreen
class _GameColorEasyScreenState extends State<GameColorEasyScreen> {
  // คะแนนของผู้เล่น
  int score = 0;

  // แผนที่สำหรับติดตามว่ารูปภาพใดถูกวางบนโหลใด (คู่ของ jarIndex และ imageIndex)
  Map<int, int> placedOnJar = {};

  // แผนที่สำหรับติดตามว่ารูปภาพถูกวางหรือยัง (คู่ของ 'image0', true/false)
  Map<String, bool> placedImages = {};

  // รายการของรูปภาพโจทย์ (รายการของ ColorItem)
  final List<ColorItem> questionItems = [
    ColorItem(
        imagePath: 'assets/images/questionImages/carrot.png',
        color: Colors.orange),
    ColorItem(
        imagePath: 'assets/images/questionImages/mushroom.png',
        color: Colors.red),
    ColorItem(
        imagePath: 'assets/images/questionImages/grap.png',
        color: Colors.purple),
    ColorItem(
        imagePath: 'assets/images/questionImages/apple.png',
        color: Colors.green),
    ColorItem(
        imagePath: 'assets/images/questionImages/blueberry.png',
        color: Colors.blue),
    ColorItem(
        imagePath: 'assets/images/questionImages/lemon.png',
        color: Colors.yellow),
  ];

  // รายการของรูปภาพโหล (คำตอบ) (รายการของ ColorItem)
  final List<ColorItem> jarItems = [
    ColorItem(
        imagePath: 'assets/images/jarAsset/jarred.png', color: Colors.red),
    ColorItem(
        imagePath: 'assets/images/jarAsset/jarblue.png', color: Colors.blue),
    ColorItem(
        imagePath: 'assets/images/jarAsset/jargreen.png', color: Colors.green),
    ColorItem(
        imagePath: 'assets/images/jarAsset/jaryellow_1.png',
        color: Colors.yellow),
    ColorItem(
        imagePath: 'assets/images/jarAsset/jarorange.png',
        color: Colors.orange),
    ColorItem(
        imagePath: 'assets/images/jarAsset/jarpurple.png',
        color: Colors.purple),
  ];

  // ตัวควบคุม confetti สำหรับอนิเมชั่นการฉลอง
  late ConfettiController _confettiController;

  // ตัวแปรเพื่อระบุว่าด่านถูกผ่านหรือไม่
  bool levelCompleted = false;

  @override
  void initState() {
    super.initState();
    // เริ่มต้นแผนที่ placedImages โดยกำหนดให้รูปภาพทุกภาพยังไม่ถูกวาง
    for (int i = 0; i < questionItems.length; i++) {
      placedImages['image$i'] = false;
    }
    // เริ่มต้นตัวควบคุม confetti โดยกำหนดระยะเวลา 2 วินาที
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    // ปล่อยทรัพยากรของ _confettiController เมื่อไม่ใช้งาน
    _confettiController.dispose();
    super.dispose();
  }

  // ฟังก์ชันตรวจสอบว่าทุกภาพถูกวางถูกต้องหรือไม่
  void checkLevelCompletion() {
    // ถ้ารูปภาพทุกภาพถูกวาง (ค่าใน placedImages ทั้งหมดเป็น true)
    if (placedImages.values.every((placed) => placed)) {
      setState(() {
        levelCompleted = true; // ระบุว่าด่านถูกผ่านแล้ว
      });
      // เริ่มอนิเมชั่น confetti
      _confettiController.play();
      // แสดง pop-up หลังจาก 1 วินาที
      Future.delayed(const Duration(seconds: 1), () {
        showLevelCompletionPopup();
      });
    }
  }

  // ฟังก์ชันแสดง pop-up เมื่อผ่านด่านหรือไม่ผ่านด่าน
  void showLevelCompletionPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // คำนวณจำนวนดาวตามคะแนน
        int stars = 0;
        if (score >= 0 && score <= 40) {
          stars = 1;
        } else if (score >= 41 && score <= 70) {
          stars = 2;
        } else if (score >= 71 && score >= 100) {
          stars = 3;
        }

        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // แสดงข้อความผ่านด่านหรือไม่ผ่านด่าน
              Text(levelCompleted ? 'ผ่านด่าน' : 'ไม่ผ่านด่าน'),
              const SizedBox(height: 20),
              // แสดงดาวตามจำนวนที่คำนวณได้
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    Icons.star,
                    color: index < stars ? Colors.yellow : Colors.grey,
                  );
                }),
              ),
              const SizedBox(height: 20),
              // แสดงปุ่มนำทาง (ย้อนกลับ, เริ่มใหม่, ไปต่อ)
              if (levelCompleted)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // ย้อนกลับ
                        Navigator.of(context).pop(); // ปิด dialog
                        Navigator.of(context).pop(); // กลับไปหน้าก่อนหน้า
                      },
                      child: const Text('ย้อนกลับ'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // ไปต่อ (ยังไม่ได้กำหนดฟังก์ชัน)
                        Navigator.of(context).pop(); // ปิด dialog
                        // เพิ่มฟังก์ชันการไปยังด่านถัดไป
                      },
                      child: const Text('ไปต่อ'),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // เริ่มเกมใหม่
                        Navigator.of(context).pop(); // ปิด dialog
                        resetGame(); // รีเซ็ตเกม
                      },
                      child: const Text('เริ่มใหม่'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // ย้อนกลับ
                        Navigator.of(context).pop(); // ปิด dialog
                        Navigator.of(context).pop(); // กลับไปหน้าก่อนหน้า
                      },
                      child: const Text('ย้อนกลับ'),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  // ฟังก์ชันรีเซ็ตเกมกลับสู่สถานะเริ่มต้น
  void resetGame() {
    setState(() {
      score = 0; // รีเซ็ตคะแนน
      levelCompleted = false; // รีเซ็ตสถานะด่าน
      placedImages.clear(); // ล้างข้อมูลรูปภาพที่ถูกวาง
      placedOnJar.clear(); // ล้างข้อมูลรูปภาพที่ถูกวางบนโหล
      // ตั้งค่าให้รูปภาพทุกภาพยังไม่ถูกวาง
      for (int i = 0; i < questionItems.length; i++) {
        placedImages['image$i'] = false;
      }
    });
  }

  // ฟังก์ชันสำหรับสร้างรายการวิดเจ็ตรูปภาพโจทย์
  Widget buildQuestionImages() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center, // จัดวางให้อยู่กึ่งกลาง
        spacing: 16.0, // ระยะห่างระหว่างวิดเจ็ตในแนวนอน
        runSpacing: 16.0, // ระยะห่างระหว่างวิดเจ็ตในแนวตั้ง
        children: List.generate(questionItems.length, (index) {
          return Draggable<String>(
            data: 'image$index', // กำหนดข้อมูลที่จะส่งเมื่อถูกลาก
            feedback: Image.asset(
              questionItems[index].imagePath,
              width: 120,
              height: 120,
            ), // รูปภาพที่แสดงขณะลาก
            childWhenDragging: const SizedBox(
              width: 120,
              height: 120,
              // แสดงกล่องสีเทาเมื่อถูกลากออกไป
            ),
            child: (placedImages['image$index'] ?? false)
                ? const SizedBox(
                    width: 120,
                    height: 120,
                    // ถ้ารูปภาพถูกวางแล้ว แสดงกล่องสีเทา
                  )
                : Image.asset(
                    questionItems[index].imagePath,
                    width: 120,
                    height: 120,
                  ), // รูปภาพโจทย์
          );
        }),
      ),
    );
  }

  // ฟังก์ชันสำหรับสร้างรายการวิดเจ็ตโหล (คำตอบ)
  Widget buildAnswerJars() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center, // จัดวางให้อยู่กึ่งกลาง
        spacing: 16.0, // ระยะห่างระหว่างวิดเจ็ตในแนวนอน
        runSpacing: 16.0, // ระยะห่างระหว่างวิดเจ็ตในแนวตั้ง
        children: List.generate(jarItems.length, (index) {
          return DragTarget<String>(
            onAccept: (data) {
              int imageIndex = int.parse(data.replaceAll('image', ''));
              if (questionItems[imageIndex].color == jarItems[index].color) {
                // ถ้าสีของรูปภาพตรงกับสีของโหล (วางถูกต้อง)
                setState(() {
                  placedImages[data] = true; // กำหนดว่ารูปภาพถูกวางแล้ว
                  placedOnJar[index] =
                      imageIndex; // บันทึกว่ารูปภาพใดถูกวางบนโหลใด
                  score += 20; // เพิ่มคะแนน
                });
                checkLevelCompletion(); // ตรวจสอบว่าผ่านด่านหรือไม่
              } else {
                // ถ้าวางไม่ถูกต้อง
                setState(() {
                  score -= 10; // ลดคะแนน
                });
              }
            },
            onWillAccept: (data) {
              // ยอมรับการลากเข้ามาถ้ารูปภาพยังไม่ถูกวาง
              return !(placedImages[data] ?? false);
            },
            builder: (context, candidateData, rejectedData) {
              return SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  children: [
                    // แสดงรูปภาพโหล
                    Image.asset(
                      jarItems[index].imagePath,
                      width: 180,
                      height: 180,
                    ),
                    // ถ้ามีรูปภาพถูกวางบนโหลนี้ แสดงรูปภาพโจทย์
                    if (placedOnJar.containsKey(index))
                      Image.asset(
                        questionItems[placedOnJar[index]!].imagePath,
                        width: 150,
                        height: 150,
                      ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        // Stack สำหรับวางวิดเจ็ตซ้อนกัน เช่น ปุ่มย้อนกลับและ confetti
        children: [
          // เนื้อหาหลักของเกม
          SafeArea(
            child: Column(
              children: [
                // วิดเจ็ตคะแนนที่มุมบนขวา
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'คะแนน: $score',
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                // วิดเจ็ตโจทย์ (รูปภาพ)
                Expanded(
                  flex: 5,
                  child: buildQuestionImages(),
                ),
                // วิดเจ็ตโหล (คำตอบ)
                Expanded(
                  flex: 5,
                  child: buildAnswerJars(),
                ),
              ],
            ),
          ),
          // ปุ่มย้อนกลับที่มุมบนซ้าย
          Positioned(
            top: 16,
            left: 16,
            child: FloatingActionButton(
              onPressed: () {
                // ย้อนกลับไปหน้าก่อนหน้า
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.arrow_back),
            ),
          ),
          // อนิเมชั่น confetti เมื่อผ่านด่าน
          if (levelCompleted)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.yellow,
                  Colors.orange,
                  Colors.purple,
                ],
              ),
            ),
        ],
      ),
    );
  }
}
