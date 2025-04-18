import 'package:flutter/material.dart';

class PulseWarningImage extends StatefulWidget {
  final String imagePath; // ไฟล์รูปที่จะแสดง
  final double beginScale; // ขนาดเริ่มต้น
  final double endScale; // ขนาดสูงสุด
  final Duration duration; // ระยะเวลาต่อรอบหนึ่งของการขยาย-ย่อ

  const PulseWarningImage({
    Key? key,
    required this.imagePath,
    this.beginScale = 1.0,
    this.endScale = 1.2,
    this.duration = const Duration(milliseconds: 800),
  }) : super(key: key);

  @override
  State<PulseWarningImage> createState() => _PulseWarningImageState();
}

class _PulseWarningImageState extends State<PulseWarningImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    // controller จะรัน forward + reverse วนลูปไม่มีที่สิ้นสุด
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    // สร้าง Tween จาก beginScale -> endScale เช่น 1.0 -> 1.2
    // และใช้ Curves.easeInOut ให้ smooth
    _scale = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose(); // ยกเลิกอนิเมชันเมื่อ Widget ถูกลบ
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale, // ใช้อนิเมชัน scale
      child: Image.asset(
        widget.imagePath,
        width: 600,
      ),
    );
  }
}
