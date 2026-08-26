# ランキング・リーダーボード システムガイド
# Leaderboard & Ranking System Guide

日本語ガイドは下のセクション「システム概要（日本語）」を参照してください。
English documentation is available in the "System Overview (English)" section below.

---

## システム概要（日本語）

### 概要
チェスタクティクスマスターのランキング・リーダーボード（以下「ランキングシステム」）は、プレイヤーの成績を複数の観点から可視化し、競争的な環境を実現するための機能です。

#### 主な特徴
- **グローバルランキング**: すべてのプレイヤーをELOレーティングで順位付け
- **段級別ランキング**: 同じ将棋段級のプレイヤー同士での競争
- **月間ランキング**: 月ごとの限定的なランキング（季節イベント）
- **リアルタイム更新**: ゲーム終了時に自動的にランキングを更新
- **プレイヤー詳細**: 個別プレイヤーの統計情報を表示

### アーキテクチャ

#### サービス層 (`lib/src/services/ranking_service.dart`)
ランキング管理の中核となるビジネスロジック層

**主要メソッド:**
- `updateUserRanking()` - ゲーム後にプレイヤーランキングを更新
- `getGlobalRanking(limit, offset)` - グローバルランキングを取得
- `getRankingByShogi(shogiRank)` - 段級別ランキングを取得
- `getMonthlyRanking(monthKey)` - 月間ランキングを取得
- `getUserRank(uid)` - 特定プレイヤーの順位を取得
- `getNearbyRankings(uid, proximityCount)` - ユーザー周辺のプレイヤーを取得
- `getRankingStats()` - 集計統計を取得
- `watchGlobalRanking()` - リアルタイムストリーム（グローバル）
- `watchUserRanking(uid)` - リアルタイムストリーム（個別ユーザー）

**Firestore スキーマ:**
```
rankings/
├── global/
│   └── players/
│       └── {uid}/
│           ├── uid: String
│           ├── displayName: String
│           ├── photoUrl: String?
│           ├── rating: int
│           ├── shogiRankString: String
│           ├── gamesPlayed: int
│           ├── winRate: double
│           ├── lastGameAt: Timestamp
│           └── updatedAt: Timestamp
│
├── byShogi/
│   └── {shogiRankString}/
│       └── players/
│           └── {uid}/
│               └── (similar fields)
│
└── monthly/
    └── {YYYY-MM}/
        └── players/
            └── {uid}/
                └── (similar fields)

ranking_stats/
└── global/
    ├── totalPlayers: int
    ├── averageRating: double
    ├── topRating: int
    └── lastUpdated: Timestamp
```

#### 状態管理層 (`lib/src/providers/leaderboard_provider.dart`)
Riverpod を使用した反応型状態管理

**主要プロバイダー:**
- `leaderboardProvider` - メインレーダーボード状態
- `globalRankingStreamProvider` - リアルタイムランキングストリーム
- `userRankProvider` - 特定ユーザーの順位
- `nearbyRankingsProvider` - 周辺プレイヤー
- `watchUserRankingProvider` - ユーザーランキングのリアルタイム監視
- `rankingStatsProvider` - 統計情報

**LeaderboardState:**
- `entries: List<RankingEntry>` - ランキング項目
- `stats: RankingStats?` - 集計統計
- `isLoading: bool` - 読込中フラグ
- `error: String?` - エラーメッセージ
- `currentPage: int` - 現在のページ
- `filter: LeaderboardFilter` - フィルタータイプ
- `lastRefreshed: DateTime?` - 最終更新時刻

#### UI層

**スクリーン:**
1. **LeaderboardScreen** (`lib/src/screens/ranking/leaderboard_screen.dart`)
   - グローバル・段級別・月間ランキングの表示
   - フィルタータブ
   - ページネーション
   - 統計セクション

2. **PlayerDetailScreen** (`lib/src/screens/ranking/player_detail_screen.dart`)
   - 個別プレイヤーの詳細情報
   - 周辺プレイヤー表示
   - 成績統計

3. **MyRankingScreen** (`lib/src/screens/ranking/my_ranking_screen.dart`)
   - 現在のユーザーのランキング位置
   - 周辺プレイヤー
   - マイプロフィール統計

**ウィジェット:**
- `RankCard` - ランキング項目表示
- `ShogiRankDisplay` - 将棋段級バッジ（既存）

### データフロー

#### ゲーム完了時の流れ

```
Game Ends
    ↓
OnlineGameService._updateRatingsAfterGame()
    ↓
[1] Update user ratings in users collection
[2] Calculate new shogi rank
[3] Call RankingService.updateUserRanking()
    ↓
RankingService.updateUserRanking()
    ↓
[1] Update rankings/global/players/{uid}
[2] Update rankings/byShogi/{shogiRank}/players/{uid}
[3] Update rankings/monthly/{YYYY-MM}/players/{uid}
[4] Call _updateRankingStats()
    ↓
_updateRankingStats()
    ↓
Update ranking_stats/global with:
- totalPlayers (count)
- averageRating (mean of all ratings)
- topRating (max rating)
- lastUpdated (server timestamp)
```

### 使用例

#### グローバルランキングの表示
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final leaderboardState = ref.watch(leaderboardProvider);

  return leaderboardState.when(
    data: (state) => ListView.builder(
      itemCount: state.entries.length,
      itemBuilder: (context, index) => RankCard(
        entry: state.entries[index],
        index: index,
      ),
    ),
    loading: () => const CircularProgressIndicator(),
    error: (err, st) => Text('Error: $err'),
  );
}
```

#### ユーザーの順位を取得
```dart
final userRank = await ref.watch(userRankProvider(uid));
// Returns: int? (nil if user not in rankings)
```

#### ユーザー周辺のプレイヤーを表示
```dart
final nearby = ref.watch(nearbyRankingsProvider(uid));
// Returns: List<RankingEntry> (5 above and below user)
```

#### リアルタイム監視
```dart
final ranking = ref.watch(watchUserRankingProvider(uid));
// Automatically updates when user's ranking changes
```

### 計算ロジック

#### レーティング計算
- **アルゴリズム**: ELO（K-factor = 32）
- **実装**: `OnlineGameService._calculateRatingDeltas()`
- **計算例**:
  - ホワイト 1600、ブラック 1500 → ホワイト勝利
  - ホワイト期待スコア = 1.0 / (1.0 + 10^((1500-1600)/400)) ≈ 0.64
  - ホワイト変化 = 32 × (1.0 - 0.64) = +11.5 → +12
  - ブラック変化 = 32 × (0.0 - 0.36) = -11.5 → -12

#### 将棋段級への変換
- **実装**: `ShogiRankService.calculateRank(eloRating)`
- **変換テーブル**: 
  - 20級: 0-499
  - 19級: 500-599
  - ... (各段級に100-200レート差)
  - 8段: 1900+

### パフォーマンス最適化

#### インデックス戦略
推奨 Firestore インデックス：
```
rankings/global/players: rating (descending), updatedAt (descending)
rankings/byShogi/{rank}/players: rating (descending)
rankings/monthly/{month}/players: rating (descending)
ranking_stats/global: lastUpdated (descending)
```

#### ページネーション
- 1ページあたり50プレイヤー
- offset-limit パターンを使用
- クライアント側でページキャッシュ

#### キャッシング戦略
- Riverpod の自動キャッシング（同じパラメータ）
- Stream の再接続は30秒ごと
- ユーザーランク：ゲーム後に自動リフレッシュ

### エラーハンドリング

#### 実装パターン
```dart
try {
  final entries = await rankingService.getGlobalRanking();
  state = state.copyWith(entries: entries, isLoading: false);
} catch (e) {
  state = state.copyWith(
    error: 'Failed to load rankings: $e',
    isLoading: false,
  );
}
```

#### ユーザーへの表示
- 読込エラー → 「読込に失敗しました」+ 再試行ボタン
- ネットワークエラー → SwipeRefresh で再試行可能
- タイムアウト → 「接続がタイムアウトしました」

### テスト戦略

#### ユニットテスト (`test/providers/leaderboard_provider_test.dart`)
- LeaderboardNotifier の状態遷移
- UserRankNotifier のロード処理
- エラーハンドリング
- ページネーション

#### ウィジェットテスト (`test/screens/ranking/`)
- UI の初期表示
- フィルタータブの切り替え
- ランキング項目の表示
- ページネーション UI

#### 統合テスト (`integration_test/leaderboard_flow_test.dart`)
- 完全なユーザーフロー
- フィルタリング動作
- データ表示の正確性
- レスポンシブデザイン

### トラブルシューティング

#### Firestore クエリの最適化
**問題**: ランキング取得が遅い
**解決策**:
1. インデックスが作成されているか確認
2. offset + limit の代わりに cursor ベースを検討
3. キャッシング戦略を調整

#### リアルタイム更新の遅延
**問題**: ランキングがすぐに反映されない
**解決策**:
1. `lastRefreshed` チェック（15秒以内なら再読込しない）
2. ユーザーが手動更新できるボタンを用意
3. Firestore の書き込み遅延を確認

#### メモリリーク
**問題**: Stream の購読が残っている
**解決策**:
1. `dispose()` で購読をキャンセル
2. Riverpod は自動的にクリーンアップ（ProviderScope 離脱時）

---

## System Overview (English)

### Overview
The Leaderboard & Ranking System is a feature designed to visualize player performance across multiple perspectives and create a competitive environment.

#### Key Features
- **Global Ranking**: All players ranked by ELO rating
- **Shogi Rank Filter**: Competition among players of the same shogi dan/kyu
- **Monthly Ranking**: Limited-time seasonal rankings
- **Real-time Updates**: Automatic ranking updates upon game completion
- **Player Details**: Display individual player statistics

### Architecture

#### Service Layer (`lib/src/services/ranking_service.dart`)
Core business logic for ranking management

**Main Methods:**
- `updateUserRanking()` - Update player rankings after game
- `getGlobalRanking(limit, offset)` - Fetch global rankings
- `getRankingByShogi(shogiRank)` - Fetch shogi-filtered rankings
- `getMonthlyRanking(monthKey)` - Fetch monthly rankings
- `getUserRank(uid)` - Get specific player's rank position
- `getNearbyRankings(uid, proximityCount)` - Get rankings around user
- `getRankingStats()` - Get aggregate statistics
- `watchGlobalRanking()` - Real-time stream (global)
- `watchUserRanking(uid)` - Real-time stream (individual user)

**Firestore Schema:** (See Japanese section for detailed structure)

#### State Management (`lib/src/providers/leaderboard_provider.dart`)
Reactive state management using Riverpod

**Main Providers:** (See Japanese section for detailed list)

#### UI Layer

**Screens:**
1. **LeaderboardScreen** - Global, filter, monthly rankings display
2. **PlayerDetailScreen** - Individual player details and nearby rankings
3. **MyRankingScreen** - Current user's ranking position

### Data Flow

Game completion → Rating update → Ranking update → Stats recalculation

### Usage Examples

#### Display Global Rankings
```dart
final leaderboardState = ref.watch(leaderboardProvider);
// Display state.entries in ListView
```

#### Get User Rank
```dart
final userRank = ref.watch(userRankProvider(uid));
// Returns: int? position in rankings
```

#### Watch Real-time Updates
```dart
final ranking = ref.watch(watchUserRankingProvider(uid));
// Automatically updates when user's ranking changes
```

### Rating Calculation
- **Algorithm**: ELO (K-factor = 32)
- **Implementation**: `OnlineGameService._calculateRatingDeltas()`

### Shogi Rank Conversion
- **Service**: `ShogiRankService.calculateRank(eloRating)`
- **Range**: 20-kyu to 8-dan
- **ELO Thresholds**: See shogi_rank_service.dart

### Performance Optimization

#### Indexing
Recommended Firestore indexes:
- `ratings/global/players`: rating (desc), updatedAt (desc)
- `rankings/byShogi/{rank}/players`: rating (desc)
- `rankings/monthly/{month}/players`: rating (desc)

#### Pagination
- 50 players per page
- Offset-limit pattern
- Client-side caching

### Error Handling
- Network errors caught and displayed
- Retry functionality provided
- Graceful degradation

### Testing

#### Unit Tests
- State notifier transitions
- Ranking calculations
- Error handling

#### Widget Tests
- UI element display
- Filter functionality
- Pagination

#### Integration Tests
- Complete user flows
- Data accuracy
- Responsive design

---

## ファイル一覧（File Structure）

### Services
- `lib/src/services/ranking_service.dart` (419 lines)

### Providers
- `lib/src/providers/leaderboard_provider.dart` (379 lines)

### UI Screens
- `lib/src/screens/ranking/leaderboard_screen.dart` (355 lines)
- `lib/src/screens/ranking/player_detail_screen.dart` (365 lines)
- `lib/src/screens/ranking/my_ranking_screen.dart` (407 lines)

### Tests
- `test/providers/leaderboard_provider_test.dart` (370 lines)
- `test/screens/ranking/leaderboard_screen_test.dart` (268 lines)
- `test/screens/ranking/player_detail_screen_test.dart` (126 lines)
- `test/screens/ranking/my_ranking_screen_test.dart` (73 lines)
- `integration_test/leaderboard_flow_test.dart` (305 lines)

### Documentation
- `LEADERBOARD_GUIDE.md` (this file)

---

## Integration with Existing Systems

### User Model Integration
```dart
// lib/src/models/user.dart
class UserModel {
  int rating;              // ELO rating
  int gamesPlayed;         // Sync with rankings
  int wins;                // Used in winRate calculation
  ShogiRank shogiRank;     // Sync with ranking system
}
```

### Online Game Integration
```dart
// When game completes
await rankingService.updateUserRanking(
  uid: userId,
  rating: newRating,
  shogiRankString: ShogiRankService.calculateRank(newRating).displayName(),
  gamesPlayed: gamesPlayed + 1,
  // ... other stats
);
```

---

## Future Enhancements

### Phase I Planned Features
- [ ] Player comparison tool
- [ ] Rating progress charts
- [ ] Achievement badges
- [ ] Seasonal leaderboard archives
- [ ] Spectator mode for top matches

---

**Last Updated**: 2026-08-26
**Phase**: H - Leaderboard System (In Progress)
**Status**: Core implementation complete, UI/Tests in progress
