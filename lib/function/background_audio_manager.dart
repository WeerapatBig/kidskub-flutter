import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class BackgroundAudioManager with WidgetsBindingObserver {
  // Singleton Pattern
  static final BackgroundAudioManager _instance =
      BackgroundAudioManager._internal();
  factory BackgroundAudioManager() => _instance;
  final bool _muteAllSounds = false;

  late AudioPlayer backgroundMusicController; // สำหรับ Background Music
  double _soundEffectVolume = 0.5; // ระดับเสียงเริ่มต้นของ Sound Effect
  bool _shouldPlayMusic = true; // ควบคุมว่า Background Music ควรเล่นหรือไม่

  // Map สำหรับเก็บตัวควบคุมเสียงเอฟเฟกต์ล่วงหน้า
  final Map<String, AudioPlayer> soundEffectControllers = {};

  BackgroundAudioManager._internal() {
    backgroundMusicController = AudioPlayer();
    _initialize();
    _preloadSoundEffects();
    WidgetsBinding.instance
        .addObserver(this); // เพิ่ม Observer สำหรับ App Lifecycle
  }

  Future<void> _initialize() async {
    if (_muteAllSounds) return;
    try {
      if (!backgroundMusicController.playing) {
        // ✅ ถ้ายังไม่ได้เล่นอยู่
        await backgroundMusicController
            .setAsset('assets/music/background_music.mp3');
        await backgroundMusicController.setLoopMode(LoopMode.one);
        await backgroundMusicController.setVolume(0.2);
        await backgroundMusicController.play();
      }
    } catch (e) {
      print('Error initializing background music: $e');
      await backgroundMusicController.stop();
    }
  }

  Future<void> _preloadSoundEffects() async {
    if (!_muteAllSounds) return;
    List<String> soundEffectAssets = [
      'assets/soundeffect/button_click.mp3',
      'assets/soundeffect/touch_screen.mp3',
      'assets/soundeffect/button_back.mp3',
      'assets/soundeffect/chapter_lock.mp3',
      'assets/soundeffect/cut_fruit.mp3',
      'assets/soundeffect/CuttingMelonSound.mp3',
      'assets/soundeffect/collect.mp3',
      'assets/soundeffect/openstickerbook.mp3',
      'assets/soundeffect/three_stars.mp3',
      'assets/soundeffect/HintButtonSound.mp3',
      'assets/soundeffect/closeHintButtonSound.mp3',
      'assets/soundeffect/lineCorrectAnswer.mp3',
      'assets/soundeffect/drawingPopSound.mp3',
      'assets/soundeffect/selectLineSound.mp3',
      'assets/soundeffect/lineHintButtonSound.mp3',
      'assets/soundeffect/melonSeed.mp3',
      'assets/soundeffect/melonSeedPlace.mp3',
      'assets/soundeffect/drawingLineSound.mp3',
      'assets/soundeffect/countdownDotSound.mp3',
      'assets/soundeffect/clickDotSound.mp3',
      'assets/soundeffect/dragDice.mp3',
      'assets/soundeffect/backMelonSeed.mp3',
      'assets/soundeffect/slideDownBar.mp3',
      'assets/soundeffect/slideUpBar.mp3',
      'assets/soundeffect/scrollScreenDoth.mp3',
      'assets/soundeffect/wrongDraw.mp3',
      'assets/soundeffect/correctAnswerQuizDot.mp3',
      'assets/soundeffect/worngAnswerQuizDot.mp3',
      'assets/soundeffect/quizWin.mp3',
      'assets/soundeffect/soundSettingButton.mp3',
      'assets/soundeffect/hitCorner1.mp3',
      'assets/soundeffect/hitCorner2.mp3',
    ];

    await Future.wait(
      soundEffectAssets.map((asset) async {
        try {
          final player = AudioPlayer();
          await player.setAsset(asset);
          player.setVolume(_soundEffectVolume);
          soundEffectControllers[asset] = player;
          print('✅ Preloaded: $asset');
        } catch (e) {
          print('❌ Failed to preload $asset: $e');
        }
      }),
    );
  }

  void playButtonClickSound() {
    playSoundEffect('assets/soundeffect/button_click.mp3');
  }

  void playButtonBackSound() {
    playSoundEffect('assets/soundeffect/button_back.mp3');
  }

  void playChapterLockSound() {
    playSoundEffect('assets/soundeffect/chapter_lock.mp3');
  }

  void playCutFruitSound() {
    playSoundEffect('assets/soundeffect/cut_fruit.mp3');
  }

  void playTouchScreenSound() {
    playSoundEffect('assets/soundeffect/touch_screen.mp3');
  }

  void playCollectSound() {
    playSoundEffect('assets/soundeffect/collect.mp3');
  }

  void playOpenStickerBookSound() {
    playSoundEffect('assets/soundeffect/openstickerbook.mp3');
  }

  void playThreeStarsSound() {
    playSoundEffect('assets/soundeffect/three_stars.mp3');
  }

  void playHintButtonSound() {
    playSoundEffect('assets/soundeffect/HintButtonSound.mp3');
  }

  void playCloseHintButtonSound() {
    playSoundEffect('assets/soundeffect/closeHintButtonSound.mp3');
  }

  void playCuttingMelonSound() {
    playSoundEffect('assets/soundeffect/CuttingMelonSound.mp3');
  }

  void playDrawinglineSound() {
    playSoundEffect('assets/soundeffect/drawingLineSound.mp3');
  }

  void playLineCorrrectAnswerSound() {
    playSoundEffect('assets/soundeffect/lineCorrectAnswer.mp3');
  }

  void playSelectlineSound() {
    playSoundEffect('assets/soundeffect/selectLineSound.mp3');
  }

  void playlineHintButtonSound() {
    playSoundEffect('assets/soundeffect/lineHintButtonSound.mp3');
  }

  void playMelonSeedSound() {
    playSoundEffect('assets/soundeffect/melonSeed.mp3');
  }

  void playMelonSeedPlaceSound() {
    playSoundEffect('assets/soundeffect/melonSeedPlace.mp3');
  }

  void playCountdownSound() {
    playSoundEffect('assets/soundeffect/countdownDotSound.mp3');
  }

  void playClickDotSound() {
    playSoundEffect('assets/soundeffect/clickDotSound.mp3');
  }

  void playTickingClockSound() {
    playSoundEffect('assets/soundeffect/tickingClockSound.mp3');
  }

  void playClickDiceSound() {
    playSoundEffect('assets/soundeffect/clickDotSound.mp3');
  }

  void playPasteDiceSound() {
    playSoundEffect('assets/soundeffect/pasteDice.mp3');
  }

  void playBackMelonSeedSound() {
    playSoundEffect('assets/soundeffect/backMelonSeed.mp3');
  }

  void playSlideDownSound() {
    playSoundEffect('assets/soundeffect/slideDownBar.mp3');
  }

  void playSlideUpSound() {
    playSoundEffect('assets/soundeffect/slideUpBar.mp3');
  }

  void playScrollScreenDotHSound() {
    playSoundEffect('assets/soundeffect/scrollScreenDoth.mp3');
  }

  void playWrongDrawSound() {
    playSoundEffect('assets/soundeffect/wrongDraw.mp3');
  }

  void playQuizWinSound() {
    playSoundEffect('assets/soundeffect/quizWin.mp3');
  }

  void playSoundSettingButtonSound() {
    playSoundEffect('assets/soundeffect/soundSettingButton.mp3');
  }

  void playHitCorner1Sound() {
    playSoundEffect('assets/soundeffect/hitCorner1.mp3');
  }

  void playHitCorner2Sound() {
    playSoundEffect('assets/soundeffect/hitCorner2.mp3');
  }

  void setBackgroundVolume(double volume) {
    backgroundMusicController
        .setVolume(volume); // ปรับระดับเสียงของ Background Music
  }

  void playCorrectAnswerQuizDotSound() {
    playSoundEffect('assets/soundeffect/correctAnswerQuizDot.mp3');
  }

  void playWrongAnswerQuizDotSound() {
    playSoundEffect('assets/soundeffect/worngAnswerQuizDot.mp3');
  }

  void setSoundEffectVolume(double volume) {
    _soundEffectVolume = volume; // ปรับระดับเสียงของ Sound Effect
    for (var controller in soundEffectControllers.values) {
      controller.setVolume(volume);
    }
  }

  void playDragDiceSound() async {
    // ถ้าเสียงกำลังเล่นอยู่แล้ว ให้ไม่เล่นซ้ำ
    if (soundEffectControllers.containsKey('dragDice') &&
        soundEffectControllers['dragDice']!.playing) {
      return;
    }

    try {
      AudioPlayer controller = AudioPlayer();
      await controller.setAsset('assets/soundeffect/dragDice.mp3');
      controller.setVolume(_soundEffectVolume);

      await controller.play(); // เล่นเสียงครั้งเดียว

      // บันทึกตัวควบคุมเสียง
      soundEffectControllers['dragDice'] = controller;

      print('Playing dragDice sound once...');
    } catch (e) {
      print('Error playing dragDice sound: $e');
    }
  }

  void stopDragDiceSound() {
    if (soundEffectControllers.containsKey('dragDice')) {
      soundEffectControllers['dragDice']!.stop(); // หยุดเสียง
      soundEffectControllers.remove('dragDice'); // ลบออกจากระบบ
      print('Stopped dragDice sound.');
    }
  }

  void stopAllSounds() {
    // หยุดเสียง Background Music
    backgroundMusicController.stop();

    // หยุดเสียง Effect ทั้งหมด
    for (var controller in soundEffectControllers.values) {
      controller.stop();
    }

    print('All sounds stopped.');
  }

  Future<void> playSoundEffect(String assetPath) async {
    AudioPlayer? controller = soundEffectControllers[assetPath];
    if (controller == null) {
      try {
        print('Sound effect not preloaded: $assetPath. Loading now...');
        controller = AudioPlayer();
        await controller.setAsset(assetPath);
        controller.setVolume(_soundEffectVolume);
        soundEffectControllers[assetPath] = controller;
      } catch (e) {
        print('Error loading sound effect: $assetPath, Error: $e');
        return;
      }
    }

    try {
      await controller.stop(); // ✅ หยุดเสียงก่อนหน้า (ป้องกันเสียงค้าง)
      await controller.seek(Duration.zero);
      await controller.setClip(
          start: Duration.zero); // ✅ ป้องกันเสียงไม่เล่นซ้ำ
      controller.play();
      print('Playing sound: $assetPath');
    } catch (e) {
      print('Error playing sound: $assetPath, Error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _shouldPlayMusic) {
      print("App resumed - playing background music...");
      backgroundMusicController.play();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      print("App paused - pausing background music...");
      backgroundMusicController.pause();
    }
  }

  void pauseBackgroundMusic() {
    _shouldPlayMusic = false;
    backgroundMusicController.pause();
  }

  void playBackgroundMusic() {
    if (!_shouldPlayMusic || backgroundMusicController.playing) return;
    backgroundMusicController.play();
  }

  void dispose() {
    print('Disposing BackgroundAudioManager...');
    backgroundMusicController.dispose();
    soundEffectControllers.forEach((key, controller) {
      controller.dispose();
    });
    soundEffectControllers.clear();
    WidgetsBinding.instance.removeObserver(this);
  }
}
