# Phase I: Player Comparison & Statistics System
## Comprehensive Design & Implementation Guide

**Date**: 2026-08-26  
**Phase**: I (Player Comparison & Statistics)  
**Status**: Design Complete - Ready for Implementation  
**Estimated Lines of Code**: 2,500-3,000

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Data Models](#data-models)
4. [Services](#services)
5. [Providers](#providers)
6. [UI Screens](#ui-screens)
7. [API Reference](#api-reference)
8. [Testing Strategy](#testing-strategy)
9. [Implementation Checklist](#implementation-checklist)

---

## Overview

Phase I extends the Phase H Leaderboard system with detailed player comparison and advanced statistics capabilities. This phase enables users to:

- **Compare Players**: Head-to-head statistics and matchup analysis
- **View Match History**: Complete game records with date, opponent, result, and rating change
- **Analyze Performance**: Win rate trends, rating progression, and seasonal statistics
- **Explore Matchups**: H2H records between specific players with detailed breakdowns

### Key Features

1. **Head-to-Head Comparison**
   - Win/loss/draw records between two players
   - Rating difference analysis
   - Performance metrics (win rate, average rating gained/lost)

2. **Match History**
   - Paginated game records with filtering (date range, opponent, result)
   - Detailed match information (time, opponent rating change, duration)
   - Export match data (CSV format)

3. **Performance Analytics**
   - Rating progression graphs (last 30/90/365 days)
   - Win rate by opponent rank
   - Monthly statistics and trends
   - Streak tracking (win/loss streaks)

4. **Advanced Statistics**
   - Performance by time control (bullet, blitz, rapid)
   - Opening repertoire analysis (for future integration)
   - Performance against specific ranks
   - Seasonal performance breakdowns

---

## Architecture

### System Diagram

```
┌─────────────────────────────────────────────────────────┐
│                  Player Comparison Layer                 │
├─────────────────────────────────────────────────────────┤
│  Comparison | Match History | Performance | Analytics  │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│            Comparison Service Layer                      │
├─────────────────────────────────────────────────────────┤
│  ComparisonService | MatchHistoryService |              │
│  PerformanceService | AnalyticsService                  │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│            Firestore Collections                         │
├─────────────────────────────────────────────────────────┤
│  games/ | match_history/ | performance_stats/ |         │
│  player_analytics/ | monthly_performance/               │
└─────────────────────────────────────────────────────────┘
```

### Key Components

1. **ComparisonService**
   - Manages player-to-player comparisons
   - Calculates head-to-head statistics
   - Tracks matchup history

2. **MatchHistoryService**
   - Retrieves and filters game records
   - Pagination support
   - Export functionality

3. **PerformanceService**
   - Calculates rating progression
   - Tracks win rate trends
   - Analyzes performance by opponent rank

4. **AnalyticsService**
   - Aggregates advanced statistics
   - Calculates streak information
   - Time-control analysis

---

## Data Models

### 1. MatchRecord (freezed)

```dart
@freezed
class MatchRecord with _$MatchRecord {
  const factory MatchRecord({
    required String matchId,
    required String playerId,
    required String opponentId,
    required String opponentName,
    required int playerRatingBefore,
    required int playerRatingAfter,
    required int opponentRatingBefore,
    required int opponentRatingAfter,
    required String result, // 'win', 'loss', 'draw'
    required String timeControl, // 'bullet', 'blitz', 'rapid'
    required DateTime playedAt,
    int? duration, // seconds
    String? pgn, // For future chess analysis
  }) = _MatchRecord;

  factory MatchRecord.fromJson(Map<String, dynamic> json) =>
      _$MatchRecordFromJson(json);
}
```

### 2. HeadToHeadStats (freezed)

```dart
@freezed
class HeadToHeadStats with _$HeadToHeadStats {
  const factory HeadToHeadStats({
    required String player1Id,
    required String player2Id,
    required int player1Wins,
    required int player2Wins,
    required int draws,
    required double player1WinRate,
    required double player2WinRate,
    required int ratingDifference, // player1 - player2
    required DateTime lastMatch,
    required List<MatchRecord> recentMatches, // last 10
  }) = _HeadToHeadStats;

  factory HeadToHeadStats.fromJson(Map<String, dynamic> json) =>
      _$HeadToHeadStatsFromJson(json);
}
```

### 3. RatingProgression (freezed)

```dart
@freezed
class RatingProgression with _$RatingProgression {
  const factory RatingProgression({
    required DateTime date,
    required int rating,
    required int gamesPlayed,
    required double winRate,
  }) = _RatingProgression;

  factory RatingProgression.fromJson(Map<String, dynamic> json) =>
      _$RatingProgressionFromJson(json);
}
```

### 4. PerformanceStats (freezed)

```dart
@freezed
class PerformanceStats with _$PerformanceStats {
  const factory PerformanceStats({
    required String playerId,
    required List<RatingProgression> progressionLast30Days,
    required List<RatingProgression> progressionLast90Days,
    required int currentStreak, // positive = wins, negative = losses
    required int longestWinStreak,
    required int longestLossStreak,
    required Map<String, int> performanceByRank, // e.g., "3段": 65 (win %)
    required Map<String, int> performanceByTimeControl,
    required DateTime updatedAt,
  }) = _PerformanceStats;

  factory PerformanceStats.fromJson(Map<String, dynamic> json) =>
      _$PerformanceStatsFromJson(json);
}
```

### 5. AnalyticsSnapshot (freezed)

```dart
@freezed
class AnalyticsSnapshot with _$AnalyticsSnapshot {
  const factory AnalyticsSnapshot({
    required String playerId,
    required int monthYear, // e.g., 202608 for Aug 2026
    required int gamesPlayed,
    required int wins,
    required int losses,
    required int draws,
    required int ratingChange,
    required double avgRatingGained,
    required double avgRatingLost,
  }) = _AnalyticsSnapshot;

  factory AnalyticsSnapshot.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsSnapshotFromJson(json);
}
```

---

## Services

### ComparisonService

```dart
class ComparisonService {
  // Get head-to-head statistics between two players
  Future<HeadToHeadStats> getHeadToHeadStats(
    String player1Id,
    String player2Id,
  );

  // Stream head-to-head stats for real-time updates
  Stream<HeadToHeadStats> watchHeadToHeadStats(
    String player1Id,
    String player2Id,
  );

  // Get recent matches between two players
  Future<List<MatchRecord>> getRecentMatches(
    String player1Id,
    String player2Id, {
    int limit = 10,
  });

  // Calculate win probability based on rating difference
  double calculateWinProbability(int ratingDiff);
}
```

**Firestore Collections**:
- `player_matchups/{player1Id}_{player2Id}/`
  - `h2hStats`: Head-to-head statistics
  - `recentMatches/`: Recent match documents (one per match)

### MatchHistoryService

```dart
class MatchHistoryService {
  // Get paginated match history for a player
  Future<List<MatchRecord>> getMatchHistory(
    String playerId, {
    int limit = 50,
    DocumentSnapshot? startAfter,
  });

  // Stream match history updates
  Stream<List<MatchRecord>> watchMatchHistory(String playerId);

  // Filter matches by criteria
  Future<List<MatchRecord>> filterMatches(
    String playerId, {
    DateTime? fromDate,
    DateTime? toDate,
    String? opponentId,
    String? result, // 'win', 'loss', 'draw'
    String? timeControl,
  });

  // Export match history as CSV
  Future<String> exportMatchHistoryAsCSV(String playerId);

  // Get match statistics for a specific opponent
  Future<Map<String, int>> getStatsVsOpponent(
    String playerId,
    String opponentId,
  );
}
```

**Firestore Collections**:
- `match_history/{playerId}/matches/`
  - One document per match with indexed fields for filtering
  - Indexed by: playedAt, opponentId, result, timeControl

### PerformanceService

```dart
class PerformanceService {
  // Get rating progression for different time ranges
  Future<List<RatingProgression>> getRatingProgression(
    String playerId, {
    required int days, // 30, 90, or 365
  });

  // Stream rating progression updates
  Stream<List<RatingProgression>> watchRatingProgression(
    String playerId, {
    required int days,
  });

  // Calculate current win rate
  Future<double> getWinRate(String playerId);

  // Get performance by opponent rank
  Future<Map<String, int>> getPerformanceByRank(String playerId);

  // Get performance by time control
  Future<Map<String, int>> getPerformanceByTimeControl(String playerId);

  // Calculate streak information
  Future<StreakInfo> getStreakInfo(String playerId);
}
```

**Firestore Collections**:
- `performance_stats/{playerId}/`
  - `progression_30days/`: Daily rating snapshots
  - `progression_90days/`: Daily rating snapshots
  - `byRankPerformance/`: Performance metrics by opponent rank
  - `byTimeControlPerformance/`: Performance by time control

### AnalyticsService

```dart
class AnalyticsService {
  // Get monthly analytics snapshot
  Future<AnalyticsSnapshot> getMonthlySnapshot(
    String playerId,
    int monthYear,
  );

  // Get aggregated analytics for multiple months
  Future<List<AnalyticsSnapshot>> getAnalyticsRange(
    String playerId,
    DateTime fromDate,
    DateTime toDate,
  );

  // Stream analytics updates
  Stream<AnalyticsSnapshot> watchCurrentMonthAnalytics(String playerId);

  // Compare analytics between players
  Future<Map<String, dynamic>> compareAnalytics(
    String player1Id,
    String player2Id,
  );
}
```

**Firestore Collections**:
- `player_analytics/{playerId}/monthly/`
  - One document per month (e.g., 202608)
  - Aggregated statistics

---

## Providers

### leaderboard_comparison_provider.dart

```dart
// State class for comparison
class ComparisonState {
  final HeadToHeadStats? stats;
  final List<MatchRecord> matches;
  final bool isLoading;
  final String? error;

  ComparisonState({...});
}

// Provider for head-to-head comparison
final headToHeadStatsProvider = StreamProvider.family<
  HeadToHeadStats,
  ({String player1Id, String player2Id})
>(
  (ref, params) async* {
    final service = ref.watch(comparisonServiceProvider);
    yield* service.watchHeadToHeadStats(
      params.player1Id,
      params.player2Id,
    );
  },
);

// Provider for recent matches between players
final recentMatchesProvider = FutureProvider.family<
  List<MatchRecord>,
  ({String player1Id, String player2Id})
>(
  (ref, params) async {
    final service = ref.watch(comparisonServiceProvider);
    return service.getRecentMatches(
      params.player1Id,
      params.player2Id,
    );
  },
);
```

### match_history_provider.dart

```dart
// Provider for match history with pagination
final matchHistoryProvider = StateNotifierProvider<
  MatchHistoryNotifier,
  AsyncValue<List<MatchRecord>>
>(
  (ref) => MatchHistoryNotifier(ref.watch(matchHistoryServiceProvider)),
);

class MatchHistoryNotifier extends StateNotifier<AsyncValue<List<MatchRecord>>> {
  final MatchHistoryService _service;

  MatchHistoryNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> loadHistory(String playerId) async {
    state = await AsyncValue.guard(() =>
      _service.getMatchHistory(playerId),
    );
  }

  Future<void> loadMore(String playerId) async {
    // Pagination logic
  }

  Future<void> filterMatches({
    required String playerId,
    DateTime? fromDate,
    DateTime? toDate,
    String? opponentId,
    String? result,
    String? timeControl,
  }) async {
    state = await AsyncValue.guard(() =>
      _service.filterMatches(
        playerId,
        fromDate: fromDate,
        toDate: toDate,
        opponentId: opponentId,
        result: result,
        timeControl: timeControl,
      ),
    );
  }
}
```

### performance_analytics_provider.dart

```dart
// Provider for rating progression
final ratingProgressionProvider = StreamProvider.family<
  List<RatingProgression>,
  ({String playerId, int days})
>(
  (ref, params) async* {
    final service = ref.watch(performanceServiceProvider);
    yield* service.watchRatingProgression(
      params.playerId,
      days: params.days,
    );
  },
);

// Provider for performance statistics
final performanceStatsProvider = FutureProvider.family<
  PerformanceStats,
  String
>(
  (ref, playerId) async {
    final service = ref.watch(performanceServiceProvider);
    
    final progression30 = await service.getRatingProgression(
      playerId,
      days: 30,
    );
    final byRank = await service.getPerformanceByRank(playerId);
    final byTimeControl = await service.getPerformanceByTimeControl(playerId);
    final streak = await service.getStreakInfo(playerId);

    return PerformanceStats(
      playerId: playerId,
      progressionLast30Days: progression30,
      progressionLast90Days: [],
      currentStreak: streak.current,
      longestWinStreak: streak.longestWin,
      longestLossStreak: streak.longestLoss,
      performanceByRank: byRank,
      performanceByTimeControl: byTimeControl,
      updatedAt: DateTime.now(),
    );
  },
);
```

---

## UI Screens

### 1. PlayerComparisonScreen

**Purpose**: Display head-to-head comparison between two players

**Components**:
- Header with both player names and ratings
- H2H statistics card (wins, losses, draws, win rates)
- Recent matches list
- Win probability indicator
- Navigation tabs for different views

**Widgets**:
- `ComparisonHeader`: Shows both players with avatars and ratings
- `H2HStatsCard`: Displays head-to-head statistics
- `RecentMatchesList`: Paginated list of recent matches
- `WinProbabilityIndicator`: Visual indicator of win probability

### 2. MatchHistoryScreen

**Purpose**: Display paginated match history with filtering

**Components**:
- Filter controls (date range, opponent, result, time control)
- Paginated match list
- Match detail view
- Export button
- Search functionality

**Widgets**:
- `MatchFilterBar`: Filter controls
- `MatchHistoryList`: Paginated match list
- `MatchCard`: Individual match display
- `MatchDetailSheet`: Detailed match information

### 3. PerformanceAnalyticsScreen

**Purpose**: Display rating progression and performance trends

**Components**:
- Rating progression chart (30/90/365 days)
- Win rate chart
- Streak information
- Performance by opponent rank table
- Performance by time control table
- Monthly statistics

**Widgets**:
- `RatingProgressionChart`: Line chart showing rating changes
- `PerformanceBreakdown`: Performance statistics by category
- `StreakIndicator`: Current and longest streaks
- `PerformanceTable`: Table showing performance by rank

### 4. ComparisonListScreen

**Purpose**: Browse and compare multiple players

**Components**:
- Search/filter player list
- Quick comparison mode (select 2+ players)
- Comparison matrix
- Sort by rating, name, or recency

---

## API Reference

### ComparisonService Methods

#### `getHeadToHeadStats(player1Id, player2Id)`
- **Returns**: `Future<HeadToHeadStats>`
- **Throws**: `FirebaseException` on database error
- **Description**: Retrieves cached or computed H2H statistics

#### `watchHeadToHeadStats(player1Id, player2Id)`
- **Returns**: `Stream<HeadToHeadStats>`
- **Description**: Real-time stream of H2H statistics

#### `calculateWinProbability(ratingDiff)`
- **Parameters**: `ratingDiff` (int) - Rating difference (player1 - player2)
- **Returns**: `double` (0.0 to 1.0)
- **Formula**: Using ELO probability: P = 1 / (1 + 10^(-ratingDiff/400))

### MatchHistoryService Methods

#### `getMatchHistory(playerId, {limit, startAfter})`
- **Returns**: `Future<List<MatchRecord>>`
- **Parameters**:
  - `playerId`: Player identifier
  - `limit`: Number of matches per page (default: 50)
  - `startAfter`: Pagination cursor (last document)

#### `filterMatches(playerId, {...})`
- **Returns**: `Future<List<MatchRecord>>`
- **Parameters**:
  - `fromDate`: Start date filter
  - `toDate`: End date filter
  - `opponentId`: Filter by specific opponent
  - `result`: 'win', 'loss', or 'draw'
  - `timeControl`: 'bullet', 'blitz', 'rapid'

### PerformanceService Methods

#### `getRatingProgression(playerId, days)`
- **Returns**: `Future<List<RatingProgression>>`
- **Parameters**: `days` - 30, 90, or 365
- **Description**: Gets daily rating snapshots for the specified period

#### `getStreakInfo(playerId)`
- **Returns**: `Future<StreakInfo>`
- **Contains**:
  - `current`: Current streak (+ for wins, - for losses)
  - `longestWin`: Longest winning streak
  - `longestLoss`: Longest losing streak

---

## Testing Strategy

### Unit Tests (test/services/)

1. **test/services/comparison_service_test.dart**
   - H2H stats calculation
   - Win probability calculation
   - Matchup history retrieval
   - Mock Firestore data

2. **test/services/match_history_service_test.dart**
   - Match filtering (date, opponent, result)
   - Pagination logic
   - CSV export generation
   - Edge cases (empty history, single match)

3. **test/services/performance_service_test.dart**
   - Rating progression calculation
   - Win rate calculation
   - Streak detection
   - Performance by rank/time control

### Widget Tests (test/screens/)

1. **test/screens/player_comparison_screen_test.dart**
   - Header rendering with both players
   - H2H statistics display
   - Recent matches list
   - Navigation between tabs

2. **test/screens/match_history_screen_test.dart**
   - Filter controls interaction
   - Pagination controls
   - Match card rendering
   - Empty state handling

3. **test/screens/performance_analytics_screen_test.dart**
   - Chart rendering
   - Performance breakdown display
   - Streak information display
   - Monthly statistics table

### Integration Tests (integration_test/)

1. **integration_test/comparison_flow_test.dart**
   - Select two players from leaderboard
   - View comparison screen
   - Navigate to match history
   - Apply filters and verify results

2. **integration_test/analytics_flow_test.dart**
   - View own performance analytics
   - Select different time ranges
   - View performance breakdowns
   - Export match history

---

## Implementation Checklist

### Data Models (Freezed)
- [ ] Create `match_record.dart`
- [ ] Create `head_to_head_stats.dart`
- [ ] Create `rating_progression.dart`
- [ ] Create `performance_stats.dart`
- [ ] Create `analytics_snapshot.dart`
- [ ] Run build_runner to generate freezed code

### Services
- [ ] Implement `comparison_service.dart`
- [ ] Implement `match_history_service.dart`
- [ ] Implement `performance_service.dart`
- [ ] Implement `analytics_service.dart`
- [ ] Create service providers

### Providers
- [ ] Create `comparison_provider.dart`
- [ ] Create `match_history_provider.dart`
- [ ] Create `performance_analytics_provider.dart`
- [ ] Test provider integration

### UI Screens
- [ ] Create `player_comparison_screen.dart`
- [ ] Create `match_history_screen.dart`
- [ ] Create `performance_analytics_screen.dart`
- [ ] Create comparison widgets
- [ ] Create performance charts
- [ ] Add navigation integration

### Testing
- [ ] Write service unit tests (4 files)
- [ ] Write screen widget tests (3 files)
- [ ] Write integration tests (2 files)
- [ ] Achieve 70%+ code coverage

### Documentation
- [ ] Add PLAYER_COMPARISON_GUIDE.md
- [ ] Document API usage
- [ ] Add code comments
- [ ] Update main README.md

---

## File Structure

```
lib/src/
├── models/
│   ├── match_record.dart
│   ├── head_to_head_stats.dart
│   ├── rating_progression.dart
│   ├── performance_stats.dart
│   └── analytics_snapshot.dart
├── services/
│   ├── comparison_service.dart
│   ├── match_history_service.dart
│   ├── performance_service.dart
│   └── analytics_service.dart
├── providers/
│   ├── comparison_provider.dart
│   ├── match_history_provider.dart
│   └── performance_analytics_provider.dart
├── screens/
│   ├── comparison/
│   │   ├── player_comparison_screen.dart
│   │   ├── comparison_list_screen.dart
│   │   └── comparison_widgets.dart
│   └── analytics/
│       ├── match_history_screen.dart
│       ├── performance_analytics_screen.dart
│       └── analytics_widgets.dart
└── widgets/
    ├── charts/
    │   ├── rating_progression_chart.dart
    │   ├── win_rate_chart.dart
    │   └── performance_chart.dart
    ├── comparison/
    │   ├── h2h_stats_card.dart
    │   ├── recent_matches_list.dart
    │   └── win_probability_indicator.dart
    └── analytics/
        ├── performance_breakdown.dart
        ├── streak_indicator.dart
        └── performance_table.dart

test/
├── services/
│   ├── comparison_service_test.dart
│   ├── match_history_service_test.dart
│   ├── performance_service_test.dart
│   └── analytics_service_test.dart
└── screens/
    ├── player_comparison_screen_test.dart
    ├── match_history_screen_test.dart
    └── performance_analytics_screen_test.dart

integration_test/
├── comparison_flow_test.dart
└── analytics_flow_test.dart
```

---

## Dependencies

Required packages (already available):
- `freezed_annotation`
- `json_serializable`
- `riverpod`
- `flutter_riverpod`
- `firebase_firestore`
- `fl_chart` (for charts)
- `intl` (for date formatting)

---

## Performance Considerations

1. **Caching Strategy**
   - Cache H2H stats for 24 hours
   - Cache performance stats for 1 hour
   - Use Firestore snapshots for real-time updates

2. **Query Optimization**
   - Index `match_history` by playedAt, opponentId, result
   - Use composite indexes for multi-field filters
   - Paginate match history (50 per page)

3. **UI Performance**
   - Lazy-load charts for performance analytics
   - Virtual scrolling for long match lists
   - Debounce filter changes (500ms)

---

## Error Handling

1. **Network Errors**
   - Display user-friendly error messages
   - Implement retry logic with exponential backoff
   - Show cached data when offline

2. **Data Errors**
   - Validate match records before display
   - Handle missing opponent data gracefully
   - Log errors for monitoring

3. **UI Errors**
   - Show empty states for no matches
   - Display loading states during data fetch
   - Graceful degradation for unavailable features

---

## Security Considerations

1. **Firestore Rules**
   ```javascript
   match /player_matchups/{matchup} {
     allow read: if request.auth != null;
     allow write: if request.auth.uid == resource.data.player1Id ||
                     request.auth.uid == resource.data.player2Id;
   }

   match /match_history/{playerId}/matches/{matchId} {
     allow read: if request.auth != null;
     allow write: if request.auth.uid == playerId;
   }

   match /performance_stats/{playerId} {
     allow read: if request.auth != null;
     allow write: if request.auth.uid == playerId;
   }
   ```

2. **Data Privacy**
   - Only show stats for public profiles
   - Don't expose sensitive match data
   - Implement rating hiding for accounts

---

## Localization

All UI strings are Japanese (ja) with English (en) fallback:
- `'比較'` (Comparison)
- `'対戦履歴'` (Match History)
- `'パフォーマンス'` (Performance)
- `'勝率'` (Win Rate)
- `'連勝'` (Win Streak)
- `'連敗'` (Loss Streak)

---

## Success Metrics

1. **Functionality**
   - All comparison views render correctly
   - Filtering works for all match history criteria
   - Charts display smoothly with 1000+ data points

2. **Performance**
   - Screen load time < 500ms (cached)
   - Filter response < 200ms
   - Pagination change < 100ms

3. **Testing**
   - 70%+ code coverage
   - All edge cases tested
   - Integration tests pass

---

## Future Enhancements

1. **Advanced Analytics**
   - Opening repertoire tracking
   - Time management analysis
   - Position evaluation history

2. **Social Features**
   - Share comparison results
   - Challenge friend with similar rating
   - Rematch functionality

3. **AI Insights**
   - Personalized improvement recommendations
   - Performance prediction models
   - Optimal opponent suggestions

---

## References

- **ELO Rating Formula**: https://en.wikipedia.org/wiki/Elo_rating_system
- **FL Charts Documentation**: https://github.com/imaNNeoFighT/fl_chart
- **Firestore Best Practices**: https://firebase.google.com/docs/firestore/best-practices
- **Phase H (Leaderboard System)**: LEADERBOARD_GUIDE.md

---

**Document Version**: 1.0  
**Last Updated**: 2026-08-26  
**Prepared By**: Claude AI  
**Status**: ✅ Ready for Implementation
