import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/analytics.dart';

/// Firebase Analytics Service
class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService(this._analytics);

  /// Log an analytics event
  Future<void> logEvent(
    String eventName, {
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      // Log errors silently to not disrupt user experience
      print('Analytics error: $e');
    }
  }

  /// Log a custom analytics event
  Future<void> logCustomEvent(AnalyticsEvent event) async {
    try {
      await _analytics.logEvent(
        name: event.eventType.analyticsName,
        parameters: {
          ...event.parameters,
          'timestamp': event.timestamp.toIso8601String(),
          if (event.userId != null) 'user_id': event.userId!,
          if (event.sessionId != null) 'session_id': event.sessionId!,
        },
      );
    } catch (e) {
      print('Analytics error: $e');
    }
  }

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    required String screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      print('Analytics error: $e');
    }
  }

  /// Log game completion
  Future<void> logGameCompleted({
    required String gameId,
    required String gameType,
    required int duration,
    required bool won,
    required int moveCount,
    int? ratingBefore,
    int? ratingAfter,
    String? result,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEventType.gameCompleted.analyticsName,
        parameters: {
          'game_id': gameId,
          'game_type': gameType,
          'duration_ms': duration,
          'won': won,
          'rating_before': ratingBefore ?? 0,
          'rating_after': ratingAfter ?? 0,
          'move_count': moveCount,
          'result': result ?? 'unknown',
        },
      );
    } catch (e) {
      print('Analytics error: $e');
    }
  }

  /// Log puzzle solved
  Future<void> logPuzzleSolved({
    required String puzzleId,
    required int difficulty,
    required int timeSpent,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEventType.puzzleSolved.analyticsName,
        parameters: {
          'puzzle_id': puzzleId,
          'difficulty': difficulty,
          'time_spent_ms': timeSpent,
        },
      );
    } catch (e) {
      print('Analytics error: $e');
    }
  }

  /// Log matchmaking event
  Future<void> logMatchmakingStarted({
    required String timeControl,
    String? colorPreference,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEventType.matchmakingStarted.analyticsName,
        parameters: {
          'time_control': timeControl,
          if (colorPreference != null) 'color_preference': colorPreference,
        },
      );
    } catch (e) {
      print('Analytics error: $e');
    }
  }

  /// Log match found
  Future<void> logMatchFound({
    required String gameId,
    required int waitTime,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEventType.matchFound.analyticsName,
        parameters: {
          'game_id': gameId,
          'wait_time_ms': waitTime,
        },
      );
    } catch (e) {
      print('Analytics error: $e');
    }
  }

  /// Log subscription event
  Future<void> logSubscriptionPurchased({
    required String productId,
    required double price,
    required String currency,
  }) async {
    try {
      await _analytics.logPurchase(
        currency: currency,
        value: price,
        items: [
          AnalyticsEventItem(itemName: productId),
        ],
      );

      await _analytics.logEvent(
        name: AnalyticsEventType.subscriptionPurchased.analyticsName,
        parameters: {
          'product_id': productId,
          'price': price,
          'currency': currency,
        },
      );
    } catch (e) {
      print('Analytics error: $e');
    }
  }

  /// Log trial started
  Future<void> logTrialStarted({
    required String productId,
    required int durationDays,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEventType.trialStarted.analyticsName,
        parameters: {
          'product_id': productId,
          'duration_days': durationDays,
        },
      );
    } catch (e) {
      print('Analytics error: $e');
    }
  }

  /// Log premium feature used
  Future<void> logPremiumFeatureUsed({
    required String featureName,
    Map<String, Object>? additionalData,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEventType.premiumFeatureUsed.analyticsName,
        parameters: {
          'feature_name': featureName,
          ...?additionalData,
        },
      );
    } catch (e) {
      print('Analytics error: $e');
    }
  }

  /// Log error
  Future<void> logError({
    required String errorCode,
    required String errorMessage,
    String? screenName,
  }) async {
    try {
      await _analytics.logEvent(
        name: AnalyticsEventType.errorOccurred.analyticsName,
        parameters: {
          'error_code': errorCode,
          'error_message': errorMessage,
          if (screenName != null) 'screen_name': screenName,
        },
      );
    } catch (e) {
      print('Analytics error: $e');
    }
  }

  /// Set user property
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      print('Analytics error: $e');
    }
  }

  /// Set user ID
  Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(userId);
    } catch (e) {
      print('Analytics error: $e');
    }
  }

  /// Reset analytics
  Future<void> reset() async {
    try {
      await _analytics.resetAnalyticsData();
    } catch (e) {
      print('Analytics error: $e');
    }
  }
}
