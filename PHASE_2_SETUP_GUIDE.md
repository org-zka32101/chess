# Phase 2: Staging Setup - Complete Guide

**Timeline:** 2026-09-06 (8-10 hours)  
**Owner:** DevOps/Infrastructure Team  
**Status:** Ready for execution

---

## Executive Summary

This guide provides step-by-step instructions for setting up the Chess Tactics Master staging environment. Phase 2 prepares all infrastructure for comprehensive E2E testing before production deployment.

**Key Milestones:**
1. ✅ Firebase staging project creation & configuration
2. ✅ RevenueCat sandbox setup & test products
3. ✅ Staging APK/IPA build creation
4. ✅ Distribution to internal testers

---

## Prerequisites & Validation

### Required Tools & Access

```bash
# 1. Verify Flutter installation
flutter --version
# Expected: Flutter 3.24.0 or higher

# 2. Verify Dart installation  
dart --version
# Expected: Dart 3.x

# 3. Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# 4. Verify Firebase CLI
firebase --version

# 5. Verify you're logged in
firebase login
```

### Required Credentials & Accounts

- [ ] **Firebase Admin Account**
  - Email: (your Firebase email)
  - Project: yourwish-chess-staging (will be created)
  - Permissions: Editor or Owner role

- [ ] **RevenueCat Account**
  - Dashboard access: https://dashboard.revenuecat.com
  - API key for sandbox: `pk_test_xxxxx` (from Settings → API Keys)
  - Permissions: Admin role

- [ ] **GitHub Repository Access**
  - Repository: org-zka32101/chess
  - Branch: claude/phase-d-stage-3-device-testing-wgxbuo (deployed)
  - Permissions: Pull access minimum

- [ ] **Apple Developer Account** (for iOS staging)
  - Team ID: (will be configured)
  - Provisioning profiles ready

- [ ] **Google Play Console Account** (for Android staging)
  - Staging track created
  - Internal testing group configured

### Validation Script

Run this before starting:

```bash
#!/bin/bash
set -e

echo "🔍 Validating Phase 2 Prerequisites..."
echo ""

# Check Flutter
if ! flutter --version > /dev/null 2>&1; then
    echo "❌ Flutter not found. Install from https://flutter.dev"
    exit 1
fi
echo "✅ Flutter: $(flutter --version | head -1)"

# Check Dart
if ! dart --version > /dev/null 2>&1; then
    echo "❌ Dart not found. Install with Flutter"
    exit 1
fi
echo "✅ Dart: $(dart --version)"

# Check Firebase CLI
if ! firebase --version > /dev/null 2>&1; then
    echo "⚠️  Firebase CLI not found. Installing..."
    npm install -g firebase-tools
fi
echo "✅ Firebase CLI: $(firebase --version)"

# Check Firebase login
if ! firebase projects:list > /dev/null 2>&1; then
    echo "⚠️  Not logged in to Firebase. Running login..."
    firebase login
fi
echo "✅ Firebase authenticated"

# Check environment files
if [ ! -f ".env.staging" ]; then
    echo "❌ .env.staging not found"
    exit 1
fi
echo "✅ Environment files present"

echo ""
echo "✅ All prerequisites validated!"
echo ""
echo "Next: Follow Phase 2 setup steps below"
```

---

## Phase 2.1: Firebase Staging Project Setup (2-4 hours)

### Step 1: Create Firebase Staging Project

```bash
# Set project ID
export PROJECT_ID="chess-staging"

# Check if project exists
firebase projects:list

# If not listed, create it
firebase projects:create $PROJECT_ID

# Set it as default for this session
firebase use $PROJECT_ID
```

### Step 2: Enable Firebase Services

Go to Firebase Console: https://console.firebase.google.com/project/chess-staging

**Enable these services:**

1. **Authentication**
   - [ ] Email/Password provider
   - [ ] Google Sign-In provider
   - [ ] Apple Sign-In provider
   - User sign-up: Enabled
   - Email verification: Optional (for staging)

2. **Firestore Database**
   - [ ] Create Firestore database
   - Location: us-central1 (or nearest)
   - Mode: Production mode (we'll apply rules)
   - Start with Firestore Security Rules

3. **Realtime Database**
   - [ ] Create Realtime Database
   - Location: us-central1
   - Security rules: Will be deployed

4. **Cloud Storage**
   - [ ] Create storage bucket
   - Location: us-central1
   - Access level: Private (rules will govern)

5. **Cloud Functions**
   - [ ] Enable Cloud Functions API
   - [ ] Enable Cloud Build API
   - [ ] Enable Cloud Logging API
   - Runtime: Node.js 18

6. **Analytics**
   - [ ] Enable Google Analytics
   - Create new analytics property
   - Reporting timezone: UTC

7. **Crashlytics**
   - [ ] Enable Crashlytics
   - (Automatically enabled with Analytics)

### Step 3: Configure Firestore Security Rules

```bash
# Deploy Firestore rules to staging
firebase deploy --only firestore:rules --project $PROJECT_ID
```

Expected output:
```
i  deploying firestore
i  cloud firestore rules updated successfully
✔  Deploy complete!
```

### Step 4: Deploy Cloud Functions

```bash
# Deploy functions to staging
firebase deploy --only functions --project $PROJECT_ID
```

Expected output:
```
i  deploying functions
✔  functions[onUserCreated(region: us-central1)] Successful
✔  functions[... (other functions)] Successful
✔  Deploy complete!
```

### Step 5: Retrieve Firebase Configuration

1. Go to Firebase Project Settings
   - URL: https://console.firebase.google.com/project/chess-staging/settings/general

2. Copy these values:
   ```
   API Key: (from Web SDK setup)
   Auth Domain: chess-staging.firebaseapp.com
   Database URL: https://chess-staging-default-rtdb.firebaseio.com
   Project ID: chess-staging
   Storage Bucket: chess-staging.appspot.com
   Messaging Sender ID: (from Web SDK setup)
   App ID: (from Web SDK setup)
   ```

### Step 6: Update .env.staging

```bash
# Edit .env.staging with Firebase config
cat > .env.staging << 'EOF'
# Staging Environment Configuration

ENVIRONMENT=staging
FIREBASE_PROJECT=chess-staging

# Firebase Configuration (from console)
FIREBASE_API_KEY=YOUR_API_KEY_HERE
FIREBASE_AUTH_DOMAIN=chess-staging.firebaseapp.com
FIREBASE_DATABASE_URL=https://chess-staging-default-rtdb.firebaseio.com
FIREBASE_PROJECT_ID=chess-staging
FIREBASE_STORAGE_BUCKET=chess-staging.appspot.com
FIREBASE_MESSAGING_SENDER_ID=YOUR_SENDER_ID
FIREBASE_APP_ID=YOUR_APP_ID

# RevenueCat Configuration (next section)
REVENUECAT_KEY=pk_test_xxxxx

# Staging Flags
DEBUG_MODE=true
ANALYTICS_DEBUG=true
VERBOSE_LOGGING=true
EOF
```

Verify configuration:
```bash
source .env.staging
echo "✅ Environment loaded: $ENVIRONMENT"
echo "✅ Firebase Project: $FIREBASE_PROJECT"
echo "✅ RevenueCat Key: ${REVENUECAT_KEY:0:10}..."
```

---

## Phase 2.2: RevenueCat Sandbox Configuration (1-2 hours)

### Step 1: Access RevenueCat Dashboard

1. Login: https://dashboard.revenuecat.com
2. Go to Settings → API Keys
3. Copy Public API Key (starts with `pk_test_`)

### Step 2: Create Test Products

In RevenueCat Dashboard → Products:

Create 6 test products:

1. **Basic Monthly**
   - ID: `basic_monthly_test`
   - Name: Basic Monthly (Staging)
   - Type: Subscription (Monthly)
   - Price: $2.99
   - Duration: 1 month

2. **Basic Annual**
   - ID: `basic_annual_test`
   - Name: Basic Annual (Staging)
   - Type: Subscription (Annual)
   - Price: $19.99
   - Duration: 1 year

3. **Premium Monthly**
   - ID: `premium_monthly_test`
   - Name: Premium Monthly (Staging)
   - Type: Subscription (Monthly)
   - Price: $4.99
   - Duration: 1 month

4. **Premium Annual**
   - ID: `premium_annual_test`
   - Name: Premium Annual (Staging)
   - Type: Subscription (Annual)
   - Price: $39.99
   - Duration: 1 year

5. **Elite Monthly**
   - ID: `elite_monthly_test`
   - Name: Elite Monthly (Staging)
   - Type: Subscription (Monthly)
   - Price: $9.99
   - Duration: 1 month

6. **Elite Annual**
   - ID: `elite_annual_test`
   - Name: Elite Annual (Staging)
   - Type: Subscription (Annual)
   - Price: $79.99
   - Duration: 1 year

### Step 3: Configure Test User Access

1. Go to Settings → Test Users
2. Create test accounts for:
   - `test_user_1@chess.local`
   - `test_user_2@chess.local`
   - `test_user_3@chess.local`

3. Grant free trial access:
   - Duration: 7 days
   - Auto-renew: No (for testing)

### Step 4: Sandbox Credentials

In .env.staging, update RevenueCat key:

```bash
# Get from Settings → API Keys
REVENUECAT_KEY=pk_test_xxxxxxxxxxxxx
```

Verify:
```bash
curl -H "Authorization: Bearer pk_test_xxxxxxxxxxxxx" \
  https://api.revenuecat.com/v1/products \
  --data "app_id=chess_staging"
```

Expected: Returns list of products (or empty, which is OK initially)

---

## Phase 2.3: Staging Build Creation (2-3 hours)

### Step 1: Prepare Build Environment

```bash
# Clone/checkout the staging branch
git checkout claude/phase-d-stage-3-device-testing-wgxbuo

# Update dependencies
flutter pub get

# Verify dependency resolution
flutter pub get --offline || flutter pub get

# Generate code
dart run build_runner build
```

Expected output:
```
Running build...
✓ Built ... (sources)
✓ Generated ... (generated files)
```

### Step 2: Build Android Staging APK

```bash
# Source environment
source .env.staging

# Validate environment
echo "Building Android for: $ENVIRONMENT"
echo "Firebase Project: $FIREBASE_PROJECT"

# Build APK
flutter build apk \
  --release \
  --dart-define=ENVIRONMENT=$ENVIRONMENT \
  --dart-define=FIREBASE_PROJECT=$FIREBASE_PROJECT \
  --dart-define=REVENUECAT_KEY=$REVENUECAT_KEY

# Output location
ls -lh build/app/outputs/apk/release/app-release.apk
```

Expected output:
```
✓ Built build/app/outputs/apk/release/app-release.apk (XXX MB)
```

### Step 3: Build iOS Staging IPA

```bash
# Build for iOS
flutter build ios \
  --release \
  --dart-define=ENVIRONMENT=$ENVIRONMENT \
  --dart-define=FIREBASE_PROJECT=$FIREBASE_PROJECT \
  --dart-define=REVENUECAT_KEY=$REVENUECAT_KEY

# Create IPA from Xcode build
cd build/ios/iphoneos
mkdir -p Payload
cp -r Runner.app Payload/
zip -r Chess.ipa Payload/
cp Chess.ipa ../../../

# Verify
ls -lh Chess.ipa
```

Expected output:
```
-rw-r--r-- 1 root root XXX MB  Chess.ipa
```

### Step 4: Verify Builds

```bash
# Check Android APK
file build/app/outputs/apk/release/app-release.apk
# Expected: Zip archive

# Check iOS IPA
file Chess.ipa
# Expected: Zip archive

# Get build info
aapt dump badging build/app/outputs/apk/release/app-release.apk | head -5
```

---

## Phase 2.4: Distribution Setup (1-2 hours)

### Android Internal Testing (Google Play)

1. Go to Google Play Console: https://play.google.com/console

2. Create or select Chess Tactics Master app

3. Navigate to: **Testing** → **Internal testing**

4. Create internal testing track:
   ```
   Name: Staging Testing
   Testers: (add internal team emails)
   Description: Staging build for Phase 2 E2E testing
   ```

5. Upload staging APK:
   - Go to Internal testing track
   - Click "Create release"
   - Upload: `build/app/outputs/apk/release/app-release.apk`
   - Release notes: "Phase 2 Staging - E2E Testing Build"
   - Review and publish

6. Share testing link:
   - Copy internal testing link
   - Share with QA team
   - Testers can install via link

### iOS Internal Testing (TestFlight)

1. Go to App Store Connect: https://appstoreconnect.apple.com

2. Select Chess Tactics Master app

3. Navigate to: **TestFlight** → **Internal Testing**

4. Create build:
   - Connect to Xcode
   - Select Chess.ipa
   - Upload build
   - Build processing time: ~10-15 minutes

5. Add testers:
   - Go to Internal Testing tab
   - Add team members (up to 100)
   - Testers receive email invite

6. Share TestFlight link:
   - Copy invitation link
   - Testers can install via TestFlight app

### Distribution Checklist

- [ ] **Android**
  - [ ] APK uploaded to Google Play internal testing
  - [ ] Testing track created
  - [ ] Testers added and invited
  - [ ] Link shared with QA team
  - [ ] Install confirmed on test device

- [ ] **iOS**
  - [ ] IPA uploaded to TestFlight
  - [ ] Build processing completed
  - [ ] Internal testers added
  - [ ] Invite emails sent
  - [ ] Install confirmed on test device

---

## Phase 2.5: Validation & Handoff

### Pre-Testing Validation

Run these checks before E2E testing begins:

```bash
# 1. Verify app launches
echo "🔍 Launching app on connected device..."
# Manual: Install from Google Play/TestFlight and launch

# 2. Verify Firebase connectivity
echo "🔍 Firebase connection status..."
# Manual: Open app settings, check "Firebase: Connected"

# 3. Verify RevenueCat connectivity
echo "🔍 RevenueCat connection status..."
# Manual: Go to subscriptions, check paywall loads

# 4. Verify Analytics
echo "🔍 Analytics tracking..."
# Manual: Check Firebase Analytics dashboard for test events
```

### Success Criteria - Phase 2

- ✅ Firebase staging project created & deployed
- ✅ Firestore & Realtime DB rules deployed
- ✅ Cloud Functions deployed
- ✅ RevenueCat sandbox configured (6 products, 3 test users)
- ✅ Android APK built & distributed
- ✅ iOS IPA built & distributed
- ✅ All testers have access
- ✅ App launches successfully
- ✅ Firebase connectivity verified
- ✅ RevenueCat connectivity verified
- ✅ Analytics events tracked

### Handoff to Phase 3 (E2E Testing)

When Phase 2 is complete:

1. **QA Team** receives:
   - App installation links (Android + iOS)
   - STAGING_E2E_TESTS.md with 350+ test procedures
   - Firebase Analytics credentials (read-only)
   - Issue tracking template

2. **DevOps Team** receives:
   - Firebase staging project (read-only access)
   - RevenueCat sandbox dashboard access
   - Monitoring dashboards setup
   - Alert thresholds configured

3. **Documentation Update**:
   - Mark Phase 2 complete in LAUNCH_CHECKLIST.md
   - Log time spent per section
   - Document any issues encountered
   - Note any deviations from procedure

---

## Troubleshooting

### Firebase Issues

**Issue:** "Error: Insufficient permissions to access projects"
```bash
# Solution: Login again with full permissions
firebase logout
firebase login --reauth
```

**Issue:** "Cloud Firestore database already exists"
```bash
# Solution: Database already created; update rules only
firebase deploy --only firestore:rules --project $PROJECT_ID
```

**Issue:** "Cloud Functions deployment failed"
```bash
# Solution: Check Cloud Build API is enabled
# Verify in Firebase Console: APIs & Services → Cloud Build
# Retry deployment after API enables (may take 2-3 minutes)
firebase deploy --only functions --project $PROJECT_ID
```

### Build Issues

**Issue:** "flutter pub get" fails with dependency errors
```bash
# Solution: Clean and retry
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

**Issue:** "APK build fails with keystore error"
```bash
# Solution: Generate new debug keystore
rm ~/.android/debug.keystore
flutter build apk --release
```

**Issue:** "IPA build fails with code signing"
```bash
# Solution: Reset provisioning profiles
rm -rf ~/Library/Developer/Xcode/DerivedData
xcode-select --reset
flutter build ios --release
```

### RevenueCat Issues

**Issue:** "Error: Invalid RevenueCat API key"
```bash
# Solution: Verify key format
echo $REVENUECAT_KEY
# Should be: pk_test_xxxxx...

# Get correct key from dashboard
firebase console → Settings → API Keys
```

**Issue:** "RevenueCat products not visible in app"
```bash
# Solution: Wait 5-10 minutes for sync
# Check: Dashboard → Products → check product status
# Verify: app code references correct product IDs
```

---

## Timeline & Accountability

| Component | Estimated Time | Owner | Status |
|-----------|-----------------|-------|--------|
| Prerequisites Validation | 30 min | DevOps | ⏳ |
| Firebase Setup | 2-4 hours | DevOps | ⏳ |
| RevenueCat Config | 1-2 hours | Payment Lead | ⏳ |
| Android Build | 45 min | Mobile Lead | ⏳ |
| iOS Build | 45 min | Mobile Lead | ⏳ |
| Distribution Setup | 1 hour | Mobile Lead | ⏳ |
| Pre-Test Validation | 30 min | QA Lead | ⏳ |
| **Total Phase 2** | **8-10 hours** | Team | ⏳ |

---

## Communication Checklist

- [ ] **Daily Standup** - Report progress on Phase 2 steps
- [ ] **Milestone Updates**:
  - [ ] Firebase setup complete
  - [ ] RevenueCat configured
  - [ ] Builds distributed
  - [ ] Testers ready
- [ ] **Issues Log** - Document any blockers or deviations
- [ ] **Phase 3 Kickoff** - Schedule E2E testing start time

---

## Next: Phase 3 - E2E Testing

When Phase 2 complete, proceed to STAGING_E2E_TESTS.md for comprehensive testing procedures (350+ test points, 1-2 days).

**Phase 3 Start:** 2026-09-07  
**Phase 3 Duration:** 1-2 days  
**Phase 3 Owner:** QA Lead

---

**Generated:** 2026-09-05  
**Status:** Ready for execution  
**Questions?** Check LAUNCH_CHECKLIST.md or STAGING_DEPLOYMENT_PLAN.md
