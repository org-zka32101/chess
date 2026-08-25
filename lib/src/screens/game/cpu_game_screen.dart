import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/chess_board.dart';
import '../../providers/cpu_game_provider.dart';
import '../../services/chess_engine_service.dart';

class CPUGameScreen extends ConsumerStatefulWidget {
  final String difficulty; // 'easy', 'medium', 'hard'
  final String timeControl; // '3+0', '5+3', '10+5'

  const CPUGameScreen({
    Key? key,
    this.difficulty = 'medium',
    this.timeControl = '5+3',
  }) : super(key: key);

  @override
  ConsumerState<CPUGameScreen> createState() => _CPUGameScreenState();
}

class _CPUGameScreenState extends ConsumerState<CPUGameScreen> {
  late String _gameId;
  late ChessEngineService _engine;
  bool _gameInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      final service = ref.read(cpuGameServiceProvider);
      final game = await service.createCPUGame(
        timeControl: widget.timeControl,
        difficulty: widget.difficulty,
      );

      _gameId = game.gameId;
      _engine = ChessEngineService();
      _engine.initGame();

      setState(() {
        _gameInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_gameInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Game...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final cpuGameState = ref.watch(cpuGameStateProvider(_gameId));
    final gameStream = ref.watch(cpuGameStreamProvider(_gameId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Play vs CPU'),
        centerTitle: true,
        elevation: 0,
      ),
      body: gameStream.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
        data: (game) {
          if (game == null) {
            return const Center(child: Text('Game not found'));
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // CPU player card
                    _buildPlayerCard(
                      playerName: 'Chess Engine',
                      rating: 1600,
                      difficulty: widget.difficulty,
                      isTopCard: true,
                    ),
                    const SizedBox(height: 16),

                    // Chess board
                    Center(
                      child: ChessBoard(
                        engine: _engine,
                        size: 350,
                        enabled: !cpuGameState.isThinking &&
                            game.status == 'active' &&
                            _engine.isWhiteTurn(),
                        onMoveMade: (from, to) async {
                          await ref
                              .read(cpuGameStateProvider(_gameId).notifier)
                              .makeMove(from, to);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Player card
                    _buildPlayerCard(
                      playerName: 'You',
                      rating: 1600,
                      isTopCard: false,
                    ),

                    const SizedBox(height: 24),

                    // Game status
                    if (game.status == 'completed')
                      _buildGameOverCard(game)
                    else
                      _buildGameInfoCard(game, cpuGameState.isThinking),

                    const SizedBox(height: 16),

                    // Action buttons
                    if (game.status == 'active')
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _showResignDialog(context, _gameId),
                              child: const Text('Resign'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                // TODO: Implement move undo
                              },
                              child: const Text('Undo'),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(),
                              child: const Text('Exit Game'),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayerCard({
    required String playerName,
    required int rating,
    String? difficulty,
    required bool isTopCard,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              playerName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (difficulty != null)
                  Text(
                    'Difficulty: ${difficulty[0].toUpperCase()}${difficulty.substring(1)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  )
                else
                  Text(
                    'Rating: $rating',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfoCard(var game, bool isThinking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Moves',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(game.moves?.length ?? 0) ~/ 2}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (isThinking)
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Thinking...',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Time Control',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    game.timeControl ?? '5+3',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverCard(var game) {
    final result = game.result;
    final reason = game.resultReason;

    String resultText;
    Color resultColor;

    if (result == 'white_win') {
      resultText = 'You won!';
      resultColor = Colors.green;
    } else if (result == 'black_win') {
      resultText = 'You lost';
      resultColor = Colors.red;
    } else {
      resultText = 'Draw';
      resultColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: resultColor.withOpacity(0.1),
        border: Border.all(color: resultColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            resultText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: resultColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Result: ${reason?.replaceAll('_', ' ').toUpperCase() ?? 'GAME ENDED'}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showResignDialog(BuildContext context, String gameId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resign Game'),
        content: const Text('Are you sure you want to resign?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(cpuGameStateProvider(gameId).notifier).resign();
              Navigator.pop(context);
            },
            child: const Text('Resign'),
          ),
        ],
      ),
    );
  }
}
