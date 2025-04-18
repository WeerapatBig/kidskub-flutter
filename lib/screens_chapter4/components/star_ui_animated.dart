import 'package:flutter/material.dart';

import '../model/animated_popup_template.dart';

class AnimatedStar extends StatefulWidget {
  final bool isFilled;
  final String filledAsset;
  final String emptyAsset;

  const AnimatedStar({
    Key? key,
    required this.isFilled,
    required this.filledAsset,
    required this.emptyAsset,
  }) : super(key: key);

  @override
  State<AnimatedStar> createState() => _AnimatedStarState();
}

class _AnimatedStarState extends State<AnimatedStar> {
  bool _wasFilled = false;

  @override
  void didUpdateWidget(covariant AnimatedStar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isFilled && widget.isFilled) {
      _wasFilled = true;
    } else {
      _wasFilled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final starImage = Image.asset(
      widget.isFilled ? widget.filledAsset : widget.emptyAsset,
      width: 40,
      height: 40,
      fit: BoxFit.contain,
    );

    // ถ้ากำลังเปลี่ยนเป็นดาวเต็ม => เล่นแอนิเมชัน popup
    if (_wasFilled) {
      return AnimatedPopupTemplate(
          duration: const Duration(milliseconds: 1000),
          beginScale: 0.1,
          endScale: 1.0,
          child: starImage);
    }

    return starImage;
  }
}
