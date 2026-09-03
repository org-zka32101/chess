# Phase H Stage 2: A/B Testing & Optimization

**Status**: Ready for Execution  
**Date**: 2026-09-03  
**Duration**: Ongoing (Week 17+)  
**Target**: Continuous optimization through experimentation, data-driven decisions

---

## Overview

Phase H Stage 2 implements a systematic approach to testing variations of features, UI elements, and user flows. Through A/B testing, we identify high-impact improvements and optimize the app based on user behavior data.

**Timeline**: Week 17+ (post-launch + 2 weeks)  
**Success Criteria**: A/B testing framework operational, 3+ tests running, conversion metrics improving

---

## 1. A/B Testing Framework

### 1.1 Testing Infrastructure

**Firebase Remote Config Setup**:
```dart
// lib/src/services/ab_test_service.dart

class ABTestService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initializeABTests() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    // Set default values
    await _remoteConfig.setDefaults({
      // Paywall A/B Tests
      'paywall_design': 'control', // control vs. new_design
      'subscription_price': 'tier1', // tier1 vs. tier2 vs. promotional
      'trial_length_days': 7,
      'trial_cta_text': 'Start Free Trial', // vs. other copy
      
      // Feature Flags
      'enable_dark_mode': true,
      'enable_game_analysis': true,
      'enable_chess_variants': false,
      
      // Onboarding A/B Tests
      'tutorial_length': 'standard', // short vs. standard vs. long
      'tutorial_skip_allowed': true,
      'first_puzzle_difficulty': 'medium',
      
      // Content Tests
      'daily_puzzle_limit_free': 30, // vs. 40, 50
      'multiplayer_elo_matching': 'strict', // strict vs. loose
      
      // Engagement Tests
      'push_notification_frequency': 'daily', // never vs. daily vs. weekly
      'achievement_system': 'basic', // basic vs. advanced
    });

    // Fetch and activate remote config
    await _remoteConfig.fetchAndActivate();
  }

  // Check if user is in test variant
  String getTestVariant(String testName) {
    return _remoteConfig.getString(testName);
  }

  // Check if feature enabled
  bool isFeatureEnabled(String featureName) {
    return _remoteConfig.getBool(featureName);
  }

  // Log test impression (user saw variant)
  void logTestImpression(String testName, String variant) {
    FirebaseAnalytics.instance.logEvent(
      name: 'ab_test_impression',
      parameters: {
        'test_name': testName,
        'variant': variant,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Log test conversion (user acted on variant)
  void logTestConversion(String testName, String variant, {String? action}) {
    FirebaseAnalytics.instance.logEvent(
      name: 'ab_test_conversion',
      parameters: {
        'test_name': testName,
        'variant': variant,
        'action': action ?? 'conversion',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
```

**Test Assignment**:
```
User Bucketing Strategy:
- Deterministic assignment (based on user ID hash)
- Stable across sessions (same user always in same variant)
- 50/50 split by default (control vs. variant)
- Can be weighted (80/20, 70/30, etc.)

Assignment Logic:
1. Hash user ID: hash(user_id)
2. Modulo 100: hash % 100 = bucket (0-99)
3. 0-49: Control group
4. 50-99: Variant group

Example:
```python
def get_test_bucket(user_id, test_name):
    seed = f"{test_name}_{user_id}"
    bucket = hash(seed) % 100
    return "control" if bucket < 50 else "variant"
```

Ensures:
✅ No bias (hash-based)
✅ Stability (same user always assigned same)
✅ 50/50 split (mathematical guarantee)
```

### 1.2 Test Design Process

**Before Running Any Test**:
```
Step 1: Define Hypothesis
"We hypothesize that showing a 7-day free trial 
instead of 3-day will increase trial signups 
by 15% without harming conversion rate."

Step 2: Identify Metric
Primary: Trial signup rate (daily)
Secondary: Trial-to-paid conversion rate
Guardrail: Revenue per user (must not decrease)

Step 3: Calculate Sample Size
Using A/B test calculator:
- Baseline: 2% trial signup rate
- Expected lift: 15% (to 2.3%)
- Significance level: 95%
- Statistical power: 80%
Result: 6,400 users per group (12,800 total)
Duration: ~5 days at 1,300 DAU

Step 4: Duration & Schedule
- Test duration: 5-7 days minimum
- Run during normal week (avoid weekends)
- Avoid holidays/special events
- Schedule for Sept 15-22

Step 5: Data Collection
- Log test variant assignment
- Track all relevant events
- Monitor for data issues
- Alert if variant differs significantly

Step 6: Analysis
- Wait for statistical significance
- Calculate confidence intervals
- Check guardrail metrics
- Document learnings
```

---

## 2. Concurrent A/B Tests (Roadmap)

### 2.1 Month 1 Tests (September)

**Test 1: Paywall Design** (Week 2)
```
Hypothesis: 
"A redesigned paywall with social proof 
(testimonials + ratings) will increase 
subscription conversion by 20%"

Control: Current paywall design
Variant: New design with:
- 5-star rating badges
- "Joined by 5,000+ players" message
- Testimonial quotes
- Better tier comparison

Metrics:
- Paywall view rate
- Tap subscribe rate
- Trial signup rate
- Trial-to-paid conversion

Success Criteria:
- Variant ≥ 20% lift in any metric
- No guardrail violation (revenue)

Expected ROI:
- If hypothesis correct: +20% subscriptions
- Revenue impact: ~+$1,000/month
- Implementation cost: 1 day design, 0.5 day dev
```

**Test 2: Free Daily Puzzle Limit** (Week 1-2)
```
Hypothesis:
"Increasing daily free puzzles from 30 to 50 
will reduce churn and increase engagement 
without reducing subscription conversion"

Control: 30 daily puzzles (free)
Variant: 50 daily puzzles (free)

Rationale:
- User feedback: "Need more free content" (78 requests)
- Competitor has 50+ daily puzzles
- Goal: Increase engagement, not hurt monetization

Metrics:
- Daily puzzle completion (free)
- DAU retention (D1, D7, D30)
- Trial signup rate
- Trial-to-paid conversion

Success Criteria:
- Variant shows improved retention (D7 +5%+)
- Conversion rate stable (not decreased >5%)
- Engagement increases measurably

Expected ROI:
- Improved retention → higher LTV
- Better engagement → more app opens
- Risk: Lower conversion if too much free content
```

**Test 3: Tutorial Length** (Week 3)
```
Hypothesis:
"Shortening the tutorial from 5 minutes 
to 2 minutes will increase tutorial 
completion rate without hurting learning"

Control: Full 5-minute tutorial
Variant A: Shortened 2-minute tutorial
Variant B: Skip-able tutorial (1-click skip)

Metrics:
- Tutorial completion rate
- Tutorial skip rate
- First puzzle completion rate
- D1 retention
- Engagement (puzzles per session)

Success Criteria:
- Variant completion rate increases
- First puzzle completion stays stable
- No regression in D1 retention

Expected ROI:
- Faster onboarding = more users reach games
- Risk: Users might not understand features
- Balance: Keep essential learning
```

### 2.2 Month 2 Tests (October)

**Test 4: Push Notification Frequency** (Week 5-6)
```
Hypothesis:
"Sending 3 push notifications per week 
will increase DAU by 10% without 
increasing uninstall rate"

Control: Current frequency (1x/week)
Variant: 3x/week notifications
- Monday: "New puzzles available"
- Wednesday: "Your friends are playing"
- Friday: "Climb the leaderboard"

Metrics:
- Notification click rate
- DAU (with notification opt-in)
- Uninstall rate
- Notification opt-out rate

Success Criteria:
- Variant increases DAU by 8%+
- Uninstall rate stable (<5%)
- Opt-out rate acceptable (<30%)
```

**Test 5: Multiplayer Matching Algorithm** (Week 6-7)
```
Hypothesis:
"Loosening ELO matching requirements 
will reduce queue wait times and 
increase multiplayer participation"

Control: Strict matching (±150 ELO)
Variant: Loose matching (±300 ELO)

Metrics:
- Average queue wait time
- Multiplayer participation rate
- Game completion rate
- User satisfaction rating

Success Criteria:
- Variant reduces wait by 30%+ 
- Participation increases
- User rating doesn't drop
```

### 2.3 Month 3+ (November - Ongoing)

**Test Template for Future**:
```
Test: [Name]
Hypothesis: [One sentence]
Control: [Current state]
Variant: [Change being tested]
Duration: [X-Y days]
Sample Size: [Users needed]
Primary Metric: [KPI]
Secondary Metrics: [Supporting KPIs]
Guardrails: [Metrics that must not worsen]
Success Criteria: [Win condition]
Expected Impact: [Revenue/engagement/retention]
```

---

## 3. Test Analysis & Results

### 3.1 Statistical Analysis Framework

**Post-Test Analysis**:
```python
# analyze_ab_test.py

from scipy import stats
import numpy as np

def analyze_test_results(control_data, variant_data, 
                         metric_name, baseline_rate):
    """
    Analyze A/B test results for statistical significance
    """
    
    # Extract conversion counts
    control_conversions = control_data['conversions'].sum()
    control_total = len(control_data)
    
    variant_conversions = variant_data['conversions'].sum()
    variant_total = len(variant_data)
    
    # Calculate rates
    control_rate = control_conversions / control_total
    variant_rate = variant_conversions / variant_total
    
    # Chi-square test for significance
    contingency_table = [
        [control_conversions, control_total - control_conversions],
        [variant_conversions, variant_total - variant_conversions]
    ]
    
    chi2, p_value = stats.chi2_contingency(contingency_table)[:2]
    
    # Calculate confidence interval for uplift
    pooled_rate = (control_conversions + variant_conversions) / (control_total + variant_total)
    se = np.sqrt(pooled_rate * (1 - pooled_rate) * (1/control_total + 1/variant_total))
    
    uplift = (variant_rate - control_rate) / control_rate
    ci_lower = uplift - 1.96 * se
    ci_upper = uplift + 1.96 * se
    
    # Result
    is_significant = p_value < 0.05
    
    return {
        'control_rate': control_rate,
        'variant_rate': variant_rate,
        'uplift_pct': uplift * 100,
        'p_value': p_value,
        'significant': is_significant,
        'ci_lower': ci_lower * 100,
        'ci_upper': ci_upper * 100,
        'sample_sizes': {
            'control': control_total,
            'variant': variant_total
        }
    }

# Example output:
# {
#     'control_rate': 0.024,
#     'variant_rate': 0.029,
#     'uplift_pct': 20.8,
#     'p_value': 0.0312,
#     'significant': True,
#     'ci_lower': 2.4,
#     'ci_upper': 39.2,
# }
#
# Interpretation: 20.8% uplift, 95% confident true uplift is 2.4% to 39.2%
```

### 3.2 Test Results Report Template

**Report (Post-Test)**:
```markdown
# A/B Test Results: Paywall Redesign

## Summary
**Result**: WINNER - Variant statistically significant

## Metrics

| Metric | Control | Variant | Uplift | P-Value | Sig |
|--------|---------|---------|--------|---------|-----|
| Paywall CTR | 2.4% | 2.88% | +20% | 0.031 | ✅ |
| Trial Signup | 0.89% | 1.06% | +19% | 0.042 | ✅ |
| Conversion (paid) | 0.22% | 0.24% | +9% | 0.412 | ❌ |

## Statistical Details

**Paywall CTR**:
- Control: 24/1000 = 2.4%
- Variant: 29/1003 = 2.89%
- Uplift: +20.4% (95% CI: +2.1% to +42.8%)
- P-value: 0.031 (significant at p<0.05)
- Sample size: 2,003 users

## Business Impact

**Monthly Revenue (Projected)**:
- Current: ~$6,000/month
- With variant: ~$7,200/month
- Incremental: +$1,200/month

**Confidence**: 
- 95% confident true uplift is between 2% and 43%
- Conservative estimate: 2% uplift = +$120/month
- Optimistic estimate: 20% uplift = +$1,200/month
- Expected value: 11% uplift = +$660/month

## Recommendation

**ACTION**: Deploy Variant (New Paywall Design)
- ROI: +11% subscription revenue
- Risk: Low (paywall redesign, no breaking changes)
- Timeline: Deploy immediately to 100%
- Monitoring: Watch conversion rate for 1 week post-launch

## Learnings

1. **Social proof works**: Testimonials increased CTR
2. **Visual hierarchy matters**: Better tier comparison helped
3. **No cannibalization**: Didn't hurt D1 paid conversion

## Follow-up Tests

- Test different testimonials (which ones resonate?)
- Test pricing tiers (price elasticity)
- Test CTA button colors (call-to-action testing)
```

---

## 4. Continuous Optimization Process

### 4.1 Optimization Cycle

**Weekly Process**:
```
Monday: Planning
├─ Review current test results
├─ Analyze new feedback (500+ user mentions)
├─ Identify optimization opportunity
└─ Design next test hypothesis

Tuesday-Wednesday: Development
├─ Implement variant
├─ Code review (design + engineering)
├─ QA testing on real devices
└─ Remote config setup

Thursday: Deployment
├─ Deploy to 50% of users (gradual rollout)
├─ Monitor for crashes/errors
├─ Verify analytics logging
└─ Announce to team

Friday: Monitoring
├─ Check first-day results
├─ Verify no data collection issues
├─ Monitor guardrail metrics
└─ Prepare weekend report

Weekend: Analysis (if needed)
├─ Detect issues early
├─ Prepare emergency rollback
├─ Document learnings
└─ Update roadmap
```

### 4.2 Guardrail Metrics (Must Not Regress)

**Non-negotiable Metrics**:
```
Any test must NOT:

1. Crash Rate
   - Baseline: <0.1%
   - Threshold: >0.5% = STOP test immediately

2. Revenue per User
   - Baseline: $1.13/user/month
   - Threshold: >10% decrease = STOP test

3. Core Flow Completion
   - First puzzle completion: >90%
   - Threshold: <80% = STOP test

4. D1 Retention
   - Baseline: 42%
   - Threshold: <35% = STOP test

5. Error Rate
   - Baseline: <1% of sessions
   - Threshold: >2% = STOP test

Automated Monitoring:
- Check every 2 hours while test is running
- Auto-alert if guardrail breached
- Automatic rollback if critical threshold exceeded
```

---

## 5. Performance Optimization

### 5.1 Code Optimization

**Performance Targets**:
```
Metric              Target      Current     Gap
────────────────────────────────────────────
Cold Startup        <2.5s       2.1s        ✅
Hot Startup         <600ms      600ms       ✅
Memory (idle)       <100MB      98MB        ✅
Memory (peak)       <150MB      120MB       ✅
Frame Rate          60fps       59fps       ✅
Battery (1hr)       <10%        8%          ✅

Areas for Optimization:
1. Puzzle Loading: Cache locally
2. Multiplayer Sync: Reduce network calls
3. Board Rendering: Optimize CustomPainter
4. Image Assets: Compress, use WebP format
```

**Optimization Roadmap**:
```
Week 1: Profiling
├─ Profile app with DevTools
├─ Identify hotspots (top 5)
└─ Document baseline metrics

Week 2-3: Low-hanging Fruit
├─ Fix obvious inefficiencies
├─ Add caching for UI
└─ Optimize image loading

Week 4+: Deep Optimizations
├─ Refactor hot code paths
├─ Implement advanced caching
└─ Platform-specific optimizations
```

---

## 6. Sign-Off

**A/B Testing & Optimization System Complete**:
- [ ] Remote Config Firebase set up
- [ ] Test assignment logic working
- [ ] Analytics event logging configured
- [ ] First 3 tests designed and scheduled
- [ ] Statistical analysis framework ready
- [ ] Performance monitoring active
- [ ] Optimization cycle documented

**Ready to Proceed**: Phase H Stage 3 (Feature Prioritization & Roadmap)

---

**Document Version**: 1.0  
**Last Updated**: 2026-09-03  
**Phase**: H Stage 2 (A/B Testing & Optimization)  
**Status**: Ready for Implementation
