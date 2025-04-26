import 'dart:async';
import 'dart:math';
import 'package:firstly/function/mediaquery_values.dart';
import 'package:flutter/material.dart';

import '../../../../widgets/custom_button.dart';
import '../../../../widgets/hand_guide.dart';
import 'horizontal_progress_bar.dart';

/// ใช้ครอบทับบนหน้าจอเกม/แอปด้วย Stack หรือ Navigator overlay
class ColorQuizDialog extends StatefulWidget {
  /// เรียกกลับเมื่อผู้ใช้กดปิด (หรือจบ sequence)
  final VoidCallback onExit;

  /// ความยาวเฟรม (1–1.5 s) – เปลี่ยนได้ตอนสร้าง
  final Duration frameDuration;

  const ColorQuizDialog({
    Key? key,
    required this.onExit,
    this.frameDuration = const Duration(milliseconds: 2500),
  }) : super(key: key);

  @override
  State<ColorQuizDialog> createState() => _ColorQuizDialogState();
}

class _ColorQuizDialogState extends State<ColorQuizDialog>
    with TickerProviderStateMixin {
  static const _imagePaths = [
    'assets/images/colorgame/quiz_color/dialog/dialogs_1.png',
    'assets/images/colorgame/quiz_color/dialog/dialogs_2.png',
    'assets/images/colorgame/quiz_color/dialog/dialogs_3.png',
    'assets/images/colorgame/quiz_color/dialog/dialogs_4.png',
    'assets/images/colorgame/quiz_color/dialog/dialogs_5.png',
    'assets/images/colorgame/quiz_color/dialog/dialogs_6.png',
  ];

  static const double _designW = 1280;
  static const double _designH = 720;

  double progressValue = 0.0;
  int currentAction = 0; // 1 = next, -1 = prev, 0 = none
  int _currentIndex = 0; // ภาพปัจจุบัน
  bool _buttonLocked = false; // true ระหว่างคูลดาวน์

  // ─────────── CONTROLLERS ───────────
  late final AnimationController _dialogCountdownCtrl; // 2.5 วิ
  late final AnimationController _buttonCooldownCtrl; // 1.5 วิ

  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _dialogCountdownCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          if (_currentIndex < _imagePaths.length - 1) {
            _goNextImage(); // จะรีเซ็ต progress อยู่แล้วภายในนี้
          } else {
            // หน้าสุดท้าย: หยุดไว้เฉยๆ
            _dialogCountdownCtrl.value = 0.0;
            _dialogCountdownCtrl.stop();
          }
        }
      });

    _buttonCooldownCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed && mounted) {
          setState(() => _buttonLocked = false); // ปลดล็อก
        }
      });

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // เริ่มล่างสุด
      end: Offset.zero, // ตำแหน่งปกติ
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack, // ให้ดูนุ่มนวลขึ้น
    ));

    _slideController.forward(); // เริ่มเลื่อนเข้าฉาก
    _dialogCountdownCtrl.forward(); // เริ่มรอบแรก
  }

  Future<void> _handleArrowTap(VoidCallback changeImage) async {
    if (_buttonLocked) return; // ห้ามกดถ้ายังหน่วงอยู่

    changeImage(); // เปลี่ยนภาพ
    _dialogCountdownCtrl.forward(from: 0); // รีเซ็ต progress
    _buttonCooldownCtrl.forward(from: 0); // เริ่มหน่วงปุ่ม
    setState(() => _buttonLocked = true);
  }

  void _goNextImage() {
    if (!mounted) return;

    if (_currentIndex < _imagePaths.length - 1) {
      setState(() => _currentIndex++);
      _dialogCountdownCtrl.forward(from: 0); // เดินต่อรอบใหม่
    } else {
      // อยู่หน้าสุดท้าย → หยุด
      _dialogCountdownCtrl.value = 0.0;
      _dialogCountdownCtrl.stop();
    }
  }

  void _goPrevImage() {
    if (_currentIndex == 0) return;

    setState(() {
      _currentIndex--;
      _dialogCountdownCtrl.forward(from: 0); // กลับมาเริ่มเดิน progress ใหม่
    });
  }

  Widget _progressBar(BuildContext context) => AnimatedBuilder(
        animation: _dialogCountdownCtrl,
        builder: (ctx, _) => HorizontalProgressBar(
          progress: _dialogCountdownCtrl.value,
        ),
      );

  @override
  void dispose() {
    _dialogCountdownCtrl.dispose();
    _buttonCooldownCtrl.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Widget _buildFixedLayout() {
    return SizedBox(
      width: _designW,
      height: _designH,
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 50),
              child: Image.asset(
                _imagePaths[_currentIndex],
                key: ValueKey(_currentIndex),
              ),
            ),

            Positioned(
              bottom: context.screenHeight * 0.03,
              left: context.screenWidth * 0.04,
              right: context.screenWidth * 0.04,
              child: AnimatedBuilder(
                animation: _dialogCountdownCtrl,
                builder: (ctx, _) => _progressBar(ctx),
              ),
            ),

            // ลูกศรย้อนกลับ
            if (_currentIndex > 0)
              Positioned(
                top: context.screenHeight * 0.04,
                bottom: context.screenHeight * 0.04,
                left: context.screenWidth * 0.04,
                child: SizedBox(
                  width: context.screenWidth * 0.025,
                  child: CustomButton(
                    onTap: () => _handleArrowTap(_goPrevImage),
                    child: Image.asset(
                        'assets/images/colorgame/quiz_color/dialog/left_arrow.png'),
                  ),
                ),
              ),

            // ลูกศรถัดไป
            if (_currentIndex < _imagePaths.length - 1)
              Positioned(
                top: context.screenHeight * 0.04,
                bottom: context.screenHeight * 0.04,
                right: context.screenWidth * 0.03,
                child: SizedBox(
                  width: context.screenWidth * 0.025,
                  child: CustomButton(
                    onTap: () => _handleArrowTap(_goNextImage),
                    child: Image.asset(
                        'assets/images/colorgame/quiz_color/dialog/right_arrow.png'),
                  ),
                ),
              ),

            // ปุ่มปิด (X)
            if (_currentIndex == _imagePaths.length - 1)
              Positioned(
                top: context.screenHeight * -0.02,
                right: context.screenWidth * -0.01,
                child: GestureDetector(
                  onTap: () async {
                    await _slideController.reverse(); // 👈 เล่นอนิเมชันย้อนลง
                    widget.onExit(); // 👈 แล้วค่อยลบ overlay
                  },
                  child: Image.asset(
                    'assets/images/setting/exit.png',
                    width: 48,
                    height: 48,
                  ),
                ),
              ),

            if (_currentIndex == _imagePaths.length - 1)
              const HandGuide(
                angle: -0.5, // หมุนให้มือเอียง
                scale: 1.0,
                start: Offset(780, 0),
                end: Offset(790, 10),
                duration: Duration(milliseconds: 800),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scale =
        min(screenSize.width / _designW, screenSize.height / _designH);

    return Padding(
      padding: const EdgeInsets.fromLTRB(300, 450, 100, 0),
      child: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: _buildFixedLayout(),
          ),
        ),
      ),
    );
  }
}
