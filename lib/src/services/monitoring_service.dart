import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../config/deployment_config.dart';

/// Service for monitoring app health, performance, and user behavior post-launch
class MonitoringService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // ============================================================================
  // APP STARTUP & PERFORMANCE MONITORING
  // ============================================================================

  /// Track app startup time for performance monitoring
  Future<void> trackAppStartup(Duration startupTime) async {
    await _analytics.logEvent(
      name: 'app_startup_time',
      parameters: {
        'startup_time_ms': startupTime.inMilliseconds,
        'release_version': DeploymentConfig.appVersion,
        'build_number': DeploymentConfig.buildNumber,
      },
    );

    // Alert if startup time exceeds target (3 seconds)
    if (startupTime.inMilliseconds > 3000) {
      await _logPerformanceWarning(
        'app_startup_slow',
        'App startup took ${startupTime.inSeconds}s (target: <3s)',
      );
    }
  }

  /// Track screen transition performance
  Future<void> trackScreenTransition(
    String fromScreen,
    String toScreen,
    Duration transitionTime,
  ) async {
    await _analytics.logEvent(
      name: 'screen_transition',
      parameters: {
        'from_screen': fromScreen,
        'to_screen': toScreen,
        'transition_time_ms': transitionTime.inMilliseconds,
        'release_version': DeploymentConfig.appVersion,
      },
    );

    // Alert if transition is slow (>500ms)
    if (transitionTime.inMilliseconds > 500) {
      await _logPerformanceWarning(
        'screen_transition_slow',
        '$fromScreen → $toScreen took ${transitionTime.inMilliseconds}ms',
      );
    }
  }

  /// Track feature-specific performance
  Future<void> trackFeaturePerformance(
    String featureName,
    Duration duration,
    Map<String, dynamic> metadata,
  ) async {
    await _analytics.logEvent(
      name: 'feature_performance',
      parameters: {
        'feature_name': featureName,
        'duration_ms': duration.inMilliseconds,
        'release_version': DeploymentConfig.appVersion,
        ...metadata,
      },
    );
  }

  // ============================================================================
  // ERROR & CRASH TRACKING
  // ============================================================================

  /// Record uncaught exceptions with detailed context
  Future<void> recordException(
    dynamic exception,
    StackTrace stackTrace,
    Map<String, dynamic>? context,
  ) async {
    // Log to Crashlytics
    await _crashlytics.recordError(
      exception,
      stackTrace,
      reason: 'Uncaught exception in ${context?['screen'] ?? 'unknown'}',
      fatal: false,
    );

    // Also log to Analytics for tracking
    await _analytics.logEvent(
      name: 'app_exception',
      parameters: {
        'error_type': exception.runtimeType.toString(),
        'error_message': exception.toString(),
        'screen': context?['screen'] ?? 'unknown',
        'feature': context?['feature'] ?? 'unknown',
        'release_version': DeploymentConfig.appVersion,
      },
    );

    // Check if this is a critical error
    if (_isCriticalError(exception)) {
      await _logCriticalError(exception, stackTrace, context);
    }
  }

  /// Track API/network errors
  Future<void> trackNetworkError(
    String endpoint,
    int? statusCode,
    String errorMessage,
  ) async {
    await _analytics.logEvent(
      name: 'network_error',
      parameters: {
        'endpoint': endpoint,
        'status_code': statusCode ?? 0,
        'error_message': errorMessage,
        'release_version': DeploymentConfig.appVersion,
      },
    );

    // Alert on critical HTTP errors
    if (statusCode == 500 || statusCode == 503) {
      await _logCriticalError(
        Exception('Server error: $statusCode'),
        StackTrace.current,
        {'endpoint': endpoint},
      );
    }
  }

  /// Track validation/input errors
  Future<void> trackValidationError(
    String fieldName,
    String validationRule,
    dynamic invalidValue,
  ) async {
    await _analytics.logEvent(
      name: 'validation_error',
      parameters: {
        'field_name': fieldName,
        'validation_rule': validationRule,
        'invalid_type': invalidValue.runtimeType.toString(),
        'release_version': DeploymentConfig.appVersion,
      },
    );
  }

  // ============================================================================
  // ENGAGEMENT & HEALTH METRICS
  // ============================================================================

  /// Track user engagement metrics
  Future<void> trackEngagement(
    String userId,
    String subscriptionTier,
    Duration sessionDuration,
  ) async {
    await _analytics.logEvent(
      name: 'user_engagement',
      parameters: {
        'user_id': userId,
        'subscription_tier': subscriptionTier,
        'session_duration_seconds': sessionDuration.inSeconds,
        'release_version': DeploymentConfig.appVersion,
      },
    );

    // Set user properties for segmentation
    await _setUserProperties(userId, subscriptionTier);
  }

  /// Track retention
  Future<void> trackRetention(String userId, int daysSinceInstall) async {
    await _analytics.logEvent(
      name: 'retention_check',
      parameters: {
        'user_id': userId,
        'days_since_install': daysSinceInstall,
        'is_retained': daysSinceInstall >= 1,
        'release_version': DeploymentConfig.appVersion,
      },
    );
  }

  /// Track churn risk
  Future<void> trackChurnRisk(String userId, Map<String, dynamic> riskFactors) async {
    await _analytics.logEvent(
      name: 'churn_risk',
      parameters: {
        'user_id': userId,
        'days_since_last_session': riskFactors['daysSinceLastSession'] ?? 0,
        'session_count': riskFactors['sessionCount'] ?? 0,
        'avg_session_duration_seconds': riskFactors['avgSessionDuration'] ?? 0,
        'has_premium': riskFactors['hasPremium'] ?? false,
        'release_version': DeploymentConfig.appVersion,
      },
    );
  }

  // ============================================================================
  // RELEASE-SPECIFIC MONITORING
  // ============================================================================

  /// Track installation source (marketing attribution)
  Future<void> trackInstallSource(String source, String? campaign) async {
    await _analytics.logEvent(
      name: 'app_install',
      parameters: {
        'source': source, // 'organic', 'app_store', 'campaign', etc.
        'campaign': campaign ?? 'unknown',
        'release_version': DeploymentConfig.appVersion,
        'install_timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track app rating/review submissions
  Future<void> trackRatingSubmission(int rating, String? reviewText) async {
    await _analytics.logEvent(
      name: 'app_rating',
      parameters: {
        'rating': rating,
        'has_review': reviewText != null && reviewText.isNotEmpty,
        'review_length': reviewText?.length ?? 0,
        'release_version': DeploymentConfig.appVersion,
      },
    );
  }

  /// Track first-time user experience metrics
  Future<void> trackFtuMetrics(
    String userId,
    Duration completionTime,
    bool completed,
  ) async {
    await _analytics.logEvent(
      name: 'ftu_completion',
      parameters: {
        'user_id': userId,
        'completion_time_seconds': completionTime.inSeconds,
        'completed': completed,
        'release_version': DeploymentConfig.appVersion,
      },
    );
  }

  // ============================================================================
  // FEATURE & BUSINESS METRICS
  // ============================================================================

  /// Track feature usage for launch monitoring
  Future<void> trackFeatureUsage(
    String featureName,
    Map<String, dynamic> metadata,
  ) async {
    await _analytics.logEvent(
      name: 'feature_usage_${featureName.replaceAll(' ', '_')}',
      parameters: {
        'feature_name': featureName,
        'release_version': DeploymentConfig.appVersion,
        ...metadata,
      },
    );
  }

  /// Track monetization events
  Future<void> trackMonetization(
    String eventType,
    String tier,
    double amount,
    String currency,
  ) async {
    await _analytics.logEvent(
      name: 'monetization_$eventType',
      parameters: {
        'subscription_tier': tier,
        'amount': amount,
        'currency': currency,
        'release_version': DeploymentConfig.appVersion,
      },
    );
  }

  /// Track social/sharing events
  Future<void> trackSharing(String contentType, String shareMethod) async {
    await _analytics.logEvent(
      name: 'content_shared',
      parameters: {
        'content_type': contentType,
        'share_method': shareMethod,
        'release_version': DeploymentConfig.appVersion,
      },
    );
  }

  // ============================================================================
  // DEPLOYMENT HEALTH DASHBOARD DATA
  // ============================================================================

  /// Get current app health status
  Future<Map<String, dynamic>> getHealthStatus() async {
    return {
      'version': DeploymentConfig.appVersion,
      'buildNumber': DeploymentConfig.buildNumber,
      'deploymentStatus': DeploymentConfig.getDeploymentStatusString(),
      'timestamp': DateTime.now().toIso8601String(),
      // These would be fetched from Firebase Analytics in production
      'estimatedCrashRate': 0.0,
      'estimatedRating': 4.5,
      'estimatedDau': 0,
    };
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// Set user properties for analytics segmentation
  Future<void> _setUserProperties(String userId, String tier) async {
    await _analytics.setUserId(userId);
    await _analytics.setUserProperty(
      name: 'subscription_tier',
      value: tier,
    );
    await _analytics.setUserProperty(
      name: 'app_version',
      value: DeploymentConfig.appVersion,
    );
  }

  /// Check if error is critical (app-breaking)
  bool _isCriticalError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('crash') ||
        errorString.contains('fatal') ||
        errorString.contains('unhandled') ||
        errorString.contains('firebase');
  }

  /// Log critical errors with higher priority
  Future<void> _logCriticalError(
    dynamic error,
    StackTrace stackTrace,
    Map<String, dynamic>? context,
  ) async {
    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: 'CRITICAL: ${context?['screen'] ?? 'unknown'}',
      fatal: true,
    );

    if (kDebugMode) {
      debugPrint('CRITICAL ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Log performance warnings
  Future<void> _logPerformanceWarning(String metric, String message) async {
    await _crashlytics.log('PERF_WARNING: $metric - $message');
  }
}
