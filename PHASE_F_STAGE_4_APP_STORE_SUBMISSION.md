# Phase F Stage 4: App Store & Play Store Submission

**Status**: 🟡 READY FOR EXECUTION
**Date**: 2026-09-03
**Duration**: Days 1-4 of Week 15 (4-5 days)
**Target**: Both stores accept submission, enter beta testing

---

## Overview

Phase F Stage 4 covers complete submission to App Store and Google Play Store. Includes metadata preparation, screenshot creation, app review requirements, and handling of app review feedback.

**Parallel Execution**: Both stores can be submitted simultaneously
**Timeline**: Typically 1-3 days for App Store, 2-4 hours for Play Store initial review
**Success Criteria**: Both apps approved and available for beta testing

---

## Pre-Submission Checklist

### App Versioning
```bash
# Verify version numbers match
grep "version:" pubspec.yaml
# Expected: 1.0.0+2 (major.minor.patch+buildNumber)

# iOS build number
plutil -p ios/Runner/Info.plist | grep CFBundle
# Expected: CFBundleVersion: 2, CFBundleShortVersionString: 1.0.0

# Android version
grep "versionCode\|versionName" android/app/build.gradle
# Expected: versionCode: 2, versionName: "1.0.0"
```

**Requirement**: ✅ All version numbers aligned

### Build Artifacts Ready
```bash
# Verify builds exist
ls -lh build/app/outputs/flutter-apk/app-release.apk
ls -lh build/app/outputs/bundle/release/app-release.aab
ls -lh build/ios/ipa/chess_tactics_master.ipa

# File size checks
# APK: ~100-150MB typical
# AAB: ~90-140MB typical
# IPA: ~120-160MB typical
```

**Requirement**: ✅ All binaries built and verified

### Code Signing Certificates
```bash
# iOS: Verify signing certificate
# Go to Xcode → Signing & Capabilities
# Verify:
# - Signing Certificate: Apple Distribution (not Development)
# - Provisioning Profile: App Store or Ad Hoc

# Android: Verify signing key
# Check android/key.properties exists (in .gitignore)
# Verify keystore file exists and password stored securely
```

**Requirement**: ✅ Code signing certificates ready

---

## App Store Submission (iOS)

### 1. Create App Store Connect Account

**Pre-requisites**:
- Apple Developer Program membership ($99/year)
- App Store Connect account
- Xcode installed

**Steps**:
```bash
# Go to App Store Connect
# https://appstoreconnect.apple.com

# Steps:
# 1. Click "My Apps"
# 2. Click "+"
# 3. Select "New App"
# 4. Fill in app information
```

### 2. Prepare App Information

#### App Name
```
Chess Tactics Master
```

#### Bundle ID
```
com.yourwish.chess_tactics_master
```

#### Primary Category
```
Games
  └─ Strategy
```

#### Secondary Category
```
Education
```

#### Content Rating Questionnaire

Complete on App Store Connect:
- Violence: None
- Sexual Content: None
- Profanity: None
- Alcohol, Tobacco, Drugs: None
- Gambling: No (even though has purchases, no gambling mechanics)
- Simulated Gambling: No

### 3. Create Screenshots

**Technical Requirements**:
- iPhone 6.7" (max iPhone size): 1242 x 2688 pixels
- iPad Pro 12.9": 2048 x 2732 pixels
- Minimum 2 screenshots, maximum 10
- JPEG or PNG format

**Screenshot Workflow**:
```bash
# 1. Take screenshots on device or simulator
# 2. Use https://shotsnapp.com for framing
# 3. Add text overlay if needed
# 4. Upload 5-8 screenshots total

# Screenshot sequence:
# Screen 1: Onboarding / Main menu
# Screen 2: Puzzle gameplay
# Screen 3: Solve puzzle (success)
# Screen 4: Subscribe to premium
# Screen 5: Premium features
# Screen 6: Game statistics
```

**Example Screenshot Set**:
```
1. Home Screen + CTA
   Text: "Master Chess Tactics"
   Text: "100+ Daily Puzzles"

2. Puzzle in Progress
   Text: "Solve to Increase Rating"

3. Solution Screen
   Text: "Congratulations!"

4. Paywall
   Text: "Unlock Premium Features"
   Text: "Pro + Elite Tiers"

5. Premium Features
   Text: "Advanced Analysis"
   Text: "Custom Engines"
```

### 4. Write App Description

```
Chess Tactics Master helps you improve your chess skills through targeted tactical puzzles.

✓ 500+ chess puzzles from beginner to master level
✓ Real-time multiplayer matches
✓ Skill-based rating system
✓ Detailed game analysis
✓ Compete on global leaderboards
✓ AI-powered chess engine

FEATURES:
• Puzzle Mode: Solve 100+ daily tactics
• Online Multiplayer: Challenge players worldwide
• Rating System: Track your improvement
• Game Analysis: Review moves and learn
• Leaderboards: Compete globally

SUBSCRIPTION OPTIONS:
• Free: Core features with limits
• Pro: Unlimited puzzles, advanced analysis
• Elite: Pro features + private coaching

Start your chess mastery journey today!
```

### 5. Fill App Review Information

**Contact Information**:
- First Name: [Your Name]
- Last Name: [Your Name]
- Email: [Your Email]
- Phone: [Your Phone]

**Demo Account** (if needed for premium features):
- Username: demo@example.com
- Password: DemoPassword123!
- Note: If app has IAP, provide test account details

**Review Notes**:
```
This app uses RevenueCat for subscription management and Firebase for analytics.

Test accounts:
- Free tier: No subscription required
- Pro/Elite: Use the provided demo account

Beta access via TestFlight: [Link]

Privacy Policy: https://yourwish-chess.com/privacy
Terms of Service: https://yourwish-chess.com/terms
```

### 6. Upload IPA Build

**Method 1: Xcode Uploader**
```bash
# Xcode menu: Window → Organizer
# Select Chess Tactics Master app
# Click "Distribute App"
# Select "App Store Connect"
# Follow prompts to upload IPA
```

**Method 2: Transporter**
```bash
# Download Transporter from App Store
# Open Transporter
# Add IPA: build/ios/ipa/chess_tactics_master.ipa
# Deliver to App Store Connect
```

### 7. Submit for Review

**On App Store Connect**:
1. Go to "App Review Information" tab
2. Select "Build" tab
3. Choose build to review
4. Fill out "App Review Information"
5. Click "Save"
6. Click "Submit for Review"

**Submission Checklist**:
- [ ] Version number matches
- [ ] Build uploaded and processing complete
- [ ] Screenshots added (minimum 2)
- [ ] Description and keywords filled
- [ ] Content rating questionnaire completed
- [ ] Privacy policy link provided
- [ ] Support URL provided
- [ ] Demo account provided (if needed)
- [ ] No export compliance issues
- [ ] Pricing tier set

### 8. Monitor Review Status

```bash
# Go to App Store Connect
# Navigate to "My Apps" → "Chess Tactics Master"
# Check "App Store" → "Status"

# Possible statuses:
# • Waiting for Review
# • In Review
# • Ready for Sale
# • Rejected
# • Metadata Rejected
```

**Typical Timeline**:
- Waiting for Review: 24-48 hours
- In Review: 24-48 hours
- Ready for Sale: Approved!

**Common Rejection Reasons**:
1. Incomplete app functionality
   → Ensure all features work without crashing

2. Performance issues
   → Test on various devices, fix crashes

3. Privacy issues
   → Ensure privacy policy is complete

4. Misleading content
   → Screenshots must match app functionality

5. Guideline violations
   → Review App Store Review Guidelines

### 9. Handle Feedback

**If Approved**:
- ✅ App appears on App Store
- ✅ Can promote for TestFlight beta
- ✅ Collect user feedback

**If Metadata Rejected**:
- Review feedback
- Fix screenshots/description
- Resubmit (just metadata, not build)

**If Rejected**:
- Review detailed rejection reason
- Make required changes
- Resubmit build

---

## Google Play Store Submission (Android)

### 1. Create Google Play Developer Account

**Pre-requisites**:
- Google Play Developer account ($25 one-time)
- Google Play Console access

**Steps**:
```bash
# Go to Google Play Console
# https://play.google.com/console

# Create new app:
# 1. Click "Create app"
# 2. Enter app name: Chess Tactics Master
# 3. Select app type: Game
# 4. Select category: Casual (or Strategy if available)
# 5. Declare as free/paid
```

### 2. Prepare Store Listing

#### App Title
```
Chess Tactics Master
```

#### Short Description (80 chars max)
```
Master chess tactics through daily puzzles and multiplayer matches.
```

#### Full Description (4000 chars)
```
Chess Tactics Master is your personal chess coach, helping you improve tactical skills through:

✓ 500+ chess puzzles from beginner to expert
✓ Real-time multiplayer battles
✓ Rating system to track progress
✓ AI-powered chess engine with analysis
✓ Global leaderboards

FEATURES:
📚 Puzzle Mode
- Daily tactical puzzles
- Difficulty levels
- Detailed solutions

🎮 Multiplayer
- Real-time matches
- Rating-based matchmaking
- Chat with opponents

📊 Progress Tracking
- Personal statistics
- Game history
- Rating curves

⚙️ Advanced Features (Premium)
- Deep game analysis
- Engine strength selection
- Opening database
- Endgame studies

SUBSCRIPTION:
• Free: Limited puzzles
• Pro: Unlimited puzzles, basic analysis
• Elite: Pro features + advanced analysis

Why Chess Tactics Master?
- Proven chess training method
- Scientifically-designed curriculum
- Play with real opponents
- Improve your rating rapidly

PERMISSIONS:
- Internet: For multiplayer and cloud sync
- Camera: For in-app video tutorials (optional)

Chess Tactics Master is for players of all levels from beginners to advanced players.
Start your chess journey today!
```

#### Category
```
Games → Casual or Strategy
```

#### Content Rating
```
Complete the content rating questionnaire:
- Violence: None
- Sexual Content: None
- Profanity: None
- Alcohol, Tobacco, Drugs: None
- Gambling: No

Target audience: 4+ (no restricted content)
```

### 3. Create Screenshots

**Technical Requirements**:
- Phone: 1080 x 1920 pixels (portrait)
- Tablet: 1440 x 2560 pixels (portrait)
- Minimum 2, maximum 8 screenshots per device type

**Google Play requires**:
```
Phone screenshots:
1. Puzzle gameplay
2. Multiplayer
3. Leaderboard
4. Subscribe screen
5. Settings/profile

Tablet screenshots (if supported):
1-2 high-quality tablet layouts
```

### 4. Upload Screenshots

**On Google Play Console**:
```
1. Go to "All apps" → "Chess Tactics Master"
2. Go to "Manage releases" → "Add release"
3. Upload APK or AAB:
   - Google Play prefers AAB (smaller download)
   - AAB automatically generates optimized APKs
   
4. Add screenshots:
   - Phone (required)
   - 7-inch tablet (optional)
   - 10-inch tablet (optional)

5. Add feature graphic:
   - 1024 x 500 pixels
   - PNG or JPG
   - Highlight key features

6. Add preview video (optional):
   - YouTube URL
   - Up to 30 seconds
```

### 5. Fill App Details

**Contact Information**:
```
Email: your@email.com
Phone: +1 (555) 123-4567
Website: https://yourwish-chess.com
Privacy Policy: https://yourwish-chess.com/privacy
```

**Permissions Review**:
```
If your app requests permissions:
- INTERNET: Required for multiplayer/analytics
- Camera (if tutorials): Optional
- Microphone: Not needed
- Contacts/Calendar: Not needed

Google Play will verify app only requests necessary permissions.
```

### 6. Set Pricing and Distribution

```
Price Tier: Free

Countries: All (or specify regions)

Target Android Versions:
  Minimum: Android 7 (API 24)
  Target: Android 14 (API 34)
```

### 7. Prepare for Release

**Create Release**:
```
1. Go to "Release" → "Create new release"
2. Select: Production (for public release) or Internal Testing
3. Upload AAB: build/app/outputs/bundle/release/app-release.aab
4. Add release notes: "v1.0.0 - Initial release"
5. Review rollout: 100% (full rollout)
6. Click "Review release"
```

### 8. Review Checklist

```
Before submitting, verify:
- [ ] App name and store listing complete
- [ ] Screenshots uploaded (high quality)
- [ ] Feature graphic created
- [ ] Content rating set
- [ ] Privacy policy link working
- [ ] AAB/APK uploaded and tested
- [ ] Pricing set correctly
- [ ] All required information filled
- [ ] No placeholder text remaining
- [ ] Screenshots match app content
```

### 9. Submit Release

**On Google Play Console**:
```
1. Review all information
2. Click "Start rollout to Production"
3. Confirm submission
4. App enters review queue

Google Play Review Status:
• Pending review (first release may take 2-4 hours)
• In review
• Available (approved!)
• Rejected (rare, usually policy issues)
```

### 10. Monitor & Respond

**Timeline**:
- First release: 2-4 hours typical
- Updates: Usually 1-2 hours
- Very occasionally: 24 hours

**Check Status**:
```bash
# On Google Play Console:
# Navigate to "All apps" → "Chess Tactics Master"
# Check "Release status"
```

**If Approved**:
- ✅ App available on Play Store
- ✅ Can promote for testing
- ✅ Users can download

**If Rejected**:
- Review rejection reason (usually clear policy violation)
- Fix issue
- Resubmit
- Typically takes 2-4 hours again

---

## Review Guidelines Compliance

### App Store Review Guidelines

**Key Requirements**:
```
1. Crash-free: App must not crash on any device
2. Functionality: All features must work as described
3. Legal: Must include privacy policy, terms
4. Content: Screenshots/description must match app
5. Performance: No excessive battery/data drain
6. Security: No suspicious network activity
7. Kids: If targeting kids, meet age requirements
```

**Common Rejections**:
- Missing privacy policy
- Crashes on test devices
- Screenshots don't match functionality
- Misleading app description
- Incorrect app category

### Play Store Policy

**Key Requirements**:
```
1. Security: No malware, spyware, exploits
2. Spam: No misleading behavior
3. Deceptive: Description must be accurate
4. Content: Must be appropriate for rating
5. Minors: Extra protection if under-13 allowed
```

---

## Beta Testing Setup

### TestFlight (iOS)

```bash
# On App Store Connect:
# 1. Go to "TestFlight" tab
# 2. Click "Build number for TestFlight Review"
# 3. Select build to beta test
# 4. Add test information

# Add Testers:
# - Internal testers (max 25, Apple employees)
# - External testers (unlimited, up to 10,000)

# Create Invite Link:
# Send beta link: https://testflight.apple.com/join/XXXXXXX
```

### Play Store Internal Testing

```bash
# On Google Play Console:
# 1. Go to "Testing" → "Internal testing"
# 2. Create release with build
# 3. Add testers (email addresses)
# 4. Send invite links

# Testers get:
# - Early access to new versions
# - Direct feedback channel
# - Version before public release
```

---

## Release Management

### Version Strategy

```
v1.0.0: Initial release
├─ 1.0.0 Build 1: Internal testing
├─ 1.0.0 Build 2: Beta testing (TestFlight/Play)
└─ 1.0.0 Build 3: Production release

v1.0.1: Minor bug fixes
v1.1.0: New features
v2.0.0: Major rewrite
```

### Release Notes Template

```markdown
# Chess Tactics Master v1.0.0

## What's New
- ✨ Puzzle mode with 500+ tactics
- 🎮 Real-time multiplayer battles
- 📊 Skill rating system
- 💎 Premium subscription tiers
- 📱 Responsive UI for all screens
- 🔒 Secure Firebase backend

## Improvements
- Performance optimized for all devices
- Offline mode for puzzle practice
- Enhanced analytics for game insights
- Better error handling and recovery

## Bug Fixes
- Fixed crash on app launch
- Fixed sign-in issues
- Improved network stability

## Known Issues
None known at this time

## Thank you!
Enjoy Chess Tactics Master. Send feedback to support@yourwish-chess.com
```

---

## Post-Release Monitoring

### First 24 Hours
```
Monitor:
- Crash rate (target: < 0.1%)
- Ratings/reviews
- Performance metrics
- Error reports

Actions:
- Respond to user reviews
- Monitor analytics
- Check error logs
- Prepare hotfix if needed
```

### First Week
```
Metrics to track:
- Download count
- Crash rate
- Daily active users (DAU)
- Engagement metrics
- Revenue (subscription conversion)
- Ratings (target: 4.0+)
```

### First Month
```
Analysis:
- Retention curves
- User cohort analysis
- Feature usage
- Conversion funnels
- Revenue metrics
- User feedback themes

Improvements:
- Address common complaints
- Optimize underperforming features
- Plan v1.0.1 updates
- Gather feedback for v1.1.0
```

---

## Troubleshooting

### App Rejected for Crashes

```
Solution:
1. Reproduce crash on test device
2. Fix root cause in code
3. Test thoroughly
4. Rebuild and resubmit
5. Include detailed description of fix in review notes
```

### Metadata Rejected

```
Solution:
1. Review rejection reason carefully
2. Fix screenshots/description/content rating
3. Resubmit metadata only (not full build)
4. Usually approved within 1 hour
```

### Rejected for Privacy Issues

```
Solution:
1. Verify privacy policy is complete
2. Ensure all data sharing disclosed
3. Add privacy policy link to app
4. Update to latest privacy policy version
5. Resubmit with clear privacy compliance notes
```

---

## Success Checklist

**Pre-Submission**:
- [ ] All builds ready (APK, AAB, IPA)
- [ ] Code signing certificates valid
- [ ] Version numbers aligned
- [ ] Device testing passed
- [ ] Security audit passed

**Store Listing**:
- [ ] App name, description, keywords filled
- [ ] Screenshots created (high quality)
- [ ] Content rating set
- [ ] Privacy policy linked
- [ ] Support contact information ready

**Submission**:
- [ ] App Store submission complete
- [ ] Play Store submission complete
- [ ] Both apps in review
- [ ] Team notified of submission

**Post-Submission**:
- [ ] Monitor review status daily
- [ ] Respond to any review feedback
- [ ] Prepare beta testing access
- [ ] Set up release monitoring
- [ ] Plan post-release iterations

---

## Timeline Summary

```
Day 1: Prepare metadata
  └─ Screenshots, descriptions, content rating

Day 1-2: Submit both stores
  └─ App Store submission
  └─ Play Store submission

Day 2-3: App Store review
  └─ Initial review 24-48 hours
  └─ Handle feedback if needed

Day 1-2: Play Store initial review
  └─ Usually 2-4 hours
  └─ Quick turnaround

Day 3: Approved!
  └─ Apps available
  └─ Begin beta testing
  └─ Prepare marketing

Day 4-7: Beta testing
  └─ Collect user feedback
  └─ Monitor crash rates
  └─ Plan next release
```

---

**Status**: Ready for app store submission
**Total Time**: 2-4 days from submission to approval
**Success Rate**: ~95% on first try (if guidelines followed)

---

**Document Version**: 1.0
**Last Updated**: 2026-09-03
**Phase**: F Stage 4 (App Store Submission)
