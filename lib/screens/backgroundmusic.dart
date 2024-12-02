import 'package:audioplayers/audioplayers.dart';

class BackgroundMusic {
  late AudioPlayer _audioPlayer;

  BackgroundMusic() {
    _audioPlayer = AudioPlayer();
    _playBackgroundMusic();
  }

  void _playBackgroundMusic() async {
    await _audioPlayer.setSource(AssetSource('assets/music/background.mp3'));
    _audioPlayer.setReleaseMode(ReleaseMode.loop); // ทำให้เพลงเล่นซ้ำ
    await _audioPlayer.resume(); // เริ่มเล่นเพลง
  }

  void stopMusic() {
    _audioPlayer.stop(); // หยุดเพลง
  }
}
