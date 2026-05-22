import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/quiz_models.dart';

class QuestionRepository {
  QuestionRepository({AssetBundle? bundle, Random? random})
    : _bundle = bundle ?? rootBundle,
      _random = random ?? Random();

  final AssetBundle _bundle;
  final Random _random;
  List<Question>? _cache;

  Future<List<Question>> loadQuestions() async {
    if (_cache != null) return _cache!;
    final raw = await _bundle.loadString('assets/questions.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    _cache = decoded
        .whereType<Map>()
        .map((item) => Question.fromJson(Map<String, dynamic>.from(item)))
        .where(
          (question) => question.id.isNotEmpty && question.examType.isNotEmpty,
        )
        .toList(growable: false);
    return _cache!;
  }

  Future<List<Question>> getQuestionsForConfig(QuizConfig config) async {
    final allQuestions = await loadQuestions();
    final filtered = allQuestions.where((question) {
      if (question.examType != config.examType) return false;
      if (config.mode == QuizMode.practice && config.difficulty != null) {
        return question.difficulty == config.difficulty!.name;
      }
      return true;
    }).toList();

    filtered.shuffle(_random);
    return filtered.take(min(config.questionCount, filtered.length)).toList();
  }

  Future<Map<String, int>> questionCounts() async {
    final allQuestions = await loadQuestions();
    final counts = <String, int>{'total': allQuestions.length};
    for (final question in allQuestions) {
      counts.update(question.examType, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }
}
