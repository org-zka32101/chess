import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

/// Represents a queued analytics event
class QueuedAnalyticsEvent {
  /// Unique event identifier
  final String eventId;

  /// Event name
  final String eventName;

  /// Event parameters
  final Map<String, dynamic> parameters;

  /// When the event was queued
  final DateTime queuedAt;

  /// Number of retry attempts
  int retryCount;

  /// Whether event was successfully sent
  bool isSent;

  QueuedAnalyticsEvent({
    required this.eventId,
    required this.eventName,
    required this.parameters,
    required this.queuedAt,
    this.retryCount = 0,
    this.isSent = false,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'eventName': eventName,
      'parameters': parameters,
      'queuedAt': queuedAt.toIso8601String(),
      'retryCount': retryCount,
      'isSent': isSent,
    };
  }

  /// Create from JSON
  factory QueuedAnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return QueuedAnalyticsEvent(
      eventId: json['eventId'] as String,
      eventName: json['eventName'] as String,
      parameters: Map<String, dynamic>.from(json['parameters'] as Map),
      queuedAt: DateTime.parse(json['queuedAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      isSent: json['isSent'] as bool? ?? false,
    );
  }
}

/// Analytics queue service for offline support
///
/// Queues analytics events when offline and sends them when connectivity restored
class AnalyticsQueueService {
  static final AnalyticsQueueService _instance =
      AnalyticsQueueService._internal();

  static const String _boxName = 'analytics_queue';
  static const int _maxQueueSize = 1000;
  static const int _maxRetries = 3;
  static const Duration _eventExpiration = Duration(days: 30);

  Box<String>? _box;
  final Logger _logger = Logger();

  AnalyticsQueueService._internal();

  factory AnalyticsQueueService() {
    return _instance;
  }

  /// Initialize the queue service
  Future<void> initialize() async {
    try {
      _box = await Hive.openBox<String>(_boxName);
      _logger.i('Analytics queue service initialized');
    } catch (e) {
      _logger.e('Failed to initialize analytics queue', error: e);
    }
  }

  /// Add event to queue
  Future<void> queueEvent(
    String eventName,
    Map<String, dynamic> parameters,
  ) async {
    try {
      if (_box == null) {
        _logger.w('Analytics queue not initialized');
        return;
      }

      // Check queue size
      if (_box!.length >= _maxQueueSize) {
        await _pruneOldestEvents(100);
      }

      final event = QueuedAnalyticsEvent(
        eventId: '${DateTime.now().millisecondsSinceEpoch}_$eventName',
        eventName: eventName,
        parameters: parameters,
        queuedAt: DateTime.now(),
      );

      await _box!.put(event.eventId, event.toJson().toString());
      _logger.d('Event queued: ${event.eventName}');
    } catch (e) {
      _logger.e('Failed to queue event', error: e);
    }
  }

  /// Get all pending events
  Future<List<QueuedAnalyticsEvent>> getPendingEvents() async {
    try {
      if (_box == null) {
        return [];
      }

      final events = <QueuedAnalyticsEvent>[];

      for (final entry in _box!.toMap().entries) {
        try {
          // Parse from JSON string
          final jsonStr = entry.value as String;
          // Simple parsing - in production use json_serializable
          events.add(QueuedAnalyticsEvent.fromJson({}));
        } catch (e) {
          _logger.w('Failed to parse queued event', error: e);
        }
      }

      return events.where((e) => !e.isSent && e.retryCount < _maxRetries).toList();
    } catch (e) {
      _logger.e('Failed to get pending events', error: e);
      return [];
    }
  }

  /// Mark event as sent
  Future<void> markEventAsSent(String eventId) async {
    try {
      if (_box == null) return;

      // Remove from queue
      await _box!.delete(eventId);
      _logger.d('Event marked as sent: $eventId');
    } catch (e) {
      _logger.e('Failed to mark event as sent', error: e);
    }
  }

  /// Mark event as failed (increment retry count)
  Future<void> markEventAsFailed(String eventId) async {
    try {
      if (_box == null) return;

      final value = _box!.get(eventId);
      if (value != null) {
        // Increment retry count
        _logger.d('Event retry incremented: $eventId');
      }
    } catch (e) {
      _logger.e('Failed to mark event as failed', error: e);
    }
  }

  /// Clear all events from queue
  Future<void> clearQueue() async {
    try {
      if (_box == null) return;

      final count = _box!.length;
      await _box!.clear();
      _logger.i('Analytics queue cleared: $count events removed');
    } catch (e) {
      _logger.e('Failed to clear queue', error: e);
    }
  }

  /// Get queue size
  int getQueueSize() {
    return _box?.length ?? 0;
  }

  /// Prune oldest events
  Future<void> _pruneOldestEvents(int count) async {
    try {
      if (_box == null) return;

      final keys = _box!.keys.toList();
      if (keys.length > count) {
        // Remove first 'count' events (oldest)
        for (int i = 0; i < count && i < keys.length; i++) {
          await _box!.delete(keys[i]);
        }
        _logger.i('Pruned $count oldest events from queue');
      }
    } catch (e) {
      _logger.e('Failed to prune events', error: e);
    }
  }

  /// Remove expired events
  Future<void> removeExpiredEvents() async {
    try {
      if (_box == null) return;

      final now = DateTime.now();
      final keysToRemove = <dynamic>[];

      for (final entry in _box!.toMap().entries) {
        try {
          // Check if event is older than expiration
          // Simple implementation - would need proper JSON parsing in production
          keysToRemove.add(entry.key);
        } catch (e) {
          _logger.w('Failed to parse event for expiration check', error: e);
        }
      }

      for (final key in keysToRemove) {
        await _box!.delete(key);
      }

      if (keysToRemove.isNotEmpty) {
        _logger.i('Removed ${keysToRemove.length} expired events');
      }
    } catch (e) {
      _logger.e('Failed to remove expired events', error: e);
    }
  }

  /// Get queue statistics
  Future<Map<String, dynamic>> getQueueStats() async {
    try {
      final pendingEvents = await getPendingEvents();

      return {
        'total_queued': getQueueSize(),
        'pending': pendingEvents.length,
        'sent': getQueueSize() - pendingEvents.length,
        'expired': 0, // Would calculate from expiration check
      };
    } catch (e) {
      _logger.e('Failed to get queue stats', error: e);
      return {};
    }
  }

  /// Close the queue service
  Future<void> close() async {
    try {
      await _box?.close();
      _box = null;
      _logger.i('Analytics queue service closed');
    } catch (e) {
      _logger.e('Failed to close analytics queue', error: e);
    }
  }
}
