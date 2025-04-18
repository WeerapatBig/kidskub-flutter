import 'dart:ui';

import '../game_color_hard.dart';

class TargetColorTracker {
  final List<Color> targets;
  final List<AnswerResult?> results;

  TargetColorTracker(this.targets)
      : results = List.filled(targets.length, null);

  bool get isAllCorrect => results.every((r) => r == AnswerResult.correct);

  void markAnswer(int index, bool isCorrect) {
    results[index] = isCorrect ? AnswerResult.correct : AnswerResult.wrong;
  }

  void reset() {
    for (int i = 0; i < results.length; i++) {
      results[i] = null;
    }
  }
}
