import 'package:firstly/function/background_audio_manager.dart';
import 'package:firstly/screens/shared_prefs_service.dart';
import 'package:firstly/screens_chapter3/mini_game_shape/mini_game_shape_screen.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MotionChapterShape extends StatefulWidget {
  const MotionChapterShape({super.key});

  @override
  State<MotionChapterShape> createState() => _MotionChapterShapeState();
}

class _MotionChapterShapeState extends State<MotionChapterShape>
    with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _textAnimationController;
  late Animation<double> _textScaleAnimation;
  final prefsService = SharedPrefsService();

  bool _showNextText = false;
  bool _isVideoReady = false;

  int currentVideoIndex = 0;
  final List<String> videoPaths = [
    'assets/motion/shape_1.mp4',
    'assets/motion/shape_2.mp4',
    'assets/motion/shape_3.mp4',
    'assets/motion/shape_4.mp4',
    'assets/motion/shape_5.mp4',
  ];

  @override
  void initState() {
    super.initState();
    BackgroundAudioManager().pauseBackgroundMusic();

    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _textScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _initializeAndPlayVideo();
  }

  void _initializeAndPlayVideo() {
    _controller = VideoPlayerController.asset(videoPaths[currentVideoIndex])
      ..initialize().then((_) {
        setState(() {
          _isVideoReady = true;
          _controller.play();
          _showNextText = false;
        });
      });

    _controller.addListener(() {
      if (_controller.value.isInitialized &&
          _controller.value.position >= _controller.value.duration) {
        if (currentVideoIndex < videoPaths.length - 1) {
          setState(() {
            _showNextText = true;
          });
        } else {
          _onButtonPressed(); // วิดีโอสุดท้าย shape_5.mp4 จบ กลับเลย
        }
      }
    });
  }

  void _onButtonPressed() async {
    // บันทึกข้อมูลของด่านปัจจุบัน
    await prefsService.saveLevelData('Shape Motion', 0, '', true);

// ปลดล็อคด่านถัดไป
    await prefsService.updateLevelUnlockStatus('Shape Motion', 'Shape Easy');

    // ตรวจสอบข้อมูลที่บันทึก
    final result = await prefsService.loadLevelData('Shape Motion');
    print("Saved Level Data: $result");

    // กลับไปยังหน้าเลือกเกม
    Navigator.pop(context);
  }

  void _playNextVideo() async {
    if (currentVideoIndex == 2) {
      // เมื่อจบ shape_3.mp4 ไปเล่นมินิเกม
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MiniGameShapeScreen()),
      );

      if (result == true) {
        setState(() {
          currentVideoIndex++;
          _isVideoReady = false;
        });
        _controller.dispose();
        _initializeAndPlayVideo();
      } else {
        Navigator.pop(context);
      }
    } else {
      setState(() {
        currentVideoIndex++;
        _isVideoReady = false;
      });
      _controller.dispose();
      _initializeAndPlayVideo();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (!_isVideoReady || !_controller.value.isInitialized) {
                return const SizedBox.expand(
                  child: ColoredBox(color: Colors.black),
                );
              }
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              );
            },
          ),
          if (_showNextText)
            Positioned(
              bottom: screenHeight * 0.1,
              left: screenWidth / 2.3,
              child: ScaleTransition(
                scale: _textScaleAnimation,
                child: Text(
                  "แตะเพื่อไปต่อ",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: screenWidth * 0.02,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (_showNextText) {
                _playNextVideo();
              }
            },
          ),
        ],
      ),
    );
  }
}
