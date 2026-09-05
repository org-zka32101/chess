# Phase G: Staging Deployment & Validation Plan

**Phase:** G (Production Deployment & Monitoring)  
**Status:** 🚀 Ready to Execute  
**Date:** 2026-09-05  
**Estimated Duration:** 5-7 days

---

## Executive Summary

Chess Tactics Master is ready for staging deployment. All phases (A-J) are implemented, the critical dependency blocker is resolved, and comprehensive production deployment documentation is complete. This plan outlines the structured approach to validate the staging environment before production rollout.

**Key Milestones:**
1. ✅ Dependency Resolution (PR #50 merged)
2. ✅ Deployment Documentation (PR #51 merged)
3. ⏳ Staging Environment Setup (this plan)
4. ⏳ E2E Testing & Sign-Off
5. ⏳ Production Build & Submission
6. ⏳ Phased User Rollout

---

## Pre-Staging Checklist

### Code & Documentation Ready ✅
- [x] All phases A-J implemented and tested
- [x] 250+ unit and widget tests
- [x] Security audit completed
- [x] Code analysis and linting passing
- [x] Dependency resolution working (flutter pub get succeeds)
- [x] DEPLOYMENT_READINESS.md created
- [x] PHASE_G_PRODUCTION_DEPLOYMENT.md available
- [x] CLAUDE.md (project guide) updated

### Repository Status ✅
- [x] PR #50 (Dependency Fix) merged to main
- [x] PR #51 (Deployment Documentation) merged to main
- [x] Main branch stable and working
- [x] CI/CD pipeline unblocked

### Development Branch ✅
- [x] Feature branch: `claude/phase-d-stage-3-device-testing-wgxbuo`
- [x] All work integrated
- [x] Ready for staging deployment

---

## Staging Environment Setup

### Phase 1: Firebase Staging Configuration (2-4 hours)

**Location:** `firebase-console.google.com`

**Steps:**

1. **Create Staging Project**
   ```bash
   firebase projects:create chess-staging
   ```

2. **Enable Required Services**
   - ✓ Authentication
     - Email/Password
     - Google Sign-In
     - Apple Sign-In
   - ✓ Firestore Database
   - ✓ Realtime Database
   - ✓ Cloud Storage
   - ✓ Analytics
     - Real-time Dashboard
     - Custom Events
   - ✓ Crashlytics
     - Error Monitoring
     - Crash Reporting
   - ✓ Cloud Functions

3. **Deploy Security Rules & Functions**
   ```bash
   # Run deployment script
   chmod +x deploy_staging_firebase.sh
   ./deploy_staging_firebase.sh
   ```

4. **Configure API Access**
   - API Key restrictions
   - CORS settings
   - OAuth consent screen
   - Test users for authentication

### Phase 2: RevenueCat Sandbox Setup (1-2 hours)

**Location:** `dashboard.revenuecat.com`

**Steps:**

1. **Switch to Sandbox Environment**
   - Access RevenueCat Sandbox App
   - Do NOT use production credentials

2. **Create Test Products**
   ```
   Premium Monthly:        $4.99 (1-month trial)
   Premium Yearly:         $49.90 (14-day trial)
   Premium Lifetime:       $99.99
   Premium Plus Monthly:   $9.99 (1-month trial)
   Premium Plus Yearly:    $99.90 (14-day trial)
   Premium Plus Lifetime:  $199.99
   ```

3. **Retrieve Sandbox Credentials**
   - Sandbox Public SDK Key: `pk_test_xxxxx`
   - Update `.env.staging` with key

4. **Configure Sandbox Payment Methods**
   - Test credit card: 4111-1111-1111-1111
   - Valid expiry: any future date
   - CVV: any 3 digits

5. **Create Test Users**
   - At least 2 test user accounts for purchase testing
   - Document test credentials

### Phase 3: Staging Build Creation (2-3 hours)

**Scripts Ready:**
- `build_staging.sh` - Automated build script
- `.env.staging` - Environment configuration

**Steps:**

1. **Update Environment Configuration**
   ```bash
   # .env.staging - Update with actual values
   ENVIRONMENT=staging
   FIREBASE_PROJECT=chess-staging
   REVENUECAT_KEY=pk_test_xxxxx  # <-- Your actual sandbox key
   DEBUG_MODE=true
   ANALYTICS_DEBUG=true
   ```

2. **Build Staging Releases**
   ```bash
   chmod +x build_staging.sh
   ./build_staging.sh
   ```

   Outputs:
   - Android APK: `build/app/outputs/apk/release/app-release.apk`
   - iOS IPA: `build/ios/iphoneos/Runner.app`

3. **Version Management**
   - Increment version in `pubspec.yaml`
   - Example: `1.0.0+1` → `1.0.1+1` (for staging)
   - Keep production version separate

### Phase 4: Distribution Setup (1-2 hours)

**Android - Firebase App Distribution:**
```bash
firebase appdistribution:distribute \
  build/app/outputs/apk/release/app-release.apk \
  --app=1:xxx:android:xxxx \
  --project=chess-staging \
  --testers-file=testers.txt
```

**iOS - TestFlight:**
- Build archive in Xcode
- Upload via Transporter
- Add internal testers
- Configure review notes
- Expected wait: 1-2 days for processing

**Distribute to Testers:**
- At least 3-5 internal testers
- Mix of iOS and Android devices
- Various screen sizes (phone, tablet)
- Current OS versions (iOS 14+, Android 7+)

---

## E2E Testing Phase (1-2 days)

### Comprehensive Test Coverage

**Using:** `STAGING_E2E_TESTS.md` checklist

**Test Categories:**
1. **Authentication** (30 min)
   - Email signup/login
   - Google/Apple sign-in
   - Session management
   - Logout flow

2. **Subscriptions** (45 min)
   - Paywall display
   - All 6 product purchases
   - Trial functionality
   - Subscription management

3. **Feature Access** (30 min)
   - Free tier restrictions
   - Premium unlocks
   - Premium Plus unlocks
   - Feature gating logic

4. **Analytics** (30 min)
   - Event tracking
   - Real-time dashboard
   - Custom events
   - Revenue tracking

5. **Payment Processing** (30 min)
   - Sandbox transactions
   - Receipt validation
   - Error handling
   - Retry mechanisms

6. **Performance** (1 hour)
   - Launch times < 2 seconds
   - Paywall load < 1 second
   - Purchase flow < 5 seconds
   - Memory stability

7. **Security** (30 min)
   - API key security
   - Payment data protection
   - Firebase rules
   - Auth token handling

8. **Error Handling** (30 min)
   - Network disconnection
   - Payment errors
   - Firebase errors
   - Invalid states

9. **UI/UX** (30 min)
   - Screen rendering
   - Typography
   - Accessibility
   - Dark mode

10. **Device Testing** (1+ hour)
    - iPhone (iOS 14+)
    - iPad (if applicable)
    - Android phones (7+)
    - Android tablets (if applicable)

**Total Testing Time:** 6-8 hours per tester

### Testing Resources

**Testers Needed:** 2-3 minimum
- 1 iOS tester
- 1 Android tester
- 1 cross-platform verification

**Test Devices:**
- iPhone (minimum: iPhone 12+)
- iPad (recommended)
- Android phone (minimum: Android 10+)
- Android tablet (recommended)

**Test Data:**
- Staging Firebase project
- RevenueCat sandbox credentials
- Test email accounts
- Test payment methods

---

## Staging Validation Sign-Off

**Criteria for Production Approval:**

```
Staging Deployment Validation Report
=====================================

[ ] Authentication system working (all methods)
[ ] All subscription tiers functional  
[ ] Feature gating enforced correctly
[ ] Analytics events tracked in Firebase
[ ] Payment processing working in sandbox
[ ] Error handling robust
[ ] Performance acceptable (launch < 2s)
[ ] Security measures verified
[ ] No console errors/warnings
[ ] Device testing passed (multiple devices)

Critical Issues Found: _____ (Target: 0)
Minor Issues Found: _____ (Target: < 3)

Overall Status:
[ ] ✅ APPROVED - Ready for production
[ ] ⚠️ CONDITIONAL - Ready with documented issues
[ ] ❌ HOLD - Additional testing required

Sign-Off: _________________________ Date: _________
```

---

## Post-Staging: Production Build Phase (2-3 days)

### After Staging Sign-Off:

1. **Version Bump**
   ```yaml
   # pubspec.yaml
   version: 1.1.0+2  # Production version
   ```

2. **Production Build**
   ```bash
   flutter build appbundle --release  # Android
   flutter build ios --release         # iOS
   ```

3. **Signing Configuration**
   - Android: Upload keystore configured
   - iOS: Provisioning profiles and certificates
   - Apple Team ID configured
   - Google Play signing key ready

4. **App Store Setup**
   - **Apple App Store Connect:**
     - Create app listing
     - Configure subscription products
     - Upload screenshots
     - Write app description
     - Set privacy policy and terms
     
   - **Google Play Console:**
     - Create app listing
     - Configure subscription products
     - Upload graphics
     - Write description and features
     - Configure store listing details

---

## Phased Rollout Timeline (1 week+)

### After App Store Approval:

**Phase 1: Early Access (Days 1-3)**
- Rollout: 10% of users
- Monitor: Crash rate < 0.5%, Payment success > 99%
- Decision: Expand to 25% if stable

**Phase 2: Beta Rollout (Days 4-6)**
- Rollout: 25% → 50% of users
- Monitor: Stability metrics, conversion rates, support volume
- Decision: Expand to 100% if stable

**Phase 3: Full Rollout (Days 7+)**
- Rollout: 50% → 100% of users
- Monitor: Long-term stability, user feedback, performance

---

## Success Metrics

### Week 1 Goals (Staging + Production Rollout)
- [ ] Reach 10% rollout (Phase 1)
- [ ] No critical issues requiring rollback
- [ ] Crash-free users > 99%
- [ ] Payment success rate > 99%
- [ ] Zero payment data breaches
- [ ] Analytics data quality > 95%

### Month 1 Goals
- [ ] Full rollout (100%)
- [ ] Premium conversion rate > 5%
- [ ] Monthly revenue > $5,000
- [ ] User retention > 40%
- [ ] Support volume manageable

### Quarter 1 Goals
- [ ] Optimize paywall for conversion
- [ ] Reduce churn to < 3%/month
- [ ] Premium Plus adoption > 20%
- [ ] User LTV > $50
- [ ] Quarterly revenue > $50,000

---

## Rollback Procedures

**If Critical Issue Found During Staging:**
1. Document issue
2. Return to code phase
3. Deploy fix
4. Rebuild staging
5. Re-test specific area
6. Proceed with staging sign-off

**If Critical Issue Found During Rollout:**
1. Pause rollout at current percentage
2. Investigate and deploy hotfix
3. Re-test in production (% holdback)
4. Resume phased rollout

**Complete Rollback Scenario:**
1. Pause 100% rollout immediately
2. Revert to previous stable version
3. Investigate root cause
4. Deploy fix to separate version
5. Re-test thoroughly
6. Begin rollout again at 10%

---

## Key Contacts & Resources

### Documentation
- Deployment Guide: `docs/PHASE_G_PRODUCTION_DEPLOYMENT.md`
- This Plan: `STAGING_DEPLOYMENT_PLAN.md`
- E2E Tests: `STAGING_E2E_TESTS.md`
- Status Report: `DEPLOYMENT_READINESS.md`
- Project Guide: `CLAUDE.md`

### Scripts & Configuration
- Build Script: `build_staging.sh`
- Deployment Script: `deploy_staging_firebase.sh`
- Staging Config: `.env.staging`

### External Services
- Firebase Console: https://console.firebase.google.com
- RevenueCat Dashboard: https://dashboard.revenuecat.com
- App Store Connect: https://appstoreconnect.apple.com
- Google Play Console: https://play.google.com/console

### Project Repository
- Repository: org-zka32101/chess
- Main Branch: All phases complete and working
- Staging Branch: `claude/phase-d-stage-3-device-testing-wgxbuo`

---

## Risk Assessment

### Resolved Risks ✅
- **Dependency Resolution** - FIXED (PR #50)
- **CI/CD Blocking** - UNBLOCKED (flutter pub get works)
- **Build Process** - VERIFIED working
- **Code Coverage** - 250+ tests available

### Remaining Considerations ⚠️
- **Third-party Service Uptime** - Monitor RevenueCat & Firebase
- **App Store Review** - Apple review typically 1-2 days
- **Payment Processing** - Monitor transaction success rates
- **Scale Performance** - Monitor under real user load

### Mitigation Strategies
- Monitoring dashboards active
- Phased rollout approach
- Support team on standby
- Incident response procedures documented
- Automatic alerts configured

---

## Next Steps (Immediate Actions)

### Today (2026-09-05):
- [ ] Review this plan
- [ ] Set up Firebase staging project
- [ ] Configure RevenueCat sandbox

### Tomorrow (2026-09-06):
- [ ] Deploy staging builds
- [ ] Distribute to testers
- [ ] Begin E2E testing

### Days 3-4 (2026-09-07 to 2026-09-08):
- [ ] Complete E2E testing
- [ ] Collect test results
- [ ] Obtain staging sign-off

### Days 5-6 (2026-09-09 to 2026-09-10):
- [ ] Create production builds
- [ ] Submit to app stores
- [ ] Prepare marketing materials

### Week 2 (2026-09-12 onwards):
- [ ] Await app store approvals
- [ ] Begin phased rollout
- [ ] Monitor production metrics

---

## Approval & Authorization

**Project Owner:** _________________________ **Date:** __________

**Tech Lead:** _________________________ **Date:** __________

**Product Manager:** _________________________ **Date:** __________

---

**Status:** 🚀 Ready to Begin Staging Deployment  
**Phase G Estimated Completion:** 2026-09-12  
**Production Launch Target:** 2026-09-15

---

Generated with [Claude Code](https://claude.ai/code)  
Chess Tactics Master - Phase G Production Deployment  
2026-09-05
