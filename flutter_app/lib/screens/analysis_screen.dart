part of 'package:flutter_app/main.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({
    super.key,
    required this.allQuestions,
    required this.selectedTrack,
    required this.questionCounts,
  });

  final List<Question> allQuestions;
  final ExamTrack selectedTrack;
  final Map<String, int> questionCounts;

  @override
  Widget build(BuildContext context) {
    final topics = _topicsForTrack(selectedTrack, allQuestions);
    return PremiumScrollView(
      maxWidth: 900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Analytics', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            'Readiness, weak topics, consistency, and mock-test signals.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _ReadinessHero(
            score: (selectedTrack.readiness * 100).round(),
            track: selectedTrack,
            subtitle:
                '${_countForTrack(questionCounts, selectedTrack)} local questions',
          ),
          const SizedBox(height: 16),
          _AnalyticsChartCard(
            title: 'Accuracy trend',
            subtitle: 'Last six study sessions',
            color: selectedTrack.accent,
            values: const [52, 58, 62, 64, 70, 74],
          ),
          const SizedBox(height: 16),
          _ConsistencyCard(track: selectedTrack),
          const SizedBox(height: 16),
          SectionHeader(
            title: 'Weak topics',
            subtitle: 'Start here before your next timed session.',
          ),
          const SizedBox(height: 12),
          for (final topic in topics.take(4)) ...[
            _DomainMasteryRow(
              domain: topic.title,
              score: (topic.progress * 100).round(),
              color: topic.color,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({
    super.key,
    required this.result,
    required this.onRestart,
  });

  final QuizResult result;
  final VoidCallback onRestart;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String? _expandedCategory;

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final color = _scoreColor(result.score);
    final track = result.questions.isEmpty
        ? _examTracks.first
        : _trackForCode(result.questions.first.examType);
    return PremiumScrollView(
      maxWidth: 980,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReadinessHero(
            score: result.score,
            track: track,
            subtitle: _scoreMessage(result.score),
          ),
          const SizedBox(height: 16),
          Text(
            'Quiz Completed!',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.card),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _MetricCard(
                title: 'Score',
                value: '${result.score}%',
                color: color,
                icon: Icons.query_stats_rounded,
              ),
              _MetricCard(
                title: 'Correct',
                value: '${result.correctAnswers}/${result.totalQuestions}',
                color: AppColors.success,
                icon: Icons.task_alt_rounded,
              ),
              _MetricCard(
                title: 'Time',
                value: _formatDuration(result.timeSpent),
                color: AppColors.warning,
                icon: Icons.schedule_rounded,
              ),
              _MetricCard(
                title: 'Average',
                value: _formatDuration(
                  Duration(
                    milliseconds:
                        result.timeSpent.inMilliseconds ~/
                        math.max(1, result.totalQuestions),
                  ),
                ),
                color: AppColors.azure,
                icon: Icons.speed_rounded,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _AnalyticsChartCard(
            title: 'Mock performance',
            subtitle: 'Score compared with recent practice signals',
            color: color,
            values: [
              44,
              52,
              58,
              math.max(0, result.score - 12),
              math.max(0, result.score - 5),
              result.score,
            ],
          ),
          const SizedBox(height: 16),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionTitle(
                  icon: Icons.menu_book_rounded,
                  title: 'Detailed result summary',
                ),
                const SizedBox(height: 12),
                for (final entry in result.categoryBreakdown.entries)
                  _CategoryTile(
                    category: entry.key,
                    breakdown: entry.value,
                    expanded: _expandedCategory == entry.key,
                    wrongQuestions: _wrongQuestions(entry.key),
                    onToggle: () => setState(
                      () => _expandedCategory = _expandedCategory == entry.key
                          ? null
                          : entry.key,
                    ),
                    result: result,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Feedback(result: result),
          const SizedBox(height: AppSpacing.section),
          FilledButton.icon(
            onPressed: widget.onRestart,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Take Another Quiz'),
          ),
        ],
      ),
    );
  }

  List<Question> _wrongQuestions(String category) {
    return widget.result.questions.where((question) {
      return question.category == category &&
          !QuizEngine.checkAnswer(question, widget.result.answers[question.id]);
    }).toList();
  }
}

class _ReadinessHero extends StatelessWidget {
  const _ReadinessHero({
    required this.score,
    required this.track,
    required this.subtitle,
  });

  final int score;
  final ExamTrack track;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(score);
    return PremiumCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          track.accent.withValues(alpha: .14),
          track.gradientEnd.withValues(alpha: .08),
        ],
      ),
      child: Row(
        children: [
          ProgressRing(value: score / 100, label: '$score%', color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Readiness score',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusBadge(
                      icon: Icons.badge_rounded,
                      label: track.code,
                      color: track.accent,
                    ),
                    StatusBadge(
                      icon: Icons.workspace_premium_rounded,
                      label: score >= 80
                          ? 'Exam ready'
                          : score >= 60
                          ? 'Review mode'
                          : 'Foundation',
                      color: color,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsChartCard extends StatelessWidget {
  const _AnalyticsChartCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.values,
  });

  final String title;
  final String subtitle;
  final Color color;
  final List<num> values;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, subtitle: subtitle),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                maxY: 100,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                barGroups: [
                  for (var index = 0; index < values.length; index++)
                    BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: values[index].toDouble(),
                          color: color.withValues(alpha: .88),
                          width: 18,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 100,
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: .56),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsistencyCard extends StatelessWidget {
  const _ConsistencyCard({required this.track});

  final ExamTrack track;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Study consistency',
            subtitle: 'Seven-day activity map',
          ),
          const SizedBox(height: AppSpacing.card),
          Row(
            children: [
              for (final value in const [
                .48,
                .72,
                .32,
                .88,
                .66,
                .92,
                .74,
              ]) ...[
                Expanded(
                  child: AnimatedContainer(
                    duration: AppDurations.medium,
                    height: 82 * value,
                    decoration: BoxDecoration(
                      color: track.accent.withValues(alpha: .22 + (.5 * value)),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.card),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              StatusBadge(
                icon: Icons.local_fire_department_rounded,
                label: '7 day streak',
                color: AppColors.warning,
              ),
              StatusBadge(
                icon: Icons.bolt_rounded,
                label: '+320 XP week',
                color: AppColors.azure,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.breakdown,
    required this.expanded,
    required this.wrongQuestions,
    required this.onToggle,
    required this.result,
  });

  final String category;
  final ScoreBreakdown breakdown;
  final bool expanded;
  final List<Question> wrongQuestions;
  final VoidCallback onToggle;
  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    final percentage = ((breakdown.correct / breakdown.total) * 100).round();
    final color = _scoreColor(percentage);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: expanded,
          onExpansionChanged: (_) => onToggle(),
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: Text(
            category,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(
              value: breakdown.correct / breakdown.total,
              minHeight: 8,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              color: color,
            ),
          ),
          trailing: Text(
            '$percentage%',
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
          children: [
            if (wrongQuestions.isEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.task_alt_rounded,
                  color: AppColors.success,
                ),
                title: const Text('No misses in this domain'),
              )
            else
              for (final question in wrongQuestions)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(question.question),
                  subtitle: Text(
                    'Your answer: ${QuizEngine.fullAnswerText(question, result.answers[question.id])}\n'
                    'Correct: ${QuizEngine.correctAnswerText(question)}'
                    '${question.explanation.isEmpty ? '' : '\n${question.explanation}'}',
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _DomainMasteryRow extends StatelessWidget {
  const _DomainMasteryRow({
    required this.domain,
    required this.score,
    this.color,
  });

  final String domain;
  final int score;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final rowColor = color ?? _scoreColor(score);
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.card),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  domain,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: score / 100,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  color: rowColor,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            '$score%',
            style: TextStyle(color: rowColor, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.result});

  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    final strengths = result.categoryBreakdown.entries
        .where((entry) => entry.value.correct / entry.value.total >= .8)
        .map((entry) => entry.key)
        .toList();
    final improvements = result.categoryBreakdown.entries
        .where((entry) => entry.value.correct / entry.value.total < .7)
        .map((entry) => entry.key)
        .toList();
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.lightbulb_rounded,
            title: 'Personalized feedback',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (strengths.isEmpty)
                const StatusBadge(
                  icon: Icons.auto_stories_rounded,
                  label: 'Build strengths',
                  color: AppColors.azure,
                )
              else
                for (final item in strengths)
                  StatusBadge(
                    icon: Icons.task_alt_rounded,
                    label: item,
                    color: AppColors.success,
                  ),
              for (final item in improvements)
                StatusBadge(
                  icon: Icons.flag_rounded,
                  label: 'Review $item',
                  color: AppColors.warning,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.score >= 80
                ? 'Run one more timed mock test, then switch to light review.'
                : result.score >= 60
                ? 'Review the flagged domains and retake a 20-question mixed session.'
                : 'Return to fundamentals and use short topic drills before mock tests.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
