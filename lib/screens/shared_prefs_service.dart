import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  // ฟังก์ชันสำหรับล้างข้อมูลทั้งหมด
  Future<void> clearAllPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ล้างข้อมูลทั้งหมดใน SharedPreferences
  }

  // ฟังก์ชันสำหรับบันทึกสถานะกุญแจใน SharedPreferences
  Future<void> saveKeyStatus(String key, bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, status);
  }

  // ฟังก์ชันสำหรับโหลดสถานะกุญแจจาก SharedPreferences
  Future<bool> loadKeyStatus(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  // ฟังก์ชันลบสถานะกุญแจ (กรณีต้องการ reset)
  Future<void> clearKeyStatus(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // **ฟังก์ชันสำหรับบันทึกสถานะของด่าน**
  Future<void> saveLevelProgress(
      String levelName, int earnedStars, String starColor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> levelData = {
      'earnedStars': earnedStars,
      'starColor': starColor,
    };
    await prefs.setString(levelName, jsonEncode(levelData));
    print('Saved progress for $levelName: $levelData');
  }

  // **ฟังก์ชันสำหรับโหลดสถานะของด่าน**
  Future<Map<String, dynamic>> loadLevelProgress(String levelName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? levelData = prefs.getString(levelName);

    if (levelData != null) {
      return jsonDecode(levelData) as Map<String, dynamic>;
    } else {
      return {
        'earnedStars': 0,
        'starColor': '',
      }; // ค่าเริ่มต้นหากยังไม่มีข้อมูล
    }
  }

  // **ฟังก์ชันสำหรับโหลดสถานะทั้งหมด**
  Future<List<Map<String, dynamic>>> loadAllLevels(
      List<Map<String, dynamic>> levels) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> updatedLevels = [];
    for (var level in levels) {
      String levelName = level['name'];
      String? levelData = prefs.getString(levelName);

      if (levelData != null) {
        Map<String, dynamic> progress =
            jsonDecode(levelData) as Map<String, dynamic>;
        level['earnedStars'] = progress['earnedStars'];
        level['starColor'] = progress['starColor'];
      } else {
        level['earnedStars'] = 0;
        level['starColor'] = '';
      }

      updatedLevels.add(level);
    }
    return updatedLevels;
  }
}
