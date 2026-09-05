# Phase G Stage 2: Store Submission

**Status**: Ready for Execution  
**Date**: 2026-09-03  
**Duration**: 2-3 hours setup, 24-72 hours processing  
**Target**: Both apps submitted to stores, approved and live

---

## Overview

Phase G Stage 2 focuses on the actual submission of Chess Tactics Master to Apple App Store and Google Play Store. This includes uploading builds, configuring store listings, and monitoring approval processes.

**Timeline**: Day 3-5 of Phase G  
**Success Criteria**: Both apps submitted, under review, and approved within 72 hours

---

## 1. iOS App Store Submission

### 1.1 App Store Connect Setup

**Creating App in App Store Connect**:
```
1. Navigate to: https://appstoreconnect.apple.com
2. Sign in with Apple Developer account
3. Click "My Apps" → "+" → "New App"

App Information:
- Platform: iOS
- App Name: Chess Tactics Master (EXACT)
- Primary Language: English
- Bundle ID: com.yourwish.chess-tactics-master
- SKU: chess-tactics-master-ios-1.0.0
- User Access: Limited
```

**App Store Info Setup**:
```
1. General Information
   - App Name: Chess Tactics Master
   - Subtitle: Learn Chess Through Puzzles
   - Category: Games → Puzzle
   - Content Rights: Yes, I own the content

2. App Pricing and Availability
   - Pricing Tier: Free (with in-app purchases)
   - Price: Free
   - Availability: Worldwide
   - Release Date: Automatic (on approval)
   - Age Rating: 4+
```

**Pricing & In-App Purchases**:
```
Create In-App Purchase Products:
1. Pro Subscription
   - Type: Auto-Renewable Subscription
   - Reference Name: Chess Pro Monthly
   - Product ID: chess.pro.monthly
   - Duration: 1 Month
   - Price: $9.99 USD
   - Renewal: Automatic
   - Family Sharing: Enabled

2. Elite Subscription
   - Type: Auto-Renewable Subscription
   - Reference Name: Chess Elite Monthly
   - Product ID: chess.elite.monthly
   - Duration: 1 Month
   - Price: $19.99 USD
   - Renewal: Automatic
   - Family Sharing: Enabled

3. Trial (7 days, then auto-renews at $9.99)
   - Free Trial Duration: 7 Days
   - Billing: Starts on day 8
   - Cancellation: Users can cancel anytime

Note: Use RevenueCat for management
Sync RevenueCat products to App Store Connect
```

### 1.2 Preparing Version Release

**Version Setup**:
```
Create New Version:
1. Go to App Store Connect → Versions
2. Click "+" → "Create New Version"
3. Version Number: 1.0.0
4. Build: (Will add after archive upload)
5. Copyright: 2026 YourWish Inc.
6. Category: Games > Puzzle
```

**What's New**:
```
Version 1.0.0 Release Notes:
=============================

Welcome to Chess Tactics Master!

🎯 1000+ Engaging Chess Puzzles
- Puzzles for all skill levels
- Learn from beginner to advanced tactics

🌍 Real-Time Multiplayer
- Challenge players worldwide
- Instant matchmaking with rated opponents

📊 ELO Rating System
- Climb the global leaderboard
- Compete with players of all levels

🏆 Achievements & Badges
- Unlock badges as you progress
- Track your improvement over time

🎮 Offline Mode
- Solve puzzles anytime, anywhere
- No internet required

🌙 Dark Mode
- Comfortable gaming experience
- Easy on the eyes

Subscribe to Pro or Elite for unlimited puzzles and exclusive features!

Privacy Policy: https://chessmaster.app/privacy
Terms of Service: https://chessmaster.app/terms
Support: support@chessmaster.app
```

### 1.3 Screenshots & Media

**Uploading Screenshots**:
```
In App Store Connect:
1. General → Screenshots
2. Select Device Type: iPhone 6.5" (required)
3. Upload screenshots in order:
   - Screenshot 1.png
   - Screenshot 2.png
   - ... (up to 6)

Guidelines:
- Dimensions: EXACTLY 1242x2688
- Format: PNG or JPG
- Size: <5MB each
- Text overlay recommended
- Shows key features clearly
```

**Screenshot Details**:
```
Screenshot Set (1242x2688):

1. Home Screen
   Overlay: "Learn Chess Through Tactics"
   Shows: Dashboard, 5 puzzles, profile icon

2. Puzzle Solver
   Overlay: "1000+ Puzzles to Master"
   Shows: Chess board, puzzle interface, hint button

3. Multiplayer Queue
   Overlay: "Play Players Worldwide"
   Shows: Queue interface, opponent selection

4. Live Game
   Overlay: "Real-Time Battles"
   Shows: Active game, opponent, timer

5. Leaderboards
   Overlay: "Climb the Ranks"
   Shows: Global rankings, user stats, rating

6. Premium Features
   Overlay: "Unlimited with Pro"
   Shows: Subscription tiers, feature list
```

**App Preview Video** (Optional but recommended):
```
Preview Video Specs:
- Duration: 15-30 seconds
- Format: MP4, H.264 codec
- Resolution: 1242x2688 (same as screenshots)
- Frame rate: 30fps

Content:
1. Open app (2s)
2. Solve puzzle (5s)
3. Play multiplayer (5s)
4. View leaderboard (3s)
5. Show subscription screen (3s)
```

### 1.4 App Privacy Information

**Privacy Labels**:
```
Navigate: App Store Connect → Privacy

Data Categories to Disclose:

1. User ID
   Purpose: App Functionality
   Tracking: No

2. Email Address
   Purpose: Account Management, Customer Support
   Tracking: No

3. User Name
   Purpose: App Functionality
   Tracking: No

4. Gameplay Statistics
   Purpose: Analytics
   Tracking: Yes (for engagement metrics)

5. Device ID
   Purpose: Analytics, App Functionality
   Tracking: Yes (for crash reporting)

6. Crash Data
   Purpose: Analytics
   Tracking: No (anonymized)

Tracking Transparency:
- Tracking for Advertising: Yes/No (based on implementation)
- Requires ATT (App Tracking Transparency): If tracking enabled
```

**Privacy Answers**:
```
Health/Fitness Data: No
Financial Info: Yes (payment info via RevenueCat)
Sensitive Info: No
Contacts: No
Photos/Video: No
Location: No
Sensitive Health: No
```

### 1.5 Content Rating

**Completing Rating Questionnaire**:
```
Navigate: App Store Connect → Ratings

Questions:
1. Does your app contain:
   - Frequent/intense violence: NO
   - Cartoon violence: NO
   - Realistic violence: NO
   - Profanity: NO
   - Frequent/intense mature themes: NO
   - Frequent/intense horror/fear: NO
   - Frequent/intense sexual content: NO
   - Infrequent/mild sexual content: NO
   - Alcohol/tobacco/drugs: NO
   - Gambling: NO (note: in-app purchase != gambling)
   - Simulated gambling: NO
   - Medical/treatment info: NO
   - Unrestricted Web access: NO

Result: 4+ Rating (PEGI 3+)

Submit for rating
```

### 1.6 Building and Uploading IPA

**Build & Archive Process**:
```bash
# Clean workspace
flutter clean
rm -rf ios/Pods ios/Podfile.lock

# Get dependencies
flutter pub get
dart run build_runner build

# Build iOS app (release mode)
flutter build ios --release -v 2>&1 | tee build.log

# Open Xcode Organizer
open ~/Library/Developer/Xcode/Archives
```

**Using Xcode Organizer to Upload**:
```
1. Open Xcode
2. Window → Organizer
3. Select your app's archive
4. Click "Distribute App"
5. Distribution Method:
   - Select "App Store Connect"
   - Click "Next"

6. Signing Options:
   - Automatically manage signing (recommended)
   - Click "Next"

7. Review:
   - Verify bundle ID: com.yourwish.chess-tactics-master
   - Verify version: 1.0.0
   - Click "Upload"

8. Monitor Upload:
   - Status bar shows "Uploading..."
   - Wait for "Upload Successful"
   - Email confirmation from Apple
   - Takes 5-15 minutes

9. Verify in App Store Connect:
   - Refresh page
   - Build should appear in "Builds" section
   - Status: "Processing" → "Ready to Submit"
```

**Using Transporter (Alternative)**:
```bash
# Download Transporter from App Store
# or via: xcrun altool --version

# Export IPA from archive
# Use Xcode Organizer → Export

# Upload via Transporter
xcrun altool --upload-package Chess-1.0.0.ipa \
  --type ios \
  --username [your-apple-id] \
  --password [app-specific-password] \
  --show-progress

# Verify upload completed
xcrun altool --list-apps \
  --username [your-apple-id] \
  --password [app-specific-password]
```

### 1.7 Submit for Review

**Submitting to App Store**:
```
1. App Store Connect → Versions → 1.0.0
2. Build Section:
   - Select build uploaded (will appear here)
   - Build status: "Ready to Submit"
3. App Review Information:
   - Account contact info: [Your email]
   - Demo Account:
     * Username: demo@chessmaster.app
     * Password: [Secure password]
     * Notes: "Pro subscription already active"
   - Test Notes:
     "1. Open app
      2. Browse puzzles (free mode)
      3. Tap 'Pro' to test subscription flow
      4. Tap back to continue playing free puzzles"
   - Review Notes:
     "Chess Tactics Master - Initial release 1.0.0"
4. Click "Save"
5. Ready for Review:
   - Click "Submit for Review" (top right)
   - Select Release Version: "Automatic Release"
   - Confirm submission
   - Status: "Submitted for Review"
   - Typical wait: 24-48 hours
```

---

## 2. Android Google Play Submission

### 2.1 Google Play Console Setup

**Creating App in Play Console**:
```
1. Navigate to: https://play.google.com/console
2. Create new app
   - App Name: Chess Tactics Master
   - Default Language: English
   - App Category: Games → Puzzle
   - Content Rating: Appropriate

3. App Details:
   - Bundle ID: com.yourwish.chess_tactics_master
   - App Type: Game
   - Category: Puzzle
```

**Store Listing Setup**:
```
1. Store listing → Main store listing
   - Title (50 chars): Chess Tactics Master
   - Short description (80 chars):
     "Master chess through 1000+ puzzles"
   
   - Full description (4000 chars):
     [Use iOS description text above]
   
   - Category: Games > Puzzle
   - Content Rating: 3+ (Everyone)
   - Target Audience: Gamers

2. Graphics
   - Feature graphic (1024x500):
     App name + key features
   - Icon (512x512):
     High-res app icon
   - Screenshots (5.5" phone, 1080x1920):
     Upload 4-8 screenshots
   - Video (optional, recommended):
     Preview video 1242x2688 converted to 1080x1920

3. Localization
   - Default language: English
   - Additional languages: [None for MVP]
```

**In-App Products Configuration**:
```
Products → In-App Products:

1. Create Pro Subscription
   - Product ID: chess.pro.monthly
   - Name: Chess Pro Monthly
   - Type: Subscription
   - Default price: $9.99 USD
   - Billing period: Monthly
   - Free trial: 7 days (optional)
   - Renewal: Auto-renew enabled
   - Grace period: 3 days
   - Re-engagement offer: Available

2. Create Elite Subscription
   - Product ID: chess.elite.monthly
   - Name: Chess Elite Monthly
   - Type: Subscription
   - Default price: $19.99 USD
   - Billing period: Monthly
   - Free trial: 7 days (optional)
   - Renewal: Auto-renew enabled
   - Grace period: 3 days

3. Configure in RevenueCat
   - Link Google Play products
   - Configure offerings
   - Test with sandbox accounts
```

**Pricing & Distribution**:
```
1. Pricing
   - Content Rating: Everyone
   - Categories: Games > Puzzle
   - Countries/regions: Worldwide
   - Price: Free (IAP pricing above)

2. Rating
   - Content rating questionnaire: Complete
   - Ad Disclosure: (if applicable)
   - Permissions: Justified

3. Release Settings
   - Track: Production
   - Deployment: Staged rollout
   - Initial rollout: 5%
```

### 2.2 Content Rating Questionnaire

**ESRB/PEGI Rating**:
```
Navigate: Play Console → Ratings

Questions:
1. Violence:
   - Does your app contain violence? NO
   - Realistic violence? NO

2. Language/Profanity:
   - Profanity or crude language? NO

3. Sexual Content:
   - Sexual content or nudity? NO

4. Substances:
   - Alcohol, tobacco, or drugs? NO

5. Gambling:
   - Gambling or gambling content? NO
   - (Note: In-app purchase is NOT gambling)

6. Medical/Health:
   - Medical/health information? NO

7. Personal Information:
   - Kids under 13 targeted? NO
   - Personal info collected? Email/user ID only
   - Parental consent: N/A

Result: Everyone / PEGI 3+

Certificate: Automatically issued
```

### 2.3 Preparing Android App Bundle

**Build Process**:
```bash
# Clean and prepare
flutter clean
rm -rf android/.gradle

# Get dependencies
flutter pub get
dart run build_runner build

# Build app bundle (AAB)
flutter build appbundle --release -v

# Output: build/app/outputs/bundle/release/app-release.aab

# Verify bundle
bundletool validate \
  --bundle-path=build/app/outputs/bundle/release/app-release.aab

# Expected: "The app bundle is valid."
```

**Testing Bundle Locally**:
```bash
# Extract APKs from bundle
bundletool build-apks \
  --bundle=build/app/outputs/bundle/release/app-release.aab \
  --output=app-test.apks \
  --mode=universal \
  --ks=~/keystores/chess-release.jks \
  --ks-pass=pass:[password] \
  --ks-key-alias=chess-key-alias \
  --key-pass=pass:[password]

# Install on device
adb install app-test.apks

# Test app thoroughly
# Verify all features work
# Test payment flow with sandbox account
```

**Bundle Size Verification**:
```
Acceptable Sizes:
- Base bundle: <50 MB
- Total with splits: <80 MB
- Per-language split: <20 MB
- Per-density split: <30 MB

Measured: [Run this on your bundle]
bundletool dump manifest \
  --bundle=build/app/outputs/bundle/release/app-release.aab
```

### 2.4 Uploading to Play Console

**Uploading App Bundle**:
```
1. Play Console → Releases → Production
2. Create new release
   - Release name: v1.0.0
   - Release notes:
     "Welcome to Chess Tactics Master!
      - 1000+ engaging puzzles
      - Real-time multiplayer
      - ELO rating system
      - Offline mode
      - Dark theme"

3. App bundles:
   - Click "Browse files"
   - Select: app-release.aab
   - Upload (wait for processing)

4. Review app details:
   - Permissions: Justified
   - Vulnerable dependencies: None
   - API levels: 24-34 supported

5. Staged rollout:
   - Start: 5% of users
   - Schedule expansion: Manual
   - Next stages: 10% → 25% → 50% → 100%

6. Save and submit
   - Click "Submit for review"
   - Status: "Preparing release"
   - Typical wait: 2-3 hours
```

**Monitoring Upload Progress**:
```
Check Status:
1. Releases → Production
2. Release status shows progress:
   - "Preparing release" (5-15 min)
   - "Ready for internal testing" (if sandbox)
   - "In review" (Google review, 2-3 hours)
   - "Approved" (Ready for rollout)
   - "Pending publication" (Waiting for manual approval)
   - "Live" (Available to users)

Email notification when status changes
Track via Play Console dashboard
```

### 2.5 Handling App Review

**Common Play Store Review Issues**:
```
Issue: Inappropriate content
Fix: Ensure content rating is accurate

Issue: Crash on install
Fix: Test on target devices, re-upload

Issue: Missing privacy policy
Fix: Add URL in Play Console

Issue: Unimplemented features advertised
Fix: Verify all features work, update description

Issue: Violates monetization policy
Fix: In-app purchases must be clearly disclosed

Issue: Target age rating incorrect
Fix: Re-evaluate content, update rating
```

**Response to Rejection**:
```
If rejected:
1. Read rejection email carefully
2. Identify specific policy violation
3. Fix issue in code/metadata
4. Re-build and re-upload AAB
5. Submit again with detailed explanation:
   "Issue identified and fixed:
    - [Specific fix made]
    - Tested on devices [list]
    - Verified against policy [policy link]"
6. Re-submission typically approved same day

Track rejection rate and reasons
Update documentation to prevent future issues
```

---

## 3. Submission Coordination

### 3.1 Submission Timeline

**Recommended Sequence**:
```
Timeline:
Day 1 (T+0):
  08:00 - Final build verification
  09:00 - iOS build + upload to App Store
  09:30 - Android build + upload to Play Console
  10:00 - Submit iOS to review
  10:15 - Submit Android to review
  10:30 - Announce launch to team

Day 2 (T+1):
  08:00 - Check Android approval (usually approved)
  12:00 - Check iOS approval (12-24 hour wait)
  (Continue monitoring both stores)

Day 3 (T+2):
  08:00 - iOS approval expected (if not, check emails)
  Check store listings appearance
  Download and test both apps
  Begin marketing announcement

Day 4-5 (T+3-4):
  Monitor ratings and reviews
  Address any user feedback
  Prepare patch release if needed
```

### 3.2 Monitoring Submissions

**Daily Checklist**:
```
☐ Check iOS status: App Store Connect → Versions
☐ Check Android status: Play Console → Releases
☐ Verify app appears in searches
☐ Download and test both apps
☐ Check Firebase analytics for first installs
☐ Monitor reviews and ratings
☐ Check crash reports in Crashlytics
☐ Respond to any user support emails
```

**Status Indicators**:
```
iOS:
- "Submitted for Review" (processing)
- "In Review" (Apple reviewing)
- "Ready for Sale" (approved)
- "Available" (live in store)

Android:
- "In review" (Google reviewing)
- "Approved" (approved)
- "Queued for rollout" (waiting for manual approval)
- "Live" (available)
```

### 3.3 Approval Monitoring Tools

**Set Up Notifications**:
```
iOS:
- App Store Connect app (iOS app)
- Enable notifications for version status
- Email notifications (default enabled)

Android:
- Play Console app (Android app)
- Enable notifications
- Email notifications from Google

Both:
- Check dashboards daily (first week)
- Set phone reminders for key dates
- Keep support email monitored
```

---

## 4. Pre-Submission Verification

### 4.1 Final Checklist Before Submission

**Code & Build**:
- [ ] flutter analyze: 0 errors
- [ ] flutter test: All tests pass
- [ ] Build runs without warnings
- [ ] Performance benchmarks met
- [ ] No hardcoded debug values
- [ ] Version numbers consistent (pubspec.yaml, iOS, Android)

**iOS Submission**:
- [ ] IPA uploaded and processing
- [ ] Build appears in "Builds" section
- [ ] Screenshots uploaded (1242x2688, 6 total)
- [ ] App privacy labels complete
- [ ] Content rating questionnaire done
- [ ] Demo account configured
- [ ] Pricing tiers configured in App Store Connect
- [ ] Review notes complete
- [ ] Ready to Submit button visible

**Android Submission**:
- [ ] AAB uploaded and processed
- [ ] No warning messages from Play Console
- [ ] Store listing complete
- [ ] Screenshots uploaded (1080x1920, 4-8 total)
- [ ] Feature graphic uploaded (1024x500)
- [ ] Content rating questionnaire done
- [ ] In-app products configured
- [ ] Release notes written
- [ ] Privacy policy URL correct
- [ ] Support email active

**Legal & Compliance**:
- [ ] Privacy policy published and accessible
- [ ] Terms of service published
- [ ] Support email monitored
- [ ] GDPR compliance verified (if applicable)
- [ ] Age rating appropriate for content

**Marketing & Support**:
- [ ] Social media ready for announcement
- [ ] Support team briefed
- [ ] FAQ prepared
- [ ] Help documentation ready
- [ ] Monitoring dashboards set up

---

## 5. Sign-Off

**Store Submission Complete**:
- [ ] iOS app submitted to App Store
- [ ] Android app submitted to Play Store
- [ ] Both apps under review or approved
- [ ] Monitoring procedures active
- [ ] Team alerted to status
- [ ] Support channels prepared

**Ready to Proceed**: Phase G Stage 3 (Launch & Monitoring)

---

**Document Version**: 1.0  
**Last Updated**: 2026-09-03  
**Phase**: G Stage 2 (Store Submission)  
**Status**: Ready for Implementation
