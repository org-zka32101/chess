# Phase 2: Staging Setup - Execution Tracker

**Project:** Chess Tactics Master  
**Phase:** 2 - Staging Setup  
**Timeline:** 2026-09-06 (Target: Complete by EOD)  
**Duration:** 8-10 hours  
**Owner:** DevOps/Infrastructure Team

---

## 🎯 Phase 2 Objectives

- [ ] **PRIMARY:** Create staging environment for E2E testing
- [ ] **SECONDARY:** Validate staging setup before Phase 3 testing
- [ ] **TERTIARY:** Document any issues or deviations

---

## 📅 Execution Schedule

### Morning Session (2-3 hours)
- [ ] Prerequisites validation (30 min)
- [ ] Firebase staging project creation (1-2 hours)
- [ ] Firestore & Realtime DB setup (30 min)

### Afternoon Session (3-4 hours)
- [ ] RevenueCat sandbox configuration (1-2 hours)
- [ ] Staging builds creation (1.5 hours)
- [ ] Distribution setup (30 min)

### Evening Session (1-2 hours)
- [ ] Pre-testing validation (30 min)
- [ ] Phase 3 handoff preparation (30 min)

---

## 👥 Team Roles & Assignments

| Role | Name | Responsibility | Status |
|------|------|-----------------|--------|
| **DevOps Lead** | [Name] | Firebase setup, Cloud Functions | ⏳ |
| **Payment Lead** | [Name] | RevenueCat sandbox config | ⏳ |
| **Mobile Lead** | [Name] | Build creation, distribution | ⏳ |
| **QA Lead** | [Name] | Pre-testing validation | ⏳ |
| **Release Manager** | [Name] | Coordination, timeline tracking | ⏳ |

---

## 🚀 Execution Steps with Checkpoints

### Step 1: Prerequisites Validation (30 min)

**Owner:** DevOps Lead

**Command:**
```bash
# Run validation script
flutter --version
dart --version
firebase --version
firebase login
```

**Success Criteria:**
- [ ] Flutter 3.24+ installed
- [ ] Dart 3.x installed
- [ ] Firebase CLI installed
- [ ] Firebase account authenticated

**Completion Time:** _____ (Expected: 30 min)  
**Issues Encountered:** (None / describe)  
**Sign-off:** _________________ Date: _____

---

### Step 2: Firebase Staging Project Creation (1-2 hours)

**Owner:** DevOps Lead

**Substeps:**

**2.1 Create Project**
```bash
export PROJECT_ID="chess-staging"
firebase projects:create $PROJECT_ID
firebase use $PROJECT_ID
```

**Success Criteria:**
- [ ] Project "chess-staging" created
- [ ] Project set as default
- [ ] Firebase Console accessible

**Completion Time:** _____ (Expected: 15 min)

---

**2.2 Enable Services (Firebase Console)**

Go to: https://console.firebase.google.com/project/chess-staging

Enable:
- [ ] Authentication (Email, Google, Apple)
- [ ] Firestore Database
- [ ] Realtime Database
- [ ] Cloud Storage
- [ ] Cloud Functions
- [ ] Google Analytics
- [ ] Crashlytics

**Completion Time:** _____ (Expected: 30 min)

---

**2.3 Deploy Firestore Rules**
```bash
firebase deploy --only firestore:rules --project chess-staging
```

**Success Criteria:**
- [ ] Rules deployed successfully
- [ ] No validation errors

**Completion Time:** _____ (Expected: 5 min)

---

**2.4 Deploy Cloud Functions**
```bash
firebase deploy --only functions --project chess-staging
```

**Success Criteria:**
- [ ] All functions deployed
- [ ] No deployment errors

**Completion Time:** _____ (Expected: 5 min)

---

**2.5 Retrieve Firebase Configuration**

From: https://console.firebase.google.com/project/chess-staging/settings/general

Record values:
- [ ] API Key: `_______________________`
- [ ] Auth Domain: `_______________________`
- [ ] Database URL: `_______________________`
- [ ] Project ID: `_______________________`
- [ ] Storage Bucket: `_______________________`

**Completion Time:** _____ (Expected: 10 min)

---

### Step 3: RevenueCat Sandbox Configuration (1-2 hours)

**Owner:** Payment Lead

**3.1 Access Dashboard**

- [ ] Login to https://dashboard.revenuecat.com
- [ ] Navigate to Settings → API Keys
- [ ] Copy Public API Key: `pk_test_______________`

**Completion Time:** _____ (Expected: 5 min)

---

**3.2 Create Test Products**

In RevenueCat Dashboard → Products, create:

- [ ] basic_monthly_test ($2.99/mo)
- [ ] basic_annual_test ($19.99/yr)
- [ ] premium_monthly_test ($4.99/mo)
- [ ] premium_annual_test ($39.99/yr)
- [ ] elite_monthly_test ($9.99/mo)
- [ ] elite_annual_test ($79.99/yr)

**Completion Time:** _____ (Expected: 45 min)

---

**3.3 Create Test Users**

In RevenueCat Dashboard → Test Users:

- [ ] test_user_1@chess.local (7-day free trial)
- [ ] test_user_2@chess.local (7-day free trial)
- [ ] test_user_3@chess.local (7-day free trial)

**Completion Time:** _____ (Expected: 15 min)

---

**3.4 Update Environment**

```bash
# Edit .env.staging with RevenueCat key
export REVENUECAT_KEY="pk_test_xxxxxxxxxxxxx"
```

- [ ] .env.staging updated
- [ ] RevenueCat key verified

**Completion Time:** _____ (Expected: 5 min)

---

### Step 4: Staging Builds Creation (2-3 hours)

**Owner:** Mobile Lead

**4.1 Prepare Environment**
```bash
git checkout claude/phase-d-stage-3-device-testing-wgxbuo
flutter pub get
dart run build_runner build
```

- [ ] Dependencies resolved
- [ ] Code generation complete

**Completion Time:** _____ (Expected: 30 min)

---

**4.2 Build Android APK**
```bash
source .env.staging
flutter build apk --release \
  --dart-define=ENVIRONMENT=$ENVIRONMENT \
  --dart-define=FIREBASE_PROJECT=$FIREBASE_PROJECT \
  --dart-define=REVENUECAT_KEY=$REVENUECAT_KEY
```

- [ ] Build completed successfully
- [ ] APK location: `build/app/outputs/apk/release/app-release.apk`
- [ ] APK size: _________ MB

**Completion Time:** _____ (Expected: 45 min)

---

**4.3 Build iOS IPA**
```bash
flutter build ios --release \
  --dart-define=ENVIRONMENT=$ENVIRONMENT \
  --dart-define=FIREBASE_PROJECT=$FIREBASE_PROJECT \
  --dart-define=REVENUECAT_KEY=$REVENUECAT_KEY

cd build/ios/iphoneos
mkdir -p Payload
cp -r Runner.app Payload/
zip -r Chess.ipa Payload/
```

- [ ] Build completed successfully
- [ ] IPA location: `Chess.ipa`
- [ ] IPA size: _________ MB

**Completion Time:** _____ (Expected: 45 min)

---

### Step 5: Distribution Setup (1-2 hours)

**Owner:** Mobile Lead

**5.1 Android - Google Play Internal Testing**

1. Go to: https://play.google.com/console
2. Create internal testing track
3. Upload `build/app/outputs/apk/release/app-release.apk`
4. Add testers: (list emails)
   - [ ] QA Tester 1: _______________
   - [ ] QA Tester 2: _______________
   - [ ] QA Tester 3: _______________

**Success Criteria:**
- [ ] Internal testing track created
- [ ] APK uploaded
- [ ] Testers invited
- [ ] Install link generated: `_______________________`

**Completion Time:** _____ (Expected: 45 min)

---

**5.2 iOS - TestFlight**

1. Go to: https://appstoreconnect.apple.com
2. Upload `Chess.ipa`
3. Wait for processing (~10-15 min)
4. Add internal testers: (list emails)
   - [ ] QA Tester 1: _______________
   - [ ] QA Tester 2: _______________
   - [ ] QA Tester 3: _______________

**Success Criteria:**
- [ ] IPA uploaded
- [ ] Build processing complete
- [ ] Testers invited
- [ ] TestFlight link generated: `_______________________`

**Completion Time:** _____ (Expected: 30 min)

---

### Step 6: Pre-Testing Validation (30 min)

**Owner:** QA Lead

**6.1 Device Testing**

Install from Google Play/TestFlight on test devices:

**Android Device:**
- [ ] Device: _______________
- [ ] Build installed successfully
- [ ] App launches without crash
- [ ] Firebase connection: ✓ Connected
- [ ] RevenueCat connection: ✓ Loaded

**iOS Device:**
- [ ] Device: _______________
- [ ] App installed successfully
- [ ] App launches without crash
- [ ] Firebase connection: ✓ Connected
- [ ] RevenueCat connection: ✓ Loaded

---

**6.2 Analytics Verification**

Check Firebase Analytics Dashboard:
- [ ] Events received from test devices
- [ ] User sessions tracked
- [ ] No critical errors in logs

---

## 📊 Progress Summary

| Component | Owner | Status | Time | Issues |
|-----------|-------|--------|------|--------|
| Prerequisites | DevOps | ⏳ | / | |
| Firebase Project | DevOps | ⏳ | / | |
| Firebase Services | DevOps | ⏳ | / | |
| Firebase Rules | DevOps | ⏳ | / | |
| Cloud Functions | DevOps | ⏳ | / | |
| RevenueCat Setup | Payment | ⏳ | / | |
| Android Build | Mobile | ⏳ | / | |
| iOS Build | Mobile | ⏳ | / | |
| Distribution | Mobile | ⏳ | / | |
| Validation | QA | ⏳ | / | |

---

## 🚨 Issues Log

### Issue Template

**Issue #1:**
- **Description:** (What went wrong)
- **Component:** (Firebase/RevenueCat/Build/Distribution)
- **Owner:** (Who's handling)
- **Status:** 🔴 Blocked / 🟡 In Progress / ✅ Resolved
- **Resolution:** (How it was fixed)
- **Time Impact:** (Minutes delayed)

---

## ✅ Phase 2 Completion Checklist

- [ ] All prerequisites validated
- [ ] Firebase staging project created & configured
- [ ] Firestore & Realtime DB deployed
- [ ] Cloud Functions deployed
- [ ] RevenueCat sandbox configured (6 products, 3 test users)
- [ ] Android APK built & distributed
- [ ] iOS IPA built & distributed
- [ ] All testers have access
- [ ] Pre-testing validation passed
- [ ] Firebase analytics receiving events
- [ ] No critical issues blocking Phase 3
- [ ] Phase 3 kickoff scheduled

---

## 🎯 Phase 2 Completion Sign-Off

**Overall Status:** ⏳ IN PROGRESS

**Phase 2 Complete Date/Time:** _____________

**Signed by:**
- DevOps Lead: _________________ Date: _____
- Payment Lead: _________________ Date: _____
- Mobile Lead: _________________ Date: _____
- QA Lead: _________________ Date: _____
- Release Manager: _________________ Date: _____

---

## ➡️ Transition to Phase 3

**Phase 3 Start Date:** 2026-09-07  
**Phase 3 Owner:** QA Lead  
**Phase 3 Duration:** 1-2 days

**Phase 3 Materials:**
- STAGING_E2E_TESTS.md (350+ test procedures)
- Test execution environment ready
- All test accounts configured
- Team ready for comprehensive testing

**Handoff Checklist:**
- [ ] Phase 2 complete and signed off
- [ ] QA Lead briefed on Phase 3 procedures
- [ ] Test devices ready with staging app
- [ ] Firebase monitoring configured
- [ ] Support contacts established
- [ ] Issue escalation procedures defined

---

**Document Version:** 1.0  
**Last Updated:** 2026-09-06  
**Status:** Ready for team execution
