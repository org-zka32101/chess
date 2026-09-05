#!/bin/bash
#
# Chess Tactics Master - Staging Deployment Setup Script
# Phase G: Staging Environment Configuration & Build
#
# This script automates the setup of the staging environment including:
# - Firebase staging project configuration
# - Environment file setup
# - Staging build creation
# - Deployment artifacts preparation
#

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Chess Tactics Master - Staging Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Step 1: Verify prerequisites
echo -e "${YELLOW}[1/5] Verifying prerequisites...${NC}"
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter not found${NC}"
    exit 1
fi
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}❌ Firebase CLI not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Flutter and Firebase CLI installed${NC}"
echo ""

# Step 2: Create staging environment file
echo -e "${YELLOW}[2/5] Setting up staging environment configuration...${NC}"
cat > .env.staging << 'EOF'
# Chess Tactics Master - Staging Environment
ENVIRONMENT=staging
FIREBASE_PROJECT=chess-staging
REVENUECAT_KEY=pk_test_xxxxx
DEBUG_MODE=true
ANALYTICS_DEBUG=true
EOF

echo -e "${GREEN}✓ Created .env.staging${NC}"
echo "  Location: ./.env.staging"
echo "  Note: Update REVENUECAT_KEY with actual sandbox key from dashboard"
echo ""

# Step 3: Create staging build script
echo -e "${YELLOW}[3/5] Creating staging build script...${NC}"
cat > build_staging.sh << 'EOF'
#!/bin/bash
# Staging Build Script

STAGING_ENV=.env.staging

echo "Loading staging environment from $STAGING_ENV"
source $STAGING_ENV

echo "Building Android staging release..."
flutter build apk \
  --release \
  --dart-define=ENVIRONMENT=$ENVIRONMENT \
  --dart-define=FIREBASE_PROJECT=$FIREBASE_PROJECT \
  --dart-define=REVENUECAT_KEY=$REVENUECAT_KEY

echo "Building iOS staging release..."
flutter build ios \
  --release \
  --dart-define=ENVIRONMENT=$ENVIRONMENT \
  --dart-define=FIREBASE_PROJECT=$FIREBASE_PROJECT \
  --dart-define=REVENUECAT_KEY=$REVENUECAT_KEY

echo "Staging builds complete!"
echo "  Android: build/app/outputs/apk/release/app-release.apk"
echo "  iOS: build/ios/iphoneos/Runner.app"
EOF

chmod +x build_staging.sh
echo -e "${GREEN}✓ Created build_staging.sh${NC}"
echo ""

# Step 4: Create Firebase staging deployment script
echo -e "${YELLOW}[4/5] Creating Firebase staging deployment script...${NC}"
cat > deploy_staging_firebase.sh << 'EOF'
#!/bin/bash
# Firebase Staging Deployment Script

PROJECT_ID="chess-staging"

echo "Deploying to Firebase staging project: $PROJECT_ID"
echo ""

# Create project if needed
echo "1. Creating Firebase project (if needed)..."
firebase projects:create $PROJECT_ID --quiet || true

echo "2. Deploying Firestore security rules..."
firebase deploy --only firestore:rules --project $PROJECT_ID

echo "3. Deploying Cloud Functions..."
firebase deploy --only functions --project $PROJECT_ID

echo "4. Configuring Firebase services..."
echo "   Note: Manually enable in Firebase Console:"
echo "   - Authentication (Email, Google, Apple)"
echo "   - Firestore Database"
echo "   - Realtime Database"
echo "   - Cloud Storage"
echo "   - Analytics"
echo "   - Crashlytics"

echo ""
echo "Firebase staging deployment complete!"
echo "Next: Configure .env.staging with actual Revenuecat key"
EOF

chmod +x deploy_staging_firebase.sh
echo -e "${GREEN}✓ Created deploy_staging_firebase.sh${NC}"
echo ""

# Step 5: Create E2E testing checklist
echo -e "${YELLOW}[5/5] Creating E2E testing checklist...${NC}"
cat > STAGING_E2E_TESTS.md << 'EOF'
# Chess Tactics Master - Staging E2E Testing Checklist

## Pre-Testing Preparation
- [ ] Staging Firebase project created and configured
- [ ] RevenueCat sandbox environment set up with test products
- [ ] Staging APK/IPA built and deployed to Firebase App Distribution & TestFlight
- [ ] Test users created in Firebase Auth (staging)
- [ ] Test credit cards configured in RevenueCat sandbox

## A. Authentication Flow
- [ ] Email signup with new account
- [ ] Email login with existing account
- [ ] Google sign-in
- [ ] Apple sign-in
- [ ] Session persistence (restart app, session maintained)
- [ ] Logout and re-login
- [ ] Password reset flow
- [ ] Account deletion (if applicable)

## B. Subscription Flow (RevenueCat Sandbox)
- [ ] Paywall screen displays all subscription tiers
- [ ] Premium Monthly purchase completes
- [ ] Premium Plus Yearly purchase completes
- [ ] Lifetime subscription purchase completes
- [ ] Restore purchases works for existing subscriptions
- [ ] Cancel subscription from app settings
- [ ] Re-subscribe after cancellation
- [ ] Trial period functionality (if applicable)
- [ ] Promotional offers (if applicable)

## C. Feature Access Verification
- [ ] Free tier users have correct feature restrictions
- [ ] Premium features unlock after purchase
- [ ] Premium Plus features unlock after purchase
- [ ] Feature gating UI updates correctly
- [ ] Paywall reappears for unpaid features
- [ ] Analytics events track feature access

## D. Analytics Validation
- [ ] App launch event tracked in Firebase Console
- [ ] Screen view events tracked
- [ ] Game completion events tracked
- [ ] Lesson view events tracked
- [ ] Purchase events tracked with revenue
- [ ] Custom parameters attached to events
- [ ] Real-time events visible in Firebase Dashboard (5-min lag acceptable)

## E. Payment Processing
- [ ] Sandbox payment processes without real charges
- [ ] Receipt validation succeeds
- [ ] Subscription status updates immediately
- [ ] Multiple purchases tracked correctly
- [ ] Payment failure scenarios handled gracefully
- [ ] Retry mechanisms work correctly

## F. Performance Testing
- [ ] App launch time < 2 seconds
- [ ] Paywall screen load < 1 second
- [ ] Purchase flow completes < 5 seconds
- [ ] No memory leaks (test for 30+ minutes)
- [ ] Smooth animation performance
- [ ] No jank during transitions

## G. Security Validation
- [ ] API keys not exposed in logs
- [ ] Firebase token not exposed in logs
- [ ] Payment data not logged anywhere
- [ ] Firebase security rules enforced
- [ ] Authentication tokens secure (HTTPS only)
- [ ] No sensitive data in device storage
- [ ] Network requests encrypted

## H. Error Handling
- [ ] Network disconnection handled gracefully
- [ ] Payment timeout shows user-friendly error
- [ ] Firebase connection loss handled
- [ ] Invalid subscription state shows recovery option
- [ ] App crashes logged to Crashlytics
- [ ] Error messages non-technical for users

## I. UI/UX Validation
- [ ] All screens render correctly
- [ ] Text sizing appropriate (readability)
- [ ] Colors accessible (contrast ratios)
- [ ] Dark mode functioning properly
- [ ] Responsive layouts (various screen sizes)
- [ ] Touch targets appropriately sized
- [ ] No layout overflow or clipping

## J. Device Testing
- [ ] iPhone (iOS 14+) - Full flow
- [ ] iPad - Full flow
- [ ] Android phone (Android 7+) - Full flow
- [ ] Tablet (Android) - Full flow
- [ ] Landscape orientation handling
- [ ] Portrait orientation handling
- [ ] System font size changes respected

## Test Results Summary

**Date:** _______________
**Tester:** _______________
**Platform:** iPhone [ ] iPad [ ] Android Phone [ ] Android Tablet [ ]
**OS Version:** _______________
**Build Version:** _______________

**Overall Status:**
- [ ] PASS - All tests successful
- [ ] PASS WITH NOTES - Minor issues, acceptable for production
- [ ] HOLD - Blocking issues found, needs fixes

**Critical Issues Found:**
(None = Ready for Production)
1. _______________
2. _______________
3. _______________

**Minor Issues Found:**
1. _______________
2. _______________

**Sign-Off:** _______________  **Date:** _______________
EOF

echo -e "${GREEN}✓ Created STAGING_E2E_TESTS.md${NC}"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Staging Deployment Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Next Steps:"
echo "1. Update .env.staging with RevenueCat sandbox key"
echo "2. Run: ./deploy_staging_firebase.sh"
echo "3. Run: ./build_staging.sh"
echo "4. Deploy builds to Firebase App Distribution & TestFlight"
echo "5. Execute E2E tests using STAGING_E2E_TESTS.md"
echo ""
