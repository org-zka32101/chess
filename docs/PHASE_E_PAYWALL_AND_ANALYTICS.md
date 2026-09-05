# Phase E: Paywall & Analytics Implementation Guide

## Overview
Phase E implements a complete monetization and analytics system for Chess Tactics Master using RevenueCat for subscriptions and Firebase Analytics for event tracking.

## Paywall System

### PaywallService (`lib/src/services/paywall_service.dart`)

**Subscription Models:**
```dart
enum SubscriptionType { free, premium, premiumPlus }
enum SubscriptionPeriod { monthly, yearly, lifetime }
enum SubscriptionStatus { active, cancelled, expired, paused, pendingRenewal }
```

**Pricing:**
- Free: $0.00
- Premium: $4.99/month, $49.90/year (17% discount), $99.99 lifetime
- Premium Plus: $9.99/month, $99.90/year (17% discount), $199.99 lifetime

**Core Methods:**
```dart
// Initialize and fetch subscription
Future<void> initialize()
Future<Subscription?> fetchSubscription()

// Purchase and management
Future<bool> purchaseSubscription(type, period)
Future<bool> restorePurchases()
Future<bool> cancelSubscription()

// Feature access
bool isFeatureAvailable(String featureId)
List<PremiumFeature> getFeaturesForTier(SubscriptionType)

// Listeners and reporting
void addSubscriptionListener(Function callback)
String generateSubscriptionReport()
```

### Premium Features

**Premium Tier ($4.99/month):**
1. **Unlimited Puzzles** - Access to unlimited daily puzzle content
2. **Online Multiplayer** - Play against opponents in real-time
3. **Advanced Analytics** - Detailed game statistics and performance analysis
4. **Ad-Free Experience** - No advertisements while playing

**Premium Plus Tier ($9.99/month):**
- All Premium features, plus:
5. **Exclusive Content** - Premium puzzles and game modes
6. **AI Chess Coach** - Personal AI coach for improvement recommendations
7. **Early Access** - Access new features before general release

### Feature Gating

Access control is managed through `isFeatureAvailable(featureId)`:
```dart
if (paywall.isFeatureAvailable('unlimited_puzzles')) {
  // Show premium puzzle content
}
```

### RevenueCat Integration (Production)

**Setup Required:**
1. Get RevenueCat Public SDK Key from dashboard.revenuecat.com
2. Configure in `.env`:
   ```
   REVENUEAT_API_KEY=your_public_sdk_key
   ```
3. Uncomment production code in `PaywallService.initialize()`:
   ```dart
   await Purchases.setup("your_key");
   // Fetch actual subscription from RevenueCat
   ```

**Supported Platforms:**
- iOS (App Store)
- Android (Google Play)
- Web (web subscriptions via StoreKit)

## Analytics System

### AnalyticsService (`lib/src/services/analytics_service.dart`)

**Core Tracking:**
- Screen views and navigation
- Custom event logging
- Game completion metrics
- Puzzle solving analytics
- User engagement tracking

**Event Methods:**
```dart
// Core logging
Future<void> logEvent(String name, {Map<String, Object>? parameters})
Future<void> logScreenView(String screenName, String screenClass)

// Game events
Future<void> logGameCompleted({
  gameId, gameType, duration, won, moveCount,
  ratingBefore, ratingAfter, result
})

// Puzzle events
Future<void> logPuzzleSolved({puzzleId, difficulty, timeSpent})

// User events
Future<void> logPuzzleSelected(puzzleId, difficulty)
Future<void> logUserPreferenceChanged(settingName, value)
```

### Analytics Providers (State Management)

**Core Providers:**
- `analyticsServiceProvider` - Singleton service access
- `analyticsEventProvider` - Event tracking
- `performanceAnalyticsProvider` - Performance metrics
- `analyticsEngagementProvider` - User engagement tracking

**Data Collection:**
- Screen views (automatically tracked)
- Game metrics (win rate, duration, rating changes)
- Puzzle metrics (completion rate, difficulty distribution)
- Engagement metrics (session duration, feature usage)
- Revenue metrics (via revenue_tracking_service)

### Analytics Dimensions (Firebase)

**Custom Dimensions:**
- `subscription_type` - Free, Premium, Premium+
- `game_type` - CPU, Online, Puzzle
- `game_difficulty` - Beginner, Intermediate, Advanced, Expert
- `user_tier` - Based on rating progression
- `session_duration` - Total time in app

**Standard Events:**
- `game_completed` - Game finished with outcome
- `puzzle_solved` - Puzzle successfully completed
- `screen_view` - App navigation tracking
- `purchase` - Subscription purchase (automatic via Firebase)
- `first_open` - New user first app launch
- `app_exception` - Error tracking via Crashlytics

### Revenue Tracking (`lib/src/services/revenue_tracking_service.dart`)

**Metrics:**
- Subscription revenue (MRR, ARR)
- ARPU (Average Revenue Per User)
- Churn rate tracking
- LTV (Lifetime Value) calculation
- Refund tracking

**Methods:**
```dart
Future<void> trackSubscriptionPurchase(subscription)
Future<void> trackSubscriptionCancellation(subscription)
Future<double> calculateMonthlyRecurringRevenue()
Future<double> calculateAnnualRecurringRevenue()
Future<double> calculateARPU()
Future<double> calculateLTV()
```

### Analytics Debug Service (`lib/src/services/analytics_debug_service.dart`)

Development tools for testing analytics:
```dart
// Simulate events in development
Future<void> simulateGameCompletion()
Future<void> simulatePuzzleCompletion()
Future<void> simulateSubscriptionPurchase()

// Debug output
void printAnalyticsQueue()
void exportAnalyticsData()
```

## Integration Points

### Paywall Screen (`lib/src/screens/premium/paywall_screen.dart`)

**UI Components:**
- Subscription tier cards
- Feature comparison view
- Purchase button with loading state
- Trial offer display
- Restore purchases button

**Integration:**
```dart
OnPressed: () => paywall.purchaseSubscription(
  type: SubscriptionType.premium,
  period: SubscriptionPeriod.monthly,
)
```

### Feature Gating in UI

**Example: Showing premium content**
```dart
if (paywall.isFeatureAvailable('unlimited_puzzles')) {
  // Show unlimited puzzle list
} else {
  // Show paywall promotion
  showPaywall(context, 'unlimited_puzzles');
}
```

### Analytics Integration

**Track game completion:**
```dart
analytics.logGameCompleted(
  gameId: game.id,
  gameType: 'online_pvp',
  duration: duration.inMilliseconds,
  won: game.winner == userId,
  moveCount: game.moves.length,
  ratingBefore: userBefore.rating,
  ratingAfter: userAfter.rating,
)
```

## Firebase Configuration

### Required Collections

**For Analytics:**
- Events automatically stored in Firebase Console
- Custom events accessible via BigQuery export
- Real-time dashboard available in Firebase Console

**For Paywall:**
- Revenue events tracked automatically
- Subscription purchases logged via Firebase
- Custom revenue collection (optional):
  ```
  - revenue_events/{userId}/subscription_history
  - analytics_revenue/monthly_metrics
  ```

### Dashboard Queries

**Revenue Query (Firebase Console → Analytics):**
- Purchase events by subscription type
- Conversion rate (free → premium)
- Churn rate calculation
- LTV by cohort

**Engagement Query:**
- Daily/Monthly Active Users (DAU/MAU)
- Retention curves
- Feature adoption rates
- Churn correlation analysis

## Testing

### Manual Testing Checklist

- [ ] Free user can access free features
- [ ] Free user is blocked from premium features
- [ ] Premium user can access premium features
- [ ] Premium Plus user can access all features
- [ ] Purchase flow completes successfully (sandbox mode)
- [ ] Restore purchases works
- [ ] Subscription cancellation works
- [ ] Analytics events are logged
- [ ] Screen views are tracked
- [ ] Revenue events appear in Firebase Console

### Test Scenarios

**Free to Premium Conversion:**
1. Start as free user
2. Attempt premium feature access
3. Paywall appears
4. Complete mock purchase
5. Verify premium access granted
6. Check Firebase for purchase event

**Analytics Tracking:**
1. Complete game
2. Check Firebase event logged
3. Verify all parameters captured
4. Check custom dimensions set

## Production Checklist

- [ ] RevenueCat API key configured
- [ ] Firebase Analytics enabled
- [ ] Revenue tracking implemented
- [ ] App Store subscription products created
- [ ] Google Play subscription products created
- [ ] Privacy policy updated with subscription terms
- [ ] Test subscription purchases
- [ ] Monitor first week revenue
- [ ] Set up Firebase alerts for failures

## Troubleshooting

**Subscription not syncing:**
- Check RevenueCat API key is correct
- Verify network connectivity
- Check Firebase rules allow analytics writes

**Analytics events missing:**
- Enable Firebase Analytics in app
- Check event parameters are valid
- Verify user opted in to analytics
- Check Firebase quota limits

**Revenue not appearing:**
- Verify purchases are in sandbox/production
- Check user is logged in
- Ensure Firebase SDK initialized before purchase
- Check revenue collection is enabled

## Next Steps

1. **Phase F (Testing & Release)** - Comprehensive testing of paywall/analytics
2. **Phase G (Deployment)** - Production deployment with monitoring
3. **Phase P (Analytics)** - Advanced analytics dashboards and insights

---

Generated with [Claude Code](https://claude.ai/code)

Phase E: Week 13 - Paywall & Analytics Complete ✅
