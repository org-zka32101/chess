import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_lesson.dart';
import '../providers/phase_j_providers.dart';

/// Widget displaying game analysis results with AI insights
class AIGameAnalysisCard extends ConsumerWidget {
  final String userId;
  final String gameId;

  const AIGameAnalysisCard({
    required this.userId,
    required this.gameId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(
      gameAnalysisProvider(
        (userId: userId, gameId: gameId),
      ),
    );

    return analysisAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, stack) => Text('Error: $err'),
      data: (analysis) => Card(
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Game Analysis',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _AnalysisMetricsRow(analysis: analysis),
              const SizedBox(height: 16),
              _ErrorBreakdown(analysis: analysis),
              const SizedBox(height: 16),
              _WeaknessesSection(
                weaknesses: analysis.identifiedWeaknesses,
              ),
              const SizedBox(height: 12),
              Text(
                'Assessment: ${analysis.overallAssessment}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalysisMetricsRow extends StatelessWidget {
  final GameAnalysis analysis;

  const _AnalysisMetricsRow({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _MetricBox(
          label: 'Accuracy',
          value: '${analysis.overallAccuracy.toStringAsFixed(1)}%',
        ),
        _MetricBox(
          label: 'Moves',
          value: '${analysis.totalMoves}',
        ),
        _MetricBox(
          label: 'Blunders',
          value: '${analysis.blunders}',
        ),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;

  const _MetricBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _ErrorBreakdown extends StatelessWidget {
  final GameAnalysis analysis;

  const _ErrorBreakdown({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Error Breakdown',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value:
              analysis.blunders / (analysis.totalMoves > 0 ? analysis.totalMoves : 1),
          color: Colors.red,
        ),
        const SizedBox(height: 4),
        Text(
          'Blunders: ${analysis.blunders}',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _WeaknessesSection extends StatelessWidget {
  final List<String> weaknesses;

  const _WeaknessesSection({required this.weaknesses});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Identified Weaknesses',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: weaknesses
              .map((w) => Chip(label: Text(w)))
              .toList(),
        ),
      ],
    );
  }
}

/// Widget displaying player profile and statistics
class PlayerProfileCard extends ConsumerWidget {
  final String userId;

  const PlayerProfileCard({
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(playerProfileProvider(userId));

    return profileAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, stack) => Text('Error: $err'),
      data: (profile) => Card(
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Profile',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _ProfileStats(profile: profile),
              const SizedBox(height: 16),
              _StrengthsAndWeaknesses(profile: profile),
              const SizedBox(height: 16),
              _PlayStyleBadge(style: profile.playStyle),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  final PlayerProfile profile;

  const _ProfileStats({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatRow(
          label: 'Games Analyzed',
          value: '${profile.totalGamesAnalyzed}',
        ),
        _StatRow(
          label: 'Average Accuracy',
          value: '${profile.averageAccuracy.toStringAsFixed(1)}%',
        ),
        _StatRow(
          label: 'Tactic Patterns Known',
          value: '${profile.tacticPatternsKnown}',
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _StrengthsAndWeaknesses extends StatelessWidget {
  final PlayerProfile profile;

  const _StrengthsAndWeaknesses({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Strengths',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: profile.mainStrengths
              .map((s) => Chip(
                    label: Text(s),
                    backgroundColor: Colors.green[200],
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        Text(
          'Areas to Improve',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: profile.mainWeaknesses
              .map((w) => Chip(
                    label: Text(w),
                    backgroundColor: Colors.red[200],
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _PlayStyleBadge extends StatelessWidget {
  final String style;

  const _PlayStyleBadge({required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Play Style: $style',
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

/// Widget displaying personalized improvement path
class ImprovementPathCard extends ConsumerWidget {
  final String userId;

  const ImprovementPathCard({
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathAsync = ref.watch(improvementPathProvider(userId));

    return pathAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, stack) => Text('Error: $err'),
      data: (path) => Card(
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Improvement Path',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _PriorityAreas(areas: path.priorityAreas),
              const SizedBox(height: 16),
              _EstimationBox(
                days: path.estimatedDaysToImprovement,
              ),
              const SizedBox(height: 16),
              _PersonalizedAdviceBox(
                advice: path.personalizedAdvice,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityAreas extends StatelessWidget {
  final List<String> areas;

  const _PriorityAreas({required this.areas});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority Focus Areas',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ...areas.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${e.key + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(e.value),
                ],
              ),
            )),
      ],
    );
  }
}

class _EstimationBox extends StatelessWidget {
  final int days;

  const _EstimationBox({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        border: Border.all(color: Colors.amber),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, color: Colors.amber),
          const SizedBox(width: 12),
          Text(
            'Estimated improvement in ~$days days',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _PersonalizedAdviceBox extends StatelessWidget {
  final String advice;

  const _PersonalizedAdviceBox({required this.advice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personalized Advice',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 8),
          Text(
            advice,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying AI-generated lessons
class AILessonsList extends ConsumerWidget {
  final String userId;
  final AIContentType? contentType;
  final RecommendationLevel? skillLevel;

  const AILessonsList({
    required this.userId,
    this.contentType,
    this.skillLevel,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<AIGeneratedLesson>> lessonsAsync;

    if (contentType != null && skillLevel != null) {
      lessonsAsync = ref.watch(aiGeneratedLessonsByLevelProvider(
        (userId: userId, level: skillLevel!),
      ));
    } else if (contentType != null) {
      lessonsAsync = ref.watch(aiGeneratedLessonsByTypeProvider(
        (userId: userId, contentType: contentType!),
      ));
    } else {
      lessonsAsync = ref.watch(aiGeneratedLessonsProvider(userId));
    }

    return lessonsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, stack) => Text('Error: $err'),
      data: (lessons) => ListView.builder(
        itemCount: lessons.length,
        itemBuilder: (context, index) => _AILessonCard(
          lesson: lessons[index],
          userId: userId,
        ),
      ),
    );
  }
}

class _AILessonCard extends ConsumerWidget {
  final AIGeneratedLesson lesson;
  final String userId;

  const _AILessonCard({
    required this.lesson,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    lesson.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    lesson.isLiked ? Icons.favorite : Icons.favorite_border,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              lesson.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(lesson.recommendedLevel.toString().split('.').last),
                  backgroundColor: Colors.orange[200],
                ),
                Text(
                  '${lesson.estimatedMinutes} min',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
