import 'package:firstly/function/mediaquery_values.dart';
import 'package:flutter/material.dart';

class StarCongrate extends StatefulWidget {
  const StarCongrate({Key? key}) : super(key: key);

  @override
  State<StarCongrate> createState() => _StarCongrateState();
}

class _StarCongrateState extends State<StarCongrate>
    with TickerProviderStateMixin {
  bool _startAnimation = false;

  // Controller สำหรับหมุน
  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation; // 0..1 -> หมุน 1 รอบ

  // Controller สำหรับย่อ–ขยาย
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation; // เช่น 1.0..1.2..1.0

  @override
  void initState() {
    super.initState();

    // (1) สร้าง AnimationController สำหรับหมุน
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000), // หมุน 1 รอบใน 2 วิ
    );
    // Tween 0..1 => 1 รอบ = 360 องศา => RotationTransition จะใช้ 0..1 = 1 cycle
    _rotateAnimation =
        Tween<double>(begin: 0, end: 1).animate(_rotateController);

    // (2) สร้าง AnimationController สำหรับย่อ–ขยาย
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // Tween 1.0..1.2 => ทำให้ดาวย่อ–ขยายไป–มา
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // เริ่มต้น: ยังไม่ให้หมุน/ย่อขยาย
    _rotateController.stop();
    _scaleController.stop();

    // เมื่อ Widget สร้างเสร็จ (Frame แรก) ให้เริ่มอนิเมชัน
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // (A) เคลื่อนจากกลางจอ -> ตำแหน่งปลายทาง
      setState(() => _startAnimation = true);

      // (B) รอ 1 วินาที (ระยะเวลาที่ดาวเคลื่อน)
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;

        // เริ่มหมุน + ย่อขยาย
        _rotateController.repeat();
        _scaleController.repeat(reverse: true);

        // (C) รออีก 1.5 วินาที (ค้างที่ปลายทาง)
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (!mounted) return;

          // (D) เคลื่อนกลับมาที่กลางจอ
          setState(() => _startAnimation = false);

          // (E) ถ้าต้องการหยุดหมุน/ย่อขยายเมื่อกลับถึงกลางจอ
          //     ก็รออีก 1 วินาที (ระยะเวลาที่เคลื่อนกลับ)
          Future.delayed(const Duration(seconds: 1), () {
            if (!mounted) return;
            _rotateController.stop();
            _scaleController.stop();
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = context.screenWidth;
    final screenH = context.screenHeight;

    double bigSize = 70;
    double smallSize = 30;

    double centerX = screenW / 2 - bigSize / 2;
    double centerY = screenH / 2 - bigSize / 2;

    double leftSmallX = screenW * 0.22;
    double leftSmallY = screenH * 0.1;

    double leftBigX = screenW * 0.185;
    double leftBigY = screenH * 0.17;

    double rightBigX = screenW * 0.185;
    double rightBigY = screenH * 0.17;
    double finalRightBigX = screenW - rightBigX - bigSize;

    double rightSmallX = screenW * 0.22;
    double rightSmallY = screenH * 0.1;
    double finalRightSmallX = screenW - rightSmallX - smallSize;

    // กำหนด Stack ให้ครอบเต็มพื้นที่
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // ---------------------------
          // ดาวด้านซ้าย (ใหญ่)
          // ---------------------------
          AnimatedPositioned(
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              left: _startAnimation ? leftBigX : centerX,
              top: _startAnimation ? leftBigY : centerY,
              child: _buildStar(bigSize)),

          // ---------------------------
          // ดาวซ้ายเล็ก
          AnimatedPositioned(
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              left: _startAnimation ? leftSmallX : centerX,
              top: _startAnimation ? leftSmallY : centerY,
              child: _buildStar(smallSize)),

          // ---------------------------
          // ดาวขวาใหญ่
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            left: _startAnimation ? finalRightBigX : centerX,
            top: _startAnimation ? rightBigY : centerY,
            child: _buildStar(bigSize),
          ),

          // ---------------------------
          // ดาวขวาเล็ก
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            left: _startAnimation ? finalRightSmallX : centerX,
            top: _startAnimation ? rightSmallY : centerY,
            child: _buildStar(smallSize),
          ),
        ],
      ),
    );
  }

  /// สร้าง Widget ดาว + หมุน + ย่อขยาย
  Widget _buildStar(double size) {
    String imagePath =
        'assets/images/linegamelist/starcongrats.png'; // กำหนด path ของรูปดาว
    return RotationTransition(
      turns: _rotateAnimation, // หมุน 1 รอบต่อ duration = 2 วิ
      child: ScaleTransition(
        scale: _scaleAnimation, // ย่อ–ขยาย 1..1.2..1..
        child: Image.asset(
          imagePath,
          width: size,
          height: size,
        ),
      ),
    );
  }
}
