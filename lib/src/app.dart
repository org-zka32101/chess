import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/auth/auth_wrapper.dart';
import 'theme/chess_theme.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';

class ChessTacticsMasterApp extends ConsumerWidget {
  const ChessTacticsMasterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme mode and system dark mode settings
    final themeMode = ref.watch(themeModeProvider);
    final isDarkSystem = ref.watch(systemDarkModeProvider);

    // Determine if the app should use dark theme
    bool isDarkMode;
    switch (themeMode) {
      case ThemeMode.light:
        isDarkMode = false;
        break;
      case ThemeMode.dark:
        isDarkMode = true;
        break;
      case ThemeMode.system:
        isDarkMode = isDarkSystem;
        break;
    }

    // Get the appropriate theme
    final lightTheme = ChessTheme.getLightTheme();
    final darkTheme = ChessTheme.getDarkTheme();

    return MaterialApp(
      title: 'Chess Tactics Master',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Update system dark mode setting based on MediaQuery
        ref.read(systemDarkModeProvider.notifier).updateFromMediaQuery(
          MediaQuery.of(context),
        );
        return child ?? const SizedBox();
      },
    );
  }
}
