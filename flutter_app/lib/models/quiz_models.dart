enum QuestionType {
  mcq('mcq'),
  dragDrop('drag-drop'),
  matching('matching'),
  trueFalseTable('true-false-table'),
  dropdownFill('dropdown-fill'),
  dragDropMatching('drag-drop-matching');

  const QuestionType(this.value);
  final String value;

  static QuestionType fromJson(String value) {
    return QuestionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => QuestionType.mcq,
    );
  }
}

enum QuizMode { practice, examination }

enum Difficulty { easy, medium, hard }

class BlankOption {
  const BlankOption({required this.id, required this.options});

  factory BlankOption.fromJson(Map<String, dynamic> json) {
    return BlankOption(
      id: json['id'] as String? ?? '',
      options: List<String>.from(json['options'] as List? ?? const []),
    );
  }

  final String id;
  final List<String> options;
}

class MatchingPairs {
  const MatchingPairs({required this.left, required this.right});

  factory MatchingPairs.fromJson(Map<String, dynamic>? json) {
    return MatchingPairs(
      left: List<String>.from(json?['left'] as List? ?? const []),
      right: List<String>.from(json?['right'] as List? ?? const []),
    );
  }

  final List<String> left;
  final List<String> right;
}

class Question {
  const Question({
    required this.id,
    required this.question,
    required this.type,
    required this.correctAnswer,
    required this.category,
    required this.difficulty,
    required this.examType,
    this.options = const [],
    this.explanation = '',
    this.blanks = const [],
    this.matchingPairs = const MatchingPairs(left: [], right: []),
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      type: QuestionType.fromJson(json['type'] as String? ?? 'mcq'),
      options: List<String>.from(json['options'] as List? ?? const []),
      correctAnswer: json['correct_answer'],
      explanation: json['explanation'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      difficulty: json['difficulty'] as String? ?? 'easy',
      examType: json['exam_type'] as String? ?? 'AZ-900',
      blanks: (json['blanks'] as List? ?? const [])
          .map(
            (blank) =>
                BlankOption.fromJson(Map<String, dynamic>.from(blank as Map)),
          )
          .toList(),
      matchingPairs: MatchingPairs.fromJson(
        json['matchingPairs'] == null
            ? null
            : Map<String, dynamic>.from(json['matchingPairs'] as Map),
      ),
    );
  }

  final String id;
  final String question;
  final QuestionType type;
  final List<String> options;
  final dynamic correctAnswer;
  final String explanation;
  final String category;
  final String difficulty;
  final String examType;
  final List<BlankOption> blanks;
  final MatchingPairs matchingPairs;
}

class QuizConfig {
  const QuizConfig({
    required this.mode,
    required this.examType,
    required this.questionCount,
    this.difficulty,
  });

  final QuizMode mode;
  final String examType;
  final int questionCount;
  final Difficulty? difficulty;
}

class QuizResult {
  const QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.timeSpent,
    required this.categoryBreakdown,
    required this.difficultyBreakdown,
    required this.questions,
    required this.answers,
  });

  final int totalQuestions;
  final int correctAnswers;
  final int score;
  final Duration timeSpent;
  final Map<String, ScoreBreakdown> categoryBreakdown;
  final Map<String, ScoreBreakdown> difficultyBreakdown;
  final List<Question> questions;
  final Map<String, dynamic> answers;
}

class ScoreBreakdown {
  const ScoreBreakdown({required this.correct, required this.total});

  final int correct;
  final int total;

  ScoreBreakdown add({required bool isCorrect}) {
    return ScoreBreakdown(
      correct: correct + (isCorrect ? 1 : 0),
      total: total + 1,
    );
  }
}
