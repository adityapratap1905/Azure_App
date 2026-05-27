part of 'package:flutter_app/main.dart';

class ProfileScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return PremiumScrollView(
      maxWidth: 760,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileHeader(selectedTrack: selectedTrack, lastResult: lastResult),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: _ProfileStatCard(
                  icon: Icons.bolt_rounded,
                  label: 'XP points',
                  value: '1,840',
                  color: AppColors.azure,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _ProfileStatCard(
                  icon: Icons.emoji_events_rounded,
                  label: 'Rank',
                  value: '#128',
                  color: AppColors.warning,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _ProfileStatCard(
                  icon: Icons.workspace_premium_rounded,
                  label: 'Badges',
                  value: '12',
                  color: AppColors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionHeader(
            title: 'Preparing for',
            subtitle: 'Your active Microsoft certification tracks.',
          ),
          const SizedBox(height: 12),
          for (final track in _examTracks) ...[
            CertificationCard(
              track: track,
              questionCount: _countForTrack(questionCounts, track),
              selected: track.code == selectedTrack.code,
              compact: true,
              onTap: () => onSelectTrack(track),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 12),
          SectionHeader(title: 'Achievement badges'),
          const SizedBox(height: 12),
          _BadgeShelf(),
          const SizedBox(height: 20),
          PremiumCard(
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
                  icon: Icons.notifications_active_rounded,
                  title: 'Daily study reminders',
                  subtitle: '8:30 PM',
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
                const Divider(height: 1),
                const _SettingsRow(
                  icon: Icons.privacy_tip_rounded,
                  title: 'Exam preferences',
                  subtitle: 'Mixed practice, instant feedback',
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.selectedTrack, required this.lastResult});

  final ExamTrack selectedTrack;
  final QuizResult? lastResult;

  @override
  Widget build(BuildContext context) {
    final score = lastResult?.score ?? (selectedTrack.readiness * 100).round();
    return PremiumCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          selectedTrack.accent.withValues(alpha: .92),
          selectedTrack.gradientEnd.withValues(alpha: .86),
        ],
      ),
      borderColor: Colors.white.withValues(alpha: .16),
      child: Row(
        children: [
          Container(
            height: 72,
            width: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: Colors.white.withValues(alpha: .26)),
            ),
            child: const Text(
              'A',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alex',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${selectedTrack.code} readiness $score%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: .82),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    StatusBadge(
                      icon: Icons.local_fire_department_rounded,
                      label: '7 day streak',
                      color: Colors.white,
                      onColor: Colors.white,
                    ),
                    StatusBadge(
                      icon: Icons.leaderboard_rounded,
                      label: 'Top 12%',
                      color: Colors.white,
                      onColor: Colors.white,
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

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.dense),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeShelf extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: const [
          _AchievementBadge(
            icon: Icons.cloud_done_rounded,
            title: 'Cloud Core',
            color: AppColors.azure,
          ),
          _AchievementBadge(
            icon: Icons.psychology_rounded,
            title: 'AI Scout',
            color: AppColors.purple,
          ),
          _AchievementBadge(
            icon: Icons.security_rounded,
            title: 'Secure Mind',
            color: AppColors.danger,
          ),
          _AchievementBadge(
            icon: Icons.timer_rounded,
            title: 'Fast Mock',
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.all(AppSpacing.dense),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.dense),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: .68),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
          trailing,
        ],
      ),
    );
  }
}
