# Phase F: Device Testing Matrix & Procedures

**Phase**: F (Testing & Release)
**Component**: Device Testing
**Status**: Ready for Execution
**Date**: 2026-09-02

---

## Device Testing Matrix

### iOS Testing Devices

| Device | OS Version | Screen Size | Chip | RAM | Status |
|--------|-----------|------------|------|-----|--------|
| iPhone SE (2nd Gen) | iOS 14.8+ | 4.7" | A13 | 3GB | Priority |
| iPhone 12 | iOS 15.x | 6.1" | A14 | 4GB | Priority |
| iPhone 13 Pro | iOS 16.x | 6.1" | A15 | 6GB | Priority |
| iPhone 14 Pro Max | iOS 17.x | 6.7" | A16 | 8GB | Priority |
| iPad (7th Gen) | iOS 15.x | 10.2" | A10 | 3GB | Important |

### Android Testing Devices

| Device | OS Version | Screen Size | Chip | RAM | Status |
|--------|-----------|------------|------|-----|--------|
| Motorola G30 | Android 7.1 | 6.5" | Helio G85 | 4GB | Critical |
| Samsung Galaxy S21 | Android 11.x | 6.2" | Exynos 2100 | 8GB | Priority |
| OnePlus 9 | Android 12.x | 6.55" | SD 888 | 8GB | Priority |
| Pixel 4a | Android 13.x | 5.81" | SD 765G | 6GB | Priority |
| Samsung Galaxy Tab S7 | Android 11.x | 11.0" | SD 865+ | 6GB | Important |

---

## Test Categories

### 1. Installation & Setup
- [ ] Clean install from app store (both platforms)
- [ ] Upgrade from previous version (if applicable)
- [ ] App permissions requests
- [ ] Initial onboarding flow
- [ ] User registration/login
- [ ] First launch experience

### 2. Paywall & Purchases
- [ ] Paywall displays correctly
- [ ] Pricing displays accurately
- [ ] Trial option visible
- [ ] Purchase initiation works
- [ ] Purchase completion works
- [ ] Subscription status displays
- [ ] Restore purchases works
- [ ] Failed purchase recovery

### 3. Subscription Management
- [ ] Subscription details display
- [ ] Renewal date shows correctly
- [ ] Cancellation flow works
- [ ] Account information displays
- [ ] Upgrade/downgrade options
- [ ] Support contact info visible

### 4. Premium Features
- [ ] Pro features accessible
- [ ] Elite features accessible
- [ ] Feature paywalls trigger
- [ ] Upsell messaging appears
- [ ] Feature access validated

### 5. Core Gameplay
- [ ] Puzzle mode loads
- [ ] Puzzle displays correctly
- [ ] Move tracking works
- [ ] Puzzle completion tracked
- [ ] Game mode loads
- [ ] Game displays correctly
- [ ] Move validation works
- [ ] Game completion tracked

### 6. Analytics
- [ ] Events logged (Firebase)
- [ ] User properties set
- [ ] Revenue events tracked
- [ ] Engagement events tracked
- [ ] Funnel events logged
- [ ] Crashes reported
- [ ] Custom events recorded

### 7. Offline Functionality
- [ ] Offline queue works
- [ ] Events queue locally
- [ ] Sync on reconnection
- [ ] Queue persists after restart
- [ ] No data loss

### 8. Performance
- [ ] App launch < 3 seconds
- [ ] Paywall display < 1 second
- [ ] Smooth scrolling (60fps)
- [ ] No jank detected
- [ ] Memory stable
- [ ] Battery drain acceptable

### 9. Accessibility
- [ ] Text size options work
- [ ] Voice-over compatible
- [ ] High contrast mode works
- [ ] Touch targets adequate
- [ ] Navigation logical

### 10. Network Conditions
- [ ] WiFi connectivity
- [ ] 4G/LTE connectivity
- [ ] Network timeout handling
- [ ] Retry logic works
- [ ] Error messages clear

### 11. User Interface
- [ ] UI displays correctly
- [ ] Text readable
- [ ] Images load
- [ ] Buttons responsive
- [ ] Navigation works
- [ ] Dark mode support
- [ ] Landscape mode (if supported)

### 12. Orientation
- [ ] Portrait mode works
- [ ] Landscape mode works
- [ ] Rotation handles correctly
- [ ] State preserved on rotation
- [ ] UI adjusts properly

### 13. Localization
- [ ] Text displays correctly
- [ ] Special characters handled
- [ ] Date formatting correct
- [ ] Number formatting correct
- [ ] Currency display correct

### 14. Audio/Notifications
- [ ] Sounds play (if applicable)
- [ ] Vibration works (if applicable)
- [ ] Notifications display
- [ ] Notification badges update
- [ ] Sound settings respected

---

## Test Execution Procedures

### Pre-Test Setup
1. **Device Preparation**
   ```
   - Clear app cache: Settings → Apps → [App] → Clear Cache
   - Clear app data: Settings → Apps → [App] → Clear Storage
   - Check available storage: > 1GB free
   - Enable development options (Android)
   - Enable Console logs (iOS)
   ```

2. **Test Account Setup**
   ```
   - Create test user account
   - Test with test/sandbox purchase account
   - Document credentials
   - Document test transaction IDs
   ```

3. **Environment Setup**
   ```
   - Firebase emulator (if using)
   - RevenueCat sandbox mode
   - Analytics debugging enabled
   - Network proxy (optional, for request inspection)
   ```

### Test Execution

#### Quick Test (30 minutes)
1. Install app
2. Complete onboarding
3. View paywall
4. Attempt purchase (use sandbox)
5. Check subscription display
6. Verify analytics events in Firebase

#### Standard Test (2 hours)
1. Full installation test
2. All purchase scenarios
3. Subscription management
4. Gameplay features
5. Analytics validation
6. Offline scenarios
7. Performance measurements

#### Comprehensive Test (4 hours)
1. All standard test items
2. All edge cases
3. Network condition variations
4. Memory/battery impact
5. Accessibility testing
6. UI/UX validation
7. Documentation and screenshots

### Test Documentation

#### Test Report Template
```
Device: [Model]
OS Version: [Version]
App Version: [Version]
Build Number: [Number]
Date: [Date]
Tester: [Name]

Test Results:
- Category: [Result - PASS/FAIL/WARNING]
- Notes: [Observations]

Performance:
- Startup time: [ms]
- Memory usage: [MB]
- Battery impact: [%/hour]

Issues Found:
1. [Issue ID] - [Severity] - [Description]
2. [Issue ID] - [Severity] - [Description]

Screenshots:
- [Screenshot locations]

Recommendations:
- [Recommendation 1]
- [Recommendation 2]
```

---

## Issue Severity Levels

| Severity | Description | Example |
|----------|-------------|---------|
| Critical | App crashes, no workaround | App doesn't launch, purchase always fails |
| High | Feature broken, significant impact | Paywall doesn't display, can't restore purchases |
| Medium | Feature partially broken, workaround exists | Minor visual glitch, slow loading |
| Low | Cosmetic or minor issue | Typo, color mismatch, animation jank |

---

## Device Testing Schedule

### Week 14 Testing
```
Monday:
- iPhone SE + iPhone 12 on iOS 14/15
- Motorola G30 + Pixel 4a on Android 7/13

Tuesday:
- iPhone 13 Pro + iPhone 14 Pro Max
- Samsung Galaxy S21 + OnePlus 9

Wednesday:
- iPad testing
- Samsung Galaxy Tab S7

Thursday:
- Network condition testing
- Performance profiling
- Issue triage and documentation

Friday:
- Retesting of fixed issues
- Final validation
```

---

## Performance Benchmarking

### Startup Time Test
```
Procedure:
1. Close app completely
2. Start timer
3. Tap app icon
4. Stop timer when app first interactive

Target: < 3 seconds
Acceptable: < 5 seconds
Warning: > 5 seconds
```

### Memory Usage Test
```
Procedure:
1. Open app
2. Perform typical actions for 5 minutes
3. Check memory usage in:
   - iOS: Xcode Instruments
   - Android: Android Studio Profiler

Target: < 100MB
Acceptable: < 150MB
Warning: > 150MB
```

### Battery Impact Test
```
Procedure:
1. Fully charge device
2. Use app for 1 hour
3. Note battery drain %

Target: < 10% drain
Acceptable: < 15% drain
Warning: > 15% drain
```

---

## Accessibility Testing

### VoiceOver Testing (iOS)
- [ ] All buttons have descriptive labels
- [ ] Text hierarchy correct
- [ ] Images have alt text
- [ ] Navigation logical
- [ ] Gestures documented

### TalkBack Testing (Android)
- [ ] All interactive elements labeled
- [ ] Reading order logical
- [ ] Button text descriptive
- [ ] Links identified
- [ ] Images described

### Visual Accessibility
- [ ] Text size adjustable
- [ ] High contrast option
- [ ] Color not only differentiator
- [ ] Focus indicators visible
- [ ] Touch targets > 48x48dp

---

## Test Defect Tracking

### Defect Report Template
```
ID: DEF-XXXX
Title: [Brief description]
Severity: [Critical/High/Medium/Low]
Device: [Device model]
OS Version: [OS version]
Build: [Build number]
Date Found: [Date]
Tester: [Name]

Steps to Reproduce:
1. [Step 1]
2. [Step 2]
3. [Step 3]

Expected Behavior:
[What should happen]

Actual Behavior:
[What actually happened]

Screenshots/Videos:
[Attachments]

Environment:
- Network: [WiFi/4G/3G/Offline]
- RAM: [GB]
- Storage: [GB free]
- Other apps running: [Yes/No]

Root Cause (if known):
[Analysis]

Resolution:
[Fix applied]

Status:
- Found: [Date]
- Fixed: [Date]
- Verified: [Date]
```

---

## Test Metrics

### Coverage Metrics
- Test cases executed: _____ / 100+
- Pass rate: _____ %
- Defects found: _____ 
  - Critical: _____
  - High: _____
  - Medium: _____
  - Low: _____

### Platform Coverage
- iOS versions tested: _____ / 5
- Android versions tested: _____ / 5
- Screen sizes tested: _____ / 8

### Feature Coverage
- Purchase flow: _____ % tested
- Subscription management: _____ % tested
- Gameplay: _____ % tested
- Analytics: _____ % tested
- Offline: _____ % tested

---

## Sign-Off

### QA Lead Sign-Off
```
Name: _______________________
Date: _______________________
All tests passed: [ ] Yes [ ] No
Critical issues: 0 [ ] Yes [ ] No
Approval: [ ] Approved [ ] Rejected
```

### Release Manager Sign-Off
```
Name: _______________________
Date: _______________________
Ready for release: [ ] Yes [ ] No
Risk level: [ ] Low [ ] Medium [ ] High
Approval: [ ] Approved [ ] Rejected
```

---

**Status**: ✅ **READY FOR DEVICE TESTING**
