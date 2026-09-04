# Testing Framework - Phase 3

**Date**: 2026-09-04  
**Status**: Documentation & Planning  
**Scope**: CI/CD Integration, Performance Profiling, Test Utilities  
**Duration**: 4-week sprint

---

## Phase 3 Roadmap

### Week 1: CI/CD Integration
- [ ] GitHub Actions workflow setup
- [ ] Test automation on PR/commit
- [ ] Coverage reporting (Codecov)
- [ ] Lint and format checks
- [ ] Security scanning

### Week 2: Performance Profiling
- [ ] Benchmark suite setup
- [ ] Memory profiling
- [ ] Build time optimization
- [ ] App size analysis
- [ ] Performance regression detection

### Week 3: Test Utilities & Helpers
- [ ] Golden file testing
- [ ] Custom matchers
- [ ] Test data factories
- [ ] Fixture management
- [ ] Test isolation utilities

### Week 4: Documentation & Validation
- [ ] Test guidelines documentation
- [ ] CI/CD troubleshooting guide
- [ ] Coverage analysis
- [ ] Test metrics dashboard
- [ ] Team onboarding guide

---

## CI/CD Integration Strategy

### GitHub Actions Workflows

#### 1. Test Workflow (`on push, pull_request`)
```yaml
name: Flutter Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
```

#### 2. Build Workflow (iOS/Android)
```yaml
name: Build Apps
on: [push]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build ios --release
      - run: flutter build apk --release
```

#### 3. Security Workflow
```yaml
name: Security Scan
on: [push]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: osv-scanner@v1
      - uses: dart-lang/setup-dart@v1
      - run: dart run lints
```

---

## Performance Profiling Framework

### Benchmark Structure

```dart
// benchmark/performance_benchmarks.dart

class PerformanceBenchmark {
  final String name;
  final Future<void> Function() test;
  Duration? maxDuration;
  
  PerformanceBenchmark({
    required this.name,
    required this.test,
    this.maxDuration,
  });
  
  Future<BenchmarkResult> run() async {
    final sw = Stopwatch()..start();
    try {
      await test();
      sw.stop();
      return BenchmarkResult(
        name: name,
        duration: sw.elapsed,
        passed: maxDuration == null || sw.elapsed < maxDuration!,
      );
    } catch (e) {
      return BenchmarkResult(
        name: name,
        duration: Duration.zero,
        passed: false,
        error: e.toString(),
      );
    }
  }
}

class BenchmarkResult {
  final String name;
  final Duration duration;
  final bool passed;
  final String? error;
  
  BenchmarkResult({
    required this.name,
    required this.duration,
    required this.passed,
    this.error,
  });
  
  @override
  String toString() =>
      '$name: ${duration.inMilliseconds}ms ${passed ? "✓" : "✗"}';
}
```

### Coverage Reporting

```bash
# Generate coverage
flutter test --coverage

# View coverage
lcov --summary coverage/lcov.info

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Memory Profiling

```dart
// test/performance/memory_profiling_test.dart

testWidgets('memory usage stays under 100MB', (tester) async {
  final startMemory = ProcessInfo.currentRss;
  
  // Perform operations
  await tester.pumpWidget(testApp);
  await tester.pumpAndSettle();
  
  final endMemory = ProcessInfo.currentRss;
  final usedMemory = (endMemory - startMemory) / 1024 / 1024; // MB
  
  expect(usedMemory, lessThan(100));
});
```

---

## Test Utilities Implementation

### Custom Test Matchers

```dart
// test/matchers/custom_matchers.dart

Matcher isValidEmail() => _IsValidEmail();
Matcher isValidRating() => _IsValidRating();
Matcher isValidGameStatus() => _IsValidGameStatus();

class _IsValidEmail extends Matcher {
  @override
  bool matches(Object? item, Map matchState) {
    if (item is! String) return false;
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(item);
  }
  
  @override
  Description describe(Description description) =>
      description.add('valid email address');
}

class _IsValidRating extends Matcher {
  @override
  bool matches(Object? item, Map matchState) {
    if (item is! int) return false;
    return item >= 400 && item <= 3000;
  }
  
  @override
  Description describe(Description description) =>
      description.add('valid rating (400-3000)');
}

class _IsValidGameStatus extends Matcher {
  @override
  bool matches(Object? item, Map matchState) {
    const validStatuses = ['active', 'completed', 'aborted'];
    return validStatuses.contains(item);
  }
  
  @override
  Description describe(Description description) =>
      description.add('valid game status');
}
```

### Test Factories

```dart
// test/factories/game_factory.dart

class GameFactory {
  static int _counter = 0;
  
  static OnlineGame create({
    String? id,
    String status = 'active',
    int whiteRating = 1600,
    int blackRating = 1650,
  }) {
    _counter++;
    return OnlineGame(
      id: id ?? 'game_$_counter',
      whitePlayerId: 'white_$_counter',
      whitePlayerName: 'White Player $_counter',
      whiteRating: whiteRating,
      blackPlayerId: 'black_$_counter',
      blackPlayerName: 'Black Player $_counter',
      blackRating: blackRating,
      status: status,
      pgn: 'e4 c5 Nf3',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      timeControl: '5+3',
    );
  }
  
  static List<OnlineGame> createBatch(int count) {
    return List.generate(count, (_) => create());
  }
  
  static void reset() => _counter = 0;
}
```

### Golden File Testing

```dart
// test/golden/golden_test.dart

void main() {
  group('Golden File Tests', () {
    testWidgets('HomeScreen renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(child: HomeScreen()));
      
      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('home_screen.png'),
      );
    });
  });
}
```

---

## Test Metrics & Reporting

### Metrics to Track
- **Coverage**: Line, branch, and method coverage %
- **Performance**: Test execution time, memory usage
- **Stability**: Flaky test detection, success rate
- **Size**: App size, build time

### Metrics Dashboard
```
Test Results Summary
├── Total Tests: 250+
├── Passing: 250 (100%)
├── Flaky: 0
├── Duration: 2m 15s
├── Coverage: 75%
└── Last Run: 2 minutes ago
```

---

## Continuous Integration Checklist

- [ ] Tests run on every PR
- [ ] Coverage > 70%
- [ ] No flaky tests
- [ ] Build succeeds (iOS + Android)
- [ ] Security scan passes
- [ ] Lint passes
- [ ] Format check passes

---

## Test Execution Timeline

**Phase 1** (Week 1): CI/CD setup → Automated testing on every PR  
**Phase 2** (Week 2): Performance framework → Benchmarking in CI  
**Phase 3** (Week 3): Test utilities → Reusable patterns  
**Phase 4** (Week 4): Documentation → Team readiness  

---

## Success Criteria

✅ Automated tests run on all PRs  
✅ 70%+ code coverage maintained  
✅ Build artifacts generated automatically  
✅ Performance regressions detected  
✅ Zero flaky test tolerance  
✅ Team onboarding complete

---

## Next Actions

1. **Immediate** (Today)
   - Set up GitHub Actions workflows
   - Configure Codecov integration
   - Create performance benchmark suite

2. **This Week**
   - Integrate lint/format checks
   - Add security scanning
   - Build test metrics dashboard

3. **This Month**
   - Extend to all screens
   - Performance profiling
   - Team documentation

---

**All three work streams (Performance Optimization, QA Phase 2, Testing Framework) are now documented and ready for implementation.**
