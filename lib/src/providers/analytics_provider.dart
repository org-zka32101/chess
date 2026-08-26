import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/analytics.dart';
import '../services/analytics_service.dart';
import 'auth_provider.dart';

/// Analytics service provider
final analyticsServiceProvider = Provider((ref) {
  final analytics = FirebaseAnalytics.instance;
  return AnalyticsService(analytics);
});

/// Analytics session notifier
class AnalyticsSessionNotifier extends StateNotifier<String?> {
  final AnalyticsService _service;

  AnalyticsSessionNotifier(this._service)
      : super(_generateSessionId()) {
    _initializeSession();
  }

  static String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _initializeSession() async {
    // Set session ID as user property for analytics
    await _service.setUserProperty(name: 'session_id', value: state!);
  }

  Future<void> endSession() async {
    state = null;
  }

  Future<void> startNewSession() async {
    state = _generateSessionId();
    await _initializeSession();
  }
}

/// Analytics session provider
final analyticsSessionProvider =
    StateNotifierProvider<AnalyticsSessionNotifier, String?>((ref) {
  final service = ref.watch(analyticsServiceProvider);
  return AnalyticsSessionNotifier(service);
});

/// Screen view tracker
final screenViewTrackerProvider =
    StateNotifierProvider<ScreenViewTrackerNotifier, AsyncValue<void>>((ref) {
  return ScreenViewTrackerNotifier(ref);
});

class ScreenViewTrackerNotifier extends StateNotifier<AsyncValue<void>> {
  final StateNotifierProviderRef ref;

  ScreenViewTrackerNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> trackScreenView({
    required String screenName,
    required String screenClass,
    Map<String, dynamic>? customData,
  }) async {
    state = const AsyncValue.loading();
    final service = ref.watch(analyticsServiceProvider);
    final sessionId = ref.watch(analyticsSessionProvider);

    state = await AsyncValue.guard(() async {
      await service.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );

      // Log custom event if additional data provided
      if (customData != null && customData.isNotEmpty) {
        await service.logCustomEvent(
          AnalyticsEvent(
            eventName: 'screen_view_detailed',
            eventType: AnalyticsEventType.screenViewed,
            timestamp: DateTime.now(),
            parameters: {
              'screen_name': screenName,
              'screen_class': screenClass,
              ...customData,
            },
            sessionId: sessionId,
          ),
        );
      }
    });
  }
}

/// Game analytics tracker
final gameAnalyticsTrackerProvider =
    StateNotifierProvider<GameAnalyticsTrackerNotifier, AsyncValue<void>>((ref) {
  return GameAnalyticsTrackerNotifier(ref);
});

class GameAnalyticsTrackerNotifier extends StateNotifier<AsyncValue<void>> {
  final StateNotifierProviderRef ref;

  GameAnalyticsTrackerNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> trackGameCompleted(GameAnalyticsData gameData) async {
    state = const AsyncValue.loading();
    final service = ref.watch(analyticsServiceProvider);

    state = await AsyncValue.guard(() async {
      await service.logGameCompleted(
        gameId: gameData.gameId,
        gameType: gameData.gameType,
        duration: gameData.duration,
        won: gameData.won,
        moveCount: gameData.moveCount,
        ratingBefore: gameData.ratingBefore,
        ratingAfter: gameData.ratingAfter,
        result: gameData.result,
      );
    });
  }

  Future<void> trackPuzzleSolved({
    required String puzzleId,
    required int difficulty,
    required int timeSpent,
  }) async {
    state = const AsyncValue.loading();
    final service = ref.watch(analyticsServiceProvider);

    state = await AsyncValue.guard(() async {
      await service.logPuzzleSolved(
        puzzleId: puzzleId,
        difficulty: difficulty,
        timeSpent: timeSpent,
      );
    });
  }
}

/// Subscription analytics tracker
final subscriptionAnalyticsTrackerProvider = StateNotifierProvider<
    SubscriptionAnalyticsTrackerNotifier, AsyncValue<void>>((ref) {
  return SubscriptionAnalyticsTrackerNotifier(ref);
});

class SubscriptionAnalyticsTrackerNotifier extends StateNotifier<AsyncValue<void>> {
  final StateNotifierProviderRef ref;

  SubscriptionAnalyticsTrackerNotifier(this.ref)
      : super(const AsyncValue.data(null));

  Future<void> trackSubscriptionPurchase({
    required String productId,
    required double price,
    required String currency,
  }) async {
    state = const AsyncValue.loading();
    final service = ref.watch(analyticsServiceProvider);

    state = await AsyncValue.guard(() async {
      await service.logSubscriptionPurchased(
        productId: productId,
        price: price,
        currency: currency,
      );
    });
  }

  Future<void> trackTrialStarted({
    required String productId,
    required int durationDays,
  }) async {
    state = const AsyncValue.loading();
    final service = ref.watch(analyticsServiceProvider);

    state = await AsyncValue.guard(() async {
      await service.logTrialStarted(
        productId: productId,
        durationDays: durationDays,
      );
    });
  }

  Future<void> trackPremiumFeatureUsed(String featureName) async {
    state = const AsyncValue.loading();
    final service = ref.watch(analyticsServiceProvider);

    state = await AsyncValue.guard(() async {
      await service.logPremiumFeatureUsed(
        featureName: featureName,
      );
    });
  }
}

/// Error tracking
final errorAnalyticsTrackerProvider = StateNotifierProvider<
    ErrorAnalyticsTrackerNotifier, AsyncValue<void>>((ref) {
  return ErrorAnalyticsTrackerNotifier(ref);
});

class ErrorAnalyticsTrackerNotifier extends StateNotifier<AsyncValue<void>> {
  final StateNotifierProviderRef ref;

  ErrorAnalyticsTrackerNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> trackError({
    required String errorCode,
    required String errorMessage,
    String? screenName,
  }) async {
    state = const AsyncValue.loading();
    final service = ref.watch(analyticsServiceProvider);

    state = await AsyncValue.guard(() async {
      await service.logError(
        errorCode: errorCode,
        errorMessage: errorMessage,
        screenName: screenName,
      );
    });
  }
}
