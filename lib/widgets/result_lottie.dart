import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ResultWidgetLottie extends StatefulWidget {
  final bool onLevelComplete;
  final int starsEarned;
  final VoidCallback onButton1Pressed;
  final VoidCallback onButton2Pressed;
  final VoidCallback onButton3Pressed;

  const ResultWidgetLottie({
    super.key,
    required this.onLevelComplete,
    required this.starsEarned,
    required this.onButton1Pressed,
    required this.onButton2Pressed,
    required this.onButton3Pressed,
  });

  @override
  State<ResultWidgetLottie> createState() => _ResultWidgetLottieState();
}

class _ResultWidgetLottieState extends State<ResultWidgetLottie>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isLooping = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  String _getLottiePath() {
    return 'assets/lottie/Yellow_${widget.starsEarned}_Stars_Score_Anim.json';
  }

  void _onLottieLoaded(LottieComposition composition) {
    _controller
      ..duration = composition.duration
      ..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isLooping) {
        _isLooping = true;
        if (widget.starsEarned == 0) {
          // ได้ 0 ดาว → ให้หยุดที่ 90%
          _controller.animateTo(
            0.9,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        } else {
          const double loopStart = 0.71; // 70% ของ timeline
          const double loopEnd = 0.85; // 100% ของ timeline
          _controller.repeat(
            min: loopStart,
            max: loopEnd,
            period: Duration(
                milliseconds: ((loopEnd - loopStart) *
                        composition.duration.inMilliseconds)
                    .round()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          color: Colors.black.withOpacity(0.7),
        ),
        if (widget.onLevelComplete)
          Center(
            child: Lottie.asset(
              _getLottiePath(),
              controller: _controller,
              onLoaded: _onLottieLoaded,
              width: MediaQuery.of(context).size.width * 0.8,
              fit: BoxFit.contain,
            ),
          ),
        Positioned(
          bottom: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AnimatedButton(
                imagePath: 'assets/images/result/exit.png',
                onPressed: widget.onButton1Pressed,
              ),
              const SizedBox(width: 20),
              _AnimatedButton(
                imagePath: 'assets/images/result/next_yellow.png',
                onPressed: widget.onButton2Pressed,
              ),
              const SizedBox(width: 20),
              _AnimatedButton(
                imagePath: 'assets/images/result/replay_yellow.png',
                onPressed: widget.onButton3Pressed,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final String imagePath;
  final VoidCallback onPressed;

  const _AnimatedButton({
    required this.imagePath,
    required this.onPressed,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.9,
      upperBound: 1.0,
    );
    _controller.forward();
  }

  void _onTapDown(TapDownDetails details) => _controller.reverse();
  void _onTapUp(TapUpDetails details) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (details) {
        _onTapUp(details);
        widget.onPressed();
      },
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _controller,
        child: Image.asset(
          widget.imagePath,
          width: 120,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
