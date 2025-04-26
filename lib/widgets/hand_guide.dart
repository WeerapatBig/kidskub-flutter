import 'package:flutter/material.dart';

class HandGuide extends StatefulWidget {
  final Offset start;
  final Offset end;
  final double angle;
  final double scale;
  final Duration duration;
  final bool flipX;
  final String assetPath;
  final int maxLoops;

  const HandGuide({
    super.key,
    required this.start,
    required this.end,
    this.angle = 0,
    this.scale = 1.0,
    this.duration = const Duration(milliseconds: 1000),
    this.flipX = false,
    this.assetPath = 'assets/images/hand_guide.png',
    this.maxLoops = 8,
  });

  @override
  State<HandGuide> createState() => _HandGuideState();
}

class _HandGuideState extends State<HandGuide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  int loopCount = 0;
  bool isVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _slideAnim = Tween<Offset>(
      begin: widget.start,
      end: widget.end,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse(); // ไปถึง end ➔ กลับไป start
      } else if (status == AnimationStatus.dismissed) {
        loopCount++; // นับรอบเมื่อกลับมาที่ start
        if (loopCount >= widget.maxLoops) {
          _controller.stop();
          setState(() {
            isVisible = false; // ซ่อน
          });
        } else {
          _controller.forward(); // กลับไปเดินหน้าใหม่
        }
      }
    });

    _controller.forward(); // เริ่มต้นไปข้างหน้า
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _slideAnim,
      builder: (_, child) {
        return Positioned(
          left: _slideAnim.value.dx,
          top: _slideAnim.value.dy,
          child: IgnorePointer(
            ignoring: true,
            child: Transform.rotate(
              angle: widget.angle,
              child: Transform.scale(
                scale: widget.scale,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(widget.flipX ? 3.1416 : 0),
                  child: Image.asset(
                    widget.assetPath,
                    width: 80,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
