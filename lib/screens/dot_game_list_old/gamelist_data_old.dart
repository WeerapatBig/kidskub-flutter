// dotgame_data.dart

// ---------------------------------------------------------------------------
// ส่วนของ "Data" (ข้อมูล) ที่จัดเก็บสถานะต่าง ๆ และการเตรียมข้อมูลเริ่มต้น
// ---------------------------------------------------------------------------

// เก็บสถานะการปลดล็อคต่าง ๆ (ตัวอย่าง - ถ้าต้องการย้ายไปเป็น class/structure ได้เช่นกัน)
bool isLevel1Unlocked = true;
bool isLevel2Unlocked = false;
bool isLevel3Unlocked = false;
bool isQuizUnlocked = false;
bool isWarningVisible = false;
bool hasKey2 = false; // สถานะการปลดล็อค Chapter 2

// เก็บจำนวนดาว
int purpleStars = 0;
int yellowStars = 0;

// ตำแหน่งที่จะเก็บ List ของทุกด่าน
late List<Map<String, dynamic>> levels;

/// ฟังก์ชันคืนค่า List<Map<String, dynamic>> สำหรับนำไปใช้งานในหน้าจอหลัก
List<Map<String, dynamic>> initializeLevels() {
  return [
    {
      'name': 'Motion',
      'unlocked': isLevel1Unlocked,
      'lockedImage': 'assets/images/dotchapter/motion_card.png',
      'unlockedImage': 'assets/images/dotchapter/motion_card.png',
      'maxStars': 0,
      'earnedStars': 0,
      'starColor': '',
      'sticker': 'sticker1',
    },
    {
      'name': 'Level 2',
      'unlocked': isLevel2Unlocked,
      'lockedImage': 'assets/images/dotchapter/lv1_card_lock.png',
      'unlockedImage': 'assets/images/dotchapter/lv1_card_unlock.png',
      'maxStars': 3,
      'earnedStars': 0,
      'starColor': 'yellow',
      'sticker': 'sticker2',
    },
    {
      'name': 'Level 3',
      'unlocked': isLevel3Unlocked,
      'lockedImage': 'assets/images/dotchapter/lv2_card_lock.png',
      'unlockedImage': 'assets/images/dotchapter/lv2_card_unlock.png',
      'maxStars': 3,
      'earnedStars': 0,
      'starColor': 'yellow',
      'sticker': 'sticker3',
    },
    {
      'name': 'Quiz',
      'unlocked': isQuizUnlocked,
      'lockedImage': 'assets/images/dotchapter/quiz_card_lock.png',
      'unlockedImage': 'assets/images/dotchapter/quiz_card_unlock.png',
      'maxStars': 1,
      'earnedStars': 0,
      'starColor': 'purple',
      'sticker': 'sticker4',
    },
  ];
}
