class QuizColorLevelData2 {
  final String color1;
  final String color2;
  final String color3;
  final int questIndex;
  final List<String> options;
  final String answerColor;

  QuizColorLevelData2({
    required this.color1,
    required this.color2,
    required this.color3,
    required this.questIndex,
    required this.options,
    required this.answerColor,
  });
}

final List<QuizColorLevelData2> quizColorLevels2 = [
  QuizColorLevelData2(
    color1: 'red',
    color2: 'yellow',
    color3: 'quest',
    questIndex: 2,
    options: ['blue', 'orange'],
    answerColor: 'orange',
  ),
  QuizColorLevelData2(
    color1: 'blue',
    color2: 'yellow',
    color3: 'quest',
    questIndex: 2,
    options: ['orange', 'green'],
    answerColor: 'green',
  ),
  QuizColorLevelData2(
    color1: 'red',
    color2: 'blue',
    color3: 'quest',
    questIndex: 2,
    options: ['green', 'purple'],
    answerColor: 'purple',
  ),
  QuizColorLevelData2(
    color1: 'yellow',
    color2: 'quest',
    color3: 'green',
    questIndex: 1,
    options: ['red', 'orange', 'blue'],
    answerColor: 'blue',
  ),
  QuizColorLevelData2(
    color1: 'quest',
    color2: 'blue',
    color3: 'purple',
    questIndex: 0,
    options: ['green', 'red', 'yellow'],
    answerColor: 'red',
  ),
  QuizColorLevelData2(
    color1: 'quest',
    color2: 'red',
    color3: 'orange',
    questIndex: 0,
    options: ['purple', 'yellow', 'blue'],
    answerColor: 'yellow',
  ),
  // ด่านต่อๆไปเพิ่มได้
];
