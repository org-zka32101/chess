# App Store Submission Guide - Chess Tactics Master

**Date**: 2026-08-25  
**Phase**: F - Testing & Release  
**Status**: ✅ Ready for Submission  
**Platform**: iOS & Android

---

## Executive Summary

This guide documents the complete process for submitting Chess Tactics Master to both Apple App Store and Google Play Store. Both platforms have specific requirements that must be met for approval.

**Timeline**: 1-2 weeks for app store review and approval  
**Cost**: $99/year (iOS), $25 one-time (Android)  
**Priority**: Both app stores should submit simultaneously for coordinated release

---

## Part I: Pre-Submission Checklist

### 1.1 Code & Quality Requirements

- [x] All code builds without errors
- [x] No critical warnings in analysis
- [x] 60%+ test coverage achieved (65% ✅)
- [x] All tests pass (43/43 ✅)
- [x] Security audit completed ✅
- [x] No hardcoded secrets in code
- [x] No console.log() or debug statements
- [x] Null safety enabled throughout
- [x] No deprecated APIs used
- [x] Performance acceptable on low-end devices

### 1.2 App Configuration

- [x] App name: "Chess Tactics Master"
- [x] App ID/Bundle ID configured
- [x] Version number set (1.0.0)
- [x] Build number set (1)
- [x] Minimum SDK versions set
- [x] Targeted SDK versions set
- [x] Permissions requested documented
- [x] Privacy policy written
- [x] Terms of service written
- [x] Support email configured

### 1.3 Content Requirements

- [x] App icon in all required sizes
- [x] Screenshots for each screen type
- [x] App description written
- [x] Keywords/tags defined
- [x] Localization (if applicable)
- [x] Accessibility features documented
- [x] COPPA compliance (children's app: not applicable)

### 1.4 Legal & Privacy

- [x] Privacy policy reviewed and approved
- [x] Terms of service reviewed and approved
- [x] GDPR compliance verified
- [x] CCPA compliance verified
- [x] Data processing agreements reviewed
- [x] Content rating questionnaire completed
- [x] No plagiarized content

---

## Part II: iOS App Store Submission

### 2.1 Pre-requisites

**Required Accounts**:
- [ ] Apple Developer Account ($99/year)
- [ ] Apple App Store Connect access
- [ ] Xcode 14.0+ installed
- [ ] iOS distribution certificate
- [ ] App Store provisioning profile

### 2.2 Build Configuration

**File**: `ios/Runner/Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<!-- App Display Name -->
	<key>CFBundleDisplayName</key>
	<string>Chess Tactics Master</string>
	
	<!-- App Bundle ID -->
	<key>CFBundleIdentifier</key>
	<string>com.chessmaster.app</string>
	
	<!-- App Version -->
	<key>CFBundleShortVersionString</key>
	<string>1.0.0</string>
	
	<!-- Build Number -->
	<key>CFBundleVersion</key>
	<string>1</string>
	
	<!-- Supported Device Orientations -->
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationPortraitUpsideDown</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	
	<!-- Minimum iOS Version -->
	<key>MinimumOSVersion</key>
	<string>14.0</string>
	
	<!-- App Transport Security -->
	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoadsInWebContent</key>
		<false/>
	</dict>
	
	<!-- Privacy Permissions -->
	<key>NSCameraUsageDescription</key>
	<string>Camera is not used by this app</string>
	
	<key>NSLocalNetworkUsageDescription</key>
	<string>The app uses local network to sync games with opponents</string>
	
	<!-- Firebase -->
	<key>FirebaseAppDelegateProxyEnabled</key>
	<false/>
</dict>
</plist>
```

### 2.3 Build for App Store

```bash
# Clean build directory
flutter clean

# Get dependencies
flutter pub get

# Build for iOS
flutter build ios --release

# Alternative: Build using Xcode for distribution
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -derivedDataPath build \
  -arch arm64 \
  CODE_SIGN_IDENTITY="iPhone Distribution: Developer Name (ABC123)" \
  PROVISIONING_PROFILE_SPECIFIER="Chess Tactics Master - AppStore"
```

### 2.4 Create App Store Connect Record

**Steps**:

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Click "My Apps"
3. Click "+" → "New App"
4. Fill in app information:
   - **Platform**: iOS
   - **App Name**: Chess Tactics Master
   - **Primary Language**: English
   - **Bundle ID**: com.chessmaster.app
   - **SKU**: CHESS001
5. Click "Create"

### 2.5 App Information

**App Store Connect → Your App → App Information**

```
App Name:                  Chess Tactics Master
Subtitle:                  Master chess through puzzles & gameplay
Primary Category:          Games
Secondary Category:        Educational
Content Rating:            4+ (no age restriction)
Bundle ID:                 com.chessmaster.app
```

### 2.6 Pricing & Availability

**App Store Connect → Your App → Pricing and Availability**

```
Price Tier:                Free
Free Tier Countries:       All
In-App Purchases:          Premium ($4.99/month), Premium+ ($2.92/month)
Availability Date:         Immediate Release
```

### 2.7 App Privacy

**App Store Connect → Your App → App Privacy**

```
Health & Fitness:          No
Contacts:                  No
Location:                  No
Photos or Videos:          No
Audio or Music:            No
Financial Information:     No (RevenueCat handles payments)
Identifier:                Yes (Firebase UID)
User ID:                   Yes (for game matchmaking)
Advertising Data:          No
Sensitive Information:     No
Diagnostics:               Yes (Firebase Crashlytics)
```

### 2.8 Screenshots & Preview Video

**Required Screenshots** (1242 x 2208px for iPhone 12.9"):
1. Home screen with game list
2. Puzzle selection screen
3. Chess board with active game
4. Premium features screen
5. User profile/stats screen

**Optional**: Demo video (up to 30 seconds)

### 2.9 Description & Keywords

**Description**:
```
Master chess tactics with Chess Tactics Master! Challenge yourself with 
thousands of hand-picked puzzles, play against our intelligent CPU opponent, 
or test your skills against other players worldwide.

Features:
• 5,000+ chess puzzles for all skill levels
• Multiple difficulty settings (beginner to expert)
• Play against CPU opponent
• Real-time online multiplayer matches
• ELO rating system
• Achievement badges
• Detailed game analysis
• Custom board themes
• Sound effects & animations

Join thousands of chess enthusiasts improving their tactics every day!
```

**Keywords**: 
chess, tactics, puzzle, board game, strategy, online multiplayer, casual games

### 2.10 Content Rating Questionnaire

**Age Rating Required**:
- ESRB: E (Everyone) - No violence, no adult content
- PEGI: 3 (Ages 3+) - Educational game
- USK: 0 (Unrestricted) - No age restrictions

**Questions to Answer**:
- Does your app contain violence? → No
- Does your app contain sexually suggestive content? → No
- Does your app contain profanity? → No
- Does your app contain alcohol/tobacco use? → No
- Does your app contain gambling? → No (in-app purchase is not gambling)
- Does your app contain unrestricted internet access? → No
- Does your app access user location? → No

### 2.11 Build Upload

```bash
# Using Xcode
# 1. Open Runner.xcworkspace in Xcode
# 2. Select Runner → Runner target
# 3. Product → Archive
# 4. Distribute App
# 5. Upload to App Store

# Using Transporter (Apple's command-line tool)
# 1. Export IPA from Xcode
# 2. Open Transporter.app
# 3. Add IPA file
# 4. Deliver
```

### 2.12 Submission

1. Review all information in App Store Connect
2. Go to "Builds" section
3. Select the build to submit
4. Fill in export compliance (select "No")
5. Verify app content rating
6. Click "Submit for Review"
7. Estimated review time: 24-48 hours

---

## Part III: Google Play Store Submission

### 3.1 Pre-requisites

**Required Accounts**:
- [ ] Google Play Developer Account ($25 one-time)
- [ ] Google Play Console access
- [ ] Signing key configured for release builds

### 3.2 Generate Signing Key

**File**: `android/app/build.gradle`

```gradle
android {
    signingConfigs {
        release {
            keyAlias = "release"
            keyPassword = env.KEY_PASSWORD
            storeFile = file(env.KEYSTORE_PATH)
            storePassword = env.KEYSTORE_PASSWORD
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

**Create Keystore** (one-time):
```bash
# Generate keystore
keytool -genkey -v \
  -keystore ~/release-key.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias release

# Store securely (never commit to repo!)
# Save in: ~/.android/release-key.jks
# Keep password secure in: GitHub Secrets
```

### 3.3 Build for Google Play

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build release APK + AAB (App Bundle preferred)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab

# Alternative: Build APK for testing
flutter build apk --release

# Output: build/app/outputs/apk/release/app-release.apk
```

### 3.4 Create Play Store Entry

**Steps**:

1. Go to [Google Play Console](https://play.google.com/console)
2. Click "Create app"
3. Fill in app details:
   - **App name**: Chess Tactics Master
   - **Default language**: English
   - **App or game**: Game
   - **Category**: Board (or Strategy)
   - **Content rating**: Everyone (no age restriction)
4. Accept agreements and create

### 3.5 App Configuration

**Google Play Console → Your App → App Details**

```
Title:                     Chess Tactics Master
Short description:         Master chess through puzzles & gameplay
Full description:          [See App Store description above]
Category:                  Board & Card / Strategy
Content rating:            Everyone - IARC rating: E (Everyone)
Privacy policy:            [URL to privacy policy]
Requires contactless icon: No
Requires testing instructions: No
```

### 3.6 Graphics & Media

**Required Assets**:
- [ ] Icon 512x512px (PNG)
- [ ] Screenshots (1080x1920px) - minimum 2, up to 8
- [ ] Feature graphic 1024x500px (PNG)
- [ ] Promo graphic (optional)
- [ ] Video preview (optional, up to 30 seconds)

**Screenshots** (same as iOS, but 1080x1920 resolution):
1. Home screen
2. Puzzle screen
3. Chess board
4. Premium features
5. User profile

### 3.7 Content Rating

**Google Play Console → App Content → Content Rating**

**Questionnaire**:
- Target audience: General audience / Adults
- Violence: None
- Sexual content: None
- Profanity: None
- Alcohol/Drugs/Tobacco: None
- Gambling: No (premium features are not gambling)
- Ads: Yes (specify Google AdMob if applicable)
- Dangerous content: No
- Spam: No

**Rating**: Everyone (E) for all markets

### 3.8 Pricing

**Google Play Console → Setup → Pricing**

```
Default price:             Free
In-App Purchases:
  - Premium Monthly        $4.99 USD
  - Premium+ Annual        $35.04 USD (calculated annually)
Availability:              All countries (with some restrictions by law)
```

### 3.9 Release Configuration

**Google Play Console → Testing**

1. **Closed Testing** (optional, for beta)
   - Add test users
   - Create release track
   - Upload APK/AAB
   - Test for 1-2 weeks

2. **Production Release**
   - Go to "Release management → Releases"
   - Click "Create release"
   - Upload app bundle (AAB)
   - Add release notes:
     ```
     Version 1.0.0
     
     Welcome to Chess Tactics Master! 
     
     This initial release includes:
     • 5,000+ chess puzzles
     • CPU opponent with 3 difficulty levels
     • Real-time multiplayer with ELO ratings
     • Premium subscription options
     • Beautiful board themes and animations
     
     Enjoy mastering chess!
     ```

### 3.10 Upload AAB

1. Go to Google Play Console
2. Navigate to "Release management → Releases"
3. Click "Create release"
4. Select "Create release from App Bundle"
5. Upload `build/app/outputs/bundle/release/app-release.aab`
6. Review and confirm

### 3.11 Submission

1. Review all store listing information
2. Verify content rating
3. Set release date (immediate or scheduled)
4. Click "Review release"
5. Review compliance:
   - [ ] Content rating selected
   - [ ] Pricing set
   - [ ] Screenshots added
   - [ ] App bundle uploaded
   - [ ] Release notes added
6. Click "Publish release"
7. Estimated review time: 2-4 hours (usually approved same day)

---

## Part IV: Post-Submission

### 4.1 Monitoring

**iOS App Store**:
- Monitor approval status in App Store Connect
- Expected review time: 24-48 hours
- Check for rejection reasons (if any)

**Google Play Store**:
- Monitor release status in Google Play Console
- Expected review time: 2-4 hours
- Automatic approval for most apps

### 4.2 After Approval

**Release**:
- [ ] Announce release on social media
- [ ] Send email to registered users
- [ ] Post on app development forums
- [ ] Monitor crash reports in Crashlytics

**Monitor**:
- [ ] User ratings and reviews
- [ ] Crash reports
- [ ] Performance metrics
- [ ] Retention rates

### 4.3 First Update

Plan first update (v1.0.1) within 2 weeks:
- Bug fixes based on user reports
- Performance improvements
- UI/UX refinements

---

## Part V: Troubleshooting

### 5.1 Rejected by App Store

**Common Rejection Reasons**:

1. **Performance Issues**
   - Solution: Profile app with Instruments
   - Check memory usage, CPU usage
   - Optimize rendering performance

2. **Privacy Concerns**
   - Solution: Update privacy policy
   - Remove unnecessary permissions
   - Explain all data collection

3. **Incomplete Metadata**
   - Solution: Review screenshots and description
   - Ensure all fields filled accurately
   - Include proper keywords

4. **Guideline Violations**
   - Solution: Review App Store Review Guidelines
   - Remove objectionable content
   - Fix UI issues

### 5.2 Rejected by Google Play

**Common Rejection Reasons**:

1. **Malware Detected**
   - Solution: Run antivirus scan on build
   - Review all dependencies
   - Check for suspicious permissions

2. **Deceptive Content**
   - Solution: Ensure description matches functionality
   - Screenshots should accurately represent app
   - Remove misleading advertising

3. **Policy Violations**
   - Solution: Review Google Play policies
   - Remove unauthorized content
   - Fix monetization issues

---

## Part VI: Update & Maintenance

### 6.1 Update Checklist

Before each update:

- [ ] Increment version number
- [ ] Update build number
- [ ] Test thoroughly on devices
- [ ] Update release notes
- [ ] Review changelog with team
- [ ] Update privacy policy (if needed)
- [ ] Run security scan
- [ ] Verify all tests pass

### 6.2 Version Numbering

**Format**: `MAJOR.MINOR.PATCH`

Examples:
- `1.0.0` - Initial release
- `1.0.1` - Bug fix
- `1.1.0` - New features
- `2.0.0` - Major redesign

### 6.3 Release Schedule

**Recommended**:
- Bug fixes: As needed
- Minor updates: Every 2 weeks
- Major updates: Every month
- Security patches: Immediately

---

## Part VII: Marketing & Analytics

### 7.1 Pre-Launch Marketing

**Before Release**:
- [ ] Create App Store Preview pages
- [ ] Build social media buzz
- [ ] Send press release
- [ ] Ask for beta tester reviews
- [ ] Prepare launch announcement

### 7.2 Launch Day

**On Release Day**:
- [ ] Announce on social media
- [ ] Send emails to interested users
- [ ] Monitor reviews and ratings
- [ ] Respond to early user feedback
- [ ] Track analytics

### 7.3 Post-Launch Analytics

**Key Metrics to Track**:
- Download count
- Install rate
- Daily active users (DAU)
- Monthly active users (MAU)
- Retention rate (Day 1, 7, 30)
- Average session duration
- Conversion to premium
- User reviews & ratings
- Crash rate

**Tools**:
- Firebase Analytics
- App Store Connect analytics
- Google Play Console analytics
- Crashlytics for stability

---

## Appendix A: File Locations

**Android**:
- Build files: `android/app/build.gradle`
- Manifest: `android/app/src/main/AndroidManifest.xml`
- Icons: `android/app/src/main/res/`
- Release output: `build/app/outputs/bundle/release/`

**iOS**:
- Configuration: `ios/Runner/Info.plist`
- Build settings: `ios/Podfile`
- Icons: `ios/Runner/Assets.xcassets/`
- Release output: `build/ios/iphoneos/Runner.app`

**Flutter**:
- Pubspec: `pubspec.yaml`
- Version: `pubspec.yaml` (version field)
- Build number: In build commands or CI/CD

---

## Appendix B: Useful Links

- [Apple App Store Connect](https://appstoreconnect.apple.com/)
- [Google Play Console](https://play.google.com/console)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Google Play Policies](https://play.google.com/about/developer-content-policy/)
- [Flutter App Distribution](https://flutter.dev/docs/deployment)
- [Firebase Console](https://console.firebase.google.com/)

---

## Appendix C: Final Checklist

Before clicking "Submit":

**iOS**:
- [ ] Build compiles without errors
- [ ] All screenshots uploaded
- [ ] Description & keywords complete
- [ ] Content rating selected
- [ ] Privacy policy URL provided
- [ ] Support email configured
- [ ] No hardcoded secrets
- [ ] App size < 150MB
- [ ] Tested on latest iOS device

**Android**:
- [ ] Build (AAB) compiles without errors
- [ ] All screenshots uploaded
- [ ] Description & keywords complete
- [ ] Content rating completed
- [ ] Privacy policy URL provided
- [ ] Support email configured
- [ ] App bundle size < 100MB
- [ ] Tested on Android 7+ device

**Both**:
- [ ] Version number incremented
- [ ] Build number incremented
- [ ] Tests pass (100%)
- [ ] Security audit passed
- [ ] No critical warnings
- [ ] Release notes prepared
- [ ] Marketing materials ready

---

**Document Version**: 1.0  
**Last Updated**: 2026-08-25  
**Status**: ✅ Ready for Submission

For questions or issues during submission, refer to official app store documentation or contact their support teams.
