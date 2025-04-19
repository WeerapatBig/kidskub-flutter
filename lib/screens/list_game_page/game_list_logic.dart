// lib\screens\list_game_page\game_list_logic.dart
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../../widgets/showkey.dart';
import '../../widgets/showsticker.dart';
import '../../widgets/stickerbook_page/services/sticker_prefs_service.dart';
import '../shared_prefs_service.dart';
import 'data/game_list_data.dart';
import 'data/star_reward_data.dart';

final SharedPrefsService prefsService = SharedPrefsService();
bool _isWarningVisible = false;

Future<void> onLevelTap(
    BuildContext context, ListGameData levelData, TickerProvider ticker) async {
  if (levelData.isUnlocked) {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => levelData.page),
    ).then((_) async {
      // เมื่อกลับมาจากหน้าเกม, โหลดข้อมูลใหม่เพื่ออัพเดท UI
      final levelDataFromPrefs =
          await prefsService.loadLevelData(levelData.title);
      levelData.earnedStars = levelDataFromPrefs['earnedStars'];
      levelData.starColor = levelDataFromPrefs['starColor'];
      levelData.isUnlocked = levelDataFromPrefs['unlocked'];

      // ดึง stickerKey จาก levelData
      final String? stickerKey = levelData.stickerName;

      // เช็คว่าสติ๊กเกอร์นี้ถูกเก็บแล้วหรือยัง
      final bool isStickerCollected =
          await StickerBookPrefsService.loadIsCollected(stickerKey);

// ถ้ายังไม่เก็บและมี stickerKey ให้แสดง ShowStickerPage
      if (stickerKey != null && stickerKey.isNotEmpty && !isStickerCollected) {
        print('stickerKey: $stickerKey');
        print('isStickerCollected: $isStickerCollected');
        await showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withOpacity(0.5),
          pageBuilder: (context, animation, secondaryAnimation) {
            return ShowStickerPage(stickerKey: stickerKey);
          },
        );
      }
    });
  } else {
    showUnlockWarningLevel(context, ticker, levelData.warningImagePath);
  }
}

void showUnlockWarningLevel(
    BuildContext context, TickerProvider ticker, String imagePath) {
  // ถ้ากำลังแสดง popup อยู่ ไม่ต้องแสดงซ้ำ
  if (_isWarningVisible) return;

  // ตั้งค่าสถานะให้กำลังแสดง popup
  _isWarningVisible = true;

  // สร้าง AnimationController สำหรับอนิเมชันการเลื่อนเข้าและออก
  final animationController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: ticker,
  );

  // ฟังก์ชันสำหรับลบ OverlayEntry
  late OverlayEntry overlayEntry;
  void removeOverlay() {
    animationController.reverse().then((value) {
      overlayEntry.remove();
      animationController.dispose();
      _isWarningVisible = false; // รีเซ็ตสถานะเมื่อแอนิเมชันเสร็จสิ้น
    });
  }

  // สร้าง OverlayEntry
  overlayEntry = OverlayEntry(
    builder: (context) {
      // สร้างอนิเมชันการเลื่อน
      final slideAnimation = Tween<Offset>(
        begin: const Offset(0.0, -1.0), // เริ่มจากนอกหน้าจอด้านบน
        end: const Offset(0.0, 0.0), // เลื่อนเข้ามาในหน้าจอ
      ).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOut,
        ),
      );

      return Positioned(
        top: MediaQuery.of(context).size.height * 0,
        right: MediaQuery.of(context).size.width * 0.35,
        child: SlideTransition(
          position: slideAnimation,
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.height * 0.2,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      );
    },
  );

  // แทรก OverlayEntry ลงใน Overlay
  Overlay.of(context).insert(overlayEntry);

  // เริ่มอนิเมชันเลื่อนเข้า
  animationController.forward();

  // ตั้งเวลาให้ Pop-up แสดงผล 2 วินาที แล้วเลื่อนออก
  Future.delayed(const Duration(seconds: 2), () {
    removeOverlay();
  });
}

Future<void> onPurpleStarTap({
  required BuildContext context,
  required String starColor,
  required int purpleStars,
  required List<StarRewardData> rewardList,
}) async {
  final matchedReward = rewardList.firstWhereOrNull(
    (r) => r.starColor == starColor,
  );

  // ถ้าไม่เจอ rewardData ของม่วง ก็จบ
  if (matchedReward == null) {
    print("No StarRewardData for purple star");
    return;
  }

  final bool isAlreadyCollected = await StickerBookPrefsService.loadIsCollected(
      matchedReward.rewardStickerName);

  if (isAlreadyCollected) {
    print(
        "ผู้เล่นเคยรับรางวัลสีม่วง (rewardStickerName=${matchedReward.rewardStickerName}) ไปแล้ว");
    return; // จบ ไม่แสดงอะไร
  }

  // ตรวจสอบว่ามีดาวม่วงพอไหม
  if (purpleStars >= matchedReward.starRequirement) {
    // กรณีตัวอย่าง: ให้ดาวม่วงโชว์ ShowStickerPage
    // พร้อมระบุ stickerKey = matchedReward.rewardStickerName
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ShowStickerPage(stickerKey: matchedReward.rewardStickerName);
      },
    );
  } else {
    print("Purple stars not enough. Need >= ${matchedReward.starRequirement}");
  }
}

/// ฟังก์ชันสำหรับ “ดาวเหลือง”
Future<void> onYellowStarTap({
  required BuildContext context,
  required String starColor,
  required int yellowStars,
  required List<StarRewardData> rewardList,
}) async {
  final matchedReward = rewardList.firstWhereOrNull(
    (r) => r.starColor == starColor,
  );
  if (matchedReward == null) {
    print("No StarRewardData for yellow star");
    return;
  }

  // 2) เช็คว่าผู้เล่นเคยได้ key นี้แล้วหรือยัง
  //    (ใช้ฟังก์ชัน loadKeyStatus(...) จาก SharedPrefsService)
  final bool hasKey =
      await SharedPrefsService().loadKeyStatus(matchedReward.rewardStickerName);

  if (hasKey) {
    print("ผู้เล่นมี key '${matchedReward.rewardStickerName}' แล้ว");
    return; // จบ ไม่ต้องแสดง ShowKeyPage
  }

  if (yellowStars >= matchedReward.starRequirement) {
    // กรณีตัวอย่าง: ให้ดาวเหลืองโชว์ ShowKeyPage
    // ใช้ matchedReward.rewardStickerName เป็น key
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ShowKeyPage(stickerKey: matchedReward.rewardStickerName);
      },
    );

    // เพิ่มบันทึก SharedPreferences key ที่ตรงกับ GameSelectionPage
    if (matchedReward.rewardStickerName == 'sticker6') {
      await SharedPrefsService().saveKeyStatus('hasKey2', true);
      print('[DEBUG] Set hasKey2 = true');
    }
  } else {
    print("Yellow stars not enough. Need >= ${matchedReward.starRequirement}");
  }
}
