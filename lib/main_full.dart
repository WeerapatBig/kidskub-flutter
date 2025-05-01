import 'package:firstly/function/background_audio_manager.dart';
import 'package:firstly/widgets/gamesettingsdialog.dart';
import 'package:firstly/widgets/progressbar_lineeasy.dart';
import 'package:firstly/widgets/result_widget_quiz.dart';
//import 'package:firstly/function/progressbar_dothard.dart';
//import 'package:firstly/function/result_widget.dart';
import 'package:firstly/widgets/showsticker.dart';
import 'package:firstly/screens_chapter1/dotgamehard.dart';
import 'package:firstly/screens/gameselectionpage.dart';
import 'package:firstly/screens/homepage.dart';
import 'package:firstly/screens_chapter1/motionlevel1.dart';
import 'package:firstly/screens_chapter1/quizgamedot.dart';
import 'package:firstly/screens_chapter2/line_game_hard_screen.dart';
import 'package:firstly/screens_chapter2/line_game_easy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/stickerbook_page/strickerbook.dart';
//import 'package:flutter/rendering.dart'; //เปิดการแสดงผลขอบเขต Widget

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    ValueNotifier<int> remainingTime = ValueNotifier<int>(120);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.kodchasanTextTheme(),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/gamesettingsdialog': (context) => const GameSettingsDialog(),
        '/strickerbook': (context) => const StickerBookPage(),
        '/showsticker': (context) => const ShowStickerPage(
              stickerKey: 'stricker1',
            ),
        '/gameselectionpage': (context) => const GameSelectionPage(),

        '/line_game_test': (contex) => DrawLineGameScreen(),
        '/line_game_hard_test': (contex) => const LineGameHardScreen(
            // starColor: 'yellow',
            // earnedStars: 0,
            ),
        '/dotgamehard': (context) => const DotGameHard(),
        '/quizgamedot': (context) => const DotQuizGame(),
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
        '/progressbar_lineeasy': (context) => ProgressBarLineEasyWidget(
              remainingTime: remainingTime,
              maxTime: 120,
              starCount: 3,
            ),
        // '/progressbar_dothard': (context) =>
        //     const ProgressBarDotHardWidget(remainingTime: 60, getStars: 1),
        '/motionlevel1': (context) => MotionLevel1(),
      },
    );
  }
}
