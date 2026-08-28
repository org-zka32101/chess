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
///
/// Current implementation is a placeholder that enables/disables sound and logs playback.
/// To implement actual audio playback:
/// 1. Add dependency: `flutter pub add just_audio` or `audio_players`
/// 2. Replace placeholder with actual implementation using AudioPlayer
/// 3. Ensure sound files are in assets/sounds/ directory in pubspec.yaml
/// 4. Test on both iOS and Android platforms
class SoundService {
  bool _soundEnabled = true;
  static final SoundService _instance = SoundService._internal();

  SoundService._internal();

  factory SoundService() => _instance;

  /// Set whether sound is enabled
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Get current sound enabled state
  bool get isSoundEnabled => _soundEnabled;

  /// Play a sound effect
  ///
  /// Placeholder implementation. To enable actual audio:
  /// 1. Add audio package (just_audio recommended for performance)
  /// 2. Load sound file from assetPath
  /// 3. Play with volume control
  Future<void> play(SoundEffect sound) async {
    if (!_soundEnabled) return;

    try {
      // Placeholder: Log sound play for testing
      // In production, would load and play: sound.assetPath
      if (kDebugMode) {
        print('[SOUND] Playing: ${sound.displayName} (${sound.assetPath})');
      }
      // TODO: Actual implementation
      // final player = AudioPlayer();
      // await player.setAsset(sound.assetPath);
      // await player.play();
    } catch (e) {
      if (kDebugMode) {
        print('[SOUND] Error playing ${sound.displayName}: $e');
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
  ///
  /// Placeholder implementation. In production would stop all active players.
  Future<void> stopAll() async {
    try {
      if (kDebugMode) {
        print('[SOUND] Stopping all sounds');
      }
      // TODO: Actual implementation
      // Stop all active audio players
    } catch (e) {
      if (kDebugMode) {
        print('[SOUND] Error stopping sounds: $e');
      }
    }
  }

  /// Dispose resources and cleanup audio players
  ///
  /// Call this when the app exits or sound service is no longer needed.
  /// In production, would dispose all active AudioPlayer instances.
  void dispose() {
    _soundEnabled = false;
    // TODO: Actual implementation
    // Dispose all active audio players to free resources
    if (kDebugMode) {
      print('[SOUND] SoundService disposed');
    }
  }
}

/// Riverpod provider for sound service
final soundServiceProvider = Provider((ref) => SoundService());
