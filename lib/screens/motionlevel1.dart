import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MotionLevel1 extends StatefulWidget {
  @override
  _MotionLevel1State createState() => _MotionLevel1State();
}

class _MotionLevel1State extends State<MotionLevel1>
    with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _textAnimationController;
  late Animation<double> _textScaleAnimation;
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  bool _showButton = false; // ตัวแปรควบคุมการแสดงปุ่ม
  int _currentVideoIndex = 0; // เก็บลำดับของวิดีโอที่กำลังเล่น
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
  bool _showNextText = false; // ควบคุมการแสดงข้อความ "แตะเพื่อไปต่อ"

  @override
  void initState() {
    super.initState();

    // ตั้งค่า AnimationController สำหรับข้อความ "แตะเพื่อไปต่อ"
    _textAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _textScaleAnimation =
        Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: Curves.easeInOut,
    ));

    // ตั้งค่า AnimationController สำหรับอนิเมชันหดขยายของปุ่ม
    _buttonAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _buttonScaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.elasticOut,
    ));

    _initializeAndPlayVideo();
  }

  void _initializeAndPlayVideo() {
    // กำหนด VideoPlayerController ใหม่ตามไฟล์วิดีโอ
    _controller = VideoPlayerController.asset(_videoPaths[_currentVideoIndex])
      ..initialize().then((_) {
        setState(() {
          _controller.play();
          _showNextText =
              false; // ซ่อนข้อความ "แตะเพื่อไปต่อ" ระหว่างเล่นวิดีโอ
        });
      });

    // เพิ่ม Listener เพื่อตรวจสอบเมื่อวิดีโอเล่นจบ
    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        if (_currentVideoIndex < _videoPaths.length - 1) {
          // ถ้ายังไม่ใช่วิดีโอสุดท้าย ให้แสดงข้อความ "แตะเพื่อไปต่อ"
          setState(() {
            _showNextText = true;
          });
        } else {
          // ถ้าเป็นวิดีโอสุดท้าย
          _onLastVideoEnd();
        }
      }
    });
  }

  void _onLastVideoEnd() {
    setState(() {
      _showButton = true; // แสดงปุ่ม
    });
    _buttonAnimationController.forward(); // เริ่มอนิเมชันหดขยายของปุ่ม
  }

  void _playNextVideo() {
    setState(() {
      _currentVideoIndex++;
      _controller.dispose(); // ลบ Controller เก่า
      _initializeAndPlayVideo(); // เริ่มเล่นวิดีโอถัดไป
    });
  }

  void _onButtonPressed() {
    Navigator.pop(context, {
      'earnedStars': 0, // ตัวอย่าง: ส่งจำนวนดาวที่ได้รับกลับไป
      'starColor': '' // ตัวอย่าง: ส่งสีของดาวกลับไป
    });
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
          // วิดีโอที่แสดงเต็มหน้าจอ
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
          // แสดงข้อความ "แตะเพื่อไปต่อ" ระหว่างวิดีโอ
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
            behavior: HitTestBehavior
                .opaque, // ทำให้ GestureDetector ตรวจจับการกดทั่วพื้นที่
            onTap: () {
              if (_showNextText) {
                _playNextVideo(); // ให้กดที่ส่วนไหนของหน้าจอก็ได้
              }
            },
          ),
          // แสดงปุ่ม Floating เมื่อเป็นวิดีโอสุดท้าย
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
