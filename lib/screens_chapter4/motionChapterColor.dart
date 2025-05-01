import 'package:firstly/screens/shared_prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MotionChapterColor extends StatefulWidget {
  const MotionChapterColor({super.key});

  @override
  State<MotionChapterColor> createState() => _MotionChapterColorState();
}

class _MotionChapterColorState extends State<MotionChapterColor>
    with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _textAnimationController;
  late Animation<double> _textScaleAnimation;
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  final prefsService = SharedPrefsService();

  bool _showButton = false;
  int _currentVideoIndex = 0;
  final List<String> _videoPaths = [
    'assets/motion/color_1.mp4',
    'assets/motion/color_2.mp4',
    'assets/motion/color_3.mp4',
    'assets/motion/color_4.mp4',
    'assets/motion/color_5.mp4',
    'assets/motion/color_6.mp4',
    'assets/motion/color_7.mp4',
    'assets/motion/color_8.mp4',
  ];
  bool _showNextText = false;

  @override
  void initState() {
    super.initState();

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

    _buttonAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _buttonScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _initializeAndPlayVideo();
  }

  void _initializeAndPlayVideo() {
    _controller = VideoPlayerController.asset(_videoPaths[_currentVideoIndex])
      ..initialize().then((_) {
        setState(() {
          _controller.play();
          _showNextText = false;
        });
      });

    _controller.addListener(() {
      if (_controller.value.isInitialized &&
          _controller.value.position >= _controller.value.duration) {
        if (_currentVideoIndex < _videoPaths.length - 1) {
          setState(() {
            _showNextText = true;
          });
        } else {
          _onLastVideoEnd();
        }
      }
    });
  }

  void _onLastVideoEnd() {
    setState(() {
      _showButton = true;
    });
    _buttonAnimationController.forward();
  }

  void _playNextVideo() {
    setState(() {
      _currentVideoIndex++;
      _controller.dispose();
      _initializeAndPlayVideo();
    });
  }

  void _onButtonPressed() async {
    // บันทึกข้อมูลของด่านปัจจุบัน
    await prefsService.saveLevelData('Color Motion', 0, '', true);

// ปลดล็อคด่านถัดไป
    await prefsService.updateLevelUnlockStatus('Color Motion', 'Color Easy');

    // ตรวจสอบข้อมูลที่บันทึก
    final result = await prefsService.loadLevelData('Color Motion');
    print("Saved Level Data: $result");

    // กลับไปยังหน้าเลือกเกม
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    _textAnimationController.dispose();
    _buttonAnimationController.dispose();
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
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: _controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : const Center(child: CircularProgressIndicator()),
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
          if (_showButton)
            Center(
              child: ScaleTransition(
                scale: _buttonScaleAnimation,
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: FloatingActionButton(
                    onPressed: _onButtonPressed,
                    backgroundColor: Colors.white,
                    elevation: 10.0,
                    child: const Icon(Icons.arrow_forward, size: 125),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
