import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'audio_preferences_provider.g.dart';

/// Audio preferences model
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

/// Audio preferences state notifier
@riverpod
class AudioPreferencesNotifier extends _$AudioPreferencesNotifier {
  static const String _soundEnabledKey = 'audio_sound_enabled';
  static const String _musicEnabledKey = 'audio_music_enabled';
  static const String _notificationsEnabledKey = 'audio_notifications_enabled';
  static const String _sfxVolumeKey = 'audio_sfx_volume';
  static const String _musicVolumeKey = 'audio_music_volume';
  static const String _hapticFeedbackKey = 'audio_haptic_feedback';

  @override
  Future<AudioPreferences> build() async {
    final prefs = await SharedPreferences.getInstance();

    return AudioPreferences(
      soundEnabled: prefs.getBool(_soundEnabledKey) ?? true,
      musicEnabled: prefs.getBool(_musicEnabledKey) ?? true,
      notificationsEnabled: prefs.getBool(_notificationsEnabledKey) ?? true,
      sfxVolume: prefs.getDouble(_sfxVolumeKey) ?? 0.8,
      musicVolume: prefs.getDouble(_musicVolumeKey) ?? 0.5,
      hapticFeedback: prefs.getBool(_hapticFeedbackKey) ?? true,
    );
  }

  /// Toggle sound effects
  Future<void> toggleSound() async {
    final prefs = await SharedPreferences.getInstance();
    final current = state.maybeWhen(
      data: (prefs) => prefs.soundEnabled,
      orElse: () => true,
    );
    final newValue = !current;

    await prefs.setBool(_soundEnabledKey, newValue);
    state = AsyncValue.data(
      (state.maybeWhen(
        data: (p) => p,
        orElse: () => const AudioPreferences(),
      )).copyWith(soundEnabled: newValue),
    );
  }

  /// Toggle music
  Future<void> toggleMusic() async {
    final prefs = await SharedPreferences.getInstance();
    final current = state.maybeWhen(
      data: (prefs) => prefs.musicEnabled,
      orElse: () => true,
    );
    final newValue = !current;

    await prefs.setBool(_musicEnabledKey, newValue);
    state = AsyncValue.data(
      (state.maybeWhen(
        data: (p) => p,
        orElse: () => const AudioPreferences(),
      )).copyWith(musicEnabled: newValue),
    );
  }

  /// Toggle notifications
  Future<void> toggleNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final current = state.maybeWhen(
      data: (prefs) => prefs.notificationsEnabled,
      orElse: () => true,
    );
    final newValue = !current;

    await prefs.setBool(_notificationsEnabledKey, newValue);
    state = AsyncValue.data(
      (state.maybeWhen(
        data: (p) => p,
        orElse: () => const AudioPreferences(),
      )).copyWith(notificationsEnabled: newValue),
    );
  }

  /// Set SFX volume
  Future<void> setSfxVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    final clampedVolume = volume.clamp(0.0, 1.0);

    await prefs.setDouble(_sfxVolumeKey, clampedVolume);
    state = AsyncValue.data(
      (state.maybeWhen(
        data: (p) => p,
        orElse: () => const AudioPreferences(),
      )).copyWith(sfxVolume: clampedVolume),
    );
  }

  /// Set music volume
  Future<void> setMusicVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    final clampedVolume = volume.clamp(0.0, 1.0);

    await prefs.setDouble(_musicVolumeKey, clampedVolume);
    state = AsyncValue.data(
      (state.maybeWhen(
        data: (p) => p,
        orElse: () => const AudioPreferences(),
      )).copyWith(musicVolume: clampedVolume),
    );
  }

  /// Toggle haptic feedback
  Future<void> toggleHapticFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    final current = state.maybeWhen(
      data: (prefs) => prefs.hapticFeedback,
      orElse: () => true,
    );
    final newValue = !current;

    await prefs.setBool(_hapticFeedbackKey, newValue);
    state = AsyncValue.data(
      (state.maybeWhen(
        data: (p) => p,
        orElse: () => const AudioPreferences(),
      )).copyWith(hapticFeedback: newValue),
    );
  }
}

/// Provider for audio preferences
@riverpod
Future<AudioPreferences> audioPreferences(AudioPreferencesRef ref) async {
  return ref.watch(audioPreferencesNotifierProvider.future);
}
