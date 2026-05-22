part of 'package:flutter_app/main.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.selectedTrack,
    required this.questionCounts,
    required this.allQuestions,
    required this.lastResult,
    required this.loading,
    required this.onSelectTrack,
    required this.onViewAllExams,
    required this.onStartPractice,
    required this.onStartMock,
  });

  final ExamTrack selectedTrack;
  final Map<String, int> questionCounts;
  final List<Question> allQuestions;
  final QuizResult? lastResult;
  final bool loading;
  final ValueChanged<ExamTrack> onSelectTrack;
  final VoidCallback onViewAllExams;
  final ValueChanged<ExamTrack> onStartPractice;
  final ValueChanged<ExamTrack> onStartMock;

  @override
  Widget build(BuildContext context) {
    final popularTracks = [
      'AZ-900',
      'AI-900',
      'CLF-C02',
      'SC-900',
    ].map(_trackForCode).toList(growable: false);
    final continueTrack = _trackForCode('AI-900');
    final topics = _homeTopics(allQuestions).take(4).toList();
    return PremiumScrollView(
      maxWidth: 430,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _DashboardHeader(),
          const SizedBox(height: 16),
          _DashboardHero(
            initialTrack: selectedTrack,
            questionCounts: questionCounts,
            loading: loading,
            onExploreTrack: onStartPractice,
          ),
          const SizedBox(height: AppSpacing.section),
          SectionHeader(
            title: 'Popular Exams',
            actionLabel: 'View all',
            onAction: onViewAllExams,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 176,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: popularTracks.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final track = popularTracks[index];
                return _PopularExamCard(
                  track: track,
                  questionCount: _displayQuestionCount(questionCounts, track),
                  selected: selectedTrack.code == track.code,
                  onTap: () => onSelectTrack(track),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          SectionHeader(title: 'Continue Learning'),
          const SizedBox(height: 12),
          _ContinueLearningCard(
            track: continueTrack,
            onContinue: () => onStartPractice(continueTrack),
          ),
          const SizedBox(height: AppSpacing.section),
          SectionHeader(
            title: 'Study by Topic',
            actionLabel: 'View all',
            onAction: onViewAllExams,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: topics.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) =>
                  _TopicMiniCard(topic: topics[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, Alex',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Let's continue your certification journey",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    height: 7,
                    width: 7,
                    decoration: BoxDecoration(
                      color: AppColors.azure,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.surface,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.card),
        SizedBox(
          height: 42,
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Search for exams, topics, or questions',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardHero extends StatefulWidget {
  const _DashboardHero({
    required this.initialTrack,
    required this.questionCounts,
    required this.loading,
    required this.onExploreTrack,
  });

  final ExamTrack initialTrack;
  final Map<String, int> questionCounts;
  final bool loading;
  final ValueChanged<ExamTrack> onExploreTrack;

  @override
  State<_DashboardHero> createState() => _DashboardHeroState();
}

class _DashboardHeroState extends State<_DashboardHero> {
  static const _autoSlideDuration = Duration(seconds: 5);
  static const _loopSeed = 1000;
  late final PageController _controller;
  late int _pageIndex;
  Timer? _timer;

  final List<ExamTrack> _slides = [
    _trackForCode('AZ-900'),
    _trackForCode('AI-900'),
    _trackForCode('DP-700'),
    _trackForCode('SC-900'),
  ];

  @override
  void initState() {
    super.initState();
    final initialIndex = math.max(
      0,
      _slides.indexWhere((track) => track.code == widget.initialTrack.code),
    );
    _pageIndex = (_loopSeed * _slides.length) + initialIndex;
    _controller = PageController(initialPage: _pageIndex);
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _DashboardHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTrack.code == widget.initialTrack.code) return;
    final nextIndex = _slides.indexWhere(
      (track) => track.code == widget.initialTrack.code,
    );
    if (nextIndex < 0 || nextIndex == _selectedSlide) return;
    final base = _pageIndex - _selectedSlide;
    _pageIndex = base + nextIndex;
    _controller.animateToPage(
      _pageIndex,
      duration: AppDurations.medium,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_autoSlideDuration, (_) => _showNextSlide());
  }

  void _showNextSlide() {
    if (!mounted || !_controller.hasClients) return;
    _controller.animateToPage(
      _pageIndex + 1,
      duration: AppDurations.medium,
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _pageIndex = index);
    _startTimer();
  }

  int get _selectedSlide => _pageIndex % _slides.length;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      borderColor: Colors.white.withValues(alpha: .16),
      child: SizedBox(
        height: 170,
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final track = _slides[index % _slides.length];
                return _DashboardHeroSlide(
                  track: track,
                  count: _countForTrack(widget.questionCounts, track),
                  loading: widget.loading,
                  onExplore: () => widget.onExploreTrack(track),
                );
              },
            ),
            Positioned(
              right: 16,
              bottom: 14,
              child: _HeroDots(count: _slides.length, selected: _selectedSlide),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeroSlide extends StatelessWidget {
  const _DashboardHeroSlide({
    required this.track,
    required this.count,
    required this.loading,
    required this.onExplore,
  });

  final ExamTrack track;
  final int count;
  final bool loading;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final enabled = track.available && count > 0;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [track.accent, track.gradientEnd],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(right: -18, bottom: -16, child: _CloudCluster()),
          Positioned(right: 24, top: 20, child: _CertifiedShield(track: track)),
          Positioned(
            left: 16,
            top: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Text(
                track.available
                    ? '${track.category} Certificate'
                    : 'Coming Soon',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 48,
            width: 218,
            child: Text(
              '${track.code}: Microsoft\n${track.name}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                height: 1.15,
                fontSize: 16,
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 91,
            width: 196,
            child: Text(
              enabled
                  ? '$count questions ready. ${track.description}'
                  : '${track.description} Content will unlock soon.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: .88),
                fontSize: 11,
                height: 1.18,
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: SizedBox(
              height: 34,
              child: FilledButton.icon(
                onPressed: enabled && !loading ? onExplore : null,
                iconAlignment: IconAlignment.end,
                icon: loading
                    ? const SizedBox.square(
                        dimension: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_rounded, size: 17),
                label: Text(enabled ? 'Explore ${track.code}' : 'Notify me'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: track.accent,
                  minimumSize: const Size(0, 34),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroDots extends StatelessWidget {
  const _HeroDots({required this.count, required this.selected});

  final int count;
  final int selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < count; index++)
          AnimatedContainer(
            duration: AppDurations.fast,
            curve: Curves.easeOut,
            height: 6,
            width: index == selected ? 18 : 6,
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: index == selected ? .95 : .45,
              ),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
      ],
    );
  }
}

class _CloudCluster extends StatelessWidget {
  const _CloudCluster();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      width: 178,
      child: Stack(
        children: [
          for (final cloud in const [
            (8.0, 30.0, 42.0),
            (44.0, 8.0, 56.0),
            (92.0, 28.0, 66.0),
            (126.0, 14.0, 44.0),
          ])
            Positioned(
              left: cloud.$1,
              top: cloud.$2,
              child: Container(
                height: cloud.$3,
                width: cloud.$3 * 1.45,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .22),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CertifiedShield extends StatelessWidget {
  const _CertifiedShield({required this.track});

  final ExamTrack track;

  @override
  Widget build(BuildContext context) {
    return CertificationBadgeMark(track: track, size: 106);
  }
}

class _PopularExamCard extends StatelessWidget {
  const _PopularExamCard({
    required this.track,
    required this.questionCount,
    required this.selected,
    required this.onTap,
  });

  final ExamTrack track;
  final int questionCount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 126,
      child: PremiumCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.sm),
        borderColor: selected ? track.accent.withValues(alpha: .58) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: MiniCertificationBadge(track: track, size: 62)),
            const SizedBox(height: 7),
            Text(
              track.code,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: track.accent,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                track.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontSize: 10,
                  height: 1.18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.quiz_outlined, color: track.accent, size: 12),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    '$questionCount Questions',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: track.accent,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MiniCertificationBadge extends StatelessWidget {
  const MiniCertificationBadge({
    super.key,
    required this.track,
    this.size = 58,
    this.disabled = false,
  });

  final ExamTrack track;
  final double size;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return CertificationBadgeMark(track: track, size: size, disabled: disabled);
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({required this.track, required this.onContinue});

  final ExamTrack track;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.card),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: track.accent.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(Icons.library_books_rounded, color: track.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${track.code}: Microsoft ${track.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Machine Learning Basics',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: .60,
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        color: track.accent,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '60% Complete',
                      style: TextStyle(
                        color: track.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 38,
            child: FilledButton(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                backgroundColor: track.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size(80, 38),
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicMiniCard extends StatelessWidget {
  const _TopicMiniCard({required this.topic});

  final StudyTopic topic;

  @override
  Widget build(BuildContext context) {
    final count = _topicDisplayCount(topic.title);
    return SizedBox(
      width: 86,
      child: PremiumCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: [
            Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                color: topic.color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(topic.icon, color: topic.color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              topic.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '$count Questions',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 8),
            ),
          ],
        ),
      ),
    );
  }
}

int _displayQuestionCount(Map<String, int> questionCounts, ExamTrack track) {
  final realCount = _countForTrack(questionCounts, track);
  if (realCount > 0) return realCount;
  return switch (track.code) {
    'CLF-C02' => 72,
    'SC-900' => 85,
    'DP-900' => 74,
    _ => 65,
  };
}

List<StudyTopic> _homeTopics(List<Question> questions) {
  return const [
    StudyTopic(
      title: 'Cloud Concepts',
      subtitle: '32 Questions',
      icon: Icons.cloud_queue_rounded,
      progress: .72,
      color: AppColors.azure,
      difficulty: Difficulty.easy,
    ),
    StudyTopic(
      title: 'AI Fundamentals',
      subtitle: '28 Questions',
      icon: Icons.psychology_rounded,
      progress: .48,
      color: AppColors.purple,
      difficulty: Difficulty.easy,
    ),
    StudyTopic(
      title: 'Security',
      subtitle: '36 Questions',
      icon: Icons.shield_outlined,
      progress: .36,
      color: AppColors.success,
      difficulty: Difficulty.medium,
    ),
    StudyTopic(
      title: 'Pricing & Support',
      subtitle: '16 Questions',
      icon: Icons.analytics_outlined,
      progress: .58,
      color: AppColors.warning,
      difficulty: Difficulty.medium,
    ),
  ];
}

int _topicDisplayCount(String title) {
  return switch (title) {
    'Cloud Concepts' => 32,
    'AI Fundamentals' => 28,
    'Security' => 36,
    'Pricing & Support' => 16,
    _ => 24,
  };
}

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({
    super.key,
    required this.onStart,
    required this.onStartTrack,
    required this.questionCounts,
    required this.loading,
    required this.initialConfig,
    this.error,
  });

  final ValueChanged<QuizConfig> onStart;
  final Future<void> Function(
    ExamTrack track, {
    QuizMode mode,
    Difficulty? difficulty,
  })
  onStartTrack;
  final Map<String, int> questionCounts;
  final bool loading;
  final QuizConfig initialConfig;
  final String? error;

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  late QuizMode _mode = widget.initialConfig.mode;
  late String _examType = widget.initialConfig.examType;
  late Difficulty _difficulty =
      widget.initialConfig.difficulty ?? Difficulty.easy;
  late int _questionCount = widget.initialConfig.questionCount;

  ExamTrack get _selectedTrack => _trackForCode(_examType);

  String get _modeLabel =>
      _mode == QuizMode.practice ? 'Practice Mode' : 'Mock Test';

  String get _difficultyLabel => _mode == QuizMode.practice
      ? '${_difficulty.name[0].toUpperCase()}${_difficulty.name.substring(1)}'
      : 'Mixed';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final count = _countForTrack(widget.questionCounts, _selectedTrack);
    final canStart = _selectedTrack.available && count > 0;
    return PremiumScrollView(
      maxWidth: 860,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Practice studio',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Set the pace, choose the exam, and start a focused session.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _MockSimulationPanel(
            track: _selectedTrack,
            count: count,
            loading: widget.loading,
            onStart: canStart
                ? () => widget.onStartTrack(
                    _selectedTrack,
                    mode: QuizMode.examination,
                  )
                : null,
          ),
          const SizedBox(height: 16),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ChoiceGroup<QuizMode>(
                  title: 'Session type',
                  value: _mode,
                  options: const {
                    QuizMode.practice: (
                      'Practice Mode',
                      'Filter by difficulty and learn with less pressure',
                      Icons.track_changes_rounded,
                    ),
                    QuizMode.examination: (
                      'Examination Mode',
                      'Mixed difficulty with exam-style timing',
                      Icons.workspace_premium_rounded,
                    ),
                  },
                  onChanged: (value) => setState(() => _mode = value),
                ),
                const SizedBox(height: AppSpacing.section),
                SectionHeader(
                  title: 'Certification',
                  subtitle: 'Only tracks with local questions can start.',
                ),
                const SizedBox(height: 12),
                for (final track in _availableExamTracks) ...[
                  CertificationCard(
                    track: track,
                    questionCount: _countForTrack(widget.questionCounts, track),
                    selected: _examType == track.code,
                    compact: true,
                    onTap: () => setState(() => _examType = track.code),
                    onStart: () {},
                  ),
                  const SizedBox(height: 10),
                ],
                if (_mode == QuizMode.practice) ...[
                  const SizedBox(height: 10),
                  _ChoiceGroup<Difficulty>(
                    title: 'Difficulty',
                    value: _difficulty,
                    options: const {
                      Difficulty.easy: (
                        'Easy',
                        'Basic concepts',
                        Icons.sentiment_satisfied_rounded,
                      ),
                      Difficulty.medium: (
                        'Medium',
                        'Scenario practice',
                        Icons.trending_up_rounded,
                      ),
                      Difficulty.hard: (
                        'Hard',
                        'Exam pressure',
                        Icons.local_fire_department_rounded,
                      ),
                    },
                    onChanged: (value) => setState(() => _difficulty = value),
                  ),
                ],
                const SizedBox(height: AppSpacing.section),
                DropdownButtonFormField<int>(
                  initialValue: _questionCount,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Number of Questions',
                    prefixIcon: Icon(Icons.format_list_numbered_rounded),
                  ),
                  selectedItemBuilder: (context) => const [
                    Text('5 Questions', overflow: TextOverflow.ellipsis),
                    Text('10 Questions', overflow: TextOverflow.ellipsis),
                    Text('20 Questions', overflow: TextOverflow.ellipsis),
                    Text('50 Questions', overflow: TextOverflow.ellipsis),
                  ],
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5 Questions')),
                    DropdownMenuItem(value: 10, child: Text('10 Questions')),
                    DropdownMenuItem(value: 20, child: Text('20 Questions')),
                    DropdownMenuItem(value: 50, child: Text('50 Questions')),
                  ],
                  onChanged: (value) =>
                      setState(() => _questionCount = value ?? 10),
                ),
                if (widget.error != null) ...[
                  const SizedBox(height: AppSpacing.card),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.dense),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.error!,
                            style: TextStyle(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.section),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusBadge(
                      icon: Icons.badge_rounded,
                      label: 'Exam: $_examType',
                      color: _selectedTrack.accent,
                    ),
                    StatusBadge(
                      icon: Icons.fact_check_rounded,
                      label: '$_questionCount questions',
                      color: AppColors.success,
                    ),
                    StatusBadge(
                      icon: Icons.speed_rounded,
                      label: _difficultyLabel,
                      color: AppColors.warning,
                    ),
                    StatusBadge(
                      icon: _mode == QuizMode.practice
                          ? Icons.track_changes_rounded
                          : Icons.workspace_premium_rounded,
                      label: _modeLabel,
                      color: AppColors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: widget.loading || !canStart
                      ? null
                      : () => widget.onStart(
                          QuizConfig(
                            mode: _mode,
                            examType: _examType,
                            questionCount: math.min(_questionCount, count),
                            difficulty: _mode == QuizMode.practice
                                ? _difficulty
                                : null,
                          ),
                        ),
                  icon: widget.loading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    widget.loading
                        ? 'Preparing...'
                        : _mode == QuizMode.practice
                        ? 'Start Practice'
                        : 'Start Mock Test',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MockSimulationPanel extends StatelessWidget {
  const _MockSimulationPanel({
    required this.track,
    required this.count,
    required this.loading,
    required this.onStart,
  });

  final ExamTrack track;
  final int count;
  final bool loading;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [track.accent.withValues(alpha: .96), AppColors.ink],
      ),
      borderColor: Colors.white.withValues(alpha: .12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusBadge(
                  icon: Icons.timer_rounded,
                  label: 'Mock Test Screen',
                  color: Colors.white,
                  onColor: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  '${track.code} simulation',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Countdown, mixed difficulty, prediction, and confirmation submit.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: .78),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: loading ? null : onStart,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: track.accent,
              minimumSize: const Size(92, 46),
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}
