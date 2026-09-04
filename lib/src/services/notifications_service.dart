import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

/// Firebase Cloud Messaging notifications service
/// Handles push notifications, background messages, and notification routing
class NotificationsService {
  static final NotificationsService _instance =
      NotificationsService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Notification callback
  Function(NotificationPayload)? _onNotificationReceived;
  Function(String)? _onNotificationTapped;

  factory NotificationsService() {
    return _instance;
  }

  NotificationsService._internal();

  /// Initialize notifications service
  Future<void> initialize({
    Function(NotificationPayload)? onMessageReceived,
    Function(String)? onNotificationTapped,
  }) async {
    _onNotificationReceived = onMessageReceived;
    _onNotificationTapped = onNotificationTapped;

    try {
      // Request notification permissions
      final NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carryForward: true,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint(
        '[NotificationsService] Permission status: ${settings.authorizationStatus}',
      );

      // Get FCM token
      final fcmToken = await _firebaseMessaging.getToken();
      debugPrint('[NotificationsService] FCM Token: $fcmToken');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[NotificationsService] Foreground message: ${message.messageId}');
        _handleForegroundMessage(message);
      });

      // Handle messages when app is opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[NotificationsService] Message opened: ${message.messageId}');
        _handleMessageTap(message);
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
        debugPrint('[NotificationsService] Token refreshed: $fcmToken');
        _onTokenRefresh(fcmToken);
      });

      debugPrint('[NotificationsService] Initialized successfully');
    } catch (e) {
      debugPrint('[NotificationsService] Initialization error: $e');
    }
  }

  /// Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;

    debugPrint('[NotificationsService] Data: $data');

    if (_onNotificationReceived != null) {
      _onNotificationReceived!(
        NotificationPayload(
          title: notification?.title,
          body: notification?.body,
          data: data,
          messageId: message.messageId,
        ),
      );
    }
  }

  /// Handle message tap
  void _handleMessageTap(RemoteMessage message) {
    final data = message.data;
    debugPrint('[NotificationsService] Handling message tap with data: $data');

    if (_onNotificationTapped != null && data['type'] != null) {
      _onNotificationTapped!(data['type']!);
    }
  }

  /// Handle token refresh
  void _onTokenRefresh(String newToken) {
    // TODO: Send new token to backend
    debugPrint('[NotificationsService] Token refresh callback: $newToken');
  }

  /// Subscribe to notification topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('[NotificationsService] Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('[NotificationsService] Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from notification topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('[NotificationsService] Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('[NotificationsService] Error unsubscribing: $e');
    }
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('[NotificationsService] Error getting token: $e');
      return null;
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      debugPrint('[NotificationsService] Error checking status: $e');
      return false;
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      debugPrint('[NotificationsService] Error requesting permissions: $e');
      return false;
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[NotificationsService] Background message: ${message.messageId}');
  // Handle notification in background
  // This is called when app is terminated or in background
}

/// Notification payload model
class NotificationPayload {
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
  final String? messageId;

  NotificationPayload({
    this.title,
    this.body,
    required this.data,
    this.messageId,
  });

  /// Parse notification type from data
  String? get type => data['type'] as String?;

  /// Parse game ID from data
  String? get gameId => data['game_id'] as String?;

  /// Parse achievement ID from data
  String? get achievementId => data['achievement_id'] as String?;

  /// Convert to JSON string
  String toJson() => jsonEncode({
        'title': title,
        'body': body,
        'data': data,
        'messageId': messageId,
      });

  @override
  String toString() => 'NotificationPayload(title: $title, body: $body, '
      'type: $type, messageId: $messageId)';
}

/// Notification types
enum NotificationType {
  matchFound,
  gameInvite,
  gameUpdate,
  achievement,
  leaderboard,
  dailyReminder,
  promotion,
}

/// Notification type extensions
extension NotificationTypeExt on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.matchFound:
        return 'match_found';
      case NotificationType.gameInvite:
        return 'game_invite';
      case NotificationType.gameUpdate:
        return 'game_update';
      case NotificationType.achievement:
        return 'achievement';
      case NotificationType.leaderboard:
        return 'leaderboard';
      case NotificationType.dailyReminder:
        return 'daily_reminder';
      case NotificationType.promotion:
        return 'promotion';
    }
  }

  static NotificationType? fromValue(String? value) {
    return NotificationType.values.cast<NotificationType?>().firstWhere(
          (e) => e?.value == value,
          orElse: () => null,
        );
  }
}
