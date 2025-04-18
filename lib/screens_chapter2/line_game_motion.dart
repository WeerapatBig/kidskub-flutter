import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../screens/shared_prefs_service.dart';

class LineGameMotion extends StatefulWidget {
  const LineGameMotion({super.key});

  @override
  _LineGameMotionState createState() => _LineGameMotionState();
}

class _LineGameMotionState extends State<LineGameMotion>
    with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _textAnimationController;
  late Animation<double> _textScaleAnimation;
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  final prefsService = SharedPrefsService();

  bool _showButton = false; // ตัวแปรควบคุมการแสดงปุ่ม
  int _currentVideoIndex = 0; // เก็บลำดับของวิดีโอที่กำลังเล่น
  final List<String> _videoPaths = [
    'assets/motion/lineComp_1.mp4',
    'assets/motion/lineComp_2.mp4',
    'assets/motion/lineComp_3.mp4',
    'assets/motion/lineComp_4.mp4',
    'assets/motion/lineComp_5.mp4',
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

  void _onButtonPressed() async {
    // สมมติให้ Motion ได้ 0 ดาว และไม่มีสี (เพราะเป็นเลเวลแนะนำ)
    await prefsService.saveLevelData('Line Motion', 0, '', true);

    // ปลดล็อคด่านถัดไป (Dot Easy)
    await prefsService.updateLevelUnlockStatus('Line Motion', 'Line Easy');

    // Debug เช็คว่าข้อมูลถูกบันทึกหรือไม่
    final motionData = await prefsService.loadLevelData('Line Motion');
    final easyData = await prefsService.loadLevelData('Line Easy');
    print('Motion Data: $motionData');
    print('Easy Data: $easyData');

    print(
        "Pop from DotMotion -> route is: ${ModalRoute.of(context)?.settings.name}");
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
