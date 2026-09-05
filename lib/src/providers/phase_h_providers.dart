import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';

import '../models/feedback.dart';
import '../models/performance.dart';
import '../models/roadmap.dart';
import '../models/community.dart';
import '../models/version.dart';
import '../services/feedback_service.dart';
import '../services/performance_monitor_service.dart';
import '../services/feature_roadmap_service.dart';
import '../services/ab_testing_service.dart';
import '../services/community_service.dart';
import '../services/version_management_service.dart';

part 'phase_h_providers.g.dart';

// ============================================================================
// Service Providers
// ============================================================================

@riverpod
FeedbackService feedbackService(FeedbackServiceRef ref) {
  return FeedbackService();
}

@riverpod
PerformanceMonitorService performanceMonitorService(
    PerformanceMonitorServiceRef ref) {
  return PerformanceMonitorService();
}

@riverpod
FeatureRoadmapService featureRoadmapService(FeatureRoadmapServiceRef ref) {
  return FeatureRoadmapService();
}

@riverpod
ABTestingService abTestingService(ABTestingServiceRef ref) {
  return ABTestingService();
}

@riverpod
CommunityService communityService(CommunityServiceRef ref) {
  return CommunityService();
}

@riverpod
VersionManagementService versionManagementService(
    VersionManagementServiceRef ref) {
  return VersionManagementService();
}

// ============================================================================
// Feedback Providers
// ============================================================================

@riverpod
Future<List<UserFeedback>> allFeedback(AllFeedbackRef ref) async {
  final service = ref.watch(feedbackServiceProvider);
  return service.getAllFeedback();
}

@riverpod
Future<List<UserFeedback>> feedbackByCategory(
  FeedbackByCategoryRef ref,
  FeedbackCategory category,
) async {
  final service = ref.watch(feedbackServiceProvider);
  return service.getFeedbackByCategory(category);
}

@riverpod
Future<List<BugReport>> allBugReports(AllBugReportsRef ref) async {
  final service = ref.watch(feedbackServiceProvider);
  return service.getAllBugReports();
}

@riverpod
Future<List<FeatureRequest>> allFeatureRequests(AllFeatureRequestsRef ref) async {
  final service = ref.watch(feedbackServiceProvider);
  return service.getFeatureRequests();
}

@riverpod
Future<Map<String, dynamic>> feedbackStatistics(FeedbackStatisticsRef ref) async {
  final service = ref.watch(feedbackServiceProvider);
  return service.getFeedbackStats();
}

// ============================================================================
// Performance Monitoring Providers
// ============================================================================

@riverpod
Future<List<PerformanceMetric>> performanceMetrics(
    PerformanceMetricsRef ref) async {
  final service = ref.watch(performanceMonitorServiceProvider);
  return service.getPerformanceMetrics();
}

@riverpod
Future<List<PerformanceMetric>> performanceMetricsByType(
  PerformanceMetricsByTypeRef ref,
  MetricType type,
) async {
  final service = ref.watch(performanceMonitorServiceProvider);
  return service.getMetricsByType(type);
}

@riverpod
Future<List<CrashReport>> crashReports(CrashReportsRef ref) async {
  final service = ref.watch(performanceMonitorServiceProvider);
  return service.getCrashReports();
}

@riverpod
Future<List<OptimizationSuggestion>> optimizationSuggestions(
    OptimizationSuggestionsRef ref) async {
  final service = ref.watch(performanceMonitorServiceProvider);
  return service.identifyBottlenecks();
}

// ============================================================================
// Feature Roadmap Providers
// ============================================================================

@riverpod
Future<List<RoadmapItem>> roadmapItems(RoadmapItemsRef ref) async {
  final service = ref.watch(featureRoadmapServiceProvider);
  return service.getRoadmapItems();
}

@riverpod
Future<List<RoadmapItem>> roadmapByPriority(RoadmapByPriorityRef ref) async {
  final service = ref.watch(featureRoadmapServiceProvider);
  return service.getRoadmapByPriority();
}

@riverpod
Future<List<RoadmapItem>> roadmapByTimeline(RoadmapByTimelineRef ref) async {
  final service = ref.watch(featureRoadmapServiceProvider);
  return service.getRoadmapByTimeline();
}

@riverpod
Future<double> roadmapCompletion(RoadmapCompletionRef ref) async {
  final service = ref.watch(featureRoadmapServiceProvider);
  return service.getCompletionPercentage();
}

// ============================================================================
// A/B Testing Providers
// ============================================================================

@riverpod
Future<List<ABTest>> activeABTests(ActiveABTestsRef ref) async {
  final service = ref.watch(abTestingServiceProvider);
  return service.getActiveTests();
}

@riverpod
Future<ABTest?> abTestResults(
  ABTestResultsRef ref,
  String testId,
) async {
  final service = ref.watch(abTestingServiceProvider);
  return service.getTestResults(testId);
}

// ============================================================================
// Community Providers
// ============================================================================

@riverpod
Future<UserProfile?> userProfile(
  UserProfileRef ref,
  String userId,
) async {
  final service = ref.watch(communityServiceProvider);
  return service.getUserProfile(userId);
}

@riverpod
Future<List<CommunityPost>> communityFeed(CommunityFeedRef ref) async {
  final service = ref.watch(communityServiceProvider);
  return service.getCommunityFeed();
}

@riverpod
Future<List<UserProfile>> communityLeaderboard(CommunityLeaderboardRef ref) async {
  final service = ref.watch(communityServiceProvider);
  return service.getLeaderboard();
}

@riverpod
Future<List<PuzzleChallenge>> activeChallenges(
  ActiveChallengesRef ref,
  String userId,
) async {
  final service = ref.watch(communityServiceProvider);
  return service.getActiveChallenges(userId);
}

@riverpod
Future<List<CommunityGroup>> communityGroups(CommunityGroupsRef ref) async {
  final service = ref.watch(communityServiceProvider);
  return service.getCommunityGroups();
}

// ============================================================================
// Version Management Providers
// ============================================================================

@riverpod
String currentAppVersion(CurrentAppVersionRef ref) {
  final service = ref.watch(versionManagementServiceProvider);
  return service.getCurrentVersion();
}

@riverpod
int currentBuildNumber(CurrentBuildNumberRef ref) {
  final service = ref.watch(versionManagementServiceProvider);
  return service.getCurrentBuildNumber();
}

@riverpod
Future<AppVersion?> availableUpdate(AvailableUpdateRef ref) async {
  final service = ref.watch(versionManagementServiceProvider);
  return service.checkForUpdates();
}

@riverpod
Future<String> versionReleaseNotes(
  VersionReleaseNotesRef ref,
  String version,
) async {
  final service = ref.watch(versionManagementServiceProvider);
  return service.getVersionReleaseNotes(version);
}

// ============================================================================
// State Notifiers for Mutable Operations
// ============================================================================

class FeedbackSubmissionNotifier extends StateNotifier<AsyncValue<void>> {
  final FeedbackService _feedbackService;

  FeedbackSubmissionNotifier(this._feedbackService) : super(const AsyncValue.data(null));

  Future<void> submitFeedback({
    required String userId,
    required FeedbackCategory category,
    required String message,
    required int rating,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _feedbackService.submitFeedback(
        userId: userId,
        category: category,
        message: message,
        rating: rating,
        deviceInfo: 'device_info',
        appVersion: '1.0.0',
        metadata: {},
      );
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

@riverpod
StateNotifier<AsyncValue<void>> feedbackSubmission(
    FeedbackSubmissionRef ref) {
  final service = ref.watch(feedbackServiceProvider);
  return FeedbackSubmissionNotifier(service);
}

class RoadmapUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  final FeatureRoadmapService _roadmapService;

  RoadmapUpdateNotifier(this._roadmapService)
      : super(const AsyncValue.data(null));

  Future<void> updateRoadmapItemStatus(
      String itemId, RoadmapStatus status) async {
    state = const AsyncValue.loading();
    try {
      await _roadmapService.updateRoadmapItemStatus(itemId, status);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

@riverpod
StateNotifier<AsyncValue<void>> roadmapUpdate(RoadmapUpdateRef ref) {
  final service = ref.watch(featureRoadmapServiceProvider);
  return RoadmapUpdateNotifier(service);
}

class CommunityPostNotifier extends StateNotifier<AsyncValue<void>> {
  final CommunityService _communityService;

  CommunityPostNotifier(this._communityService)
      : super(const AsyncValue.data(null));

  Future<void> createPost({
    required String authorId,
    required String content,
    required PostCategory category,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _communityService.createCommunityPost(
        authorId: authorId,
        content: content,
        category: category,
      );
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> upvotePost(String postId) async {
    state = const AsyncValue.loading();
    try {
      await _communityService.upvotePost(postId);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

@riverpod
StateNotifier<AsyncValue<void>> communityPostNotifier(
    CommunityPostNotifierRef ref) {
  final service = ref.watch(communityServiceProvider);
  return CommunityPostNotifier(service);
}
