import 'package:flutter/material.dart';

class PulseEffect extends StatefulWidget {
  final double size;
  final Color color;
  final Offset position;

  const PulseEffect({
    Key? key,
    required this.size,
    required this.color,
    required this.position,
  }) : super(key: key);

  @override
  _PulseEffectState createState() => _PulseEffectState();
}

class _PulseEffectState extends State<PulseEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: widget.position,
          child: Transform.scale(
            scale: _animation.value,
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 50, 0),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 0),
                    )
                  ]),
            ),
          ),
        );
      },
    );
  }
}
