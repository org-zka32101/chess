import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/matchmaking.dart';
import '../../providers/matchmaking_provider.dart';
import '../../utils/animations.dart';

/// Screen shown while waiting for matchmaking to find an opponent
class MatchmakingWaitingScreen extends ConsumerStatefulWidget {
  final String timeControl;
  final int playerRating;

  const MatchmakingWaitingScreen({
    Key? key,
    required this.timeControl,
    required this.playerRating,
  }) : super(key: key);

  @override
  ConsumerState<MatchmakingWaitingScreen> createState() =>
      _MatchmakingWaitingScreenState();
}

class _MatchmakingWaitingScreenState
    extends ConsumerState<MatchmakingWaitingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _waitSeconds = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Start wait timer
    Future.delayed(Duration.zero, () {
      _startWaitTimer();
    });

    // Join matchmaking queue
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchmakingQueueProvider.notifier).joinQueue(
            timeControl: widget.timeControl,
            playerRating: widget.playerRating,
          );
    });
  }

  void _startWaitTimer() {
    Future.doWhile(() {
      if (!mounted) return false;

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _waitSeconds++);
        }
      });
      return true;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Leave queue when screen is closed
    ref.read(matchmakingQueueProvider.notifier).leaveQueue();
    super.dispose();
  }

  String _formatWaitTime(int seconds) {
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final queueStatus = ref.watch(matchmakingQueueStatusProvider);

    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cancel Matchmaking?'),
            content: const Text('Are you sure you want to cancel searching for an opponent?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Continue'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ) ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Finding Opponent'),
          centerTitle: true,
          elevation: 0,
        ),
        body: queueStatus.when(
          data: (status) {
            // If matched, navigate to game
            if (status.matched && status.gameId != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(
                  context,
                  '/online-game',
                  arguments: status.gameId,
                );
              });
            }

            return _buildWaitingContent(context, status);
          },
          loading: () => _buildWaitingContent(context, null),
          error: (error, st) => _buildErrorState(context, error),
        ),
      ),
    );
  }

  Widget _buildWaitingContent(BuildContext context, QueueStatus? status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pulsing search indicator
          ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.2).animate(
              CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
            ),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 3,
                ),
              ),
              child: Icon(
                Icons.search_outlined,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Searching text with ellipsis animation
          Text(
            'Searching for opponent',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),

          // Wait time
          Text(
            'Waiting: ${_formatWaitTime(_waitSeconds)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),

          // Queue stats
          if (status != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQueueStatCard(
                        label: 'Queue Position',
                        value: '${status.position}',
                        icon: Icons.persons_outlined,
                      ),
                      _buildQueueStatCard(
                        label: 'Players Waiting',
                        value: '${status.playersWaiting}',
                        icon: Icons.group_outlined,
                      ),
                      _buildQueueStatCard(
                        label: 'Avg Wait',
                        value: '${status.avgWaitSeconds}s',
                        icon: Icons.schedule_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Tips section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    '💡 Tips',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Playing ${widget.timeControl} • Rating ~${widget.playerRating}±100',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueStatCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Connection Error',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
