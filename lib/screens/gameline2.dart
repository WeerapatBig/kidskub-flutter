import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:async';

class GameLine2 extends StatefulWidget {
  const GameLine2({super.key});

  @override
  _GameLine2State createState() => _GameLine2State();
}

class _GameLine2State extends State<GameLine2>
    with SingleTickerProviderStateMixin {
  List<Offset> points = []; // จุดที่ผู้เล่นลากเส้น
  double imageOpacity = 0.2; // ความโปร่งใสของรูปภาพ
  bool levelCompleted = false; // สถานะผ่านเลเวล
  int score = 0; // ตัวแปรเก็บคะแนนของผู้เล่น

  // Animation สำหรับทำให้ภาพชัดขึ้น
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  // เส้นรอบนอก (Outline) ที่ต้องการให้ผู้เล่นวาดตาม
  List<Offset> outlinePoints = [];
  List<List<int>> outlineEdges = []; // ขอบที่เชื่อมระหว่างจุด
  Set<int> visitedPoints = {}; // เก็บจุดที่ผู้เล่นลากผ่าน
  int? startPointIndex; // เก็บจุดเริ่มต้นของการลาก

  @override
  void initState() {
    super.initState();

    // AnimationController สำหรับการปรับความชัดของภาพ
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.2, end: 1.0).animate(_animationController!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      _setOutlinePoints(screenSize);
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  // ฟังก์ชันกำหนดจุด (Offset) และเส้น (Edges) ของ Outline รอบรูปภาพ
  void _setOutlinePoints(Size screenSize) {
    setState(() {
      outlinePoints = [
        Offset(screenSize.width * 0.263, screenSize.height * 0.85),
        Offset(screenSize.width * 0.27, screenSize.height * 0.62),
        Offset(screenSize.width * 0.58, screenSize.height * 0.09),
        Offset(screenSize.width * 0.616, screenSize.height * 0.054),
        Offset(screenSize.width * 0.648, screenSize.height * 0.068),
        Offset(screenSize.width * 0.718, screenSize.height * 0.19),
        Offset(screenSize.width * 0.735, screenSize.height * 0.23),
        Offset(screenSize.width * 0.738, screenSize.height * 0.27),
        Offset(screenSize.width * 0.728, screenSize.height * 0.3),
        Offset(screenSize.width * 0.55, screenSize.height * 0.6),
        Offset(screenSize.width * 0.415, screenSize.height * 0.838),
        Offset(screenSize.width * 0.266, screenSize.height * 0.856),
      ];

      outlineEdges = [
        [0, 1],
        [1, 2],
        [2, 3],
        [3, 4],
        [4, 5],
        [5, 6],
        [6, 7],
        [7, 8],
        [8, 9],
        [9, 10],
        [10, 11],
        [11, 12],
        [12, 0],
      ]; // เชื่อมจุดเป็นขอบ
    });
  }

  int _getStarCount() {
    if (score >= 90) {
      return 3;
    } else if (score >= 60) {
      return 2;
    } else {
      return 1;
    }
  }

  // ฟังก์ชันสำหรับแสดง Pop-up เมื่อผ่านด่าน
  void _showLevelCompleteDialog() {
    int starCount = _getStarCount(); // รับจำนวนดาวจากคะแนน

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Level Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // แสดงดาวตามจำนวนที่ได้
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                if (index < starCount) {
                  return Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 40,
                  );
                } else {
                  return Icon(
                    Icons.star_border,
                    color: Colors.grey,
                    size: 40,
                  );
                }
              }),
            ),
            const SizedBox(height: 10),
            Text('Your Score: $score'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ปิด Pop-up
              Navigator.pop(context); // กลับหน้าเมนูหลัก
            },
            child: const Text('Menu'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ปิด Pop-up
              // Logic สำหรับไปด่านถัดไป
            },
            child: const Text('Next Level'),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันตรวจเช็คการลากเส้นขณะที่ลากผ่านจุด Outline
  void _handlePanUpdate(Offset position) {
    bool shouldUpdate = false;

    for (int i = 0; i < outlinePoints.length; i++) {
      if (_isPointNear(position, outlinePoints[i]) &&
          !visitedPoints.contains(i)) {
        visitedPoints.add(i); // เพิ่มจุดที่ผู้เล่นลากผ่านเข้าไป

        // เพิ่มคะแนนเมื่อผ่านจุดใหม่
        score += 10;
        shouldUpdate = true;

        // กำหนดจุดเริ่มต้นถ้ายังไม่มีการลาก
        if (startPointIndex == null) {
          startPointIndex = i;
        }

        // ถ้าครบทุกจุดและลากกลับมาที่จุดเริ่มต้น
        if (visitedPoints.length == outlinePoints.length &&
            i == startPointIndex) {
          _checkDrawing();
        }
      }
    }
    points.add(position); // เก็บตำแหน่งการลากของผู้เล่น

    if (shouldUpdate || points.length % 5 == 0) {
      setState(() {}); // เรียก setState เมื่อจำเป็น
    }
  }

  // ฟังก์ชันตรวจสอบว่าผู้เล่นลากครบทุกจุดและกลับมาที่จุดเริ่มต้นหรือไม่
  void _checkDrawing() {
    if (visitedPoints.length == outlinePoints.length) {
      setState(() {
        levelCompleted = true;
      });
      _animationController?.forward(); // ทำให้ภาพค่อยๆชัดขึ้น
      Future.delayed(const Duration(seconds: 2), () {
        _showLevelCompleteDialog(); // หลังจากภาพชัดขึ้น แสดง Pop-up
      });
    }
  }

  bool _isPointNear(Offset p1, Offset p2, {double tolerance = 10.0}) {
    return (p1 - p2).distance <= tolerance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chapter 2: Draw the Line'),
      ),
      body: Stack(
        children: [
          // วางรูปภาพพื้นหลังแบบจางๆ
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _fadeAnimation!,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation!.value,
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/pencil.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          // วางเส้นรอบนอก (รอยปะ) ที่ผู้เล่นต้องวาดตาม
          CustomPaint(
            size: Size.infinite,
            painter: OutlinePainter(outlinePoints),
          ),
          // วาง GestureDetector เพื่อให้ผู้เล่นวาดเส้น
          GestureDetector(
            onPanUpdate: (details) {
              _handlePanUpdate(
                  details.localPosition); // เก็บการลากขณะผู้เล่นลาก
            },
            onPanEnd: (details) {
              if (visitedPoints.length == outlinePoints.length) {
                _checkDrawing(); // ตรวจสอบการจบการลากเมื่อผู้เล่นลากครบ
              }
            },
            child: CustomPaint(
              painter: LinePainter(points), // แสดงเส้นที่ผู้เล่นวาด
              size: Size.infinite,
            ),
          ),

          // วิดเจ็ตแสดงคะแนนที่มุมบนขวา
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Score: $score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// วิดเจ็ตสำหรับการวาดเส้นของผู้เล่น
class LinePainter extends CustomPainter {
  final List<Offset> points;

  LinePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPoints(PointMode.polygon, points, paint);
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return oldDelegate.points.length != points.length;
  }
}

// วิดเจ็ตสำหรับการวาดเส้น Outline
class OutlinePainter extends CustomPainter {
  final List<Offset> outlinePoints;

  OutlinePainter(this.outlinePoints);

  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()
      ..color = const Color.fromARGB(255, 34, 167, 255)
      ..style = PaintingStyle.fill;

    final paint = Paint()
      ..color = const Color.fromARGB(255, 120, 120, 120)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // วาดเส้นรอบนอกแบบรอยปะ (ไม่เชื่อมติดกัน)
    for (int i = 0; i < outlinePoints.length - 1; i++) {
      _drawDashedLine(canvas, outlinePoints[i], outlinePoints[i + 1], paint);
    }

    // วาดจุดที่เส้นเชื่อมต่อกัน
    for (var point in outlinePoints) {
      canvas.drawCircle(point, 5, circlePaint);
    }
  }

  // ฟังก์ชันวาดเส้นปะ
  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 10.0;
    const double dashSpace = 5.0;
    final double distance = (p2 - p1).distance;
    final int dashCount = (distance / (dashWidth + dashSpace)).floor();
    final Offset dashVector = (p2 - p1) / dashCount.toDouble();

    for (int i = 0; i < dashCount; i++) {
      final Offset start = p1 + dashVector * i.toDouble();
      final Offset end = p1 + dashVector * (i + 0.5);
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
