import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chess/src/models/analytics_snapshot.dart';
import 'package:chess/src/models/match_record.dart';

/// Service for managing aggregated analytics
class AnalyticsService {
  final FirebaseFirestore _firestore;

  AnalyticsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get monthly analytics snapshot
  Future<AnalyticsSnapshot> getMonthlySnapshot(
    String playerId,
    int monthYear,
  ) async {
    try {
      final doc = await _firestore
          .collection('player_analytics')
          .doc(playerId)
          .collection('monthly')
          .doc(monthYear.toString())
          .get();

      if (doc.exists) {
        return AnalyticsSnapshot.fromJson(doc.data()!);
      }

      // Calculate from match history if not cached
      return _calculateMonthlySnapshot(playerId, monthYear);
    } catch (e) {
      throw Exception('Failed to get monthly snapshot: $e');
    }
  }

  /// Get aggregated analytics for multiple months
  Future<List<AnalyticsSnapshot>> getAnalyticsRange(
    String playerId,
    DateTime fromDate,
    DateTime toDate,
  ) async {
    try {
      final snapshots = <AnalyticsSnapshot>[];

      // Get month-year values for the range
      var current = DateTime(fromDate.year, fromDate.month);
      while (!current.isAfter(toDate)) {
        final monthYear = int.parse(
          '${current.year}${current.month.toString().padLeft(2, '0')}',
        );

        final snapshot = await getMonthlySnapshot(playerId, monthYear);
        snapshots.add(snapshot);

        // Move to next month
        current = DateTime(current.year, current.month + 1);
      }

      // Sort by date
      snapshots.sort((a, b) => a.monthYear.compareTo(b.monthYear));

      return snapshots;
    } catch (e) {
      throw Exception('Failed to get analytics range: $e');
    }
  }

  /// Stream analytics updates for current month
  Stream<AnalyticsSnapshot> watchCurrentMonthAnalytics(String playerId) {
    final now = DateTime.now();
    final monthYear = int.parse(
      '${now.year}${now.month.toString().padLeft(2, '0')}',
    );

    return _firestore
        .collection('player_analytics')
        .doc(playerId)
        .collection('monthly')
        .doc(monthYear.toString())
        .snapshots()
        .asyncMap((doc) async {
      if (doc.exists) {
        return AnalyticsSnapshot.fromJson(doc.data()!);
      }

      // Return calculated snapshot if not cached
      return _calculateMonthlySnapshot(playerId, monthYear);
    }).handleError((e) => throw Exception('Failed to watch current month analytics: $e'));
  }

  /// Compare analytics between players
  Future<Map<String, dynamic>> compareAnalytics(
    String player1Id,
    String player2Id,
  ) async {
    try {
      final now = DateTime.now();
      final monthYear = int.parse(
        '${now.year}${now.month.toString().padLeft(2, '0')}',
      );

      final player1Snapshot = await getMonthlySnapshot(player1Id, monthYear);
      final player2Snapshot = await getMonthlySnapshot(player2Id, monthYear);

      return {
        'player1': {
          'gamesPlayed': player1Snapshot.gamesPlayed,
          'wins': player1Snapshot.wins,
          'winRate': (player1Snapshot.gamesPlayed > 0
              ? player1Snapshot.wins / player1Snapshot.gamesPlayed * 100
              : 0.0),
          'ratingChange': player1Snapshot.ratingChange,
          'avgRatingGained': player1Snapshot.avgRatingGained,
        },
        'player2': {
          'gamesPlayed': player2Snapshot.gamesPlayed,
          'wins': player2Snapshot.wins,
          'winRate': (player2Snapshot.gamesPlayed > 0
              ? player2Snapshot.wins / player2Snapshot.gamesPlayed * 100
              : 0.0),
          'ratingChange': player2Snapshot.ratingChange,
          'avgRatingGained': player2Snapshot.avgRatingGained,
        },
      };
    } catch (e) {
      throw Exception('Failed to compare analytics: $e');
    }
  }

  /// Record monthly analytics
  Future<void> recordMonthlyAnalytics(
    String playerId,
    AnalyticsSnapshot snapshot,
  ) async {
    try {
      await _firestore
          .collection('player_analytics')
          .doc(playerId)
          .collection('monthly')
          .doc(snapshot.monthYear.toString())
          .set(snapshot.toJson());
    } catch (e) {
      throw Exception('Failed to record monthly analytics: $e');
    }
  }

  /// Calculate monthly snapshot from match history
  Future<AnalyticsSnapshot> _calculateMonthlySnapshot(
    String playerId,
    int monthYear,
  ) async {
    try {
      // Parse month and year
      final year = monthYear ~/ 100;
      final month = monthYear % 100;

      final fromDate = DateTime(year, month, 1);
      final toDate = DateTime(year, month + 1, 1).subtract(Duration(days: 1));

      // Fetch matches for this month
      final snapshot = await _firestore
          .collection('match_history')
          .doc(playerId)
          .collection('matches')
          .where('playedAt', isGreaterThanOrEqualTo: fromDate)
          .where('playedAt', isLessThanOrEqualTo: toDate)
          .get();

      int wins = 0;
      int losses = 0;
      int draws = 0;
      int totalRatingGained = 0;
      int totalRatingLost = 0;

      for (final doc in snapshot.docs) {
        final match = MatchRecord.fromJson(doc.data());

        switch (match.result) {
          case 'win':
            wins++;
            totalRatingGained += match.playerRatingAfter - match.playerRatingBefore;
            break;
          case 'loss':
            losses++;
            totalRatingLost +=
                match.playerRatingBefore - match.playerRatingAfter;
            break;
          case 'draw':
            draws++;
            break;
        }
      }

      final gamesPlayed = wins + losses + draws;
      final ratingChange = totalRatingGained - totalRatingLost;
      final avgRatingGained =
          wins > 0 ? totalRatingGained / wins : 0.0;
      final avgRatingLost =
          losses > 0 ? totalRatingLost / losses : 0.0;

      return AnalyticsSnapshot(
        playerId: playerId,
        monthYear: monthYear,
        gamesPlayed: gamesPlayed,
        wins: wins,
        losses: losses,
        draws: draws,
        ratingChange: ratingChange,
        avgRatingGained: avgRatingGained,
        avgRatingLost: avgRatingLost,
      );
    } catch (e) {
      throw Exception('Failed to calculate monthly snapshot: $e');
    }
  }

  /// Get performance trends (month-over-month comparison)
  Future<Map<String, dynamic>> getPerformanceTrends(
    String playerId,
    int months,
  ) async {
    try {
      final now = DateTime.now();
      final snapshots = <AnalyticsSnapshot>[];

      for (int i = 0; i < months; i++) {
        final month =
            DateTime(now.year, now.month - i, 1);
        final monthYear = int.parse(
          '${month.year}${month.month.toString().padLeft(2, '0')}',
        );

        try {
          final snapshot = await getMonthlySnapshot(playerId, monthYear);
          snapshots.add(snapshot);
        } catch (_) {
          // Skip if month doesn't have data
        }
      }

      // Calculate trends
      final winRates = <double>[];
      final ratingChanges = <int>[];

      for (final snapshot in snapshots) {
        if (snapshot.gamesPlayed > 0) {
          final winRate = snapshot.wins / snapshot.gamesPlayed * 100;
          winRates.add(winRate);
          ratingChanges.add(snapshot.ratingChange);
        }
      }

      // Calculate trend (simple: compare first and last)
      double winRateTrend = 0;
      int ratingTrend = 0;

      if (winRates.length >= 2) {
        winRateTrend = winRates.last - winRates.first;
      }

      if (ratingChanges.length >= 2) {
        ratingTrend = ratingChanges.last - ratingChanges.first;
      }

      return {
        'snapshots': snapshots,
        'winRateTrend': winRateTrend,
        'ratingTrend': ratingTrend,
        'averageWinRate':
            winRates.isNotEmpty ? winRates.reduce((a, b) => a + b) / winRates.length : 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get performance trends: $e');
    }
  }
}
