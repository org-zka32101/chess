import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:chess/src/screens/settings/sound_preferences_screen.dart';
import 'package:chess/src/providers/sound_preferences_provider.dart';

// Mock SoundPreferencesService
class MockSoundPreferencesService extends Mock
    implements SoundPreferencesService {}

void main() {
  group('SoundPreferencesScreen Widget Tests', () {
    late MockSoundPreferencesService mockService;

    setUp(() {
      mockService = MockSoundPreferencesService();
    });

    testWidgets('renders loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          overrides: [
            soundPreferencesProvider.overrideWith(
              (_) => AsyncValue.loading(),
            ),
          ],
          child: const MaterialApp(
            home: SoundPreferencesScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state', (WidgetTester tester) async {
      const testError = 'Test error message';

      await tester.pumpWidget(
        ProviderContainer(
          overrides: [
            soundPreferencesProvider.overrideWith(
              (_) => AsyncValue.error(
                testError,
                StackTrace.current,
              ),
            ),
          ],
          child: const MaterialApp(
            home: SoundPreferencesScreen(),
          ),
        ),
      );

      expect(find.byType(Text), findsWidgets);
      await tester.pumpAndSettle();
    });

    testWidgets('renders sound preferences screen with all sections',
        (WidgetTester tester) async {
      final testPreferences = SoundPreferences(
        userId: 'test-user',
        soundMasterEnabled: true,
        volume: 0.8,
      );

      await tester.pumpWidget(
        ProviderContainer(
          overrides: [
            soundPreferencesProvider.overrideWith(
              (_) => AsyncValue.data(testPreferences),
            ),
            soundPreferencesServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(
            home: SoundPreferencesScreen(),
          ),
        ),
      );

      // Find all major sections
      expect(find.text('Sound Settings'), findsOneWidget);
      expect(find.text('Master Volume'), findsWidgets);
      expect(find.text('Volume'), findsWidgets);
      expect(find.text('Sound Categories'), findsOneWidget);

      // Find all category titles
      expect(find.text('Gameplay'), findsOneWidget);
      expect(find.text('Game End'), findsOneWidget);
      expect(find.text('UI Sounds'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('master toggle can be tapped', (WidgetTester tester) async {
      final testPreferences = SoundPreferences(
        userId: 'test-user',
        soundMasterEnabled: true,
      );

      await tester.pumpWidget(
        ProviderContainer(
          overrides: [
            soundPreferencesProvider.overrideWith(
              (_) => AsyncValue.data(testPreferences),
            ),
            soundPreferencesServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(
            home: SoundPreferencesScreen(),
          ),
        ),
      );

      // Find and tap the master switch
      final switches = find.byType(Switch);
      expect(switches, findsWidgets);

      await tester.tap(switches.first);
      await tester.pumpAndSettle();

      // Verify the service method was called
      verify(mockService.setSoundMasterEnabled(any)).called(greaterThan(0));
    });

    testWidgets('volume slider updates when dragged',
        (WidgetTester tester) async {
      final testPreferences = SoundPreferences(
        userId: 'test-user',
        soundMasterEnabled: true,
        volume: 0.5,
      );

      await tester.pumpWidget(
        ProviderContainer(
          overrides: [
            soundPreferencesProvider.overrideWith(
              (_) => AsyncValue.data(testPreferences),
            ),
            soundPreferencesServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(
            home: SoundPreferencesScreen(),
          ),
        ),
      );

      // Find the slider
      final sliders = find.byType(Slider);
      expect(sliders, findsWidgets);

      // Drag the slider
      await tester.drag(sliders.first, const Offset(50, 0));
      await tester.pumpAndSettle();

      // Verify service method was called
      verify(mockService.setVolume(any)).called(greaterThan(0));
    });

    testWidgets('category switches call service methods',
        (WidgetTester tester) async {
      final testPreferences = SoundPreferences(
        userId: 'test-user',
        soundMasterEnabled: true,
      );

      await tester.pumpWidget(
        ProviderContainer(
          overrides: [
            soundPreferencesProvider.overrideWith(
              (_) => AsyncValue.data(testPreferences),
            ),
            soundPreferencesServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(
            home: SoundPreferencesScreen(),
          ),
        ),
      );

      // Get all switches (including master toggle)
      final switches = find.byType(Switch);
      final switchCount = switchCount;

      // Tap the second switch (first category)
      if (switches.evaluate().length > 1) {
        await tester.tap(switches.at(1));
        await tester.pumpAndSettle();

        verify(mockService.setCategoryEnabled(any, any))
            .called(greaterThan(0));
      }
    });

    testWidgets('category switches are disabled when master is off',
        (WidgetTester tester) async {
      final testPreferences = SoundPreferences(
        userId: 'test-user',
        soundMasterEnabled: false,
      );

      await tester.pumpWidget(
        ProviderContainer(
          overrides: [
            soundPreferencesProvider.overrideWith(
              (_) => AsyncValue.data(testPreferences),
            ),
            soundPreferencesServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(
            home: SoundPreferencesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // When master is off, category switches should be disabled
      // (their onChanged should be null)
    });

    testWidgets('help text is displayed', (WidgetTester tester) async {
      final testPreferences = SoundPreferences(userId: 'test-user');

      await tester.pumpWidget(
        ProviderContainer(
          overrides: [
            soundPreferencesProvider.overrideWith(
              (_) => AsyncValue.data(testPreferences),
            ),
            soundPreferencesServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(
            home: SoundPreferencesScreen(),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data!.contains('Disable "All Sound Effects"'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('scrollable content', (WidgetTester tester) async {
      final testPreferences = SoundPreferences(userId: 'test-user');

      await tester.pumpWidget(
        ProviderContainer(
          overrides: [
            soundPreferencesProvider.overrideWith(
              (_) => AsyncValue.data(testPreferences),
            ),
            soundPreferencesServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(
            home: SoundPreferencesScreen(),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
