import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/models/quiz_models.dart';
import 'package:flutter_app/services/quiz_engine.dart';

void main() {
  group('QuizEngine scoring', () {
    test('accepts letter-based MCQ answers', () {
      final question = _question(
        type: QuestionType.mcq,
        options: const [
          'A. Storage',
          'B. Compute',
          'C. Network',
          'D. Identity',
        ],
        correctAnswer: 'B',
      );

      expect(QuizEngine.checkAnswer(question, 'B. Compute'), isTrue);
      expect(QuizEngine.checkAnswer(question, 'A. Storage'), isFalse);
    });

    test('checks drag-drop ordering exactly', () {
      final question = _question(
        type: QuestionType.dragDrop,
        options: const ['Create resource group', 'Deploy app'],
        correctAnswer: const ['Create resource group', 'Deploy app'],
      );

      expect(
        QuizEngine.checkAnswer(question, [
          'Create resource group',
          'Deploy app',
        ]),
        isTrue,
      );
      expect(
        QuizEngine.checkAnswer(question, [
          'Deploy app',
          'Create resource group',
        ]),
        isFalse,
      );
    });

    test('checks true-false table maps', () {
      final question = _question(
        type: QuestionType.trueFalseTable,
        options: const ['Azure supports regions', 'All services are free'],
        correctAnswer: const {'0': true, '1': false},
      );

      expect(QuizEngine.checkAnswer(question, {'0': true, '1': false}), isTrue);
      expect(QuizEngine.checkAnswer(question, {'0': true, '1': true}), isFalse);
    });

    test('checks dropdown and matching maps', () {
      final dropdown = _question(
        type: QuestionType.dropdownFill,
        correctAnswer: const {'blank1': 'Azure Functions'},
      );
      final matching = _question(
        type: QuestionType.dragDropMatching,
        correctAnswer: const {'Compute': 'Virtual Machines'},
      );

      expect(
        QuizEngine.checkAnswer(dropdown, {'blank1': 'Azure Functions'}),
        isTrue,
      );
      expect(
        QuizEngine.checkAnswer(matching, {'Compute': 'Virtual Machines'}),
        isTrue,
      );
      expect(
        QuizEngine.checkAnswer(matching, {'Compute': 'Blob Storage'}),
        isFalse,
      );
    });

    test('calculates totals and breakdowns', () {
      final questions = [
        _question(correctAnswer: 'A', category: 'Identity', difficulty: 'easy'),
        _question(
          correctAnswer: 'B',
          category: 'Identity',
          difficulty: 'medium',
          id: 'q2',
        ),
      ];

      final result = QuizEngine.calculateResult(
        questions: questions,
        answers: {'q1': 'A. Correct', 'q2': 'A. Wrong'},
        startTime: DateTime.now().subtract(const Duration(seconds: 20)),
      );

      expect(result.totalQuestions, 2);
      expect(result.correctAnswers, 1);
      expect(result.score, 50);
      expect(result.categoryBreakdown['Identity']!.total, 2);
    });
  });
}

Question _question({
  String id = 'q1',
  QuestionType type = QuestionType.mcq,
  List<String> options = const ['A. Correct', 'B. Wrong'],
  dynamic correctAnswer = 'A',
  String category = 'General',
  String difficulty = 'easy',
}) {
  return Question(
    id: id,
    question: 'Test question?',
    type: type,
    options: options,
    correctAnswer: correctAnswer,
    category: category,
    difficulty: difficulty,
    examType: 'AZ-900',
  );
}
