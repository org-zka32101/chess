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
}

/// Sound service for managing audio playback
class SoundService {
  bool _soundEnabled = true;

  /// Set whether sound is enabled
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Play a sound effect
  Future<void> play(SoundEffect sound) async {
    if (!_soundEnabled) return;

    try {
      // TODO: Implement actual audio playback using audio_players or just_audio package
      // For now, this is a placeholder that logs the sound play
      if (kDebugMode) {
        print('[SOUND] Playing: ${sound.displayName}');
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
      await play(sound);
      await Future.delayed(const Duration(milliseconds: 100));
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
