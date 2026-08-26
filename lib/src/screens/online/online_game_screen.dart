import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:chess/src/models/online_game.dart';
import 'package:chess/src/providers/online_game_provider.dart';

/// Screen for playing online multiplayer chess games
class OnlineGameScreen extends ConsumerStatefulWidget {
  final String gameId;

  const OnlineGameScreen({
    Key? key,
    required this.gameId,
  }) : super(key: key);

  @override
  ConsumerState<OnlineGameScreen> createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends ConsumerState<OnlineGameScreen> {
  late String _gameId;

  @override
  void initState() {
    super.initState();
    _gameId = widget.gameId;
  }

  @override
  Widget build(BuildContext context) {
    final gameStream = ref.watch(gameStreamProvider(_gameId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Game'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showGameMenu(context),
          ),
        ],
      ),
      body: gameStream.when(
        data: (game) => _buildGameBoard(context, game),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => _buildErrorState(err),
      ),
    );
  }

  /// Build main game board layout
  Widget _buildGameBoard(BuildContext context, OnlineGame game) {
    final isBoardActive = game.status == 'active';

    return Column(
      children: [
        // Top player info (opponent)
        _buildPlayerInfo(
          name: game.whitePlayerId == _getCurrentPlayerId()
              ? game.blackPlayerName
              : game.whitePlayerName,
          rating: game.whitePlayerId == _getCurrentPlayerId()
              ? game.blackRating
              : game.whiteRating,
          timeMs: game.whitePlayerId == _getCurrentPlayerId()
              ? game.blackTimeRemainingMs
              : game.whiteTimeRemainingMs,
          isCurrentPlayer: false,
        ),

        const Divider(height: 1),

        // Chess Board (would integrate with existing board UI)
        Expanded(
          child: Container(
            color: Colors.grey[100],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chess Board\n(FEN: ${game.currentFen})',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Moves: ${game.moves.length}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),

        const Divider(height: 1),

        // Bottom player info (self)
        _buildPlayerInfo(
          name: game.whitePlayerId == _getCurrentPlayerId()
              ? game.whitePlayerName
              : game.blackPlayerName,
          rating: game.whitePlayerId == _getCurrentPlayerId()
              ? game.whiteRating
              : game.blackRating,
          timeMs: game.whitePlayerId == _getCurrentPlayerId()
              ? game.whiteTimeRemainingMs
              : game.blackTimeRemainingMs,
          isCurrentPlayer: true,
        ),

        // Move/Action buttons
        if (isBoardActive) _buildGameActions(context, game),
      ],
    );
  }

  /// Build player information widget (name, rating, time)
  Widget _buildPlayerInfo({
    required String name,
    required int rating,
    required int timeMs,
    required bool isCurrentPlayer,
  }) {
    final minutes = timeMs ~/ 60000;
    final seconds = (timeMs % 60000) ~/ 1000;
    final timeColor = timeMs < 60000 ? Colors.red : Colors.black;

    return Container(
      color: isCurrentPlayer ? Colors.blue[50] : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Rating: $rating',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: timeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$minutes:${seconds.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: timeColor,
                fontFamily: 'Courier',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build game action buttons
  Widget _buildGameActions(BuildContext context, OnlineGame game) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Resign button
          OutlinedButton.icon(
            onPressed: () => _showResignConfirmation(context, game),
            icon: const Icon(Icons.flag),
            label: const Text('Resign'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),

          // Offer Draw button
          OutlinedButton.icon(
            onPressed: () => _offerDraw(game),
            icon: const Icon(Icons.handshake),
            label: const Text('Offer Draw'),
          ),

          // Claim Draw button
          OutlinedButton.icon(
            onPressed: () => _claimDraw(game),
            icon: const Icon(Icons.check),
            label: const Text('Claim Draw'),
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('Error loading game: $error'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  /// Show game menu options
  void _showGameMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Game Info'),
              onTap: () {
                Navigator.pop(context);
                _showGameInfo(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Move History'),
              onTap: () {
                Navigator.pop(context);
                _showMoveHistory(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Abandon Game'),
              onTap: () {
                Navigator.pop(context);
                _showAbandonConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Show resign confirmation dialog
  void _showResignConfirmation(BuildContext context, OnlineGame game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resign Game?'),
        content: const Text(
          'Are you sure you want to resign? This will lose the game.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _resign(game);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Resign'),
          ),
        ],
      ),
    );
  }

  /// Show abandon confirmation dialog
  void _showAbandonConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandon Game?'),
        content: const Text(
          'Abandoning will result in a loss. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _abandon();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Abandon'),
          ),
        ],
      ),
    );
  }

  /// Show game info dialog
  void _showGameInfo(BuildContext context) {
    final game = ref.read(onlineGameProvider(_gameId)).value;
    if (game == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Game ID', game.gameId),
            _buildInfoRow('Type', game.type),
            _buildInfoRow('Status', game.status),
            _buildInfoRow('Time Control', game.timeControl),
            _buildInfoRow(
              'Total Moves',
              game.moves.length.toString(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show move history
  void _showMoveHistory(BuildContext context) {
    final moves = ref.read(gameMoveProvider(_gameId)).value ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: moves.length,
            itemBuilder: (context, index) {
              final move = moves[index];
              return ListTile(
                title: Text('${index + 1}. ${move.from}${move.to}'),
                subtitle: Text(
                  'By ${move.playerId}',
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Build info row for dialogs
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  /// Resign from game
  Future<void> _resign(OnlineGame game) async {
    final notifier = ref.read(onlineGameNotifierProvider.notifier);
    try {
      await notifier.resign(_gameId);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// Offer draw
  Future<void> _offerDraw(OnlineGame game) async {
    // TODO: Implement draw offer logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draw offer sent')),
    );
  }

  /// Claim draw
  Future<void> _claimDraw(OnlineGame game) async {
    // TODO: Implement draw claim logic (threefold, 50-move rule)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draw claimed')),
    );
  }

  /// Abandon game
  Future<void> _abandon() async {
    final notifier = ref.read(onlineGameNotifierProvider.notifier);
    try {
      await notifier.abandon(_gameId);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// Get current player ID
  String _getCurrentPlayerId() {
    final auth = ref.read(firebaseAuthProvider).value;
    return auth?.uid ?? '';
  }
}
