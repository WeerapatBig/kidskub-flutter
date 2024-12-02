// ignore_for_file: avoid_print

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class DraggingDots extends StatefulWidget {
  final int level;

  const DraggingDots({required this.level, Key? key}) : super(key: key);

  @override
  _DraggingDotsState createState() => _DraggingDotsState();
}

class _DraggingDotsState extends State<DraggingDots>
    with SingleTickerProviderStateMixin {
  List<Offset> points = []; // จุดที่ต้องเชื่อมต่อในแต่ละเลเวล
  List<int> connectedPoints = []; // ดัชนีของจุดที่ถูกเชื่อมต่อแล้ว
  List<List<int>> userEdges = []; // เส้นที่ผู้เล่นลาก
  Offset? currentTouchPoint; // ตำแหน่งปัจจุบันของการสัมผัส
  int? lastPointIndex; // ดัชนีของจุดสุดท้ายที่ผู้เล่นสัมผัส
  bool levelCompleted = false; // สถานะการผ่านเลเวล
  bool dragging = false;
  bool showPreview = true; // สถานะแสดงตัวอย่าง

  // กำหนดเส้นที่ถูกต้องสำหรับแต่ละเลเวล
  List<List<int>> correctEdges = [];

  Timer? _timer;
  int _start = 10; // เวลานับถอยหลัง
  int countdown = 3; // นับถอยหลังก่อนเริ่มเกม
  int _score = 0; // คะแนนหรือจำนวนดาวที่ได้

  ConfettiController? _confettiController;

  // เพิ่มสำหรับแอนิเมชัน
  AnimationController? _colorAnimationController;
  Animation<Color?>? _lineColorAnimation;

  @override
  void initState() {
    super.initState();
    // กำหนดจุดและเส้นที่ถูกต้องสำหรับแต่ละเลเวลเมื่อเริ่มต้นเกม
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      _setLevelData(widget.level, screenSize);

      // เริ่มต้นการแสดงตัวอย่างพร้อมนับถอยหลัง 3 วินาที
      _startCountdownWithPreview();
    });

    // ConfettiController สำหรับการแสดงเอฟเฟกต์
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    // AnimationController สำหรับการเปลี่ยนสีเส้น
    _colorAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // ColorTween สำหรับการเปลี่ยนสีเส้นจากแดงเป็นเขียว
    _lineColorAnimation = ColorTween(
      begin: Colors.red,
      end: Colors.green,
    ).animate(_colorAnimationController!);

    // เพิ่ม listener เพื่อให้แน่ใจว่าทุกครั้งที่แอนิเมชันเปลี่ยนค่า UI จะถูกอัปเดต
    _colorAnimationController!.addListener(() {
      setState(() {});
    });
  }

  void _startCountdownWithPreview() {
    // ตั้งค่าเริ่มต้นแสดงตัวอย่างและนับถอยหลัง
    setState(() {
      showPreview = true;
      countdown = 3;
    });

    // นับถอยหลังพร้อมแสดงตัวอย่าง
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        countdown--;
      });

      if (countdown == 0) {
        timer.cancel();
        setState(() {
          showPreview = false; // ปิดการแสดงตัวอย่างเมื่อจบ 3 วินาที
        });
        _startTimer(); // เริ่มเกมเมื่อหมดเวลานับถอยหลัง
      }
    });
  }

  @override
  void dispose() {
    _confettiController?.dispose();
    _timer?.cancel();
    _colorAnimationController?.dispose();
    super.dispose();
  }

  // ฟังก์ชันสำหรับกำหนดจุดและเส้นที่ถูกต้องในแต่ละเลเวล
  void _setLevelData(int level, Size screenSize) {
    switch (level) {
      case 1:
        // ด่าน 1: ลากเส้นตรง (2 จุด)
        points = [
          Offset(screenSize.width * 0.3, screenSize.height * 0.5), // จุดที่ 0
          Offset(screenSize.width * 0.7, screenSize.height * 0.5), // จุดที่ 1
        ];
        correctEdges = [
          [0, 1],
        ];
        break;
      case 2:
        // ด่าน 2: รูปสามเหลี่ยม
        points = [
          Offset(screenSize.width * 0.5, screenSize.height * 0.2), // จุดที่ 0
          Offset(screenSize.width * 0.7, screenSize.height * 0.6), // จุดที่ 1
          Offset(screenSize.width * 0.3, screenSize.height * 0.6), // จุดที่ 2
        ];
        correctEdges = [
          [0, 1],
          [1, 2],
          [2, 0],
        ];
        break;
      case 3:
        // เลเวล 3: รูปสี่เหลี่ยมจัตุรัส
        points = [
          Offset(screenSize.width * 0.3, screenSize.height * 0.3), // จุดที่ 0
          Offset(screenSize.width * 0.7, screenSize.height * 0.3), // จุดที่ 1
          Offset(screenSize.width * 0.7, screenSize.height * 0.7), // จุดที่ 2
          Offset(screenSize.width * 0.3, screenSize.height * 0.7), // จุดที่ 3
        ];
        correctEdges = [
          [0, 1],
          [1, 2],
          [2, 3],
          [3, 0],
        ];
        break;
      case 4:
        // เลเวล 4: รูปห้าเหลี่ยม
        points = [
          Offset(screenSize.width * 0.5, screenSize.height * 0.2), // จุดที่ 0
          Offset(screenSize.width * 0.7, screenSize.height * 0.4), // จุดที่ 1
          Offset(screenSize.width * 0.6, screenSize.height * 0.7), // จุดที่ 2
          Offset(screenSize.width * 0.4, screenSize.height * 0.7), // จุดที่ 3
          Offset(screenSize.width * 0.3, screenSize.height * 0.4), // จุดที่ 4
        ];
        correctEdges = [
          [0, 1],
          [1, 2],
          [2, 3],
          [3, 4],
          [4, 0],
        ];
        break;
      case 5:
        // ด่าน 5: รูปบ้าน
        points = [
          Offset(screenSize.width * 0.4,
              screenSize.height * 0.6), // จุดที่ 0 ฐานบ้านซ้ายล่าง
          Offset(screenSize.width * 0.6,
              screenSize.height * 0.6), // จุดที่ 1 ฐานบ้านขวาล่าง
          Offset(screenSize.width * 0.6,
              screenSize.height * 0.4), // จุดที่ 2 ฐานบ้านขวาบน
          Offset(screenSize.width * 0.4,
              screenSize.height * 0.4), // จุดที่ 3 ฐานบ้านซ้ายบน
          Offset(screenSize.width * 0.5,
              screenSize.height * 0.2), // จุดที่ 4 จุดยอดหลังคา
        ];
        correctEdges = [
          [0, 1], // ฐานล่าง
          [1, 2], // ขอบขวา
          [2, 3], // ฐานบน
          [3, 0], // ขอบซ้าย
          [3, 4], // ซ้ายหลังคา
          [4, 2], // ขวาหลังคา
        ];
        break;
      default:
        points = [];
        correctEdges = [];
    }
  }

  void _startTimer() {
    _start = 10;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start <= 0) {
        timer.cancel();
        _onTimeOut();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void _onTimeOut() {
    // เวลาหมด
    if (!levelCompleted) {
      _showResultDialog(0);
    }
  }

  void _resetGame() {
    setState(() {
      connectedPoints.clear();
      userEdges.clear();
      lastPointIndex = null;
      levelCompleted = false;
      _startTimer();
    });
  }

  // ฟังก์ชันนี้จะถูกเรียกเมื่อเชื่อมต่อจุดสำเร็จ
  void _animateLineColor() {
    _colorAnimationController?.reset(); // รีเซ็ตแอนิเมชันเพื่อเริ่มใหม่
    _colorAnimationController?.forward(); // เริ่มแอนิเมชันเปลี่ยนสี
  }

  void _submit() {
    _timer?.cancel();
    print('User submitted the solution.');

    if (connectedPoints.length == points.length && _isShapeCorrect()) {
      print('Level completed.');
      _animateLineColor();
      _calculateScore();
      setState(() {
        levelCompleted = true;
      });

      // เรียกแอนิเมชันเฉลิมฉลองก่อนแสดงหน้าต่างจบด่าน
      _showCelebrationAnimation().then((_) {
        // หลังจากแอนิเมชันเสร็จสิ้นแล้ว ค่อยแสดง Pop-up จบด่าน
        _showResultDialog(_score);
      });
    } else {
      print('Level not completed, incorrect shape or incomplete.');
      _showResultDialog(0);
    }
  }

  Future<void> _showCelebrationAnimation() async {
    print("Celebration animation started...");
    _confettiController?.play(); // เริ่ม Confetti Animation

    // การหน่วงเวลาเพื่อให้แอนิเมชันเสร็จสิ้น (เช่น 2 วินาที)
    await Future.delayed(const Duration(seconds: 2));
    _confettiController?.stop(); // หยุด Confetti หลังจาก 2 วินาที

    // แอนิเมชันจบ
    print("Celebration animation ended.");
  }

  void _calculateScore() {
    if (_start > 6) {
      _score = 3;
    } else if (_start > 4) {
      _score = 2;
    } else if (_start > 1) {
      _score = 1;
    } else {
      _score = 0;
    }
  }

  void _showResultDialog(int score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(score > 0 ? 'Level Complete!' : 'Time\'s Up!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You earned $score star${score != 1 ? 's' : ''}!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (score > 0 && widget.level < 5) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DraggingDots(level: widget.level + 1),
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  void _handlePan(Offset position) {
    for (int i = 0; i < points.length; i++) {
      if (_isPointNear(position, points[i])) {
        if (lastPointIndex != null && lastPointIndex != i) {
          // เพิ่มเส้นที่ผู้เล่นลาก
          List<int> edge = [lastPointIndex!, i];
          edge.sort();

          print('User dragged from point $lastPointIndex to point $i');
          print('Edge added: $edge');

          if (!userEdges.any((e) => e[0] == edge[0] && e[1] == edge[1])) {
            userEdges.add(edge);

            // เรียกแอนิเมชันการเปลี่ยนสีทันทีเมื่อเชื่อมต่อจุดสำเร็จ
            _animateLineColor();
          }
        }

        lastPointIndex = i;
        if (!connectedPoints.contains(i)) {
          connectedPoints.add(i);
        }

        // ตรวจสอบการเชื่อมต่อหลังจากลากเส้น
        if (connectedPoints.length == points.length &&
            userEdges.length == correctEdges.length) {
          _submit(); // เรียกตรวจสอบเมื่อเชื่อมต่อครบทุกจุด
        }
        break;
      }
    }
  }

  bool _isShapeCorrect() {
    if (userEdges.length != correctEdges.length) {
      print("Number of edges doesn't match");
      return false;
    }

    // เปลี่ยนเส้นเป็นเซ็ตของสตริงเพื่อเปรียบเทียบ
    Set<String> userEdgeSet = userEdges.map((e) {
      e.sort();
      return '${e[0]}-${e[1]}';
    }).toSet();

    Set<String> correctEdgeSet = correctEdges.map((e) {
      e.sort();
      return '${e[0]}-${e[1]}';
    }).toSet();

    print('User Edges: $userEdgeSet');
    print('Correct Edges: $correctEdgeSet');

    bool isCorrect = userEdgeSet.containsAll(correctEdgeSet) &&
        correctEdgeSet.containsAll(userEdgeSet);
    print('Shape correct: $isCorrect');
    return isCorrect;
  }

  bool _isPointNear(Offset p1, Offset p2, {double tolerance = 20.0}) {
    return (p1 - p2).distance <= tolerance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showPreview
            ? 'Showing Preview...'
            : countdown > 0
                ? 'Get Ready: $countdown'
                : 'Level ${widget.level} - Time: $_start'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
          ),
        ],
      ),
      body: points.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GestureDetector(
                  onPanStart: (details) {
                    if (levelCompleted || showPreview || countdown > 0) return;
                    dragging = true;
                    currentTouchPoint = details.localPosition;
                    _handlePan(details.localPosition);
                    setState(() {});
                  },
                  onPanUpdate: (details) {
                    if (levelCompleted || showPreview || countdown > 0) return;
                    currentTouchPoint = details.localPosition;
                    _handlePan(details.localPosition);
                    setState(() {});
                  },
                  onPanEnd: (details) {
                    if (levelCompleted || showPreview || countdown > 0) return;
                    dragging = false;
                    currentTouchPoint = null;
                    lastPointIndex = null; // รีเซ็ตดัชนีจุดสุดท้าย
                    setState(() {});
                  },
                  child: CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: GamePainter(
                      points: points,
                      userEdges: userEdges,
                      correctEdges:
                          correctEdges, // เพิ่มเส้นที่ถูกต้องสำหรับตัวอย่าง
                      showPreview: showPreview, // แสดงตัวอย่างหรือไม่
                      currentTouchPoint: currentTouchPoint,
                      lastPointIndex: lastPointIndex,
                      dragging: dragging,
                      connectedPoints: connectedPoints,
                      lineColorAnimation: _lineColorAnimation!,
                    ),
                  ),
                ),
                // เพิ่มการแสดง Count Down ให้อยู่กลางจอ
                if (countdown > 0)
                  Center(
                    child: Text(
                      '$countdown',
                      style: const TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                // เพิ่ม Confetti Animation ไว้บนสุด
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController!,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.yellow
                    ],
                    numberOfParticles: 30,
                  ),
                ),
              ],
            ),
    );
  }
}

class GamePainter extends CustomPainter {
  final List<Offset> points; // จุดทั้งหมดในเลเวล
  final List<List<int>> userEdges; // เส้นที่ผู้เล่นลาก
  final List<List<int>> correctEdges; // เพิ่มเส้นที่ถูกต้องสำหรับแสดงตัวอย่าง
  final bool showPreview; // แสดงตัวอย่าง
  final Offset? currentTouchPoint; // ตำแหน่งปัจจุบันของการสัมผัส
  final int? lastPointIndex; // ดัชนีของจุดสุดท้ายที่ผู้เล่นสัมผัส
  final bool dragging;
  final List<int> connectedPoints; // จุดที่เชื่อมต่อแล้ว
  final Animation<Color?> lineColorAnimation; // Animation สำหรับสีเส้น

  GamePainter({
    required this.points,
    required this.userEdges,
    required this.correctEdges, // รับเส้นที่ถูกต้องเข้ามา
    required this.showPreview, // แสดงตัวอย่างหรือไม่
    required this.currentTouchPoint,
    required this.lastPointIndex,
    required this.dragging,
    required this.connectedPoints,
    required this.lineColorAnimation, // รับแอนิเมชันสีเส้นเข้ามา
  });

  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = lineColorAnimation.value ?? Colors.red // สีเส้นที่เปลี่ยนแปลง
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 10.0;

    // วาดจุดทั้งหมด
    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 10.0, circlePaint);
    }

    if (showPreview) {
      // วาดเส้นตัวอย่างเมื่อ showPreview เปิดอยู่
      final previewLinePaint = Paint()
        ..color = const Color.fromARGB(255, 209, 249, 7)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 10.0
        ..style = PaintingStyle.stroke;

      for (var edge in correctEdges) {
        var fromPoint = points[edge[0]];
        var toPoint = points[edge[1]];
        canvas.drawLine(fromPoint, toPoint, previewLinePaint);
      }
    } else {
      // วาดเส้นที่ผู้เล่นลาก
      for (var edge in userEdges) {
        var fromPoint = points[edge[0]];
        var toPoint = points[edge[1]];
        canvas.drawLine(fromPoint, toPoint, linePaint);
      }

      // วาดเส้นที่กำลังลาก
      if (dragging && currentTouchPoint != null && lastPointIndex != null) {
        var fromPoint = points[lastPointIndex!];
        canvas.drawLine(fromPoint, currentTouchPoint!, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
