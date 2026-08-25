import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game.dart';

final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

// Get active games for current user
final activeGamesProvider = StreamProvider<List<GameModel>>((ref) async* {
  final firestore = ref.watch(firestoreProvider);
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    yield [];
    return;
  }

  try {
    await for (final snapshot in firestore
        .collection('games')
        .where('status', isEqualTo: 'active')
        .where(
          Filter.or(
            Filter('whitePlayerId', isEqualTo: user.uid),
            Filter('blackPlayerId', isEqualTo: user.uid),
          ),
        )
        .snapshots()) {
      final games = snapshot.docs
          .map((doc) => GameModel.fromJson({
                ...doc.data(),
                'gameId': doc.id,
              }))
          .toList();
      yield games;
    }
  } catch (e) {
    yield [];
  }
});

// Get game history for current user
final gameHistoryProvider = StreamProvider<List<GameModel>>((ref) async* {
  final firestore = ref.watch(firestoreProvider);
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    yield [];
    return;
  }

  try {
    await for (final snapshot in firestore
        .collection('games')
        .where('status', isEqualTo: 'completed')
        .where(
          Filter.or(
            Filter('whitePlayerId', isEqualTo: user.uid),
            Filter('blackPlayerId', isEqualTo: user.uid),
          ),
        )
        .orderBy('endedAt', descending: true)
        .limit(50)
        .snapshots()) {
      final games = snapshot.docs
          .map((doc) => GameModel.fromJson({
                ...doc.data(),
                'gameId': doc.id,
              }))
          .toList();
      yield games;
    }
  } catch (e) {
    yield [];
  }
});

// Get specific game by ID
final gameByIdProvider = StreamProvider.family<GameModel?, String>((ref, gameId) async* {
  final firestore = ref.watch(firestoreProvider);

  try {
    await for (final snapshot in firestore
        .collection('games')
        .doc(gameId)
        .snapshots()) {
      if (snapshot.exists) {
        yield GameModel.fromJson({
          ...snapshot.data()!,
          'gameId': snapshot.id,
        });
      } else {
        yield null;
      }
    }
  } catch (e) {
    yield null;
  }
});

// Game service for creating and managing games
class GameService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  GameService(this._firestore, this._auth);

  Future<GameModel> createGame({
    required String opponentId,
    required String timeControl,
    required String gameType,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('No user logged in');

    // TODO: Implement game creation logic
    throw UnimplementedError('Game creation not yet implemented');
  }

  Future<void> makeMove({
    required String gameId,
    required String from,
    required String to,
    String? promotion,
  }) async {
    // TODO: Implement move logic
    throw UnimplementedError('Make move not yet implemented');
  }

  Future<void> resignGame(String gameId) async {
    // TODO: Implement resign logic
    throw UnimplementedError('Resign game not yet implemented');
  }

  Future<void> offerDraw(String gameId) async {
    // TODO: Implement draw offer logic
    throw UnimplementedError('Offer draw not yet implemented');
  }
}

final gameServiceProvider = Provider((ref) {
  final firestore = ref.watch(firestoreProvider);
  final auth = FirebaseAuth.instance;
  return GameService(firestore, auth);
});
