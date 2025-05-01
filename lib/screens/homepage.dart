// ignore: file_names
import 'package:firstly/function/background_audio_manager.dart';
import 'package:firstly/screens/gameselectionpage.dart';
import 'package:firstly/widgets/stickerbook_page/strickerbook.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:firstly/widgets/gamesettingsdialog.dart';

class FloatingAsset {
  Offset position;
  Offset velocity;
  final String imagePath;
  final double width;
  final double height;
  bool isBeingDragged = false; // เพิ่มตัวแปรนี้

  FloatingAsset({
    required this.position,
    required this.velocity,
    required this.imagePath,
    required this.width,
    required this.height,
  });
}

// Home Page
class HomePage extends StatefulWidget {
  final bool showHeader;
  final bool showMiddle;
  final bool showFooter;
  final bool showButton;

  const HomePage({
    Key? key,
    this.showHeader = true,
    this.showMiddle = true,
    this.showFooter = true,
    this.showButton = true,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  double _scaleButton1 = 1.0;
  double _scaleButton2 = 1.0;
  double _scaleButton3 = 1.0;

  final Duration _duration = const Duration(milliseconds: 100);

  final BackgroundAudioManager backgroundAudioManager =
      BackgroundAudioManager();

  // รายการของ Asset
  List<FloatingAsset> _assets = [];
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  // ขนาดของหน้าจอ
  late Size screenSize;

  late AnimationController _controller;
  late Animation<Offset> _imageSlideAnimation;
  late Animation<Offset> _rowSlideAnimation;

  @override
  void initState() {
    super.initState();
    BackgroundAudioManager()
        .playBackgroundMusic(); // สร้างอินสแตนซ์เพื่อเริ่มต้นเสียงเพลง

    // สร้างรายการของ Asset
    _assets = [
      FloatingAsset(
        position: const Offset(-350, -180),
        velocity: const Offset(-5, 5),
        width: 200,
        height: 200,
        imagePath: 'assets/images/homepage/rectangle2.png',
      ),
      FloatingAsset(
        position: const Offset(400, 300),
        velocity: const Offset(10, -10),
        width: 180,
        height: 180,
        imagePath: 'assets/images/homepage/rectangle1.png',
      ),
      FloatingAsset(
        position: const Offset(150, -80),
        velocity: const Offset(1, 5),
        width: 300,
        height: 300,
        imagePath: 'assets/images/homepage/line.png',
      ),
      FloatingAsset(
        position: const Offset(450, -250),
        velocity: const Offset(20, -10),
        width: 280,
        height: 280,
        imagePath: 'assets/images/homepage/ellipse1.png',
      ),
      FloatingAsset(
        position: const Offset(-420, 180),
        velocity: const Offset(-10, 5),
        width: 400,
        height: 400,
        imagePath: 'assets/images/homepage/polygon1.png',
      ),
    ];

    // สร้าง Ticker สำหรับการเคลื่อนไหวของ Asset
    _ticker = createTicker((elapsed) {
      final deltaTime = (elapsed - _lastElapsed).inMilliseconds / 100.0;

      _lastElapsed = elapsed;

      setState(() {
        for (var asset in _assets) {
          if (!asset.isBeingDragged) {
            // ตรวจสอบว่ากำลังถูกลากหรือไม่
            asset.position += asset.velocity * deltaTime;
            // เพิ่มแรงเสียดทาน
            asset.velocity *= 0.999; // ลดความเร็วลง 1% ทุกเฟรม
            _checkBounds(asset);
          }
        }
      });
    });

    // กำหนดค่าเริ่มต้นของ Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // แอนิเมชันให้ภาพขยับขึ้น
    _imageSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -6.0), // ขยับขึ้นบน
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // แอนิเมชันให้ Row ขยับไปทางขวา
    _rowSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(3.0, 0.0), // ขยับไปทางขวา
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _startAnimationSequence2() async {
    // เริ่มต้นอนิเมชั่นของ _imageSlideAnimation
    await _controller.forward().orCancel;

    // หลังจาก _imageSlideAnimation เสร็จแล้ว รอให้ _rowSlideAnimation เริ่มทำงาน
    //_controller.reset(); // รีเซ็ตคอนโทรลเลอร์ก่อนเริ่มใหม่
    _controller.duration = const Duration(
        milliseconds: 500); // ตั้งระยะเวลาสำหรับ rowSlideAnimation

    await _controller
        .forward()
        .orCancel; // รอให้ _rowSlideAnimation ทำงานจนเสร็จ

    // เมื่อทั้งสองอนิเมชั่นเสร็จสิ้นแล้ว ให้ทำการเปลี่ยนหน้า
    _navigateToNextPage();
  }

//TO DO ChangeNamePage
  void _navigateToNextPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            const StickerBookPage(), // เปลี่ยนไปยังหน้าใหม่
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  void _startAnimationSequence() async {
    // เริ่มต้นอนิเมชั่นของ _imageSlideAnimation
    await _controller.forward().orCancel;

    // หลังจาก _imageSlideAnimation เสร็จแล้ว รอให้ _rowSlideAnimation เริ่มทำงาน
    //_controller.reset(); // รีเซ็ตคอนโทรลเลอร์ก่อนเริ่มใหม่
    _controller.duration = const Duration(
        milliseconds: 100); // ตั้งระยะเวลาสำหรับ rowSlideAnimation

    await _controller
        .forward()
        .orCancel; // รอให้ _rowSlideAnimation ทำงานจนเสร็จ

    // เมื่อทั้งสองอนิเมชั่นเสร็จสิ้นแล้ว ให้ทำการเปลี่ยนหน้า
    _navigateToLevelSelectionPage();
  }

  void _navigateToLevelSelectionPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            const GameSelectionPage(), // เปลี่ยนไปยังหน้าใหม่
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  // ตรวจสอบขอบเขตของ Asset เพื่อไม่ให้ออกนอกหน้าจอ
  void _checkBounds(FloatingAsset asset) {
    if (asset.position.dx < -screenSize.width / 2) {
      asset.position = Offset(-screenSize.width / 2, asset.position.dy);
      asset.velocity = Offset(-asset.velocity.dx, asset.velocity.dy);
      backgroundAudioManager.playHitCorner1Sound();
    }
    if (asset.position.dx > screenSize.width / 2) {
      asset.position = Offset(screenSize.width / 2, asset.position.dy);
      asset.velocity = Offset(-asset.velocity.dx, asset.velocity.dy);
      backgroundAudioManager.playHitCorner1Sound();
    }
    if (asset.position.dy < -screenSize.height / 2) {
      asset.position = Offset(asset.position.dx, -screenSize.height / 2);
      asset.velocity = Offset(asset.velocity.dx, -asset.velocity.dy);
      backgroundAudioManager.playHitCorner1Sound();
    }
    if (asset.position.dy > screenSize.height / 2) {
      asset.position = Offset(asset.position.dx, screenSize.height / 2);
      asset.velocity = Offset(asset.velocity.dx, -asset.velocity.dy);
      backgroundAudioManager.playHitCorner1Sound();
    }
  }

  @override
  Widget build(BuildContext context) {
    // กำหนดขนาดของหน้าจอ
    screenSize = MediaQuery.of(context).size;

    void _limitVelocity(FloatingAsset asset, double maxSpeed) {
      if (asset.velocity.distance > maxSpeed) {
        asset.velocity = (asset.velocity / asset.velocity.distance) * maxSpeed;
      }
    }

    // เริ่มต้น Ticker เมื่อได้ขนาดของหน้าจอแล้ว
    if (!_ticker.isActive) {
      _ticker.start();
    }

    return GestureDetector(
      onTap: () {
        BackgroundAudioManager()
            .playTouchScreenSound(); // เล่นเสียงเมื่อสัมผัสหน้าจอ
      },
      child: Scaffold(
        body: Container(
          // เพิ่มภาพพื้นหลัง
          decoration: widget.showHeader
              ? const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/homepage/grid.png'),
                    fit: BoxFit.cover,
                  ),
                )
              : null,

          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (widget.showMiddle)
                // แสดง Asset ทั้งหมด (วางไว้ก่อนเนื้อหาหลัก)
                ..._assets.map(
                  (asset) {
                    return Positioned(
                      left: (screenSize.width / 2) +
                          asset.position.dx -
                          asset.width / 2,
                      top: (screenSize.height / 2) +
                          asset.position.dy -
                          asset.height / 2,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanStart: (_) {
                          // ไม่ต้องหยุด Ticker แล้ว
                          asset.isBeingDragged =
                              true; // ตั้งค่าสถานะว่ากำลังถูกลาก
                          asset.velocity = Offset.zero;
                        },
                        onPanUpdate: (details) {
                          setState(() {
                            asset.position += details.delta;
                          });
                        },
                        onPanEnd: (details) {
                          asset.isBeingDragged = false; // ปล่อยสถานะการลาก
                          asset.velocity =
                              details.velocity.pixelsPerSecond / 60;
                          _limitVelocity(
                              asset, 300); // กำหนดความเร็วสูงสุดที่ 300 หน่วย
                          //_lastElapsed = Duration.zero; // รีเซ็ตเวลาเริ่มต้น
                          // ไม่ต้องเริ่ม Ticker ใหม่
                        },
                        child: Image.asset(
                          asset.imagePath,
                          width: asset.width,
                          height: asset.height,
                        ),
                      ),
                    );
                  },
                ),
              if (widget.showFooter)
                // เนื้อหาหลัก
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // รูปภาพด้านบน
                      SlideTransition(
                        position: _imageSlideAnimation,
                        child: Container(
                          width: screenSize.width * 0.6,
                          height: screenSize.height * 0.28,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/homepage/kidskubhomepage.png'),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      SlideTransition(
                        position: _rowSlideAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ปุ่มแรก
                            GestureDetector(
                              onTap: () {
                                BackgroundAudioManager()
                                    .playButtonClickSound(); // เล่นเสียงกดปุ่ม
                                _startAnimationSequence2();
                              },
                              onTapDown: (_) {
                                setState(() {
                                  _scaleButton1 = 0.9;
                                });
                              },
                              onTapUp: (_) {
                                setState(() {
                                  _scaleButton1 = 1.0;
                                });
                              },
                              onTapCancel: () {
                                setState(() {
                                  _scaleButton1 = 1.0;
                                });
                              },
                              child: AnimatedScale(
                                scale: _scaleButton1,
                                duration: _duration,
                                child: Image.asset(
                                  'assets/images/homepage/strickerbook_button.png',
                                  width: screenSize.width * 0.15,
                                  height: screenSize.height * 0.25,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: screenSize.width * 0.005,
                            ),
                            // ปุ่มที่สอง
                            GestureDetector(
                              onTap: () {
                                BackgroundAudioManager()
                                    .playButtonClickSound(); // เล่นเสียงกดปุ่ม
                                _startAnimationSequence();
                              },
                              onTapDown: (_) {
                                setState(() {
                                  _scaleButton2 = 0.9;
                                });
                              },
                              onTapUp: (_) {
                                setState(() {
                                  _scaleButton2 = 1.0;
                                });
                              },
                              onTapCancel: () {
                                setState(() {
                                  _scaleButton2 = 1.0;
                                });
                              },
                              child: AnimatedScale(
                                scale: _scaleButton2,
                                duration: _duration,
                                child: Image.asset(
                                  'assets/images/homepage/buttonplay.png',
                                  width: screenSize.width * 0.15,
                                  height: screenSize.height * 0.25,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.showButton)
                Positioned(
                  top: screenSize.height * 0.04,
                  right: screenSize.width * 0.02,
                  child: GestureDetector(
                    onTap: () {
                      BackgroundAudioManager()
                          .playButtonClickSound(); // เล่นเสียงกดปุ่ม
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const GameSettingsDialog();
                        },
                      );
                    },
                    onTapDown: (_) {
                      setState(() {
                        _scaleButton3 = 0.9;
                      });
                    },
                    onTapUp: (_) {
                      setState(() {
                        _scaleButton3 = 1.0;
                      });
                    },
                    onTapCancel: () {
                      setState(() {
                        _scaleButton3 = 1.0;
                      });
                    },
                    child: AnimatedScale(
                      scale: _scaleButton3,
                      duration: _duration,
                      child: Image.asset(
                        'assets/images/homepage/setting_button.png',
                        width: screenSize.width * 0.09,
                        height: screenSize.height * 0.12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
