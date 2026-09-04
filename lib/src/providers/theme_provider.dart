import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

/// Theme mode state notifier
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  static const String _themeModeKey = 'theme_mode';

  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_themeModeKey);

    if (modeString != null) {
      return ThemeMode.values.firstWhere(
        (mode) => mode.toString() == modeString,
        orElse: () => ThemeMode.system,
      );
    }

    return ThemeMode.system;
  }

  /// Set the theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    state = AsyncValue.data(mode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.toString());
  }

  /// Toggle between light and dark mode
  /// If system is selected, switches to light, then dark, then back to system
  Future<void> toggleThemeMode() async {
    final currentMode = state.maybeWhen(
      data: (mode) => mode,
      orElse: () => ThemeMode.system,
    );

    late final ThemeMode newMode;
    switch (currentMode) {
      case ThemeMode.light:
        newMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        newMode = ThemeMode.system;
        break;
      case ThemeMode.system:
        newMode = ThemeMode.light;
        break;
    }

    await setThemeMode(newMode);
  }
}

/// Provider for current theme mode
@riverpod
Future<ThemeMode> themeMode(ThemeModeRef ref) async {
  return ref.watch(themeModeNotifierProvider.future);
}

/// Provider for theme mode notifier (for setting theme)
final themeModeNotifierProvider =
    StateNotifierProvider<ThemeModeNotifier, AsyncValue<ThemeMode>>(
  (ref) => ThemeModeNotifier(),
);
