part of 'package:flutter_app/main.dart';

class AppColors {
  static const azure = Color(0xFF0078D4);
  static const azureDark = Color(0xFF005A9E);
  static const azureDeep = Color(0xFF003A6B);
  static const cyan = Color(0xFF00BCF2);
  static const purple = Color(0xFF7F52FF);
  static const success = Color(0xFF21A366);
  static const warning = Color(0xFFFFB020);
  static const danger = Color(0xFFD83B01);
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF667085);
  static const canvas = Color(0xFFF6F8FC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xFFEAF1FB);
  static const outline = Color(0xFFD7DEEA);
  static const darkCanvas = Color(0xFF0B1220);
  static const darkSurface = Color(0xFF111A2C);
  static const darkSurfaceSoft = Color(0xFF1B2840);
}

class AppSpacing {
  static const xs = 6.0;
  static const sm = 10.0;
  static const dense = 12.0;
  static const card = 14.0;
  static const md = 16.0;
  static const section = 18.0;
  static const screenBottom = md;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppRadii {
  static const sm = 8.0;
  static const md = 8.0;
  static const lg = 8.0;
  static const pill = 999.0;
}

class AppDurations {
  static const fast = Duration(milliseconds: 160);
  static const medium = Duration(milliseconds: 260);
}

class ExamTrack {
  const ExamTrack({
    required this.code,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.progress,
    required this.readiness,
    required this.description,
    required this.icon,
    required this.accent,
    required this.gradientEnd,
    required this.available,
  });

  final String code;
  final String name;
  final String category;
  final String difficulty;
  final double progress;
  final double readiness;
  final String description;
  final IconData icon;
  final Color accent;
  final Color gradientEnd;
  final bool available;
}

class StudyTopic {
  const StudyTopic({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.progress,
    required this.color,
    required this.difficulty,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final double progress;
  final Color color;
  final Difficulty difficulty;
}

class Achievement {
  const Achievement({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

const _examTracks = [
  ExamTrack(
    code: 'AZ-900',
    name: 'Azure Fundamentals',
    category: 'Cloud',
    difficulty: 'Beginner',
    progress: .68,
    readiness: .74,
    description:
        'Cloud concepts, Azure services, pricing, SLA, and governance.',
    icon: Icons.cloud_rounded,
    accent: AppColors.azure,
    gradientEnd: AppColors.cyan,
    available: true,
  ),
  ExamTrack(
    code: 'AI-900',
    name: 'AI Fundamentals',
    category: 'AI',
    difficulty: 'Beginner',
    progress: .46,
    readiness: .61,
    description: 'Machine learning, NLP, vision, responsible AI, and Azure AI.',
    icon: Icons.psychology_rounded,
    accent: AppColors.purple,
    gradientEnd: AppColors.cyan,
    available: true,
  ),
  ExamTrack(
    code: 'CLF-C02',
    name: 'AWS Cloud Practitioner',
    category: 'Cloud',
    difficulty: 'Beginner',
    progress: .0,
    readiness: .0,
    description:
        'AWS cloud concepts, security, technology, billing, and support.',
    icon: Icons.cloud_sync_rounded,
    accent: Color(0xFF00A88E),
    gradientEnd: Color(0xFF16D6B5),
    available: false,
  ),
  ExamTrack(
    code: 'DP-700',
    name: 'Fabric Data Engineer',
    category: 'Data',
    difficulty: 'Intermediate',
    progress: .28,
    readiness: .42,
    description: 'Lakehouse, pipelines, warehouse, governance, and monitoring.',
    icon: Icons.storage_rounded,
    accent: Color(0xFF5B5FC7),
    gradientEnd: Color(0xFF00C7BE),
    available: true,
  ),
  ExamTrack(
    code: 'DP-900',
    name: 'Data Fundamentals',
    category: 'Data',
    difficulty: 'Beginner',
    progress: .0,
    readiness: .0,
    description:
        'Core data concepts, relational data, analytics, and Azure data.',
    icon: Icons.dataset_rounded,
    accent: Color(0xFF2AA0A4),
    gradientEnd: Color(0xFF7F52FF),
    available: false,
  ),
  ExamTrack(
    code: 'SC-900',
    name: 'Security Fundamentals',
    category: 'Security',
    difficulty: 'Beginner',
    progress: .0,
    readiness: .0,
    description:
        'Identity, compliance, security posture, and Microsoft Defender.',
    icon: Icons.security_rounded,
    accent: Color(0xFFD83B01),
    gradientEnd: Color(0xFFFFB020),
    available: false,
  ),
];

ExamTrack _trackForCode(String code) {
  return _examTracks.firstWhere(
    (track) => track.code == code,
    orElse: () => _examTracks.first,
  );
}

List<ExamTrack> get _availableExamTracks =>
    _examTracks.where((track) => track.available).toList(growable: false);

int _countForTrack(Map<String, int> questionCounts, ExamTrack track) {
  return questionCounts[track.code] ?? 0;
}

List<StudyTopic> _topicsForTrack(ExamTrack track, List<Question> questions) {
  final trackQuestions = questions
      .where((question) => question.examType == track.code)
      .toList(growable: false);
  if (trackQuestions.isEmpty) {
    return const [
      StudyTopic(
        title: 'Cloud Concepts',
        subtitle: 'Core concepts and service models',
        icon: Icons.cloud_queue_rounded,
        progress: .72,
        color: AppColors.azure,
        difficulty: Difficulty.easy,
      ),
      StudyTopic(
        title: 'AI Fundamentals',
        subtitle: 'Responsible AI and workloads',
        icon: Icons.auto_awesome_rounded,
        progress: .48,
        color: AppColors.purple,
        difficulty: Difficulty.easy,
      ),
      StudyTopic(
        title: 'Security',
        subtitle: 'Identity and compliance basics',
        icon: Icons.shield_rounded,
        progress: .36,
        color: AppColors.danger,
        difficulty: Difficulty.medium,
      ),
      StudyTopic(
        title: 'Pricing & SLA',
        subtitle: 'Cost, support, and reliability',
        icon: Icons.payments_rounded,
        progress: .58,
        color: AppColors.warning,
        difficulty: Difficulty.medium,
      ),
    ];
  }

  final grouped = <String, int>{};
  for (final question in trackQuestions) {
    grouped.update(question.category, (value) => value + 1, ifAbsent: () => 1);
  }
  final sorted = grouped.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final colors = [
    AppColors.azure,
    AppColors.purple,
    AppColors.success,
    AppColors.warning,
    AppColors.cyan,
    AppColors.danger,
  ];
  final icons = [
    Icons.cloud_queue_rounded,
    Icons.auto_awesome_rounded,
    Icons.security_rounded,
    Icons.account_tree_rounded,
    Icons.query_stats_rounded,
    Icons.hub_rounded,
  ];
  return [
    for (var index = 0; index < math.min(sorted.length, 8); index++)
      StudyTopic(
        title: sorted[index].key,
        subtitle: '${sorted[index].value} exam-style questions',
        icon: icons[index % icons.length],
        progress: (.34 + (index * .09) + track.progress).clamp(.18, .96),
        color: colors[index % colors.length],
        difficulty: index < 3 ? Difficulty.easy : Difficulty.medium,
      ),
  ];
}

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final seed = isDark ? const Color(0xFF84C5FF) : AppColors.azure;
  final colorScheme =
      ColorScheme.fromSeed(seedColor: seed, brightness: brightness).copyWith(
        primary: isDark ? const Color(0xFF8CCBFF) : AppColors.azure,
        onPrimary: Colors.white,
        primaryContainer: isDark
            ? const Color(0xFF123B62)
            : const Color(0xFFE6F4FF),
        onPrimaryContainer: isDark
            ? const Color(0xFFD7ECFF)
            : AppColors.azureDeep,
        secondary: isDark ? const Color(0xFFC7B7FF) : AppColors.purple,
        tertiary: isDark ? const Color(0xFF7DE7FF) : AppColors.cyan,
        surface: isDark ? AppColors.darkSurface : AppColors.surface,
        surfaceContainerHighest: isDark
            ? AppColors.darkSurfaceSoft
            : AppColors.surfaceSoft,
        onSurface: isDark ? const Color(0xFFF8FAFC) : AppColors.ink,
        onSurfaceVariant: isDark ? const Color(0xFFC6D0DF) : AppColors.muted,
        outline: isDark ? const Color(0xFF34435C) : AppColors.outline,
        outlineVariant: isDark
            ? const Color(0xFF27364E)
            : const Color(0xFFE2E8F0),
        error: AppColors.danger,
      );

  final baseTheme = ThemeData(
    colorScheme: colorScheme,
    brightness: brightness,
    useMaterial3: true,
  );
  final textTheme = GoogleFonts.interTextTheme(baseTheme.textTheme);

  return ThemeData(
    colorScheme: colorScheme,
    brightness: brightness,
    useMaterial3: true,
    textTheme: textTheme.copyWith(
      headlineLarge: textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w900,
        color: colorScheme.onSurface,
      ),
      headlineMedium: textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w900,
        color: colorScheme.onSurface,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(height: 1.45),
      bodyMedium: textTheme.bodyMedium?.copyWith(height: 1.45),
      labelLarge: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
    ),
    scaffoldBackgroundColor: isDark ? AppColors.darkCanvas : AppColors.canvas,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
    ),
    chipTheme: baseTheme.chipTheme.copyWith(
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(
        alpha: .64,
      ),
      selectedColor: colorScheme.primaryContainer,
      side: BorderSide(color: colorScheme.outlineVariant),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      labelStyle: TextStyle(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface,
      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 8,
      extendedTextStyle: const TextStyle(fontWeight: FontWeight.w900),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
          color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 22,
          color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        );
      }),
    ),
  );
}
