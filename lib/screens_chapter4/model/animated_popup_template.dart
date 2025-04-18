import 'package:flutter/material.dart';

class AnimatedPopupTemplate extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double beginScale;
  final double endScale;

  const AnimatedPopupTemplate({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.beginScale = 0.1,
    this.endScale = 1.0,
  }) : super(key: key);

  @override
  State<AnimatedPopupTemplate> createState() => _AnimatedPopupTemplateState();
}

class _AnimatedPopupTemplateState extends State<AnimatedPopupTemplate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}
