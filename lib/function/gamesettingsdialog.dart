import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'background_audio_manager.dart';

class GameSettingsDialog extends StatefulWidget {
  const GameSettingsDialog({super.key});

  @override
  _GameSettingsDialogState createState() => _GameSettingsDialogState();
}

class _GameSettingsDialogState extends State<GameSettingsDialog> {
  int musicVolumeLevel = 3;
  int sfxVolumeLevel = 5;
  final int maxVolumeLevel = 10;

  @override
  void initState() {
    super.initState();
    _loadVolumeSettings();
  }

  Future<void> _loadVolumeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      musicVolumeLevel =
          ((prefs.getDouble('musicVolume') ?? 0.5) * maxVolumeLevel).round();
      sfxVolumeLevel =
          ((prefs.getDouble('soundEffectVolume') ?? 0.5) * maxVolumeLevel)
              .round();
    });
    BackgroundAudioManager()
        .setBackgroundVolume(musicVolumeLevel / maxVolumeLevel);
    BackgroundAudioManager()
        .setSoundEffectVolume(sfxVolumeLevel / maxVolumeLevel);
  }

  Future<void> _saveVolumeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('musicVolume', musicVolumeLevel / maxVolumeLevel);
    await prefs.setDouble('soundEffectVolume', sfxVolumeLevel / maxVolumeLevel);
  }

  Widget buildVolumeControl({
    required String label,
    required String iconPath,
    required int volumeLevel,
    required Color color,
    required VoidCallback onDecrease,
    //required VoidCallback onTap,
    required VoidCallback onIncrease,
  }) {
    Size size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Section for Icon and Label
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: size.width * 0.06,
              height: size.height * 0.07,
            ),
            SizedBox(width: size.width * 0.005),
            SizedBox(
              width: size.width * 0.27,
              child: Text(
                label,
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),

        // Volume Bar Section
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // เปลี่ยนจาก IconButton เป็น GestureDetector
            GestureDetector(
              onTap: onDecrease,
              child: Container(
                margin: EdgeInsets.all(5),
                child: Image.asset(
                  'assets/images/setting/button_minus.png',
                  width: size.width * 0.045,
                  height: size.height * 0.06,
                ),
              ),
            ),
            SizedBox(
              width: size.width * 0.01,
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/setting/bar.png',
                  width: size.width * 0.355,
                ),
                Row(
                  children: List.generate(maxVolumeLevel, (index) {
                    return Container(
                      width: size.width * 0.025,
                      height: size.height * 0.073,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                          color: index < volumeLevel ? color : Colors.grey[300],
                          border: index < volumeLevel
                              ? Border.all(
                                  color: Colors.black,
                                  width: size.width * 0.0015,
                                )
                              : Border.all(
                                  color: Colors.transparent,
                                  width: size.width * 0.1,
                                ),
                          borderRadius:
                              const BorderRadius.all(Radius.elliptical(8, 8))),
                    );
                  }),
                ),
              ],
            ),
            SizedBox(
              width: size.width * 0.01,
            ),
            GestureDetector(
              onTap: onIncrease,
              child: Container(
                margin: EdgeInsets.all(5),
                child: Image.asset(
                  'assets/images/setting/button_plus.png',
                  width: size.width * 0.05,
                  height: size.height * 0.07,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(80.0),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            child: Container(
              width: screenWidth * 0.65,
              height: screenHeight * 0.65,
              padding: const EdgeInsets.all(50.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.black,
                  width: 5.0,
                ),
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: SizedBox(
                width: screenWidth * 0.55,
                height: screenHeight * 0.65,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.055),
                    buildVolumeControl(
                      label: 'เสียงเพลง',
                      iconPath: 'assets/images/setting/music_icon.png',
                      volumeLevel: musicVolumeLevel,
                      color: Colors.orange,
                      onDecrease: () {
                        setState(() {
                          if (musicVolumeLevel > 0) musicVolumeLevel--;
                          BackgroundAudioManager().setBackgroundVolume(
                              musicVolumeLevel / maxVolumeLevel);
                          _saveVolumeSettings();
                        });
                      },
                      onIncrease: () {
                        setState(() {
                          if (musicVolumeLevel < maxVolumeLevel)
                            musicVolumeLevel++;
                          BackgroundAudioManager().setBackgroundVolume(
                              musicVolumeLevel / maxVolumeLevel);
                          _saveVolumeSettings();
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    buildVolumeControl(
                      label: 'เสียงเอฟเฟกต์',
                      iconPath: 'assets/images/setting/sfx_icon.png',
                      volumeLevel: sfxVolumeLevel,
                      color: Colors.red,
                      onDecrease: () {
                        setState(() {
                          // เล่นเสียงเอฟเฟกต์เพื่อให้ผู้ใช้ได้ยินการเปลี่ยนแปลง
                          BackgroundAudioManager()
                              .playSoundEffect('assets/music/click_sound.mp3');
                          if (sfxVolumeLevel > 0) sfxVolumeLevel--;
                          BackgroundAudioManager().setSoundEffectVolume(
                              sfxVolumeLevel / maxVolumeLevel);
                          _saveVolumeSettings();
                        });
                      },
                      onIncrease: () {
                        setState(() {
                          // เล่นเสียงเอฟเฟกต์เพื่อให้ผู้ใช้ได้ยินการเปลี่ยนแปลง
                          BackgroundAudioManager()
                              .playSoundEffect('assets/music/click_sound.mp3');
                          if (sfxVolumeLevel < maxVolumeLevel) sfxVolumeLevel++;
                          BackgroundAudioManager().setSoundEffectVolume(
                              sfxVolumeLevel / maxVolumeLevel);
                          _saveVolumeSettings();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ข้อความ "ตั้งค่า" อยู่ด้านบนกึ่งกลาง
          Positioned(
            top: -45,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 40.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black,
                    width: 5.0,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: const Text(
                  "ตั้งค่า",
                  style: TextStyle(
                    fontSize: 50.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // ปุ่มปิดที่มุมขวาบน
          Positioned(
            top: screenHeight * -0.03,
            right: screenWidth * -0.01,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Image.asset(
                'assets/images/setting/exit.png',
                width: screenWidth * 0.08,
                height: screenHeight * 0.14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
