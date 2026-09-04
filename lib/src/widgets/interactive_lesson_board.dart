import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Interactive Chess Board Widget for Lesson Display
class InteractiveLessonBoard extends ConsumerStatefulWidget {
  final String pgnString;
  final List<String> keyPoints;
  final List<String> annotations;
  final bool isInteractive;
  final Function(int)? onMoveSelected;

  const InteractiveLessonBoard({
    Key? key,
    required this.pgnString,
    required this.keyPoints,
    required this.annotations,
    this.isInteractive = true,
    this.onMoveSelected,
  }) : super(key: key);

  @override
  ConsumerState<InteractiveLessonBoard> createState() =>
      _InteractiveLessonBoardState();
}

class _InteractiveLessonBoardState extends ConsumerState<InteractiveLessonBoard> {
  late int currentMoveIndex = 0;
  late List<String> moves = [];

  @override
  void initState() {
    super.initState();
    _parsePgn(widget.pgnString);
  }

  void _parsePgn(String pgn) {
    // Extract moves from PGN format
    final movePattern = RegExp(r'\d+\.\s*(\S+)\s+(\S+)?');
    final matches = movePattern.allMatches(pgn);

    moves = [];
    for (final match in matches) {
      if (match.group(1) != null) {
        moves.add(match.group(1)!);
      }
      if (match.group(2) != null) {
        moves.add(match.group(2)!);
      }
    }
  }

  void _nextMove() {
    if (currentMoveIndex < moves.length - 1) {
      setState(() => currentMoveIndex++);
      widget.onMoveSelected?.call(currentMoveIndex);
    }
  }

  void _previousMove() {
    if (currentMoveIndex > 0) {
      setState(() => currentMoveIndex--);
      widget.onMoveSelected?.call(currentMoveIndex);
    }
  }

  void _resetBoard() {
    setState(() => currentMoveIndex = 0);
    widget.onMoveSelected?.call(0);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Chess Board Display Area
          Container(
            width: double.infinity,
            height: 400,
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chess Board Position ${currentMoveIndex + 1}',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 20),
                  if (currentMoveIndex < moves.length)
                    Text(
                      'Move: ${moves[currentMoveIndex]}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Display annotation if available
                  if (currentMoveIndex < widget.annotations.length)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        widget.annotations[currentMoveIndex],
                        style: Theme.of(context).textTheme.bodyText2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Move Navigation Controls
          if (widget.isInteractive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _resetBoard,
                    icon: const Icon(Icons.first_page),
                    label: const Text('Reset'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _previousMove,
                    icon: const Icon(Icons.navigate_before),
                    label: const Text('Previous'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _nextMove,
                    icon: const Icon(Icons.navigate_next),
                    label: const Text('Next'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),

          // Key Points Panel
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Key Points',
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(height: 12),
                ...widget.keyPoints.map((point) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              point,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lesson Completion Card
class LessonCompletionCard extends StatelessWidget {
  final String title;
  final double completionPercentage;
  final VoidCallback onContinue;

  const LessonCompletionCard({
    Key? key,
    required this.title,
    required this.completionPercentage,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: completionPercentage / 100,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text('${completionPercentage.toStringAsFixed(1)}% Complete'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onContinue,
              child: const Text('Continue Learning'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opening Statistics Display
class OpeningStatisticsWidget extends StatelessWidget {
  final String openingName;
  final double winRateWhite;
  final double winRateBlack;
  final double drawRate;
  final int totalGames;

  const OpeningStatisticsWidget({
    Key? key,
    required this.openingName,
    required this.winRateWhite,
    required this.winRateBlack,
    required this.drawRate,
    required this.totalGames,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$openingName Statistics',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 16),
            _StatisticRow('Total Games', totalGames.toString()),
            _StatisticRow('White Wins', '${(winRateWhite * 100).toStringAsFixed(1)}%'),
            _StatisticRow('Black Wins', '${(winRateBlack * 100).toStringAsFixed(1)}%'),
            _StatisticRow('Draws', '${(drawRate * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }
}

class _StatisticRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatisticRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
