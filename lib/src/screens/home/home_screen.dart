import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateNotifierProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
      data: (user) {
        if (user == null) {
          // User not authenticated, redirect to login
          // This should be handled by the root navigation
          return const Scaffold(
            body: Center(
              child: Text('Not authenticated'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('♟️ Chess Tactics Master'),
            centerTitle: true,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  // TODO: Navigate to settings
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // User Status Section
                _UserStatusSection(user: user),

                // Daily Challenge Section
                _DailyChallengeSection(),

                // Recent Games Section
                _RecentGamesSection(),

                // Bottom spacer
                const SizedBox(height: 24),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // TODO: Sign out
            },
            label: const Text('Sign Out'),
            icon: const Icon(Icons.logout),
          ),
        );
      },
    );
  }
}

class _UserStatusSection extends StatelessWidget {
  final UserModel user;

  const _UserStatusSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: user.photoUrl != null
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: user.photoUrl == null
                    ? Text(
                        user.displayName?.substring(0, 1).toUpperCase() ?? '?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? 'Player',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Rating and stats
          Row(
            children: [
              _StatCard(
                label: 'Rating',
                value: user.rating.toString(),
                icon: Icons.trending_up,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Games',
                value: user.gamesPlayed.toString(),
                icon: Icons.sports_esports,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Win Rate',
                value: user.gamesPlayed > 0
                    ? '${(user.wins / user.gamesPlayed * 100).toStringAsFixed(0)}%'
                    : '--',
                icon: Icons.emoji_events,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyChallengeSection extends StatelessWidget {
  const _DailyChallengeSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Challenge',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.emoji_events,
                  size: 48,
                  color: Colors.amber,
                ),
                const SizedBox(height: 12),
                Text(
                  'Fork Tactic Challenge',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '5 puzzles • Rating 800-1200',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      // TODO: Navigate to daily challenge
                    },
                    child: const Text('Start Challenge'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentGamesSection extends StatelessWidget {
  const _RecentGamesSection();

  @override
  Widget build(BuildContext context) {
    // Mock data for now
    final mockGames = [
      {
        'opponent': 'AlexChess',
        'result': 'Win',
        'ratingChange': '+18',
        'time': '2 hours ago',
      },
      {
        'opponent': 'ChessMaster99',
        'result': 'Loss',
        'ratingChange': '-12',
        'time': 'Yesterday',
      },
      {
        'opponent': 'PuzzleKing',
        'result': 'Draw',
        'ratingChange': '+0',
        'time': '3 days ago',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Games',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to game history
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...mockGames.map((game) => _GameCard(
                opponent: game['opponent'] as String,
                result: game['result'] as String,
                ratingChange: game['ratingChange'] as String,
                time: game['time'] as String,
              )),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String opponent;
  final String result;
  final String ratingChange;
  final String time;

  const _GameCard({
    required this.opponent,
    required this.result,
    required this.ratingChange,
    required this.time,
  });

  Color _getResultColor() {
    switch (result.toLowerCase()) {
      case 'win':
        return Colors.green;
      case 'loss':
        return Colors.red;
      case 'draw':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            child: Text(opponent.substring(0, 1).toUpperCase()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  opponent,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getResultColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  result,
                  style: TextStyle(
                    color: _getResultColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ratingChange,
                style: TextStyle(
                  color: ratingChange.contains('-') ? Colors.red : Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
