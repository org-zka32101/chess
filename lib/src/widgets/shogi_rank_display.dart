import 'package:flutter/material.dart';
import '../services/shogi_rank_service.dart';

/// Display widget for shogi ranks with color coding
class ShogiRankDisplay extends StatelessWidget {
  final String rankString;
  final bool compact;

  const ShogiRankDisplay({
    Key? key,
    required this.rankString,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rank = ShogiRankService.parseRank(rankString);
    final theme = Theme.of(context);

    if (compact) {
      return _buildCompactBadge(context, rank);
    } else {
      return _buildDetailedDisplay(context, rank);
    }
  }

  /// Compact badge display (for leaderboard cards)
  Widget _buildCompactBadge(BuildContext context, ShogiRank rank) {
    final color = _getRankColor(rank);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        rankString,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Detailed display with progress bar
  Widget _buildDetailedDisplay(BuildContext context, ShogiRank rank) {
    final color = _getRankColor(rank);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Text(
            rankString,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            _getRankDescription(rank),
            style: theme.textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Get color for rank
  Color _getRankColor(ShogiRank rank) {
    if (rank is _KyuRank) {
      return switch ((rank as _KyuRank).level) {
        1 => const Color(0xFF4CAF50), // Bright green
        <= 5 => const Color(0xFF66BB6A), // Medium green
        <= 10 => const Color(0xFF81C784), // Light green
        <= 15 => const Color(0xFFA5D6A7), // Lighter green
        _ => const Color(0xFFC8E6C9), // Very light green
      };
    } else {
      return switch ((rank as _DanRank).level) {
        1 => const Color(0xFF2196F3), // Blue
        2 => const Color(0xFF42A5F5), // Light blue
        3 => const Color(0xFF64B5F6), // Lighter blue
        4 => const Color(0xFF7E57C2), // Purple
        5 => const Color(0xFF9575CD), // Light purple
        6 => const Color(0xFFFFB300), // Gold
        7 => const Color(0xFFFFC107), // Amber
        _ => const Color(0xFFFF6F00), // Orange
      };
    }
  }

  /// Get description for rank
  String _getRankDescription(ShogiRank rank) {
    if (rank is _KyuRank) {
      return '初心者レベル';
    } else {
      return switch ((rank as _DanRank).level) {
        1 => 'アマ初段相当',
        2 => 'アマ2段相当',
        3 => 'アマ3段相当',
        4 => 'アマ4段相当',
        5 => 'アマ5段相当',
        6 => 'アマ6段相当',
        7 => 'プロ同等',
        _ => 'マスター',
      };
    }
  }
}

/// Progress bar showing progression to next rank
class ShogiRankProgressBar extends StatelessWidget {
  final int currentRating;
  final double height;

  const ShogiRankProgressBar({
    Key? key,
    required this.currentRating,
    this.height = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = ShogiRankService.getProgressToNextRank(currentRating);
    final currentRank = ShogiRankService.calculateRank(currentRating);
    final nextRank = currentRank.nextRank();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (nextRank != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentRank.displayName(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.labelSmall,
                ),
                Text(
                  nextRank.displayName(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: height,
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
        if (nextRank == null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'マスタークラス達成！',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget showing comparison between two ranks
class ShogiRankComparison extends StatelessWidget {
  final String rank1String;
  final String player1Name;
  final String rank2String;
  final String player2Name;

  const ShogiRankComparison({
    Key? key,
    required this.rank1String,
    required this.player1Name,
    required this.rank2String,
    required this.player2Name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rank1 = ShogiRankService.parseRank(rank1String);
    final rank2 = ShogiRankService.parseRank(rank2String);
    final comparison = ShogiRankService.compareRanks(rank1, rank2);
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                player1Name,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: _getRankColor(rank1).withOpacity(0.2),
                  border: Border.all(color: _getRankColor(rank1)),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  rank1String,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getRankColor(rank1),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                comparison < 0
                    ? Icons.arrow_downward
                    : comparison > 0
                        ? Icons.arrow_upward
                        : Icons.drag_handle,
                size: 24,
                color: comparison < 0
                    ? Colors.red
                    : comparison > 0
                        ? Colors.green
                        : Colors.grey,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                player2Name,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: _getRankColor(rank2).withOpacity(0.2),
                  border: Border.all(color: _getRankColor(rank2)),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  rank2String,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getRankColor(rank2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getRankColor(ShogiRank rank) {
    if (rank is _KyuRank) {
      return switch ((rank as _KyuRank).level) {
        1 => const Color(0xFF4CAF50),
        <= 5 => const Color(0xFF66BB6A),
        <= 10 => const Color(0xFF81C784),
        <= 15 => const Color(0xFFA5D6A7),
        _ => const Color(0xFFC8E6C9),
      };
    } else {
      return switch ((rank as _DanRank).level) {
        1 => const Color(0xFF2196F3),
        2 => const Color(0xFF42A5F5),
        3 => const Color(0xFF64B5F6),
        4 => const Color(0xFF7E57C2),
        5 => const Color(0xFF9575CD),
        6 => const Color(0xFFFFB300),
        7 => const Color(0xFFFFC107),
        _ => const Color(0xFFFF6F00),
      };
    }
  }
}
