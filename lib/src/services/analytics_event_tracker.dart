import 'package:flutter/foundation.dart';
import 'analytics_service.dart';

/// Analytics event tracker for structured event logging
class AnalyticsEventTracker {
  static final AnalyticsEventTracker _instance = AnalyticsEventTracker._internal();

  final _analyticsService = AnalyticsService();
  final _trackedEvents = <String, int>{};
  final _eventChains = <String, List<String>>{};

  factory AnalyticsEventTracker() {
    return _instance;
  }

  AnalyticsEventTracker._internal();

  /// Track purchase event
  Future<void> trackPurchase({
    required String itemId,
    required double price,
    required String currency,
    required String type,
  }) async {
    await _analyticsService.logEvent(
      name: 'purchase',
      parameters: {
        'item_id': itemId,
        'price': price,
        'currency': currency,
        'purchase_type': type,
      },
    );
    _recordTrackedEvent('purchase');
  }

  /// Track subscription event
  Future<void> trackSubscription({
    required String subscriptionType,
    required String period,
    required double price,
  }) async {
    await _analyticsService.logEvent(
      name: 'subscription_purchase',
      parameters: {
        'subscription_type': subscriptionType,
        'period': period,
        'price': price,
      },
    );
    _recordTrackedEvent('subscription_purchase');
  }

  /// Track feature usage
  Future<void> trackFeatureUsage(String featureId) async {
    await _analyticsService.logEvent(
      name: 'feature_used',
      parameters: {'feature_id': featureId},
    );
    _recordTrackedEvent('feature_used');
  }

  /// Track game completion
  Future<void> trackGameCompletion({
    required String gameType,
    required String result,
    required int durationSeconds,
  }) async {
    await _analyticsService.logEvent(
      name: 'game_completed',
      parameters: {
        'game_type': gameType,
        'result': result,
        'duration_seconds': durationSeconds,
      },
    );
    _recordTrackedEvent('game_completed');
  }

  /// Track puzzle attempt
  Future<void> trackPuzzleAttempt({
    required String difficulty,
    required bool solved,
    required int durationSeconds,
  }) async {
    await _analyticsService.logEvent(
      name: 'puzzle_attempt',
      parameters: {
        'difficulty': difficulty,
        'solved': solved,
        'duration_seconds': durationSeconds,
      },
    );
    _recordTrackedEvent('puzzle_attempt');
  }

  /// Track user navigation
  Future<void> trackNavigation(String from, String to) async {
    await _analyticsService.logEvent(
      name: 'navigation',
      parameters: {
        'from': from,
        'to': to,
      },
    );
    _recordEventChain('navigation', '$from -> $to');
  }

  /// Track user action
  Future<void> trackUserAction({
    required String screen,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    await _analyticsService.logEvent(
      name: 'user_action',
      parameters: {
        'screen': screen,
        'action': action,
        ...?metadata,
      },
    );
    _recordTrackedEvent('user_action');
  }

  /// Track error
  Future<void> trackError({
    required String errorType,
    required String message,
  }) async {
    await _analyticsService.logEvent(
      name: 'error',
      parameters: {
        'error_type': errorType,
        'error_message': message,
      },
    );
    _recordTrackedEvent('error');
  }

  /// Track session event
  Future<void> trackSessionEvent({
    required String eventType,
    Map<String, dynamic>? data,
  }) async {
    await _analyticsService.logEvent(
      name: 'session_event',
      parameters: {
        'event_type': eventType,
        ...?data,
      },
    );
    _recordTrackedEvent('session_event');
  }

  /// Record tracked event count
  void _recordTrackedEvent(String eventName) {
    _trackedEvents[eventName] = (_trackedEvents[eventName] ?? 0) + 1;
  }

  /// Record event chain
  void _recordEventChain(String chainName, String event) {
    _eventChains.putIfAbsent(chainName, () => []).add(event);
  }

  /// Get all tracked events
  Map<String, int> getTrackedEvents() => Map.unmodifiable(_trackedEvents);

  /// Get event chains
  Map<String, List<String>> getEventChains() => Map.unmodifiable(_eventChains);

  /// Get event count
  int getEventCount(String eventName) => _trackedEvents[eventName] ?? 0;

  /// Generate tracking report
  String generateReport() {
    final buffer = StringBuffer();
    final totalEvents = _trackedEvents.values.fold<int>(0, (a, b) => a + b);

    buffer.writeln('''
╔══════════════════════════════════════════════════════════════════╗
║               EVENT TRACKING REPORT                             ║
╠══════════════════════════════════════════════════════════════════╣
║ Total Events: ${totalEvents.toString().padRight(50)}║
║ Unique Events: ${_trackedEvents.length.toString().padRight(47)}║
║ Event Chains: ${_eventChains.length.toString().padRight(48)}║
╠══════════════════════════════════════════════════════════════════╣
║ EVENT COUNTS:
    ''');

    for (final entry in _trackedEvents.entries) {
      buffer.writeln('║ ${entry.key.padRight(30)}: ${entry.value.toString().padRight(32)}║');
    }

    if (_eventChains.isNotEmpty) {
      buffer.writeln('''
╠══════════════════════════════════════════════════════════════════╣
║ EVENT CHAINS:
      ''');

      for (final entry in _eventChains.entries) {
        buffer.writeln('║ ${entry.key}:');
        for (final chain in entry.value) {
          buffer.writeln('║   → $chain');
        }
      }
    }

    buffer.writeln('''
╚══════════════════════════════════════════════════════════════════╝
    ''');

    return buffer.toString();
  }

  /// Clear all tracking data
  void clear() {
    _trackedEvents.clear();
    _eventChains.clear();
  }
}
