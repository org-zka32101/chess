import 'package:freezed_annotation/freezed_annotation.dart';

part 'shogi_rank_service.freezed.dart';
part 'shogi_rank_service.g.dart';

/// Shogi dan/kyu rank with ELO mapping
@freezed
class ShogiRank with _$ShogiRank {
  // Kyu ranks (1級 to 20級)
  const factory ShogiRank.kyu(int level) = _KyuRank;

  // Dan ranks (1段 to 8段)
  const factory ShogiRank.dan(int level) = _DanRank;

  /// Display name (e.g., "5級", "3段")
  String displayName() {
    if (this is _KyuRank) {
      final kyu = this as _KyuRank;
      return '${kyu.level}級';
    } else {
      final dan = this as _DanRank;
      return dan.level == 1 ? '初段' : '${dan.level}段';
    }
  }

  /// Get kyu level, or -1 if dan
  int? kyu() {
    if (this is _KyuRank) {
      return (this as _KyuRank).level;
    }
    return null;
  }

  /// Get dan level, or -1 if kyu
  int? dan() {
    if (this is _DanRank) {
      return (this as _DanRank).level;
    }
    return null;
  }

  /// Get detailed description
  String getDescription() {
    return displayName();
  }

  /// Progress to next rank (returns null if already at 8段)
  ShogiRank? nextRank() {
    if (this is _KyuRank) {
      final kyu = (this as _KyuRank).level;
      if (kyu == 1) {
        return const ShogiRank.dan(1); // 初段
      }
      return ShogiRank.kyu(kyu - 1);
    } else {
      final dan = (this as _DanRank).level;
      if (dan < 8) {
        return ShogiRank.dan(dan + 1);
      }
      return null; // Already at top
    }
  }

  factory ShogiRank.fromJson(Map<String, dynamic> json) =>
      _$ShogiRankFromJson(json);
}

/// Service for managing shogi rank conversions
class ShogiRankService {
  /// ELO rating thresholds for shogi ranks
  static const Map<int, int> _rankThresholds = {
    // 級 (kyu) - ascending numbers, descending skill
    20: 0,      // 20級
    19: 100,    // 19級
    18: 200,    // 18級
    17: 300,    // 17級
    16: 400,    // 16級
    15: 500,    // 15級
    14: 600,    // 14級
    13: 700,    // 13級
    12: 800,    // 12級
    11: 900,    // 11級
    10: 1000,   // 10級
    9: 1100,    // 9級
    8: 1200,    // 8級
    7: 1300,    // 7級
    6: 1400,    // 6級
    5: 1500,    // 5級
    4: 1600,    // 4級
    3: 1700,    // 3級
    2: 1800,    // 2級
    1: 1900,    // 1級
    // 段 (dan) - ascending numbers, ascending skill
    0: 2000,    // 初段 (1st dan)
    // Note: higher dan levels require even higher ratings
  };

  /// Calculate ShogiRank from ELO rating
  ///
  /// Mapping:
  /// - 0-499: 20級
  /// - 500-599: 19級
  /// - ... (progressive)
  /// - 1900+: 初段 (1st dan) and up
  static ShogiRank calculateRank(int eloRating) {
    if (eloRating >= 2400) return const ShogiRank.dan(8);   // 8段
    if (eloRating >= 2200) return const ShogiRank.dan(7);   // 7段
    if (eloRating >= 2000) return const ShogiRank.dan(6);   // 6段
    if (eloRating >= 1900) return const ShogiRank.dan(5);   // 5段
    if (eloRating >= 1800) return const ShogiRank.dan(4);   // 4段
    if (eloRating >= 1700) return const ShogiRank.dan(3);   // 3段
    if (eloRating >= 1600) return const ShogiRank.dan(2);   // 2段
    if (eloRating >= 1500) return const ShogiRank.dan(1);   // 初段
    if (eloRating >= 1400) return const ShogiRank.kyu(1);   // 1級
    if (eloRating >= 1300) return const ShogiRank.kyu(2);   // 2級
    if (eloRating >= 1200) return const ShogiRank.kyu(3);   // 3級
    if (eloRating >= 1100) return const ShogiRank.kyu(4);   // 4級
    if (eloRating >= 1000) return const ShogiRank.kyu(5);   // 5級
    if (eloRating >= 900) return const ShogiRank.kyu(6);    // 6級
    if (eloRating >= 800) return const ShogiRank.kyu(7);    // 7級
    if (eloRating >= 700) return const ShogiRank.kyu(8);    // 8級
    if (eloRating >= 600) return const ShogiRank.kyu(9);    // 9級
    if (eloRating >= 500) return const ShogiRank.kyu(10);   // 10級
    if (eloRating >= 400) return const ShogiRank.kyu(11);   // 11級
    if (eloRating >= 300) return const ShogiRank.kyu(12);   // 12級
    if (eloRating >= 200) return const ShogiRank.kyu(13);   // 13級
    if (eloRating >= 100) return const ShogiRank.kyu(14);   // 14級
    return const ShogiRank.kyu(20); // 20級 (minimum)
  }

  /// Parse rank string (e.g., "5級", "3段", "初段")
  static ShogiRank parseRank(String rankString) {
    if (rankString.contains('段')) {
      if (rankString == '初段') {
        return const ShogiRank.dan(1);
      }
      final level = int.tryParse(rankString.replaceAll('段', '')) ?? 1;
      return ShogiRank.dan(level);
    } else if (rankString.contains('級')) {
      final level = int.tryParse(rankString.replaceAll('級', '')) ?? 20;
      return ShogiRank.kyu(level);
    }
    return const ShogiRank.dan(1); // Default: 1st dan
  }

  /// Get ELO range for a rank
  static (int, int) getRatingRange(ShogiRank rank) {
    if (rank is _KyuRank) {
      final level = rank.level;
      final min = switch (level) {
        1 => 1400,
        2 => 1300,
        3 => 1200,
        4 => 1100,
        5 => 1000,
        6 => 900,
        7 => 800,
        8 => 700,
        9 => 600,
        10 => 500,
        11 => 400,
        12 => 300,
        13 => 200,
        14 => 100,
        _ => 0,
      };
      return (min, min + 99);
    } else {
      final level = (rank as _DanRank).level;
      final min = switch (level) {
        1 => 1500,
        2 => 1600,
        3 => 1700,
        4 => 1800,
        5 => 1900,
        6 => 2000,
        7 => 2200,
        _ => 2400,
      };
      return (min, min + 199);
    }
  }

  /// Get progress to next rank (0.0 to 1.0)
  static double getProgressToNextRank(int eloRating) {
    final currentRank = calculateRank(eloRating);
    final (minElo, maxElo) = getRatingRange(currentRank);

    if (eloRating < minElo) return 0.0;
    if (eloRating > maxElo) return 1.0;

    return (eloRating - minElo) / (maxElo - minElo + 1);
  }

  /// Check if two ranks are the same
  static bool isSameRank(ShogiRank a, ShogiRank b) {
    if (a is _KyuRank && b is _KyuRank) {
      return a.level == b.level;
    } else if (a is _DanRank && b is _DanRank) {
      return a.level == b.level;
    }
    return false;
  }

  /// Compare two ranks (-1: a < b, 0: a == b, 1: a > b)
  static int compareRanks(ShogiRank a, ShogiRank b) {
    final aElo = _rankThresholds[a is _KyuRank ? (a as _KyuRank).level : -(a as _DanRank).level] ?? 1500;
    final bElo = _rankThresholds[b is _KyuRank ? (b as _KyuRank).level : -(b as _DanRank).level] ?? 1500;

    if (aElo < bElo) return -1;
    if (aElo > bElo) return 1;
    return 0;
  }
}
