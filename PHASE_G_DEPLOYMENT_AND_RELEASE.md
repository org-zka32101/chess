# Phase G: Production Deployment & Release

**Status**: Ready for Implementation  
**Timeline**: 3-5 days  
**Goal**: Deploy Chess Tactics Master to App Store and Google Play with full monitoring and update infrastructure

---

## Overview

Phase G transitions the application from production-ready state to public release across iOS and Android platforms. This phase includes platform submission preparation, release coordination, monitoring setup, and post-release management.

---

## 1. Release Planning & Coordination

### 1.1 Version Management

**Current Version**: 1.0.0+1 (from Phase F `release_config.dart`)

**Versioning Strategy**:
- **Major.Minor.Patch** (semantic versioning)
- iOS: CFBundleShortVersionString = "X.Y.Z"
- Android: versionName = "X.Y.Z"
- Build number increments with each release
  - iOS: CFBundleVersion (integer)
  - Android: versionCode (integer)

**Release Cadence**:
- **Hotfixes**: Within 24 hours (critical bugs)
- **Patch Releases**: Weekly (minor fixes, 1.0.1, 1.0.2, etc.)
- **Minor Releases**: Monthly (features, 1.1.0, 1.2.0, etc.)
- **Major Releases**: Quarterly (significant updates, 2.0.0, etc.)

### 1.2 Release Notes Template

```markdown
## Version X.Y.Z - Release Date

### 🎉 New Features
- Feature 1 description
- Feature 2 description

### 🐛 Bug Fixes
- Bug fix 1
- Bug fix 2

### 🚀 Performance Improvements
- Improvement 1
- Improvement 2

### ⚠️ Known Issues
- Issue 1 (workaround if available)

### 📋 Requirements
- iOS 14.0+ / Android API 24+
- Network connection required for online play

### 🙏 Thank You
Thank you for playing Chess Tactics Master!
For support, visit: [support link]
```

---

## 2. iOS App Store Submission

### 2.1 Pre-Submission Checklist

**Build Configuration**:
- [ ] Xcode updated to latest version
- [ ] iOS deployment target: 14.0
- [ ] Architecture: arm64 + arm64e
- [ ] Signing certificate valid and up-to-date
- [ ] Provisioning profile active
- [ ] Device support: iPhone 6s+ (A9 and later)
- [ ] Orientation: Portrait + Landscape

**App Icons & Assets**:
- [ ] App Icon 1024x1024 (required)
- [ ] iPhone app clips icon (iOS 14+)
- [ ] Notarization certificate for macOS distribution
- [ ] Privacy icon (iOS 14.5+)

**App Store Metadata**:
- [ ] App name (up to 30 chars): "Chess Tactics Master"
- [ ] Subtitle (up to 30 chars): "Learn Chess Through Puzzles"
- [ ] Keywords (up to 100 chars): "chess, tactics, puzzles, online, multiplayer"
- [ ] Description (up to 4000 chars): Feature-rich description
- [ ] Support URL: https://support.chessmaster.app
- [ ] Privacy Policy URL: https://chessmaster.app/privacy
- [ ] Category: Games > Puzzle
- [ ] Content Ratings Questionnaire completed

**Screenshots** (Required for each device type):
- iPhone 5.5" / 6.5": 6 screenshots max
- iPad 12.9" / 2nd gen: 6 screenshots max
- Screenshots show key features:
  1. Home/Dashboard
  2. Puzzle solving
  3. Online multiplayer queue
  4. Game in progress
  5. Rating/Leaderboard
  6. Settings/Customization

**App Privacy**:
- [ ] Privacy label generated
- [ ] Data categories identified:
  - User ID: App Functionality
  - Rating/ELO: App Functionality + Analytics
  - Email: Account Management
  - Photos (optional): User Content
- [ ] Tracking enabled disclosed if applicable
- [ ] Privacy policy matches app behavior

### 2.2 Build & Archive

```bash
# Flutter build for iOS
flutter clean
flutter pub get
dart run build_runner build

# Archive for App Store
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -derivedDataPath build \
  -archivePath build/Runner.xcarchive \
  archive

# Validate archive
xcodebuild -validateArchive \
  -archivePath build/Runner.xcarchive \
  -scheme Runner
```

### 2.3 App Store Connect Upload

**Options**:
1. **Xcode Organizer** (GUI):
   - Open Xcode → Window → Organizer
   - Select archive → Distribute App
   - Select "App Store Connect"
   - Choose "Upload"

2. **Transporter** (CLI):
```bash
# Install/update Transporter
xcrun altool --version

# Upload package
xcrun altool --upload-package build/Runner.ipa \
  --type ios \
  --file [path/to/exported.ipa] \
  --username [apple-id] \
  --password [app-specific-password]
```

3. **Fastlane** (Automated):
```bash
# Install fastlane
sudo gem install fastlane

# Setup
cd ios
fastlane init

# Configure lane for App Store upload
# Edit fastlane/Fastfile
fastlane ios release
```

### 2.4 App Store Review Process

**Timeline**: 24-48 hours typically

**Review Focus Areas**:
- Authentication & security
- Data collection & privacy
- Performance & stability
- Content rating compliance
- Crash-free functionality
- Network connectivity handling

**Common Rejection Reasons**:
- Missing privacy policy
- Crashes on launch
- Incomplete metadata
- Performance issues
- Misleading descriptions
- Unimplemented features

**Response Strategy**:
- Check rejection email within 24 hours
- Address all issues methodically
- Resubmit with detailed explanatory notes
- Expedite review if appropriate

### 2.5 Release Strategy

**Options**:
1. **Immediate Release**: Available immediately upon approval
2. **Scheduled Release**: Release at specific date/time
3. **Phased Release**: Gradual rollout (7/14/30 days)

**Recommendation for 1.0.0**:
- Use Phased Release (7 days)
- Monitor crash reports and ratings
- Fix critical issues discovered
- Complete rollout to 100%

---

## 3. Android Google Play Submission

### 3.1 Pre-Submission Checklist

**Build Configuration**:
- [ ] Minimum SDK: API 24 (Android 7.0)
- [ ] Target SDK: API 34 (latest)
- [ ] Architecture: arm64-v8a + armeabi-v7a
- [ ] Signing key created and stored securely
- [ ] Keystore password secure and backed up

**Google Play Console Setup**:
- [ ] Developer account created (one-time $25)
- [ ] App created in Google Play Console
- [ ] App bundle configuration complete
- [ ] Content Rating Questionnaire done
- [ ] Privacy Policy URL set

**App Icons & Assets**:
- [ ] Feature image 1024x500
- [ ] App icon 512x512 (high-res)
- [ ] Screenshots (required):
  - Phone (5.5"): 4-8 screenshots
  - Tablet 7" (optional): 4-8 screenshots
  - Tablet 10" (optional): 4-8 screenshots
- [ ] Screenshots show gameplay, features

**App Metadata**:
- [ ] Title (50 chars max)
- [ ] Short description (80 chars)
- [ ] Full description (4000 chars)
- [ ] Category: Games > Puzzle
- [ ] Content Rating: 3+ (or higher if applicable)
- [ ] Target audience: Gamers, Chess enthusiasts

**Privacy & Compliance**:
- [ ] Privacy policy URL correct
- [ ] Data safety form completed
- [ ] Ad-related disclosures (if applicable)
- [ ] Permissions justified

### 3.2 Build & Sign

```bash
# Flutter build for Android
flutter clean
flutter pub get
dart run build_runner build

# Create keystore (one-time)
keytool -genkey -v \
  -keystore ~/keystores/chess-release.jks \
  -keyalias chess-key-alias \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10950

# Configure signing in android/app/build.gradle
# (Already set up in pubspec.yaml)

# Build app bundle
flutter build appbundle \
  --release \
  -t lib/main.dart

# Verify bundle
bundletool validate \
  --bundle-path=build/app/outputs/bundle/release/app-release.aab

# (Optional) Test bundle on device
bundletool build-apks \
  --bundle=build/app/outputs/bundle/release/app-release.aab \
  --output=app-test.apks \
  --mode=universal \
  --ks=~/keystores/chess-release.jks

adb install-multiple app-test.apks
```

### 3.3 Google Play Console Upload

1. **Navigate** to Google Play Console → [App] → Release
2. **Select Track**:
   - Internal Testing (for QA)
   - Closed Testing (for beta testers)
   - Production (for public release)

3. **Upload Bundle**:
   - Click "Create new release"
   - Upload `app-release.aab`
   - Add release notes
   - Review app details

4. **Release Review**: Google Play typically reviews within 2-3 hours for initial releases, then can be faster for updates

### 3.4 Release Strategy

**Recommendation for 1.0.0**:
- Start in **Closed Testing** (7 days)
  - Invite beta testers
  - Collect feedback
  - Monitor crash metrics
  - Fix critical issues

- Promote to **Production**
  - Use Staged Rollout (5% → 10% → 25% → 50% → 100%)
  - Monitor daily: crashes, ANRs, ratings
  - Fix issues and re-release if needed
  - Complete rollout in 5-7 days

---

## 4. Monitoring & Analytics Setup

### 4.1 Release Monitoring Dashboard

**Key Metrics to Track**:

| Metric | Target | Alert Threshold |
|--------|--------|------------------|
| Crash Rate | <0.1% | >0.5% |
| ANR Rate | <0.05% | >0.1% |
| App Rating | >4.0 stars | <3.5 stars |
| Install Rate | Baseline | N/A |
| Uninstall Rate | <5%/day | >10%/day |
| Session Length | >5 min | <2 min |
| DAU | Baseline | N/A |
| Retention (D7) | >30% | <20% |
| Error Count | 0 | Any increase |

### 4.2 Firebase Setup

```dart
// lib/src/services/monitoring_service.dart

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class MonitoringService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // Release-specific tracking
  Future<void> logReleaseEvent(String eventName, Map<String, dynamic> params) async {
    params['release_version'] = '1.0.0';
    params['platform'] = 'ios'; // or 'android'
    await _analytics.logEvent(
      name: eventName,
      parameters: params,
    );
  }

  // Monitor app startup time
  void trackAppStartup(Duration startupTime) {
    _analytics.logEvent(
      name: 'app_startup',
      parameters: {
        'startup_time_ms': startupTime.inMilliseconds,
        'release_version': '1.0.0',
      },
    );
  }

  // Monitor specific feature performance
  void trackFeatureUsage(String featureName, Duration duration) {
    _analytics.logEvent(
      name: 'feature_usage',
      parameters: {
        'feature_name': featureName,
        'duration_ms': duration.inMilliseconds,
        'release_version': '1.0.0',
      },
    );
  }

  // Crash reporting
  void recordError(dynamic error, StackTrace stackTrace) {
    _crashlytics.recordError(
      error,
      stackTrace,
      reason: 'Uncaught exception',
      fatal: true,
    );
  }

  // Set user properties for segmentation
  void setReleaseUserProperties(String userId, String tier) {
    _analytics.setUserId(userId);
    _analytics.setUserProperty(
      name: 'subscription_tier',
      value: tier,
    );
    _analytics.setUserProperty(
      name: 'release_version',
      value: '1.0.0',
    );
  }
}
```

### 4.3 Real-Time Dashboards

**Firebase Console**:
- Dashboard → Stability (crashes, ANRs)
- Analytics → Realtime (active users)
- Performance → Performance traces

**Custom Dashboards**:
- Google Sheets + Data Studio
- Looker Studio connected to Firestore
- Manual daily reports first 7 days

---

## 5. Post-Release Support

### 5.1 Day 1 (Launch Day)

**Launch Window (T-0 to T+6 hours)**:
- [ ] Monitor crash dashboard every 30 mins
- [ ] Check App Store/Google Play submission status
- [ ] Verify app appears in both stores
- [ ] Test download on real devices
- [ ] Monitor social media for issues
- [ ] Have team on-call for critical issues

**Support Tasks**:
- [ ] Respond to user reviews within 24 hours
- [ ] Document any reported issues
- [ ] Prepare hotfix if critical bug found
- [ ] Track DAU metrics

### 5.2 First Week (T+1 to T+7 days)

**Daily Checks**:
- Crash rate trending
- Rating average and review sentiment
- Top crash signatures
- Feature engagement metrics
- Network/API error rates

**Weekly Goals**:
- 0 critical crashes unfixed
- Rating >4.0 stars
- <5% uninstall rate
- Resolve 100% of user support requests

**Issue Response Protocol**:
1. P0 (Critical, app-breaking): Hotfix within 4 hours
2. P1 (Major feature broken): Hotfix within 24 hours
3. P2 (Minor issues): Include in next weekly release
4. P3 (Cosmetic/UX): Include in next monthly release

### 5.3 Ongoing Maintenance

**Weekly**:
- Review analytics summary
- Prioritize feedback from users
- Plan patch releases
- Monitor store ratings/reviews

**Monthly**:
- Comprehensive analytics review
- User cohort analysis
- Feature engagement analysis
- Plan next feature release
- Update documentation

**Quarterly**:
- Major feature planning
- Platform update compatibility
- Security audit
- Architecture review

---

## 6. Hotfix & Update Procedures

### 6.1 Critical Hotfix Process

**Trigger**: App-breaking bugs (crashes, unplayable state)

**Steps**:
1. Create branch: `hotfix/v1.0.1-{issue}`
2. Cherry-pick fix from main
3. Increment patch version: 1.0.1+2
4. Build and test on real devices
5. Submit to both stores
6. Monitor for regressions
7. Merge back to main after verified

**Timeline**: Hotfix → Submission → Approval → Available
- iOS: 24-48 hours
- Android: 2-3 hours

### 6.2 Weekly Patch Release

**Cadence**: Every Tuesday 2 PM UTC

**Preparation** (Monday):
- Code review all PRs
- Merge to main
- Update version: 1.0.X
- Write release notes
- Build and test

**Release** (Tuesday):
- Submit to both stores
- Announce on social media
- Monitor metrics

**Follow-up** (Wed-Fri):
- Track crash rates
- Respond to user feedback

### 6.3 Version Management Script

```bash
# scripts/release.sh

#!/bin/bash

VERSION=$1
BUILD_NUM=$2

if [ -z "$VERSION" ] || [ -z "$BUILD_NUM" ]; then
  echo "Usage: ./scripts/release.sh 1.0.1 2"
  exit 1
fi

# Update version in config
sed -i.bak "s/appVersion = '.*'/appVersion = '$VERSION'/" \
  lib/src/config/release_config.dart
sed -i.bak "s/buildNumber = .*/buildNumber = $BUILD_NUM/" \
  lib/src/config/release_config.dart

# Update pubspec.yaml
sed -i.bak "s/version: .*/version: $VERSION+$BUILD_NUM/" pubspec.yaml

# iOS
sed -i.bak "s/FLUTTER_BUILD_NUMBER=.*/FLUTTER_BUILD_NUMBER=$BUILD_NUM/" \
  ios/Flutter/Flutter.xcconfig
sed -i.bak "s/MARKETING_VERSION=.*/MARKETING_VERSION=$VERSION/" \
  ios/Flutter/Flutter.xcconfig

# Android
sed -i.bak "s/versionCode .*/versionCode $BUILD_NUM/" \
  android/app/build.gradle
sed -i.bak "s/versionName .*/versionName \"$VERSION\"/" \
  android/app/build.gradle

# Commit
git add -A
git commit -m "chore: Bump version to $VERSION+$BUILD_NUM"
git tag "v$VERSION+$BUILD_NUM"

echo "Version updated to $VERSION+$BUILD_NUM"
echo "Run: git push origin claude/chess-j8fad7 --tags"
```

---

## 7. Success Metrics & Targets

### 7.1 Launch Success Criteria

**First 24 Hours**:
- [ ] App appears in both stores within 2 hours
- [ ] Zero critical crash reports
- [ ] Rating ≥3.5 stars (minimum)
- [ ] Minimum 100 downloads
- [ ] <50% uninstall rate

**First Week**:
- [ ] Rating ≥4.0 stars
- [ ] <5% uninstall rate
- [ ] Crash rate <0.5%
- [ ] DAU ≥500
- [ ] Session avg >5 minutes
- [ ] Retention (D1) >40%

**First Month**:
- [ ] Rating ≥4.2 stars
- [ ] Crash rate <0.1%
- [ ] DAU ≥2,000
- [ ] Retention (D7) >25%
- [ ] Retention (D30) >10%
- [ ] ARPU (if monetized) >$0.50

### 7.2 Key Performance Indicators

| KPI | Target | Method |
|-----|--------|--------|
| Crash Rate | <0.1% | Firebase Crashlytics |
| Rating | >4.2 stars | App Store + Play Store |
| Install Rate | 100+/day | Store analytics |
| DAU | 2,000+ | Firebase Analytics |
| Retention D7 | >25% | Firebase Analytics |
| Session Length | >5 min | Firebase Analytics |
| ARPU | >$0.50 | RevenueCat |
| Premium Conv | >10% | RevenueCat |

---

## 8. Communication Plan

### 8.1 Pre-Launch (Day 0)

**Team**:
- Notify team of launch
- Confirm on-call coverage
- Share monitoring links
- Brief on support process

**Users**:
- No public announcement yet (soft launch)
- Monitoring only for first 24 hours

### 8.2 Launch (Hour 0)

**Social Media**:
- 🎉 Tweet: "Chess Tactics Master is live! Available now on iOS and Android."
- Instagram: Screenshot + app link
- Reddit: Post to r/chess and r/AndroidGaming

**Email**:
- Beta tester newsletter: "Thank you email" + link
- Early access: "Your game awaits" email

### 8.3 Post-Launch (Day 1-7)

**Daily**:
- Share stats: "1,000+ downloads!"
- Highlight features: "Did you know?" posts
- Engage with user reviews
- Respond to questions

**Weekly**:
- Feature spotlight posts
- Leaderboard highlights
- Community news
- User testimonials

---

## 9. Deployment Timeline

```
Day 1 (Today):
├─ Finalize release notes
├─ Create iOS build & upload to App Store
├─ Create Android build & upload to Google Play
└─ Setup monitoring dashboards

Day 2:
├─ iOS Review (24-48 hrs)
├─ Android Approval (2-3 hrs)
├─ Test installations on real devices
└─ Monitor crash rates

Day 3-5:
├─ Approval from both stores
├─ Phased rollout begins
├─ Daily monitoring
└─ Support team active

Day 6-7:
├─ Full rollout complete
├─ Comprehensive metrics review
├─ Plan first weekly update
└─ Schedule next release

Week 2+:
├─ Weekly patch releases
├─ Monthly feature updates
├─ Ongoing monitoring
└─ User feedback integration
```

---

## 10. Rollback Procedures

### 10.1 When to Rollback

**Conditions**:
- Crash rate >5% continuously
- App completely unplayable
- Data corruption reported
- Security vulnerability discovered
- Server outage affecting >50% users

### 10.2 How to Rollback

**iOS**:
- App Store → Version Release → Choose previous version
- Takes 24-48 hours

**Android**:
- Google Play Console → Select previous release version
- Automatic rollback via staged rollout pause

**Immediate Workaround**:
- If no working version, submit emergency hotfix
- Alert users via in-app notification
- Update social media

---

## Checklist: Ready for Deployment

- [ ] All Phase F tests passing
- [ ] Security audit complete
- [ ] Performance benchmarks validated
- [ ] Release notes written
- [ ] App icons & screenshots prepared
- [ ] Privacy policies updated
- [ ] Support channel setup
- [ ] Monitoring dashboards configured
- [ ] On-call team confirmed
- [ ] Analytics tracking verified
- [ ] Firebase configured for production
- [ ] RevenueCat ready for payments
- [ ] iOS build signed and archived
- [ ] Android bundle signed and ready
- [ ] App Store Connect metadata complete
- [ ] Google Play Console metadata complete
- [ ] Team notified of launch plan
- [ ] Communication plan reviewed

---

**Phase G Status**: Ready for Implementation  
**Next Step**: Build and submit to both app stores  
**Success Criteria**: Both apps approved and available in their respective stores within 72 hours

