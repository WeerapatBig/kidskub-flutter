import 'package:firstly/function/mediaquery_values.dart';
import 'package:flutter/material.dart';

class TimeAlertImage extends StatefulWidget {
  const TimeAlertImage({super.key});

  @override
  State<TimeAlertImage> createState() => _TimeAlertImageState();
}

class _TimeAlertImageState extends State<TimeAlertImage>
    with TickerProviderStateMixin {
  late AnimationController _leftController;
  late AnimationController _rightController;

  late Animation<double> _leftScale;
  late Animation<double> _rightScale;

  bool _isDisposed = false; // ✅ เพิ่มตัวแปร flag

  @override
  void initState() {
    super.initState();

    _leftController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _rightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _leftScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _leftController, curve: Curves.elasticOut),
    );

    _rightScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rightController, curve: Curves.elasticOut),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    while (mounted) {
      // 1. เล่นฝั่งซ้าย
      await _leftController.forward(from: 0);
      // 2. เล่นฝั่งขวา
      await Future.delayed(const Duration(milliseconds: 200));
      await _rightController.forward(from: 0);
      // 3. พัก 0.5 วินาที
      await Future.delayed(const Duration(milliseconds: 500));

      if (_isDisposed) return; // ✅ หยุดทันทีหากถูก dispose
      // 4. รีเซ็ตเพื่อเริ่มรอบใหม่
      _leftController.reset();
      _rightController.reset();
    }
  }

  @override
  void dispose() {
    _isDisposed = true; // ✅ ติด flag ว่าถูก dispose แล้ว

    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 👈 รูปซ้าย
        Positioned(
          bottom: context.screenHeight * 0.24,
          left: context.screenWidth * 0.045,
          child: ScaleTransition(
            scale: _leftScale,
            child: Image.asset(
              'assets/images/colorgame/time_alert_1.png',
              width: context.screenWidth * 0.1,
              height: context.screenHeight * 0.1,
            ),
          ),
        ),
        // 👉 รูปขวา
        Positioned(
          bottom: context.screenHeight * 0.24,
          left: context.screenWidth * 0.14,
          child: ScaleTransition(
            scale: _rightScale,
            child: Image.asset(
              'assets/images/colorgame/time_alert_2.png',
              width: context.screenWidth * 0.07,
              height: context.screenHeight * 0.07,
            ),
          ),
        ),
      ],
    );
  }
}
