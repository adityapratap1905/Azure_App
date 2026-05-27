part of 'package:flutter_app/main.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.config,
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.answer,
    required this.startedAt,
    required this.onAnswer,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
    required this.onExit,
  });

  final QuizConfig config;
  final Question question;
  final int questionIndex;
  final int totalQuestions;
  final dynamic answer;
  final DateTime startedAt;
  final ValueChanged<dynamic> onAnswer;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;
  final VoidCallback onExit;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Set<String> _bookmarkedIds = {};
  late final Stream<int> _timer = Stream.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now().difference(widget.startedAt).inSeconds,
  );

  bool get _isLastQuestion => widget.questionIndex + 1 == widget.totalQuestions;
  bool get _isExamMode => widget.config.mode == QuizMode.examination;

  @override
  Widget build(BuildContext context) {
    final answered = QuizEngine.isAnswered(widget.question, widget.answer);
    final progress = (widget.questionIndex + 1) / widget.totalQuestions;
    final track = _trackForCode(widget.question.examType);
    final bookmarked = _bookmarkedIds.contains(widget.question.id);
    return PremiumScrollView(
      maxWidth: 900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PracticeTopBar(
            track: track,
            mode: widget.config.mode,
            difficulty: widget.question.difficulty,
            bookmarked: bookmarked,
            onExit: _showExitConfirmation,
            onBookmark: () {
              setState(() {
                bookmarked
                    ? _bookmarkedIds.remove(widget.question.id)
                    : _bookmarkedIds.add(widget.question.id);
              });
            },
            timer: StreamBuilder<int>(
              stream: _timer,
              initialData: DateTime.now()
                  .difference(widget.startedAt)
                  .inSeconds,
              builder: (context, snapshot) {
                final elapsed = snapshot.data ?? 0;
                return _TimerBadge(
                  label: _timerLabel(elapsed),
                  urgent: _isExamMode && _remainingSeconds(elapsed) < 300,
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.card),
          _QuestionProgress(
            current: widget.questionIndex + 1,
            total: widget.totalQuestions,
            progress: progress,
            color: track.accent,
          ),
          const SizedBox(height: 16),
          PremiumCard(
            padding: const EdgeInsets.all(AppSpacing.card),
            child: QuestionRenderer(
              question: widget.question,
              answer: widget.answer,
              onAnswer: widget.onAnswer,
            ),
          ),
          const SizedBox(height: AppSpacing.card),
          _ExplanationPanel(question: widget.question, unlocked: answered),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.questionIndex == 0
                      ? null
                      : widget.onPrevious,
                  icon: const Icon(Icons.chevron_left_rounded),
                  label: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                tooltip: 'Skip question',
                onPressed: _isLastQuestion ? null : widget.onSkip,
                icon: const Icon(Icons.skip_next_rounded),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: answered ? _handlePrimaryAction : null,
                  icon: Icon(
                    _isLastQuestion
                        ? Icons.flag_rounded
                        : Icons.chevron_right_rounded,
                  ),
                  label: Text(
                    _isLastQuestion
                        ? _isExamMode
                              ? 'Submit'
                              : 'Finish'
                        : 'Next',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showExitConfirmation() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exit this quiz?'),
          content: const Text(
            'Your current answers in this session will be discarded.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Stay'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
    if (shouldExit == true && mounted) widget.onExit();
  }

  void _handlePrimaryAction() {
    if (_isLastQuestion && _isExamMode) {
      _showSubmitConfirmation();
      return;
    }
    widget.onNext();
  }

  Future<void> _showSubmitConfirmation() async {
    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Submit mock test?'),
          content: const Text(
            'Your answers will be scored and converted into a readiness summary.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Review'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
    if (shouldSubmit == true && mounted) widget.onNext();
  }

  int _remainingSeconds(int elapsed) {
    final examSeconds = math.max(15 * 60, widget.totalQuestions * 90);
    return math.max(0, examSeconds - elapsed);
  }

  String _timerLabel(int elapsed) {
    if (!_isExamMode) return _formatSeconds(elapsed);
    return _formatSeconds(_remainingSeconds(elapsed));
  }
}

class _PracticeTopBar extends StatelessWidget {
  const _PracticeTopBar({
    required this.track,
    required this.mode,
    required this.difficulty,
    required this.bookmarked,
    required this.onExit,
    required this.onBookmark,
    required this.timer,
  });

  final ExamTrack track;
  final QuizMode mode;
  final String difficulty;
  final bool bookmarked;
  final VoidCallback onExit;
  final VoidCallback onBookmark;
  final Widget timer;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ExamBadge(track: track, size: 48),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mode == QuizMode.practice ? 'Practice session' : 'Mock test',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                '${track.code} - ${difficulty.toUpperCase()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        timer,
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: 'Exit quiz',
          onPressed: onExit,
          icon: const Icon(Icons.close_rounded),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark question',
          onPressed: onBookmark,
          icon: Icon(
            bookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_outline_rounded,
          ),
        ),
      ],
    );
  }
}

class _TimerBadge extends StatelessWidget {
  const _TimerBadge({required this.label, required this.urgent});

  final String label;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      icon: Icons.schedule_rounded,
      label: label,
      color: urgent ? AppColors.danger : AppColors.azure,
    );
  }
}

class _QuestionProgress extends StatelessWidget {
  const _QuestionProgress({
    required this.current,
    required this.total,
    required this.progress,
    required this.color,
  });

  final int current;
  final int total;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.card),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Question $current of $total',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            color: color,
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }
}

class _ExplanationPanel extends StatelessWidget {
  const _ExplanationPanel({required this.question, required this.unlocked});

  final Question question;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.card),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            unlocked ? Icons.lightbulb_rounded : Icons.lock_outline_rounded,
            color: unlocked ? AppColors.warning : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explanation',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  unlocked
                      ? question.explanation.isEmpty
                            ? 'Review the concept behind this answer before moving on.'
                            : question.explanation
                      : 'Choose an answer to unlock the explanation.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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

class QuestionRenderer extends StatelessWidget {
  const QuestionRenderer({
    super.key,
    required this.question,
    required this.answer,
    required this.onAnswer,
  });

  final Question question;
  final dynamic answer;
  final ValueChanged<dynamic> onAnswer;

  @override
  Widget build(BuildContext context) {
    return switch (question.type) {
      QuestionType.mcq => McqQuestion(
        question: question,
        answer: answer as String?,
        onAnswer: onAnswer,
      ),
      QuestionType.dragDrop => OrderingQuestion(
        question: question,
        answer: answer is List ? List<String?>.from(answer as List) : const [],
        onAnswer: onAnswer,
      ),
      QuestionType.trueFalseTable => TrueFalseQuestion(
        question: question,
        answer: Map<String, dynamic>.from(
          answer is Map ? answer as Map : const {},
        ),
        onAnswer: onAnswer,
      ),
      QuestionType.dropdownFill => DropdownFillQuestion(
        question: question,
        answer: Map<String, dynamic>.from(
          answer is Map ? answer as Map : const {},
        ),
        onAnswer: onAnswer,
      ),
      QuestionType.dragDropMatching ||
      QuestionType.matching => MatchingQuestion(
        question: question,
        answer: Map<String, dynamic>.from(
          answer is Map ? answer as Map : const {},
        ),
        onAnswer: onAnswer,
      ),
    };
  }
}

class McqQuestion extends StatelessWidget {
  const McqQuestion({
    super.key,
    required this.question,
    required this.answer,
    required this.onAnswer,
  });

  final Question question;
  final String? answer;
  final ValueChanged<dynamic> onAnswer;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _QuestionTitle(question.question),
        for (var index = 0; index < question.options.length; index++)
          _AnswerOptionTile(
            index: index,
            label: question.options[index],
            selected: answer == question.options[index],
            onTap: () => onAnswer(question.options[index]),
            selectedColor: colorScheme.primary,
          ),
      ],
    );
  }
}

class _AnswerOptionTile extends StatelessWidget {
  const _AnswerOptionTile({
    required this.index,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
  });

  final int index;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final letter = String.fromCharCode('A'.codeUnitAt(0) + index);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: onTap,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? selectedColor.withValues(alpha: .10)
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: selected ? selectedColor : colorScheme.outlineVariant,
                width: selected ? 1.8 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? selectedColor
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Text(
                    letter,
                    style: TextStyle(
                      color: selected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: selected ? 1 : 0,
                  duration: AppDurations.fast,
                  child: Icon(Icons.check_circle_rounded, color: selectedColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OrderingQuestion extends StatelessWidget {
  const OrderingQuestion({
    super.key,
    required this.question,
    required this.answer,
    required this.onAnswer,
  });

  final Question question;
  final List<String?> answer;
  final ValueChanged<dynamic> onAnswer;

  @override
  Widget build(BuildContext context) {
    final placed = answer.whereType<String>().toList();
    final available = question.options
        .where((item) => !placed.contains(item))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _QuestionTitle(question.question),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: available
              .map(
                (item) => ActionChip(
                  avatar: const Icon(Icons.add_rounded, size: 18),
                  label: Text(item),
                  onPressed: () => onAnswer([...placed, item]),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        if (placed.isEmpty)
          const _EmptyDropMessage()
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: placed.length,
            onReorder: (oldIndex, newIndex) {
              final next = [...placed];
              if (newIndex > oldIndex) newIndex--;
              final item = next.removeAt(oldIndex);
              next.insert(newIndex, item);
              onAnswer(next);
            },
            itemBuilder: (context, index) {
              return Padding(
                key: ValueKey('${placed[index]}-$index'),
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  tileColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: .42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(placed[index]),
                  trailing: IconButton(
                    tooltip: 'Remove item',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      final next = [...placed]..removeAt(index);
                      onAnswer(next);
                    },
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class TrueFalseQuestion extends StatelessWidget {
  const TrueFalseQuestion({
    super.key,
    required this.question,
    required this.answer,
    required this.onAnswer,
  });

  final Question question;
  final Map<String, dynamic> answer;
  final ValueChanged<dynamic> onAnswer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _QuestionTitle(question.question),
        for (var i = 0; i < question.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PremiumCard(
              padding: const EdgeInsets.all(AppSpacing.dense),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${i + 1}. ${question.options[i]}'),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, label: Text('True')),
                        ButtonSegment(value: false, label: Text('False')),
                      ],
                      selected: answer[i.toString()] is bool
                          ? {answer[i.toString()] as bool}
                          : const {},
                      emptySelectionAllowed: true,
                      onSelectionChanged: (selection) {
                        if (selection.isNotEmpty) {
                          onAnswer({...answer, i.toString(): selection.first});
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class DropdownFillQuestion extends StatelessWidget {
  const DropdownFillQuestion({
    super.key,
    required this.question,
    required this.answer,
    required this.onAnswer,
  });

  final Question question;
  final Map<String, dynamic> answer;
  final ValueChanged<dynamic> onAnswer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _QuestionTitle(
          question.question.replaceAll(RegExp(r'\[BLANK_\d+\]'), '____'),
        ),
        for (final blank in question.blanks)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DropdownButtonFormField<String>(
              initialValue: (answer[blank.id] as String?)?.isEmpty ?? true
                  ? null
                  : answer[blank.id] as String?,
              decoration: InputDecoration(labelText: blank.id),
              items: blank.options
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
              onChanged: (value) =>
                  onAnswer({...answer, blank.id: value ?? ''}),
            ),
          ),
      ],
    );
  }
}

class MatchingQuestion extends StatefulWidget {
  const MatchingQuestion({
    super.key,
    required this.question,
    required this.answer,
    required this.onAnswer,
  });

  final Question question;
  final Map<String, dynamic> answer;
  final ValueChanged<dynamic> onAnswer;

  @override
  State<MatchingQuestion> createState() => _MatchingQuestionState();
}

class _MatchingQuestionState extends State<MatchingQuestion> {
  String? _selectedLeft;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final left = widget.question.matchingPairs.left;
    final right = widget.question.matchingPairs.right;
    final matchedRight = widget.answer.values.toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _QuestionTitle(widget.question.question),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 390,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Items', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  for (final item in left)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: OutlinedButton(
                        onPressed: () {
                          if (widget.answer[item] != null) {
                            final next = Map<String, dynamic>.from(
                              widget.answer,
                            )..remove(item);
                            widget.onAnswer(next);
                          } else {
                            setState(
                              () => _selectedLeft = _selectedLeft == item
                                  ? null
                                  : item,
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: widget.answer[item] != null
                              ? AppColors.success.withValues(alpha: .10)
                              : _selectedLeft == item
                              ? colorScheme.primaryContainer.withValues(
                                  alpha: .35,
                                )
                              : null,
                          side: BorderSide(
                            color: widget.answer[item] != null
                                ? AppColors.success
                                : _selectedLeft == item
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.answer[item] == null
                                ? item
                                : '$item -> ${widget.answer[item]}',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: 390,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Matches',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  for (final item in right)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: OutlinedButton(
                        onPressed:
                            _selectedLeft == null || matchedRight.contains(item)
                            ? null
                            : () {
                                final next =
                                    Map<String, dynamic>.from(widget.answer)
                                      ..removeWhere((_, value) => value == item)
                                      ..[_selectedLeft!] = item;
                                widget.onAnswer(next);
                                setState(() => _selectedLeft = null);
                              },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            matchedRight.contains(item)
                                ? '$item (matched)'
                                : item,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
