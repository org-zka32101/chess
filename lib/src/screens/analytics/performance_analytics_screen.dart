import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess/src/providers/performance_analytics_provider.dart';

/// Screen for displaying performance analytics and trends
class PerformanceAnalyticsScreen extends ConsumerWidget {
  final String playerId;
  final String playerName;

  const PerformanceAnalyticsScreen({
    Key? key,
    required this.playerId,
    required this.playerName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performanceStats = ref.watch(performanceStatsProvider(playerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('パフォーマンス分析'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(performanceStatsProvider(playerId)),
          ),
        ],
      ),
      body: performanceStats.when(
        data: (stats) => _buildContent(context, ref, stats),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'パフォーマンスデータの取得に失敗しました',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.refresh(performanceStatsProvider(playerId)),
                icon: const Icon(Icons.refresh),
                label: const Text('再試行'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    dynamic stats,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Streak information
          _buildStreakSection(context, ref),
          const SizedBox(height: 24),

          // Rating progression chart
          _buildProgressionSection(context, stats),
          const SizedBox(height: 24),

          // Performance by time control
          _buildPerformanceByTimeControl(context, ref),
          const SizedBox(height: 24),

          // Performance by opponent rank
          _buildPerformanceByRank(context, ref),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStreakSection(BuildContext context, WidgetRef ref) {
    final streakInfo = ref.watch(streakInfoProvider(playerId));

    return streakInfo.when(
      data: (streak) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '連続記録',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStreakCard(
                    context,
                    '現在の連勝',
                    '${streak.current > 0 ? streak.current : 0}',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStreakCard(
                    context,
                    '最長連勝',
                    '${streak.longestWin}',
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStreakCard(
                    context,
                    '最長連敗',
                    '${streak.longestLoss}',
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStreakCard(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressionSection(BuildContext context, dynamic stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'レーティング進行',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            height: 200,
            child: Center(
              child: Text(
                'グラフ表示 (fl_chart統合時に実装)',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeRangeButton(context, '30日', 30),
              _buildTimeRangeButton(context, '90日', 90),
              _buildTimeRangeButton(context, '365日', 365),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeButton(BuildContext context, String label, int days) {
    return OutlinedButton(
      onPressed: () {
        // TODO: Implement time range switching
      },
      child: Text(label),
    );
  }

  Widget _buildPerformanceByTimeControl(BuildContext context, WidgetRef ref) {
    final performanceByTimeControl =
        ref.watch(performanceByTimeControlProvider(playerId));

    return performanceByTimeControl.when(
      data: (performance) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '時間制別パフォーマンス',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: performance.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entries = performance.entries.toList();
                final timeControl = entries[index].key;
                final winRate = entries[index].value;

                return _buildPerformanceRow(
                  context,
                  _getTimeControlLabel(timeControl),
                  '$winRate%',
                  winRate,
                );
              },
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildPerformanceByRank(BuildContext context, WidgetRef ref) {
    final performanceByRank = ref.watch(performanceByRankProvider(playerId));

    return performanceByRank.when(
      data: (performance) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'レベル別パフォーマンス',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            performance.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'データがありません',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: performance.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entries = performance.entries.toList();
                      final rank = entries[index].key;
                      final winRate = entries[index].value;

                      return _buildPerformanceRow(
                        context,
                        rank,
                        '$winRate%',
                        winRate,
                      );
                    },
                  ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildPerformanceRow(
    BuildContext context,
    String label,
    String winRate,
    int percentage,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                winRate,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getPerformanceColor(percentage),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getPerformanceColor(percentage),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPerformanceColor(int percentage) {
    if (percentage >= 70) {
      return Colors.green;
    } else if (percentage >= 50) {
      return Colors.blue;
    } else if (percentage >= 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getTimeControlLabel(String timeControl) {
    switch (timeControl) {
      case 'bullet':
        return 'バレット (1分以下)';
      case 'blitz':
        return 'ブリッツ (3分～5分)';
      case 'rapid':
        return 'ラピッド (10分以上)';
      default:
        return timeControl;
    }
  }
}
