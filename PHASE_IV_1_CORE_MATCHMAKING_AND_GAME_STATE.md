# Phase IV.1: Core Matchmaking & Game State Management

**Status**: ✅ Complete  
**Date**: 2026-08-26  
**Scope**: Matchmaking system, online game management, real-time synchronization foundation

---

## Overview

Phase IV.1 implements the foundational services and data models for online multiplayer chess. This phase covers:

1. **Data Models** - Complete representation of online games, matchmaking queues, and presence
2. **Matchmaking Service** - Rating-based queue management with dynamic range expansion
3. **Online Game Service** - Real-time game state management, move recording, timeout handling
4. **Riverpod Providers** - Integration with state management for UI consumption
5. **Comprehensive Tests** - Unit and integration test cases

---

## Files Created

### Data Models
**`lib/src/models/online_game.dart`** (497 lines)

Core data structures for online multiplayer:

- **OnlineGame** (400 lines)
  - Represents a complete multiplayer game
  - Fields: gameId, type, status, timestamps, player info, game state, time control, results, ratings
  - Methods: toJson(), fromJson(), copyWith(), currentTurn, currentPlayerName, isFinished, isActive
  - Full Firestore serialization support

- **GameMove** (40 lines)
  - Individual move representation
  - Fields: moveNumber, from, to, promotion, timestamp, playerId
  - Methods: toJson(), fromJson(), notation getter

- **MatchmakingQueueEntry** (75 lines)
  - Queue entry for waiting players
  - Fields: queueId, playerId, playerName, rating, ratingRange, timeControl, timestamps, status, color
  - Methods: toJson(), fromJson(), waitTimeSeconds, isExpired getters

- **RatingRange** (25 lines)
  - Rating range helper for matchmaking
  - Methods: contains(), overlaps(), toJson(), fromJson()

- **UserPresence** (65 lines)
  - Real-time presence tracking
  - Fields: playerId, isOnline, lastSeenAt, currentActivity, currentGameId, connectionStatus, deviceInfo
  - Methods: toJson(), fromJson(), copyWith()

- **DeviceInfo** (25 lines)
  - Device information for presence
  - Fields: type (web/ios/android), lastActivity

### Services

**`lib/src/services/matchmaking_service.dart`** (237 lines)

Rating-based matchmaking with dynamic range expansion:

- **joinQueue()** - Add player to matchmaking queue
  - Initializes entry with ±50 rating range
  - Sets 30-second timeout
  - Starts matching process
  - Returns MatchmakingQueueEntry

- **leaveQueue()** - Remove player from queue
  - Cleans up queue entry
  - Stops matching process

- **getQueueStatus()** - Get current status of queue entry
  - Returns status, wait time, rating range, expiration
  - Handles non-existent entries gracefully

- **getQueueStats()** - Get overall queue statistics
  - Total waiting players
  - Grouped by time control type
  - Average wait time calculation

- **cleanupExpiredEntries()** - Remove expired queue entries
  - Called by Cloud Function on schedule
  - Returns count of cleaned entries

- **Rating Range Expansion**
  - 0-10s: ±50 (strict)
  - 10-20s: ±100 (relaxed)
  - 20-30s: ±200 (more relaxed)
  - 30+s: ±300 (very relaxed)

**`lib/src/services/online_game_service.dart`** (380 lines)

Real-time game state management:

- **createGame()** - Create new game from matched players
  - Initializes with starting position (FEN)
  - Sets timeControl milliseconds
  - Creates game in 'matchmaking' status
  - Generates unique gameId

- **startGame()** - Transition to active status
  - Sets startedAt timestamp via server
  - Prepares for move recording

- **recordMove()** - Record player move
  - Adds to moves subcollection
  - Updates currentFen and pgn
  - Records move timestamp
  - Tracks which player moved

- **updateTimeRemaining()** - Update time for both players
  - Detects timeout conditions
  - Ends game on timeout with rating updates

- **recordActivity()** - Track player activity for timeout detection

- **resignGame()** - Handle player resignation
  - Determines winner based on resigning player
  - Updates ratings via ELO calculation
  - Marks game as completed

- **abandonGame()** - Handle disconnection/abandonment
  - Marks game as abandoned
  - Records which player abandoned
  - Other player declared winner

- **getGame()** - Fetch game by ID

- **getGameMoves()** - Get all moves for a game ordered by moveNumber

- **watchGame()** - Stream real-time game updates

- **getPlayerActiveGames()** - Get all active games for a player
  - Combines white and black games
  - Filters to status='active'

- **getPlayerRecentGames()** - Get player's recent games
  - Ordered by creation date descending
  - Respects limit parameter (default 10)

- **ELO Rating Calculation**
  - Formula: ΔR = K × (S - E)
  - K-factor: 32
  - D-constant: 400
  - Expected score: 1 / (1 + 10^((opponent - player) / 400))
  - Handles win, loss, draw scenarios

### Riverpod Providers

**`lib/src/providers/online_game_provider.dart`** (310 lines)

State management for online game operations:

- **matchmakingServiceProvider** - Singleton MatchmakingService
- **onlineGameServiceProvider** - Singleton OnlineGameService

- **queueStatusProvider** - Watch queue status for specific queueId
- **queueStatsProvider** - Overall queue statistics
- **userActiveGamesProvider** - Current user's active games
- **userRecentGamesProvider** - Current user's recent games (limit: 20)
- **onlineGameProvider** - Specific game by ID
- **gameStreamProvider** - Real-time game updates
- **gameMoveProvider** - All moves for a game

- **OnlineGameNotifier** - StateNotifier for game operations
  - createGame() - Create new game
  - startGame() - Start game
  - recordMove() - Record move
  - updateTimeRemaining() - Update time
  - recordActivity() - Track activity
  - resign() - Resign from game
  - abandon() - Abandon game

- **onlineGameNotifierProvider** - Exposes OnlineGameNotifier

- **MatchmakingNotifier** - StateNotifier for queue operations
  - joinQueue() - Join matchmaking
  - leaveQueue() - Leave queue

- **matchmakingNotifierProvider** - Exposes MatchmakingNotifier

### Tests

**`test/services/online_game_service_test.dart`** (280 lines)

Comprehensive test coverage:

**MatchmakingService Tests:**
- joinQueue: rating range, timeout, status initialization
- leaveQueue: removal, error handling
- getQueueStatus: status retrieval, wait time, expiration
- getQueueStats: player count, grouping, averages
- cleanupExpiredEntries: removal, preservation

**OnlineGameService Tests:**
- createGame: starting position, status, time control parsing
- startGame: status transition, timestamp
- recordMove: move recording, FEN/PGN updates, timestamp
- updateTimeRemaining: time updates, timeout detection
- recordActivity: activity tracking
- resignGame: winner determination, rating updates
- abandonGame: abandonment tracking
- getGame: game retrieval
- getGameMoves: move ordering
- watchGame: stream functionality
- getPlayerActiveGames: game filtering
- getPlayerRecentGames: sorting, limits
- Rating calculation: ELO formula, rating changes

**Integration Tests:**
- Complete game flow (create → start → moves → complete)
- Timeout handling in active game
- Resignation handling
- Abandonment handling
- Real-time synchronization
- Draw agreement handling

---

## Database Schema

### Firestore Collections

**`/games/{gameId}`** - Online games
```javascript
{
  gameId: string,
  type: 'online_pvp' | 'online_rapid' | 'online_blitz',
  status: 'matchmaking' | 'active' | 'completed' | 'abandoned',
  
  // Timestamps
  createdAt: Timestamp,
  startedAt: Timestamp?,
  endedAt: Timestamp?,
  
  // Players
  whitePlayerId: string,
  blackPlayerId: string,
  whitePlayerName: string,
  blackPlayerName: string,
  whiteRating: int,
  blackRating: int,
  
  // Game state
  pgn: string,
  currentFen: string,
  moves: GameMove[],
  
  // Time control
  timeControl: string,
  timeControlMs: int,
  whiteTimeRemainingMs: int,
  blackTimeRemainingMs: int,
  
  // Activity tracking
  lastMoveTimestamp: Timestamp?,
  whiteLastActivityTimestamp: Timestamp?,
  blackLastActivityTimestamp: Timestamp?,
  
  // Results
  result: 'white_win' | 'black_win' | 'draw'?,
  resultReason: string?,
  abandonedBy: string?,
  
  // Rating changes
  whiteRatingDelta: int?,
  blackRatingDelta: int?,
  whiteNewRating: int?,
  blackNewRating: int?
}
```

**`/games/{gameId}/moves/{moveId}`** - Individual moves
```javascript
{
  moveNumber: int,
  from: string,          // e.g., "e2"
  to: string,            // e.g., "e4"
  promotion: string?,    // e.g., "Q" for queen promotion
  timestamp: Timestamp,
  playerId: string
}
```

**`/matchmaking_queue/{queueId}`** - Matchmaking entries
```javascript
{
  queueId: string,
  playerId: string,
  playerName: string,
  currentRating: int,
  ratingRange: {
    min: int,
    max: int
  },
  timeControlType: string,
  queuedAt: Timestamp,
  timeoutAt: Timestamp,
  priority: int,
  status: 'waiting' | 'matched' | 'expired',
  matchedGameId: string?,
  matchedOpponentId: string?,
  color: 'white' | 'black' | 'random'
}
```

---

## Rating System Details

### ELO Formula

```
Expected Score = 1 / (1 + 10^((opponent_rating - player_rating) / 400))
Rating Change = K × (Actual Score - Expected Score)
```

### Parameters
- **K-factor**: 32 (determines rating volatility)
- **D-constant**: 400 (rating difference divisor)
- **Actual Score**: 1.0 (win), 0.5 (draw), 0.0 (loss)

### Examples

Player 1600 vs Player 1400:
- Expected for 1600: 1 / (1 + 10^(-200/400)) = 0.76
- Win: 1600 + 32 × (1.0 - 0.76) = 1600 + 7.68 ≈ 1608 (+8)
- Loss: 1600 + 32 × (0.0 - 0.76) = 1600 - 24.32 ≈ 1576 (-24)

Player 1400 vs Player 1600:
- Expected for 1400: 1 / (1 + 10^(200/400)) = 0.24
- Win (upset): 1400 + 32 × (1.0 - 0.24) = 1400 + 24.32 ≈ 1424 (+24)
- Loss: 1400 + 32 × (0.0 - 0.24) = 1400 - 7.68 ≈ 1392 (-8)

---

## Firestore Indexes Required

```yaml
# Composite indexes
- collection: games
  fields:
    - status (Ascending)
    - createdAt (Descending)

- collection: games
  fields:
    - whitePlayerId (Ascending)
    - createdAt (Descending)

- collection: games
  fields:
    - blackPlayerId (Ascending)
    - createdAt (Descending)

- collection: matchmaking_queue
  fields:
    - status (Ascending)
    - priority (Descending)
    - queuedAt (Ascending)
```

---

## Next Steps (Phase IV.2)

1. **Cloud Functions Implementation**
   - Matchmaking logic (find best matching opponent)
   - Game state validation (move legality)
   - Timeout handling (automatic game ending)
   - Rating updates (atomic operations)

2. **Realtime Database Integration**
   - Move broadcasting
   - Time synchronization
   - Player presence updates

3. **UI Implementation**
   - Matchmaking screen
   - Online game board
   - Game result screen
   - Rating display

---

## Files Modified

None (all new files for Phase IV.1)

---

## Testing

All services include comprehensive mock-based tests. Run with:
```bash
flutter test test/services/online_game_service_test.dart
```

---

## Architecture Notes

### Separation of Concerns

- **MatchmakingService**: Queue management only
- **OnlineGameService**: Game state management only
- **Riverpod Providers**: UI integration and caching
- **Cloud Functions**: Server-side validation and matching logic

### Scalability Considerations

- Subcollection for moves (grows with game length, not player count)
- Firestore indexes on status and player fields
- Batch operations for rating updates
- Priority queue implementation in Cloud Functions

### Real-time Sync Strategy

- Firestore for authoritative game state (primary)
- Realtime Database for low-latency updates (secondary)
- Stream watches on both for UI updates
- Automatic merge of conflicting updates (server timestamp wins)

---

**Created by**: Claude  
**Session**: https://claude.ai/code/session_015qWQDTgX7nUUH94CwJce7J  
**Completion Date**: 2026-08-26
