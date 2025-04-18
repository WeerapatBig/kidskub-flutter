import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../logic_game_color_quiz/logic_color_quiz_intro.dart';

class GameColorQuizIntroScreen extends StatelessWidget {
  const GameColorQuizIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameColorQuizIntro();

    return Scaffold(
      body: GameWidget(game: game),
    );
  }
}
