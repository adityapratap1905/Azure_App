part of 'package:flutter_app/main.dart';

class CertificationLearningScreen extends StatelessWidget {
  const CertificationLearningScreen({
    super.key,
    required this.track,
    required this.questionCount,
    required this.onBack,
    required this.onOpenPracticeStudio,
  });

  final ExamTrack track;
  final int questionCount;
  final VoidCallback onBack;
  final ValueChanged<ExamTrack> onOpenPracticeStudio;

  @override
  Widget build(BuildContext context) {
    final guide = _learningGuideForTrack(track);
    return PremiumScrollView(
      maxWidth: 900,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LearningTopBar(track: track, onBack: onBack),
          const SizedBox(height: 12),
          _LearningHero(
            track: track,
            guide: guide,
            questionCount: questionCount,
            onOpenPracticeStudio: () => onOpenPracticeStudio(track),
          ),
          const SizedBox(height: AppSpacing.section),
          _LearningOverview(guide: guide, track: track),
          const SizedBox(height: AppSpacing.section),
          SectionHeader(
            title: 'Course modules',
            subtitle: 'Definitions, key points, and exam memory hooks',
          ),
          const SizedBox(height: 10),
          for (var index = 0; index < guide.modules.length; index++) ...[
            _LearningModuleCard(
              module: guide.modules[index],
              index: index + 1,
              color: track.accent,
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: AppSpacing.section),
          _ExamChecklistCard(guide: guide, color: track.accent),
          const SizedBox(height: AppSpacing.section),
          SectionHeader(
            title: 'Documentation',
            subtitle: 'Resources to review before entering Practice Studio',
          ),
          const SizedBox(height: 10),
          for (final resource in guide.resources) ...[
            _LearningResourceTile(resource: resource, color: track.accent),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: AppSpacing.section),
          FilledButton.icon(
            onPressed: () => onOpenPracticeStudio(track),
            style: FilledButton.styleFrom(
              backgroundColor: track.accent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            icon: const Icon(Icons.fitness_center_rounded),
            label: const Text('Go to Practice Studio'),
          ),
        ],
      ),
    );
  }
}

class CertificationLearningGuide {
  const CertificationLearningGuide({
    required this.goal,
    required this.summary,
    required this.modules,
    required this.checklist,
    required this.resources,
  });

  final String goal;
  final String summary;
  final List<CertificationLearningModule> modules;
  final List<String> checklist;
  final List<CertificationResource> resources;
}

class CertificationLearningModule {
  const CertificationLearningModule({
    required this.title,
    required this.definition,
    required this.keyPoints,
    required this.examTip,
    required this.icon,
  });

  final String title;
  final String definition;
  final List<String> keyPoints;
  final String examTip;
  final IconData icon;
}

class CertificationResource {
  const CertificationResource({
    required this.title,
    required this.description,
    required this.label,
  });

  final String title;
  final String description;
  final String label;
}

class _LearningTopBar extends StatelessWidget {
  const _LearningTopBar({required this.track, required this.onBack});

  final ExamTrack track;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: 'Back',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${track.code} learning',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'Study first, then practice',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LearningHero extends StatelessWidget {
  const _LearningHero({
    required this.track,
    required this.guide,
    required this.questionCount,
    required this.onOpenPracticeStudio,
  });

  final ExamTrack track;
  final CertificationLearningGuide guide;
  final int questionCount;
  final VoidCallback onOpenPracticeStudio;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      borderColor: Colors.white.withValues(alpha: .16),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [track.accent, track.gradientEnd],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -18,
            child: Icon(
              track.icon,
              size: 150,
              color: Colors.white.withValues(alpha: .10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.card),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CertificationBadgeMark(track: track, size: 72),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${track.code}: Microsoft ${track.name}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  height: 1.12,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            guide.goal,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: .86),
                                  height: 1.3,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroMetric(
                      icon: Icons.menu_book_rounded,
                      label: '${guide.modules.length} modules',
                    ),
                    _HeroMetric(
                      icon: Icons.quiz_rounded,
                      label: '$questionCount questions',
                    ),
                    _HeroMetric(
                      icon: Icons.trending_up_rounded,
                      label: '${(track.readiness * 100).round()}% ready',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onOpenPracticeStudio,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: track.accent,
                      minimumSize: const Size(0, 44),
                    ),
                    icon: const Icon(Icons.fitness_center_rounded),
                    label: const Text('Go to Practice Studio'),
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

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: Colors.white.withValues(alpha: .20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningOverview extends StatelessWidget {
  const _LearningOverview({required this.guide, required this.track});

  final CertificationLearningGuide guide;
  final ExamTrack track;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: 'What this exam covers'),
        const SizedBox(height: 10),
        PremiumCard(
          padding: const EdgeInsets.all(AppSpacing.card),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: track.accent.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(Icons.school_rounded, color: track.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  guide.summary,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.42,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LearningModuleCard extends StatelessWidget {
  const _LearningModuleCard({
    required this.module,
    required this.index,
    required this.color,
  });

  final CertificationLearningModule module;
  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.card),
      borderColor: color.withValues(alpha: .20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(module.icon, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$index. ${module.title}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            module.definition,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.42,
            ),
          ),
          const SizedBox(height: 12),
          for (final point in module.keyPoints) ...[
            _LearningBullet(text: point, color: color),
            const SizedBox(height: 7),
          ],
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(AppSpacing.dense),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: color.withValues(alpha: .18)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    module.examTip,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w800,
                    ),
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

class _LearningBullet extends StatelessWidget {
  const _LearningBullet({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          height: 7,
          width: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExamChecklistCard extends StatelessWidget {
  const _ExamChecklistCard({required this.guide, required this.color});

  final CertificationLearningGuide guide;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: 'Before practice checklist'),
        const SizedBox(height: 10),
        PremiumCard(
          padding: const EdgeInsets.all(AppSpacing.card),
          child: Column(
            children: [
              for (final item in guide.checklist) ...[
                _ChecklistRow(text: item, color: color),
                if (item != guide.checklist.last) const Divider(height: 18),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check_circle_rounded, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _LearningResourceTile extends StatelessWidget {
  const _LearningResourceTile({required this.resource, required this.color});

  final CertificationResource resource;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.dense),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(Icons.article_outlined, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  resource.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge(
            icon: Icons.menu_book_outlined,
            label: resource.label,
            color: color,
          ),
        ],
      ),
    );
  }
}

CertificationLearningGuide _learningGuideForTrack(ExamTrack track) {
  return switch (track.code) {
    'AZ-900' => _az900Guide,
    'AI-900' => _ai900Guide,
    'DP-900' => _dp900Guide,
    'SC-900' => _sc900Guide,
    'DP-700' => _dp700Guide,
    _ => _defaultGuide(track),
  };
}

const _az900Guide = CertificationLearningGuide(
  goal:
      'Master the fundamentals a beginner needs before attempting Azure practice questions.',
  summary:
      'AZ-900 validates that you understand cloud concepts, Azure architecture, core Azure services, identity, security, governance, pricing, service level agreements, and support. You do not need deep engineering experience, but you must know when each service or concept is used.',
  modules: [
    CertificationLearningModule(
      title: 'Cloud concepts',
      definition:
          'Cloud computing means delivering compute, storage, networking, databases, and software over the internet with pay-as-you-go access instead of owning all infrastructure yourself.',
      keyPoints: [
        'High availability keeps services usable during failures; scalability handles demand changes; elasticity adds or removes resources automatically.',
        'Capital expense is upfront hardware spending. Operational expense is ongoing usage-based spending, which is common in cloud.',
        'Public cloud is shared provider infrastructure, private cloud is dedicated to one organization, and hybrid cloud combines both.',
      ],
      examTip:
          'When a question says demand changes quickly, think scalability and elasticity. When it says avoid downtime, think availability and resilience.',
      icon: Icons.cloud_queue_rounded,
    ),
    CertificationLearningModule(
      title: 'Azure architecture and global infrastructure',
      definition:
          'Azure organizes resources through subscriptions, resource groups, regions, availability zones, and management groups so teams can deploy and govern services consistently.',
      keyPoints: [
        'A region is a geographic area with Azure datacenters. Availability zones are separate datacenter locations inside supported regions.',
        'Resource groups are logical containers for related resources and lifecycle management.',
        'Management groups help apply governance across multiple subscriptions.',
      ],
      examTip:
          'For organizing billing and access, look for subscriptions and management groups. For organizing related deployed services, choose resource groups.',
      icon: Icons.account_tree_rounded,
    ),
    CertificationLearningModule(
      title: 'Core Azure services',
      definition:
          'Core Azure services include compute, networking, storage, databases, analytics, and AI services that support common application workloads.',
      keyPoints: [
        'Azure Virtual Machines provide infrastructure as a service when you need operating system control.',
        'App Service hosts web apps without managing servers. Azure Functions runs event-driven serverless code.',
        'Blob Storage stores unstructured data such as images, backups, logs, and documents.',
      ],
      examTip:
          'If the scenario needs full server control, pick virtual machines. If it needs simple web hosting, pick App Service. If it is event-driven code, pick Functions.',
      icon: Icons.apps_rounded,
    ),
    CertificationLearningModule(
      title: 'Security, identity, and governance',
      definition:
          'Azure security combines identity, access control, threat protection, policy, monitoring, and compliance tools to protect cloud resources.',
      keyPoints: [
        'Microsoft Entra ID manages users, groups, authentication, and single sign-on.',
        'Role-based access control assigns permissions to users, groups, or services at scopes such as subscription or resource group.',
        'Azure Policy enforces rules, while Defender for Cloud helps find security risks and recommendations.',
      ],
      examTip:
          'Authentication proves who you are. Authorization decides what you can access. Azure Policy is for enforcing standards.',
      icon: Icons.verified_user_rounded,
    ),
    CertificationLearningModule(
      title: 'Pricing, SLA, and support',
      definition:
          'Azure cost and support concepts help estimate spend, monitor budgets, understand uptime commitments, and choose the right help channel.',
      keyPoints: [
        'The pricing calculator estimates future Azure costs. The TCO calculator compares on-premises costs with Azure.',
        'Service level agreements describe Microsoft uptime commitments for services.',
        'Azure Advisor gives recommendations for cost, security, reliability, operational excellence, and performance.',
      ],
      examTip:
          'Pricing calculator is for estimating Azure usage. TCO calculator is for comparing current infrastructure with Azure migration.',
      icon: Icons.payments_rounded,
    ),
  ],
  checklist: [
    'Explain IaaS, PaaS, SaaS, public cloud, private cloud, and hybrid cloud.',
    'Know the difference between regions, availability zones, subscriptions, and resource groups.',
    'Map simple scenarios to Virtual Machines, App Service, Functions, Blob Storage, and Azure SQL.',
    'Understand Entra ID, RBAC, Azure Policy, Defender for Cloud, and Azure Advisor.',
    'Review pricing calculator, TCO calculator, SLAs, support plans, and Service Health.',
  ],
  resources: [
    CertificationResource(
      title: 'Microsoft Learn AZ-900 path',
      description:
          'Official guided modules for cloud concepts, Azure services, security, governance, pricing, and support.',
      label: 'Learn',
    ),
    CertificationResource(
      title: 'Azure architecture center',
      description:
          'Architecture guidance for reliability, regions, availability zones, and resilient cloud design.',
      label: 'Docs',
    ),
    CertificationResource(
      title: 'Azure pricing and calculators',
      description:
          'Pricing calculator, total cost of ownership calculator, budgets, and cost management guidance.',
      label: 'Costs',
    ),
  ],
);

const _ai900Guide = CertificationLearningGuide(
  goal: 'Understand AI workloads and Azure AI services before practice.',
  summary:
      'AI-900 covers machine learning, computer vision, natural language processing, conversational AI, generative AI basics, and responsible AI principles at a fundamentals level.',
  modules: [
    CertificationLearningModule(
      title: 'AI workloads and responsible AI',
      definition:
          'Artificial intelligence workloads use models to predict, classify, understand, generate, or interpret data while following fairness, reliability, privacy, and transparency principles.',
      keyPoints: [
        'Machine learning predicts outcomes from data patterns.',
        'Responsible AI reduces unfair, unsafe, or opaque model behavior.',
        'Generative AI creates new content from prompts and context.',
      ],
      examTip:
          'If a scenario mentions fairness, privacy, accountability, or transparency, connect it to responsible AI.',
      icon: Icons.psychology_rounded,
    ),
    CertificationLearningModule(
      title: 'Vision, language, and speech',
      definition:
          'Azure AI services can analyze images, extract text, understand language, translate, synthesize speech, and power conversational experiences.',
      keyPoints: [
        'Computer vision identifies objects, text, scenes, and image features.',
        'Natural language processing extracts meaning, sentiment, key phrases, and entities.',
        'Speech services convert speech to text, text to speech, and translate spoken language.',
      ],
      examTip:
          'Match the input type to the service family: images use vision, text uses language, audio uses speech.',
      icon: Icons.record_voice_over_rounded,
    ),
  ],
  checklist: [
    'Define machine learning, computer vision, NLP, speech, and generative AI.',
    'Recognize common Azure AI service scenarios.',
    'Review responsible AI principles and examples.',
  ],
  resources: [
    CertificationResource(
      title: 'Microsoft Learn AI-900 path',
      description: 'Official AI fundamentals modules and scenario guidance.',
      label: 'Learn',
    ),
    CertificationResource(
      title: 'Azure AI services documentation',
      description: 'Vision, language, speech, search, and Azure OpenAI docs.',
      label: 'Docs',
    ),
  ],
);

const _dp900Guide = CertificationLearningGuide(
  goal: 'Learn data fundamentals before answering Azure data questions.',
  summary:
      'DP-900 focuses on core data concepts, relational and non-relational data, analytics workloads, and Azure data services.',
  modules: [
    CertificationLearningModule(
      title: 'Core data concepts',
      definition:
          'Data workloads include transactional systems, analytical systems, relational data, non-relational data, and batch or streaming analytics.',
      keyPoints: [
        'Relational data uses tables, rows, columns, and SQL.',
        'Non-relational data includes key-value, document, graph, and wide-column patterns.',
        'Analytics workloads summarize data for reporting and decision making.',
      ],
      examTip:
          'Operational apps usually need transactional stores. Reporting and dashboards usually need analytical stores.',
      icon: Icons.storage_rounded,
    ),
    CertificationLearningModule(
      title: 'Azure data services',
      definition:
          'Azure provides managed services for databases, storage, analytics, data lakes, and business intelligence.',
      keyPoints: [
        'Azure SQL Database is a managed relational database service.',
        'Cosmos DB is a globally distributed NoSQL database service.',
        'Synapse and Fabric support large-scale analytics scenarios.',
      ],
      examTip:
          'Use Azure SQL for relational SQL needs and Cosmos DB for globally distributed NoSQL scenarios.',
      icon: Icons.dataset_rounded,
    ),
  ],
  checklist: [
    'Compare relational and non-relational data models.',
    'Know transactional versus analytical workload patterns.',
    'Map services such as Azure SQL, Cosmos DB, Storage, Synapse, and Fabric.',
  ],
  resources: [
    CertificationResource(
      title: 'Microsoft Learn DP-900 path',
      description: 'Official Azure data fundamentals learning modules.',
      label: 'Learn',
    ),
    CertificationResource(
      title: 'Azure data documentation',
      description: 'Database, analytics, and storage service guidance.',
      label: 'Docs',
    ),
  ],
);

const _sc900Guide = CertificationLearningGuide(
  goal: 'Build security, compliance, and identity fundamentals first.',
  summary:
      'SC-900 covers Microsoft security, compliance, identity, access management, governance, and privacy concepts across Microsoft cloud services.',
  modules: [
    CertificationLearningModule(
      title: 'Identity and access',
      definition:
          'Identity systems verify users and services, then control what they can access using policies, roles, and authentication methods.',
      keyPoints: [
        'Microsoft Entra ID supports identity, authentication, and single sign-on.',
        'Multi-factor authentication adds verification beyond a password.',
        'Conditional Access applies access rules based on signals and risk.',
      ],
      examTip:
          'Authentication confirms identity. Conditional Access controls sign-in conditions.',
      icon: Icons.badge_rounded,
    ),
    CertificationLearningModule(
      title: 'Security and compliance',
      definition:
          'Microsoft security and compliance tools help protect data, manage risk, detect threats, and meet regulatory expectations.',
      keyPoints: [
        'Microsoft Defender helps protect endpoints, cloud, identity, and workloads.',
        'Microsoft Purview supports data governance, compliance, and information protection.',
        'Zero Trust assumes breach and verifies every access request.',
      ],
      examTip:
          'Purview is usually compliance and data governance. Defender is usually threat protection.',
      icon: Icons.security_rounded,
    ),
  ],
  checklist: [
    'Understand Entra ID, MFA, Conditional Access, and identity governance.',
    'Compare Defender, Sentinel, and Purview scenarios.',
    'Review Zero Trust and shared responsibility concepts.',
  ],
  resources: [
    CertificationResource(
      title: 'Microsoft Learn SC-900 path',
      description: 'Official security, compliance, and identity modules.',
      label: 'Learn',
    ),
    CertificationResource(
      title: 'Microsoft Entra and Purview docs',
      description:
          'Identity, access, compliance, and governance documentation.',
      label: 'Docs',
    ),
  ],
);

const _dp700Guide = CertificationLearningGuide(
  goal: 'Study Microsoft Fabric data engineering concepts before practice.',
  summary:
      'DP-700 focuses on implementing data engineering solutions with Microsoft Fabric, including lakehouses, pipelines, warehouses, transformations, monitoring, and governance.',
  modules: [
    CertificationLearningModule(
      title: 'Fabric lakehouse and data ingestion',
      definition:
          'A Fabric lakehouse stores data for analytics and engineering workflows while pipelines bring data from source systems into managed destinations.',
      keyPoints: [
        'Lakehouses combine data lake flexibility with structured analytics features.',
        'Pipelines orchestrate ingestion, transformation, and movement tasks.',
        'Medallion architecture commonly separates bronze, silver, and gold data layers.',
      ],
      examTip:
          'When the scenario asks for orchestrated movement or scheduled ingestion, think data pipelines.',
      icon: Icons.waterfall_chart_rounded,
    ),
    CertificationLearningModule(
      title: 'Transform, monitor, and govern',
      definition:
          'Data engineering solutions need reliable transformations, quality checks, monitoring, access control, and governance.',
      keyPoints: [
        'Notebooks and dataflows support transformation workflows.',
        'Monitoring helps identify pipeline failures and performance issues.',
        'Governance protects data through permissions, lineage, and policies.',
      ],
      examTip:
          'Operational questions often focus on monitoring failures, lineage, permissions, and repeatable transformations.',
      icon: Icons.settings_suggest_rounded,
    ),
  ],
  checklist: [
    'Understand Fabric lakehouse, warehouse, pipelines, notebooks, and dataflows.',
    'Review medallion architecture and transformation patterns.',
    'Know monitoring, permissions, lineage, and governance basics.',
  ],
  resources: [
    CertificationResource(
      title: 'Microsoft Fabric learning path',
      description: 'Lakehouse, warehouse, and data engineering modules.',
      label: 'Learn',
    ),
    CertificationResource(
      title: 'Fabric data engineering docs',
      description:
          'Pipelines, notebooks, lakehouse, governance, and monitoring.',
      label: 'Docs',
    ),
  ],
);

CertificationLearningGuide _defaultGuide(ExamTrack track) {
  return CertificationLearningGuide(
    goal: 'Review the core concepts before starting practice.',
    summary:
        '${track.code} preparation should start with the official skills outline, service definitions, scenario mapping, and documentation review before quiz practice.',
    modules: [
      CertificationLearningModule(
        title: 'Core exam objectives',
        definition:
            'Exam objectives describe the knowledge areas a student must understand to pass the certification.',
        keyPoints: [
          'Read the skills outline before practice.',
          'Map each product or service to a real scenario.',
          'Review definitions before memorizing answers.',
        ],
        examTip:
            'If a service name appears in multiple scenarios, focus on what problem it solves.',
        icon: track.icon,
      ),
    ],
    checklist: const [
      'Review the official exam outline.',
      'Study key service definitions.',
      'Practice only after learning the concept map.',
    ],
    resources: const [
      CertificationResource(
        title: 'Official learning path',
        description: 'Guided modules from the platform documentation.',
        label: 'Learn',
      ),
    ],
  );
}
