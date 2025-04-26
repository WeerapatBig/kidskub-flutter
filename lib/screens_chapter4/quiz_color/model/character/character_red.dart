import 'package:firstly/function/mediaquery_values.dart';
import 'package:flutter/material.dart';

class CharacterRed extends StatefulWidget {
  const CharacterRed({super.key});

  /// เรียกจากภายนอกเพื่อให้ตัวละครออกจากหน้าจอแบบ slide down
  static Future<void> exitWithSlide(GlobalKey<CharacterRedState> key) async {
    if (key.currentState != null) {
      await key.currentState!.exitCharacter();
    }
  }

  @override
  State<CharacterRed> createState() => CharacterRedState();
}

class CharacterRedState extends State<CharacterRed>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideCtrl,
      curve: Curves.easeOutBack,
    ));

    _slideCtrl.forward();
  }

  Future<void> exitCharacter() async {
    await _slideCtrl.reverse(); // slide ลง
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnim,
      child: Image.asset(
        'assets/images/colorgame/quiz_color/dialog/character_red.png',
        width: context.screenWidth * 0.3,
      ),
    );
  }
}
