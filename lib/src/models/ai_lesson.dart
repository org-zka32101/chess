import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_lesson.freezed.dart';
part 'ai_lesson.g.dart';

// Enums for AI-generated content classification
enum AIContentType {
  gameAnalysis,
  openingRecommendation,
  tacticPattern,
  endgameInsight,
  positionEvaluation,
  improvementArea,
}

enum AnalysisType {
  blunder,
  mistake,
  inaccuracy,
  goodMove,
  excellentMove,
  bestMove,
}

enum RecommendationLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

// Models for AI-generated lessons

@freezed
class AIGeneratedLesson with _$AIGeneratedLesson {
  const factory AIGeneratedLesson({
    required String id,
    required String userId,
    required String gameId,
    required AIContentType contentType,
    required String title,
    required String description,
    required String pgn,
    required List<String> keyPoints,
    required List<String> commonMistakes,
    required List<String> suggestedFocus,
    required double relevanceScore,
    required RecommendationLevel recommendedLevel,
    required DateTime generatedAt,
    required int estimatedMinutes,
    @Default(false) bool isReviewed,
    @Default(false) bool isLiked,
    @Default(0) int reviewCount,
    @Default('') String customNotes,
  }) = _AIGeneratedLesson;

  factory AIGeneratedLesson.fromJson(Map<String, dynamic> json) =>
      _$AIGeneratedLessonFromJson(json);
}

@freezed
class GameAnalysis with _$GameAnalysis {
  const factory GameAnalysis({
    required String id,
    required String userId,
    required String gameId,
    required DateTime analysisDate,
    required double overallAccuracy,
    required int totalMoves,
    required int blunders,
    required int mistakes,
    required int inaccuracies,
    required int goodMoves,
    required List<MoveAnalysis> moveAnalyses,
    required List<String> identifiedWeaknesses,
    required List<String> openingsPlayed,
    required List<String> tacticPatternsEncountered,
    required String overallAssessment,
    required List<AIGeneratedLesson> suggestedLessons,
  }) = _GameAnalysis;

  factory GameAnalysis.fromJson(Map<String, dynamic> json) =>
      _$GameAnalysisFromJson(json);
}

@freezed
class MoveAnalysis with _$MoveAnalysis {
  const factory MoveAnalysis({
    required int moveNumber,
    required String move,
    required String currentFen,
    required AnalysisType analysisType,
    required double evaluationDifference,
    required String bestMove,
    required String explanation,
    required String tacticPattern,
    required bool isBlunder,
    required bool isMistake,
    required bool isInaccuracy,
  }) = _MoveAnalysis;

  factory MoveAnalysis.fromJson(Map<String, dynamic> json) =>
      _$MoveAnalysisFromJson(json);
}

@freezed
class AIOpeningRecommendation with _$AIOpeningRecommendation {
  const factory AIOpeningRecommendation({
    required String id,
    required String userId,
    required String ecoCode,
    required String openingName,
    required String reasoning,
    required double compatibilityScore,
    required RecommendationLevel skillLevel,
    required List<String> mainLines,
    required List<String> tacticalThemes,
    required List<String> strategicIdeas,
    required Map<String, double> winRates,
    required DateTime recommendedAt,
  }) = _AIOpeningRecommendation;

  factory AIOpeningRecommendation.fromJson(Map<String, dynamic> json) =>
      _$AIOpeningRecommendationFromJson(json);
}

@freezed
class PlayerProfile with _$PlayerProfile {
  const factory PlayerProfile({
    required String userId,
    required int totalGamesAnalyzed,
    required double averageAccuracy,
    required List<String> mainWeaknesses,
    required List<String> mainStrengths,
    required List<String> preferredOpenings,
    required List<String> frequentMistakes,
    required int tacticPatternsKnown,
    required String playStyle,
    required DateTime lastAnalysisDate,
    required List<AIGeneratedLesson> recommendedNextLessons,
  }) = _PlayerProfile;

  factory PlayerProfile.fromJson(Map<String, dynamic> json) =>
      _$PlayerProfileFromJson(json);
}

@freezed
class EndgameInsight with _$EndgameInsight {
  const factory EndgameInsight({
    required String id,
    required String userId,
    required String endgameName,
    required String position,
    required String technique,
    required String explanation,
    required List<String> keyPrinciples,
    required String relevantTacticalTheme,
    required bool isWeakness,
    required DateTime identifiedAt,
  }) = _EndgameInsight;

  factory EndgameInsight.fromJson(Map<String, dynamic> json) =>
      _$EndgameInsightFromJson(json);
}

@freezed
class ImprovementPath with _$ImprovementPath {
  const factory ImprovementPath({
    required String userId,
    required List<String> priorityAreas,
    required List<AIGeneratedLesson> lessonsToTake,
    required List<String> practiceOpenings,
    required List<String> tacticPatternsToStudy,
    required int estimatedDaysToImprovement,
    required String personalizedAdvice,
    required DateTime generatedAt,
  }) = _ImprovementPath;

  factory ImprovementPath.fromJson(Map<String, dynamic> json) =>
      _$ImprovementPathFromJson(json);
}

@freezed
class AIInsight with _$AIInsight {
  const factory AIInsight({
    required String id,
    required String userId,
    required String title,
    required String description,
    required AIContentType contentType,
    required String relatedGameId,
    required int relevanceRank,
    required DateTime generatedAt,
    @Default(false) bool isActionable,
    @Default(false) bool isRead,
  }) = _AIInsight;

  factory AIInsight.fromJson(Map<String, dynamic> json) =>
      _$AIInsightFromJson(json);
}
