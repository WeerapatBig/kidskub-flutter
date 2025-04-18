import 'package:firstly/function/background_audio_manager.dart';
import 'package:firstly/screens/homepage.dart';
import 'package:firstly/screens/strickerbook.dart';
import 'package:firstly/screens/shared_prefs_service.dart';
import 'package:firstly/screens_chapter1/dotgameeasy.dart';
import 'package:firstly/screens_chapter1/dotgamehard.dart';
import 'package:firstly/screens_chapter1/motionlevel1.dart';
import 'package:firstly/screens_chapter1/quizgamedot.dart';
import 'package:firstly/screens_chapter2/line_game_quiz.dart';
import 'package:firstly/screens_chapter2/line_game_easy.dart';
import 'package:firstly/widgets/result_lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/list_game_page/list_game_dot_screen.dart';
import 'screens_chapter3/screen_game_shape_easy.dart';
import 'screens_chapter3/shape_quiz/screen/screen_game_shape_quiz.dart';
import 'screens_chapter4/game_color_easy.dart';
import 'screens_chapter4/game_color_hard.dart';
import 'screens_chapter4/quiz_color/game_color_quiz_screen/game_color_quiz_intro_screen.dart';
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
      initialRoute: '/game_color_quiz_intro_screen',
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
      return MaterialPageRoute(builder: (_) => DrawLineGameScreen());
    case '/motionlevel1':
      return MaterialPageRoute(builder: (_) => MotionLevel1());
    case '/dotgameeasy':
      return MaterialPageRoute(builder: (_) => DotGameEasy());
    case '/dotgamehard':
      return MaterialPageRoute(builder: (_) => DotGameHard());
    case '/quizgamedot':
      return MaterialPageRoute(builder: (_) => DotQuizGame());
    case '/line_game_quiz':
      return MaterialPageRoute(builder: (_) => QuizLineGame());
    case '/screen_game_shape_easy':
      return MaterialPageRoute(builder: (_) => GameShapeEasyScreen());
    case '/screen_game_shape_quiz':
      return MaterialPageRoute(builder: (_) => ScreenGameShapeQuiz());
    case '/list_game_dot_screen':
      return MaterialPageRoute(builder: (_) => ListGameDotScreen());
    case '/game_color_easy':
      return MaterialPageRoute(builder: (_) => GameColorEasyScreen());
    case '/game_color_quiz_intro_screen':
      return MaterialPageRoute(builder: (_) => GameColorQuizIntroScreen());
    case '/result_lottie.dart':
      return MaterialPageRoute(
          builder: (_) => ResultWidgetLottie(
                onLevelComplete: true,
                starsEarned: 0,
                onButton1Pressed: () {},
                onButton2Pressed: () {},
                imagePath: 'dot',
              ));
    case '/game_color_hard':
      return MaterialPageRoute(builder: (_) => const GameColorHardScreen());

    default:
      return null; // กรณี Route ไม่พบ
  }
}
