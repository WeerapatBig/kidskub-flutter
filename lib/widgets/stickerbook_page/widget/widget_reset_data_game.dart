import 'package:firstly/function/mediaquery_values.dart';
import 'package:firstly/screens/shared_prefs_service.dart';
import 'package:firstly/widgets/custom_button.dart';
import 'package:firstly/widgets/stickerbook_page/services/sticker_prefs_service.dart';
import 'package:flutter/material.dart';

class WidgetResetDataGame extends StatelessWidget {
  const WidgetResetDataGame({super.key});

  void onPreesReset() async {
    //รีเซ้ตข้อมูลของ SharedPreferences ทั้งหมด

    final SharedPrefsService sharedPrefsService = SharedPrefsService();
    await sharedPrefsService.clearAllPreferences();

    final StickerBookPrefsService prefsService = StickerBookPrefsService();
    await prefsService.clearAllPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // พื้นหลังรูปภาพ
        Image.asset(
          'assets/images/homepage/reset_bg.png',
          width: context.screenWidth * 0.55,
        ),

        // ปุ่ม 2 ปุ่ม
        Positioned(
          bottom: context.screenHeight * 0.2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ปุ่มรีเซ็ต
              CustomButton(
                onTap: () {
                  onPreesReset(); // ฟังก์ชันรีเซ็ตข้อมูล
                  Navigator.of(context).pop(); // ปิด popup
                },
                child: Image.asset(
                  'assets/images/homepage/reset_button.png',
                  width: context.screenWidth * 0.2,
                ),
              ),
              const SizedBox(width: 20),
              // ปุ่มยังก่อน
              CustomButton(
                onTap: () {
                  Navigator.of(context).pop(); // ปิด popup
                },
                child: Image.asset(
                  'assets/images/homepage/hold_on_button.png',
                  width: context.screenWidth * 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
