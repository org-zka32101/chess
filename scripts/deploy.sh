#!/bin/bash

# Chess Tactics Master Deployment Script
# Builds and submits the app to both iOS App Store and Android Google Play
# Usage: ./scripts/deploy.sh [version] [build_number] [channel]
# Example: ./scripts/deploy.sh 1.0.0 1 production

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# CONFIGURATION
# ============================================================================

VERSION=${1:-"1.0.0"}
BUILD_NUM=${2:-"1"}
CHANNEL=${3:-"production"}

PROJECT_NAME="Chess Tactics Master"
BUNDLE_ID="com.yourwish.chess"
PACKAGE_NAME="com.yourwish.chess"

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   $PROJECT_NAME - Deployment Script${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Version:      ${GREEN}$VERSION${NC}"
echo -e "Build:        ${GREEN}$BUILD_NUM${NC}"
echo -e "Channel:      ${GREEN}$CHANNEL${NC}"
echo ""

# ============================================================================
# PRE-DEPLOYMENT CHECKS
# ============================================================================

echo -e "${YELLOW}[1/8] Running pre-deployment checks...${NC}"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}✗ Flutter is not installed${NC}"
    exit 1
fi

# Check if git is clean
if [ -n "$(git status -s)" ]; then
    echo -e "${RED}✗ Git working directory is not clean${NC}"
    echo "Please commit or stash all changes before deploying"
    exit 1
fi

echo -e "${GREEN}✓ Pre-deployment checks passed${NC}"
echo ""

# ============================================================================
# UPDATE VERSION INFORMATION
# ============================================================================

echo -e "${YELLOW}[2/8] Updating version information...${NC}"

# Update deployment_config.dart
sed -i.bak "s/static const String appVersion = '[^']*'/static const String appVersion = '$VERSION'/" \
    lib/src/config/deployment_config.dart
sed -i.bak "s/static const int buildNumber = [0-9]*/static const int buildNumber = $BUILD_NUM/" \
    lib/src/config/deployment_config.dart

# Update pubspec.yaml
sed -i.bak "s/^version: .*/version: $VERSION+$BUILD_NUM/" pubspec.yaml

# Update iOS
sed -i.bak "s/FLUTTER_BUILD_NUMBER=.*/FLUTTER_BUILD_NUMBER=$BUILD_NUM/" \
    ios/Flutter/Flutter.xcconfig
sed -i.bak "s/FLUTTER_BUILD_NAME=.*/FLUTTER_BUILD_NAME=$VERSION/" \
    ios/Flutter/Flutter.xcconfig

# Update Android
sed -i.bak "s/versionCode [0-9]*/versionCode $BUILD_NUM/" \
    android/app/build.gradle
sed -i.bak "s/versionName '[^']*'/versionName \"$VERSION\"/" \
    android/app/build.gradle

# Clean up backup files
find . -name "*.bak" -delete

echo -e "${GREEN}✓ Version updated to $VERSION+$BUILD_NUM${NC}"
echo ""

# ============================================================================
# BUILD PREPARATION
# ============================================================================

echo -e "${YELLOW}[3/8] Preparing build environment...${NC}"

flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs

echo -e "${GREEN}✓ Build environment ready${NC}"
echo ""

# ============================================================================
# BUILD iOS APP
# ============================================================================

echo -e "${YELLOW}[4/8] Building iOS app...${NC}"

cd ios

# Create archive
echo "Creating Xcode archive..."
xcodebuild -workspace Runner.xcworkspace \
    -scheme Runner \
    -configuration Release \
    -derivedDataPath build \
    -archivePath "build/Runner-$VERSION.xcarchive" \
    archive

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ iOS archive created successfully${NC}"
else
    echo -e "${RED}✗ iOS build failed${NC}"
    exit 1
fi

# Validate archive
echo "Validating iOS archive..."
xcodebuild -validateArchive \
    -archivePath "build/Runner-$VERSION.xcarchive" \
    -scheme Runner

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ iOS archive validated${NC}"
else
    echo -e "${RED}✗ iOS archive validation failed${NC}"
    exit 1
fi

cd ..
echo ""

# ============================================================================
# BUILD ANDROID APP
# ============================================================================

echo -e "${YELLOW}[5/8] Building Android app...${NC}"

echo "Creating Android App Bundle..."
flutter build appbundle \
    --release \
    -t lib/main.dart \
    --build-number=$BUILD_NUM

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Android app bundle created successfully${NC}"
else
    echo -e "${RED}✗ Android build failed${NC}"
    exit 1
fi

echo ""

# ============================================================================
# COMMIT VERSION BUMP
# ============================================================================

echo -e "${YELLOW}[6/8] Committing version changes...${NC}"

git add -A
git commit -m "chore: Bump version to $VERSION+$BUILD_NUM"
git tag -a "v$VERSION+$BUILD_NUM" -m "Release version $VERSION (build $BUILD_NUM)"

echo -e "${GREEN}✓ Version committed and tagged${NC}"
echo ""

# ============================================================================
# DEPLOYMENT INSTRUCTIONS
# ============================================================================

echo -e "${YELLOW}[7/8] Generating deployment instructions...${NC}"

cat > DEPLOYMENT_STEPS_$VERSION.txt << EOF
╔════════════════════════════════════════════════════════════════════════════╗
║                    Deployment Instructions - v$VERSION                      ║
║                      Build #$BUILD_NUM - $CHANNEL Channel                        ║
╚════════════════════════════════════════════════════════════════════════════╝

📱 iOS App Store Submission
────────────────────────────
1. Open Xcode Organizer:
   Xcode → Window → Organizer

2. Select Archive:
   - Choose "Runner-$VERSION.xcarchive"

3. Click "Distribute App"
   - Select "App Store Connect"
   - Select "Upload"
   - Choose "Automatically manage signing"
   - Select appropriate certificates

4. App Store Connect Review:
   - Navigate to: https://appstoreconnect.apple.com
   - Build should appear within 5 minutes
   - Select build for TestFlight testing
   - Complete metadata if not already done
   - Submit for review

5. Review Timeline:
   - Average: 24-48 hours
   - Check status in App Store Connect

🤖 Android Google Play Submission
──────────────────────────────────
1. Upload to Google Play Console:
   - Navigate to: https://play.google.com/console
   - Select app: $PACKAGE_NAME
   - Left menu → Release → Production
   - Click "Create new release"
   - Upload: build/app/outputs/bundle/release/app-release.aab

2. Complete Release Details:
   - Add release notes (see RELEASE_NOTES_$VERSION.md)
   - Review all app details
   - Add screenshots if not already done

3. Review Settings:
   - Recommended: Use Staged Rollout
   - Start with 5% rollout
   - Monitor for 24 hours
   - Escalate based on metrics

4. Submit:
   - Click "Review" to validate
   - Click "Confirm rollout"
   - Release submitted

5. Review Timeline:
   - Average: 2-3 hours for first release
   - Faster for updates

📊 Post-Launch Monitoring
──────────────────────────
1. Dashboard Setup:
   - Firebase Console: https://console.firebase.google.com
   - Monitor: Stability → Crashes
   - Monitor: Analytics → Realtime

2. Daily Checklist (First 7 days):
   ☐ Crash rate < 0.5%
   ☐ App rating >= 3.5 stars
   ☐ User feedback reviewed
   ☐ Critical issues documented
   ☐ Support emails responded to

3. Escalation (if needed):
   ☐ Crash rate > 1%: Prepare hotfix
   ☐ Rating < 3.0: Emergency response required
   ☐ Negative reviews: Community engagement

4. Key Metrics to Track:
   - Crashes: ${YELLOW}< 0.1%${NC}
   - Rating: ${YELLOW}>= 4.0 stars${NC}
   - DAU: Baseline + tracking
   - Session Length: Target 5+ minutes
   - Retention D1: Target >40%

✅ Deployment Checklist
───────────────────────
☐ Both builds created successfully
☐ Version committed to git
☐ Git tags pushed: git push origin --tags
☐ iOS build uploaded to App Store Connect
☐ Android build uploaded to Google Play
☐ Release notes reviewed and published
☐ Monitoring dashboards configured
☐ Support team briefed
☐ Social media ready to announce
☐ On-call coverage confirmed

📝 Important Notes
──────────────────
- Keep this file for reference during deployment
- Don't close this script output until deployment complete
- Deployment is now automated - follow the steps above
- For emergency rollback: Contact Apple/Google support

🚀 Next Steps
──────────────
1. Execute iOS submission (Manual in Xcode)
2. Execute Android submission (Manual in Google Play Console)
3. Monitor metrics in Firebase dashboard
4. Announce release on social media
5. Send support team alert

═════════════════════════════════════════════════════════════════════════════
Deployment Script: $(date)
═════════════════════════════════════════════════════════════════════════════
EOF

echo -e "${GREEN}✓ Deployment instructions generated${NC}"
echo -e "   File: ${BLUE}DEPLOYMENT_STEPS_$VERSION.txt${NC}"
echo ""

# ============================================================================
# COMPLETION
# ============================================================================

echo -e "${YELLOW}[8/8] Deployment preparation complete!${NC}"
echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}   Deployment Ready!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo "📦 Build Artifacts:"
echo -e "   iOS:     ${BLUE}ios/build/Runner-$VERSION.xcarchive${NC}"
echo -e "   Android: ${BLUE}build/app/outputs/bundle/release/app-release.aab${NC}"
echo ""
echo "📋 Version Information:"
echo -e "   Version:     ${GREEN}$VERSION${NC}"
echo -e "   Build:       ${GREEN}$BUILD_NUM${NC}"
echo -e "   Channel:     ${GREEN}$CHANNEL${NC}"
echo -e "   Git Tag:     ${BLUE}v$VERSION+$BUILD_NUM${NC}"
echo ""
echo "📊 Monitoring:"
echo -e "   Firebase: ${BLUE}https://console.firebase.google.com${NC}"
echo -e "   App Store: ${BLUE}https://appstoreconnect.apple.com${NC}"
echo -e "   Google Play: ${BLUE}https://play.google.com/console${NC}"
echo ""
echo "📖 Next: Review DEPLOYMENT_STEPS_$VERSION.txt and follow manual steps"
echo ""
