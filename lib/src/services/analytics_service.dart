import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Analytics events for Chess Tactics Master
enum AnalyticsEvent {
  appLaunched,
  userSignUp,
  userLogin,
  userLogout,
  profileViewed,
  settingsChanged,
  themeChanged,
  languageChanged,
  soundToggled,
  notificationsToggled,
  boardSizeChanged,

  // Puzzle events
  puzzleStarted,
  puzzleCompleted,
  puzzleSolved,
  puzzleFailed,
  dailyChallengeStarted,
  dailyChallengeCompleted,

  // Game events
  cpuGameStarted,
  cpuGameCompleted,
  cpuGameAbandoned,
  matchmakingStarted,
  matchmakingCancelled,
  matchFound,
  matchAccepted,
  matchDeclined,
  onlineGameStarted,
  onlineGameCompleted,
  onlineGameAbandoned,

  // Game actions
  movesMade,
  gameResigned,
  drawOffered,
  drawAccepted,
  drawDeclined,

  // Premium events
  premiumPageViewed,
  subscriptionStarted,
  subscriptionCancelled,
  subscriptionRenewed,
  premiumFeatureAccessed,

  // Error events
  errorOccurred,
}

extension AnalyticsEventExt on AnalyticsEvent {
  String get eventName {
    switch (this) {
      case AnalyticsEvent.appLaunched:
        return 'app_launched';
      case AnalyticsEvent.userSignUp:
        return 'user_sign_up';
      case AnalyticsEvent.userLogin:
        return 'user_login';
      case AnalyticsEvent.userLogout:
        return 'user_logout';
      case AnalyticsEvent.profileViewed:
        return 'profile_viewed';
      case AnalyticsEvent.settingsChanged:
        return 'settings_changed';
      case AnalyticsEvent.themeChanged:
        return 'theme_changed';
      case AnalyticsEvent.languageChanged:
        return 'language_changed';
      case AnalyticsEvent.soundToggled:
        return 'sound_toggled';
      case AnalyticsEvent.notificationsToggled:
        return 'notifications_toggled';
      case AnalyticsEvent.boardSizeChanged:
        return 'board_size_changed';
      case AnalyticsEvent.puzzleStarted:
        return 'puzzle_started';
      case AnalyticsEvent.puzzleCompleted:
        return 'puzzle_completed';
      case AnalyticsEvent.puzzleSolved:
        return 'puzzle_solved';
      case AnalyticsEvent.puzzleFailed:
        return 'puzzle_failed';
      case AnalyticsEvent.dailyChallengeStarted:
        return 'daily_challenge_started';
      case AnalyticsEvent.dailyChallengeCompleted:
        return 'daily_challenge_completed';
      case AnalyticsEvent.cpuGameStarted:
        return 'cpu_game_started';
      case AnalyticsEvent.cpuGameCompleted:
        return 'cpu_game_completed';
      case AnalyticsEvent.cpuGameAbandoned:
        return 'cpu_game_abandoned';
      case AnalyticsEvent.matchmakingStarted:
        return 'matchmaking_started';
      case AnalyticsEvent.matchmakingCancelled:
        return 'matchmaking_cancelled';
      case AnalyticsEvent.matchFound:
        return 'match_found';
      case AnalyticsEvent.matchAccepted:
        return 'match_accepted';
      case AnalyticsEvent.matchDeclined:
        return 'match_declined';
      case AnalyticsEvent.onlineGameStarted:
        return 'online_game_started';
      case AnalyticsEvent.onlineGameCompleted:
        return 'online_game_completed';
      case AnalyticsEvent.onlineGameAbandoned:
        return 'online_game_abandoned';
      case AnalyticsEvent.movesMade:
        return 'moves_made';
      case AnalyticsEvent.gameResigned:
        return 'game_resigned';
      case AnalyticsEvent.drawOffered:
        return 'draw_offered';
      case AnalyticsEvent.drawAccepted:
        return 'draw_accepted';
      case AnalyticsEvent.drawDeclined:
        return 'draw_declined';
      case AnalyticsEvent.premiumPageViewed:
        return 'premium_page_viewed';
      case AnalyticsEvent.subscriptionStarted:
        return 'subscription_started';
      case AnalyticsEvent.subscriptionCancelled:
        return 'subscription_cancelled';
      case AnalyticsEvent.subscriptionRenewed:
        return 'subscription_renewed';
      case AnalyticsEvent.premiumFeatureAccessed:
        return 'premium_feature_accessed';
      case AnalyticsEvent.errorOccurred:
        return 'error_occurred';
    }
  }
}

/// Analytics service for tracking user interactions and events
class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService(this._analytics);

  /// Log an event with optional parameters
  Future<void> logEvent(
    AnalyticsEvent event, {
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: event.eventName,
        parameters: parameters,
      );
    } catch (e) {
      print('[ANALYTICS] Error logging event: $e');
    }
  }

  /// Set user ID for analytics
  Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      print('[ANALYTICS] Error setting user ID: $e');
    }
  }

  /// Set user properties
  Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      print('[ANALYTICS] Error setting user property: $e');
    }
  }

  /// Log screen view
  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      print('[ANALYTICS] Error logging screen view: $e');
    }
  }

  /// Log puzzle attempt
  Future<void> logPuzzleAttempt({
    required String puzzleId,
    required int rating,
    required bool solved,
    required int timeSpent,
  }) async {
    await logEvent(
      solved ? AnalyticsEvent.puzzleSolved : AnalyticsEvent.puzzleFailed,
      parameters: {
        'puzzle_id': puzzleId,
        'rating': rating,
        'time_spent_seconds': timeSpent,
      },
    );
  }

  /// Log game completion
  Future<void> logGameCompletion({
    required String gameId,
    required String gameType, // 'cpu' or 'online'
    required String result, // 'win', 'loss', 'draw'
    required int movesCount,
    required int durationSeconds,
  }) async {
    final event = gameType == 'cpu'
        ? AnalyticsEvent.cpuGameCompleted
        : AnalyticsEvent.onlineGameCompleted;

    await logEvent(
      event,
      parameters: {
        'game_id': gameId,
        'result': result,
        'moves_count': movesCount,
        'duration_seconds': durationSeconds,
      },
    );
  }

  /// Log subscription event
  Future<void> logSubscriptionEvent({
    required String eventType, // 'started', 'cancelled', 'renewed'
    required String planId,
    required double price,
  }) async {
    final event = eventType == 'started'
        ? AnalyticsEvent.subscriptionStarted
        : eventType == 'cancelled'
            ? AnalyticsEvent.subscriptionCancelled
            : AnalyticsEvent.subscriptionRenewed;

    await logEvent(
      event,
      parameters: {
        'plan_id': planId,
        'price': price,
      },
    );
  }

  /// Log error
  Future<void> logError(String error, {String? errorCode}) async {
    await logEvent(
      AnalyticsEvent.errorOccurred,
      parameters: {
        'error_message': error,
        if (errorCode != null) 'error_code': errorCode,
      },
    );
  }
}

/// Riverpod provider for analytics service
final analyticsServiceProvider = Provider((ref) {
  return AnalyticsService(FirebaseAnalytics.instance);
});
