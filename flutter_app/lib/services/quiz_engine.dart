import 'dart:convert';

import 'package:collection/collection.dart';

import '../models/quiz_models.dart';

class QuizEngine {
  static const _listEquality = ListEquality<String>();
  static const _mapEquality = DeepCollectionEquality.unordered();

  static bool isAnswered(Question question, dynamic answer) {
    if (answer == null || answer == '') return false;
    switch (question.type) {
      case QuestionType.mcq:
        return answer is String && answer.isNotEmpty;
      case QuestionType.dragDrop:
        return answer is List &&
            answer.any((item) => item != null && item != '');
      case QuestionType.trueFalseTable:
        if (answer is! Map) return false;
        return List.generate(
          question.options.length,
          (index) => index.toString(),
        ).every((key) => answer.containsKey(key) && answer[key] is bool);
      case QuestionType.dropdownFill:
        if (answer is! Map) return false;
        return question.blanks.every(
          (blank) => (answer[blank.id] as String?)?.isNotEmpty ?? false,
        );
      case QuestionType.dragDropMatching:
        if (answer is! Map) return false;
        return question.matchingPairs.left.every(
          (item) => (answer[item] as String?)?.isNotEmpty ?? false,
        );
      case QuestionType.matching:
        return answer is Map && answer.isNotEmpty;
    }
  }

  static bool checkAnswer(Question question, dynamic userAnswer) {
    if (userAnswer == null || userAnswer == '') return false;
    if (userAnswer is List && userAnswer.isEmpty) return false;
    if (userAnswer is Map && userAnswer.isEmpty) return false;

    switch (question.type) {
      case QuestionType.mcq:
        final user = userAnswer.toString().trim();
        final correct = question.correctAnswer.toString().trim();
        if (RegExp(r'^[A-D]$', caseSensitive: false).hasMatch(correct)) {
          return user.isNotEmpty &&
              user[0].toUpperCase() == correct.toUpperCase();
        }
        return user == correct;
      case QuestionType.dragDrop:
        if (userAnswer is! List || question.correctAnswer is! List) {
          return false;
        }
        final user = userAnswer
            .where((item) => item != null && item != '')
            .map((item) => item.toString().trim())
            .toList();
        final correct = (question.correctAnswer as List)
            .map((item) => item.toString().trim())
            .toList();
        return _listEquality.equals(user, correct);
      case QuestionType.trueFalseTable:
        return _mapEquality.equals(
          _normalizeMap(userAnswer),
          _normalizeMap(_decodeMaybeJson(question.correctAnswer)),
        );
      case QuestionType.dropdownFill:
      case QuestionType.dragDropMatching:
      case QuestionType.matching:
        return _mapEquality.equals(
          _normalizeMap(userAnswer),
          _normalizeMap(_decodeMaybeJson(question.correctAnswer)),
        );
    }
  }

  static QuizResult calculateResult({
    required List<Question> questions,
    required Map<String, dynamic> answers,
    required DateTime startTime,
  }) {
    var correctAnswers = 0;
    final categoryBreakdown = <String, ScoreBreakdown>{};
    final difficultyBreakdown = <String, ScoreBreakdown>{};

    for (final question in questions) {
      final isCorrect = checkAnswer(question, answers[question.id]);
      if (isCorrect) correctAnswers++;
      categoryBreakdown[question.category] =
          (categoryBreakdown[question.category] ??
                  const ScoreBreakdown(correct: 0, total: 0))
              .add(isCorrect: isCorrect);
      difficultyBreakdown[question.difficulty] =
          (difficultyBreakdown[question.difficulty] ??
                  const ScoreBreakdown(correct: 0, total: 0))
              .add(isCorrect: isCorrect);
    }

    final total = questions.length;
    return QuizResult(
      totalQuestions: total,
      correctAnswers: correctAnswers,
      score: total == 0 ? 0 : ((correctAnswers / total) * 100).round(),
      timeSpent: DateTime.now().difference(startTime),
      categoryBreakdown: categoryBreakdown,
      difficultyBreakdown: difficultyBreakdown,
      questions: questions,
      answers: Map<String, dynamic>.from(answers),
    );
  }

  static String fullAnswerText(Question question, dynamic answer) {
    if (answer == null || answer == '') return 'No answer';
    if (question.type == QuestionType.mcq && question.options.isNotEmpty) {
      final text = answer.toString().trim();
      if (RegExp(r'^[A-D]$', caseSensitive: false).hasMatch(text)) {
        final index = text.toUpperCase().codeUnitAt(0) - 'A'.codeUnitAt(0);
        if (index >= 0 && index < question.options.length) {
          return question.options[index];
        }
      }
      return text;
    }
    if (answer is List) {
      return answer.where((item) => item != null && item != '').join(' -> ');
    }
    if (answer is Map) {
      return answer.entries
          .map((entry) => '${entry.key}: ${entry.value}')
          .join(', ');
    }
    return answer.toString();
  }

  static String correctAnswerText(Question question) {
    return fullAnswerText(question, _decodeMaybeJson(question.correctAnswer));
  }

  static dynamic _decodeMaybeJson(dynamic value) {
    if (value is String &&
        (value.trim().startsWith('{') || value.trim().startsWith('['))) {
      try {
        return jsonDecode(value);
      } catch (_) {
        return value;
      }
    }
    return value;
  }

  static Map<String, dynamic> _normalizeMap(dynamic value) {
    if (value is! Map) return const {};
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
}
