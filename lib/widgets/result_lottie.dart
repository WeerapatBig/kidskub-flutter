import 'package:flutter/material.dart';
import 'dart:async';

class ResultWidgetLottie extends StatefulWidget {
  final bool onLevelComplete;
  final int starsEarned;
  final String imagePath;
  final VoidCallback onButton1Pressed;
  final VoidCallback onButton2Pressed;

  const ResultWidgetLottie({
    super.key,
    required this.onLevelComplete,
    required this.starsEarned,
    required this.imagePath,
    required this.onButton1Pressed,
    required this.onButton2Pressed,
  });

  @override
  State<ResultWidgetLottie> createState() => _ResultWidgetLottieState();
}

class _ResultWidgetLottieState extends State<ResultWidgetLottie> {
  bool _showSecondImage = false;

  @override
  void initState() {
    super.initState();
    if (widget.onLevelComplete) {
      Future.delayed(const Duration(milliseconds: 4400), () {
        if (mounted) {
          setState(() => _showSecondImage = true);
        }
      });
    }
  }

  String _getStarsStPath() =>
      'assets/images/result/gif_anim_result/${widget.imagePath}_chapter_result/${widget.starsEarned}_stars_st.gif';
  String _getStarsNdPath() =>
      'assets/images/result/gif_anim_result/${widget.imagePath}_chapter_result/${widget.starsEarned}_stars_nd.gif';

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
              child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 500),
            firstCurve: Curves.bounceInOut,
            secondCurve: Curves.bounceInOut,
            firstChild: Image.asset(
              _getStarsStPath(),
              width: MediaQuery.of(context).size.width * 0.7,
            ),
            secondChild: Image.asset(
              _getStarsNdPath(),
              width: MediaQuery.of(context).size.width * 0.7,
            ),
            crossFadeState: _showSecondImage
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          )),
        Positioned(
          bottom: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AnimatedButton(
                imagePath: 'assets/images/result/exit.png',
                onPressed: widget.onButton1Pressed,
              ),
              _AnimatedButton(
                imagePath: 'assets/images/result/next_yellow.png',
                onPressed: widget.onButton2Pressed,
              ),
              _AnimatedButton(
                imagePath: 'assets/images/result/replay_yellow.png',
                onPressed: widget.onButton2Pressed,
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
        scale: _controller..forward(),
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
