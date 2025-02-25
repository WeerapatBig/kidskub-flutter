import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../game_mechanic/shape_game_controller.dart';
import 'shape_model.dart';

/// Widget นี้ใช้แสดง "เงารูปทรง" (silhouette) ที่เคลื่อนที่แบบไม่มีแรงโน้มถ่วง
/// และกระเด้ง (bounce) เมื่อชนขอบ "พื้นที่แสดงผล" (Parent) โดยใช้ความเร็วคงที่
///
/// หลักการทำงาน:
/// 1. ใช้ Ticker เพื่ออัปเดตตำแหน่ง x,y ทุกเฟรม (frame-based update) ตาม vx, vy (หน่วย: พิกเซล/วินาที)
/// 2. เมื่อชนขอบซ้าย/ขวา => กลับทิศ vx, เมื่อชนขอบบน/ล่าง => กลับทิศ vy
///    (โดยไม่สูญเสียความเร็วใด ๆ ทำให้ดูเหมือนไม่มีแรงเสียดทาน ไม่มีแรงโน้มถ่วง)
/// 3. การคำนวณใช้ LayoutBuilder เพื่อให้รู้ขนาด (width, height) ของพื้นที่ภายในที่เราจะให้ silhouette เด้งไปมา

class SilhouetteItem extends StatefulWidget {
  final ShapeGameController
      gameController; // Controller สำหรับลอจิกเกม (ใช้เช็กว่าถูกเปิดเผยหรือยัง)
  final ShapeModel shape; // ข้อมูลรูปทรง (ชื่อ + path รูป)
  final double initialX; // ตำแหน่ง X เริ่มต้น (สามารถกำหนดจากภายนอก)
  final double initialY; // ตำแหน่ง Y เริ่มต้น
  final double initialVX; // ความเร็วแกน X เริ่มต้น (พิกเซล/วินาที)
  final double initialVY; // ความเร็วแกน Y เริ่มต้น
  final double itemSize; // ขนาดภาพ width/height
  final double initialRotationAngle; // มุมเริ่มต้น (เรเดียน)
  final double rotationSpeed; // ความเร็วในการหมุน (เรเดียน/วินาที)

  const SilhouetteItem({
    Key? key,
    required this.gameController,
    required this.shape,
    this.initialX = 0,
    this.initialY = 0,
    this.initialVX = 350, // ความเร็วแกน X เริ่มต้น 100 px/s (ปรับได้)
    this.initialVY = 350, // ความเร็วแกน Y เริ่มต้น 100 px/s
    this.itemSize = 100.0, // ขนาดรูป 80 px
    this.initialRotationAngle = 0.0,
    this.rotationSpeed = pi, // pi rad/s = 180 องศา/วินาที
  }) : super(key: key);

  @override
  State<SilhouetteItem> createState() => _SilhouetteItemState();
}

class _SilhouetteItemState extends State<SilhouetteItem>
    with SingleTickerProviderStateMixin {
  // ตำแหน่ง x,y ปัจจุบันของ silhouette
  late double _x;
  late double _y;

  // ความเร็ว (vx, vy) หน่วย = px/วินาที
  late double _vx;
  late double _vy;

  // มุมสำหรับการหมุนรอบตัวเอง
  late double _rotationAngle;

  // Ticker สำหรับอัปเดตตำแหน่งทุกเฟรม
  late Ticker _ticker;
  // ใช้เก็บค่าเวลาของเฟรมก่อนหน้า เพื่อคำนวณ dt (time delta) ได้อย่างแม่นยำ
  late Duration _prevElapsed;

  @override
  void initState() {
    super.initState();

    // กำหนดค่าเริ่มต้นตำแหน่ง
    _x = widget.initialX;
    _y = widget.initialY;

    // กำหนดค่าเริ่มต้นของความเร็ว
    _vx = widget.initialVX;
    _vy = widget.initialVY;
    _rotationAngle = widget.initialRotationAngle;

    // กำหนดเวลาเริ่มต้น = 0
    _prevElapsed = Duration.zero;

    // สร้าง Ticker (เครื่องยิง callback ทุก frame) แล้ว start
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose(); // หยุด Ticker เมื่อ widget ถูก dispose
    super.dispose();
  }

  /// ฟังก์ชัน callback ที่จะถูกเรียกทุกเฟรมโดย Ticker
  /// [elapsed] คือเวลาที่นับจากตอนเริ่ม start Ticker (ตั้งแต่ 0)
  void _onTick(Duration elapsed) {
    // คำนวณเวลาที่ผ่านมาจากเฟรมก่อนเป็นวินาที (dt)
    final double dtSeconds = (elapsed - _prevElapsed).inMicroseconds /
        2e6; // inMicroseconds => วินาที (1e6 = 1 ล้าน) 1e5
    _prevElapsed = elapsed;

    // อัปเดตตำแหน่งของ silhouette โดย x += vx * dt, y += vy * dt
    setState(() {
      _x += _vx * dtSeconds;
      _y += _vy * dtSeconds;

      // อัปเดตมุมหมุน (rotationAngle) ตาม rotationSpeed
      _rotationAngle += widget.rotationSpeed * dtSeconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ใช้ LayoutBuilder เพื่อรู้ขนาดพื้นที่แม่ (constraints)
    return LayoutBuilder(
      builder: (context, constraints) {
        // ความกว้างและความสูงของพื้นที่แม่ (parent)
        final double maxWidth = constraints.maxWidth;
        final double maxHeight = constraints.maxHeight;

        // ตรวจจับชนขอบซ้าย/ขวา
        // หาก _x < 0 => ชนขอบซ้าย => แก้ให้ _x = 0 และกลับทิศ vx => _vx = -_vx
        // หาก _x + widget.itemSize > maxWidth => ชนขอบขวา => แก้ให้ _x = maxWidth - itemSize และกลับทิศ vx
        if (_x < 0) {
          _x = 0;
          _vx = -_vx;
        } else if (_x + widget.itemSize > maxWidth) {
          _x = maxWidth - widget.itemSize;
          _vx = -_vx;
        }

        // ตรวจจับชนขอบบน/ล่าง
        if (_y < 0) {
          _y = 0;
          _vy = -_vy;
        } else if (_y + widget.itemSize > maxHeight) {
          _y = maxHeight - widget.itemSize;
          _vy = -_vy;
        }

        // หลังปรับค่าต่าง ๆ เสร็จ ค่อยแสดง Positioned
        return Stack(
          children: [
            Positioned(
              left: _x,
              top: _y,
              child: Transform.rotate(
                angle: _rotationAngle,
                alignment: Alignment.center,
                child: _buildSilhouetteChild(),
              ),
            ),
          ],
        );
      },
    );
  }

  /// สร้าง Widget Silhouette (เงาดำหรือภาพสี) โดยอิงลอจิกว่าถูกเปิดเผยหรือยัง
  Widget _buildSilhouetteChild() {
    final bool isActive =
        widget.gameController.isSilhouetteActive(widget.shape.name);

    if (isActive) {
      // ยังไม่ถูกเปิด => เป็นเงาดำ
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
        child: Image.asset(
          widget.shape.imagePath,
          width: widget.itemSize,
          height: widget.itemSize,
        ),
      );
    } else {
      // ถูกเปิด => แสดงภาพสีจริง
      return Image.asset(
        widget.shape.imagePath,
        width: widget.itemSize,
        height: widget.itemSize,
      );
    }
  }
}
