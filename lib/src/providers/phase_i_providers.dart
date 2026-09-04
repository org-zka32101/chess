import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';

import '../models/lesson.dart';
import '../services/chess_lessons_service.dart';

part 'phase_i_providers.g.dart';

// ============================================================================
// Service Providers
// ============================================================================

@riverpod
ChessLessonsService chessLessonsService(ChessLessonsServiceRef ref) {
  return ChessLessonsService();
}

// ============================================================================
// Lesson Retrieval Providers
// ============================================================================

@riverpod
Future<List<ChessLesson>> openingLessons(
  OpeningLessonsRef ref, {
  DifficultyLevel? difficulty,
}) async {
  final service = ref.watch(chessLessonsServiceProvider);
  return service.getLessonsByType(
    ContentType.opening,
    difficulty: difficulty,
  );
}

@riverpod
Future<List<ChessLesson>> tacticLessons(
  TacticLessonsRef ref, {
  DifficultyLevel? difficulty,
}) async {
  final service = ref.watch(chessLessonsServiceProvider);
  return service.getLessonsByType(
    ContentType.tactic,
    difficulty: difficulty,
  );
}

@riverpod
Future<List<ChessLesson>> strategyLessons(
  StrategyLessonsRef ref, {
  DifficultyLevel? difficulty,
}) async {
  final service = ref.watch(chessLessonsServiceProvider);
  return service.getLessonsByType(
    ContentType.strategy,
    difficulty: difficulty,
  );
}

@riverpod
Future<List<OpeningExplanation>> allOpenings(AllOpeningsRef ref) async {
  final service = ref.watch(chessLessonsServiceProvider);
  return service.getAllOpenings();
}

@riverpod
Future<OpeningExplanation?> openingByEco(
  OpeningByEcoRef ref,
  String ecoCode,
) async {
  final service = ref.watch(chessLessonsServiceProvider);
  return service.getOpeningByEco(ecoCode);
}

@riverpod
Future<List<TacticsPattern>> tacticsByDifficulty(
  TacticsByDifficultyRef ref,
  DifficultyLevel difficulty,
) async {
  final service = ref.watch(chessLessonsServiceProvider);
  return service.getTacticsByDifficulty(difficulty);
}

@riverpod
Future<List<TacticsPattern>> allTactics(AllTacticsRef ref) async {
  final service = ref.watch(chessLessonsServiceProvider);
  return service.getAllTactics();
}

@riverpod
Future<List<StrategyGuide>> strategyGuides(StrategyGuidesRef ref) async {
  final service = ref.watch(chessLessonsServiceProvider);
  return service.getStrategyGuides();
}

@riverpod
Future<List<LessonCollection>> lessonCollections(
  LessonCollectionsRef ref, {
  DifficultyLevel? difficulty,
}) async {
  final service = ref.watch(chessLessonsServiceProvider);
  return service.getLessonCollections(difficulty: difficulty);
}

// ============================================================================
// User Progress Providers
// ============================================================================

@riverpod
Future<List<UserLessonProgress>> userLessonProgress(
  UserLessonProgressRef ref,
  String userId,
) async {
  final service = ref.watch(chessLessonsServiceProvider);
  return service.getUserProgress(userId);
}

@riverpod
Future<UserLessonProgress?> lessonProgress(
  LessonProgressRef ref,
  String userId,
  String lessonId,
) async {
  final service = ref.watch(chessLessonsServiceProvider);
  return service.getUserLessonProgress(userId, lessonId);
}

@riverpod
Future<Map<String, dynamic>> openingStatistics(
  OpeningStatisticsRef ref,
  String ecoCode,
) async {
  final service = ref.watch(chessLessonsServiceProvider);
  return service.getOpeningStatistics(ecoCode);
}

// ============================================================================
// State Notifiers for Lesson Interactions
// ============================================================================

class LessonProgressNotifier extends StateNotifier<AsyncValue<void>> {
  final ChessLessonsService _lessonsService;

  LessonProgressNotifier(this._lessonsService)
      : super(const AsyncValue.data(null));

  Future<void> startLesson(String userId, String lessonId) async {
    state = const AsyncValue.loading();
    try {
      await _lessonsService.startLesson(userId, lessonId);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateProgress(
    String userId,
    String lessonId,
    int percentageComplete,
  ) async {
    state = const AsyncValue.loading();
    try {
      await _lessonsService.updateLessonProgress(
        userId,
        lessonId,
        percentageComplete,
      );
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> rateLessonCompletion(
    String userId,
    String lessonId,
    double score,
  ) async {
    state = const AsyncValue.loading();
    try {
      await _lessonsService.rateLessonCompletion(userId, lessonId, score);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addNote(String userId, String lessonId, String note) async {
    state = const AsyncValue.loading();
    try {
      await _lessonsService.addNoteToLesson(userId, lessonId, note);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

@riverpod
StateNotifier<AsyncValue<void>> lessonProgressNotifier(
    LessonProgressNotifierRef ref) {
  final service = ref.watch(chessLessonsServiceProvider);
  return LessonProgressNotifier(service);
}

// ============================================================================
// Aggregated Progress Analytics
// ============================================================================

@riverpod
Future<Map<String, dynamic>> userProgressAnalytics(
  UserProgressAnalyticsRef ref,
  String userId,
) async {
  final service = ref.watch(chessLessonsServiceProvider);
  final progress = await service.getUserProgress(userId);

  if (progress.isEmpty) {
    return {
      'totalLessonsStarted': 0,
      'totalLessonsCompleted': 0,
      'completionRate': 0.0,
      'averageScore': 0.0,
      'learningStreak': 0,
      'totalHoursSpent': 0.0,
    };
  }

  final completed =
      progress.where((p) => p.status == LessonStatus.completed).length;
  final totalHours = progress.fold<double>(
    0.0,
    (sum, p) => sum + (p.percentageComplete / 100.0),
  );
  final avgScore = progress.isNotEmpty
      ? progress.fold<double>(
          0.0,
          (sum, p) => sum + p.selfAssessmentScore,
        ) /
          progress.length
      : 0.0;

  return {
    'totalLessonsStarted': progress.length,
    'totalLessonsCompleted': completed,
    'completionRate': completed / progress.length,
    'averageScore': avgScore,
    'learningStreak': _calculateLearningStreak(progress),
    'totalHoursSpent': totalHours,
  };
}

int _calculateLearningStreak(List<UserLessonProgress> progress) {
  if (progress.isEmpty) return 0;

  final sortedByDate = [...progress];
  sortedByDate.sort(
    (a, b) => b.lastAccessedDate.compareTo(a.lastAccessedDate),
  );

  int streak = 1;
  for (int i = 0; i < sortedByDate.length - 1; i++) {
    final current = sortedByDate[i].lastAccessedDate;
    final next = sortedByDate[i + 1].lastAccessedDate;
    final daysDifference = current.difference(next).inDays;

    if (daysDifference <= 1) {
      streak++;
    } else {
      break;
    }
  }

  return streak;
}
