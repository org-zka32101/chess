import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_lesson_generation_service.dart';
import '../models/ai_lesson.dart';

// Service provider
final aiLessonGenerationServiceProvider =
    Provider<AILessonGenerationService>((ref) {
  return aiLessonGenerationService;
});

// AI-generated lessons providers
final aiGeneratedLessonsProvider = FutureProvider.family<
    List<AIGeneratedLesson>,
    String>((ref, userId) async {
  final service = ref.watch(aiLessonGenerationServiceProvider);
  return service.getAIGeneratedLessons(userId);
});

final aiGeneratedLessonsByTypeProvider = FutureProvider.family<
    List<AIGeneratedLesson>,
    ({String userId, AIContentType contentType})>((ref, args) async {
  final service = ref.watch(aiLessonGenerationServiceProvider);
  return service.getAIGeneratedLessons(
    args.userId,
    contentType: args.contentType,
  );
});

final aiGeneratedLessonsByLevelProvider = FutureProvider.family<
    List<AIGeneratedLesson>,
    ({String userId, RecommendationLevel level})>((ref, args) async {
  final service = ref.watch(aiLessonGenerationServiceProvider);
  return service.getAIGeneratedLessons(
    args.userId,
    skillLevel: args.level,
  );
});

// Game analysis provider
final gameAnalysisProvider = FutureProvider.family<
    GameAnalysis,
    ({String userId, String gameId})>((ref, args) async {
  final service = ref.watch(aiLessonGenerationServiceProvider);
  return service.analyzeGame(args.userId, args.gameId);
});

// Opening recommendations provider
final openingRecommendationsProvider =
    FutureProvider.family<List<AIOpeningRecommendation>, String>(
        (ref, userId) async {
  final service = ref.watch(aiLessonGenerationServiceProvider);
  return service.generateOpeningRecommendations(userId);
});

// Player profile provider
final playerProfileProvider = FutureProvider.family<PlayerProfile, String>(
    (ref, userId) async {
  final service = ref.watch(aiLessonGenerationServiceProvider);
  return service.generatePlayerProfile(userId);
});

// Improvement path provider
final improvementPathProvider = FutureProvider.family<ImprovementPath, String>(
    (ref, userId) async {
  final service = ref.watch(aiLessonGenerationServiceProvider);
  return service.generateImprovementPath(userId);
});

// Endgame insights provider
final endgameInsightsProvider = FutureProvider.family<List<EndgameInsight>, String>(
    (ref, userId) async {
  final service = ref.watch(aiLessonGenerationServiceProvider);
  return service.analyzeEndgameWeaknesses(userId);
});

// Recent AI insights provider
final recentAIInsightsProvider = FutureProvider.family<List<AIInsight>, String>(
    (ref, userId) async {
  final service = ref.watch(aiLessonGenerationServiceProvider);
  return service.getRecentInsights(userId);
});

// Performance progress analytics provider
final performanceProgressAnalyticsProvider = FutureProvider.family<
    Map<String, dynamic>,
    String>((ref, userId) async {
  final service = ref.watch(aiLessonGenerationServiceProvider);
  return service.getPerformanceProgressAnalytics(userId);
});

// State notifier for AI lesson interactions
class AILessonInteractionNotifier
    extends StateNotifier<Map<String, dynamic>> {
  final AILessonGenerationService _service;

  AILessonInteractionNotifier(this._service)
      : super({'loading': false, 'error': null});

  Future<void> rateLessonUsefulness(
    String userId,
    String lessonId,
    int rating,
  ) async {
    state = {...state, 'loading': true};
    try {
      await _service.rateLessonUsefulness(userId, lessonId, rating);
      state = {
        ...state,
        'loading': false,
        'message': 'Rating submitted',
      };
    } catch (e) {
      state = {
        ...state,
        'loading': false,
        'error': e.toString(),
      };
    }
  }

  Future<void> respondToLesson(
    String userId,
    String lessonId,
    bool accepted,
  ) async {
    state = {...state, 'loading': true};
    try {
      await _service.respondToLesson(userId, lessonId, accepted);
      state = {
        ...state,
        'loading': false,
        'message': 'Response recorded',
      };
    } catch (e) {
      state = {
        ...state,
        'loading': false,
        'error': e.toString(),
      };
    }
  }

  Future<void> clearCache(String userId) async {
    state = {...state, 'loading': true};
    try {
      await _service.clearCachedAnalysis(userId);
      state = {
        ...state,
        'loading': false,
        'message': 'Cache cleared',
      };
    } catch (e) {
      state = {
        ...state,
        'loading': false,
        'error': e.toString(),
      };
    }
  }
}

// AI lesson interaction state notifier provider
final aiLessonInteractionProvider = StateNotifierProvider<
    AILessonInteractionNotifier,
    Map<String, dynamic>>((ref) {
  final service = ref.watch(aiLessonGenerationServiceProvider);
  return AILessonInteractionNotifier(service);
});

// Analytics aggregation providers
final userLearningAnalyticsProvider = FutureProvider.family<
    Map<String, dynamic>,
    String>((ref, userId) async {
  final profile = await ref.watch(playerProfileProvider(userId).future);
  final progress = await ref.watch(performanceProgressAnalyticsProvider(userId).future);
  final improvementPath = await ref.watch(improvementPathProvider(userId).future);

  return {
    'gamesAnalyzed': profile.totalGamesAnalyzed,
    'averageAccuracy': profile.averageAccuracy,
    'mainWeaknesses': profile.mainWeaknesses,
    'mainStrengths': profile.mainStrengths,
    'accuracyImprovement': progress['accuracyImprovement'] ?? 0,
    'trend': progress['trend'] ?? 'stable',
    'estimatedDaysToImprovement': improvementPath.estimatedDaysToImprovement,
    'priorityAreas': improvementPath.priorityAreas,
  };
});

// Personalized dashboard data provider
final personalizedDashboardProvider = FutureProvider.family<
    Map<String, dynamic>,
    String>((ref, userId) async {
  final profile = await ref.watch(playerProfileProvider(userId).future);
  final recentInsights = await ref.watch(recentAIInsightsProvider(userId).future);
  final openingRecs = await ref.watch(openingRecommendationsProvider(userId).future);
  final improvementPath = await ref.watch(improvementPathProvider(userId).future);

  return {
    'playerProfile': profile,
    'recentInsights': recentInsights,
    'openingRecommendations': openingRecs,
    'improvementPath': improvementPath,
    'lastUpdated': DateTime.now().toIso8601String(),
  };
});
