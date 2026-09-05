# Chess Tactics Master - Staging E2E Testing Checklist

**Phase:** G (Production Deployment & Monitoring)  
**Environment:** chess-staging  
**Date Started:** 2026-09-05

---

## Pre-Testing Preparation

- [ ] Staging Firebase project (chess-staging) created and configured
- [ ] RevenueCat sandbox environment set up with 6 test products
- [ ] Staging APK distributed via Firebase App Distribution
- [ ] Staging IPA distributed via TestFlight
- [ ] Test users created in Firebase Auth (staging project)
- [ ] Test credit cards configured in RevenueCat sandbox
- [ ] Build version noted for testing documentation
- [ ] Environment variables verified (.env.staging)

---

## A. Authentication Flow (30 minutes)

**Email Authentication:**
- [ ] Email signup with valid email and password
- [ ] Verification email received and confirmed
- [ ] Email login with registered credentials
- [ ] Invalid email rejected
- [ ] Invalid password rejected
- [ ] Session persists after app restart
- [ ] Logout clears session
- [ ] Re-login works after logout

**Google Sign-In:**
- [ ] Google Sign-In button displays
- [ ] Google authentication popup appears
- [ ] Account selection works
- [ ] Permission consent accepted
- [ ] User logged in with Google account
- [ ] Profile information populated

**Apple Sign-In:**
- [ ] Apple Sign-In button displays (iOS)
- [ ] Apple authentication popup appears
- [ ] Account selection works
- [ ] Permission consent accepted
- [ ] User logged in with Apple account

**Session Management:**
- [ ] Session persists after app termination
- [ ] Session timeout behavior configured
- [ ] Logout removes all session data
- [ ] Firebase auth token properly managed

---

## B. Subscription Flow - RevenueCat Sandbox (45 minutes)

**Paywall Display:**
- [ ] Paywall screen renders on app launch (free user)
- [ ] All 6 subscription tiers display:
  - [ ] Premium Monthly ($4.99)
  - [ ] Premium Yearly ($49.90)
  - [ ] Premium Lifetime ($99.99)
  - [ ] Premium Plus Monthly ($9.99)
  - [ ] Premium Plus Yearly ($99.90)
  - [ ] Premium Plus Lifetime ($199.99)
- [ ] Pricing displays correctly
- [ ] Trial duration visible (if applicable)
- [ ] Terms and Privacy links accessible

**Purchase Flow:**
- [ ] Premium Monthly purchase initiates
- [ ] Payment sheet displays correctly
- [ ] Sandbox transaction completes
- [ ] Purchase confirmation shown
- [ ] Premium Features unlock immediately
- [ ] Receipt validated successfully
- [ ] Subscription status updated in Firebase

**Multiple Purchases:**
- [ ] Premium Plus Yearly purchase available
- [ ] Can upgrade from Premium to Premium Plus
- [ ] Proration calculation correct (if applicable)
- [ ] New subscription becomes active

**Lifetime Subscription:**
- [ ] Premium Lifetime purchase available
- [ ] Converts user to lifetime status
- [ ] No recurring charges
- [ ] Lifetime badge displays (if applicable)

**Subscription Management:**
- [ ] View active subscription in app settings
- [ ] Restore purchases works for existing subscriptions
- [ ] Cancel subscription option available
- [ ] Cancellation confirmation shown
- [ ] Subscription status updates to "Canceled"
- [ ] Features revoke after cancellation
- [ ] Re-subscribe after cancellation works
- [ ] Subscription manager (App Store/Play Store) reflects changes

---

## C. Feature Access Verification (30 minutes)

**Free Tier Restrictions:**
- [ ] Free user can view puzzles but limited to 5/day
- [ ] Premium features show "Upgrade to unlock" message
- [ ] Advanced tactics locked behind paywall
- [ ] Lesson content restricted
- [ ] Multiplayer play limited to 1/day
- [ ] Analytics features restricted

**Premium Tier Features:**
- [ ] Unlimited puzzle access
- [ ] All tactics patterns unlocked
- [ ] Lesson library accessible
- [ ] Unlimited multiplayer matches
- [ ] Basic analytics features enabled
- [ ] Custom lesson notes available

**Premium Plus Tier Features:**
- [ ] All Premium features included
- [ ] AI-powered game analysis enabled
- [ ] Advanced player profile access
- [ ] Custom opening preparation
- [ ] Priority support enabled
- [ ] Advanced analytics dashboard

**Feature Gating Logic:**
- [ ] UI correctly reflects subscription tier
- [ ] Paywall appears for locked features
- [ ] Feature access syncs with RevenueCat
- [ ] No feature access without valid subscription
- [ ] Cache updated after subscription change

---

## D. Analytics Validation (30 minutes)

**Event Tracking:**
- [ ] App launch event recorded in Firebase Analytics
- [ ] Screen view events tracked for each screen
- [ ] User property "subscription_type" set correctly
- [ ] User property "registration_date" captured
- [ ] Custom events logged: puzzle_completion, game_result, lesson_view

**Real-Time Dashboard:**
- [ ] Events visible in Firebase Console (5-15 min lag acceptable)
- [ ] Event counts match expected values
- [ ] User counts accurate
- [ ] Session duration reasonable

**Purchase Events:**
- [ ] Purchase event logged with revenue amount
- [ ] Currency parameter correct
- [ ] Product ID captured
- [ ] Subscription type parameter set
- [ ] Revenue tracked in Firebase Analytics

**Performance Metrics:**
- [ ] Screen load times logged
- [ ] Feature engagement tracked
- [ ] User retention metrics collected
- [ ] Churn prediction data captured

---

## E. Payment Processing (30 minutes)

**Sandbox Payment Flow:**
- [ ] No real charges occur in sandbox
- [ ] Sandbox payment methods accepted
- [ ] Transaction completes within 5 seconds
- [ ] Receipt returned successfully
- [ ] Subscription status updated immediately

**Receipt Validation:**
- [ ] Receipt signature verified
- [ ] Expiry date checked correctly
- [ ] Subscription duration accurate
- [ ] No duplicate receipts processed
- [ ] Invalid receipts rejected

**Multiple Transactions:**
- [ ] Sequential purchases tracked separately
- [ ] Refund simulation works (if applicable)
- [ ] Retry mechanism works for failed payments
- [ ] Transaction history preserved

**Error Scenarios:**
- [ ] Payment timeout shows error message
- [ ] Network failure handled gracefully
- [ ] Insufficient funds simulation handled
- [ ] Invalid card simulation handled
- [ ] Retry option available for failed payments

---

## F. Performance Testing (1 hour)

**App Launch Performance:**
- [ ] Cold start: < 2 seconds
- [ ] Warm start: < 1 second
- [ ] Home screen renders smoothly
- [ ] First puzzle loads in < 500ms
- [ ] No splash screen hangs

**Paywall Performance:**
- [ ] Paywall screen loads in < 1 second
- [ ] Pricing updates smoothly
- [ ] No layout jank
- [ ] Animations smooth (60 FPS)

**Purchase Flow Performance:**
- [ ] Payment sheet appears < 500ms
- [ ] Purchase completes < 5 seconds
- [ ] Feature unlock immediate
- [ ] UI responsive throughout

**Game Performance:**
- [ ] Chess board renders smoothly
- [ ] Move animations fluid
- [ ] AI response time < 2 seconds
- [ ] No lag during gameplay

**Memory & Battery:**
- [ ] Memory usage stable over 30 minutes
- [ ] No memory leaks detected
- [ ] Battery drain acceptable
- [ ] CPU usage reasonable
- [ ] Thermal performance normal

**Long-Term Stability:**
- [ ] App stable for 1+ hour of usage
- [ ] No crashes during extended testing
- [ ] Background tasks don't block UI
- [ ] Data persists correctly

---

## G. Security Validation (30 minutes)

**API Key Security:**
- [ ] Firebase API key not exposed in logs
- [ ] RevenueCat key not exposed in logs
- [ ] No debug credentials in release build
- [ ] Secrets not hardcoded

**Payment Data Protection:**
- [ ] Payment data not logged to console
- [ ] Credit card data not stored locally
- [ ] Transaction details encrypted in transit
- [ ] PII not exposed in logs

**Firebase Security Rules:**
- [ ] Unauthenticated users cannot read private data
- [ ] Users cannot access other users' data
- [ ] Write rules enforce ownership
- [ ] Delete rules restrict appropriately

**Authentication Security:**
- [ ] Auth tokens stored securely
- [ ] HTTPS enforced for all API calls
- [ ] Session tokens rotated properly
- [ ] Logout clears all auth data

**Data Privacy:**
- [ ] Personal data not shared externally
- [ ] Analytics data anonymized
- [ ] User can delete account and data
- [ ] GDPR compliance verified (if applicable)

---

## H. Error Handling (30 minutes)

**Network Errors:**
- [ ] Network disconnection shows error
- [ ] Retry mechanism available
- [ ] Graceful degradation for offline mode
- [ ] Error message user-friendly
- [ ] Network recovery automatic when connectivity restored

**Payment Errors:**
- [ ] Payment timeout shows recovery option
- [ ] Insufficient funds shows clear message
- [ ] Invalid card shows retry option
- [ ] RevenueCat timeout handled
- [ ] Error details logged without exposing PII

**Firebase Errors:**
- [ ] Connection loss handled gracefully
- [ ] Firestore errors show user-friendly messages
- [ ] Auth errors trigger re-login
- [ ] Storage errors offer retry
- [ ] Crashlytics captures errors

**Invalid States:**
- [ ] Invalid subscription state handled
- [ ] Corrupted data detected and recovered
- [ ] Version mismatch handled (if applicable)
- [ ] Unknown errors logged for debugging

---

## I. UI/UX Validation (30 minutes)

**Screen Design:**
- [ ] All screens render correctly
- [ ] Layout matches design specifications
- [ ] No text overflow or clipping
- [ ] Consistent padding and spacing
- [ ] Color scheme applied correctly

**Typography:**
- [ ] Font sizes appropriate for readability
- [ ] Line heights comfortable for reading
- [ ] Font weights distinguish hierarchy
- [ ] Different text sizes readable

**Accessibility:**
- [ ] Color contrast meets WCAG AA standards
- [ ] Touch targets at least 44x44 dp
- [ ] Labels attached to form fields
- [ ] Screen reader support (if applicable)

**Dark Mode:**
- [ ] Dark mode activated correctly
- [ ] Colors adjusted appropriately
- [ ] Contrast maintained in dark mode
- [ ] No bright flashes in dark mode
- [ ] Preference persists

**Responsiveness:**
- [ ] Phone layouts (320dp - 600dp width)
- [ ] Tablet layouts (600dp+ width)
- [ ] Landscape orientation
- [ ] Portrait orientation
- [ ] System font size respected

---

## J. Device Testing

### iPhone Testing (iOS 14+)

**Device:** _______________  
**iOS Version:** _______________  
**Screen Size:** _______________

- [ ] All features functional
- [ ] UI renders correctly
- [ ] Touch input responsive
- [ ] Orientation changes smooth
- [ ] App Store features work (Sign in with Apple, In-App Purchase)
- [ ] Notifications functional (if applicable)
- [ ] Performance acceptable

### iPad Testing (Optional but recommended)

**Device:** _______________  
**iPadOS Version:** _______________  
**Screen Size:** _______________

- [ ] Layout adapts to larger screen
- [ ] Touch targets appropriately sized
- [ ] Landscape and portrait work
- [ ] Multitasking compatible
- [ ] Performance stable

### Android Phone Testing (Android 7+)

**Device:** _______________  
**Android Version:** _______________  
**Screen Size:** _______________

- [ ] All features functional
- [ ] Material Design applied
- [ ] Touch input responsive
- [ ] Orientation changes smooth
- [ ] Google Play features work (Sign-in, In-App Billing)
- [ ] System permissions handled
- [ ] Performance acceptable

### Android Tablet Testing (Optional)

**Device:** _______________  
**Android Version:** _______________  
**Screen Size:** _______________

- [ ] Layout adapts to larger screen
- [ ] Touch targets appropriately sized
- [ ] Landscape and portrait work
- [ ] Split-screen compatible
- [ ] Performance stable

---

## Test Results Summary

**Test Execution Date:** _______________  
**Tester Name:** _______________  
**Tester Email:** _______________  
**Build Version:** _______________  
**Build Date:** _______________  

**Devices Tested:**
- [ ] iPhone (iOS 14+): _______________
- [ ] iPad (iPadOS 14+): _______________
- [ ] Android Phone (7+): _______________
- [ ] Android Tablet: _______________

**Total Test Duration:** _____ hours

---

## Overall Assessment

### Pass/Fail Status

**Select One:**
- [ ] **✅ APPROVED** - All tests passed, ready for production deployment
- [ ] **⚠️ CONDITIONAL APPROVAL** - Minor issues found but acceptable for production
- [ ] **❌ HOLD** - Critical issues found, requires fixes before production

---

## Critical Issues Found

(List any blocking issues that prevent production deployment)

| Issue # | Severity | Component | Description | Fix Status |
|---------|----------|-----------|-------------|-----------|
| 1 | [ ] High [ ] Medium [ ] Low | | | [ ] Fixed [ ] Deferred |
| 2 | [ ] High [ ] Medium [ ] Low | | | [ ] Fixed [ ] Deferred |
| 3 | [ ] High [ ] Medium [ ] Low | | | [ ] Fixed [ ] Deferred |

---

## Minor Issues Found

(List non-blocking issues for future improvement)

| Issue # | Component | Description | Priority |
|---------|-----------|-------------|----------|
| 1 | | | [ ] High [ ] Medium [ ] Low |
| 2 | | | [ ] High [ ] Medium [ ] Low |

---

## Performance Metrics

**App Launch Time:** _______ seconds (Target: < 2s)  
**Paywall Load Time:** _______ seconds (Target: < 1s)  
**Purchase Completion:** _______ seconds (Target: < 5s)  
**Memory Usage (peak):** _______ MB  
**CPU Usage (average):** _______ %  
**Battery Impact:** [ ] Acceptable [ ] Minimal [ ] Concerning  

---

## Recommendations

**For Production Deployment:**
1. _____________________________________________________________________
2. _____________________________________________________________________
3. _____________________________________________________________________

**For Future Phases:**
1. _____________________________________________________________________
2. _____________________________________________________________________
3. _____________________________________________________________________

---

## Sign-Off

**Tester:** _________________________ **Date:** ______________

**Test Lead:** _________________________ **Date:** ______________

**Product Manager:** _________________________ **Date:** ______________

---

**Status:** ✅ Approved for Production Deployment | ⏳ Pending Review | ❌ Blocked

---

*This checklist completed as part of Phase G: Production Deployment & Monitoring*  
*Chess Tactics Master - 2026*
