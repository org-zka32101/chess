# Analytics Testing & Sandbox Setup Guide

## Phase E Phase 5: Testing & Sandbox Configuration

This guide covers setting up test environments, running analytics tests, and validating analytics implementation.

---

## Table of Contents

1. [Test Environment Setup](#test-environment-setup)
2. [Running Analytics Tests](#running-analytics-tests)
3. [Firebase Analytics Emulator](#firebase-analytics-emulator)
4. [Sandbox Configuration](#sandbox-configuration)
5. [Test Scenarios](#test-scenarios)
6. [Performance Testing](#performance-testing)
7. [Debugging Analytics](#debugging-analytics)
8. [CI/CD Integration](#cicd-integration)

---

## Test Environment Setup

### Prerequisites

```bash
# Flutter and Dart
flutter --version  # >= 3.24.0
dart --version     # >= 3.x

# Testing dependencies
flutter pub get
dart run build_runner build
```

### Environment Variables

```bash
# Create test environment file
cp .env.example .env.test

# Update with test keys
export REVENUATE_API_KEY=test_api_key_xxxx
export ANALYTICS_DEBUG_MODE=true
export FIREBASE_EMULATOR_HOST=localhost:9099
```

### Local Firebase Emulation

```bash
# Install Firebase emulators
firebase init emulators

# Start emulator suite
firebase emulators:start \
  --only analytics,firestore,database,auth

# In separate terminal, configure your app
export FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
export CLOUD_FIRESTORE_EMULATOR_HOST=localhost:8080
export FIREBASE_REALTIME_DATABASE_EMULATOR_HOST=localhost:9000
```

---

## Running Analytics Tests

### Unit Tests

```bash
# Run all analytics unit tests
flutter test test/services/analytics*.dart

# Run specific test file
flutter test test/services/analytics_revenue_service_test.dart

# Run with coverage
flutter test --coverage test/services/analytics*.dart

# Generate coverage report
lcov --list coverage/lcov.info
```

### Widget Tests

```bash
# Run analytics-related widget tests
flutter test test/widgets/premium/

# Run specific widget test
flutter test test/widgets/premium/paywall_test.dart
```

### Integration Tests

```bash
# Run integration tests on connected device
flutter drive \
  --target=integration_test/analytics_integration_test.dart

# Run on emulator
flutter emulators launch emulator_name
flutter drive \
  --target=integration_test/analytics_integration_test.dart
```

### All Tests

```bash
# Run complete test suite
flutter test

# With verbose output
flutter test -v

# With coverage
flutter test --coverage
```

---

## Firebase Analytics Emulator

### Setup

```bash
# Install Firebase CLI
curl -sL https://firebase.tools | bash

# Initialize in project root
firebase init --project=[PROJECT_ID]

# Start emulator
firebase emulators:start --only analytics
```

### Configuration in App

```dart
// During development/testing
if (kDebugMode) {
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
  // Connect to emulator
  // Firebase will output logs to console
}
```

### Verify Events in Emulator

```bash
# Check emulator logs
firebase emulators:exec 'curl http://localhost:9099/debug/events'

# Export events for analysis
firebase emulators:export ./debug_events
```

---

## Sandbox Configuration

### Test Database Schema

```dart
// firestore_test_schema.dart
class TestFirestoreSchemas {
  // Test user documents
  static const testUser = {
    'uid': 'test_user_123',
    'email': 'test@example.com',
    'subscription_tier': 'pro',
    'created_at': '2026-01-01T00:00:00Z',
  };

  // Test purchase documents
  static const testPurchase = {
    'transaction_id': 'test_txn_123',
    'product_id': 'chess.pro.monthly',
    'price': 9.99,
    'currency': 'USD',
    'timestamp': '2026-01-01T00:00:00Z',
  };
}
```

### Test Data Factory

```dart
// test/fixtures/analytics_fixtures.dart
class AnalyticsFixtures {
  static Map<String, dynamic> validPurchaseEvent() => {
    'product_id': 'test.pro.monthly',
    'subscription_tier': 'pro',
    'value': 9.99,
    'currency': 'USD',
    'transaction_id': 'test_txn_123',
  };

  static Map<String, dynamic> validGameEvent() => {
    'game_id': 'test_game_123',
    'result': 'win',
    'moves_count': 42,
    'duration_seconds': 600.0,
    'rating_change': 25,
  };

  static Map<String, dynamic> validPuzzleEvent() => {
    'puzzle_id': 'test_puzzle_123',
    'difficulty': 1500,
    'solved': true,
    'moves_used': 3,
    'optimal_moves': 2,
    'time_spent': 45.5,
  };
}
```

### Mock Services

```dart
// test/mocks/mock_analytics_services.dart
class MockAnalyticsRevenueService extends Mock
    implements AnalyticsRevenueService {}

class MockAnalyticsEngagementService extends Mock
    implements AnalyticsEngagementService {}

class MockAnalyticsFunnelService extends Mock
    implements AnalyticsFunnelService {}

class MockAnalyticsPreferences extends Mock
    implements AnalyticsPreferences {}
```

---

## Test Scenarios

### Scenario 1: Free to Pro Conversion

```dart
test('Free user upgrades to Pro subscription', () async {
  // Setup: Create free user
  // Action: Initiate purchase flow
  // Verify: All analytics events logged
  // Verify: User segment updated
  // Verify: Subscription property set
});
```

### Scenario 2: Trial to Paid Conversion

```dart
test('Trial user converts to paid subscription', () async {
  // Setup: Create trial user
  // Simulate: Trial period usage
  // Action: Trial expires, user converts
  // Verify: Conversion event logged
  // Verify: Trial lifecycle tracked
  // Verify: Revenue recorded
});
```

### Scenario 3: Churn Event

```dart
test('User cancels subscription', () async {
  // Setup: Create paid subscriber
  // Action: User initiates cancellation
  // Verify: Cancellation event logged
  // Verify: Reason captured
  // Verify: User segment updated to churned
  // Verify: Days active calculated
});
```

### Scenario 4: Engagement Tracking

```dart
test('User engagement tracked accurately', () async {
  // Setup: Create user
  // Action: Complete puzzles, play games
  // Verify: Engagement events logged
  // Verify: Engagement level calculated
  // Verify: Streak tracking works
});
```

### Scenario 5: Offline Queue

```dart
test('Events queued while offline', () async {
  // Setup: Disable network
  // Action: Track events
  // Verify: Events queued locally
  // Action: Enable network
  // Verify: Events sent automatically
});
```

---

## Performance Testing

### Event Logging Performance

```dart
test('Analytics logging performance', () async {
  final stopwatch = Stopwatch()..start();
  
  // Log 100 events
  for (int i = 0; i < 100; i++) {
    await analyticsService.trackPuzzleCompleted(
      puzzleId: 'test_$i',
      difficulty: 1500,
      solved: true,
      movesUsed: 3,
      optimalmoves: 2,
      timeSpent: 45.5,
    );
  }
  
  stopwatch.stop();
  
  // Should complete in < 5 seconds
  expect(stopwatch.elapsedMilliseconds, lessThan(5000));
});
```

### Queue Processing Performance

```dart
test('Offline queue processing performance', () async {
  final stopwatch = Stopwatch()..start();
  
  // Queue 500 events
  for (int i = 0; i < 500; i++) {
    await queueService.queueEvent('test_event', {'index': i});
  }
  
  stopwatch.stop();
  
  // Should process in < 1 second
  expect(stopwatch.elapsedMilliseconds, lessThan(1000));
});
```

### Memory Impact

```dart
test('Analytics memory footprint', () async {
  // Monitor memory before
  final memBefore = ProcessInfo.currentRss;
  
  // Initialize analytics
  await analyticsService.initialize();
  
  // Monitor after
  final memAfter = ProcessInfo.currentRss;
  final memIncrease = memAfter - memBefore;
  
  // Should not exceed 50MB
  expect(memIncrease, lessThan(50 * 1024 * 1024));
});
```

---

## Debugging Analytics

### Enable Debug Logging

```dart
// In main.dart or test setup
void setupAnalyticsDebugging() {
  AnalyticsDebugService().setDebugMode(true);
  AnalyticsDebugService().setLogAllEvents(true);
}
```

### Print Event Log

```dart
// In tests or during development
void printAnalyticsLog() {
  AnalyticsDebugService().printEventLog();
}

// Get specific events
final puzzleEvents = AnalyticsDebugService()
    .getEventsByName('puzzle_completed');
```

### Export Analytics Data

```dart
// Export to JSON for analysis
final json = AnalyticsDebugService().exportEventLogAsJson();
File('debug_events.json').writeAsStringSync(json);
```

### Simulate Events

```dart
// For testing without actual user actions
AnalyticsDebugService().simulatePurchaseEvent();
AnalyticsDebugService().simulateGameEvent();
AnalyticsDebugService().simulatePuzzleEvent();
```

---

## CI/CD Integration

### GitHub Actions Configuration

```yaml
# .github/workflows/analytics-test.yml
name: Analytics Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Run analytics tests
        run: flutter test test/services/analytics*.dart
      
      - name: Run integration tests
        run: flutter drive --target=integration_test/analytics_integration_test.dart
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running analytics tests..."
flutter test test/services/analytics*.dart

if [ $? -ne 0 ]; then
  echo "Analytics tests failed!"
  exit 1
fi
```

---

## Validation Checklist

- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Analytics events log correctly
- [ ] Offline queue works
- [ ] User preferences persist
- [ ] Firebase Analytics integration works
- [ ] RevenueCat integration works
- [ ] Events respect user consent
- [ ] Performance acceptable
- [ ] Memory footprint acceptable
- [ ] No crashes during analytics
- [ ] Debug tools functional
- [ ] CI/CD tests pass

---

## Troubleshooting

### Events Not Logging

```dart
// Check if analytics is enabled
final prefs = analyticsPreferences;
if (!prefs.analyticsEnabled) {
  print('Analytics disabled by user');
}

// Check mock mode
if (AnalyticsDebugService()._mockAnalyticsEnabled) {
  print('Mock analytics enabled - events not sent');
}
```

### Queue Not Processing

```dart
// Check connectivity
final connectivity = Connectivity();
final result = await connectivity.checkConnectivity();
if (result == ConnectivityResult.none) {
  print('No connectivity - queue will process when online');
}

// Force queue processing
await queueService.removeExpiredEvents();
```

### Firebase Emulator Issues

```bash
# Restart emulator
firebase emulators:start --only analytics

# Check logs
firebase emulators:exec 'tail -f emulator.log'

# Export and import data
firebase emulators:export ./backup
firebase emulators:start --import=./backup
```

---

## Additional Resources

- [Firebase Analytics Documentation](https://firebase.google.com/docs/analytics)
- [Flutter Testing Guide](https://flutter.dev/docs/testing)
- [RevenueCat Testing](https://docs.revenuecat.com/docs/testing)
- [Hive Database](https://docs.hivedb.dev/)

---

**Last Updated**: 2026-09-02
**Phase**: E Phase 5 (Testing & Sandbox)
**Status**: ✅ Complete
