# Phase D Stage 2: Sound Effects & Notifications

**Status**: Ready for Execution  
**Date**: 2026-09-03  
**Duration**: Week 12 (3-4 days)  
**Target**: Audio integration, notification systems, user engagement

---

## Overview

Phase D Stage 2 integrates sound effects, background music, and push notifications to enhance user engagement and provide audio feedback for game actions.

**Timeline**: Week 12 (post-Stage 1)  
**Success Criteria**: Sound system functional, notifications working, audio preferences configurable

---

## 1. Sound Effects System

### 1.1 Audio Asset Management

**Sound Library Structure**:
```
assets/audio/
├── sfx/
│   ├── move.wav              # Move piece sound
│   ├── capture.wav           # Capture sound
│   ├── check.wav             # Check alert
│   ├── checkmate.wav         # Game over
│   ├── win.wav               # Victory
│   ├── lose.wav              # Defeat
│   ├── button_tap.wav        # UI interaction
│   ├── puzzle_complete.wav   # Puzzle solved
│   └── achievement.wav       # Achievement unlocked
├── music/
│   ├── theme.mp3             # Background theme
│   ├── game_ambience.mp3     # Game ambience
│   └── puzzle_focus.mp3      # Puzzle mode music
└── notifications/
    ├── ding.wav              # Standard notification
    ├── achievement.wav       # Achievement sound
    └── reminder.wav          # Reminder sound
```

**Audio Assets Quality**:
```
Sound Effects:
├─ Format: WAV, 44.1 kHz, Stereo
├─ Duration: 100-500ms
├─ File size: <100KB each
└─ Compression: None (for quality)

Background Music:
├─ Format: MP3, 128 kbps
├─ Duration: 30-60 seconds (loopable)
├─ File size: <1MB
└─ Compression: Standard

Notifications:
├─ Format: WAV or MP3
├─ Duration: 1-3 seconds
└─ File size: <50KB
```

### 1.2 Audio Service Implementation

```dart
// lib/src/services/audio_service.dart

import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  Future<void> initialize() async {
    // Set audio context for proper categorization
    await _sfxPlayer.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          options: {
            AVAudioSessionOptions.duckOthers,
          },
          category: AVAudioSessionCategory.ambient,
        ),
        android: AudioContextAndroid(
          audioFocus: AndroidAudioFocus.gainTransient,
          audioAttributesFlags: AndroidAudioAttributesFlags.contentTypeSonification,
        ),
      ),
    );

    // Set music player to use appropriate settings
    await _musicPlayer.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
        ),
        android: AudioContextAndroid(
          audioFocus: AndroidAudioFocus.gain,
          audioAttributesFlags: AndroidAudioAttributesFlags.contentTypeMusic,
        ),
      ),
    );
  }

  // Play sound effect
  Future<void> playSfx(String soundName) async {
    try {
      final assetPath = 'assets/audio/sfx/$soundName.wav';
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  // Play background music (loops)
  Future<void> playMusic(String trackName, {bool loop = true}) async {
    try {
      final assetPath = 'assets/audio/music/$trackName.mp3';
      await _musicPlayer.play(
        AssetSource(assetPath),
        volume: 0.3, // Background music lower volume
      );
      if (loop) {
        await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      }
    } catch (e) {
      debugPrint('Error playing music: $e');
    }
  }

  // Stop music
  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  // Set volume
  Future<void> setSfxVolume(double volume) async {
    await _sfxPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> setMusicVolume(double volume) async {
    await _musicPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  // Dispose
  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
  }
}
```

### 1.3 Game Event Sound Triggers

```dart
// lib/src/services/game_sound_service.dart

class GameSoundService {
  final AudioService _audioService = AudioService();

  Future<void> onMoveMade(ChessMove move) async {
    if (move.isCapture) {
      await _audioService.playSfx('capture');
    } else {
      await _audioService.playSfx('move');
    }
  }

  Future<void> onCheck() async {
    await _audioService.playSfx('check');
  }

  Future<void> onCheckmate(bool isWin) async {
    await _audioService.playSfx(isWin ? 'checkmate' : 'lose');
  }

  Future<void> onPuzzleComplete() async {
    await _audioService.playSfx('puzzle_complete');
  }

  Future<void> onAchievementUnlocked() async {
    await _audioService.playSfx('achievement');
  }

  Future<void> onButtonTap() async {
    await _audioService.playSfx('button_tap');
  }

  Future<void> startGameMusic() async {
    await _audioService.playMusic('game_ambience');
  }

  Future<void> startPuzzleMusic() async {
    await _audioService.playMusic('puzzle_focus');
  }

  Future<void> stopMusic() async {
    await _audioService.stopMusic();
  }
}
```

---

## 2. Audio Preferences

### 2.1 Audio Preferences Provider

```dart
// lib/src/providers/audio_preferences_provider.dart

final audioPreferencesProvider = StateNotifierProvider<
    AudioPreferencesNotifier,
    AudioPreferences>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AudioPreferencesNotifier(prefs);
});

class AudioPreferences {
  final bool soundEnabled;
  final bool musicEnabled;
  final bool notificationsEnabled;
  final double sfxVolume;
  final double musicVolume;
  final bool hapticFeedback;

  const AudioPreferences({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.notificationsEnabled = true,
    this.sfxVolume = 0.8,
    this.musicVolume = 0.5,
    this.hapticFeedback = true,
  });

  AudioPreferences copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? notificationsEnabled,
    double? sfxVolume,
    double? musicVolume,
    bool? hapticFeedback,
  }) {
    return AudioPreferences(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    );
  }
}

class AudioPreferencesNotifier extends StateNotifier<AudioPreferences> {
  AudioPreferencesNotifier(this._prefs)
      : super(AudioPreferences());

  final SharedPreferences _prefs;

  Future<void> loadPreferences() async {
    state = AudioPreferences(
      soundEnabled: _prefs.getBool('sound_enabled') ?? true,
      musicEnabled: _prefs.getBool('music_enabled') ?? true,
      notificationsEnabled: _prefs.getBool('notifications_enabled') ?? true,
      sfxVolume: _prefs.getDouble('sfx_volume') ?? 0.8,
      musicVolume: _prefs.getDouble('music_volume') ?? 0.5,
      hapticFeedback: _prefs.getBool('haptic_feedback') ?? true,
    );
  }

  Future<void> toggleSound() async {
    final newState = state.copyWith(soundEnabled: !state.soundEnabled);
    await _prefs.setBool('sound_enabled', newState.soundEnabled);
    state = newState;
  }

  Future<void> toggleMusic() async {
    final newState = state.copyWith(musicEnabled: !state.musicEnabled);
    await _prefs.setBool('music_enabled', newState.musicEnabled);
    state = newState;
  }

  Future<void> setSfxVolume(double volume) async {
    final newState = state.copyWith(sfxVolume: volume);
    await _prefs.setDouble('sfx_volume', volume);
    state = newState;
  }

  Future<void> setMusicVolume(double volume) async {
    final newState = state.copyWith(musicVolume: volume);
    await _prefs.setDouble('music_volume', volume);
    state = newState;
  }

  Future<void> toggleHapticFeedback() async {
    final newState = state.copyWith(
      hapticFeedback: !state.hapticFeedback,
    );
    await _prefs.setBool('haptic_feedback', newState.hapticFeedback);
    state = newState;
  }
}
```

### 2.2 Audio Settings Screen

```dart
// lib/src/screens/settings/audio_settings_screen.dart

class AudioSettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPrefs = ref.watch(audioPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Sound & Audio')),
      body: ListView(
        children: [
          // Sound Effects
          SwitchListTile(
            title: Text('Sound Effects'),
            subtitle: Text('Move and game sounds'),
            value: audioPrefs.soundEnabled,
            onChanged: (value) {
              ref.read(audioPreferencesProvider.notifier).toggleSound();
            },
          ),
          if (audioPrefs.soundEnabled)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sound Volume'),
                  Slider(
                    value: audioPrefs.sfxVolume,
                    onChanged: (value) {
                      ref
                          .read(audioPreferencesProvider.notifier)
                          .setSfxVolume(value);
                    },
                  ),
                ],
              ),
            ),
          Divider(),

          // Music
          SwitchListTile(
            title: Text('Background Music'),
            subtitle: Text('Game and puzzle background'),
            value: audioPrefs.musicEnabled,
            onChanged: (value) {
              ref.read(audioPreferencesProvider.notifier).toggleMusic();
            },
          ),
          if (audioPrefs.musicEnabled)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Music Volume'),
                  Slider(
                    value: audioPrefs.musicVolume,
                    onChanged: (value) {
                      ref
                          .read(audioPreferencesProvider.notifier)
                          .setMusicVolume(value);
                    },
                  ),
                ],
              ),
            ),
          Divider(),

          // Notifications
          SwitchListTile(
            title: Text('Push Notifications'),
            subtitle: Text('Match found, achievements, etc'),
            value: audioPrefs.notificationsEnabled,
            onChanged: (value) {
              // TODO: Implement notification toggle
            },
          ),
          Divider(),

          // Haptic Feedback
          SwitchListTile(
            title: Text('Haptic Feedback'),
            subtitle: Text('Vibration on interactions'),
            value: audioPrefs.hapticFeedback,
            onChanged: (value) {
              ref
                  .read(audioPreferencesProvider.notifier)
                  .toggleHapticFeedback();
            },
          ),
        ],
      ),
    );
  }
}
```

---

## 3. Push Notifications

### 3.1 Firebase Cloud Messaging Setup

```dart
// lib/src/services/notifications_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationsService {
  static final NotificationsService _instance =
      NotificationsService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  factory NotificationsService() {
    return _instance;
  }

  NotificationsService._internal();

  Future<void> initialize() async {
    // Request notification permission
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

    debugPrint('Notification permission: ${settings.authorizationStatus}');

    // Get and store FCM token
    final fcmToken = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $fcmToken');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received message: ${message.messageId}');
      _handleForegroundMessage(message);
    });

    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message tapped: ${message.messageId}');
      _handleMessageTap(message);
    });

    // Handle background message
    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      debugPrint('Token refreshed: $fcmToken');
      // Update token on server
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;

    debugPrint('Foreground message: ${notification?.title}');

    // Show local notification if app is in foreground
    if (notification != null) {
      _showLocalNotification(
        title: notification.title ?? '',
        body: notification.body ?? '',
        payload: jsonEncode(data),
      );
    }
  }

  void _handleMessageTap(RemoteMessage message) {
    final data = message.data;

    // Navigate based on notification type
    if (data['type'] == 'match_found') {
      // Navigate to game
    } else if (data['type'] == 'achievement') {
      // Show achievement
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // TODO: Implement local notifications using flutter_local_notifications
  }

  Future<void> sendTestNotification() async {
    // Server-side implementation would send this
    // For testing, use Firebase Console
  }
}

// Background message handler (must be top-level)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  // Handle notification in background
}
```

### 3.2 Local Notifications

```dart
// lib/src/services/local_notifications_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsService {
  static final LocalNotificationsService _instance =
      LocalNotificationsService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory LocalNotificationsService() {
    return _instance;
  }

  LocalNotificationsService._internal();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationResponse(response);
      },
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'chess_channel',
      'Chess Notifications',
      channelDescription: 'Notifications for chess game events',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      debugPrint('Notification tapped with payload: $payload');
      // Navigate based on payload
    }
  }
}
```

### 3.3 Notification Types

**Game Notifications**:
```dart
// Match notifications
showNotification(
  id: 1,
  title: 'Match Found!',
  body: 'You have been matched with $playerName. Let\'s play!',
  payload: jsonEncode({'type': 'match', 'game_id': gameId}),
);

// Achievement notifications
showNotification(
  id: 2,
  title: 'Achievement Unlocked!',
  body: 'Tactical Genius - Solve 10 puzzles in a row',
  payload: jsonEncode({'type': 'achievement', 'id': achievementId}),
);

// Reminder notifications
showNotification(
  id: 3,
  title: 'Time to Practice',
  body: 'Your daily puzzles are waiting. Solve 3 to earn rewards!',
  payload: jsonEncode({'type': 'reminder'}),
);
```

---

## 4. Haptic Feedback

### 4.1 Haptic Feedback Service

```dart
// lib/src/services/haptic_service.dart

import 'package:flutter/services.dart';

class HapticService {
  static Future<void> lightTap() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
  }

  static Future<void> mediumTap() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
  }

  static Future<void> heavyTap() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
  }

  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
  }
}
```

### 4.2 Haptic Integration in UI

```dart
// In button widgets
GestureDetector(
  onTap: () async {
    await HapticService.mediumTap();
    onPressed();
  },
  child: child,
)

// In game board
GestureDetector(
  onTapDown: (details) async {
    await HapticService.lightTap();
    selectSquare(position);
  },
  child: ChessPiece(),
)
```

---

## 5. Sign-Off

**Phase D Stage 2 Complete**:
- [ ] Audio service implemented
- [ ] Sound effects integrated with game events
- [ ] Background music system working
- [ ] Audio preferences configurable
- [ ] Push notifications system set up
- [ ] Local notifications working
- [ ] Haptic feedback integrated
- [ ] Settings screen includes audio controls

**Ready to Proceed**: Phase D Stage 3 (Device Testing)

---

**Document Version**: 1.0  
**Last Updated**: 2026-09-03  
**Phase**: D Stage 2 (Sound & Notifications)  
**Status**: Ready for Implementation
