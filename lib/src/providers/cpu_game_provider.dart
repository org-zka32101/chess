import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game.dart';
import '../services/chess_engine_service.dart';

/// CPU game state
class CPUGameState {
  final String gameId;
  final ChessEngineService engine;
  final GameModel game;
  final bool isThinking;
  final String? error;

  CPUGameState({
    required this.gameId,
    required this.engine,
    required this.game,
    this.isThinking = false,
    this.error,
  });

  CPUGameState copyWith({
    String? gameId,
    ChessEngineService? engine,
    GameModel? game,
    bool? isThinking,
    String? error,
  }) {
    return CPUGameState(
      gameId: gameId ?? this.gameId,
      engine: engine ?? this.engine,
      game: game ?? this.game,
      isThinking: isThinking ?? this.isThinking,
      error: error ?? this.error,
    );
  }
}

/// CPU Game Service
class CPUGameService {
  final FirebaseFirestore _firestore;

  CPUGameService(this._firestore);

  /// Create a new CPU game
  Future<GameModel> createCPUGame({
    required String timeControl,
    required String difficulty, // 'easy', 'medium', 'hard'
  }) async {
    try {
      // Generate unique game ID
      final gameId = _firestore.collection('games').doc().id;

      // Parse time control
      final timeControlMs = _parseTimeControl(timeControl);

      // Determine user color (randomly)
      final isPlayerWhite = DateTime.now().millisecond % 2 == 0;

      final gameData = {
        'gameId': gameId,
        'type': 'cpu',
        'status': 'active',
        'difficulty': difficulty,
        'whitePlayerId': isPlayerWhite ? 'player' : 'cpu',
        'blackPlayerId': isPlayerWhite ? 'cpu' : 'player',
        'whitePlayerName': isPlayerWhite ? 'You' : 'Chess Engine',
        'blackPlayerName': isPlayerWhite ? 'Chess Engine' : 'You',
        'whiteRating': 1600,
        'blackRating': 1600,
        'currentFen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        'moves': [],
        'pgn': '',
        'timeControl': timeControl,
        'timeControlMs': timeControlMs,
        'whiteTimeRemainingMs': timeControlMs,
        'blackTimeRemainingMs': timeControlMs,
        'result': null,
        'resultReason': null,
        'createdAt': FieldValue.serverTimestamp(),
        'startedAt': FieldValue.serverTimestamp(),
        'endedAt': null,
      };

      // Save to Firestore
      await _firestore.collection('games').doc(gameId).set(gameData);

      return GameModel.fromJson({
        ...gameData,
        'createdAt': DateTime.now(),
        'startedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to create CPU game: $e');
    }
  }

  /// Get CPU game by ID
  Future<GameModel?> getCPUGame(String gameId) async {
    try {
      final doc = await _firestore.collection('games').doc(gameId).get();

      if (doc.exists) {
        return GameModel.fromJson({
          ...doc.data()!,
          'gameId': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get CPU game: $e');
    }
  }

  /// Make a move in CPU game
  Future<void> makePlayerMove({
    required String gameId,
    required String from,
    required String to,
    String? promotion,
  }) async {
    try {
      final gameDoc = await _firestore.collection('games').doc(gameId).get();

      if (!gameDoc.exists) throw Exception('Game not found');

      final gameData = gameDoc.data() as Map<String, dynamic>;
      final currentMoves = List<Map<String, dynamic>>.from(gameData['moves'] ?? []);

      // Create move record
      final moveRecord = {
        'from': from,
        'to': to,
        'promotion': promotion,
        'timestamp': FieldValue.serverTimestamp(),
        'playerId': 'player',
      };

      currentMoves.add(moveRecord);

      // Update game
      await _firestore.collection('games').doc(gameId).update({
        'moves': currentMoves,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to make move: $e');
    }
  }

  /// Make CPU move (auto-generated)
  Future<void> makeCPUMove({
    required String gameId,
    required ChessEngineService engine,
    required String difficulty,
  }) async {
    try {
      // Get best moves based on difficulty
      final bestMoves = engine.getBestMoves(depth: _getDifficultyDepth(difficulty));

      if (bestMoves.isEmpty) {
        // Game is over
        return;
      }

      // Select move based on difficulty
      final move = _selectMoveByDifficulty(bestMoves, difficulty);
      if (move == null) return;

      // Make the move
      engine.makeMove(move.fromAlgebraic, move.toAlgebraic,
          promotion: move.promotion?.toString());

      final gameDoc = await _firestore.collection('games').doc(gameId).get();

      if (!gameDoc.exists) throw Exception('Game not found');

      final gameData = gameDoc.data() as Map<String, dynamic>;
      final currentMoves = List<Map<String, dynamic>>.from(gameData['moves'] ?? []);

      // Create move record
      final moveRecord = {
        'from': move.fromAlgebraic,
        'to': move.toAlgebraic,
        'promotion': move.promotion?.toString(),
        'timestamp': FieldValue.serverTimestamp(),
        'playerId': 'cpu',
      };

      currentMoves.add(moveRecord);

      // Check game status
      String? result;
      String? resultReason;

      if (engine.isCheckmate()) {
        result = engine.isWhiteTurn() ? 'black_win' : 'white_win';
        resultReason = 'checkmate';
      } else if (engine.isStalemate()) {
        result = 'draw';
        resultReason = 'stalemate';
      }

      // Update game
      await _firestore.collection('games').doc(gameId).update({
        'moves': currentMoves,
        'currentFen': engine.getCurrentFen(),
        'result': result,
        'resultReason': resultReason,
        'status': result != null ? 'completed' : 'active',
        'endedAt': result != null ? FieldValue.serverTimestamp() : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to make CPU move: $e');
    }
  }

  /// End CPU game with resignation
  Future<void> resignGame(String gameId) async {
    try {
      final gameDoc = await _firestore.collection('games').doc(gameId).get();

      if (!gameDoc.exists) throw Exception('Game not found');

      final gameData = gameDoc.data() as Map<String, dynamic>;

      // CPU wins by resignation
      await _firestore.collection('games').doc(gameId).update({
        'status': 'completed',
        'result': 'cpu_win',
        'resultReason': 'resignation',
        'endedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to resign game: $e');
    }
  }

  /// Helper: parse time control string to milliseconds
  int _parseTimeControl(String timeControl) {
    final value = int.tryParse(timeControl.replaceAll(RegExp(r'[^0-9]'), '')) ?? 5;

    if (timeControl.contains('h')) {
      return value * 60 * 60 * 1000;
    } else if (timeControl.contains('min')) {
      return value * 60 * 1000;
    } else if (timeControl.contains('s')) {
      return value * 1000;
    }

    return value * 60 * 1000;
  }

  /// Get search depth based on difficulty
  int _getDifficultyDepth(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 1;
      case 'medium':
        return 2;
      case 'hard':
        return 3;
      default:
        return 2;
    }
  }

  /// Select move based on difficulty
  dynamic _selectMoveByDifficulty(List<dynamic> bestMoves, String difficulty) {
    if (bestMoves.isEmpty) return null;

    switch (difficulty.toLowerCase()) {
      case 'easy':
        // Pick random move from all available
        bestMoves.shuffle();
        return bestMoves.last;
      case 'medium':
        // Pick from top 50%
        final topHalf = (bestMoves.length / 2).ceil();
        bestMoves.shuffle();
        return bestMoves.sublist(0, topHalf).first;
      case 'hard':
        // Pick the best move
        return bestMoves.first;
      default:
        return bestMoves.first;
    }
  }
}

// Riverpod Providers
final cpuGameServiceProvider = Provider((ref) {
  final firestore = FirebaseFirestore.instance;
  return CPUGameService(firestore);
});

/// CPU game state provider
final cpuGameStateProvider =
    StateNotifierProvider.family<CPUGameStateNotifier, CPUGameState, String>((ref, gameId) {
  return CPUGameStateNotifier(gameId, ref);
});

/// CPU game state notifier
class CPUGameStateNotifier extends StateNotifier<CPUGameState> {
  final String gameId;
  final Ref ref;

  CPUGameStateNotifier(this.gameId, this.ref)
      : super(CPUGameState(
          gameId: gameId,
          engine: ChessEngineService(),
          game: GameModel(
            gameId: gameId,
            type: 'cpu',
            status: 'active',
            whitePlayerId: '',
            blackPlayerId: '',
            whiteRating: 1600,
            blackRating: 1600,
            moves: [],
          ),
        ));

  /// Make a player move
  Future<void> makeMove(String from, String to, {String? promotion}) async {
    try {
      state = state.copyWith(isThinking: true, error: null);

      final service = ref.read(cpuGameServiceProvider);
      final engine = state.engine;

      // Make player move
      final success = engine.makeMove(from, to, promotion: promotion);
      if (!success) {
        state = state.copyWith(
          isThinking: false,
          error: 'Invalid move',
        );
        return;
      }

      // Update game state
      await service.makePlayerMove(
        gameId: gameId,
        from: from,
        to: to,
        promotion: promotion,
      );

      // Check if game is over
      if (engine.isGameOver()) {
        final result = engine.getGameResult();
        state = state.copyWith(isThinking: false);
        return;
      }

      // Make CPU move
      await service.makeCPUMove(
        gameId: gameId,
        engine: engine,
        difficulty: 'medium',
      );

      state = state.copyWith(isThinking: false);
    } catch (e) {
      state = state.copyWith(
        isThinking: false,
        error: e.toString(),
      );
    }
  }

  /// Resign game
  Future<void> resign() async {
    try {
      final service = ref.read(cpuGameServiceProvider);
      await service.resignGame(gameId);
      state = state.copyWith(
        game: state.game.copyWith(status: 'completed'),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

/// Watch CPU game updates
final cpuGameStreamProvider =
    StreamProvider.family<GameModel?, String>((ref, gameId) {
  final firestore = FirebaseFirestore.instance;

  return firestore.collection('games').doc(gameId).snapshots().map((snapshot) {
    if (snapshot.exists) {
      return GameModel.fromJson({
        ...snapshot.data()!,
        'gameId': snapshot.id,
      });
    }
    return null;
  });
});
