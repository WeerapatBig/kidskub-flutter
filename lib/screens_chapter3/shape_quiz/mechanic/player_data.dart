class PlayerDataManager {
  // เก็บจำนวนหัวใจ
  int hearts;

  PlayerDataManager({this.hearts = 3});

  // ฟังก์ชันลดหัวใจ
  void loseHeart() {
    if (hearts > 0) {
      hearts--;
    }
  }
}
