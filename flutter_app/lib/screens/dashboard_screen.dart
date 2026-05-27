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
          _DashboardHeader(
            streakDays: 7,
            onSearch: () => _showSearch(context),
            onNotifications: () => _showNotifications(context),
          ),
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
              itemBuilder: (context, index) => _TopicMiniCard(
                topic: topics[index],
                onTap: () => _showCourseDetails(context, topics[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCourseDetails(BuildContext context, StudyTopic topic) {
    final docs = _documentationForTopic(topic.title);
    final syllabus = _syllabusForTopic(topic.title);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * .78,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: topic.color.withValues(alpha: .14),
                        foregroundColor: topic.color,
                        child: Icon(topic.icon),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topic.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Course details, syllabus, and documentation',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _CourseInfoPanel(topic: topic),
                  const SizedBox(height: 16),
                  SectionHeader(title: 'Syllabus topics'),
                  const SizedBox(height: 10),
                  for (var index = 0; index < syllabus.length; index++)
                    _SyllabusTile(
                      index: index + 1,
                      title: syllabus[index],
                      color: topic.color,
                    ),
                  const SizedBox(height: 16),
                  SectionHeader(title: 'Documentation'),
                  const SizedBox(height: 10),
                  for (final doc in docs)
                    _DocumentationTile(title: doc.$1, subtitle: doc.$2),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onStartPractice(selectedTrack);
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Practice this topic'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSearch(BuildContext context) {
    final parentContext = context;
    var query = '';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final normalizedQuery = query.trim().toLowerCase();
            final matchingTracks = _examTracks.where((track) {
              if (normalizedQuery.isEmpty) return true;
              return track.code.toLowerCase().contains(normalizedQuery) ||
                  track.name.toLowerCase().contains(normalizedQuery) ||
                  track.category.toLowerCase().contains(normalizedQuery);
            }).toList();
            final matchingTopics = _homeTopics(allQuestions).where((topic) {
              if (normalizedQuery.isEmpty) return true;
              return topic.title.toLowerCase().contains(normalizedQuery) ||
                  topic.subtitle.toLowerCase().contains(normalizedQuery);
            }).toList();
            final matchingQuestions = allQuestions
                .where((question) {
                  if (normalizedQuery.isEmpty) return false;
                  return question.question.toLowerCase().contains(
                        normalizedQuery,
                      ) ||
                      question.category.toLowerCase().contains(
                        normalizedQuery,
                      ) ||
                      question.examType.toLowerCase().contains(normalizedQuery);
                })
                .take(4)
                .toList();

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  18,
                  0,
                  18,
                  20 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * .76,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Search',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Search exams, topics, or questions',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                        onChanged: (value) =>
                            setModalState(() => query = value),
                      ),
                      const SizedBox(height: 14),
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            if (matchingTracks.isNotEmpty) ...[
                              const _SearchGroupLabel('Exams'),
                              for (final track in matchingTracks)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CertificationBadgeMark(
                                    track: track,
                                    size: 42,
                                  ),
                                  title: Text(track.code),
                                  subtitle: Text(track.name),
                                  trailing: const Icon(
                                    Icons.chevron_right_rounded,
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    onSelectTrack(track);
                                    onStartPractice(track);
                                  },
                                ),
                            ],
                            if (matchingTopics.isNotEmpty) ...[
                              const _SearchGroupLabel('Topics'),
                              for (final topic in matchingTopics)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: topic.color.withValues(
                                      alpha: .14,
                                    ),
                                    foregroundColor: topic.color,
                                    child: Icon(topic.icon, size: 20),
                                  ),
                                  title: Text(topic.title),
                                  subtitle: Text(topic.subtitle),
                                  trailing: const Icon(
                                    Icons.play_arrow_rounded,
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showCourseDetails(parentContext, topic);
                                  },
                                ),
                            ],
                            if (matchingQuestions.isNotEmpty) ...[
                              const _SearchGroupLabel('Questions'),
                              for (final question in matchingQuestions)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    Icons.quiz_outlined,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  title: Text(
                                    question.question,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${question.examType} - ${question.category}',
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    final track = _trackForCode(
                                      question.examType,
                                    );
                                    onSelectTrack(track);
                                    onStartPractice(track);
                                  },
                                ),
                            ],
                            if (matchingTracks.isEmpty &&
                                matchingTopics.isEmpty &&
                                matchingQuestions.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 28,
                                ),
                                child: Text(
                                  'No matching exams, topics, or questions.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showNotifications(BuildContext context) {
    final track = selectedTrack;
    final count = _countForTrack(questionCounts, track);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                _NotificationTile(
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.warning,
                  title: '7 day learning streak',
                  subtitle:
                      'Keep the streak alive with one short practice set.',
                ),
                _NotificationTile(
                  icon: Icons.workspace_premium_rounded,
                  color: track.accent,
                  title: '${track.code} practice is ready',
                  subtitle: count > 0
                      ? '$count questions are available for ${track.name}.'
                      : '${track.name} question bank is coming soon.',
                ),
                _NotificationTile(
                  icon: Icons.insights_rounded,
                  color: AppColors.success,
                  title: 'Progress review',
                  subtitle: lastResult == null
                      ? 'Complete a quiz to unlock your score breakdown.'
                      : 'Your latest score was ${lastResult!.score}%.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.streakDays,
    required this.onSearch,
    required this.onNotifications,
  });

  final int streakDays;
  final VoidCallback onSearch;
  final VoidCallback onNotifications;

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
                  Text.rich(
                    TextSpan(
                      text: 'Hello, ',
                      children: [
                        TextSpan(
                          text: 'Alex',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
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
            Tooltip(
              message: '$streakDays day learning streak',
              child: Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 9),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: .32),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 16,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$streakDays',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: onNotifications,
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
            onTap: onSearch,
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

class _SearchGroupLabel extends StatelessWidget {
  const _SearchGroupLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: .14),
        foregroundColor: color,
        child: Icon(icon, size: 21),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

class _CourseInfoPanel extends StatelessWidget {
  const _CourseInfoPanel({required this.topic});

  final StudyTopic topic;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.card),
      borderColor: topic.color.withValues(alpha: .28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning path',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            _courseSummaryForTopic(topic.title),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge(
                icon: Icons.menu_book_rounded,
                label: '${_topicDisplayCount(topic.title)} questions',
                color: topic.color,
              ),
              StatusBadge(
                icon: Icons.speed_rounded,
                label: topic.difficulty.name,
                color: AppColors.warning,
              ),
              StatusBadge(
                icon: Icons.timeline_rounded,
                label: '${(topic.progress * 100).round()}% complete',
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SyllabusTile extends StatelessWidget {
  const _SyllabusTile({
    required this.index,
    required this.title,
    required this.color,
  });

  final int index;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.dense),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: color.withValues(alpha: .20)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color,
              foregroundColor: Colors.white,
              child: Text(
                '$index',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentationTile extends StatelessWidget {
  const _DocumentationTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.article_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.open_in_new_rounded, size: 18),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.lg),
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
                child: _HeroDots(
                  count: _slides.length,
                  selected: _selectedSlide,
                ),
              ),
            ],
          ),
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
    final heroStyle = _heroStyleForTrack(track);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: heroStyle.colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -16,
            child: _HeroBackgroundMark(style: heroStyle),
          ),
          Positioned(
            right: 86,
            top: 18,
            child: Icon(
              heroStyle.icon,
              color: Colors.white.withValues(alpha: .20),
              size: 52,
            ),
          ),
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

class _HeroVisualStyle {
  const _HeroVisualStyle({
    required this.colors,
    required this.icon,
    required this.shapes,
  });

  final List<Color> colors;
  final IconData icon;
  final List<(double, double, double, double)> shapes;
}

_HeroVisualStyle _heroStyleForTrack(ExamTrack track) {
  return switch (track.category) {
    'AI' => const _HeroVisualStyle(
      colors: [Color(0xFF6D3DFF), Color(0xFF00A6D6)],
      icon: Icons.psychology_alt_rounded,
      shapes: [
        (4, 30, 34, 1),
        (46, 8, 48, .74),
        (92, 30, 62, .92),
        (138, 14, 34, .68),
      ],
    ),
    'Data' => const _HeroVisualStyle(
      colors: [Color(0xFF2148C0), Color(0xFF00A88E)],
      icon: Icons.storage_rounded,
      shapes: [
        (8, 12, 34, .9),
        (48, 12, 34, .65),
        (88, 12, 34, .8),
        (128, 12, 34, .55),
        (28, 52, 34, .72),
        (68, 52, 34, .92),
        (108, 52, 34, .68),
      ],
    ),
    'Security' => const _HeroVisualStyle(
      colors: [Color(0xFF8A2C0A), Color(0xFFFFB020)],
      icon: Icons.security_rounded,
      shapes: [(10, 22, 58, .75), (70, 4, 74, .42), (122, 28, 50, .6)],
    ),
    _ => const _HeroVisualStyle(
      colors: [Color(0xFF0078D4), Color(0xFF00BCF2)],
      icon: Icons.cloud_rounded,
      shapes: [
        (8, 30, 42, 1),
        (44, 8, 56, .9),
        (92, 28, 66, .78),
        (126, 14, 44, .86),
      ],
    ),
  };
}

class _HeroBackgroundMark extends StatelessWidget {
  const _HeroBackgroundMark({required this.style});

  final _HeroVisualStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      width: 178,
      child: Stack(
        children: [
          for (final shape in style.shapes)
            Positioned(
              left: shape.$1,
              top: shape.$2,
              child: Container(
                height: shape.$3,
                width: shape.$3 * 1.45,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .10 + (.12 * shape.$4)),
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
  const _TopicMiniCard({required this.topic, required this.onTap});

  final StudyTopic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final count = _topicDisplayCount(topic.title);
    return SizedBox(
      width: 86,
      child: PremiumCard(
        onTap: onTap,
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

String _courseSummaryForTopic(String title) {
  return switch (title) {
    'Cloud Concepts' =>
      'Understand service models, shared responsibility, core Azure services, and how cloud architecture decisions affect cost and reliability.',
    'AI Fundamentals' =>
      'Learn core AI workloads, machine learning basics, computer vision, NLP, and responsible AI principles before attempting practice questions.',
    'Security' =>
      'Build a foundation in identity, access, threat protection, governance, and compliance concepts used across cloud certification exams.',
    'Pricing & Support' =>
      'Review cost planning, subscriptions, service-level agreements, support plans, and governance tools used to control cloud spend.',
    _ =>
      'Study the concepts, review the syllabus, and use the documentation list before starting a focused practice session.',
  };
}

List<String> _syllabusForTopic(String title) {
  return switch (title) {
    'Cloud Concepts' => const [
      'Cloud benefits, consumption models, and shared responsibility',
      'IaaS, PaaS, SaaS, and serverless service patterns',
      'Regions, availability zones, resilience, and disaster recovery',
      'Core compute, networking, storage, and database services',
    ],
    'AI Fundamentals' => const [
      'Machine learning workloads and model lifecycle basics',
      'Computer vision, OCR, and image analysis concepts',
      'Natural language processing and conversational AI',
      'Responsible AI principles, fairness, privacy, and transparency',
    ],
    'Security' => const [
      'Identity, authentication, authorization, and access control',
      'Zero Trust, defense in depth, and threat protection',
      'Governance, compliance, policy, and secure posture management',
      'Monitoring, alerts, and security operations workflows',
    ],
    'Pricing & Support' => const [
      'Subscriptions, resource groups, tags, and cost organization',
      'Pricing calculators, total cost of ownership, and budgets',
      'Service-level agreements, lifecycle, and preview services',
      'Support plans, service health, and advisory recommendations',
    ],
    _ => const [
      'Core concepts and exam vocabulary',
      'Common service capabilities and usage scenarios',
      'Practice examples with explanations',
      'Review checklist and documentation reading',
    ],
  };
}

List<(String, String)> _documentationForTopic(String title) {
  return switch (title) {
    'Cloud Concepts' => const [
      (
        'Microsoft Learn: Cloud concepts',
        'Cloud benefits, models, and service categories',
      ),
      (
        'Azure architecture center',
        'Reliability, regions, and design guidance',
      ),
      (
        'Azure services overview',
        'Compute, networking, storage, and databases',
      ),
    ],
    'AI Fundamentals' => const [
      (
        'Microsoft Learn: AI fundamentals',
        'AI workloads and responsible AI concepts',
      ),
      (
        'Azure AI services documentation',
        'Vision, language, speech, and search services',
      ),
      (
        'Machine learning overview',
        'Model training, evaluation, and deployment basics',
      ),
    ],
    'Security' => const [
      (
        'Microsoft Learn: Security fundamentals',
        'Identity, compliance, and security concepts',
      ),
      (
        'Microsoft Entra documentation',
        'Identity and access management guidance',
      ),
      (
        'Microsoft Defender for Cloud',
        'Cloud security posture and threat protection',
      ),
    ],
    'Pricing & Support' => const [
      (
        'Azure pricing documentation',
        'Pricing, calculators, and cost planning',
      ),
      ('Azure support plans', 'Support scope and response expectations'),
      (
        'Azure Service Health',
        'Incidents, advisories, and planned maintenance',
      ),
    ],
    _ => const [
      (
        'Microsoft Learn module',
        'Study the official learning module for this topic',
      ),
      ('Product documentation', 'Review service capabilities and limits'),
      ('Exam skills outline', 'Map the topic back to certification objectives'),
    ],
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
          _PracticeSetupHero(
            track: _selectedTrack,
            count: count,
            examType: _examType,
            mode: _mode,
            difficulty: _difficulty,
            difficultyLabel: _difficultyLabel,
            questionCount: _questionCount,
            loading: widget.loading,
            onExamChanged: (value) => setState(() => _examType = value),
            onModeChanged: (value) => setState(() => _mode = value),
            onDifficultyChanged: (value) => setState(() => _difficulty = value),
            onQuestionCountChanged: (value) =>
                setState(() => _questionCount = value),
            onStart: canStart
                ? () => widget.onStart(
                    QuizConfig(
                      mode: _mode,
                      examType: _examType,
                      questionCount: math.min(_questionCount, count),
                      difficulty: _mode == QuizMode.practice
                          ? _difficulty
                          : null,
                    ),
                  )
                : null,
          ),
          if (widget.error != null) ...[
            const SizedBox(height: AppSpacing.card),
            _PracticeErrorMessage(message: widget.error!),
          ],
        ],
      ),
    );
  }
}

class _PracticeSetupHero extends StatelessWidget {
  const _PracticeSetupHero({
    required this.track,
    required this.count,
    required this.examType,
    required this.mode,
    required this.difficulty,
    required this.difficultyLabel,
    required this.questionCount,
    required this.loading,
    required this.onExamChanged,
    required this.onModeChanged,
    required this.onDifficultyChanged,
    required this.onQuestionCountChanged,
    required this.onStart,
  });

  final ExamTrack track;
  final int count;
  final String examType;
  final QuizMode mode;
  final Difficulty difficulty;
  final String difficultyLabel;
  final int questionCount;
  final bool loading;
  final ValueChanged<String> onExamChanged;
  final ValueChanged<QuizMode> onModeChanged;
  final ValueChanged<Difficulty> onDifficultyChanged;
  final ValueChanged<int> onQuestionCountChanged;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveCount = count == 0 ? 0 : math.min(questionCount, count);
    return PremiumCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [track.accent.withValues(alpha: .96), track.gradientEnd],
      ),
      borderColor: Colors.white.withValues(alpha: .16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CertificationBadgeMark(track: track, size: 62),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${track.code} Practice Plan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      track.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: .82),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _HeroSetupControls(
            examType: examType,
            mode: mode,
            difficulty: difficulty,
            questionCount: questionCount,
            onExamChanged: onExamChanged,
            onModeChanged: onModeChanged,
            onDifficultyChanged: onDifficultyChanged,
            onQuestionCountChanged: onQuestionCountChanged,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  count == 0
                      ? 'Questions for this track are not available yet.'
                      : '$effectiveCount questions - $difficultyLabel - explanations included.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: .82),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: loading ? null : onStart,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: track.accent,
                ),
                icon: loading
                    ? SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      )
                    : const Icon(Icons.play_arrow_rounded),
                label: Text(
                  loading
                      ? 'Preparing'
                      : mode == QuizMode.practice
                      ? 'Start Practice'
                      : 'Start Mock Test',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PracticeErrorMessage extends StatelessWidget {
  const _PracticeErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.dense),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSetupControls extends StatelessWidget {
  const _HeroSetupControls({
    required this.examType,
    required this.mode,
    required this.difficulty,
    required this.questionCount,
    required this.onExamChanged,
    required this.onModeChanged,
    required this.onDifficultyChanged,
    required this.onQuestionCountChanged,
  });

  final String examType;
  final QuizMode mode;
  final Difficulty difficulty;
  final int questionCount;
  final ValueChanged<String> onExamChanged;
  final ValueChanged<QuizMode> onModeChanged;
  final ValueChanged<Difficulty> onDifficultyChanged;
  final ValueChanged<int> onQuestionCountChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _GlassDropdown<String>(
                value: examType,
                items: [
                  for (final track in _availableExamTracks)
                    DropdownMenuItem(
                      value: track.code,
                      child: Text(track.code, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) onExamChanged(value);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _GlassDropdown<int>(
                value: questionCount,
                items: const [
                  DropdownMenuItem(value: 5, child: Text('5 Questions')),
                  DropdownMenuItem(value: 10, child: Text('10 Questions')),
                  DropdownMenuItem(value: 20, child: Text('20 Questions')),
                  DropdownMenuItem(value: 50, child: Text('50 Questions')),
                ],
                onChanged: (value) {
                  if (value != null) onQuestionCountChanged(value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _GlassToggleButton(
                selected: mode == QuizMode.practice,
                icon: Icons.track_changes_rounded,
                label: 'Practice Mode',
                onTap: () => onModeChanged(QuizMode.practice),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _GlassToggleButton(
                selected: mode == QuizMode.examination,
                icon: Icons.workspace_premium_rounded,
                label: 'Examination Mode',
                onTap: () => onModeChanged(QuizMode.examination),
              ),
            ),
            if (mode == QuizMode.practice) ...[
              const SizedBox(width: 8),
              Expanded(
                child: _GlassDropdown<Difficulty>(
                  value: difficulty,
                  items: const [
                    DropdownMenuItem(
                      value: Difficulty.easy,
                      child: Text('Easy'),
                    ),
                    DropdownMenuItem(
                      value: Difficulty.medium,
                      child: Text('Medium'),
                    ),
                    DropdownMenuItem(
                      value: Difficulty.hard,
                      child: Text('Hard'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) onDifficultyChanged(value);
                  },
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _GlassDropdown<T> extends StatelessWidget {
  const _GlassDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      iconEnabledColor: Colors.white,
      dropdownColor: const Color(0xFF102D8F),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white.withValues(alpha: .13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .38)),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}

class _GlassToggleButton extends StatelessWidget {
  const _GlassToggleButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: selected ? .24 : .11),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: Colors.white.withValues(alpha: selected ? .42 : .16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 17),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
