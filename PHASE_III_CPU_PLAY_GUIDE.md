# Phase III: CPU Play & Single-Player Mode
## Comprehensive Design & Implementation Guide

**Date**: 2026-08-26  
**Phase**: III (CPU Play)  
**Status**: Design Complete - Ready for Implementation  
**Estimated Lines of Code**: 2,500-3,000

---

## Table of Contents

1. [Overview](#overview)
2. [AI Engine Strategy](#ai-engine-strategy)
3. [Widget Specifications](#widget-specifications)
4. [Game Flow Architecture](#game-flow-architecture)
5. [Implementation Guide](#implementation-guide)
6. [Testing Strategy](#testing-strategy)

---

## Overview

Phase III extends Phase II with a complete single-player chess experience featuring an intelligent CPU opponent with multiple difficulty levels. Players can play against the computer with varying levels of challenge, from beginner-friendly to highly competitive.

### Key Objectives

1. **Intelligent AI Engine**
   - Minimax algorithm with alpha-beta pruning
   - Multiple difficulty levels (Easy, Medium, Hard)
   - Position evaluation with material and positional factors
   - Move ordering for optimization

2. **Interactive Chess Board**
   - Piece selection with visual feedback
   - Legal move highlighting
   - Drag-and-drop move input
   - Move animation
   - Board flip option

3. **Game Management**
   - Complete game flow from start to checkmate/stalemate
   - Move history with annotations
   - Game save/load functionality
   - Undo functionality (with limits)
   - Game analysis tools

4. **User Experience**
   - Difficulty level selection
   - Game progress indicators
   - AI thinking indicator
   - Result screen with statistics
   - Replay functionality

---

## AI Engine Strategy

### Architecture

```
ChessEngineService (Existing)
    ↓
AIOpponentEngine (NEW)
    ├── Minimax Algorithm
    ├── Alpha-Beta Pruning
    ├── Position Evaluator
    └── Move Ordering
```

### Difficulty Levels

#### Easy (Depth = 2)
- Material-based evaluation only
- No positional analysis
- Random move selection from top 3 moves
- ~50ms thinking time
- Win rate: ~30% against beginner players

#### Medium (Depth = 3)
- Material + positional evaluation
- Pawn structure analysis
- Piece mobility consideration
- Alpha-beta pruning enabled
- ~200ms thinking time
- Win rate: ~60% against intermediate players

#### Hard (Depth = 4)
- Full evaluation function
- Endgame tables (optional)
- Opening book (optional)
- Advanced pruning techniques
- ~1000ms thinking time
- Win rate: ~80% against advanced players

### Position Evaluation Function

```dart
int evaluatePosition() {
  int score = 0;
  
  // Material count (most important)
  score += materialScore(); // ±1-39 points
  
  // Positional factors (optional for Easy)
  score += pawnStructure();      // ±2 points
  score += pieceActivity();      // ±2 points
  score += kingScore();          // ±1 point
  score += centerControl();      // ±1 point
  
  // Apply endgame bonus
  if (isEndgame()) {
    score += endgameBonus();
  }
  
  return score;
}
```

### Minimax with Alpha-Beta Pruning

```dart
int minimax(int depth, int alpha, int beta, bool isMaximizing) {
  if (depth == 0 || gameOver()) {
    return evaluatePosition();
  }
  
  if (isMaximizing) {
    int maxEval = -infinity;
    for (move in orderMoves(getLegalMoves())) {
      makeMove(move);
      int eval = minimax(depth - 1, alpha, beta, false);
      undoMove();
      maxEval = max(maxEval, eval);
      alpha = max(alpha, eval);
      if (beta <= alpha) break; // Prune
    }
    return maxEval;
  } else {
    int minEval = +infinity;
    for (move in orderMoves(getLegalMoves())) {
      makeMove(move);
      int eval = minimax(depth - 1, alpha, beta, true);
      undoMove();
      minEval = min(minEval, eval);
      beta = min(beta, eval);
      if (beta <= alpha) break; // Prune
    }
    return minEval;
  }
}
```

### Move Ordering (Critical for Performance)

1. Captures (ordered by victim value)
2. Checks
3. Quiet moves (ordered by history heuristic)
4. Bad captures

---

## Widget Specifications

### 1. ChessBoard (Enhanced)

**Purpose**: Interactive chess board for move input and display

**Features**:
- 8x8 grid with piece rendering
- Selected piece highlighting
- Legal move indicators (dots/squares)
- Last move highlighting
- Coordinate labels (optional)
- Dark/light theme support
- Smooth piece animations
- Drag-and-drop support

**State Management**:
- Selected square tracking
- Available moves calculation
- Piece position updates

### 2. GameBoard (NEW)

**Purpose**: Game container with board and controls

**Components**:
- ChessBoard widget
- Turn indicator (shows current player)
- Captured pieces display
- Move controls (Undo, Resign, Draw offer)
- Game status display

### 3. DifficultySelector (NEW)

**Purpose**: AI difficulty level selection

**Options**:
- Easy (2-second AI thinking)
- Medium (5-second AI thinking)
- Hard (10-second AI thinking)

**UI**:
- Radio button selection
- Difficulty description
- Estimated win rate display

### 4. GameResult (NEW)

**Purpose**: End game screen with statistics

**Display**:
- Result (White Win/Black Win/Draw)
- Winning method (Checkmate/Resignation/Draw)
- Game duration
- Move count
- Rating change (if applicable)
- Buttons: Analyze, Save, New Game, Home

### 5. MoveHistory (NEW)

**Purpose**: Visual move log with annotations

**Display**:
- Move list in algebraic notation
- Current move highlighting
- Time spent per move (optional)
- Click to jump to position

### 6. CapturedPieces (NEW)

**Purpose**: Display captured pieces for both sides

**Features**:
- Material advantage indicator
- Piece count per side
- Visual piece arrangement

---

## Game Flow Architecture

### Game States

```
GameInitialization
    ↓
PlayerTurn
    ├─ Select Piece
    ├─ Select Move
    └─ Make Move
    ↓
AI Thinking
    ├─ Calculate best move
    └─ Make move
    ↓
CheckState
    ├─ Not Check → Next turn
    ├─ Check → Display warning
    └─ Checkmate/Stalemate → End Game
    ↓
GameResult
```

### State Management with Riverpod

```dart
// Game state provider
final cpuGameProvider = StateNotifierProvider<CpuGameNotifier, CpuGameState>((ref) {
  return CpuGameNotifier();
});

// AI move provider
final aiMoveProvider = FutureProvider<String>((ref) async {
  return ref.read(cpuGameProvider).getAIMove();
});

// Board state provider
final boardProvider = Provider((ref) {
  return ref.watch(cpuGameProvider).board;
});
```

### Move Validation Flow

```
User Input (from, to)
    ↓
Validate Move
    ├─ In bounds?
    ├─ Piece exists?
    ├─ Legal move?
    └─ Not pinned?
    ↓
Apply Move
    ├─ Update board
    ├─ Check for checks/mates
    └─ Log move
    ↓
Trigger AI
```

---

## Implementation Guide

### File Structure

```
lib/src/
├── services/
│   ├── chess_engine_service.dart (existing)
│   ├── ai_opponent_engine.dart (NEW)
│   └── game_manager.dart (NEW)
├── providers/
│   ├── cpu_game_provider.dart (update)
│   ├── ai_move_provider.dart (NEW)
│   └── game_state_provider.dart (NEW)
├── models/
│   ├── game.dart (update)
│   ├── cpu_game_state.dart (NEW)
│   └── ai_difficulty.dart (NEW)
├── widgets/
│   ├── chess_board.dart (update)
│   ├── game_board.dart (NEW)
│   ├── difficulty_selector.dart (NEW)
│   ├── game_result.dart (NEW)
│   ├── move_history.dart (NEW)
│   └── captured_pieces.dart (NEW)
└── screens/
    ├── game/
    │   ├── cpu_game_screen.dart (update)
    │   └── game_result_screen.dart (NEW)
```

### Key Implementation Details

#### 1. AI Opponent Engine

```dart
class AIOpponentEngine {
  final ChessEngineService chess;
  final Difficulty difficulty;
  late int _searchDepth;
  
  AIOpponentEngine(this.chess, this.difficulty) {
    _searchDepth = difficulty.searchDepth;
  }
  
  Future<String> getNextMove() async {
    return compute(_findBestMoveSync, null);
  }
  
  String _findBestMoveSync(_) {
    final bestMove = _minimax(_searchDepth, -infinity, +infinity, true);
    return bestMove.toUCI();
  }
}
```

#### 2. Position Evaluator

```dart
class PositionEvaluator {
  static const materialValues = {
    'p': 1,
    'n': 3,
    'b': 3,
    'r': 5,
    'q': 9,
  };
  
  int evaluate(ChessEngineService chess) {
    int score = 0;
    
    // Material
    score += materialScore(chess);
    
    // Positional (if not Easy)
    if (difficulty != Difficulty.easy) {
      score += positionScore(chess);
    }
    
    return score;
  }
}
```

#### 3. Move Ordering

```dart
List<Move> orderMoves(List<Move> moves, ChessEngineService chess) {
  final scored = moves.map((move) {
    int score = 0;
    
    // Captures first (MVV/LVA)
    if (move.flags.contains('c')) {
      score += 100 + victimValue(move) - attackerValue(move);
    }
    
    // Checks second
    chess.makeMove(move);
    if (chess.isCheck()) score += 50;
    chess.undoMove();
    
    // Quiet moves
    score += historyHeuristic[move] ?? 0;
    
    return MapEntry(move, score);
  });
  
  scored.sort((a, b) => b.value.compareTo(a.value));
  return scored.map((e) => e.key).toList();
}
```

### Integration with Phase I & II

- Uses existing ChessEngineService from Phase I
- Displays results using charts from Phase II
- Integrates with performance analytics for rating changes
- Uses Theme-aware colors from Phase II

---

## Testing Strategy

### Unit Tests

#### AI Engine Tests (20+ tests)
- Checkmate detection accuracy
- Stalemate detection accuracy
- Move legality validation
- Position evaluation correctness
- Minimax algorithm correctness
- Alpha-beta pruning effectiveness

#### Position Evaluator Tests (15+ tests)
- Material count accuracy
- Pawn structure evaluation
- Piece mobility calculation
- Endgame recognition
- Tempo evaluation

#### Move Ordering Tests (10+ tests)
- Capture ordering correctness
- Check detection
- History heuristic application

### Widget Tests

#### ChessBoard Tests (12+ tests)
- Piece rendering correctness
- Move highlighting accuracy
- Drag-and-drop interaction
- Legal move calculation
- Board flip functionality

#### Game Flow Tests (15+ tests)
- Turn management
- Move validation
- Game state transitions
- Result screen display
- Move history accuracy

#### Difficulty Selector Tests (5+ tests)
- Difficulty selection
- AI thinking time accuracy
- Difficulty persistence

### Integration Tests

#### Complete Game Flow (8+ tests)
- New game initialization
- Player move → AI move sequence
- Checkmate detection
- Game saving/loading
- Rating updates

---

## Performance Considerations

### AI Optimization

1. **Caching**
   - Transposition table for repeated positions
   - Killer move heuristic
   - History heuristic for quiet moves

2. **Compute Isolation**
   - Run minimax in separate isolate
   - Don't block UI during AI thinking
   - Show loading indicator

3. **Search Limitations**
   - Time limits per difficulty
   - Move count limits in endgame
   - Repetition detection

### Memory Management

- Board state: ~1KB per game
- Move history: ~100 bytes per move
- Cache limit: 10MB for transposition table
- Isolate cleanup after AI move

### UI Performance

- Smooth 60fps piece animations
- Debounced piece selection
- Efficient redraw on move changes
- Memoized widget rebuilds

---

## Dependencies

**New Package Required**:
```yaml
# Already in pubspec.yaml
chess: ^0.7.0

# No new dependencies for Phase III
```

All AI algorithms implemented natively in Dart for optimal performance and portability.

---

## Implementation Checklist

### AI Engine Development
- [ ] Implement AIOpponentEngine class
- [ ] Implement PositionEvaluator with material count
- [ ] Implement minimax algorithm
- [ ] Implement alpha-beta pruning
- [ ] Implement move ordering
- [ ] Add positional evaluation for Medium/Hard
- [ ] Implement difficulty levels
- [ ] Optimize with transposition tables (optional)

### Widget Development
- [ ] Enhance ChessBoard with piece selection
- [ ] Add move highlighting
- [ ] Implement drag-and-drop
- [ ] Create DifficultySelector widget
- [ ] Create GameBoard container
- [ ] Create MoveHistory widget
- [ ] Create CapturedPieces widget
- [ ] Create GameResult screen

### Game Flow
- [ ] Implement game state management
- [ ] Implement turn management
- [ ] Add move validation
- [ ] Add check/checkmate detection
- [ ] Implement result screen
- [ ] Add game save/load
- [ ] Add undo functionality

### Testing
- [ ] Write AI engine tests (20+)
- [ ] Write position evaluator tests (15+)
- [ ] Write move ordering tests (10+)
- [ ] Write chess board tests (12+)
- [ ] Write game flow tests (15+)
- [ ] Write difficulty selector tests (5+)
- [ ] Write integration tests (8+)
- [ ] Manual testing on devices

---

## Success Metrics

### AI Quality
- Easy mode: Beat beginner players 30-40% of time
- Medium mode: Beat intermediate players 50-60% of time
- Hard mode: Beat advanced players 60-70% of time
- No illegal moves generated

### Performance
- AI move calculation < 2 seconds on Easy
- AI move calculation < 5 seconds on Medium
- AI move calculation < 10 seconds on Hard
- No UI freezing during AI thinking
- Memory usage < 100MB peak

### UX Quality
- Smooth piece animations (60fps)
- Responsive move input (< 200ms feedback)
- Clear legal move indicators
- Intuitive difficulty selection
- Accessible result screen

---

## Future Enhancements

### Phase IV+
1. **Opening Book**
   - Pre-computed opening moves
   - Transposition table for midgame
   - Endgame tablebases

2. **Advanced Features**
   - Game analysis with evaluation bar
   - Engine match replay
   - Computer vs Computer games
   - Puzzle mode with hints

3. **Machine Learning**
   - Neural network evaluation
   - Training on game databases
   - Adaptive difficulty

4. **Online Features**
   - Upload and analyze games
   - Compare with other players' games
   - Shared game collections

---

## Document Version
**Version**: 1.0  
**Last Updated**: 2026-08-26  
**Status**: ✅ Ready for Implementation
