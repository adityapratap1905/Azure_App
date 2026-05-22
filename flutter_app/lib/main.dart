import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/quiz_models.dart';
import 'services/question_repository.dart';
import 'services/quiz_engine.dart';
import 'services/theme_controller.dart';

part 'theme/app_theme.dart';
part 'screens/dashboard_screen.dart';
part 'screens/topics_screen.dart';
part 'screens/quiz_screen.dart';
part 'screens/analysis_screen.dart';
part 'screens/profile_screen.dart';
part 'widgets/shared_widgets.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(AzureQuizApp(repository: QuestionRepository()));
}

class AzureQuizApp extends StatefulWidget {
  const AzureQuizApp({super.key, required this.repository});

  final QuestionRepository repository;

  @override
  State<AzureQuizApp> createState() => _AzureQuizAppState();
}

class _AzureQuizAppState extends State<AzureQuizApp> {
  final ThemeController _themeController = ThemeController();

  @override
  void initState() {
    super.initState();
    _themeController.load();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CloudCert Studio',
          themeMode: _themeController.themeMode,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          home: QuizHome(
            repository: widget.repository,
            themeController: _themeController,
          ),
        );
      },
    );
  }
}

enum AppStep { setup, quiz, results }

enum AppTab { home, topics, practice, analytics, profile }

class QuizHome extends StatefulWidget {
  const QuizHome({
    super.key,
    required this.repository,
    required this.themeController,
  });

  final QuestionRepository repository;
  final ThemeController themeController;

  @override
  State<QuizHome> createState() => _QuizHomeState();
}

class _QuizHomeState extends State<QuizHome> {
  AppStep _step = AppStep.setup;
  AppTab _tab = AppTab.home;
  QuizConfig _config = const QuizConfig(
    mode: QuizMode.practice,
    examType: 'AZ-900',
    questionCount: 10,
    difficulty: Difficulty.easy,
  );
  List<Question> _allQuestions = const [];
  Map<String, int> _questionCounts = const {};
  List<Question> _questions = const [];
  final Map<String, dynamic> _answers = {};
  int _currentIndex = 0;
  DateTime _startedAt = DateTime.now();
  QuizResult? _result;
  bool _loading = false;
  String? _error;

  ExamTrack get _selectedTrack => _trackForCode(_config.examType);

  @override
  void initState() {
    super.initState();
    _loadLearningData();
  }

  Future<void> _loadLearningData() async {
    try {
      final questions = await widget.repository.loadQuestions();
      final counts = <String, int>{'total': questions.length};
      for (final question in questions) {
        counts.update(
          question.examType,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
      if (!mounted) return;
      setState(() {
        _allQuestions = questions;
        _questionCounts = counts;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  Future<void> _startQuiz(QuizConfig config) async {
    setState(() {
      _loading = true;
      _error = null;
      _config = config;
    });
    try {
      final questions = await widget.repository.getQuestionsForConfig(config);
      if (questions.isEmpty) {
        throw StateError('No questions found for ${config.examType}.');
      }
      setState(() {
        _questions = questions;
        _answers.clear();
        _currentIndex = 0;
        _startedAt = DateTime.now();
        _step = AppStep.quiz;
        _tab = AppTab.practice;
      });
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _answerCurrent(dynamic answer) {
    final question = _questions[_currentIndex];
    setState(() => _answers[question.id] = answer);
  }

  void _next() {
    if (_currentIndex + 1 >= _questions.length) {
      setState(() {
        _result = QuizEngine.calculateResult(
          questions: _questions,
          answers: _answers,
          startTime: _startedAt,
        );
        _step = AppStep.results;
        _tab = AppTab.analytics;
      });
    } else {
      setState(() => _currentIndex++);
    }
  }

  void _previous() {
    if (_currentIndex == 0) return;
    setState(() => _currentIndex--);
  }

  void _restart() {
    setState(() {
      _step = AppStep.setup;
      _questions = const [];
      _answers.clear();
      _currentIndex = 0;
      _result = null;
      _error = null;
      _tab = AppTab.practice;
    });
  }

  void _selectTrack(ExamTrack track) {
    if (!track.available) return;
    setState(() {
      _config = QuizConfig(
        mode: _config.mode,
        examType: track.code,
        questionCount: _config.questionCount,
        difficulty: _config.difficulty,
      );
    });
  }

  Future<void> _startTrack(
    ExamTrack track, {
    QuizMode mode = QuizMode.practice,
    Difficulty? difficulty,
  }) async {
    final availableQuestions = _questionCounts[track.code] ?? 0;
    if (!track.available || availableQuestions == 0) {
      _showUnavailableTrack(track);
      return;
    }
    final questionCount = mode == QuizMode.examination
        ? math.min(50, availableQuestions)
        : math.min(_config.questionCount, availableQuestions);
    await _startQuiz(
      QuizConfig(
        mode: mode,
        examType: track.code,
        questionCount: questionCount,
        difficulty: mode == QuizMode.practice
            ? difficulty ?? _config.difficulty ?? Difficulty.easy
            : null,
      ),
    );
  }

  void _showUnavailableTrack(ExamTrack track) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${track.code} content is coming soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = _buildTab();

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: AppDurations.medium,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: KeyedSubtree(key: ValueKey(_tab), child: child),
        ),
      ),
      bottomNavigationBar: CloudCertBottomNav(
        selectedTab: _tab,
        onSelected: (tab) => setState(() => _tab = tab),
      ),
    );
  }

  Widget _buildTab() {
    return switch (_tab) {
      AppTab.home => DashboardScreen(
        selectedTrack: _selectedTrack,
        questionCounts: _questionCounts,
        allQuestions: _allQuestions,
        lastResult: _result,
        loading: _loading,
        onSelectTrack: _selectTrack,
        onViewAllExams: () => setState(() => _tab = AppTab.topics),
        onStartPractice: (track) => _startTrack(track),
        onStartMock: (track) => _startTrack(track, mode: QuizMode.examination),
      ),
      AppTab.topics => TopicsScreen(
        selectedTrack: _selectedTrack,
        questions: _allQuestions,
        questionCounts: _questionCounts,
        onSelectTrack: _selectTrack,
        onStartTopic: (track, difficulty) =>
            _startTrack(track, difficulty: difficulty),
        onStartMock: (track) => _startTrack(track, mode: QuizMode.examination),
      ),
      AppTab.practice => _buildPracticeTab(),
      AppTab.analytics =>
        _result == null
            ? AnalyticsScreen(
                allQuestions: _allQuestions,
                selectedTrack: _selectedTrack,
                questionCounts: _questionCounts,
              )
            : ResultsScreen(result: _result!, onRestart: _restart),
      AppTab.profile => ProfileScreen(
        selectedTrack: _selectedTrack,
        questionCounts: _questionCounts,
        lastResult: _result,
        themeController: widget.themeController,
        onSelectTrack: _selectTrack,
      ),
    };
  }

  Widget _buildPracticeTab() {
    return switch (_step) {
      AppStep.quiz =>
        _loading
            ? const Center(child: CircularProgressIndicator())
            : QuizScreen(
                config: _config,
                question: _questions[_currentIndex],
                questionIndex: _currentIndex,
                totalQuestions: _questions.length,
                answer: _answers[_questions[_currentIndex].id],
                startedAt: _startedAt,
                onAnswer: _answerCurrent,
                onNext: _next,
                onPrevious: _previous,
                onSkip: _next,
              ),
      AppStep.results => ResultsScreen(result: _result!, onRestart: _restart),
      AppStep.setup => QuizSetupScreen(
        onStart: _startQuiz,
        onStartTrack: _startTrack,
        questionCounts: _questionCounts,
        loading: _loading,
        error: _error,
        initialConfig: _config,
      ),
    };
  }
}

class CloudCertBottomNav extends StatelessWidget {
  const CloudCertBottomNav({
    super.key,
    required this.selectedTab,
    required this.onSelected,
  });

  final AppTab selectedTab;
  final ValueChanged<AppTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final navItems = const [
      (AppTab.home, Icons.home_rounded, 'Home'),
      (AppTab.topics, Icons.menu_book_outlined, 'Exams'),
      (AppTab.analytics, Icons.bar_chart_rounded, 'Progress'),
      (AppTab.profile, Icons.person_outline_rounded, 'Profile'),
    ];
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 92,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 70,
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: .96),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colorScheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .10),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  for (var index = 0; index < navItems.length; index++) ...[
                    if (index == 2) const SizedBox(width: 74),
                    Expanded(
                      child: _BottomNavItem(
                        icon: navItems[index].$2,
                        label: navItems[index].$3,
                        selected: selectedTab == navItems[index].$1,
                        onTap: () => onSelected(navItems[index].$1),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 2,
              child: _PracticeNavButton(
                selected: selectedTab == AppTab.practice,
                onTap: () => onSelected(AppTab.practice),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.md),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeNavButton extends StatelessWidget {
  const _PracticeNavButton({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          height: 66,
          width: 66,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF258DFF), Color(0xFF006DDB)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.azure.withValues(alpha: selected ? .42 : .26),
                blurRadius: selected ? 24 : 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.track_changes_rounded, color: Colors.white, size: 24),
              SizedBox(height: 2),
              Text(
                'Practice',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
