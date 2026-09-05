# Performance Optimization Guide

**Date**: 2026-09-04  
**Status**: Implementation Phase  
**Estimated Time**: 8-9 hours  
**Priority**: High

---

## Executive Summary

Comprehensive performance optimization pass covering:
- **Firestore Query Optimization** - Eliminate N+1 queries, add batching
- **Provider Caching Strategy** - Reduce unnecessary provider watches and rebuilds
- **AI Service Optimization** - Cache expensive computations, parallelize analysis
- **List Rendering Performance** - Virtual scrolling, lazy loading
- **Firestore Indexing Strategy** - Required indexes for queries

---

## Part 1: Firestore Query Optimization

### Current Issues

**23 nested Firestore queries** identified:
```dart
// INEFFICIENT - Makes N separate queries
for (final game in games) {
  final player = await firestore
    .collection('users')
    .doc(game.playerId)
    .get();  // N queries!
}
```

### Optimization Strategy

#### 1. Batch Reads
Use `WriteBatch` and query optimization to fetch multiple documents in single operation:

```dart
// OPTIMIZED - Single batch read
final playerDocs = await firestore
    .collection('users')
    .where(FieldPath.documentId, whereIn: playerIds)
    .get();

final playerMap = {
  for (final doc in playerDocs.docs)
    doc.id: User.fromJson(doc.data())
};
```

#### 2. Denormalization Strategy
Store frequently accessed data in parent documents:

```dart
// In match_history/matchId
{
  'whitePlayerId': 'user123',
  'whitePlayerName': 'Alice',      // Denormalized
  'whitePlayerRating': 1850,       // Denormalized
  'blackPlayerId': 'user456',
  'blackPlayerName': 'Bob',        // Denormalized
  'blackPlayerRating': 1920,       // Denormalized
}
```

#### 3. Query Pagination
Implement cursor-based pagination for large result sets:

```dart
class QueryCache {
  final Query query;
  DocumentSnapshot? lastDoc;
  List<T> cachedResults = [];
  
  Future<List<T>> getNextPage(int pageSize) async {
    Query q = query;
    if (lastDoc != null) {
      q = q.startAfter([lastDoc!]);
    }
    final snapshot = await q.limit(pageSize).get();
    if (snapshot.docs.isNotEmpty) {
      lastDoc = snapshot.docs.last;
    }
    return snapshot.docs.map((d) => T.fromJson(d.data())).toList();
  }
}
```

### Firestore Indexes Required

```
Collection: match_history
Document ID: playerId
  - Index on: playedAt (Descending)
  
Collection: users
Document ID: userId
Subcollection: game_analyses
  - Index on: createdAt (Descending)
  - Index on: type (Ascending), createdAt (Descending)

Collection: leaderboard
  - Index on: rating (Descending)
  - Index on: timeControl (Ascending), rating (Descending)
```

---

## Part 2: Provider Caching & Selection Strategy

### Current Issues

**Unnecessary provider rebuilds** when using `watch()`:
```dart
// INEFFICIENT - Rebuilds on ANY state change in _service
final games = ref.watch(userActiveGamesProvider);

// Better approach: Watch only the games list
final games = ref.watch(userActiveGamesProvider.select((state) => 
  state.whenData((list) => list).value ?? []
));
```

### Optimization: Provider Selection Pattern

#### Before
```dart
class GameListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuilds when ANY game data changes
    final games = ref.watch(userActiveGamesProvider);
    
    return games.when(
      data: (games) => ListView(children: [
        for (final game in games)
          GameCard(game: game)
      ]),
      loading: () => CircularProgressIndicator(),
      error: (e, st) => Text('Error: $e'),
    );
  }
}
```

#### After
```dart
class GameListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch the games list, not individual game updates
    final games = ref.watch(
      userActiveGamesProvider.select((state) =>
        state.whenData((list) => list).value ?? []
      ),
    );
    
    // Only watch specific game if needed
    return GameCardList(games: games);
  }
}

class GameCardList extends ConsumerWidget {
  final List<OnlineGame> games;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        for (final game in games)
          GameCard(
            game: game,
            // Use .select() to watch only this game's updates
            onStatusChange: () => ref.watch(
              gameStreamProvider(game.id)
                .select((state) => state.valueOrNull?.status)
            ),
          )
      ],
    );
  }
}
```

### Caching Strategy

**Three-tier cache for AI analysis:**

```dart
class AIAnalysisCache {
  // Tier 1: Memory cache (hot data)
  final Map<String, GameAnalysis> _memoryCache = {};
  
  // Tier 2: SQLite local cache (warm data)
  final Database _localDb;
  
  // Tier 3: Firestore (cold data)
  final FirebaseFirestore _firestore;
  
  Future<GameAnalysis> getAnalysis(String gameId) async {
    // Check memory cache first
    if (_memoryCache.containsKey(gameId)) {
      return _memoryCache[gameId]!;
    }
    
    // Check local cache
    final localResult = await _localDb.query(
      'game_analysis',
      where: 'gameId = ?',
      whereArgs: [gameId],
    );
    
    if (localResult.isNotEmpty) {
      final analysis = GameAnalysis.fromJson(
        Map<String, dynamic>.from(localResult.first)
      );
      _memoryCache[gameId] = analysis;
      return analysis;
    }
    
    // Fetch from Firestore
    final firestoreResult = await _firestore
        .collection('game_analyses')
        .doc(gameId)
        .get();
    
    final analysis = GameAnalysis.fromJson(firestoreResult.data()!);
    
    // Populate caches
    _memoryCache[gameId] = analysis;
    await _localDb.insert('game_analysis', analysis.toJson());
    
    return analysis;
  }
}
```

---

## Part 3: AI Service Optimization

### Current Issues in AILessonGenerationServiceImpl

**Lines 41-46**: Loop calling expensive operations for each move:
```dart
// INEFFICIENT - 30+ operations per move in a 30-move game!
for (int i = 0; i < moves.length; i++) {
  final move = moves[i];
  final analysisType = _classifyMove(move, i);        // Expensive
  final bestMove = _findBestMove(game.pgn, i);        // VERY Expensive
  final explanation = _generateMoveExplanation(move, analysisType);
  final tacticPattern = _identifyTacticPattern(game.pgn, i);
  final evaluationDiff = _calculateEvaluationDifference(move, bestMove);
}
```

### Optimization: Batch Analysis with Caching

```dart
Future<GameAnalysis> analyzeGame(String userId, String gameId) async {
  // Check cache first
  final cached = await _cacheService.getAnalysis(gameId);
  if (cached != null) return cached;

  final game = await _getGame(userId, gameId);
  final moves = game.pgn.split(' ').where((m) => m.isNotEmpty).toList();

  // Batch move analysis - compute all in parallel
  final moveAnalyses = await Future.wait([
    for (int i = 0; i < moves.length; i++)
      _analyzeMoveEfficiently(game, moves, i),
  ]);

  // Aggregate results (single pass)
  final (
    accuracy,
    errorCounts,
    tactics,
    weaknesses,
  ) = _aggregateMoveAnalysis(moveAnalyses);

  final analysis = GameAnalysis(
    userId: userId,
    gameId: gameId,
    moveAnalyses: moveAnalyses,
    accuracy: accuracy,
    // ... other fields
  );

  // Cache result
  await _cacheService.setAnalysis(gameId, analysis);
  
  return analysis;
}

// Optimized single move analysis (reuses cached engine state)
Future<MoveAnalysis> _analyzeMoveEfficiently(
  Game game,
  List<String> moves,
  int moveIndex,
) async {
  final position = _computePosition(moves, moveIndex);
  final bestMoves = await _engineCache.getBestMoves(position);
  
  return MoveAnalysis(
    moveNumber: moveIndex + 1,
    move: moves[moveIndex],
    engineEval: bestMoves[0].evaluation,
    type: _classifyMoveType(moves[moveIndex], bestMoves[0]),
    explanation: _explainMove(moves[moveIndex], bestMoves[0]),
  );
}
```

### Compute Position Efficiently

```dart
class ChessPositionCache {
  final Map<List<String>, ChessPosition> _positionCache = {};
  
  ChessPosition computePosition(List<String> moves, int upToIndex) {
    final key = moves.sublist(0, upToIndex + 1);
    
    if (_positionCache.containsKey(key)) {
      return _positionCache[key]!;
    }
    
    // Reuse previous position if available
    ChessPosition position = ChessPosition.startingPosition;
    if (upToIndex > 0) {
      final prevKey = key.sublist(0, upToIndex);
      if (_positionCache.containsKey(prevKey)) {
        position = _positionCache[prevKey]!;
      }
    }
    
    // Apply only new move
    position = position.applyMove(key.last);
    _positionCache[key] = position;
    
    return position;
  }
}
```

---

## Part 4: List Rendering Performance

### Virtual Scrolling for Large Lists

**Before**: Renders all 1000+ games at once
```dart
// INEFFICIENT
ListView.builder(
  itemCount: allGames.length,
  itemBuilder: (context, index) => GameCard(game: allGames[index]),
)
```

**After**: Virtual scrolling with lazy loading
```dart
class VirtualGameList extends ConsumerWidget {
  final List<OnlineGame> games;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context)
          .copyWith(scrollbars: false),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            ref.read(gameListNotifierProvider.notifier)
                .loadNextPage();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: games.length + 1,
          itemBuilder: (context, index) {
            if (index == games.length) {
              return Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return GameCard(game: games[index]);
          },
        ),
      ),
    );
  }
}
```

### Widget Build Optimization

```dart
// Cache expensive widget tree builds
class GameCardList extends StatelessWidget {
  final List<OnlineGame> games;
  
  const GameCardList({required this.games});
  
  @override
  Widget build(BuildContext context) {
    // Use RepaintBoundary to prevent cascade repaints
    return ListView.builder(
      itemCount: games.length,
      itemBuilder: (context, index) => RepaintBoundary(
        child: GameCard(game: games[index]),
      ),
    );
  }
}
```

---

## Part 5: Asset & Image Optimization

### Image Caching Strategy

```dart
class CachedChessPieceImage extends StatelessWidget {
  final String piece;
  final double size;
  
  const CachedChessPieceImage({
    required this.piece,
    required this.size,
  });
  
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/pieces/$piece.svg',
      width: size,
      height: size,
      // Cache with flutter's built-in caching
      cacheWidth: (size * 2).toInt(),
      cacheHeight: (size * 2).toInt(),
    );
  }
}
```

---

## Implementation Checklist

### Phase 1: Firestore Queries (2-3 hours)
- [ ] Create Firestore indexes
- [ ] Replace 23 N+1 queries with batch reads
- [ ] Add denormalization where appropriate
- [ ] Implement pagination helper
- [ ] Update all collection queries

### Phase 2: Providers (2-3 hours)
- [ ] Add `.select()` to 15+ providers
- [ ] Implement three-tier cache
- [ ] Update StateNotifier patterns
- [ ] Test provider rebuild counts

### Phase 3: AI Service (2 hours)
- [ ] Parallelize move analysis
- [ ] Add engine state caching
- [ ] Implement result caching
- [ ] Optimize position computation

### Phase 4: List Rendering (1 hour)
- [ ] Add virtual scrolling
- [ ] Implement lazy loading
- [ ] Add RepaintBoundary optimization
- [ ] Test with 1000+ items

### Phase 5: Testing & Validation (1-2 hours)
- [ ] Benchmark query performance
- [ ] Profile memory usage
- [ ] Verify provider rebuilds
- [ ] Load testing (1000+ games)

---

## Performance Targets

| Metric | Before | Target | Improvement |
|--------|--------|--------|-------------|
| Game load time | 3-5s | <500ms | 85% |
| Move analysis | 8-10s | 2-3s | 70% |
| Game list render | 2-3s | <500ms | 80% |
| Memory usage | 150-200MB | <100MB | 40% |
| Rebuild count | 15-20/action | 2-3/action | 85% |

---

## Success Criteria

✅ All 23 N+1 queries eliminated  
✅ 85%+ rebuild reduction in provider chains  
✅ Game analysis time reduced 70%  
✅ List rendering time < 500ms  
✅ Memory footprint < 100MB  
✅ 95% test coverage for optimization code

---

## Deployment

```bash
# 1. Create branch
git checkout -b claude/performance-optimization

# 2. Implement optimizations (phases 1-5)

# 3. Run performance benchmarks
flutter test --coverage test/performance/

# 4. Profile with DevTools
flutter run --profile

# 5. Create PR
git push origin claude/performance-optimization
```

---

**Next Phase**: QA Phase 2 (Widget test expansion, edge case coverage)
