# QA Phase 2: Widget Testing & Edge Case Coverage

**Date**: 2026-09-04  
**Status**: Implementation Phase  
**Estimated Time**: 10-12 hours  
**Priority**: High

---

## Executive Summary

Comprehensive widget testing and edge case coverage for all major screens and components:

- **Widget Tests**: 50+ tests for critical UI components
- **Edge Cases**: Null handling, empty states, error boundaries
- **Integration Tests**: Multi-screen workflows and state synchronization
- **Test Infrastructure**: Mocks, fixtures, helpers, performance profiling
- **Coverage Target**: 70%+ widget, 50%+ integration

---

## Part 1: Widget Test Infrastructure

### Test Helpers & Utilities

**File**: `test/helpers/widget_test_helpers.dart`

```dart
/// Custom finder for chess-specific widgets
class ChessWidgetFinders {
  static Finder findChessBoardWidget() => 
    find.byType(ChessBoard);
  
  static Finder findGameStatusBadge(String status) =>
    find.byWidgetPredicate((widget) =>
      widget is GameStatusBadge && widget.status == status
    );
  
  static Finder findRatingChange(int ratingDelta) =>
    find.byWidgetPredicate((widget) =>
      widget is RatingChangeWidget && widget.delta == ratingDelta
    );
}

/// Widget test pump with sensible defaults
extension WidgetTesterX on WidgetTester {
  /// Pump and settle with timeout
  Future<void> pumpAndSettle({Duration? timeout}) =>
    super.pumpAndSettle(timeout ?? Duration(seconds: 2));
  
  /// Type text into a TextField
  Future<void> typeText(String text) =>
    super.enterText(find.byType(TextField), text);
  
  /// Tap a button by text
  Future<void> tapButtonWithText(String text) async {
    await tap(find.text(text));
    await pump();
  }
}

/// Mock data generators
class MockDataGenerator {
  static OnlineGame mockGame({
    String? id,
    String status = 'active',
  }) => OnlineGame(
    id: id ?? 'game_${DateTime.now().millisecondsSinceEpoch}',
    whitePlayerId: 'white_${Random().nextInt(1000)}',
    blackPlayerId: 'black_${Random().nextInt(1000)}',
    status: status,
    pgn: 'e4 c5 Nf3',
    createdAt: DateTime.now(),
  );
  
  static User mockUser({
    String? uid,
    String? email,
    int rating = 1600,
  }) => User(
    uid: uid ?? 'user_${Random().nextInt(10000)}',
    email: email ?? 'user${Random().nextInt(1000)}@example.com',
    displayName: 'Test Player',
    rating: rating,
    createdAt: DateTime.now(),
  );
}
```

### Mock Services

**File**: `test/mocks/mock_services.dart`

```dart
/// Mock Firebase Auth Service
class MockFirebaseAuthService extends Mock implements FirebaseAuthService {
  @override
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    return null; // Or return mock credential
  }
  
  @override
  Stream<User?> authStateChanges() => Stream.value(null);
}

/// Mock Firestore Service
class MockFirestoreService extends Mock implements FirebaseService {
  final Map<String, dynamic> _mockData = {};
  
  @override
  Future<DocumentSnapshot> getDocument(String path) async {
    return MockDocumentSnapshot(_mockData[path] ?? {});
  }
  
  @override
  Future<void> setDocument(String path, Map<String, dynamic> data) async {
    _mockData[path] = data;
  }
}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {
  final Map<String, dynamic> _data;
  
  MockDocumentSnapshot(this._data);
  
  @override
  dynamic noSuchMethod(Invocation invocation) => _data[invocation.memberName];
}

/// Mock Game Service
class MockOnlineGameService extends Mock implements OnlineGameService {
  List<OnlineGame> _games = [];
  
  @override
  Future<List<OnlineGame>> getPlayerActiveGames(String playerId) async {
    return _games.where((g) => g.status == 'active').toList();
  }
  
  @override
  Future<void> makeMove(String gameId, String move) async {
    // Simulate move
  }
}
```

### Test Fixtures

**File**: `test/fixtures/test_fixtures.dart`

```dart
/// Complete test app wrapper
Widget createTestApp({
  required Widget child,
  Map<String, String>? overrides,
}) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
    theme: ThemeData(useMaterial3: true),
  );
}

/// Provider override helper
List<Override> getProviderOverrides({
  MockFirebaseAuthService? authService,
  MockOnlineGameService? gameService,
}) => [
  if (authService != null)
    firebaseAuthServiceProvider.overrideWithValue(authService),
  if (gameService != null)
    onlineGameServiceProvider.overrideWithValue(gameService),
];

/// Test scenario builder
class TestScenario {
  final String name;
  final List<OnlineGame> games;
  final User? currentUser;
  final Map<String, dynamic> errors;
  
  TestScenario({
    required this.name,
    this.games = const [],
    this.currentUser,
    this.errors = const {},
  });
  
  static TestScenario activeGame() => TestScenario(
    name: 'Active Game',
    games: [MockDataGenerator.mockGame(status: 'active')],
    currentUser: MockDataGenerator.mockUser(),
  );
  
  static TestScenario multipleGames() => TestScenario(
    name: 'Multiple Active Games',
    games: [
      MockDataGenerator.mockGame(status: 'active'),
      MockDataGenerator.mockGame(status: 'active'),
      MockDataGenerator.mockGame(status: 'active'),
    ],
    currentUser: MockDataGenerator.mockUser(),
  );
  
  static TestScenario noGames() => TestScenario(
    name: 'No Active Games',
    games: [],
    currentUser: MockDataGenerator.mockUser(),
  );
  
  static TestScenario networkError() => TestScenario(
    name: 'Network Error',
    errors: {'network': 'Connection timeout'},
  );
}
```

---

## Part 2: Widget Test Cases

### Home Screen Tests (15+ tests)

**File**: `test/screens/home/home_screen_test.dart`

```dart
void main() {
  group('HomeScreen Widget Tests', () {
    late MockOnlineGameService mockGameService;
    
    setUp(() {
      mockGameService = MockOnlineGameService();
    });
    
    testWidgets('displays welcome message when no games',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: HomeScreen(),
          overrides: [mockGameService],
        ),
      );
      
      expect(find.text('Welcome to Chess Tactics'), findsOneWidget);
      expect(find.text('No active games'), findsOneWidget);
    });
    
    testWidgets('displays active game cards',
        (WidgetTester tester) async {
      mockGameService._games = [
        MockDataGenerator.mockGame(status: 'active'),
        MockDataGenerator.mockGame(status: 'active'),
      ];
      
      await tester.pumpWidget(
        createTestApp(
          child: HomeScreen(),
          overrides: [mockGameService],
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(GameCard), findsWidgets);
      expect(find.byType(GameCard), findsNWidgets(2));
    });
    
    testWidgets('navigates to game on tap',
        (WidgetTester tester) async {
      // Test navigation when game card is tapped
    });
    
    testWidgets('displays error message on load failure',
        (WidgetTester tester) async {
      // Test error state display
    });
    
    testWidgets('shows loading indicator while fetching',
        (WidgetTester tester) async {
      // Test loading state
    });
  });
}
```

### Game Screen Tests (20+ tests)

**File**: `test/screens/game/online_game_screen_test.dart`

```dart
void main() {
  group('OnlineGameScreen Widget Tests', () {
    testWidgets('displays chess board', (WidgetTester tester) async {
      // Test board rendering
    });
    
    testWidgets('allows valid moves', (WidgetTester tester) async {
      // Test move validation and UI update
    });
    
    testWidgets('prevents invalid moves', (WidgetTester tester) async {
      // Test invalid move rejection
    });
    
    testWidgets('displays opponent info', (WidgetTester tester) async {
      // Test opponent widget display
    });
    
    testWidgets('shows game timer', (WidgetTester tester) async {
      // Test timer widget
    });
    
    testWidgets('handles timeout', (WidgetTester tester) async {
      // Test timeout behavior
    });
  });
}
```

### Profile Screen Tests (15+ tests)

**File**: `test/screens/profile/profile_screen_test.dart`

```dart
void main() {
  group('ProfileScreen Widget Tests', () {
    testWidgets('displays user avatar', (WidgetTester tester) async {
      // Test avatar image display
    });
    
    testWidgets('displays user stats', (WidgetTester tester) async {
      // Test rating, win rate, total games
    });
    
    testWidgets('displays recent games', (WidgetTester tester) async {
      // Test game list
    });
    
    testWidgets('allows profile editing', (WidgetTester tester) async {
      // Test edit profile flow
    });
  });
}
```

---

## Part 3: Edge Case & Error Handling Tests

### Null Safety Tests

**File**: `test/edge_cases/null_safety_test.dart`

```dart
void main() {
  group('Null Safety Edge Cases', () {
    testWidgets('handles null user gracefully',
        (WidgetTester tester) async {
      // Should display login prompt or empty state
    });
    
    testWidgets('handles empty game list',
        (WidgetTester tester) async {
      // Should show "no games" message
    });
    
    testWidgets('handles null opponent data',
        (WidgetTester tester) async {
      // Should display "Unknown Opponent"
    });
    
    testWidgets('handles null rating',
        (WidgetTester tester) async {
      // Should display "--" or "Unrated"
    });
  });
}
```

### Error Boundary Tests

**File**: `test/edge_cases/error_boundary_test.dart`

```dart
void main() {
  group('Error Boundary Tests', () {
    testWidgets('catches widget build errors',
        (WidgetTester tester) async {
      // Test error recovery
    });
    
    testWidgets('displays error snackbar on operation failure',
        (WidgetTester tester) async {
      // Test error message display
    });
    
    testWidgets('allows retry after error',
        (WidgetTester tester) async {
      // Test retry functionality
    });
    
    testWidgets('handles malformed data gracefully',
        (WidgetTester tester) async {
      // Test data parsing errors
    });
  });
}
```

### State Management Edge Cases

**File**: `test/edge_cases/state_management_test.dart`

```dart
void main() {
  group('State Management Edge Cases', () {
    testWidgets('handles rapid state updates',
        (WidgetTester tester) async {
      // Test debouncing and throttling
    });
    
    testWidgets('syncs state across screens',
        (WidgetTester tester) async {
      // Test provider invalidation
    });
    
    testWidgets('cleans up state on unmount',
        (WidgetTester tester) async {
      // Test listener cleanup
    });
  });
}
```

---

## Part 4: Integration Tests

### Multi-Screen Workflows

**File**: `integration_test/chess_game_flow_test.dart`

```dart
void main() {
  group('Chess Game Integration Tests', () {
    testWidgets('Complete game flow: create → play → end',
        (WidgetTester tester) async {
      // 1. Start at home screen
      // 2. Tap "Find Match"
      // 3. Wait for opponent
      // 4. Play several moves
      // 5. End game
      // 6. Verify results displayed
    });
    
    testWidgets('Game disconnection recovery',
        (WidgetTester tester) async {
      // Test reconnection and state sync
    });
    
    testWidgets('Profile update flow',
        (WidgetTester tester) async {
      // Navigate to profile → edit → save → verify
    });
  });
}
```

---

## Part 5: Performance & Accessibility Tests

### Performance Tests

**File**: `test/performance/widget_performance_test.dart`

```dart
void main() {
  group('Widget Performance Tests', () {
    testWidgets('game list renders 100 items in < 2s',
        (WidgetTester tester) async {
      // Generate 100 mock games
      // Measure render time
      // Assert < 2000ms
    });
    
    testWidgets('chess board move animation smooth',
        (WidgetTester tester) async {
      // Test animation performance
    });
  });
}
```

### Accessibility Tests

**File**: `test/accessibility/semantic_test.dart`

```dart
void main() {
  group('Accessibility Tests', () {
    testWidgets('all buttons have semantic labels',
        (WidgetTester tester) async {
      // Verify Semantics are present
    });
    
    testWidgets('text contrast meets WCAG standards',
        (WidgetTester tester) async {
      // Verify color contrast
    });
  });
}
```

---

## Test Coverage Targets

| Component | Target | Current | Status |
|-----------|--------|---------|--------|
| Home Screen | 80% | 0% | 🔴 |
| Game Screen | 85% | 0% | 🔴 |
| Profile Screen | 75% | 0% | 🔴 |
| Providers | 70% | 40% | 🟡 |
| Services | 80% | 50% | 🟡 |
| **Overall** | **70%** | **45%** | 🟡 |

---

## Implementation Checklist

### Phase 1: Test Infrastructure (2 hours)
- [ ] Create widget test helpers
- [ ] Create mock services and fixtures
- [ ] Set up test data generators
- [ ] Create custom finders

### Phase 2: Widget Tests (5 hours)
- [ ] Home screen tests (15+)
- [ ] Game screen tests (20+)
- [ ] Profile screen tests (15+)
- [ ] Settings screen tests (10+)

### Phase 3: Edge Cases (2 hours)
- [ ] Null safety tests
- [ ] Error boundary tests
- [ ] State management edge cases
- [ ] Data validation tests

### Phase 4: Integration Tests (2 hours)
- [ ] Multi-screen workflows
- [ ] State synchronization
- [ ] Error recovery flows
- [ ] Real Firebase scenarios

### Phase 5: Validation (1 hour)
- [ ] Run full test suite
- [ ] Generate coverage report
- [ ] Document test results
- [ ] Create test guidelines

---

## Test Execution

```bash
# Run all widget tests
flutter test test/

# Run with coverage
flutter test --coverage

# Generate coverage report
lcov --summary coverage/lcov.info

# Run specific test file
flutter test test/screens/home/home_screen_test.dart

# Watch mode (re-run on changes)
flutter test --watch
```

---

## Success Criteria

✅ 50+ widget tests passing  
✅ 70%+ widget coverage  
✅ 50%+ integration coverage  
✅ All edge cases handled  
✅ No unhandled exceptions in tests  
✅ Performance benchmarks met  
✅ Accessibility guidelines followed

---

**Next Phase**: Testing Framework (comprehensive test utilities and CI/CD integration)
