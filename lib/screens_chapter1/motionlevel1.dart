import 'package:firstly/function/background_audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../screens/shared_prefs_service.dart';

class MotionLevel1 extends StatefulWidget {
  @override
  _MotionLevel1State createState() => _MotionLevel1State();
}

class _MotionLevel1State extends State<MotionLevel1>
    with TickerProviderStateMixin {
  VideoPlayerController? _controller; // เปลี่ยนเป็น nullable เพื่อป้องกัน error
  late AnimationController _textAnimationController;
  late Animation<double> _textScaleAnimation;
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  final prefsService = SharedPrefsService();

  bool _isProcessingTap = false;
  bool _showNextText = false;
  bool _showButton = false;
  int _currentVideoIndex = 0;
  final List<String> _videoPaths = [
    'assets/motion/Scene1.mp4',
    'assets/motion/Scene2.mp4',
    'assets/motion/Scene3.mp4',
    'assets/motion/Scene4.mp4',
    'assets/motion/Scene5.mp4',
    'assets/motion/Scene6.mp4',
    'assets/motion/Scene7.mp4',
    'assets/motion/Scene8.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeAndPlayVideo();
  }

  void _initializeAnimations() {
    _textAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
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
  }

  void _initializeAndPlayVideo() async {
    if (_currentVideoIndex >= _videoPaths.length) {
      _onLastVideoEnd();
      return;
    }

    // กำจัด controller เก่าถ้ามี
    if (_controller != null) {
      await _controller!.dispose();
    }

    // สร้าง controller ใหม่
    _controller = VideoPlayerController.asset(_videoPaths[_currentVideoIndex])
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _showNextText = false;
          });
          _controller!.setVolume(1.0);
          _controller!.play();
        }
      });

    _controller!.addListener(() {
      if (mounted && _controller!.value.isInitialized) {
        if (_controller!.value.position >= _controller!.value.duration) {
          if (mounted) {
            setState(() {
              _showNextText = true;
            });
          }
        }
      }
    });
  }

  void _onScreenTap() async {
    if (_isProcessingTap || !_showNextText) return;

    _isProcessingTap = true;
    await _playNextVideo();
    _isProcessingTap = false;
  }

  Future<void> _playNextVideo() async {
    if (_currentVideoIndex < _videoPaths.length - 1) {
      await _controller?.pause(); // หยุดวิดีโอปัจจุบัน
      VideoPlayerController? oldController = _controller;

      await oldController?.dispose(); // กำจัด controller เก่า
      setState(() {
        _currentVideoIndex++;
        _showNextText = false;
      });

      await Future.delayed(Duration(milliseconds: 200)); // ให้เวลา dispose
      _initializeAndPlayVideo();
    } else {
      _onLastVideoEnd();
    }
  }

  void _onLastVideoEnd() {
    setState(() {
      _showButton = true;
      _showNextText = false;
    });
    _buttonAnimationController.forward();
  }

  void _onButtonPressed() async {
    // สมมติให้ Motion ได้ 0 ดาว และไม่มีสี (เพราะเป็นเลเวลแนะนำ)
    await prefsService.saveLevelData('Dot Motion', 0, '', true);

    // ปลดล็อคด่านถัดไป (Dot Easy)
    await prefsService.updateLevelUnlockStatus('Dot Motion', 'Dot Easy');

    // Debug เช็คว่าข้อมูลถูกบันทึกหรือไม่
    final motionData = await prefsService.loadLevelData('Dot Motion');
    final easyData = await prefsService.loadLevelData('Dot Easy');
    print('Motion Data: $motionData');
    print('Easy Data: $easyData');

    print(
        "Pop from DotMotion -> route is: ${ModalRoute.of(context)?.settings.name}");
    Navigator.pop(context);
  }

  @override
  void dispose() {
    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.dispose();
    }
    if (_textAnimationController.isAnimating) {
      _textAnimationController.dispose();
    }
    if (_buttonAnimationController.isAnimating) {
      _buttonAnimationController.dispose();
    }
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
                child: _controller != null && _controller!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
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
                    color: Colors.white,
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
                BackgroundAudioManager().playButtonClickSound();
                _onScreenTap();
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
