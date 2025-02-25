import 'package:firstly/function/background_audio_manager.dart';
import 'package:firstly/screens/homepage.dart';
import 'package:firstly/screens/strickerbook.dart';
import 'package:firstly/screens/shared_prefs_service.dart';
import 'package:firstly/screens_chapter2/line_game_quiz.dart';
import 'package:firstly/screens_chapter2/line_game_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens_chapter3/screen_game_shape_easy.dart';
//import 'package:flutter/rendering.dart'; //เปิดการแสดงผลขอบเขต Widget

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // โหลด SharedPreferences ล่วงหน้าเพื่อลดเวลาโหลด
  await SharedPrefsService().clearAllPreferences();
  await StickerBookPrefsService().clearAllPreferences();

  // จัดการ Background Audio ให้โหลดครั้งเดียว
  BackgroundAudioManager();

  // ตั้งค่าหน้าจอเป็นแนวนอน
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  //debugPaintSizeEnabled = true; // เปิดการแสดงผลขอบเขต Widget

  runApp(const DesignQuestApp());
}

class DesignQuestApp extends StatelessWidget {
  const DesignQuestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.kodchasanTextTheme(),
      ),
      initialRoute: '/screen_game_shape_easy',
      onGenerateRoute: _generateRoute,
    );
  }
}

// ✅ ปรับปรุงการกำหนด Routes ให้สั้นลง
Route<dynamic>? _generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const HomePage());
    case '/line_game_test':
      return MaterialPageRoute(
          builder: (_) => DrawLineGameScreen(
                starColor: 'yellow',
                earnedStars: 0,
              ));
    case '/line_game_quiz':
      return MaterialPageRoute(builder: (_) => QuizLineGame());
    case '/screen_game_shape_easy':
      return MaterialPageRoute(builder: (_) => GameShapeEasyScreen());

    default:
      return null; // กรณี Route ไม่พบ
  }
}
