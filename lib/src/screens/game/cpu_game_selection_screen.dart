import 'package:flutter/material.dart';
import '../../utils/animations.dart';
import 'cpu_game_screen.dart';

class CPUGameSelectionScreen extends StatefulWidget {
  const CPUGameSelectionScreen({Key? key}) : super(key: key);

  @override
  State<CPUGameSelectionScreen> createState() => _CPUGameSelectionScreenState();
}

class _CPUGameSelectionScreenState extends State<CPUGameSelectionScreen> {
  String _selectedDifficulty = 'medium';
  String _selectedTimeControl = '5+3';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play vs Computer'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Difficulty section
                Text(
                  'Select Difficulty',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildDifficultyOptions(),
                const SizedBox(height: 32),

                // Time control section
                Text(
                  'Select Time Control',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildTimeControlOptions(),
                const SizedBox(height: 48),

                // Start button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _startGame,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text(
                      'Start Game',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyOptions() {
    const difficulties = [
      ('Easy', 'Perfect for learning', Icons.psychology_alt, 'easy'),
      ('Medium', 'Balanced gameplay', Icons.trending_up, 'medium'),
      ('Hard', 'Challenging opponent', Icons.star, 'hard'),
    ];

    return Column(
      children: [
        ...difficulties.asMap().entries.map((entry) {
          final index = entry.key;
          final (title, description, icon, value) = entry.value;
          return SlideInAnimation(
            direction: SlideDirection.left,
            delay: Duration(milliseconds: index * 100),
            child: Column(
              children: [
                _buildDifficultyCard(
                  title: title,
                  description: description,
                  icon: icon as IconData,
                  value: value,
                ),
                if (index < difficulties.length - 1)
                  const SizedBox(height: 12),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDifficultyCard({
    required String title,
    required String description,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _selectedDifficulty == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedDifficulty = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeControlOptions() {
    return Column(
      children: [
        const Text(
          'Blitz Format (minutes + increment)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['1+0', '3+0', '3+2', '5+3', '10+5', '15+10']
              .map((tc) => _buildTimeControlChip(tc))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTimeControlChip(String timeControl) {
    final isSelected = _selectedTimeControl == timeControl;

    return FilterChip(
      label: Text(timeControl),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedTimeControl = timeControl);
      },
      backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  void _startGame() {
    Navigator.of(context).push(
      SmoothPageTransition(
        page: CPUGameScreen(
          difficulty: _selectedDifficulty,
          timeControl: _selectedTimeControl,
        ),
      ),
    );
  }
}
