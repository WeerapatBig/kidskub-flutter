import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final double scaleFactor;
  final Duration duration;

  const CustomButton({
    Key? key,
    required this.onTap,
    required this.child,
    this.scaleFactor = 0.92, // ขนาดเมื่อกด (ค่า default = 90% ของขนาดเดิม)
    this.duration = const Duration(milliseconds: 500), // ยืดเวลาให้สมูทขึ้น
  }) : super(key: key);

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        widget.onTap!(); // เรียกฟังก์ชันของปุ่มเมื่อปล่อยนิ้ว
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: widget.duration,
        curve: Curves.bounceIn, // ทำให้การเคลื่อนไหว "นุ่มนวล" และดูธรรมชาติ
        alignment: Alignment.center, // จัดให้อยู่ตรงกลาง
        child: Transform.scale(
          scale: _isPressed ? widget.scaleFactor : 1.0, // ลดขนาดไปที่ศูนย์กลาง
          child: widget.child,
        ),
      ),
    );
  }
}
