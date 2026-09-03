# Phase G Stage 1: Deployment Preparation

**Status**: Ready for Execution  
**Date**: 2026-09-03  
**Duration**: 2-3 days  
**Target**: Production-ready build, verified metadata, all assets prepared

---

## Overview

Phase G Stage 1 focuses on preparing the Chess Tactics Master application for public release. This includes build verification, metadata preparation, asset creation, and compliance checks across both iOS and Android platforms.

**Timeline**: Day 1-3 of Phase G  
**Success Criteria**: Both iOS and Android builds ready, all metadata verified, launch day checklist complete

---

## 1. Pre-Deployment Verification

### 1.1 Final Code Review & Testing

**Critical Checks**:
```bash
# Run all tests
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html

# Verify no console errors/warnings
flutter analyze lib/

# Format check
dart format lib/ --line-length=120

# Performance baseline
flutter run --profile
```

**Requirements**:
- [ ] Unit test coverage: >70%
- [ ] Widget tests: All critical flows passing
- [ ] Integration tests: No failures
- [ ] Dart analysis: Zero errors, <10 warnings
- [ ] Code coverage: Report generated and reviewed

**Device Testing Matrix Verification**:
```
iOS Devices:
  ✓ iPhone SE (latest)
  ✓ iPhone 12
  ✓ iPhone 13 Pro
  ✓ iPhone 14 Pro Max
  ✓ iPad (latest)

Android Devices:
  ✓ Motorola G30 (Android 11)
  ✓ Samsung Galaxy S21 (Android 12)
  ✓ OnePlus 9 (Android 13)
  ✓ Google Pixel 4a (Android 13)
  ✓ Samsung Galaxy Tab S7 (Android 12)
```

### 1.2 Firebase Production Configuration

**Verify Firebase Setup**:
```bash
# Check firebase_options.dart
grep -E "projectId|apiKey|authDomain" lib/firebase_options.dart

# Verify Firebase CLI connection
firebase projects:list

# Check Firestore rules
firebase firestore:get-rules --project=yourwish-chess
```

**Required Services Enabled**:
- [ ] Firebase Authentication (Email, Google, Apple)
- [ ] Firestore Database (with security rules)
- [ ] Realtime Database (for multiplayer sync)
- [ ] Firebase Storage (for user data exports)
- [ ] Firebase Analytics (with tracking enabled)
- [ ] Firebase Crashlytics (for error monitoring)
- [ ] Cloud Functions (for backend logic)
- [ ] App Distribution (for TestFlight/Play Store)

**Security Rules Validation**:
```firestore
// Firestore Rules - Verify these are in place
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users: Own data only
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Games: Participants can read
    match /games/{gameId} {
      allow read, write: if gameId in request.auth.token.games;
    }
    
    // Puzzles: All authenticated users
    match /puzzles/{puzzleId} {
      allow read: if request.auth != null;
    }
  }
}
```

### 1.3 RevenueCat Configuration

**Verify Payment Setup**:
```bash
# Check RevenueCat keys in app
grep -r "REVENUE_CAT_API_KEY\|RevenueCat" lib/

# Test products are configured:
# - Pro subscription ($9.99/month)
# - Elite subscription ($19.99/month)

# Verify test user accounts work
```

**Required Configuration**:
- [ ] App project created in RevenueCat
- [ ] iOS app linked to App Store Connect
- [ ] Android app linked to Google Play
- [ ] Products configured (Pro, Elite)
- [ ] Offerings configured and published
- [ ] Test user accounts created and verified
- [ ] Sandbox testing completed

### 1.4 Analytics & Monitoring

**Firebase Analytics Events Verification**:
```dart
// Verify these events are tracked:
// Engagement Events
- app_start: Launch tracking
- screen_view: Navigation tracking
- user_engagement: Interaction tracking

// Feature Events
- puzzle_completed: Core engagement
- game_started: Multiplayer entry
- game_completed: Match completion

// Revenue Events
- subscription_purchase: Revenue tracking
- subscription_cancel: Churn tracking
- subscription_upgrade: LTV tracking

// Error Events
- app_exception: Error tracking
- network_error: Connectivity issues
- payment_failure: Transaction issues
```

**Crashlytics Configuration**:
- [ ] Crashlytics enabled in iOS (Info.plist)
- [ ] Crashlytics enabled in Android (AndroidManifest.xml)
- [ ] Test crash reporting works: `FirebaseCrashlytics.instance.crash()`
- [ ] Crash symbols uploaded for iOS
- [ ] Proguard rules configured for Android

---

## 2. Build Preparation

### 2.1 iOS Build Configuration

**Xcode Setup**:
```bash
# Update Flutter
flutter upgrade

# Update Xcode
xcode-select --install

# Check iOS target
open ios/Runner.xcworkspace
```

**Configuration Checklist**:
- [ ] iOS Deployment Target: 14.0
- [ ] Minimum iPhone Support: iPhone 6s (A9 chip)
- [ ] Signing Certificate: Valid and uploaded to Apple Developer
- [ ] Provisioning Profile: Active and downloaded
- [ ] Build Identifier: com.yourwish.chess-tactics-master
- [ ] Display Name: "Chess Tactics Master"
- [ ] Version: 1.0.0 (from pubspec.yaml)
- [ ] Build Number: 1

**Pod Dependencies**:
```bash
# Clean and reinstall pods
cd ios
rm -rf Pods Podfile.lock
pod repo update
pod install
cd ..
```

**Build Verification**:
```bash
# Build for release (iPhone)
flutter build ios --release -v

# Expected output:
# - Running Xcode build
# - Signing files with Developer ID
# - Creating IPA archive
# - Build size: ~80-120 MB

# Verify IPA created
ls -lh build/ios/ipa/Runner.ipa
```

**iOS Build Size Targets**:
```
Target Breakdown:
  Total Binary: <120 MB
  Flutter Engine: ~20 MB
  Dart Runtime: ~10 MB
  App Code: ~30 MB
  Assets (images, fonts): ~15 MB
  Framework/libraries: ~45 MB
```

### 2.2 Android Build Configuration

**Gradle Setup**:
```bash
# Update gradle
cd android
./gradlew --version

# Verify build.gradle
grep -E "minSdkVersion|targetSdkVersion|versionCode" app/build.gradle
```

**Configuration Checklist**:
- [ ] minSdkVersion: 24 (Android 7.0)
- [ ] targetSdkVersion: 34 (latest)
- [ ] App ID: com.yourwish.chess_tactics_master
- [ ] App Name: Chess Tactics Master
- [ ] Version: 1.0.0
- [ ] Version Code: 1
- [ ] Signing Key: Valid and secure

**Signing Key Creation** (One-time):
```bash
# Create keystore if not exists
keytool -genkey -v \
  -keystore ~/keystores/chess-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10950 \
  -alias chess-key-alias \
  -storepass [secure-password] \
  -keypass [secure-password]

# Verify keystore
keytool -list -v -keystore ~/keystores/chess-release.jks
```

**Build Verification**:
```bash
# Build app bundle (for Play Store)
flutter build appbundle --release -v

# Expected output:
# - Running Gradle build
# - Signing with release key
# - Creating AAB (App Bundle)
# - Build size: ~50-80 MB

# Verify AAB created
ls -lh build/app/outputs/bundle/release/app-release.aab

# Validate bundle
bundletool validate --bundle-path=build/app/outputs/bundle/release/app-release.aab
```

**Android Build Size Targets**:
```
Total Bundle: <80 MB
  - arm64-v8a: ~25 MB
  - armeabi-v7a: ~20 MB
  - x86_64: ~25 MB
  - Universal resources: ~10 MB
```

### 2.3 Build Artifacts Verification

**iOS Artifacts**:
```bash
# Check IPA contents
cd build/ios/ipa/Runner.ipa
unzip -l Runner.ipa | head -20

# Verify signing
codesign -vv Runner.app

# Check entitlements
codesign -d --entitlements - Runner.app
```

**Android Artifacts**:
```bash
# Inspect app bundle
bundletool inspect-bundle --bundle=build/app/outputs/bundle/release/app-release.aab

# Extract APK for testing
bundletool build-apks \
  --bundle=build/app/outputs/bundle/release/app-release.aab \
  --output=app-test.apks \
  --mode=universal \
  --ks=~/keystores/chess-release.jks \
  --ks-pass=pass:[password]

# Install and test
adb install-multiple app-test.apks
```

---

## 3. Asset Preparation

### 3.1 App Icons

**iOS App Icons**:
```
Required Sizes (generate from 1024x1024 master):
- 1024x1024: App Store (required)
- 180x180: iPhone 6s, 6s Plus, 7, 7 Plus
- 167x167: iPad Pro 12.9" (2nd gen)
- 152x152: iPad (3rd and 4th gen)
- 120x120: iPhone XS, XS Max, 11 Pro
- 87x87: iPad mini 2, iPad mini 3, iPad mini 4
- 80x80: iPad Air (2nd gen)
- 76x76: iPad (3rd and 4th gen)
- 58x58: App Clips (iOS 14+)

Location: ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

**Android App Icons**:
```
Required Sizes (generate from 512x512 master):
- 512x512: Google Play (for listing)
- 192x192: HDPI
- 144x144: XHDPI
- 96x96: XXHDPI
- 72x72: LDPI
- 48x48: MDPI

Location: android/app/src/main/res/mipmap-*
```

**Icon Generation Tools**:
```bash
# Using Flutter Icons
flutter pub global activate flutter_launcher_icons

# Create flutter_launcher_icons.yaml
cat > flutter_launcher_icons.yaml << EOF
flutter_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icon/app_icon_1024.png"
  adaptive_icon_background: "#1f1f1f"
  adaptive_icon_foreground: "assets/icon/app_icon_adaptive.png"
EOF

# Generate icons
flutter pub global run flutter_launcher_icons
```

### 3.2 Screenshots

**iOS Screenshots** (Required for each device):
```
Dimensions: 1242x2688 (6.5" device)
Recommended: 6 screenshots

Screenshot Sequence:
1. Home Screen - "Learn Chess Through Tactics"
   - Show: Dashboard, 5 available puzzles
   
2. Puzzle Solving - "Master Positions"
   - Show: Board, puzzle interface, solution
   
3. Multiplayer Queue - "Challenge Players Worldwide"
   - Show: Queue, opponent selection, rating
   
4. Game Play - "Real-Time Battles"
   - Show: Live game, timer, chat
   
5. Leaderboards - "Climb the Ranks"
   - Show: Global leaderboard, user stats
   
6. Premium Features - "Unlock Pro Benefits"
   - Show: Subscription screen, features list
```

**Android Screenshots** (Required for each device):
```
Dimensions: 1080x1920 (5.5" phone)
Recommended: 4-8 screenshots

Same sequence as iOS, optimized for 1080x1920
```

**Screenshot Tips**:
- [ ] Use real device or emulator
- [ ] Disable notifications/status bar
- [ ] Use consistent branding colors
- [ ] Include app name and tagline
- [ ] Show key features clearly
- [ ] Use high contrast text
- [ ] Dimensions exact (no padding)

### 3.3 Preview Images

**Feature Graphic** (Android Play Store):
```
Dimensions: 1024x500
Format: PNG or JPEG

Content:
- App icon (left side)
- App name: "Chess Tactics Master"
- Tagline: "Learn Chess Through Puzzles"
- Key features (right side):
  • 1000+ Puzzles
  • Real-Time Multiplayer
  • ELO Rating System
  • Offline Mode
```

**iPad Screenshots** (Optional for iOS):
```
Dimensions: 2048x2732 (12.9" iPad)
Recommended: 6 screenshots

Same content as iPhone but:
- Landscape orientation
- Larger text
- Showcase iPad-specific features
```

---

## 4. Metadata Preparation

### 4.1 App Store Metadata

**App Information**:
```
App Name: Chess Tactics Master
Subtitle: Learn Chess Through Puzzles
Primary Category: Games
Secondary Category: Puzzle

Keywords (100 chars max):
chess,tactics,puzzles,multiplayer,online,strategy,learning,games

Description (4000 chars max):
Master the art of chess with Chess Tactics Master – the ultimate app for learning chess through challenging puzzles and real-time multiplayer battles.

FEATURES:
🎯 1000+ Chess Puzzles
Solve puzzles from beginner to advanced levels, improving your tactical vision and decision-making skills.

🌍 Multiplayer Online
Challenge players worldwide in real-time matches. Test your skills against players of all levels and climb the global leaderboard.

📊 ELO Rating System
Track your progress with our accurate ELO rating system. See how you stack up against grandmasters and rising stars.

🏆 Leaderboards & Achievements
Compete for top spots on the global leaderboard. Earn badges and achievements as you progress.

🎮 Offline Mode
Practice puzzles offline – perfect for gaming on the go without an internet connection.

🌙 Dark Mode
Play comfortably anytime with our elegant dark theme option.

SUBSCRIPTION:
Premium (Pro) - $9.99/month
- Unlimited daily puzzles (50+ daily)
- Advanced game analysis
- Priority multiplayer matchmaking

Elite - $19.99/month
- Everything in Pro, plus:
- Exclusive coaching features
- Tournament access
- Premium support

Free tier includes 30 daily puzzles and basic features.

SUPPORT:
Have questions or need help? Visit: support.chessmaster.app
Privacy Policy: https://chessmaster.app/privacy
Terms of Service: https://chessmaster.app/terms

Download Chess Tactics Master today and become a chess master!
```

**Support & Policies**:
```
Support URL: https://support.chessmaster.app
Privacy Policy URL: https://chessmaster.app/privacy
Terms of Service: https://chessmaster.app/terms
Support Email: support@chessmaster.app
```

### 4.2 Google Play Metadata

**Store Listing**:
```
Title (50 chars max):
Chess Tactics Master

Short Description (80 chars):
Master chess through 1000+ puzzles and multiplayer battles

Full Description (4000 chars max):
[Same as iOS description above]

Category: Games > Puzzle
Content Rating: 3+ (PEGI)
Target Audience: Gamers, Chess Players, Strategy Game Enthusiasts
```

**Privacy & Compliance**:
```
Privacy Policy URL: https://chessmaster.app/privacy
Support Email: support@chessmaster.app

Data Safety Form:
- Internet: Required for online features
- User identifiable data: Email, user ID
- Sensitive data: None
- Data collection: Analytics, gameplay statistics
- User control: Can delete account anytime
```

---

## 5. Compliance & Legal

### 5.1 Privacy Policy Review

**Required Sections**:
- [ ] Data Collection: What data is collected
- [ ] Data Usage: How data is used
- [ ] Data Sharing: Third-party sharing
- [ ] Data Retention: How long data is kept
- [ ] User Rights: Access, deletion, export
- [ ] Cookies & Tracking: Analytics, ads
- [ ] Children's Privacy: COPPA compliance
- [ ] Contact Information: Support channels

**Sample Privacy Policy Structure**:
```markdown
# Privacy Policy - Chess Tactics Master

## 1. Information We Collect
- Account information (email, username)
- Gameplay data (ratings, match history)
- Device information (OS, device model)
- Analytics (features used, session duration)
- Crash reports and error logs

## 2. How We Use Your Information
- Provide and improve services
- Personalization and analytics
- Customer support
- Marketing (with consent)
- Legal compliance

## 3. Third-Party Services
- Firebase (analytics, authentication, storage)
- RevenueCat (subscription management)
- Crashlytics (error monitoring)

## 4. Your Rights
- Access your data: account settings
- Export your data: support@chessmaster.app
- Delete your account: settings → delete account
- Opt-out of analytics: settings → privacy

## 5. Updates to Policy
We may update this policy. Continued use indicates acceptance.

## 6. Contact Us
support@chessmaster.app
```

### 5.2 Terms of Service Review

**Required Sections**:
- [ ] Service Description
- [ ] User Responsibilities
- [ ] Acceptable Use Policy
- [ ] Intellectual Property
- [ ] Disclaimer of Warranties
- [ ] Limitation of Liability
- [ ] Termination Rights
- [ ] Dispute Resolution
- [ ] Contact Information

### 5.3 Content Rating Questionnaire

**iOS App Store (IARC)**:
```
Questionnaire covers:
✓ Violence: None
✓ Alcohol/Tobacco: None
✓ Gambling: No real money gambling
✓ Profanity: None
✓ Sexual Content: None
✓ Medical Information: None
✓ Horror: None
✓ Unrestricted Web Access: None

Result: 4+ PEGI / 4+ USK / 4+ ClassInd
```

**Android (ESRB/PEGI)**:
```
Content Rating Questionnaire:
- Violence: None
- Language: None
- Sexual Content: None
- Alcohol/Tobacco: None
- Gambling: None (note: in-app subscription, not gambling)

Result: Everyone / PEGI 3+
```

---

## 6. Pre-Launch Checklist

### 6.1 iOS Checklist

**Build & Archive**:
- [ ] Flutter clean + pub get completed
- [ ] Dart build_runner executed
- [ ] iOS build successful
- [ ] App size verified (<200MB)
- [ ] Signing certificate valid
- [ ] IPA archived and exported

**Metadata & Assets**:
- [ ] App name: "Chess Tactics Master"
- [ ] Keywords entered correctly
- [ ] Description complete and accurate
- [ ] Screenshots (6) uploaded for 6.5" device
- [ ] App icon 1024x1024 uploaded
- [ ] Privacy policy URL set
- [ ] Support URL set
- [ ] Demo account configured (for testing)

**Configuration**:
- [ ] Deployment target: 14.0
- [ ] Supported devices: iPhone only
- [ ] Orientations: Portrait + Landscape
- [ ] Dark mode: Enabled
- [ ] Accessibility: VoiceOver tested
- [ ] Analytics: Firebase enabled
- [ ] Crashlytics: Enabled

**Compliance**:
- [ ] Content rating questionnaire completed
- [ ] Age restrictions reviewed (4+)
- [ ] Privacy policy published
- [ ] Terms of service available
- [ ] GDPR compliance verified

### 6.2 Android Checklist

**Build & Bundle**:
- [ ] Flutter clean + pub get completed
- [ ] Dart build_runner executed
- [ ] Android build successful
- [ ] App bundle (AAB) created
- [ ] Bundle size verified (<80MB)
- [ ] Bundle validated with bundletool
- [ ] Signing key valid and secure

**Metadata & Assets**:
- [ ] Title: "Chess Tactics Master"
- [ ] Short description entered
- [ ] Full description complete
- [ ] Screenshots (4-8) uploaded for 5.5" device
- [ ] Feature graphic (1024x500) uploaded
- [ ] App icon 512x512 uploaded
- [ ] Privacy policy URL set
- [ ] Support email configured

**Configuration**:
- [ ] minSdkVersion: 24
- [ ] targetSdkVersion: 34
- [ ] App ID: com.yourwish.chess_tactics_master
- [ ] Version code: 1
- [ ] Version name: 1.0.0
- [ ] Permissions: Justified and minimal
- [ ] Firebase enabled
- [ ] Crashlytics enabled
- [ ] Analytics configured

**Compliance**:
- [ ] Content rating questionnaire completed
- [ ] Privacy policy URL correct
- [ ] Data safety form completed
- [ ] Support email active
- [ ] Terms of service available

### 6.3 Launch Day Checklist

**24 Hours Before**:
- [ ] Final build created on both platforms
- [ ] All assets uploaded to stores
- [ ] Metadata reviewed by team
- [ ] Support email monitored
- [ ] Team on-call list confirmed
- [ ] Monitoring dashboards accessible
- [ ] Release notes final

**2 Hours Before**:
- [ ] Store submissions queued (do not submit yet)
- [ ] Team gathered for launch
- [ ] Monitoring tools open and tested
- [ ] Firebase dashboards refreshed
- [ ] Crashlytics dashboard online
- [ ] Analytics events logging

**At Launch Time**:
- [ ] Submit to iOS App Store
- [ ] Submit to Google Play
- [ ] Record submission times
- [ ] Monitor for upload completion
- [ ] Monitor dashboard for first users
- [ ] Check app appears in stores (may take 1-2 hours)

---

## 7. Sign-Off

**Deployment Preparation Complete**:
- [ ] All builds verified and tested
- [ ] Metadata complete and accurate
- [ ] Assets prepared and uploaded
- [ ] Compliance checklist done
- [ ] Legal documents reviewed
- [ ] Team ready for launch
- [ ] Monitoring configured

**Ready to Proceed**: Phase G Stage 2 (Store Submission)

---

**Document Version**: 1.0  
**Last Updated**: 2026-09-03  
**Phase**: G Stage 1 (Deployment Preparation)  
**Status**: Ready for Implementation
