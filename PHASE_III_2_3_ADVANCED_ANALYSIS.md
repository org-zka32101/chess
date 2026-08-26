# Phase III.2.3: Advanced Analysis Features

## Overview

This phase adds sophisticated analysis features to deepen understanding of engine decisions and performance characteristics.

**Status**: Implementation in progress
**Estimated Completion**: Current sprint

---

## 1. Principal Variation Display

### 1.1 Principal Variation (PV) Concepts

The **principal variation** is the best line of play that the engine found during its analysis. It represents the expected sequence of moves if both sides play optimally from the current position.

```
Example PV: e2e4 c7c5 g1f3 d7d6 d2d4 c5d4
Meaning: White plays 1.e4, Black responds 1...c5, etc.
```

#### Why PV Matters

1. **Move Understanding**: Shows WHY the engine chose this move
2. **Line Evaluation**: Displays the evaluation of the best line
3. **Depth Information**: Shows how deep the search went
4. **Confidence Metric**: Indicates certainty in the line

### 1.2 Principal Variation Display Widget

**File**: `lib/src/widgets/principal_variation_display.dart` (400+ lines)

#### Features

**Single PV Display** (`PrincipalVariationDisplay`):
```dart
PrincipalVariationDisplay(
  principalVariation: ['e2e4', 'c7c5', 'g1f3'],
  evaluation: 45,  // +45 centipawns
  depth: 4,
  isBestLine: true,
  confidence: 0.85,  // 85% confidence
)
```

Visual representation:
```
┌─────────────────────────────────┐
│ Best Line              D4  +45   │
├─────────────────────────────────┤
│ Confidence: 85%                 │
│ [████████░░░] ████████         │
├─────────────────────────────────┤
│ Line continues for 3 moves      │
│                                 │
│ [1.] [e2e4] [c7c5] [g1f3]      │
└─────────────────────────────────┘
```

**Multiple PV Display** (`PrincipalVariationsPanel`):
- Shows top 5 variations by default
- Expandable to view full details
- Best line highlighted
- Quick comparison of alternatives

### 1.3 PV Data Structure

```dart
class PVLine {
  final List<String> moves;           // ['e2e4', 'c7c5', ...]
  final int evaluation;               // +45 (centipawns)
  final int depth;                    // 4 (plies)
  final double confidence;            // 0.85 (0.0-1.0)
  final int nodesSearched;            // 45320
  final int timeMs;                   // 1234
}
```

#### Creating PV Data

From engine analysis:
```dart
// After engine.getBestMove()
final stats = engine.getSearchStats();

// Construct PV from search results
final pv = PVLine(
  moves: extractBestLine(chess),
  evaluation: stats['evaluation'] ?? 0,
  depth: stats['depth'] ?? 0,
  confidence: calculateConfidence(stats),
  nodesSearched: stats['nodesEvaluated'] ?? 0,
  timeMs: stopwatch.elapsedMilliseconds,
);
```

---

## 2. Performance Graphs

### 2.1 Performance Metrics Visualization

**File**: `lib/src/widgets/performance_graphs.dart` (500+ lines)

Displays performance trends across the game with interactive metric selection.

#### Available Metrics

1. **Nodes/Sec** - Evaluation speed over time
   - Shows search speed trends
   - Indicates branching factor changes
   - Color: Blue

2. **Cache Hit %** - Zobrist cache efficiency over time
   - Shows cache maturation
   - Indicates position repetition
   - Color: Green

3. **Search Depth** - Depth achieved by move
   - Shows time allocation
   - Indicates position complexity
   - Color: Purple

4. **Time/Move** - Milliseconds per move
   - Shows timing consistency
   - Indicates position difficulty
   - Color: Orange

5. **Killer Effectiveness** - Killer move cutoffs per move
   - Shows heuristic usage
   - Indicates tactical positions
   - Color: Red

6. **Countermove Effectiveness** - Countermove cutoffs per move
   - Shows position-aware ordering
   - Indicates learned patterns
   - Color: Teal

#### Visual Representation

```
Nodes/Sec Performance Over Game
────────────────────────────────

30K ┤ 
    │     ╱╲   
25K ┤    ╱  ╲╱╲    ╱╲
    │   ╱      ╲  ╱  ╲
20K ┤  ╱        ╲╱    ╲
    │ ╱
    └────────────────────
    1  4  8  12 16 20 24

Max: 28K  Avg: 22K  Min: 18K
```

#### Statistics Display

Shows for each metric:
- **Max**: Peak value (best performance)
- **Avg**: Average across game
- **Min**: Minimum value (worst performance)

### 2.2 Performance Data Collection

```dart
class MoveMetrics {
  final int moveNumber;
  final int nodesEvaluated;
  final int timeMs;
  final int depth;
  final double cacheHitRate;
  final int zobristHits;
  final int zobristMisses;
  final int killerCutoffs;
  final int countermoveCutoffs;
  final String gamePhase;  // opening/midgame/endgame
}

// Create from engine statistics
final metrics = MoveMetrics.fromEngineStats(
  moveNumber: moveCount,
  stats: engine.getSearchStats(),
  timeMs: stopwatch.elapsedMilliseconds,
);
```

### 2.3 Integration with Game Screen

```dart
// Collect metrics per AI move
List<MoveMetrics> allMetrics = [];

// After each AI move
final metrics = MoveMetrics.fromEngineStats(
  moveNumber: moveCount,
  stats: aiEngine.getSearchStats(),
  timeMs: stopwatch.elapsedMilliseconds,
);
allMetrics.add(metrics);

// Display in separate screen/tab
PerformanceGraphs(
  moveMetrics: allMetrics,
  selectedMetric: PerformanceMetric.nodesPerSecond,
  onMetricChanged: (metric) {
    // Update displayed graph
  },
)
```

---

## 3. Move Learning Visualization

### 3.1 Heuristic Learning Patterns

Visualize how the engine learns during search:

**Killer Move Patterns**:
- Show which moves cause cutoffs at each depth
- Indicate moves learned during search
- Display effectiveness trends

**Countermove Patterns**:
- Show position-aware learning
- Indicate opponent move → counter relationships
- Display effectiveness by position type

### 3.2 Learning Visualization Widget

```dart
class HeuristicLearningPanel extends StatelessWidget {
  final List<MoveMetrics> metrics;
  final Map<String, dynamic> currentStats;

  // Display:
  // - Killer move discovery timeline
  // - Countermove pair formations
  // - Effectiveness trends per heuristic
  // - Learning speed metrics
}
```

### 3.3 Learning Metrics

**Killer Move Learning**:
```
Move Number    Cutoffs    New Killers
────────────────────────────────────
1-5            12         3 (e.g., e4, d4, Nf3)
6-10           18         2 (refinement)
11-15          22         1 (stabilization)
16-20          25         0 (mature)
```

**Countermove Learning**:
```
Opponent Move    Discovered Countermoves
─────────────────────────────────────────
c7-c5 (Sicilian)  d2-d4, c2-c3, g1-f3
e7-e5 (Italian)   f1-c4, g1-f3, b1-c3
a7-a6 (Flank)     b2-b3, c1-b2 (quiet)
```

---

## 4. Game Statistics & History

### 4.1 Game Analysis Summary

After each game, collect and display:

**Basic Stats**:
- Total moves played
- AI moves count
- Total thinking time
- Average time per AI move
- Game result (win/loss/draw)

**Performance Stats**:
- Average nodes/sec
- Average cache hit rate
- Average search depth
- Heuristic effectiveness percentages

**Learning Stats**:
- Killer moves discovered
- Countermove pairs formed
- Aged moves used
- Aging effectiveness

### 4.2 Game History Tracking

**Stored Per Game**:
```dart
class SavedGame {
  final String gameId;
  final DateTime playedAt;
  final AIDifficulty difficulty;
  final GameResult result;
  final int totalMoves;
  final int totalTimeMs;
  final double avgCacheHitRate;
  final double avgNodesPerSec;
  final List<MoveMetrics> allMetrics;
  final List<PVLine> pvHistory;
}
```

### 4.3 Trend Analysis Across Games

**Example Tracking**:
```
Game 1 (Easy):   Avg 18K nodes/sec, 45% cache hit
Game 2 (Easy):   Avg 19K nodes/sec, 48% cache hit
Game 3 (Easy):   Avg 21K nodes/sec, 52% cache hit
────────────────────────────────────────────────────
Trend: Improving with experience!
       +1.5K nodes/sec per game
       +3.5% cache hit per game
```

---

## 5. Integration Examples

### 5.1 Adding to Game Screen

```dart
class CPUGameAnalysisScreen extends StatefulWidget {
  List<MoveMetrics> moveMetrics = [];
  List<PVLine> pvHistory = [];

  @override
  build(BuildContext context) {
    return TabBarView(
      children: [
        // Tab 1: Game view with PV display
        Column(
          children: [
            ChessBoard(),
            PrincipalVariationDisplay(
              principalVariation: currentPV.moves,
              evaluation: currentPV.evaluation,
              depth: currentPV.depth,
              confidence: currentPV.confidence,
            ),
          ],
        ),

        // Tab 2: Performance graphs
        PerformanceGraphs(
          moveMetrics: moveMetrics,
          selectedMetric: PerformanceMetric.nodesPerSecond,
        ),

        // Tab 3: Game statistics
        GameStatisticsPanel(
          metrics: moveMetrics,
          pvHistory: pvHistory,
        ),
      ],
    );
  }
}
```

### 5.2 Real-Time Updates

```dart
// During game play
Future<void> _makeAIMove() async {
  final stopwatch = Stopwatch()..start();
  
  final move = aiEngine.getBestMove();
  stopwatch.stop();
  
  // Get all data
  final stats = aiEngine.getSearchStats();
  
  // Create metrics
  final metrics = MoveMetrics.fromEngineStats(
    moveNumber: moveCount,
    stats: stats,
    timeMs: stopwatch.elapsedMilliseconds,
  );
  moveMetrics.add(metrics);
  
  // Update PV display
  setState(() {
    currentPV = PVLine(
      moves: extractBestLine(chess),
      evaluation: stats['evaluation'] ?? 0,
      depth: stats['depth'] ?? 0,
    );
  });
}
```

---

## 6. Expected Insights

### 6.1 From PV Analysis

**Opening Phase**:
- PV often comes from opening book
- Depth shallow (1-2 plies)
- Confidence high (book moves)

**Midgame Phase**:
- PV from deep search
- Depth moderate (3-4 plies)
- Confidence medium (learned positions)

**Endgame Phase**:
- PV from highly transposed positions
- Depth variable (1-4 plies)
- Confidence high (familiar positions)

### 6.2 From Performance Graphs

**Nodes/Sec Pattern**:
```
Opening:   ~20K (book + quick search)
Midgame:   ~25K (high branching)
Endgame:   ~18K (low branching)
```

**Cache Hit Pattern**:
```
Opening:   40-50% (new positions)
Midgame:   60-75% (cache growth)
Endgame:   75-85% (position repetition)
```

**Depth Achievement**:
```
Easy:      2-3 plies average
Medium:    3-4 plies average
Hard:      4-5 plies average
```

### 6.3 Learning Trends

**Heuristic Effectiveness**:
- Killer moves: More effective in midgame
- Countermoves: More effective in known positions
- Aging: Prevents stale patterns

**Performance Improvement**:
- Cache hit rates stabilize after 10-15 moves
- Search speed improves as transposition table fills
- Heuristic learning accelerates in familiar positions

---

## 7. Testing & Validation

### 7.1 PV Accuracy Tests

```dart
test('PV moves are legal', () {
  final pv = PVLine(
    moves: ['e2e4', 'c7c5', 'g1f3'],
    evaluation: 45,
    depth: 3,
  );
  
  // Verify each move is legal in sequence
  for (final move in pv.moves) {
    expect(isLegalMove(move), true);
  }
});

test('PV evaluation is consistent with position', () {
  // Play PV line
  // Evaluate resulting position
  // Should match PV evaluation (approximately)
});
```

### 7.2 Performance Graph Tests

```dart
test('graphs display correct metric data', () {
  final metrics = [
    MoveMetrics(..., nodesEvaluated: 1000, timeMs: 50),
    MoveMetrics(..., nodesEvaluated: 2000, timeMs: 100),
    // ...
  ];
  
  final graph = PerformanceGraphs(moveMetrics: metrics);
  
  // Verify nodes/sec calculated correctly
  // 1000 / 0.05 = 20K nodes/sec ✓
});
```

---

## 8. Future Enhancements

### 8.1 Short Term

1. **PV Trends**
   - Track PV stability across moves
   - Show when AI changes its mind
   - Indicate position shifting from W to B

2. **Performance Anomalies**
   - Alert on unusual slowdowns
   - Identify position complexity spikes
   - Suggest when opening book ended

3. **Learning Analytics**
   - Show killer move discovery timeline
   - Display countermove formation patterns
   - Indicate aging effectiveness

### 8.2 Long Term

1. **AI vs AI Analysis**
   - Compare PVs between engines
   - Identify tactical disagreements
   - Measure position understanding

2. **Opening System Learning**
   - Track which systems engine prefers
   - Show opening book effectiveness
   - Suggest additional book positions

3. **Player Learning**
   - Recommend lines to study from games
   - Suggest opening preparation areas
   - Identify weakness exploitation

---

## Summary

Phase III.2.3 provides:

✅ **Principal Variation Display**
- Single and multiple PV widgets
- Confidence scoring
- Depth and evaluation tracking
- Visual representation

✅ **Performance Graphs**
- 6 different metrics
- Interactive selection
- Statistics summary (Max/Avg/Min)
- Trend visualization

✅ **Move Learning Visualization**
- Heuristic discovery tracking
- Effectiveness trends
- Learning speed metrics

✅ **Game Statistics Collection**
- Per-move metrics
- Game-level summaries
- Performance trends
- Learning indicators

✅ **Integration Framework**
- Real-time data collection
- Dashboard display
- Historical tracking
- Trend analysis

**Ready for**: Phase III.2.4 (Game History & Statistics) → Performance Optimization → Production

---

*Phase III.2.3 - Advanced Analysis Features*
*Completion Target: Current Sprint*
