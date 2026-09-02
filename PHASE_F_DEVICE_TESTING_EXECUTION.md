# Phase F Stage 2: Device Testing Execution

**Status**: 🟡 READY TO EXECUTE
**Date**: 2026-09-02
**Branch**: `claude/phase-f-stage-2-device-testing-*`
**Duration**: Days 3-5 of Week 14

---

## Quick Start

### Before You Begin
1. ✅ Build scripts are ready (`scripts/build_release.sh`)
2. ✅ APK/IPA built and installed on devices
3. ✅ App launches successfully
4. ✅ Firebase connection verified
5. ✅ Analytics logging confirmed

### Test Execution Modes

**Quick Test** (1-2 hours) - Essential validation
- Installation & Launch (10 cases)
- Purchase Flow (5 critical cases)
- Basic analytics verification
- One gameplay session

**Standard Test** (4-6 hours) - Comprehensive coverage
- All 14 test categories (50+ cases)
- Performance benchmarking
- Network simulation
- Full gameplay

**Comprehensive Test** (8+ hours) - Complete validation
- All 100+ test cases
- Extended stress testing
- Battery/memory monitoring
- Accessibility audit

---

## Test Environment Setup

### Device Preparation

#### Android
```bash
# Connect device
adb devices

# Enable developer options (Settings → About → Build Number x7)
# Enable USB debugging
# Install app
adb install build/app/outputs/flutter-apk/app-release.apk

# Verify installation
adb shell pm list packages | grep chess_tactics_master

# Launch app
adb shell am start -n com.yourwish.chess_tactics_master/.MainActivity

# View logs (keep running during tests)
adb logcat | grep -E "(Chess|Analytics|Firebase|Error)" &
```

#### iOS
```bash
# Connect device via Xcode
# Trusted computer dialog: Tap "Trust"
# Install IPA via Xcode or TestFlight

# View logs
# Xcode → Window → Devices and Simulators → [Device] → View Device Logs

# Alternative: Console.app
# Or: log stream --predicate 'process == "chess_tactics_master"'
```

### Test Results Documentation

Create results file for each device:

```bash
# Android
mkdir -p test_results/devices
cat > test_results/devices/android_device_DEVICENAME_DATE.md << 'EOF'
# Android Device Test Results

**Device**: [Model Name]
**OS Version**: [e.g., Android 13]
**API Level**: [e.g., 33]
**App Version**: 1.0.0+1
**Build Date**: [Date]
**Tester**: [Name]

## Installation & Launch
- [ ] APK installed successfully
- [ ] App launches without crash
- [ ] Main screen loads
- [ ] Firebase initialized
- [ ] Analytics active

## Test Results
[To be filled during testing]

## Issues Found
[List any bugs/crashes]

## Performance Metrics
- Startup time: ___ms
- Memory usage: ___MB
- Crash rate: ___

## Sign-Off
Tester: _____________  Date: _______
EOF
```

---

## Test Categories & Procedures

### 1️⃣ Installation & Launch (10 test cases)

#### Test 1.1: APK Installation
```
Steps:
  1. Build release APK
  2. Connect device
  3. Run: adb install build/app/outputs/flutter-apk/app-release.apk
  4. Verify installation: adb shell pm list packages | grep chess

Expected: ✅ App installed, shows in settings
```

#### Test 1.2: First Launch
```
Steps:
  1. Tap app icon
  2. Wait for splash screen
  3. Observe loading sequence

Expected: ✅ App launches, no crashes, Firebase logs appear
Measure: Startup time (should be < 3 seconds)
```

#### Test 1.3: Firebase Initialization
```
Steps:
  1. Launch app
  2. Check logs: adb logcat | grep Firebase
  3. Open app settings
  4. Navigate to About screen

Expected: ✅ Firebase initialized, no auth errors
Log: Look for "Firebase Auth ready" message
```

#### Test 1.4: Analytics Activation
```
Steps:
  1. Launch app
  2. Check logs: adb logcat | grep Analytics
  3. Navigate between screens

Expected: ✅ Analytics events logged, screen_view events appear
Log: Should see event names and parameters
```

#### Test 1.5: Preferences Loading
```
Steps:
  1. Go to Settings
  2. Toggle analytics consent
  3. Toggle crashlytics consent
  4. Close app completely
  5. Reopen app

Expected: ✅ Preferences persisted, no loss of settings
```

#### Test 1.6: Cold Start Performance
```
Measurement:
  1. Start stopwatch when launching app
  2. Stop when main screen is interactive
  3. Record time

Expected: ✅ < 3 seconds for cold start
  - 0-1s: Unacceptable
  - 1-2s: Good
  - 2-3s: Acceptable
  - 3s+: Needs optimization
```

#### Test 1.7: Hot Start Performance
```
Measurement:
  1. App already running
  2. Minimize and restore
  3. Record restore time

Expected: ✅ < 1 second restore time
```

#### Test 1.8: Low Memory Handling
```
Steps (Android):
  1. Go to Settings → Developer Options
  2. Enable "Limit Background Processes" to "No background processes"
  3. Launch app
  4. Navigate screens

Expected: ✅ No crashes, graceful handling
```

#### Test 1.9: Forced Stop & Restart
```
Steps:
  1. Settings → Apps → Chess Tactics Master
  2. Tap "Force Stop"
  3. Wait 5 seconds
  4. Launch app again

Expected: ✅ App restarts cleanly, no data loss
```

#### Test 1.10: Permissions Request
```
Steps:
  1. Fresh install (uninstall, reinstall)
  2. Launch app
  3. Check permission requests

Expected: ✅ Appropriate permissions requested, user can grant/deny
```

---

### 2️⃣ Purchase Flow (15 test cases)

#### Test 2.1: View Paywall
```
Steps:
  1. Go to Premium tab/section
  2. Observe paywall display
  3. Check subscription tiers

Expected: ✅ Paywall shows all tiers (Free, Pro, Elite)
          ✅ Pricing displayed correctly
          ✅ CTA buttons visible
```

#### Test 2.2: Select Tier - Pro Monthly
```
Steps:
  1. Tap "Pro" tier "Subscribe" button
  2. Review offer
  3. Tap "Subscribe"

Expected: ✅ Offer dialog appears
          ✅ Price and details shown
          ✅ Purchase button active
Log: Check for event: offer_selected, subscription tier: pro
```

#### Test 2.3: Initiate Purchase
```
Steps:
  1. From offer dialog, tap "Continue"
  2. System payment sheet appears
  3. Observe payment flow

Expected: ✅ Payment sheet loaded
          ✅ Purchase method selection available
Log: Check for event: purchase_initiated
```

#### Test 2.4: Successful Purchase (Sandbox)
```
Steps (Android - Sandbox):
  1. Use test account
  2. Complete purchase flow
  3. Tap "Buy"
  4. App processes purchase

Expected: ✅ Purchase completes
          ✅ Entitlement granted
          ✅ Subscription status updated
Log: Check events: subscription_purchase, trial_started (if applicable)
```

#### Test 2.5: Failed Purchase Recovery
```
Steps:
  1. Start purchase
  2. Decline payment
  3. Return to app

Expected: ✅ Error message shown
          ✅ User can retry
          ✅ No partial state
Log: Check event: purchase_failed with error code
```

#### Test 2.6: Upgrade Flow (Pro → Elite)
```
Setup: Free user with active Pro subscription
Steps:
  1. Go to subscription management
  2. Tap "Upgrade to Elite"
  3. Confirm upgrade

Expected: ✅ Downgraded to new tier
          ✅ Prorated price applied
          ✅ Billing cycle adjusted
Log: Check event: subscription_upgrade
```

#### Test 2.7: Downgrade Flow (Elite → Pro)
```
Setup: User with Elite subscription
Steps:
  1. Go to subscription management
  2. Tap "Downgrade to Pro"
  3. Confirm downgrade

Expected: ✅ Downgrade applied
          ✅ New tier activated
          ✅ Changes effective next cycle
Log: Check event: subscription_downgrade
```

#### Test 2.8: Trial Period Display
```
Steps:
  1. Select tier with trial (if available)
  2. Review trial details
  3. Observe trial countdown

Expected: ✅ Trial duration shown (e.g., "7 days")
          ✅ Auto-renewal terms displayed
          ✅ Cancel anytime option visible
```

#### Test 2.9: Trial Conversion
```
Setup: User in active trial
Steps:
  1. Wait for or simulate trial expiry
  2. Confirm conversion to paid
  3. Verify subscription status

Expected: ✅ Trial conversion tracked
          ✅ Payment charged
          ✅ Status updated to paid
Log: Check event: trial_converted_to_paid
```

#### Test 2.10: Restore Purchases
```
Setup: Multiple devices with same account
Steps:
  1. On new device, go to subscription
  2. Tap "Restore Purchases"
  3. Wait for sync

Expected: ✅ Existing purchases restored
          ✅ Entitlements granted
          ✅ Subscription status synced
```

#### Test 2.11: Offline Purchase Attempt
```
Setup: Disable network
Steps:
  1. Go to paywall
  2. Attempt purchase
  3. Re-enable network

Expected: ✅ Graceful error message
          ✅ Retry available
          ✅ No partial transactions
```

#### Test 2.12: Concurrent Purchases
```
Steps:
  1. Rapid-tap purchase button multiple times
  2. Observe handling

Expected: ✅ Only one transaction initiated
          ✅ Others queued/ignored
          ✅ No duplicate charges
```

#### Test 2.13: Payment Method Decline
```
Steps:
  1. Start purchase with expired card
  2. System declines payment
  3. App handles error

Expected: ✅ Clear error message
          ✅ Suggest updating payment method
          ✅ User can retry
```

#### Test 2.14: Subscription Management Screen
```
Steps:
  1. Go to Subscription Management
  2. Review all options
  3. Tap Cancel Subscription

Expected: ✅ Current subscription shown
          ✅ Renewal date visible
          ✅ Cancel option works
          ✅ Confirmation required
```

#### Test 2.15: Invoice/Receipt Access
```
Setup: After successful purchase
Steps:
  1. Go to subscription settings
  2. Look for receipt/invoice
  3. Tap to view details

Expected: ✅ Receipt accessible
          ✅ All details present
          ✅ Can share/export if needed
```

---

### 3️⃣ Subscription Management (12 test cases)

[Detailed procedures for status display, renewal, cancellation, etc.]

### 4️⃣ Premium Features (10 test cases)

[Access control, feature gating, trial limits, etc.]

### 5️⃣ Gameplay (15 test cases)

[Puzzle solving, game sessions, ratings, etc.]

### 6️⃣ Analytics (12 test cases)

[Event logging, Firebase verification, real-time dashboard, etc.]

### 7️⃣ Offline Mode (8 test cases)

[Queue events, offline play, sync on reconnect, etc.]

### 8️⃣ Performance (10 test cases)

[Startup time, memory usage, frame rate, battery impact, etc.]

### 9️⃣ Accessibility (8 test cases)

[VoiceOver/TalkBack, text size, contrast, navigation, etc.]

### 🔟 Network Conditions (10 test cases)

[WiFi, 4G, 3G, no connectivity, high latency, packet loss, etc.]

### 1️⃣1️⃣ UI/Layout (12 test cases)

[Responsive design, text wrapping, button spacing, etc.]

### 1️⃣2️⃣ Orientation Changes (6 test cases)

[Portrait ↔ Landscape, animation smoothness, state persistence, etc.]

### 1️⃣3️⃣ Localization (8 test cases)

[Language switching, RTL support, date formats, currency, etc.]

### 1️⃣4️⃣ Audio/Notifications (8 test cases)

[Sound effects, music, push notifications, do-not-disturb, etc.]

---

## Performance Benchmarking

### Metrics to Collect

```bash
# Create performance_results.csv
Device,App Version,Startup Time (ms),Memory (MB),Frames/sec,Battery %
Android - Pixel 4a,1.0.0,2100,87,59,100
iOS - iPhone 12,1.0.0,1850,92,60,100
```

### Measurement Procedures

#### Startup Time
```
1. Open logcat/console
2. Clear log
3. Tap app icon, start stopwatch
4. Stop when first screen interactive
5. Record in milliseconds

Expected: < 3000ms (3 seconds)
```

#### Memory Usage
```
Android:
  adb shell dumpsys meminfo com.yourwish.chess_tactics_master | grep TOTAL

iOS:
  Xcode → Debug Memory Graph (while app running)
  Record Total Memory

Expected: < 150MB
```

#### Frame Rate
```
Android:
  1. Enable Developer Options → Show frame rate
  2. Run app, watch frame counter
  3. Expected: Consistent 60fps, minimal drops

iOS:
  1. Xcode → Debug → Rendering Performance
  2. Expected: Smooth animations, no stuttering
```

---

## Issue Tracking Template

### Critical Issues (Blocks Release)

```markdown
## [CRITICAL] App crashes on first launch - Pixel 4a

**Device**: Google Pixel 4a (Android 13, API 33)
**Reproducibility**: 100% (every launch)
**Steps to Reproduce**:
1. Fresh install via `adb install app-release.apk`
2. Tap app icon
3. App crashes after splash screen

**Expected**: App launches successfully to home screen

**Actual**: Crash with error:
```
E/AndroidRuntime: FATAL EXCEPTION: main
  Process: com.yourwish.chess_tactics_master, PID: 12345
  java.lang.NullPointerException: Firebase initialization failed
```

**Logs**: [Paste full logcat]

**Impact**: Completely blocks usage on this device

**Priority**: 🔴 CRITICAL - Fix before release
```

### High Priority Issues

```markdown
## [HIGH] Purchase button text cut off - iPhone SE

**Device**: iPhone SE (iOS 14, 375px width)
**Reproducibility**: 100%
**Steps**:
1. Navigate to paywall
2. Observe "Subscribe" button

**Expected**: Full button text visible

**Actual**: Text is truncated to "Subscri..."

**Impact**: Affects 2% of iOS users (SE users)

**Priority**: 🟠 HIGH - Fix before week 15
```

---

## Test Execution Schedule

### Week 14 - Testing Phase

| Day | Phase | Tests | Expected Duration |
|-----|-------|-------|-------------------|
| 3 | Quick Test | 20 cases | 2 hours |
| 4 | Standard Test | 50 cases | 6 hours |
| 4 | Performance | Benchmarks | 2 hours |
| 5 | Comprehensive | 100+ cases | 8 hours |
| 5 | Security Audit | 32 items | 4 hours |

### Parallel Execution

**Multiple Testers**: Divide device matrix
- Tester 1: iPhone SE, Pixel 4a (Android devices)
- Tester 2: iPhone 12, Galaxy S21 (iOS devices)
- Tester 3: iPad, Galaxy Tab S7 (Tablets)

---

## Sign-Off Checklist

### Per Device

- [ ] Installation successful
- [ ] First launch - no crash
- [ ] Firebase initialized
- [ ] Analytics active
- [ ] All 14 test categories passing
- [ ] No critical issues
- [ ] Performance acceptable
- [ ] Accessibility working

### Device Sign-Off Template

```markdown
## Device Test Sign-Off: [Device Name]

**Device**: iPhone 13 Pro (iOS 16.7)
**Tester**: Alice
**Test Date**: 2026-09-04
**Duration**: 6 hours

### Results
- Installation: ✅ PASS
- Launch Performance: ✅ PASS (1.8s)
- Purchase Flow: ✅ PASS
- Analytics: ✅ PASS
- Offline Mode: ✅ PASS
- Performance: ✅ PASS
- Accessibility: ✅ PASS
- Issues Found: 0

### Sign-Off
**Tester Signature**: ________________
**Date**: ________________
**Status**: ✅ APPROVED FOR RELEASE
```

---

## Common Testing Scenarios

### Scenario 1: First-Time User Journey
```
1. Fresh install
2. First launch
3. See onboarding/home
4. Browse free features
5. View paywall
6. Start free trial (if available)
7. Play puzzle
8. Check subscription status
```

### Scenario 2: Returning User
```
1. App already installed
2. Launch (hot start)
3. See home screen with user data
4. Resume game session
5. Complete purchase
6. Access premium feature
```

### Scenario 3: Network Transition
```
1. Launch app (WiFi)
2. Start gameplay
3. Switch to mobile data
4. Continue gameplay
5. Lose connectivity
6. Regain connectivity
7. Verify sync
```

---

## Next Actions After Testing

### If All Tests Pass ✅
1. Create GitHub issue: "✅ Device Testing Complete - All Systems Go"
2. Prepare app store metadata
3. Create release notes
4. Proceed to Week 15 submission

### If Critical Issues Found 🔴
1. Create GitHub issue with CRITICAL label
2. Prioritize fixes (target: 24 hours)
3. Re-test after fixes
4. Only proceed when resolved

### If High Priority Issues Found 🟠
1. Create GitHub issue with High Priority label
2. Assess impact vs schedule
3. Decide: Fix now or defer to Phase G
4. Document decision
5. Proceed or schedule second testing round

---

**Status**: Ready for device testing execution
**Next Milestone**: Device testing complete by 2026-09-05
**Success Criteria**: 0 critical issues, all 100+ test cases passing
