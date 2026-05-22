import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/models/quiz_models.dart';
import 'package:flutter_app/services/question_repository.dart';

void main() {
  test('loads JSON questions and filters by exam and difficulty', () async {
    final repository = QuestionRepository(bundle: _RepositoryBundle());

    final questions = await repository.loadQuestions();
    final practice = await repository.getQuestionsForConfig(
      const QuizConfig(
        mode: QuizMode.practice,
        examType: 'AZ-900',
        questionCount: 5,
        difficulty: Difficulty.easy,
      ),
    );

    expect(questions, hasLength(3));
    expect(practice, hasLength(1));
    expect(practice.single.examType, 'AZ-900');
    expect(practice.single.difficulty, 'easy');
  });

  test('limits examination results to requested count', () async {
    final repository = QuestionRepository(bundle: _RepositoryBundle());

    final questions = await repository.getQuestionsForConfig(
      const QuizConfig(
        mode: QuizMode.examination,
        examType: 'AI-900',
        questionCount: 1,
      ),
    );

    expect(questions, hasLength(1));
    expect(questions.single.examType, 'AI-900');
  });
}

class _RepositoryBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final encoded = utf8.encode(await loadString(key));
    return ByteData.sublistView(Uint8List.fromList(encoded));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return jsonEncode([
      _question('az_easy', 'AZ-900', 'easy'),
      null,
      _question('az_hard', 'AZ-900', 'hard'),
      _question('ai_easy', 'AI-900', 'easy'),
    ]);
  }

  Map<String, Object> _question(String id, String examType, String difficulty) {
    return {
      'id': id,
      'question': 'Test question?',
      'type': 'mcq',
      'options': ['A. One', 'B. Two'],
      'correct_answer': 'A',
      'category': 'General',
      'difficulty': difficulty,
      'exam_type': examType,
    };
  }
}
