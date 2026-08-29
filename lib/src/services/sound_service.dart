import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sound effects available in the app
enum SoundEffect {
  movePiece,
  capture,
  check,
  checkmate,
  gameOver,
  buttonTap,
  notification,
  success,
  error,
  uiSwipe,
}

extension SoundEffectExt on SoundEffect {
  String get assetPath {
    switch (this) {
      case SoundEffect.movePiece:
        return 'assets/sounds/move.mp3';
      case SoundEffect.capture:
        return 'assets/sounds/capture.mp3';
      case SoundEffect.check:
        return 'assets/sounds/check.mp3';
      case SoundEffect.checkmate:
        return 'assets/sounds/checkmate.mp3';
      case SoundEffect.gameOver:
        return 'assets/sounds/game_over.mp3';
      case SoundEffect.buttonTap:
        return 'assets/sounds/tap.mp3';
      case SoundEffect.notification:
        return 'assets/sounds/notification.mp3';
      case SoundEffect.success:
        return 'assets/sounds/success.mp3';
      case SoundEffect.error:
        return 'assets/sounds/error.mp3';
      case SoundEffect.uiSwipe:
        return 'assets/sounds/swipe.mp3';
    }
  }

  String get displayName {
    switch (this) {
      case SoundEffect.movePiece:
        return 'Piece Movement';
      case SoundEffect.capture:
        return 'Piece Capture';
      case SoundEffect.check:
        return 'Check Warning';
      case SoundEffect.checkmate:
        return 'Checkmate';
      case SoundEffect.gameOver:
        return 'Game Over';
      case SoundEffect.buttonTap:
        return 'Button Tap';
      case SoundEffect.notification:
        return 'Notification';
      case SoundEffect.success:
        return 'Success';
      case SoundEffect.error:
        return 'Error';
      case SoundEffect.uiSwipe:
        return 'UI Swipe';
    }
  }

  /// Categorize the sound effect
  SoundCategory get category {
    switch (this) {
      case SoundEffect.movePiece:
      case SoundEffect.capture:
      case SoundEffect.check:
        return SoundCategory.gamePlay;
      case SoundEffect.checkmate:
      case SoundEffect.gameOver:
        return SoundCategory.gameEnd;
      case SoundEffect.buttonTap:
      case SoundEffect.uiSwipe:
        return SoundCategory.ui;
      case SoundEffect.notification:
      case SoundEffect.success:
      case SoundEffect.error:
        return SoundCategory.notifications;
    }
  }
}

/// Sound categories for grouping effects
enum SoundCategory {
  gamePlay,      // Piece movement, capture, check
  gameEnd,       // Checkmate, game over
  ui,            // Button taps, swipes
  notifications, // Notifications, success, error
}

/// Sound service for managing audio playback with category-based control
class SoundService {
  bool _soundMasterEnabled = true;
  Map<SoundCategory, bool> _categoryEnabled = {
    SoundCategory.gamePlay: true,
    SoundCategory.gameEnd: true,
    SoundCategory.ui: true,
    SoundCategory.notifications: true,
  };
  double _volume = 1.0;

  /// Set whether master sound is enabled
  void setSoundMasterEnabled(bool enabled) {
    _soundMasterEnabled = enabled;
  }

  /// Set whether a category is enabled
  void setCategoryEnabled(SoundCategory category, bool enabled) {
    _categoryEnabled[category] = enabled;
  }

  /// Set the volume level (0.0 - 1.0)
  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
  }

  /// Check if a sound should play based on category and preferences
  bool _shouldPlaySound(SoundEffect sound) {
    if (!_soundMasterEnabled) return false;
    final category = sound.category;
    return _categoryEnabled[category] ?? true;
  }

  /// Play a sound effect with category checking
  Future<void> play(SoundEffect sound) async {
    if (!_shouldPlaySound(sound)) return;

    try {
      // TODO: Implement actual audio playback using audio_players or just_audio package
      // For now, this is a placeholder that logs the sound play
      if (kDebugMode) {
        print('[SOUND] Playing: ${sound.displayName} (Volume: ${(_volume * 100).toStringAsFixed(0)}%)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[SOUND] Error playing sound: $e');
      }
    }
  }

  /// Play multiple sounds in sequence
  Future<void> playSequence(List<SoundEffect> sounds) async {
    for (final sound in sounds) {
      if (_shouldPlaySound(sound)) {
        await play(sound);
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  /// Stop all sounds
  Future<void> stopAll() async {
    try {
      // TODO: Implement stop logic
      if (kDebugMode) {
        print('[SOUND] Stopping all sounds');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[SOUND] Error stopping sounds: $e');
      }
    }
  }

  /// Dispose resources
  void dispose() {
    // TODO: Dispose audio players
  }
}

/// Riverpod provider for sound service
final soundServiceProvider = Provider((ref) => SoundService());
