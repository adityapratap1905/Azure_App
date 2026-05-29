part of 'package:flutter_app/main.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({
    super.key,
    required this.selectedTrack,
    required this.questions,
    required this.questionCounts,
    required this.onSelectTrack,
    required this.onOpenPracticeStudio,
  });

  final ExamTrack selectedTrack;
  final List<Question> questions;
  final Map<String, int> questionCounts;
  final ValueChanged<ExamTrack> onSelectTrack;
  final ValueChanged<ExamTrack> onOpenPracticeStudio;

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  String _category = 'All Exams';
  String _filter = 'All';

  List<ExamTrack> get _visibleTracks {
    final tracks = _examTracks.where((track) {
      final categoryMatches =
          _category == 'All Exams' || track.category == _category;
      final filterMatches = switch (_filter) {
        'Ready' => track.available && _count(track) > 0,
        'Started' => track.progress > 0,
        'Beginner' => track.difficulty == 'Beginner',
        _ => true,
      };
      return categoryMatches && filterMatches;
    }).toList();
    return tracks.isEmpty ? _examTracks.toList() : tracks;
  }

  int _count(ExamTrack track) =>
      _displayQuestionCount(widget.questionCounts, track);

  void _openTrackLearning(ExamTrack track) {
    widget.onSelectTrack(track);
    if (!track.available || _countForTrack(widget.questionCounts, track) == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${track.code} learning content is coming soon.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showCertificationLearningSheet(
      context: context,
      track: track,
      questionCount: _displayQuestionCount(widget.questionCounts, track),
      onOpenPracticeStudio: widget.onOpenPracticeStudio,
    );
  }

  void _showSearch() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Search exams',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                for (final track in _examTracks)
                  ListTile(
                    leading: CertificationBadgeMark(track: track, size: 44),
                    title: Text(track.code),
                    subtitle: Text(track.name),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.pop(context);
                      _openTrackLearning(track);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = const [
      'All Exams',
      'Azure',
      'AI',
      'Security',
      'Fundamentals',
    ];
    final popularTracks = [
      _trackForCode('AZ-900'),
      _trackForCode('AI-900'),
      _trackForCode('DP-900'),
      _trackForCode('SC-900'),
    ];

    return PremiumScrollView(
      maxWidth: 430,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ExamHeader(onSearch: _showSearch),
          const SizedBox(height: AppSpacing.section),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                return _ExamCategoryChip(
                  label: category,
                  selected: _category == category,
                  icon: switch (category) {
                    'Azure' => Icons.cloud_queue_rounded,
                    'AI' => Icons.psychology_alt_rounded,
                    'Security' => Icons.verified_user_outlined,
                    'Fundamentals' => Icons.workspace_premium_outlined,
                    _ => Icons.grid_view_rounded,
                  },
                  color: switch (category) {
                    'AI' => AppColors.purple,
                    'Security' => AppColors.success,
                    'Fundamentals' => AppColors.warning,
                    _ => AppColors.azure,
                  },
                  onTap: () => setState(() => _category = category),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          SectionHeader(
            title: 'Popular Exams',
            actionLabel: 'View all',
            onAction: () => setState(() {
              _category = 'All Exams';
              _filter = 'All';
            }),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 214,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: popularTracks.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final track = popularTracks[index];
                return SizedBox(
                  width: 134,
                  child: _ExamShowcaseCard(
                    track: track,
                    questionCount: _count(track),
                    selected: widget.selectedTrack.code == track.code,
                    onTap: () => _openTrackLearning(track),
                    onStart: () => _openTrackLearning(track),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          _PathFinderCard(
            onStart: () {
              setState(() => _filter = 'Ready');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Path finder matched you with ready exams.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.section),
          Row(
            children: [
              Expanded(
                child: Text(
                  'All Exams',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Filter exams',
                initialValue: _filter,
                onSelected: (value) => setState(() => _filter = value),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'All', child: Text('All')),
                  PopupMenuItem(value: 'Ready', child: Text('Ready to start')),
                  PopupMenuItem(value: 'Started', child: Text('Started')),
                  PopupMenuItem(value: 'Beginner', child: Text('Beginner')),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _filter == 'All' ? 'Filter' : _filter,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.tune_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final track in _visibleTracks) ...[
            _ExamListTile(
              track: track,
              questionCount: _count(track),
              selected: widget.selectedTrack.code == track.code,
              onTap: () => _openTrackLearning(track),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ExamHeader extends StatelessWidget {
  const _ExamHeader({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Exams', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 3),
              Text(
                'Choose an exam and start your preparation',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: IconButton(
            tooltip: 'Search exams',
            onPressed: onSearch,
            icon: const Icon(Icons.search_rounded),
          ),
        ),
      ],
    );
  }
}

class _ExamCategoryChip extends StatelessWidget {
  const _ExamCategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: color.withValues(alpha: selected ? .0 : .18),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 15, color: selected ? Colors.white : color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  fontSize: 11,
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

class _ExamShowcaseCard extends StatelessWidget {
  const _ExamShowcaseCard({
    required this.track,
    required this.questionCount,
    required this.selected,
    required this.onTap,
    required this.onStart,
  });

  final ExamTrack track;
  final int questionCount;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = track.available && questionCount > 0;
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      borderColor: selected ? track.accent.withValues(alpha: .5) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Center(child: MiniCertificationBadge(track: track)),
              ),
              Icon(
                selected
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: selected ? track.accent : colorScheme.outline,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            track.code,
            style: TextStyle(
              color: track.accent,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Microsoft ${track.name}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const Spacer(),
          LinearProgressIndicator(
            value: track.progress == 0 ? .18 : track.progress,
            minHeight: 4,
            color: track.accent,
            backgroundColor: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.quiz_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '$questionCount Questions',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${(track.progress * 100).round()}%',
                style: TextStyle(
                  color: track.accent,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: FilledButton(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                backgroundColor: enabled
                    ? track.accent.withValues(alpha: .10)
                    : colorScheme.surfaceContainerHighest,
                foregroundColor: enabled
                    ? track.accent
                    : colorScheme.onSurfaceVariant,
                minimumSize: const Size(0, 32),
                textStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              child: Text(enabled ? 'Learn' : 'Notify'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PathFinderCard extends StatelessWidget {
  const _PathFinderCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PremiumCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.card,
        AppSpacing.card,
        AppSpacing.dense,
        AppSpacing.dense,
      ),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFEAF3FF), Color(0xFFDCEBFF)],
      ),
      borderColor: Colors.white,
      child: SizedBox(
        height: 126,
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: SizedBox(
                width: 148,
                child: Stack(
                  children: [
                    Positioned(
                      right: 14,
                      top: 3,
                      child: Icon(
                        Icons.description_rounded,
                        size: 92,
                        color: Colors.white.withValues(alpha: .88),
                      ),
                    ),
                    Positioned(
                      right: 68,
                      top: 18,
                      child: _FloatingLetter(letter: 'A', size: 34),
                    ),
                    const Positioned(
                      right: 7,
                      bottom: 10,
                      child: Icon(
                        Icons.school_rounded,
                        color: Color(0xFF163B7A),
                        size: 58,
                      ),
                    ),
                    Positioned(
                      right: 88,
                      bottom: 18,
                      child: _FloatingLetter(letter: 'A', size: 40),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              width: 210,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Not sure which exam is right for you?',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Answer a few questions and we'll recommend the best path for you.",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 13),
                  SizedBox(
                    height: 34,
                    child: FilledButton.icon(
                      onPressed: onStart,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 15),
                      label: const Text('Find My Path'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 34),
                        textStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingLetter extends StatelessWidget {
  const _FloatingLetter({required this.letter, required this.size});

  final String letter;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.azure,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.azure.withValues(alpha: .28),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * .48,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ExamListTile extends StatelessWidget {
  const _ExamListTile({
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
    final enabled = track.available && questionCount > 0;
    final progress = enabled ? track.progress : .0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.all(AppSpacing.dense),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: selected
                  ? track.accent.withValues(alpha: .46)
                  : colorScheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .035),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              CertificationBadgeMark(
                track: track,
                size: 54,
                disabled: !enabled,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          track.code,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        if (track.available) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: track.accent.withValues(alpha: .10),
                              borderRadius: BorderRadius.circular(
                                AppRadii.pill,
                              ),
                            ),
                            child: Text(
                              track.difficulty == 'Beginner'
                                  ? 'Associate'
                                  : 'Intermediate',
                              style: TextStyle(
                                color: track.accent,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Microsoft ${track.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '$questionCount Questions',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          enabled ? track.difficulty : 'Soon',
                          style: TextStyle(
                            color: enabled
                                ? AppColors.danger
                                : colorScheme.onSurfaceVariant,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ProgressRing(
                value: progress,
                label: '${(progress * 100).round()}%',
                color: enabled ? track.accent : colorScheme.outline,
                size: 46,
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: track.accent),
            ],
          ),
        ),
      ),
    );
  }
}
