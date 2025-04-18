import 'package:flutter/material.dart';

class TwoStateImageButton extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget childNormal; // รูปปกติ
  final Widget childPressed; // รูปตอนกด
  final double scaleFactor;
  final Duration duration;

  const TwoStateImageButton({
    Key? key,
    required this.onTap,
    required this.childNormal,
    required this.childPressed,
    this.scaleFactor = 0.8,
    this.duration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  _TwoStateImageButtonState createState() => _TwoStateImageButtonState();
}

class _TwoStateImageButtonState extends State<TwoStateImageButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // กดนิ้วลง
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      // ปล่อยนิ้ว
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        widget.onTap?.call(); // เรียกฟังก์ชันจริง
      },
      // ยกนิ้วออกนอกปุ่ม
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      // ชั้นใน: เรียก CustomButton เดิม โดยส่ง child เป็นรูปปกติหรือกด
      child: AnimatedContainer(
        duration: widget.duration,
        curve: Curves.bounceIn,
        child: Transform.scale(
          scale: _isPressed ? widget.scaleFactor : 1.0,
          // เลือกรูปภาพตามสถานะ
          child: _isPressed ? widget.childPressed : widget.childNormal,
        ),
      ),
    );
  }
}
