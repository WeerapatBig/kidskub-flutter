// dotgame_logic.dart

// Import ข้อมูล (data) จากไฟล์ dotgame_data.dart
import 'package:flutter/material.dart';

import '../shared_prefs_service.dart';
import 'gamelist_data.dart';

/// ---------------------------------------------------------------------------
/// ส่วนของ "Logic" (หลักการทำงาน) ไม่ตัดโค้ดใด ๆ ออก แต่ย้ายฟังก์ชันเข้ามารวมไว้
/// ---------------------------------------------------------------------------

final SharedPrefsService prefsService = SharedPrefsService(); // instance

/// ฟังก์ชันอัปเดตจำนวนดาวทั้งหมด
Future<void> updateTotalStars() async {
  int totalYellowStars = 0;
  int totalPurpleStars = 0;

  for (var level in levels) {
    if (level['starColor'] == 'yellow') {
      totalYellowStars += level['earnedStars'] as int;
    } else if (level['starColor'] == 'purple') {
      totalPurpleStars += level['earnedStars'] as int;
    }
  }

  yellowStars = totalYellowStars.clamp(0, 5);
  purpleStars = totalPurpleStars.clamp(0, 1);

  // ถ้าดาวสีเหลืองครบ 5 ดวงแล้ว ให้ทำการส่งค่ากลับไปยัง GameSelectionPage
  if (yellowStars >= 5 && !hasKey2) {
    hasKey2 = true; // ส่งข้อมูลไปปลดล็อค Chapter ถัดไป
    await prefsService.saveKeyStatus('hasKey2', true);
    print('You have yellow stars: $yellowStars .Now you can unlock chapter2');
  }
  print('Updated total stars: $yellowStars yellow, $purpleStars purple');
}

/// เมื่อผู้เล่นออกจากหน้า DotGameList จะส่งค่าการปลดล็อคกลับไป
void onBackButtonPressed() async {
  await prefsService.saveKeyStatus('hasKey2', hasKey2);
  print('Saved hasKey2: $hasKey2'); // เพิ่มการดีบัค
}

/// ฟังก์ชันปลดล็อคด่านถัดไป
Future<void> unlockNextLevel(String currentLevel) async {
  int nextLevelIndex;

  if (currentLevel == 'Motion') {
    nextLevelIndex = 1;
  } else if (currentLevel == 'Level 2') {
    nextLevelIndex = 2;
  } else if (currentLevel == 'Level 3') {
    nextLevelIndex = 3;
  } else {
    return;
  }

  if (!levels[nextLevelIndex]['unlocked']) {
    levels[nextLevelIndex]['unlocked'] = true;

    // เช็คและบันทึกข้อมูลเฉพาะเมื่อ earnedStars และ starColor ถูกตั้งค่า
    if ((levels[nextLevelIndex]['earnedStars'] ?? 0) > 0 ||
        (levels[nextLevelIndex]['starColor'] ?? '').isNotEmpty) {
      await prefsService.saveLevelData(
        levels[nextLevelIndex]['name'],
        levels[nextLevelIndex]['earnedStars'],
        levels[nextLevelIndex]['starColor'],
        levels[nextLevelIndex]['unlocked'],
      );
    } else {
      // ปลดล็อค level แต่ยังไม่บันทึกค่า stars เพราะยังไม่มีค่าถูกต้อง
      await prefsService.saveLevelData(
        levels[nextLevelIndex]['name'],
        0,
        levels[nextLevelIndex]['starColor'],
        true,
      );
    }

    print(
        '--- Debug after unlockNextLevel ${levels[nextLevelIndex]['name']} ---');
    print(levels[nextLevelIndex]);
  }
}

/// แสดงเตือน (popup) หากยังไม่ปลดล็อค
/// (ใช้ OverlayEntry + Animation)
void showUnlockWarning(BuildContext context, TickerProvider ticker) {
  // ถ้ากำลังแสดง popup อยู่ ไม่ต้องแสดงซ้ำ
  if (isWarningVisible) return;

  // ตั้งค่าสถานะให้กำลังแสดง popup
  isWarningVisible = true;

  // สร้าง AnimationController สำหรับอนิเมชันการเลื่อนเข้าและออก
  final animationController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: ticker,
  );

  // สร้าง OverlayEntry สำหรับ Pop-up
  late OverlayEntry overlayEntry;

  // ฟังก์ชันสำหรับลบ OverlayEntry
  void removeOverlay() {
    animationController.reverse().then((value) {
      overlayEntry.remove();
      animationController.dispose();
      isWarningVisible = false; // รีเซ็ตสถานะเมื่อแอนิเมชันเสร็จสิ้น
    });
  }

  // สร้าง OverlayEntry
  overlayEntry = OverlayEntry(
    builder: (context) {
      // สร้างอนิเมชันการเลื่อน
      final slideAnimation = Tween<Offset>(
        begin: const Offset(0.0, -1.0), // เริ่มจากนอกหน้าจอด้านบน
        end: const Offset(0.0, 0.0), // เลื่อนเข้ามาในหน้าจอ
      ).animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ));

      return Positioned(
        top: MediaQuery.of(context).size.height * 0,
        right: MediaQuery.of(context).size.width * 0.35,
        child: SlideTransition(
          position: slideAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.height * 0.2,
              child: Image.asset(
                'assets/images/dotchapter/unlock_notification.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      );
    },
  );

  // แสดง OverlayEntry
  Overlay.of(context).insert(overlayEntry);

  // เริ่มอนิเมชันเลื่อนเข้า
  animationController.forward();

  // ตั้งเวลาให้ Pop-up แสดงผล 2 วินาที แล้วเลื่อนออก
  Future.delayed(const Duration(seconds: 2), () {
    removeOverlay();
  });
}

/// ฟังก์ชันสำหรับตั้งชื่อไฟล์รูปดาวสีเหลือง (ขึ้นกับจำนวนดาว)
String getYellowStarImageName(int stars) {
  return stars >= 0 && stars <= 5 ? stars.toString() : '0';
}

/// ฟังก์ชันสำหรับตั้งชื่อไฟล์รูปดาวสีม่วง (มีแค่ 0 กับ 1)
String getPurpleStarImageName(int stars) {
  return stars == 0 ? '0' : '1';
}
