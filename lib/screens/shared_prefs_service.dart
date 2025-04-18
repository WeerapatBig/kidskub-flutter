import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  // ฟังก์ชันสำหรับล้างข้อมูลทั้งหมด
  Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ล้างข้อมูลทั้งหมดใน SharedPreferences
  }

  // ฟังก์ชันสำหรับบันทึกสถานะกุญแจใน SharedPreferences
  Future<void> saveKeyStatus(String key, bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, status);
  }

  // ฟังก์ชันสำหรับโหลดสถานะกุญแจจาก SharedPreferences
  Future<bool> loadKeyStatus(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  // ฟังก์ชันลบสถานะกุญแจ (กรณีต้องการ reset)
  Future<void> clearKeyStatus(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // --------------------------------------------------------------------------
  // ฟังก์ชัน "ใหม่" ที่บันทึกทั้ง earnedStars, starColor, และ "unlocked"
  // --------------------------------------------------------------------------

  Future<void> saveLevelData(
    String levelName,
    int newEarnedStars,
    String newStarColor,
    bool newUnlocked,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // โหลดค่าเก่าของด่านนี้จาก SharedPref
    final currentData = await loadLevelData(levelName);

    final oldStars = currentData['earnedStars'] ?? 0;
    final oldStarColor = currentData['starColor'] ?? '';
    final oldUnlocked = currentData['unlocked'] ?? false;

    // ตัดสินใจว่าจะเก็บดาวใหม่ หรือใช้ดาวเดิม
    final finalStars = newEarnedStars > oldStars ? newEarnedStars : oldStars;

    // สีดาว ถ้าเคยเป็น "" แล้วรอบนี้มีสี (หรืออยากอัปเดตเมื่อดาวมากขึ้นเท่านั้น) ก็ปรับตาม logic ได้
    // ที่พบบ่อย: ถ้ารอบใหม่ได้ดาวมากกว่า → อัปเดตสีดาวด้วย
    // ถ้ารอบใหม่ได้ดาวเท่ากันหรือน้อยกว่า → คงค่าเก่าไว้
    String finalStarColor;
    if (newEarnedStars > oldStars) {
      finalStarColor = newStarColor;
    } else {
      finalStarColor = oldStarColor;
    }

    // การปลดล็อค: ถ้าเคย unlocked อยู่แล้ว ก็เป็น true ต่อไป
    final finalUnlocked = oldUnlocked == true || newUnlocked == true;

    // สร้าง map ที่จะเซฟกลับ
    final updatedLevelData = {
      'earnedStars': finalStars,
      'starColor': finalStarColor,
      'unlocked': finalUnlocked,
    };

    // เซฟลง SharedPref
    await prefs.setString(levelName, jsonEncode(updatedLevelData));
  }

  Future<Map<String, dynamic>> loadLevelData(String levelName) async {
    final prefs = await SharedPreferences.getInstance();
    final levelJson = prefs.getString(levelName);
    if (levelJson == null) {
      return {
        'earnedStars': 0,
        'starColor': '',
        'unlocked': levelName == 'Dot Motion',
      };
    }
    return jsonDecode(levelJson);
  }

  Future<void> updateLevelUnlockStatus(
      String currentLevel, String nextLevel) async {
    final prefs = await SharedPreferences.getInstance();

    // โหลดข้อมูลด่านปัจจุบัน
    final currentData = await loadLevelData(currentLevel);
    final nextLevelData = await loadLevelData(nextLevel);

    // ถ้าด่านปัจจุบันปลดล็อคแล้ว ให้ปลดล็อคด่านถัดไป
    if (currentData['unlocked'] == true && nextLevelData['unlocked'] == false) {
      await prefs.setString(
          nextLevel,
          jsonEncode({
            'earnedStars': nextLevelData['earnedStars'],
            'unlocked': true, // บังคับให้ปลดล็อคด่านถัดไป
          }));
    }
  }

  Future<Map<String, int>> calculateTotalStars(List<String> levels) async {
    int yellowStars = 0;
    int purpleStars = 0;
    for (String level in levels) {
      final data = await loadLevelData(level);
      if (data['starColor'] == 'yellow') {
        yellowStars += (data['earnedStars'] as num).toInt();
      } else if (data['starColor'] == 'purple') {
        purpleStars += (data['earnedStars'] as num).toInt();
      }
    }
    return {
      'yellow': yellowStars,
      'purple': purpleStars,
    };
  }

  // -----------------------------
  // Sticker Management
  // -----------------------------
  static Future<void> saveStickerCollected(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sticker_$key', value);
  }

  static Future<bool> getStickerCollected(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('sticker_$key') ?? false;
  }

  static Future<void> resetSticker(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sticker_$key');
  }

  static Future<void> resetAllStickers() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> stickerKeys = [
      'sticker1',
      'sticker2',
      'sticker3',
      'sticker4',
      'sticker5',
    ];

    for (String key in stickerKeys) {
      await prefs.remove('sticker_$key');
    }
  }

  // -----------------------------
  // Star Reward Management
  // -----------------------------
  Future<void> saveStarRewardClaimed(String starColor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${starColor}_reward_claimed', true);
  }

  Future<bool> isStarRewardClaimed(String starColor) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${starColor}_reward_claimed') ?? false;
  }
}
