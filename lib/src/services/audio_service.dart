import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Audio service for sound effects and background music
/// Manages audio playback with proper context and volume control
class AudioService {
  static final AudioService _instance = AudioService._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _sfxVolume = 0.8;
  double _musicVolume = 0.5;

  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  /// Initialize audio service with proper context
  Future<void> initialize() async {
    try {
      // Configure SFX player for sound effects
      await _sfxPlayer.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            options: {AVAudioSessionOptions.duckOthers},
            category: AVAudioSessionCategory.ambient,
          ),
          android: AudioContextAndroid(
            audioFocus: AndroidAudioFocus.gainTransient,
            audioAttributesFlags:
                AndroidAudioAttributesFlags.contentTypeSonification,
          ),
        ),
      );

      // Configure music player for background music
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

      debugPrint('[AudioService] Initialized successfully');
    } catch (e) {
      debugPrint('[AudioService] Initialization error: $e');
    }
  }

  /// Play a sound effect
  /// Sound names should not include extension or path
  Future<void> playSfx(String soundName) async {
    if (!_soundEnabled) return;

    try {
      final assetPath = 'assets/audio/sfx/$soundName.wav';
      await _sfxPlayer.play(
        AssetSource(assetPath),
        volume: _sfxVolume,
      );
      debugPrint('[AudioService] Playing SFX: $soundName');
    } catch (e) {
      debugPrint('[AudioService] Error playing SFX: $e');
    }
  }

  /// Play background music (loops by default)
  Future<void> playMusic(
    String trackName, {
    bool loop = true,
  }) async {
    if (!_musicEnabled) return;

    try {
      final assetPath = 'assets/audio/music/$trackName.mp3';
      await _musicPlayer.play(
        AssetSource(assetPath),
        volume: _musicVolume,
      );

      if (loop) {
        await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      }

      debugPrint('[AudioService] Playing music: $trackName (loop: $loop)');
    } catch (e) {
      debugPrint('[AudioService] Error playing music: $e');
    }
  }

  /// Stop background music
  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
      debugPrint('[AudioService] Music stopped');
    } catch (e) {
      debugPrint('[AudioService] Error stopping music: $e');
    }
  }

  /// Pause background music
  Future<void> pauseMusic() async {
    try {
      await _musicPlayer.pause();
      debugPrint('[AudioService] Music paused');
    } catch (e) {
      debugPrint('[AudioService] Error pausing music: $e');
    }
  }

  /// Resume background music
  Future<void> resumeMusic() async {
    try {
      await _musicPlayer.resume();
      debugPrint('[AudioService] Music resumed');
    } catch (e) {
      debugPrint('[AudioService] Error resuming music: $e');
    }
  }

  /// Set SFX volume (0.0 to 1.0)
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    try {
      await _sfxPlayer.setVolume(_sfxVolume);
      debugPrint('[AudioService] SFX volume set to: $_sfxVolume');
    } catch (e) {
      debugPrint('[AudioService] Error setting SFX volume: $e');
    }
  }

  /// Set music volume (0.0 to 1.0)
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    try {
      await _musicPlayer.setVolume(_musicVolume);
      debugPrint('[AudioService] Music volume set to: $_musicVolume');
    } catch (e) {
      debugPrint('[AudioService] Error setting music volume: $e');
    }
  }

  /// Enable/disable sound effects
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    debugPrint('[AudioService] Sound effects: ${_soundEnabled ? 'enabled' : 'disabled'}');
  }

  /// Enable/disable background music
  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      stopMusic();
    }
    debugPrint('[AudioService] Music: ${_musicEnabled ? 'enabled' : 'disabled'}');
  }

  /// Get current SFX volume
  double getSfxVolume() => _sfxVolume;

  /// Get current music volume
  double getMusicVolume() => _musicVolume;

  /// Check if sound is enabled
  bool isSoundEnabled() => _soundEnabled;

  /// Check if music is enabled
  bool isMusicEnabled() => _musicEnabled;

  /// Dispose of audio resources
  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
    debugPrint('[AudioService] Disposed');
  }
}

/// Game-specific sound triggers
extension GameSoundExtension on AudioService {
  /// Play sound for chess piece move
  Future<void> onMoveMade({required bool isCapture}) async {
    await playSfx(isCapture ? 'capture' : 'move');
  }

  /// Play sound for check
  Future<void> onCheck() async {
    await playSfx('check');
  }

  /// Play sound for checkmate or game end
  Future<void> onGameEnd({required bool isWin}) async {
    await playSfx(isWin ? 'checkmate' : 'lose');
  }

  /// Play sound for puzzle completion
  Future<void> onPuzzleComplete() async {
    await playSfx('puzzle_complete');
  }

  /// Play sound for achievement unlock
  Future<void> onAchievementUnlocked() async {
    await playSfx('achievement');
  }

  /// Play sound for button tap
  Future<void> onButtonTap() async {
    await playSfx('button_tap');
  }

  /// Start game background music
  Future<void> startGameMusic() async {
    await playMusic('game_ambience');
  }

  /// Start puzzle mode background music
  Future<void> startPuzzleMusic() async {
    await playMusic('puzzle_focus');
  }
}
