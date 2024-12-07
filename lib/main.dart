import 'package:firstly/function/background_audio_manager.dart';
import 'package:firstly/function/gamesettingsdialog.dart';
import 'package:firstly/function/progressbar.dart';
import 'package:firstly/function/result_widget%20_quiz.dart';
//import 'package:firstly/function/progressbar_dothard.dart';
//import 'package:firstly/function/result_widget.dart';
import 'package:firstly/function/showsticker.dart';
import 'package:firstly/screens/colorgame_easy.dart';
import 'package:firstly/screens/colorgamehard.dart';
import 'package:firstly/screens/dotgamehard.dart';
import 'package:firstly/screens/dotgamelist.dart';
import 'package:firstly/screens/gameline2.dart';
import 'package:firstly/screens/gamelinehard.dart';
import 'package:firstly/screens/gameselectionpage.dart';
import 'package:firstly/screens/homepage.dart';
import 'package:firstly/screens/linegamelist.dart';
import 'package:firstly/screens/motionlevel1.dart';
import 'package:firstly/screens/quizgamedot.dart';
import 'package:firstly/screens/strickerbook.dart';
import 'package:firstly/screens/dotgameeasy.dart';
import 'package:firstly/screens/shared_prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:flutter/rendering.dart'; //เปิดการแสดงผลขอบเขต Widget

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // เรียกใช้การล้าง SharedPreferences
  final SharedPrefsService sharedPrefsService = SharedPrefsService();
  await sharedPrefsService.clearAllPreferences();

  final StickerBookPrefsService prefsService = StickerBookPrefsService();
  await prefsService.clearAllPreferences();

  BackgroundAudioManager(); // สร้างอินสแตนซ์เพื่อเริ่มต้นเสียงเพลง
  // ตั้งค่าหน้าจอเป็นแนวนอนเท่านั้น
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
      initialRoute: '/',
      theme: ThemeData(
        textTheme: GoogleFonts.kodchasanTextTheme(),
      ),
      routes: {
        '/': (context) => const HomePage(),
        '/gamesettingsdialog': (context) => const GameSettingsDialog(),
        '/strickerbook': (context) => const StickerBookPage(),
        '/showsticker': (context) => const ShowStickerPage(
              stickerKey: 'stricker1',
            ),
        '/gameselectionpage': (context) => const GameSelectionPage(),

        '/gameline-2': (context) => const GameLine2(), // Example of "เกมเส้น"
        '/dotgamehard': (context) => const DotGameHard(
              starColor: 'yellow',
              earnedStars: 0,
            ),
        '/colorgamehard': (context) => const ColorGameHard(),
        '/quizgamedot': (context) => const DotQuizGame(
              starColor: 'yellow',
              earnedStars: 0,
            ),
        '/colorgame_easy': (context) => const GameColorEasyScreen(),
        '/gamelinehard': (context) => const LineGameHard(),
        '/dotgamelist': (context) => const DotGameList(),
        '/linegamelist': (context) => const LineGameList(),
        '/dotgameeasy': (context) => const DotGameEasy(
              starColor: 'yellow',
              earnedStars: 0,
            ),
        '/result_widget_quiz': (context) => ResultWidgetQuiz(
              onLevelComplete: true,
              starsEarned: 0,
              onButton1Pressed: () {
                // ฟังก์ชันเมื่อปุ่มที่ 1 ถูกกด (เล่นอีกครั้ง)
                Navigator.pushReplacementNamed(context, '/playAgain');
              },
              onButton2Pressed: () {
                // ฟังก์ชันเมื่อปุ่มที่ 2 ถูกกด (หน้าถัดไป)
                Navigator.pushReplacementNamed(context, '/nextLevel');
              },
            ),
        '/progressbar': (context) => const ProgressBarWidget(
              getStars: 1,
              starPositions: [200.0, 450.0, 700.0],
            ),
        // '/progressbar_dothard': (context) =>
        //     const ProgressBarDotHardWidget(remainingTime: 60, getStars: 1),
        '/motionlevel1': (context) => MotionLevel1(),
      },
    );
  }
}
