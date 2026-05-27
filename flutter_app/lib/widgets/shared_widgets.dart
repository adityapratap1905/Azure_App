part of 'package:flutter_app/main.dart';

class PremiumScrollView extends StatelessWidget {
  const PremiumScrollView({
    super.key,
    required this.child,
    this.maxWidth = 720,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.section,
      AppSpacing.section,
      AppSpacing.section,
      28,
    ),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.card),
    this.gradient,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = AnimatedContainer(
      duration: AppDurations.fast,
      curve: Curves.easeOut,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? colorScheme.surface : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color:
              borderColor ?? colorScheme.outlineVariant.withValues(alpha: .9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? .14
                  : .045,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(actionLabel!),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded, size: 16),
              ],
            ),
          ),
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onColor,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color? onColor;

  @override
  Widget build(BuildContext context) {
    final foreground = onColor ?? color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: color.withValues(alpha: .24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: foreground, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class ExamBadge extends StatelessWidget {
  const ExamBadge({
    super.key,
    required this.track,
    this.size = 54,
    this.disabled = false,
  });

  final ExamTrack track;
  final double size;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final color = disabled
        ? Theme.of(context).colorScheme.outline
        : track.accent;
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: disabled
              ? [color.withValues(alpha: .45), color.withValues(alpha: .18)]
              : [track.accent, track.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(track.icon, color: Colors.white, size: size * .34),
          const SizedBox(height: 1),
          Text(
            track.code.split('-').first,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * .16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class CertificationBadgeMark extends StatelessWidget {
  const CertificationBadgeMark({
    super.key,
    required this.track,
    this.size = 64,
    this.disabled = false,
  });

  final ExamTrack track;
  final double size;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final width = size * .92;
    return SizedBox(
      height: size,
      width: width,
      child: CustomPaint(
        painter: _CertificationBadgePainter(
          track: track,
          disabled: disabled,
          textDirection: Directionality.of(context),
        ),
      ),
    );
  }
}

class _CertificationBadgePainter extends CustomPainter {
  const _CertificationBadgePainter({
    required this.track,
    required this.disabled,
    required this.textDirection,
  });

  final ExamTrack track;
  final bool disabled;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final accent = disabled ? AppColors.outline : track.accent;
    final deep = disabled ? AppColors.muted : _darken(accent, .28);
    final w = size.width;
    final h = size.height;

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: disabled ? .06 : .16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final shield = Path()
      ..moveTo(w * .17, h * .10)
      ..quadraticBezierTo(w * .50, h * -.02, w * .83, h * .10)
      ..lineTo(w * .78, h * .64)
      ..quadraticBezierTo(w * .72, h * .83, w * .50, h * .96)
      ..quadraticBezierTo(w * .28, h * .83, w * .22, h * .64)
      ..close();
    canvas.drawPath(shield.shift(Offset(0, h * .025)), shadow);
    canvas.drawPath(
      shield,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [deep, accent],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      shield,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, size.shortestSide * .018)
        ..color = Colors.white.withValues(alpha: .55),
    );

    _paintText(
      canvas,
      'Microsoft',
      Offset(w * .50, h * .19),
      width: w * .48,
      color: Colors.white,
      fontSize: h * .085,
      weight: FontWeight.w900,
    );
    _paintText(
      canvas,
      'CERTIFIED',
      Offset(w * .50, h * .29),
      width: w * .50,
      color: Colors.white.withValues(alpha: .86),
      fontSize: h * .065,
      weight: FontWeight.w800,
      letterSpacing: .7,
    );

    canvas.save();
    canvas.translate(w * .50, h * .46);
    canvas.rotate(-0.07);
    final ribbon = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w * .96, height: h * .30),
      Radius.circular(h * .055),
    );
    canvas.drawRRect(
      ribbon.shift(Offset(0, h * .025)),
      Paint()..color = Colors.black.withValues(alpha: .16),
    );
    canvas.drawRRect(ribbon, Paint()..color = Colors.white);
    canvas.drawRRect(
      ribbon,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, size.shortestSide * .016)
        ..color = AppColors.ink.withValues(alpha: .74),
    );
    _paintText(
      canvas,
      _badgeTitle(track),
      Offset.zero,
      width: w * .78,
      color: AppColors.ink,
      fontSize: h * .105,
      weight: FontWeight.w900,
      maxLines: 2,
    );
    canvas.restore();

    _paintStar(canvas, Offset(w * .50, h * .78), h * .083);
  }

  String _badgeTitle(ExamTrack track) {
    if (track.code == 'AZ-900') return 'AZURE\nFUNDAMENTALS';
    if (track.code == 'AI-900') return 'AI\nFUNDAMENTALS';
    if (track.code == 'DP-900') return 'DATA\nFUNDAMENTALS';
    if (track.code == 'SC-900') return 'SECURITY\nFUNDAMENTALS';
    if (track.code == 'CLF-C02') return 'CLOUD\nPRACTITIONER';
    return track.code.replaceAll('-', '\n');
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset center, {
    required double width,
    required Color color,
    required double fontSize,
    required FontWeight weight,
    double letterSpacing = 0,
    int maxLines = 1,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          height: .98,
          letterSpacing: letterSpacing,
        ),
      ),
      maxLines: maxLines,
      textAlign: TextAlign.center,
      textDirection: textDirection,
    )..layout(maxWidth: width);
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  void _paintStar(Canvas canvas, Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final r = i.isEven ? radius : radius * .42;
      final point = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  bool shouldRepaint(covariant _CertificationBadgePainter oldDelegate) {
    return oldDelegate.track != track ||
        oldDelegate.disabled != disabled ||
        oldDelegate.textDirection != textDirection;
  }
}

class CertificationCard extends StatelessWidget {
  const CertificationCard({
    super.key,
    required this.track,
    required this.questionCount,
    required this.selected,
    this.compact = false,
    this.onTap,
    this.onStart,
  });

  final ExamTrack track;
  final int questionCount;
  final bool selected;
  final bool compact;
  final VoidCallback? onTap;
  final VoidCallback? onStart;

  bool get _enabled => track.available && questionCount > 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final muted = !_enabled;
    return Opacity(
      opacity: muted ? .72 : 1,
      child: PremiumCard(
        onTap: onTap,
        borderColor: selected
            ? track.accent.withValues(alpha: .7)
            : colorScheme.outlineVariant,
        padding: EdgeInsets.all(compact ? AppSpacing.dense : AppSpacing.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CertificationBadgeMark(
                  track: track,
                  size: compact ? 54 : 64,
                  disabled: muted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              track.code,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                          if (selected) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.check_circle_rounded,
                              color: track.accent,
                              size: 18,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        track.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!compact) ...[
              const SizedBox(height: 12),
              Text(
                track.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.card),
            Row(
              children: [
                StatusBadge(
                  icon: Icons.format_list_numbered_rounded,
                  label: _enabled ? '$questionCount questions' : 'Coming soon',
                  color: _enabled ? track.accent : colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: StatusBadge(
                    icon: Icons.signal_cellular_alt_rounded,
                    label: track.difficulty,
                    color: track.difficulty == 'Beginner'
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
              ],
            ),
            if (!compact) ...[
              const SizedBox(height: AppSpacing.card),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      child: LinearProgressIndicator(
                        value: track.progress,
                        minHeight: 8,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        color: track.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _enabled ? '${(track.progress * 100).round()}%' : 'Soon',
                    style: TextStyle(
                      color: _enabled
                          ? track.accent
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.card),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _enabled ? onStart : null,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(_enabled ? 'Continue' : 'Notify me'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    this.size = 86,
  });

  final double value;
  final String label;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              value: value.clamp(0, 1),
              strokeWidth: 9,
              color: color,
              backgroundColor: color.withValues(alpha: .14),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
    this.icon = Icons.insights_rounded,
  });

  final String title;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 158,
      child: PremiumCard(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
      ],
    );
  }
}

class _QuestionTitle extends StatelessWidget {
  const _QuestionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.card),
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: .72),
            colorScheme.tertiaryContainer.withValues(alpha: .38),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
          height: 1.32,
        ),
      ),
    );
  }
}

class _EmptyDropMessage extends StatelessWidget {
  const _EmptyDropMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: const Text('No items placed yet', textAlign: TextAlign.center),
    );
  }
}

String _formatSeconds(int seconds) {
  final minutes = seconds ~/ 60;
  final remaining = seconds % 60;
  return '$minutes:${remaining.toString().padLeft(2, '0')}';
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '${minutes}m ${seconds}s';
}

String _scoreMessage(int score) {
  if (score >= 80) {
    return "You're tracking like an exam-ready learner.";
  }
  if (score >= 60) {
    return 'Solid momentum. A focused review pass will move the needle.';
  }
  return 'Build the base first, then increase exam pressure gradually.';
}

Color _scoreColor(int score) {
  if (score >= 80) return AppColors.success;
  if (score >= 60) return AppColors.warning;
  return AppColors.danger;
}
