import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ranking_service.freezed.dart';
part 'ranking_service.g.dart';

/// ランキング情報とユーザーの位置情報
@freezed
class RankingEntry with _$RankingEntry {
  const factory RankingEntry({
    required String uid,
    required String displayName,
    required String? photoUrl,
    required int rating,
    required String shogiRankString,
    required int gamesPlayed,
    required double winRate,
    required int rank,
    required DateTime? lastGameAt,
  }) = _RankingEntry;

  factory RankingEntry.fromJson(Map<String, dynamic> json) =>
      _$RankingEntryFromJson(json);
}

/// ランキング統計
@freezed
class RankingStats with _$RankingStats {
  const factory RankingStats({
    required int totalPlayers,
    required double averageRating,
    required int topRating,
    required DateTime lastUpdated,
  }) = _RankingStats;

  factory RankingStats.fromJson(Map<String, dynamic> json) =>
      _$RankingStatsFromJson(json);
}

/// ランキングサービス - Firestore ランキング管理
class RankingService {
  final FirebaseFirestore _firestore;
  static const String _rankingsCollection = 'rankings';
  static const String _statsCollection = 'ranking_stats';

  RankingService(this._firestore);

  /// ユーザーのランキングを更新 (ゲーム後に呼び出し)
  Future<void> updateUserRanking({
    required String uid,
    required String displayName,
    required String? photoUrl,
    required int rating,
    required String shogiRankString,
    required int gamesPlayed,
    required int wins,
    required int losses,
    required int draws,
  }) async {
    try {
      final winRate = gamesPlayed > 0 ? wins / gamesPlayed : 0.0;

      // グローバルランキングに追加
      await _firestore
          .collection(_rankingsCollection)
          .doc('global')
          .collection('players')
          .doc(uid)
          .set({
        'uid': uid,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'rating': rating,
        'shogiRankString': shogiRankString,
        'gamesPlayed': gamesPlayed,
        'wins': wins,
        'losses': losses,
        'draws': draws,
        'winRate': winRate,
        'lastGameAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 段位別ランキングに追加
      await _firestore
          .collection(_rankingsCollection)
          .doc('byShogi')
          .collection(shogiRankString)
          .doc(uid)
          .set({
        'uid': uid,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'rating': rating,
        'shogiRankString': shogiRankString,
        'gamesPlayed': gamesPlayed,
        'winRate': winRate,
        'lastGameAt': FieldValue.serverTimestamp(),
      });

      // 月間ランキングに追加
      final now = DateTime.now();
      final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';

      await _firestore
          .collection(_rankingsCollection)
          .doc('monthly')
          .collection(monthKey)
          .doc(uid)
          .set({
        'uid': uid,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'rating': rating,
        'shogiRankString': shogiRankString,
        'gamesPlayed': gamesPlayed,
        'winRate': winRate,
        'monthlyGames': FieldValue.increment(1),
        'monthlyWins': FieldValue.increment(wins > 0 ? 1 : 0),
      }, SetOptions(merge: true));

      // ランキング統計を更新
      await _updateRankingStats();
    } catch (e) {
      throw Exception('Failed to update user ranking: $e');
    }
  }

  /// グローバルランキングを取得
  Future<List<RankingEntry>> getGlobalRanking({
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_rankingsCollection)
          .doc('global')
          .collection('players')
          .orderBy('rating', descending: true)
          .limit(limit)
          .offset(offset)
          .get();

      final rankings = <RankingEntry>[];
      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();

        rankings.add(RankingEntry(
          uid: data['uid'] as String,
          displayName: data['displayName'] as String,
          photoUrl: data['photoUrl'] as String?,
          rating: data['rating'] as int,
          shogiRankString: data['shogiRankString'] as String,
          gamesPlayed: data['gamesPlayed'] as int,
          winRate: (data['winRate'] as num).toDouble(),
          rank: offset + i + 1,
          lastGameAt: data['lastGameAt'] != null
              ? (data['lastGameAt'] as Timestamp).toDate()
              : null,
        ));
      }

      return rankings;
    } catch (e) {
      throw Exception('Failed to fetch global ranking: $e');
    }
  }

  /// ユーザーのランキング位置を取得
  Future<int?> getUserRank(String uid) async {
    try {
      final userDoc = await _firestore
          .collection(_rankingsCollection)
          .doc('global')
          .collection('players')
          .doc(uid)
          .get();

      if (!userDoc.exists) return null;

      final userRating = userDoc['rating'] as int;

      // ユーザーより高いレーティングを持つユーザーの数を数える
      final higherRatingCount = await _firestore
          .collection(_rankingsCollection)
          .doc('global')
          .collection('players')
          .where('rating', isGreaterThan: userRating)
          .count()
          .get();

      return higherRatingCount.count + 1;
    } catch (e) {
      throw Exception('Failed to fetch user rank: $e');
    }
  }

  /// 段位別ランキングを取得
  Future<List<RankingEntry>> getRankingByShogi(
    String shogiRank, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_rankingsCollection)
          .doc('byShogi')
          .collection(shogiRank)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      final rankings = <RankingEntry>[];
      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();

        rankings.add(RankingEntry(
          uid: data['uid'] as String,
          displayName: data['displayName'] as String,
          photoUrl: data['photoUrl'] as String?,
          rating: data['rating'] as int,
          shogiRankString: shogiRank,
          gamesPlayed: data['gamesPlayed'] as int,
          winRate: (data['winRate'] as num).toDouble(),
          rank: i + 1,
          lastGameAt: data['lastGameAt'] != null
              ? (data['lastGameAt'] as Timestamp).toDate()
              : null,
        ));
      }

      return rankings;
    } catch (e) {
      throw Exception('Failed to fetch shogi ranking: $e');
    }
  }

  /// 月間ランキングを取得
  Future<List<RankingEntry>> getMonthlyRanking({
    int limit = 50,
    String? monthKey,
  }) async {
    try {
      final now = DateTime.now();
      final month = monthKey ?? '${now.year}-${now.month.toString().padLeft(2, '0')}';

      final snapshot = await _firestore
          .collection(_rankingsCollection)
          .doc('monthly')
          .collection(month)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      final rankings = <RankingEntry>[];
      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();

        rankings.add(RankingEntry(
          uid: data['uid'] as String,
          displayName: data['displayName'] as String,
          photoUrl: data['photoUrl'] as String?,
          rating: data['rating'] as int,
          shogiRankString: data['shogiRankString'] as String,
          gamesPlayed: data['gamesPlayed'] as int,
          winRate: (data['winRate'] as num).toDouble(),
          rank: i + 1,
          lastGameAt: null,
        ));
      }

      return rankings;
    } catch (e) {
      throw Exception('Failed to fetch monthly ranking: $e');
    }
  }

  /// ランキング周辺のプレイヤーを取得
  Future<List<RankingEntry>> getNearbyRankings(
    String uid, {
    int proximityCount = 5,
  }) async {
    try {
      final userRank = await getUserRank(uid);
      if (userRank == null) return [];

      final startRank = (userRank - proximityCount - 1).clamp(0, 999999);
      final allRankings = await getGlobalRanking(
        limit: proximityCount * 2 + 1,
        offset: startRank,
      );

      return allRankings;
    } catch (e) {
      throw Exception('Failed to fetch nearby rankings: $e');
    }
  }

  /// ランキング統計を取得
  Future<RankingStats?> getRankingStats() async {
    try {
      final doc = await _firestore
          .collection(_statsCollection)
          .doc('global')
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return RankingStats(
        totalPlayers: data['totalPlayers'] as int,
        averageRating: (data['averageRating'] as num).toDouble(),
        topRating: data['topRating'] as int,
        lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      );
    } catch (e) {
      throw Exception('Failed to fetch ranking stats: $e');
    }
  }

  /// ランキング統計を更新
  Future<void> _updateRankingStats() async {
    try {
      final snapshot = await _firestore
          .collection(_rankingsCollection)
          .doc('global')
          .collection('players')
          .get();

      if (snapshot.docs.isEmpty) return;

      final ratings = snapshot.docs
          .map((doc) => (doc['rating'] as int))
          .toList();

      final averageRating =
          ratings.reduce((a, b) => a + b) / ratings.length;
      final topRating = ratings.reduce((a, b) => a > b ? a : b);

      await _firestore
          .collection(_statsCollection)
          .doc('global')
          .set({
        'totalPlayers': snapshot.docs.length,
        'averageRating': averageRating,
        'topRating': topRating,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating ranking stats: $e');
    }
  }

  /// ランキングをリアルタイム監視
  Stream<List<RankingEntry>> watchGlobalRanking({int limit = 100}) {
    return _firestore
        .collection(_rankingsCollection)
        .doc('global')
        .collection('players')
        .orderBy('rating', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final rankings = <RankingEntry>[];
      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();

        rankings.add(RankingEntry(
          uid: data['uid'] as String,
          displayName: data['displayName'] as String,
          photoUrl: data['photoUrl'] as String?,
          rating: data['rating'] as int,
          shogiRankString: data['shogiRankString'] as String,
          gamesPlayed: data['gamesPlayed'] as int,
          winRate: (data['winRate'] as num).toDouble(),
          rank: i + 1,
          lastGameAt: data['lastGameAt'] != null
              ? (data['lastGameAt'] as Timestamp).toDate()
              : null,
        ));
      }
      return rankings;
    });
  }

  /// ユーザーのランキング情報をリアルタイム監視
  Stream<RankingEntry?> watchUserRanking(String uid) {
    return _firestore
        .collection(_rankingsCollection)
        .doc('global')
        .collection('players')
        .doc(uid)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return null;

      final data = doc.data()!;
      final rank = await getUserRank(uid);

      return RankingEntry(
        uid: data['uid'] as String,
        displayName: data['displayName'] as String,
        photoUrl: data['photoUrl'] as String?,
        rating: data['rating'] as int,
        shogiRankString: data['shogiRankString'] as String,
        gamesPlayed: data['gamesPlayed'] as int,
        winRate: (data['winRate'] as num).toDouble(),
        rank: rank ?? 0,
        lastGameAt: data['lastGameAt'] != null
            ? (data['lastGameAt'] as Timestamp).toDate()
            : null,
      );
    });
  }
}
