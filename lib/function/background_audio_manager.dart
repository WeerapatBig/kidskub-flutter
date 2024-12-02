import 'package:just_audio/just_audio.dart';

class BackgroundAudioManager {
  // Singleton Pattern
  static final BackgroundAudioManager _instance =
      BackgroundAudioManager._internal();
  factory BackgroundAudioManager() => _instance;

  late AudioPlayer _audioPlayer; // สำหรับ Background Music
  double _soundEffectVolume = 0.5; // ระดับเสียงเริ่มต้นของ Sound Effect

  // Map สำหรับเก็บ AudioPlayer ที่โหลดเสียงเอฟเฟกต์ล่วงหน้า
  final Map<String, AudioPlayer> _soundEffectPlayers = {};

  BackgroundAudioManager._internal() {
    _audioPlayer = AudioPlayer();
    _initialize();
    _preloadSoundEffects();
  }

  Future<void> _initialize() async {
    // ตั้งค่า Background Music
    await _audioPlayer.setAsset('assets/music/background_music.mp3');
    _audioPlayer.setLoopMode(LoopMode.one); // ตั้งให้วนลูป
    _audioPlayer.play(); // เริ่มเล่นอัตโนมัติ
  }

  Future<void> _preloadSoundEffects() async {
    // รายการไฟล์เสียงเอฟเฟกต์ที่ต้องการโหลดล่วงหน้า
    List<String> soundEffectAssets = [
      'assets/music/click_sound.mp3',
      // เพิ่มไฟล์เสียงเอฟเฟกต์อื่น ๆ ถ้าจำเป็น
    ];

    for (var asset in soundEffectAssets) {
      AudioPlayer player = AudioPlayer();
      await player.setAsset(asset);
      player.setVolume(_soundEffectVolume);
      _soundEffectPlayers[asset] = player;
    }
  }

  void setBackgroundVolume(double volume) {
    _audioPlayer.setVolume(volume); // ปรับระดับเสียงของ Background Music
  }

  void setSoundEffectVolume(double volume) {
    _soundEffectVolume = volume; // ปรับระดับเสียงของ Sound Effect
    // อัปเดตระดับเสียงของ Sound Effect ที่โหลดล่วงหน้าทั้งหมด
    for (var player in _soundEffectPlayers.values) {
      player.setVolume(_soundEffectVolume);
    }
  }

  // แก้ไขฟังก์ชัน playSoundEffect เพื่อใช้ AudioPlayer ที่โหลดล่วงหน้า
  Future<void> playSoundEffect(String assetPath) async {
    AudioPlayer? player = _soundEffectPlayers[assetPath];
    if (player != null) {
      await player.seek(Duration.zero); // รีเซ็ตไปยังจุดเริ่มต้นของไฟล์เสียง
      player.play();
    } else {
      // ถ้าไม่พบไฟล์เสียงที่โหลดล่วงหน้า ให้แจ้งเตือนหรือจัดการตามเหมาะสม
      print('Sound effect not preloaded: $assetPath');
    }
  }

  void dispose() {
    _audioPlayer.dispose(); // ปิดการใช้งาน Background Music
    for (var player in _soundEffectPlayers.values) {
      player.dispose(); // ปิดการใช้งาน Sound Effect Players
    }
  }
}
