//lib/function/result_widget.dart
import 'package:flutter/material.dart';

class ResultWidget extends StatefulWidget {
  final bool onLevelComplete;
  final int starsEarned;

  // เพิ่มพารามิเตอร์สำหรับกำหนดการนำทางของปุ่ม
  final VoidCallback onButton1Pressed;
  final VoidCallback onButton2Pressed;

  const ResultWidget(
      {super.key,
      required this.onLevelComplete,
      required this.starsEarned,
      required this.onButton1Pressed,
      required this.onButton2Pressed});

  @override
  _ResultWidgetState createState() => _ResultWidgetState();
}

class _ResultWidgetState extends State<ResultWidget>
    with TickerProviderStateMixin {
  late AnimationController _stageController;
  late Animation<Offset> _stageOffsetAnimation;
  late Animation<double> _stageRotationAnimation;

  late AnimationController _characterController;
  late Animation<Offset> _characterOffsetAnimation;

  late AnimationController _lightController;
  late Animation<Offset> _lightOffsetAnimation;

  late AnimationController _starController;
  late Animation<Offset> _starOffsetAnimation;
  late Animation<double> _starRotationAnimation;

  late AnimationController _group2Controller;
  late Animation<Offset> _group2OffsetAnimation;

  @override
  void initState() {
    super.initState();

    // Stage Animation
    _stageController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _stageOffsetAnimation = Tween<Offset>(
      begin: Offset(0.0, 3.0), // เริ่มจากด้านซ้าย
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _stageController, curve: Curves.easeOut));
    _stageRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * 1, // หมุนหนึ่งรอบ
    ).animate(CurvedAnimation(parent: _stageController, curve: Curves.easeOut));

    // Character Animation
    _characterController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _characterOffsetAnimation = Tween<Offset>(
      begin: Offset(0.0, -2.0), // เริ่มจากด้านบน
      end: Offset(0.0, 0.0),
    ).animate(
        CurvedAnimation(parent: _characterController, curve: Curves.easeOut));

    // Light Animation
    _lightController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _lightOffsetAnimation = Tween<Offset>(
      begin: Offset(0.0, -2.0), // เริ่มจากด้านบน
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _lightController, curve: Curves.easeOut));

    // Star Animation
    _starController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _starOffsetAnimation = Tween<Offset>(
      begin: Offset(2.5, 0.0), // เริ่มจากด้านขวา
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _starController, curve: Curves.easeOut));
    _starRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * 1, // หมุนหนึ่งรอบ
    ).animate(CurvedAnimation(parent: _starController, curve: Curves.easeOut));

    // Group 2 Animation
    _group2Controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _group2OffsetAnimation = Tween<Offset>(
      begin: Offset(0.0, 2.0), // เริ่มจากด้านล่าง
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _group2Controller, curve: Curves.easeIn));

    // เริ่มการเล่นอนิเมชันตามลำดับ
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await _stageController.forward();
    await _characterController.forward();
    await _starController.forward();
    await _lightController.forward();
    await _group2Controller.forward();
  }

  @override
  void dispose() {
    _stageController.dispose();
    _characterController.dispose();
    _starController.dispose();
    _lightController.dispose();
    _group2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String backgroundImage = widget.onLevelComplete
        ? 'assets/images/result/overlay_black.png'
        : 'assets/images/result/overlay_black.png';

    String stageImage = widget.onLevelComplete
        ? 'assets/images/result/stage1.png'
        : 'assets/images/result/stage2.png';

    String characterImage = widget.onLevelComplete
        ? 'assets/images/result/character1.png'
        : 'assets/images/result/character2.png';

    String lightImage = widget.onLevelComplete
        ? 'assets/images/result/light1.png'
        : 'assets/images/result/light2.png';

    String starsImage = 'assets/images/result/star${widget.starsEarned}.png';

    // ดึงขนาดหน้าจอ
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double imageHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // ภาพพื้นหลังแสดงเต็มหน้าจอ
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.02), // ฉากหลังโปร่งใส
              child: Image.asset(
                backgroundImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // เนื้อหาของวิดเจ็ต
          Stack(
            alignment: Alignment.center,
            children: [
              // กลุ่มที่ 1: อนิเมชัน
              Positioned(
                top: screenHeight * -0.25,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SlideTransition(
                    position: _lightOffsetAnimation,
                    child: SizedBox(
                        width: screenWidth * 0.9,
                        height: screenHeight * 0.9,
                        child: Image.asset(
                          lightImage,
                          fit: BoxFit.fitHeight,
                        )),
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.515,
                child: SlideTransition(
                  position: _stageOffsetAnimation,
                  child: RotationTransition(
                    turns: _stageRotationAnimation,
                    child: SizedBox(
                        height: imageHeight * 0.27,
                        child: Image.asset(
                          stageImage,
                          fit: BoxFit.contain,
                        )),
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.09,
                child: SlideTransition(
                  position: _starOffsetAnimation,
                  child: RotationTransition(
                    turns: _starRotationAnimation,
                    child: SizedBox(
                        height: screenHeight * 0.26,
                        child: Image.asset(
                          starsImage,
                        )),
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.265,
                child: SlideTransition(
                  position: _characterOffsetAnimation,
                  child: SizedBox(
                      height: screenHeight * 0.445,
                      child: Image.asset(characterImage)),
                ),
              ),

              // กลุ่มที่ 2: ปุ่มและอนิเมชัน
              Positioned(
                bottom: screenHeight * 0.05,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _group2OffsetAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ปุ่มที่ 1
                      _AnimatedButton(
                        width: screenWidth * 0.13,
                        height: screenHeight * 0.2,
                        onPressed: widget.onButton1Pressed,
                        imageAsset: widget.onLevelComplete
                            ? 'assets/images/result/playagain2.png'
                            : 'assets/images/result/back.png',
                      ), // เพิ่มระยะห่างระหว่างปุ่ม
                      // ปุ่มที่ 2
                      _AnimatedButton(
                        width: screenWidth * 0.16,
                        height: screenHeight * 0.24,
                        onPressed: widget.onButton2Pressed,
                        imageAsset: widget.onLevelComplete
                            ? 'assets/images/result/next.png'
                            : 'assets/images/result/playagain.png',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final double width;
  final double height;
  final VoidCallback onPressed;
  final String imageAsset;

  const _AnimatedButton({
    required this.width,
    required this.height,
    required this.onPressed,
    required this.imageAsset,
  });

  @override
  __AnimatedButtonState createState() => __AnimatedButtonState();
}

class __AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animationScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
    );
    _animationScale = Tween<double>(begin: 1.0, end: 0.9).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward(); // เริ่มการย่อขนาด
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse(); // กลับคืนขนาดเดิม
  }

  void _onTapCancel() {
    _controller.reverse(); // กลับคืนขนาดเดิม
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (details) {
        _onTapUp(details);
        widget.onPressed(); // เรียกใช้งานเมื่อกดปุ่ม
      },
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _animationScale,
        builder: (context, child) {
          return Transform.scale(
            scale: _animationScale.value,
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: ElevatedButton(
                onPressed: null, // ปิดการตอบสนองของปุ่ม ElevatedButton เอง
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                child: Image.asset(widget.imageAsset),
              ),
            ),
          );
        },
      ),
    );
  }
}
