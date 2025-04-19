import 'package:shared_preferences/shared_preferences.dart';

class StickerBookPrefsService {
  static Future<bool> loadIsCollected(String? key) async {
    if (key == null || key.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static Future<void> saveIsCollected(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<bool> getIsCollected(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static Future<void> resetAllStickers() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> stickerKeys = [
      'sticker1',
      'sticker2',
      'sticker3',
      'sticker4',
      'sticker5',
      'stickerLine1',
      'stickerLine2',
      'stickerLine3',
      'stickerLine4',
      'stickerLine5',
      'stickerShape1',
      'stickerShape2',
      'stickerShape3',
      'stickerShape4',
      'stickerShape5',
      'stickerColor1',
      'stickerColor2',
      'stickerColor3',
      'stickerColor4',
      'stickerColor5',
    ];
    for (String key in stickerKeys) {
      await prefs.remove(key);
    }
  }

  //เพิ่มฟังก์ชันนี้ ถ้ายังไม่มี
  Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ล้างข้อมูลทั้งหมดใน SharedPreferences
  }
}
