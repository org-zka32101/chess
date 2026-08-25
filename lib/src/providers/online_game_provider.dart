import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game.dart';
import '../services/chess_engine_service.dart';

/// Online game state with real-time synchronization
class OnlineGameState {
  final String gameId;
  final GameModel game;
  final ChessEngineService engine;
  final bool isSyncingMove;
  final String? lastError;
  final DateTime? lastSyncTime;

  OnlineGameState({
    required this.gameId,
    required this.game,
    required this.engine,
    this.isSyncingMove = false,
    this.lastError,
    this.lastSyncTime,
  });

  OnlineGameState copyWith({
    String? gameId,
    GameModel? game,
    ChessEngineService? engine,
    bool? isSyncingMove,
    String? lastError,
    DateTime? lastSyncTime,
  }) {
    return OnlineGameState(
      gameId: gameId ?? this.gameId,
      game: game ?? this.game,
      engine: engine ?? this.engine,
      isSyncingMove: isSyncingMove ?? this.isSyncingMove,
      lastError: lastError,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

/// Online game service with real-time sync
class OnlineGameService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  OnlineGameService(this._firestore, this._auth);

  /// Make a move in online game with sync
  Future<void> makeOnlineMove({
    required String gameId,
    required String from,
    required String to,
    String? promotion,
    required ChessEngineService engine,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      final gameRef = _firestore.collection('games').doc(gameId);
      final gameDoc = await gameRef.get();

      if (!gameDoc.exists) throw Exception('Game not found');

      final gameData = gameDoc.data() as Map<String, dynamic>;

      // Validate it's the current player's turn
      final whitePlayerId = gameData['whitePlayerId'] as String;
      final isUserWhite = user.uid == whitePlayerId;
      final isWhiteTurn = (gameData['moves'] as List).length % 2 == 0;

      if (isUserWhite != isWhiteTurn) {
        throw Exception('Not your turn');
      }

      // Validate move locally first
      if (!engine.isLegalMove(from, to, promotion: promotion)) {
        throw Exception('Illegal move');
      }

      // Execute move on local engine
      engine.makeMove(from, to, promotion: promotion);

      // Prepare move record
      final moveRecord = {
        'from': from,
        'to': to,
        'promotion': promotion,
        'timestamp': FieldValue.serverTimestamp(),
        'playerId': user.uid,
      };

      // Prepare game update
      final currentMoves = List<Map<String, dynamic>>.from(gameData['moves'] ?? []);
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

      // Update Firestore with new move
      await gameRef.update({
        'moves': currentMoves,
        'currentFen': engine.getCurrentFen(),
        'result': result,
        'resultReason': resultReason,
        'status': result != null ? 'completed' : 'active',
        'endedAt': result != null ? FieldValue.serverTimestamp() : null,
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMoveBy': user.uid,
        'lastMoveAt': FieldValue.serverTimestamp(),
      });

      // Update ratings if game ended
      if (result != null) {
        await _updateRatingsAfterGame(gameId, gameData, result);
      }
    } catch (e) {
      throw Exception('Failed to make move: $e');
    }
  }

  /// Handle move received from opponent (via real-time sync)
  Future<void> handleOpponentMove({
    required String gameId,
    required ChessEngineService engine,
  }) async {
    try {
      final gameDoc = await _firestore.collection('games').doc(gameId).get();

      if (!gameDoc.exists) throw Exception('Game not found');

      final gameData = gameDoc.data() as Map<String, dynamic>;
      final moves = gameData['moves'] as List? ?? [];

      // Rebuild engine state from moves
      engine.reset();
      for (final move in moves.cast<Map<String, dynamic>>()) {
        final from = move['from'] as String;
        final to = move['to'] as String;
        final promotion = move['promotion'] as String?;
        engine.makeMove(from, to, promotion: promotion);
      }
    } catch (e) {
      throw Exception('Failed to sync opponent move: $e');
    }
  }

  /// Resign online game
  Future<void> resignGame(String gameId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      final gameRef = _firestore.collection('games').doc(gameId);
      final gameDoc = await gameRef.get();

      if (!gameDoc.exists) throw Exception('Game not found');

      final gameData = gameDoc.data() as Map<String, dynamic>;
      final whitePlayerId = gameData['whitePlayerId'] as String;

      // Determine result based on who resigned
      final isUserWhite = user.uid == whitePlayerId;
      final result = isUserWhite ? 'black_win' : 'white_win';

      await gameRef.update({
        'status': 'completed',
        'result': result,
        'resultReason': 'resignation',
        'resignedBy': user.uid,
        'endedAt': FieldValue.serverTimestamp(),
      });

      // Update ratings
      final gameModel = GameModel.fromJson({
        ...gameData,
        'gameId': gameId,
      });
      await _updateRatingsAfterGame(gameId, gameData, result);
    } catch (e) {
      throw Exception('Failed to resign game: $e');
    }
  }

  /// Offer draw
  Future<void> offerDraw(String gameId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      await _firestore.collection('games').doc(gameId).update({
        'drawOfferBy': user.uid,
        'drawOfferAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to offer draw: $e');
    }
  }

  /// Accept draw offer
  Future<void> acceptDraw(String gameId) async {
    try {
      await _firestore.collection('games').doc(gameId).update({
        'status': 'completed',
        'result': 'draw',
        'resultReason': 'draw_agreement',
        'endedAt': FieldValue.serverTimestamp(),
      });

      // Update ratings (both get 0 rating change for draw)
      final gameDoc = await _firestore.collection('games').doc(gameId).get();
      if (gameDoc.exists) {
        final gameData = gameDoc.data() as Map<String, dynamic>;
        await _updateRatingsAfterGame(gameId, gameData, 'draw');
      }
    } catch (e) {
      throw Exception('Failed to accept draw: $e');
    }
  }

  /// Decline draw offer
  Future<void> declineDraw(String gameId) async {
    try {
      await _firestore.collection('games').doc(gameId).update({
        'drawOfferBy': FieldValue.delete(),
        'drawOfferAt': FieldValue.delete(),
      });
    } catch (e) {
      throw Exception('Failed to decline draw: $e');
    }
  }

  /// Handle timeout for a player
  Future<void> handleTimeout(String gameId, String playerIdOutOfTime) async {
    try {
      final gameRef = _firestore.collection('games').doc(gameId);
      final gameDoc = await gameRef.get();

      if (!gameDoc.exists) throw Exception('Game not found');

      final gameData = gameDoc.data() as Map<String, dynamic>;
      final whitePlayerId = gameData['whitePlayerId'] as String;

      // Determine result
      final isWhiteOutOfTime = playerIdOutOfTime == whitePlayerId;
      final result = isWhiteOutOfTime ? 'black_win' : 'white_win';

      await gameRef.update({
        'status': 'completed',
        'result': result,
        'resultReason': 'timeout',
        'timeoutBy': playerIdOutOfTime,
        'endedAt': FieldValue.serverTimestamp(),
      });

      await _updateRatingsAfterGame(gameId, gameData, result);
    } catch (e) {
      throw Exception('Failed to handle timeout: $e');
    }
  }

  /// Update player ratings after game completion
  Future<void> _updateRatingsAfterGame(
    String gameId,
    Map<String, dynamic> gameData,
    String result,
  ) async {
    try {
      final whitePlayerId = gameData['whitePlayerId'] as String;
      final blackPlayerId = gameData['blackPlayerId'] as String;
      final whiteRating = gameData['whiteRating'] as int? ?? 1600;
      final blackRating = gameData['blackRating'] as int? ?? 1600;

      // Calculate rating changes (K=32 for standard rating)
      final ratingDeltas =
          _calculateRatingDeltas(result, whiteRating, blackRating);

      // Update white player
      await _firestore.collection('users').doc(whitePlayerId).update({
        'onlineRating': whiteRating + ratingDeltas['white']!,
        'gamesPlayed': FieldValue.increment(1),
        'wins': result.startsWith('white')
            ? FieldValue.increment(1)
            : FieldValue.increment(0),
        'losses': result == 'black_win'
            ? FieldValue.increment(1)
            : FieldValue.increment(0),
        'draws': result == 'draw' ? FieldValue.increment(1) : FieldValue.increment(0),
      });

      // Update black player
      await _firestore.collection('users').doc(blackPlayerId).update({
        'onlineRating': blackRating + ratingDeltas['black']!,
        'gamesPlayed': FieldValue.increment(1),
        'wins': result == 'black_win'
            ? FieldValue.increment(1)
            : FieldValue.increment(0),
        'losses': result.startsWith('white')
            ? FieldValue.increment(1)
            : FieldValue.increment(0),
        'draws': result == 'draw' ? FieldValue.increment(1) : FieldValue.increment(0),
      });

      // Update game with rating changes
      await _firestore.collection('games').doc(gameId).update({
        'whiteRatingDelta': ratingDeltas['white'],
        'blackRatingDelta': ratingDeltas['black'],
        'whiteNewRating': whiteRating + ratingDeltas['white']!,
        'blackNewRating': blackRating + ratingDeltas['black']!,
        'ratingsUpdated': true,
      });
    } catch (e) {
      print('Error updating ratings: $e');
      // Don't throw - game completion is still valid even if ratings fail
    }
  }

  /// Calculate ELO rating changes (K=32)
  Map<String, int> _calculateRatingDeltas(
    String result,
    int whiteRating,
    int blackRating,
  ) {
    const K = 32; // Standard K-factor

    // Calculate expected scores
    final whiteExpected =
        1.0 / (1.0 + pow(10, (blackRating - whiteRating) / 400).toDouble());
    final blackExpected = 1.0 - whiteExpected;

    // Determine actual scores
    double whiteActual, blackActual;
    if (result == 'white_win') {
      whiteActual = 1.0;
      blackActual = 0.0;
    } else if (result == 'black_win') {
      whiteActual = 0.0;
      blackActual = 1.0;
    } else {
      // Draw
      whiteActual = 0.5;
      blackActual = 0.5;
    }

    // Calculate rating changes
    final whiteChange =
        (K * (whiteActual - whiteExpected)).round();
    final blackChange =
        (K * (blackActual - blackExpected)).round();

    return {
      'white': whiteChange,
      'black': blackChange,
    };
  }

  /// Check for abandoned games (no move for 24 hours)
  Future<void> checkAndMarkAbandonedGames() async {
    try {
      final cutoffTime =
          DateTime.now().subtract(const Duration(hours: 24));

      final snapshot = await _firestore
          .collection('games')
          .where('status', isEqualTo: 'active')
          .where('updatedAt', isLessThan: cutoffTime)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.update({
          'status': 'abandoned',
          'abandonedBy': 'inactivity',
        });
      }
    } catch (e) {
      print('Error checking abandoned games: $e');
    }
  }
}

// Helper function
num pow(num base, num exponent) {
  return base ^ exponent;
}

// Riverpod Providers
final onlineGameServiceProvider = Provider((ref) {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  return OnlineGameService(firestore, auth);
});

/// Online game state notifier
class OnlineGameStateNotifier
    extends StateNotifier<OnlineGameState> {
  final String gameId;
  final Ref ref;

  OnlineGameStateNotifier(this.gameId, this.ref)
      : super(OnlineGameState(
          gameId: gameId,
          game: GameModel(
            gameId: gameId,
            type: 'online_pvp',
            status: 'active',
            whitePlayerId: '',
            blackPlayerId: '',
            whiteRating: 1600,
            blackRating: 1600,
            moves: [],
          ),
          engine: ChessEngineService(),
        )) {
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final gameDoc = await firestore.collection('games').doc(gameId).get();

      if (gameDoc.exists) {
        final game = GameModel.fromJson({
          ...gameDoc.data()!,
          'gameId': gameId,
        });

        final engine = ChessEngineService();
        engine.initGame(fen: game.currentFen);

        state = state.copyWith(
          game: game,
          engine: engine,
          lastSyncTime: DateTime.now(),
        );
      }
    } catch (e) {
      state = state.copyWith(lastError: e.toString());
    }
  }

  Future<void> makeMove(String from, String to, {String? promotion}) async {
    try {
      state = state.copyWith(isSyncingMove: true, lastError: null);

      final service = ref.read(onlineGameServiceProvider);
      await service.makeOnlineMove(
        gameId: gameId,
        from: from,
        to: to,
        promotion: promotion,
        engine: state.engine,
      );

      state = state.copyWith(
        isSyncingMove: false,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isSyncingMove: false,
        lastError: e.toString(),
      );
    }
  }

  Future<void> resign() async {
    try {
      final service = ref.read(onlineGameServiceProvider);
      await service.resignGame(gameId);
      state = state.copyWith(
        game: state.game.copyWith(status: 'completed'),
      );
    } catch (e) {
      state = state.copyWith(lastError: e.toString());
    }
  }

  Future<void> offerDraw() async {
    try {
      final service = ref.read(onlineGameServiceProvider);
      await service.offerDraw(gameId);
    } catch (e) {
      state = state.copyWith(lastError: e.toString());
    }
  }

  Future<void> acceptDraw() async {
    try {
      final service = ref.read(onlineGameServiceProvider);
      await service.acceptDraw(gameId);
      state = state.copyWith(
        game: state.game.copyWith(status: 'completed'),
      );
    } catch (e) {
      state = state.copyWith(lastError: e.toString());
    }
  }
}

/// Online game state provider
final onlineGameStateProvider = StateNotifierProvider.family<
    OnlineGameStateNotifier,
    OnlineGameState,
    String>((ref, gameId) {
  return OnlineGameStateNotifier(gameId, ref);
});

/// Watch online game updates in real-time
final onlineGameStreamProvider =
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

/// Watch for draw offers
final drawOfferStreamProvider =
    StreamProvider.family<bool, String>((ref, gameId) {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  return firestore
      .collection('games')
      .doc(gameId)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) return false;

    final drawOfferBy = snapshot.data()?['drawOfferBy'] as String?;
    if (drawOfferBy == null) return false;

    final currentUser = auth.currentUser;
    // Show draw offer if it's from the opponent
    return drawOfferBy != currentUser?.uid;
  });
});
