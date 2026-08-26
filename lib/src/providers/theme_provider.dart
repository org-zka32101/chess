import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess/src/theme/chess_theme.dart';

/// Theme mode enum
enum ThemeMode { light, dark, system }

/// Theme notifier for managing light/dark mode
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  /// Set theme to light mode
  void setLightMode() {
    state = ThemeMode.light;
  }

  /// Set theme to dark mode
  void setDarkMode() {
    state = ThemeMode.dark;
  }

  /// Set theme to system mode (follows device settings)
  void setSystemMode() {
    state = ThemeMode.system;
  }

  /// Toggle between light and dark mode
  void toggleTheme() {
    if (state == ThemeMode.light) {
      setDarkMode();
    } else if (state == ThemeMode.dark) {
      setLightMode();
    } else {
      // In system mode, toggle to light
      setLightMode();
    }
  }

  /// Get MaterialThemeData for current theme mode
  ThemeData getThemeData({required bool isDarkSystem}) {
    switch (state) {
      case ThemeMode.light:
        return ChessTheme.getLightTheme();
      case ThemeMode.dark:
        return ChessTheme.getDarkTheme();
      case ThemeMode.system:
        return isDarkSystem
            ? ChessTheme.getDarkTheme()
            : ChessTheme.getLightTheme();
    }
  }

  /// Check if current theme is dark
  bool isDarkMode({required bool isDarkSystem}) {
    switch (state) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return isDarkSystem;
    }
  }
}

/// Riverpod provider for theme mode
final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// Provider for whether system is using dark mode
final systemDarkModeProvider = StateNotifierProvider<SystemDarkModeNotifier, bool>((ref) {
  return SystemDarkModeNotifier();
});

/// Notifier for system dark mode
class SystemDarkModeNotifier extends StateNotifier<bool> {
  SystemDarkModeNotifier() : super(false);

  /// Update system dark mode based on MediaQuery
  void updateFromMediaQuery(MediaQueryData mediaQuery) {
    final brightness = mediaQuery.platformBrightness;
    state = brightness == Brightness.dark;
  }
}

/// Provider to get the actual theme data based on theme mode and system setting
final themeDataProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  final isDarkSystem = ref.watch(systemDarkModeProvider);

  return switch (themeMode) {
    ThemeMode.light => ChessTheme.getLightTheme(),
    ThemeMode.dark => ChessTheme.getDarkTheme(),
    ThemeMode.system => isDarkSystem
        ? ChessTheme.getDarkTheme()
        : ChessTheme.getLightTheme(),
  };
});

/// Provider to check if current theme is dark
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  final isDarkSystem = ref.watch(systemDarkModeProvider);

  return switch (themeMode) {
    ThemeMode.light => false,
    ThemeMode.dark => true,
    ThemeMode.system => isDarkSystem,
  };
});
