// lib\screens\list_game_page\game_list_data.dart
import 'package:firstly/screens_chapter1/motionlevel1.dart';
import 'package:firstly/screens_chapter1/quizgamedot.dart';
import 'package:firstly/screens_chapter2/line_game_hard_screen.dart';
import 'package:firstly/screens_chapter2/line_game_motion.dart';
import 'package:firstly/screens_chapter2/line_game_quiz.dart';
import 'package:firstly/screens_chapter2/line_game_easy.dart';
import 'package:firstly/screens_chapter3/screen_game_shape_easy.dart';
import 'package:firstly/screens_chapter3/screen_game_shape_hard.dart';
import 'package:firstly/screens_chapter3/shape_quiz/screen/screen_game_shape_quiz.dart';
import 'package:firstly/screens_chapter4/game_color_easy.dart';
import 'package:firstly/screens_chapter4/game_color_hard.dart';
import 'package:firstly/screens_chapter4/quiz_color/game_color_quiz_screen/game_color_quiz_intro_screen.dart';
import 'package:firstly/widgets/stickerbook_page/widget/next_game_color_test.dart';
import 'package:firstly/widgets/stickerbook_page/widget/next_game_test.dart';
import 'package:flutter/material.dart';

import '../../../screens_chapter1/dotgameeasy.dart';
import '../../../screens_chapter1/dotgamehard.dart';

class ListGameData {
  final String title;
  bool isUnlocked;
  final String lockedImagePath;
  final String unlockedImagePath;
  final String warningImagePath;
  final int maxStars;
  int earnedStars;
  String starColor;
  final String stickerName;
  final Widget page;

  ListGameData({
    required this.title,
    required this.isUnlocked,
    required this.lockedImagePath,
    required this.unlockedImagePath,
    required this.maxStars,
    required this.earnedStars,
    required this.starColor,
    required this.stickerName,
    required this.page,
    required this.warningImagePath,
  });
}

const String imagePathForWarningDot =
    'assets/images/dotchapter/unlock_notification.png';
const String imagePathForWarningLine =
    'assets/images/game_list/warning_unlock_line.png';
const String imagePathForWarningShape =
    'assets/images/game_list/warning_unlock_shape.png';
const String imagePathForWarningColor =
    'assets/images/game_list/warning_unlock_color.png';

final List<ListGameData> dotGameLevels = [
  ListGameData(
    title: 'Dot Motion',
    isUnlocked: true,
    lockedImagePath: 'assets/images/dotchapter/card_lock.png',
    unlockedImagePath: 'assets/images/dotchapter/motion_card.png',
    maxStars: 0,
    earnedStars: 0,
    starColor: '',
    stickerName: 'sticker1',
    page: MotionLevel1(),
    warningImagePath: imagePathForWarningDot,
  ),
  ListGameData(
    title: 'Dot Easy',
    isUnlocked: false,
    lockedImagePath: 'assets/images/dotchapter/card_lock.png',
    unlockedImagePath: 'assets/images/dotchapter/lv1_card_unlock.png',
    maxStars: 3,
    earnedStars: 0,
    starColor: 'yellow',
    stickerName: 'sticker2',
    page: const DotGameEasy(),
    warningImagePath: imagePathForWarningDot,
  ),
  ListGameData(
    title: 'Dot Hard',
    isUnlocked: false,
    lockedImagePath: 'assets/images/dotchapter/card_lock.png',
    unlockedImagePath: 'assets/images/dotchapter/lv2_card_unlock.png',
    maxStars: 3,
    earnedStars: 0,
    starColor: 'yellow',
    stickerName: 'sticker3',
    page: const DotGameHard(),
    warningImagePath: imagePathForWarningDot,
  ),
  ListGameData(
    title: 'Dot Quiz',
    isUnlocked: false,
    lockedImagePath: 'assets/images/dotchapter/card_lock.png',
    unlockedImagePath: 'assets/images/dotchapter/quiz_card_unlock.png',
    maxStars: 1,
    earnedStars: 0,
    starColor: 'purple',
    stickerName: 'sticker4',
    page: const DotQuizGame(),
    warningImagePath: imagePathForWarningDot,
  ),
];

final List<ListGameData> lineGameLevels = [
  ListGameData(
      title: 'Line Motion',
      isUnlocked: true,
      lockedImagePath: 'assets/images/linegamelist/card_comic.png',
      unlockedImagePath: 'assets/images/linegamelist/card_comic.png',
      maxStars: 0,
      earnedStars: 0,
      starColor: '',
      stickerName: 'stickerLine1',
      page: const LineGameMotion(),
      warningImagePath: imagePathForWarningLine),
  ListGameData(
    title: 'Line Easy',
    isUnlocked: false,
    lockedImagePath: 'assets/images/linegamelist/card_lock.png',
    unlockedImagePath: 'assets/images/linegamelist/lv1_card_unlock.png',
    maxStars: 3,
    earnedStars: 0,
    starColor: 'yellow',
    stickerName: 'stickerLine2',
    page: DrawLineGameScreen(),
    warningImagePath: imagePathForWarningLine,
  ),
  ListGameData(
    title: 'Line Hard',
    isUnlocked: false,
    lockedImagePath: 'assets/images/linegamelist/card_lock.png',
    unlockedImagePath: 'assets/images/linegamelist/lv2_card_unlock.png',
    maxStars: 3,
    earnedStars: 0,
    starColor: 'yellow',
    stickerName: 'stickerLine3',
    page: const LineGameHardScreen(),
    warningImagePath: imagePathForWarningLine,
  ),
  ListGameData(
    title: 'Line Quiz',
    isUnlocked: false,
    lockedImagePath: 'assets/images/linegamelist/card_lock.png',
    unlockedImagePath: 'assets/images/linegamelist/quiz_card_unlock.png',
    maxStars: 1,
    earnedStars: 0,
    starColor: 'purple',
    stickerName: 'stickerLine4',
    page: const QuizLineGame(),
    warningImagePath: imagePathForWarningLine,
  ),
];

final List<ListGameData> shapeGameLevels = [
  ListGameData(
    title: 'Shape Motion',
    isUnlocked: true,
    lockedImagePath: 'assets/images/shapegame/card_lock.png',
    unlockedImagePath: 'assets/images/shapegame/card_comic.png',
    maxStars: 0,
    earnedStars: 0,
    starColor: '',
    stickerName: 'stickerShape1',
    page: const PageShapeMotionTest(),
    warningImagePath: imagePathForWarningShape,
  ),
  ListGameData(
    title: 'Shape Easy',
    isUnlocked: false,
    lockedImagePath: 'assets/images/shapegame/card_lock.png',
    unlockedImagePath: 'assets/images/shapegame/lv1_card_unlock.png',
    maxStars: 3,
    earnedStars: 0,
    starColor: 'yellow',
    stickerName: 'stickerShape2',
    page: const GameShapeEasyScreen(),
    warningImagePath: imagePathForWarningShape,
  ),
  ListGameData(
    title: 'Shape Hard',
    isUnlocked: false,
    lockedImagePath: 'assets/images/shapegame/card_lock.png',
    unlockedImagePath: 'assets/images/shapegame/lv2_card_unlock.png',
    maxStars: 3,
    earnedStars: 0,
    starColor: 'yellow',
    stickerName: 'stickerShape3',
    page: const GameShapeHardScreen(),
    warningImagePath: imagePathForWarningShape,
  ),
  ListGameData(
    title: 'Shape Quiz',
    isUnlocked: false,
    lockedImagePath: 'assets/images/shapegame/card_lock.png',
    unlockedImagePath: 'assets/images/shapegame/quiz_card_unlock.png',
    maxStars: 1,
    earnedStars: 0,
    starColor: 'purple',
    stickerName: 'stickerShape4',
    page: const ScreenGameShapeQuiz(),
    warningImagePath: imagePathForWarningShape,
  ),
];

final List<ListGameData> colorGameLevels = [
  ListGameData(
    title: 'Color Motion',
    isUnlocked: true,
    lockedImagePath: 'assets/images/colorgame/card_lock.png',
    unlockedImagePath: 'assets/images/colorgame/card_comic.png',
    maxStars: 0,
    earnedStars: 0,
    starColor: '',
    stickerName: 'stickerColor1',
    page: const PageColorMotionTest(),
    warningImagePath: imagePathForWarningColor,
  ),
  ListGameData(
    title: 'Color Easy',
    isUnlocked: false,
    lockedImagePath: 'assets/images/colorgame/card_lock.png',
    unlockedImagePath: 'assets/images/colorgame/lv1_card_unlock.png',
    maxStars: 3,
    earnedStars: 0,
    starColor: 'yellow',
    stickerName: 'stickerColor2',
    page: const GameColorEasyScreen(),
    warningImagePath: imagePathForWarningColor,
  ),
  ListGameData(
    title: 'Color Hard',
    isUnlocked: false,
    lockedImagePath: 'assets/images/colorgame/card_lock.png',
    unlockedImagePath: 'assets/images/colorgame/lv2_card_unlock.png',
    maxStars: 3,
    earnedStars: 0,
    starColor: 'yellow',
    stickerName: 'stickerColor3',
    page: const GameColorHardScreen(),
    warningImagePath: imagePathForWarningColor,
  ),
  ListGameData(
    title: 'Color Quiz',
    isUnlocked: false,
    lockedImagePath: 'assets/images/colorgame/card_lock.png',
    unlockedImagePath: 'assets/images/colorgame/quiz_card_unlock.png',
    maxStars: 1,
    earnedStars: 0,
    starColor: 'purple',
    stickerName: 'stickerColor4',
    page: const GameColorQuizIntroScreen(),
    warningImagePath: imagePathForWarningColor,
  ),
];
