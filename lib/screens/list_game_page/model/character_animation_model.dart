import 'dart:math';

import 'package:flutter/material.dart';

import '../../../function/background_audio_manager.dart';

class CharacterAnimation extends StatefulWidget {
  final String imagePath;

  const CharacterAnimation({required this.imagePath});

  @override
  _CharacterAnimationState createState() => _CharacterAnimationState();
}

class _CharacterAnimationState extends State<CharacterAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // เรียกเมื่อหน้ากลับมาทำงาน
    BackgroundAudioManager().playBackgroundMusic();

    double screenWidth = MediaQuery.of(context).size.width;
    double characterSize = screenWidth * 0.1;

    _positionAnimation = Tween<double>(
      begin: -characterSize,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: -45.0,
      end: 15.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double characterSize = MediaQuery.of(context).size.width * 0.23;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          bottom: -50,
          left: _positionAnimation.value - 50,
          child: Transform.rotate(
            angle: _rotationAnimation.value * pi / 180,
            child: Image.asset(
              widget.imagePath,
              width: characterSize,
              height: characterSize,
            ),
          ),
        );
      },
    );
  }
}
