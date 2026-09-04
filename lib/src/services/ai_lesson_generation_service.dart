import 'package:cloud_firestore/cloud_firestore.dart';
import 'ai_lesson_generation_service_impl.dart';
import '../models/ai_lesson.dart';
import '../models/game.dart';

/// Service for AI-powered lesson generation and game analysis
/// Uses Firebase and chess engine to generate personalized learning content
abstract class AILessonGenerationService {
  /// Generate lessons from a specific game
  /// Analyzes moves and creates AI-powered lessons
  Future<GameAnalysis> analyzeGame(String userId, String gameId);

  /// Generate opening recommendations based on player profile
  /// Suggests openings aligned with skill level and play style
  Future<List<AIOpeningRecommendation>> generateOpeningRecommendations(
    String userId,
  );

  /// Analyze player's game history to identify weaknesses
  /// Returns prioritized list of improvement areas
  Future<ImprovementPath> generateImprovementPath(String userId);

  /// Get AI-generated lessons for a user
  /// Filtered by content type and skill level
  Future<List<AIGeneratedLesson>> getAIGeneratedLessons(
    String userId, {
    AIContentType? contentType,
    RecommendationLevel? skillLevel,
  });

  /// Rate the usefulness of an AI lesson
  /// Helps refine recommendation algorithms
  Future<void> rateLessonUsefulness(
    String userId,
    String lessonId,
    int rating,
  );

  /// Get player profile from game history analysis
  /// Includes strengths, weaknesses, play style, and recommendations
  Future<PlayerProfile> generatePlayerProfile(String userId);

  /// Get endgame insights for a user
  /// Identifies weak endgame patterns
  Future<List<EndgameInsight>> analyzeEndgameWeaknesses(String userId);

  /// Get AI insights for recent games
  /// Quick summary of lessons to learn from latest games
  Future<List<AIInsight>> getRecentInsights(String userId);

  /// Accept or decline AI-generated lesson recommendations
  /// Updates user preferences for future recommendations
  Future<void> respondToLesson(
    String userId,
    String lessonId,
    bool accepted,
  );

  /// Get performance analytics comparing to past
  /// Shows improvement over time
  Future<Map<String, dynamic>> getPerformanceProgressAnalytics(
    String userId,
  );

  /// Clear cached AI analysis for a user
  /// Forces re-analysis on next generation
  Future<void> clearCachedAnalysis(String userId);
}

// Singleton instance
final _instance = AILessonGenerationServiceImpl._();

// Getter for the singleton
AILessonGenerationService get aiLessonGenerationService => _instance;
