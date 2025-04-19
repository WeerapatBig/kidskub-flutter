import 'package:firstly/screens/shared_prefs_service.dart';
import 'package:flutter/material.dart';

class PageShapeMotionTest extends StatefulWidget {
  const PageShapeMotionTest({super.key});

  @override
  State<PageShapeMotionTest> createState() => _PageShapeMotionTestState();
}

class _PageShapeMotionTestState extends State<PageShapeMotionTest>
    with TickerProviderStateMixin {
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  final prefsService = SharedPrefsService();

  @override
  void initState() {
    super.initState();

    // ตั้งค่า AnimationController สำหรับอนิเมชันหดขยายของปุ่ม
    _buttonAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _buttonScaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.elasticOut,
    ));

    _buttonAnimationController.forward();
  }

  void _onButtonPressed() async {
    // บันทึกข้อมูลของด่านปัจจุบัน
    await prefsService.saveLevelData('Shape Motion', 0, '', true);

// ปลดล็อคด่านถัดไป
    await prefsService.updateLevelUnlockStatus('Shape Motion', 'Shape Easy');

    // ตรวจสอบข้อมูลที่บันทึก
    final result = await prefsService.loadLevelData('Shape Motion');
    print("Saved Level Data: $result");

    // กลับไปยังหน้าเลือกเกม
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.lightGreen, // ทดสอบสีพื้นหลัง
        child: Stack(
          children: [
            Center(
              child: ScaleTransition(
                scale: _buttonScaleAnimation,
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: FloatingActionButton(
                    onPressed: _onButtonPressed,
                    backgroundColor: Colors.white,
                    elevation: 10.0,
                    child: const Icon(Icons.arrow_forward, size: 125),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
