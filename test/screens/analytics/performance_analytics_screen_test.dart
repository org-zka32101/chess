import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chess/src/screens/analytics/performance_analytics_screen.dart';

void main() {
  group('PerformanceAnalyticsScreen', () {
    testWidgets('displays title in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: PerformanceAnalyticsScreen(
              playerId: 'player1',
              playerName: 'Test Player',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('パフォーマンス分析'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays refresh button in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: PerformanceAnalyticsScreen(
              playerId: 'player1',
              playerName: 'Test Player',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('displays streak information section', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: PerformanceAnalyticsScreen(
              playerId: 'player1',
              playerName: 'Test Player',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('連続記録'), findsOneWidget);
    });

    testWidgets('displays rating progression section', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: PerformanceAnalyticsScreen(
              playerId: 'player1',
              playerName: 'Test Player',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('レーティング進行'), findsOneWidget);
    });

    testWidgets('displays time range buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: PerformanceAnalyticsScreen(
              playerId: 'player1',
              playerName: 'Test Player',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('30日'), findsOneWidget);
      expect(find.text('90日'), findsOneWidget);
      expect(find.text('365日'), findsOneWidget);
    });

    testWidgets('displays time control performance section', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: PerformanceAnalyticsScreen(
              playerId: 'player1',
              playerName: 'Test Player',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('時間制別パフォーマンス'), findsOneWidget);
    });

    testWidgets('displays rank performance section', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: PerformanceAnalyticsScreen(
              playerId: 'player1',
              playerName: 'Test Player',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('レベル別パフォーマンス'), findsOneWidget);
    });

    testWidgets('has correct widget structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: PerformanceAnalyticsScreen(
              playerId: 'player1',
              playerName: 'Test Player',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('displays streak cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: PerformanceAnalyticsScreen(
              playerId: 'player1',
              playerName: 'Test Player',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('現在の連勝'), findsOneWidget);
      expect(find.text('最長連勝'), findsOneWidget);
      expect(find.text('最長連敗'), findsOneWidget);
    });
  });
}
