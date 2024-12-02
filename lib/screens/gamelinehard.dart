import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class LineGameHard extends StatefulWidget {
  const LineGameHard({super.key});

  @override
  _LineGameHardState createState() => _LineGameHardState();
}

class _LineGameHardState extends State<LineGameHard> {
  // ตัวแปรสำหรับจัดการการวาดเส้น
  final List<Offset> _points = [];
  int _score = 0;
  late ConfettiController _confettiController;

  // กำหนดตำแหน่งของกำแพงเขาวงกตในรูปแบบสัดส่วนของหน้าจอ
  final List<RelativeRect> _mazeWalls = [];
  // กำหนดตำแหน่งของจุดแต้มในรูปแบบสัดส่วนของหน้าจอ
  final List<Offset> _scorePoints = [
    const Offset(0.25, 0.28),
    const Offset(0.59, 0.68),
    const Offset(0.15, 0.9),
    const Offset(0.42, 0.38),

    // เพิ่มตำแหน่งตามต้องการ (ใช้ค่าสัดส่วน 0.0 - 1.0)
  ];

  // จุดเริ่มต้นและจุดสิ้นสุดในรูปแบบสัดส่วนของหน้าจอ
  final Offset _startPoint = const Offset(0.15, 0.18);
  final Offset _endPoint = const Offset(0.9, 0.9);

  // ขนาดหน้าจอ
  late Size _screenSize;

  @override
  void initState() {
    super.initState();
    // เริ่มต้น ConfettiController
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // ฟังก์ชันสำหรับสร้างกำแพงของเขาวงกต
  void _createMazeWalls() {
    _mazeWalls.clear();
    // ตัวอย่างการสร้างกำแพงในรูปแบบสัดส่วน
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.1,
        _screenSize.height * 0.1,
        _screenSize.width * 0.1,
        _screenSize.height * 0.88)); //กรอบบนสุด
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.2,
        _screenSize.height * 0.2,
        _screenSize.width * 0.15,
        _screenSize.height * 0.78)); //กรอบบนรอง
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.1,
        _screenSize.height * 0.95,
        _screenSize.width * 0.1,
        _screenSize.height * 0.03)); //กรอบล่าง
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.1,
        _screenSize.height * 0.1,
        _screenSize.width * 0.89,
        _screenSize.height * 0.03)); //กรอบซ้าย
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.89,
        _screenSize.height * 0.1,
        _screenSize.width * 0.1,
        _screenSize.height * 0.15)); //กรอบขวา
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.3,
        _screenSize.height * 0.15,
        _screenSize.width * 0.688,
        _screenSize.height * 0.65)); //กำแพงบนซ้าย
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.2,
        _screenSize.height * 0.2,
        _screenSize.width * 0.79,
        _screenSize.height * 0.55)); //กำแพงบนซ้าย
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.2,
        _screenSize.height * 0.43,
        _screenSize.width * 0.62,
        _screenSize.height * 0.55)); //กำแพงบนซ้าย
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.37,
        _screenSize.height * 0.3,
        _screenSize.width * 0.62,
        _screenSize.height * 0.55)); //กำแพงบนซ้าย
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.372,
        _screenSize.height * 0.3,
        _screenSize.width * 0.55,
        _screenSize.height * 0.685)); //กำแพงบนซ้าย
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.45,
        _screenSize.height * 0.3,
        _screenSize.width * 0.54,
        _screenSize.height * 0.15)); //กำแพงกลางซ้าย
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.1,
        _screenSize.height * 0.54,
        _screenSize.width * 0.62,
        _screenSize.height * 0.445)); //กำแพงนอนกลางซ้าย
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.37,
        _screenSize.height * 0.54,
        _screenSize.width * 0.62,
        _screenSize.height * 0.35)); //กำแพงต่อกลางซ้าย
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.27,
        _screenSize.height * 0.735,
        _screenSize.width * 0.55,
        _screenSize.height * 0.25)); //กำแพงล่างซ้ายกลาง
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.26,
        _screenSize.height * 0.63,
        _screenSize.width * 0.73,
        _screenSize.height * 0.25)); //กำแพงต่อจากล่างซ้ายกลาง
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.19,
        _screenSize.height * 0.62,
        _screenSize.width * 0.73,
        _screenSize.height * 0.368)); //กำแพงต่อจากล่างซ้ายกลาง
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.1,
        _screenSize.height * 0.735,
        _screenSize.width * 0.8,
        _screenSize.height * 0.25)); //กำแพงล่างซ้ายกลางอันสั้น
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.1,
        _screenSize.height * 0.84,
        _screenSize.width * 0.6,
        _screenSize.height * 0.14)); //กำแพงล่างซ้ายกลางอันยาว
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.5,
        _screenSize.height * 0.2,
        _screenSize.width * 0.49,
        _screenSize.height * 0.15)); //กำแพงกลาง
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.55,
        _screenSize.height * 0.35,
        _screenSize.width * 0.44,
        _screenSize.height * 0.03)); //กำแพงกลางขวา
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.56,
        _screenSize.height * 0.625,
        _screenSize.width * 0.38,
        _screenSize.height * 0.36)); //กำแพงต่อจากกลางขวา
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.61,
        _screenSize.height * 0.625,
        _screenSize.width * 0.38,
        _screenSize.height * 0.15)); //กำแพงกลางขวา
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.61,
        _screenSize.height * 0.2,
        _screenSize.width * 0.38,
        _screenSize.height * 0.45)); //กำแพงกลางขวาอันที่2
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.62,
        _screenSize.height * 0.53,
        _screenSize.width * 0.3,
        _screenSize.height * 0.45)); //กำแพงต่อกลางขวาอันที่2
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.69,
        _screenSize.height * 0.65,
        _screenSize.width * 0.3,
        _screenSize.height * 0.03)); //กำแพงกลางล่างขวาอันที่3

    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.767,
        _screenSize.height * 0.3,
        _screenSize.width * 0.22,
        _screenSize.height * 0.33)); //กำแพงต่อกลางล่างขวาอันที่3
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.66,
        _screenSize.height * 0.3,
        _screenSize.width * 0.17,
        _screenSize.height * 0.68)); //กำแพงต่อกลางล่างขวาอันที่3
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.7,
        _screenSize.height * 0.65,
        _screenSize.width * 0.15,
        _screenSize.height * 0.33)); //กำแพงต่อกลางล่างขวาอันที่3
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.82,
        _screenSize.height * 0.5,
        _screenSize.width * 0.1,
        _screenSize.height * 0.48)); //กำแพงกลางขวา
    _mazeWalls.add(RelativeRect.fromLTRB(
        _screenSize.width * 0.75,
        _screenSize.height * 0.78,
        _screenSize.width * 0.1,
        _screenSize.height * 0.2)); //กำแพงล่างขวา
    // กำแพงจากซ้าย 20%, บน 20%, ขวา 80%, ล่าง 80%
    // เพิ่มกำแพงตามต้องการ
  }

  // ฟังก์ชันสำหรับรีเซ็ตเกม
  void _resetGame() {
    setState(() {
      _points.clear();
      _score = 0;
      _createMazeWalls(); // รีเซ็ตกำแพง
    });
  }

  // ฟังก์ชันสำหรับอัปเดตคะแนน
  void _updateScore(int value) {
    setState(() {
      _score += value;
    });
  }

  // ฟังก์ชันสำหรับแสดง Pop-up เมื่อผ่านด่านหรือไม่ผ่านด่าน
  void _showLevelDialog(bool isPassed) {
    // คำนวณจำนวนดาวที่ได้จากคะแนน
    int stars = 0;
    if (_score >= 71) {
      stars = 3;
    } else if (_score >= 41) {
      stars = 2;
    } else if (_score >= 0) {
      stars = 1;
    }

    // แสดง Dialog หลังจาก Confetti ทำงานไปแล้ว 1 วินาที
    Future.delayed(const Duration(seconds: 1), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(isPassed ? 'Level Complete' : 'Level Fail'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ไอคอนดาว
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
                // ปุ่มนำทาง
                isPassed ? _passedButtons() : _failedButtons(),
              ],
            ),
          );
        },
      );
    });
  }

  // ปุ่มเมื่อผ่านด่าน
  Widget _passedButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // กลับหน้าเดิม
          },
          child: const Text('ย้อนกลับ'),
        ),
        ElevatedButton(
          onPressed: () {
            // ไปหน้าถัดไป
          },
          child: const Text('ไปต่อ'),
        ),
      ],
    );
  }

  // ปุ่มเมื่อไม่ผ่านด่าน
  Widget _failedButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _resetGame(); // เริ่มเกมใหม่
          },
          child: const Text('เริ่มใหม่'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // กลับหน้าเดิม
          },
          child: const Text('ย้อนกลับ'),
        ),
      ],
    );
  }

  // Widget สำหรับคะแนนผู้เล่น
  Widget _scoreWidget() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'คะแนน: $_score',
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  // Widget สำหรับปุ่มย้อนกลับ
  Widget _backButton() {
    return Positioned(
      top: 16,
      left: 16,
      child: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }

  // Widget สำหรับแต้มระหว่างทาง
  Widget _pointWidget(Offset position) {
    return Positioned(
      left: position.dx - 10,
      top: position.dy - 10,
      child: Container(
        width: 20,
        height: 20,
        decoration:
            const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
      ),
    );
  }

  // ฟังก์ชันสำหรับตรวจสอบการชนกับกำแพง
  bool _checkCollision(Offset position) {
    Rect containerRect =
        Rect.fromLTWH(0, 0, _screenSize.width, _screenSize.height);
    for (RelativeRect wall in _mazeWalls) {
      Rect wallRect = wall.toRect(containerRect);
      if (wallRect.contains(position)) {
        return true;
      }
    }
    return false;
  }

  // ฟังก์ชันสำหรับตรวจสอบการเก็บแต้ม
  void _checkScorePoint(Offset position) {
    _scorePoints.removeWhere((point) {
      Offset actualPoint =
          Offset(point.dx * _screenSize.width, point.dy * _screenSize.height);
      if ((actualPoint - position).distance < 15) {
        _updateScore(25); // เพิ่มคะแนน
        return true;
      }
      return false;
    });
  }

  // ฟังก์ชันสำหรับตรวจสอบว่าผู้เล่นถึงจุดหมายหรือยัง
  bool _checkGoal(Offset position) {
    Offset actualEndPoint = Offset(
        _endPoint.dx * _screenSize.width, _endPoint.dy * _screenSize.height);
    if ((position - actualEndPoint).distance < 20) {
      return true;
    }
    return false;
  }

  // ฟังก์ชันสำหรับแปลงตำแหน่งสัดส่วนเป็นตำแหน่งจริง
  Offset _getActualPosition(Offset relativePosition) {
    return Offset(relativePosition.dx * _screenSize.width,
        relativePosition.dy * _screenSize.height);
  }

  @override
  Widget build(BuildContext context) {
    // ขนาดของหน้าจอ
    _screenSize = MediaQuery.of(context).size;

    // สร้างกำแพงใหม่ตามขนาดหน้าจอ
    _createMazeWalls();

    return Scaffold(
      body: Stack(
        children: [
          // พื้นหลังของเกม
          GestureDetector(
            onPanStart: (details) {
              // ตรวจสอบว่าผู้เล่นเริ่มวาดที่จุดเริ่มต้นหรือไม่
              RenderBox? renderBox = context.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                Offset localPosition =
                    renderBox.globalToLocal(details.globalPosition);
                Offset actualStartPoint = _getActualPosition(_startPoint);
                if ((localPosition - actualStartPoint).distance < 20) {
                  setState(() {
                    _points.add(localPosition);
                  });
                }
              }
            },
            onPanUpdate: (details) {
              if (_points.isNotEmpty) {
                RenderBox? renderBox = context.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  Offset localPosition =
                      renderBox.globalToLocal(details.globalPosition);

                  setState(() {
                    _points.add(localPosition);

                    // ตรวจสอบการชนกับกำแพง
                    if (_checkCollision(localPosition)) {
                      // รีเซ็ตเส้นที่วาด
                      _points.clear();
                    }

                    // ตรวจสอบการเก็บแต้ม
                    _checkScorePoint(localPosition);

                    // ตรวจสอบว่าถึงจุดหมายหรือยัง
                    if (_checkGoal(localPosition)) {
                      // แสดง Confetti
                      _confettiController.play();
                      // แสดง Pop-up หลังจาก 1 วินาที
                      _showLevelDialog(true);
                    }
                  });
                }
              }
            },
            onPanEnd: (details) {
              // เมื่อยกนิ้วขึ้น
              setState(() {
                _points.clear();
              });
            },
            child: CustomPaint(
              size: Size.infinite,
              painter: LinePainter(
                points: _points,
                walls: _mazeWalls,
                startPoint: _getActualPosition(_startPoint),
                endPoint: _getActualPosition(_endPoint),
                scorePoints:
                    _scorePoints.map((p) => _getActualPosition(p)).toList(),
              ),
            ),
          ),
          // วาง Widget สำหรับแต้มระหว่างทาง
          Stack(
            children: _scorePoints
                .map((point) => _pointWidget(_getActualPosition(point)))
                .toList(),
          ),
          // วางคะแนนผู้เล่นที่มุมบนขวา
          Positioned(
            top: 16,
            right: 16,
            child: _scoreWidget(),
          ),
          // ปุ่มย้อนกลับที่มุมบนซ้าย
          _backButton(),
          // Confetti Animation
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter สำหรับวาดเส้นที่ผู้เล่นวาดและกำแพงเขาวงกต
class LinePainter extends CustomPainter {
  List<Offset> points;
  List<RelativeRect> walls;
  Offset startPoint;
  Offset endPoint;
  List<Offset> scorePoints;

  LinePainter({
    required this.points,
    required this.walls,
    required this.startPoint,
    required this.endPoint,
    required this.scorePoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // วาดเส้นที่ผู้เล่นวาด
    Paint linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], linePaint);
      }
    }

    // สร้างคอนเทนเนอร์ Rect จากขนาดของ Canvas
    Rect containerRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // วาดกำแพงของเขาวงกต
    Paint wallPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    for (RelativeRect wall in walls) {
      canvas.drawRect(wall.toRect(containerRect), wallPaint);
    }

    // วาดจุดเริ่มต้น
    Paint startPointPaint = Paint()
      ..color = Colors.blue // กำหนดสีของจุดเริ่มต้น
      ..style = PaintingStyle.fill;

    canvas.drawCircle(startPoint, 20, startPointPaint);
    // วาดตัวอักษร 'S' ที่จุดเริ่มต้น
    TextPainter textPainter = TextPainter(
      text: const TextSpan(
        text: 'Start',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(startPoint.dx - textPainter.width / 2,
          startPoint.dy - textPainter.height / 2),
    );

// วาดจุดสิ้นสุด
    Paint endPointPaint = Paint()
      ..color = Colors.red // กำหนดสีของจุดสิ้นสุด
      ..style = PaintingStyle.fill;

    canvas.drawCircle(endPoint, 20, endPointPaint);
    // วาดตัวอักษร 'E' ที่จุดสิ้นสุด
    textPainter.text = const TextSpan(
      text: 'End',
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(endPoint.dx - textPainter.width / 2,
          endPoint.dy - textPainter.height / 2),
    );

    // วาดจุดแต้ม
    Paint scorePointPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    for (Offset point in scorePoints) {
      canvas.drawCircle(point, 10, scorePointPaint);
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) => true;
}
