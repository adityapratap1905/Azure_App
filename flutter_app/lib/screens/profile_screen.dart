part of 'package:flutter_app/main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.selectedTrack,
    required this.questionCounts,
    required this.lastResult,
    required this.themeController,
    required this.onSelectTrack,
  });

  final ExamTrack selectedTrack;
  final Map<String, int> questionCounts;
  final QuizResult? lastResult;
  final ThemeController themeController;
  final ValueChanged<ExamTrack> onSelectTrack;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _profileImageKey = 'profile_image_base64';

  Uint8List? _profileImageBytes;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedImage = preferences.getString(_profileImageKey);
    if (encodedImage == null || encodedImage.isEmpty || !mounted) return;
    setState(() => _profileImageBytes = base64Decode(encodedImage));
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 900,
      );
      if (pickedImage == null) return;
      final bytes = await pickedImage.readAsBytes();
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_profileImageKey, base64Encode(bytes));
      if (!mounted) return;
      setState(() => _profileImageBytes = bytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo upload is not available right now.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: const Text('Upload from gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickProfileImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_rounded),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickProfileImage(ImageSource.camera);
                  },
                ),
                if (_profileImageBytes != null)
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded),
                    title: const Text('Remove current photo'),
                    onTap: () async {
                      Navigator.pop(context);
                      final preferences = await SharedPreferences.getInstance();
                      await preferences.remove(_profileImageKey);
                      if (!mounted) return;
                      setState(() => _profileImageBytes = null);
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
    return PremiumScrollView(
      maxWidth: 430,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 124),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileTopBar(themeController: widget.themeController),
          const SizedBox(height: 22),
          _ProfileSummaryCard(
            selectedTrack: widget.selectedTrack,
            lastResult: widget.lastResult,
            profileImageBytes: _profileImageBytes,
            onUploadPhoto: _showPhotoOptions,
          ),
          const SizedBox(height: 22),
          _MetricStrip(lastResult: widget.lastResult),
          const SizedBox(height: 30),
          SectionHeader(
            title: 'My Certifications',
            subtitle: 'Studying',
            actionLabel: 'View all',
            onAction: () {},
          ),
          const SizedBox(height: 12),
          _CertificationShelf(
            selectedTrack: widget.selectedTrack,
            questionCounts: widget.questionCounts,
            onSelectTrack: widget.onSelectTrack,
          ),
          const SizedBox(height: 30),
          SectionHeader(
            title: 'Achievements',
            actionLabel: 'View all',
            onAction: () {},
          ),
          const SizedBox(height: 12),
          const _AchievementShelf(),
          const SizedBox(height: 30),
          SectionHeader(
            title: 'Study Insights',
            actionLabel: 'View all',
            onAction: () {},
          ),
          const SizedBox(height: 12),
          _InsightShelf(lastResult: widget.lastResult),
          const SizedBox(height: 30),
          Text('More', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          _MoreList(themeController: widget.themeController),
        ],
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Track your progress and achievements',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        _TopActionButton(
          icon: themeController.isDark
              ? Icons.light_mode_rounded
              : Icons.dark_mode_rounded,
          tooltip: 'Theme',
          onTap: themeController.toggle,
        ),
        const SizedBox(width: 10),
        _TopActionButton(
          icon: Icons.settings_outlined,
          tooltip: 'Settings',
          onTap: () {},
        ),
      ],
    );
  }
}

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          onTap: onTap,
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(color: colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .05),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
        ),
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.selectedTrack,
    required this.lastResult,
    required this.profileImageBytes,
    required this.onUploadPhoto,
  });

  final ExamTrack selectedTrack;
  final QuizResult? lastResult;
  final Uint8List? profileImageBytes;
  final VoidCallback onUploadPhoto;

  @override
  Widget build(BuildContext context) {
    final score = lastResult?.score ?? (selectedTrack.readiness * 100).round();
    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 390;
          final levelCard = _LevelCard(
            score: score,
            color: selectedTrack.accent,
          );
          final profile = _ProfileIdentity(
            track: selectedTrack,
            profileImageBytes: profileImageBytes,
            onUploadPhoto: onUploadPhoto,
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [profile, const SizedBox(height: 18), levelCard],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [profile, const SizedBox(height: 18), levelCard],
          );
        },
      ),
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({
    required this.track,
    required this.profileImageBytes,
    required this.onUploadPhoto,
  });

  final ExamTrack track;
  final Uint8List? profileImageBytes;
  final VoidCallback onUploadPhoto;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        _ProfilePhotoButton(
          accent: track.accent,
          imageBytes: profileImageBytes,
          onTap: onUploadPhoto,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      'Alex Johnson',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.verified_rounded,
                    color: AppColors.azure,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Cloud & AI Enthusiast',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.mail_outline_rounded,
                    size: 15,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'alex.johnson@email.com',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfilePhotoButton extends StatelessWidget {
  const _ProfilePhotoButton({
    required this.accent,
    required this.imageBytes,
    required this.onTap,
  });

  final Color accent;
  final Uint8List? imageBytes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Upload profile picture',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 82,
                width: 82,
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: imageBytes == null
                    ? CircleAvatar(
                        radius: 30,
                        backgroundColor: accent.withValues(alpha: .16),
                        child: Icon(
                          Icons.person_rounded,
                          color: accent,
                          size: 42,
                        ),
                      )
                    : Image.memory(
                        imageBytes!,
                        fit: BoxFit.cover,
                        height: 82,
                        width: 82,
                      ),
              ),
              Positioned(
                right: -5,
                bottom: -5,
                child: Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 15,
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

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.score, required this.color});

  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final xp = math.max(180, score * 7).clamp(0, 1000);
    final progress = xp / 1000;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: color,
                  size: 21,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'XP Level',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                'Lv. 12',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: .16),
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$xp / 1,000 XP',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricStrip extends StatelessWidget {
  const _MetricStrip({required this.lastResult});

  final QuizResult? lastResult;

  @override
  Widget build(BuildContext context) {
    final score = lastResult?.score ?? 87;
    final metrics = [
      _MetricData(
        icon: Icons.local_fire_department_rounded,
        value: '18',
        label: 'Day Streak',
        color: AppColors.danger,
      ),
      const _MetricData(
        icon: Icons.bolt_rounded,
        value: '2,450',
        label: 'Total XP',
        color: AppColors.warning,
      ),
      const _MetricData(
        icon: Icons.emoji_events_rounded,
        value: '#24',
        label: 'Leaderboard',
        color: AppColors.warning,
      ),
      _MetricData(
        icon: Icons.track_changes_rounded,
        value: '$score%',
        label: 'Avg. Accuracy',
        color: AppColors.purple,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth < 520;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: twoColumns ? 2 : 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: twoColumns ? 2.45 : 1.55,
          ),
          itemBuilder: (context, index) {
            final metric = metrics[index];
            return _QuickMetric(metric: metric);
          },
        );
      },
    );
  }
}

class _QuickMetric extends StatelessWidget {
  const _QuickMetric({required this.metric});

  final _MetricData metric;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: metric.color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(metric.icon, color: metric.color, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  metric.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
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

class _CertificationShelf extends StatelessWidget {
  const _CertificationShelf({
    required this.selectedTrack,
    required this.questionCounts,
    required this.onSelectTrack,
  });

  final ExamTrack selectedTrack;
  final Map<String, int> questionCounts;
  final ValueChanged<ExamTrack> onSelectTrack;

  @override
  Widget build(BuildContext context) {
    final visibleTracks = _examTracks
        .where((track) => track.code == selectedTrack.code || track.available)
        .take(3)
        .toList(growable: false);

    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: visibleTracks.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == visibleTracks.length) {
            return const _AddCertificationTile();
          }
          final track = visibleTracks[index];
          return _ProfileCertificationTile(
            track: track,
            selected: track.code == selectedTrack.code,
            questionCount: _countForTrack(questionCounts, track),
            onTap: () => onSelectTrack(track),
          );
        },
      ),
    );
  }
}

class _ProfileCertificationTile extends StatelessWidget {
  const _ProfileCertificationTile({
    required this.track,
    required this.selected,
    required this.questionCount,
    required this.onTap,
  });

  final ExamTrack track;
  final bool selected;
  final int questionCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = track.progress.clamp(.0, 1.0);
    return SizedBox(
      width: 174,
      child: PremiumCard(
        onTap: onTap,
        padding: const EdgeInsets.all(13),
        borderColor: selected
            ? track.accent.withValues(alpha: .55)
            : colorScheme.outlineVariant,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: CertificationBadgeMark(track: track, size: 76)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    track.code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: track.accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: track.accent,
                    size: 17,
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              track.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: track.accent,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              '${(progress * 100).round()}% | $questionCount Questions',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCertificationTile extends StatelessWidget {
  const _AddCertificationTile();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 150,
      child: PremiumCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: .72),
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: .22),
                ),
              ),
              child: Icon(Icons.add_rounded, color: colorScheme.primary),
            ),
            const SizedBox(height: 12),
            Text(
              'Add New\nCertification',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementShelf extends StatelessWidget {
  const _AchievementShelf();

  @override
  Widget build(BuildContext context) {
    const achievements = [
      _AchievementData(
        icon: Icons.local_fire_department_rounded,
        title: '7 Day Streak',
        subtitle: 'Keep it up!',
        color: AppColors.azure,
      ),
      _AchievementData(
        icon: Icons.track_changes_rounded,
        title: 'Accuracy Master',
        subtitle: '80% accuracy',
        color: AppColors.purple,
      ),
      _AchievementData(
        icon: Icons.school_rounded,
        title: 'Quick Learner',
        subtitle: '50 quizzes',
        color: AppColors.success,
      ),
      _AchievementData(
        icon: Icons.emoji_events_rounded,
        title: 'Top Performer',
        subtitle: 'Top 25 rank',
        color: AppColors.warning,
      ),
    ];

    return SizedBox(
      height: 128,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: achievements.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _AchievementTile(data: achievements[index]);
        },
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.data});

  final _AchievementData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 146,
      child: PremiumCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(data.icon, color: data.color),
            ),
            const SizedBox(height: 10),
            Text(
              data.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              data.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightShelf extends StatelessWidget {
  const _InsightShelf({required this.lastResult});

  final QuizResult? lastResult;

  @override
  Widget build(BuildContext context) {
    final score = lastResult?.score ?? 87;
    final insights = [
      const _InsightData(
        icon: Icons.access_time_rounded,
        value: '42h 30m',
        label: 'Total Study Time',
        trend: '+12% from last week',
        color: AppColors.azure,
      ),
      const _InsightData(
        icon: Icons.check_circle_outline_rounded,
        value: '1,620',
        label: 'Questions Solved',
        trend: '+18% from last week',
        color: AppColors.success,
      ),
      _InsightData(
        icon: Icons.track_changes_rounded,
        value: '$score%',
        label: 'Average Accuracy',
        trend: '+5% from last week',
        color: AppColors.purple,
      ),
      const _InsightData(
        icon: Icons.bar_chart_rounded,
        value: '23',
        label: 'Mock Tests Taken',
        trend: '+8% from last week',
        color: AppColors.warning,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: insights.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: compact ? 2 : 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: compact ? 1.36 : 1.05,
          ),
          itemBuilder: (context, index) {
            return _InsightTile(data: insights[index]);
          },
        );
      },
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.data});

  final _InsightData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PremiumCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: data.color, size: 26),
          const Spacer(),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            data.trend,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreList extends StatelessWidget {
  const _MoreList({required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        children: [
          _SettingsRow(
            icon: Icons.dark_mode_rounded,
            title: 'Dark mode',
            subtitle: themeController.isDark ? 'Enabled' : 'Light mode',
            trailing: Switch(
              value: themeController.isDark,
              onChanged: (_) => themeController.toggle(),
            ),
          ),
          const Divider(height: 1),
          const _SettingsRow(
            icon: Icons.bookmark_border_rounded,
            title: 'Saved Questions',
            subtitle: 'Review bookmarked exam items',
            trailing: Icon(Icons.chevron_right_rounded),
          ),
          const Divider(height: 1),
          const _SettingsRow(
            icon: Icons.download_rounded,
            title: 'Downloads',
            subtitle: 'Offline study packs',
            trailing: Icon(Icons.chevron_right_rounded),
          ),
          const Divider(height: 1),
          const _SettingsRow(
            icon: Icons.workspace_premium_rounded,
            title: 'Subscription',
            subtitle: 'Pro plan',
            trailing: Icon(Icons.chevron_right_rounded),
          ),
          const Divider(height: 1),
          const _SettingsRow(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Data and account settings',
            trailing: Icon(Icons.chevron_right_rounded),
          ),
          const Divider(height: 1),
          const _SettingsRow(
            icon: Icons.info_outline_rounded,
            title: 'About Us',
            subtitle: 'CloudCert Studio',
            trailing: Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: .55),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
}

class _AchievementData {
  const _AchievementData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
}

class _InsightData {
  const _InsightData({
    required this.icon,
    required this.value,
    required this.label,
    required this.trend,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final String trend;
  final Color color;
}
