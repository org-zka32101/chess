# Apple Sign-In Setup Guide

Complete setup instructions for implementing Sign-In with Apple in Chess Tactics Master.

## Overview

Sign-In with Apple allows users to authenticate using their Apple account on iOS 13+. This guide covers all setup steps needed for iOS development and production release.

**Note**: Apple Sign-In is iOS only. Android and web users will use Google Sign-In or email/password authentication.

## Prerequisites

- Apple Developer account (paid membership)
- Xcode 11+
- iOS 13+ deployment target
- Firebase project with Apple Sign-In configured
- Team ID from Apple Developer account

---

## Step 1: Apple Developer Account Setup

### 1.1 Verify Apple Developer Membership

1. Go to [Apple Developer Account](https://developer.apple.com/account/)
2. Sign in with your Apple ID
3. Go to **Membership** section
4. Verify membership is active (paid required)
5. Note your **Team ID** (10-character code)

### 1.2 Enable Sign-In with Apple

1. Go to **Certificates, Identifiers & Profiles**
2. Select **Identifiers** from sidebar
3. Select your app's identifier (or create new)
4. Check **Sign in with Apple** capability
5. Click **Save**

---

## Step 2: Configure Service ID for Apple Sign-In

### 2.1 Create Service ID

1. Go to **Certificates, Identifiers & Profiles** → **Identifiers**
2. Click the **+** button to create new identifier
3. Select **Services IDs**
4. Click **Continue**
5. Fill in:
   - **Description**: "Chess Tactics Master Sign-In" (or similar)
   - **Identifier**: `com.chessmaster.signin` (must be unique)
6. Click **Continue** then **Register**

### 2.2 Configure Sign-In with Apple

1. Back in Identifiers list, select your new Service ID
2. Check **Sign In with Apple** capability
3. Click **Configure**
4. Ensure **Primary App ID** is set to your main app ID
5. Add **Domains and Subdomains** (if using custom domain):
   - Example: `auth.chessmaster.app`
6. Add **Return URLs** (where user redirected after sign-in):
   - Example: `https://auth.chessmaster.app/callback`
7. Click **Done**
8. Click **Save**

---

## Step 3: Create Sign-In with Apple Certificate

### 3.1 Request Certificate

1. Go to **Certificates, Identifiers & Profiles** → **Certificates**
2. Click **+** to create new certificate
3. Select **Sign in with Apple** under Services
4. Click **Continue**
5. Select your Primary App ID
6. Click **Continue**
7. Follow instructions to create Certificate Signing Request (CSR)

### 3.2 Download Certificate

1. Upload your CSR file
2. Click **Continue**
3. Download the certificate (`.cer` file)
4. Install to Keychain (double-click or drag to Keychain)

---

## Step 4: Configure Xcode Project

### 4.1 Set Bundle ID

1. Open Xcode project: `ios/Runner.xcworkspace`
2. Select **Runner** project
3. Select **Runner** target
4. Go to **General** tab
5. Set **Bundle Identifier** to match Apple Developer ID
   - Example: `com.example.chessmaster`

### 4.2 Set Team ID

1. Still in Runner target settings
2. Go to **Signing & Capabilities** tab
3. Set **Team ID** to your Apple Developer Team ID
4. Xcode auto-manages signing

### 4.3 Add Sign-In with Apple Capability

1. Click **+ Capability** button
2. Search for and select **Sign in with Apple**
3. Verify it's added to entitlements

### 4.4 Configure Entitlements

Xcode should auto-generate `Runner.entitlements` with:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>
</dict>
</plist>
```

If missing, add manually.

---

## Step 5: Configure Firebase

### 5.1 Add Apple as Auth Provider

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your Chess Tactics Master project
3. Go to **Authentication** → **Sign-in method**
4. Click **Add new provider** → **Apple**
5. Enable the provider
6. Register your Service ID:
   - **Service ID**: `com.chessmaster.signin` (from Step 2.1)
   - **Team ID**: Your 10-character Team ID
   - **Key ID**: From your certificate (in Apple Developer portal)
   - **Private Key**: Download from Apple Developer portal

### 5.2 Download GoogleService-Info.plist

1. Go to **Project Settings** → **Your apps** → **iOS app**
2. Download updated `GoogleService-Info.plist`
3. In Xcode: Drag & drop into `ios/Runner/` folder
4. Select "Copy items if needed"

---

## Step 6: Verify pubspec.yaml Dependencies

Ensure these are in `pubspec.yaml`:

```yaml
dependencies:
  sign_in_with_apple: ^5.0.0
  firebase_auth: ^4.16.0
  firebase_core: ^2.24.0
```

Run: `flutter pub get`

---

## Step 7: Test Apple Sign-In

### On iOS Simulator

1. Open **Xcode** → **Simulator** app (or use `open -a Simulator`)
2. Select an iOS 13+ simulator
3. Run the app: `flutter run -d <device-id>`
4. Navigate to Login screen
5. Tap "Sign in with Apple"
6. Select test iCloud account
7. Grant permissions when prompted
8. App should authenticate and navigate to home screen

### On Physical iOS Device

1. Connect iPhone with iOS 13+
2. Run: `flutter run`
3. Follow same steps as simulator
4. Test with your actual Apple ID

### Test Sign-In with Email Hiding

1. In Sign-In with Apple dialog, tap "Hide My Email"
2. Apple provides a private relay email
3. App should handle gracefully
4. Fallback email used if needed

---

## Troubleshooting

### Error: "SDK Version Too Low"
- Solution: Ensure iOS deployment target is 13.0+
- In Xcode: Runner → Build Settings → iOS Deployment Target = 13.0

### Error: "Entitlements File Missing"
- Solution: Ensure `Runner.entitlements` exists and has proper content
- Xcode may auto-generate when you add capability

### Error: "Service ID Not Configured"
- Solution: Verify Service ID exists in Apple Developer portal
- Ensure it's enabled for Sign in with Apple
- Check in Firebase that Service ID is registered

### Error: "Certificate Not Found"
- Solution: Verify certificate installed in Keychain
- Download fresh certificate from Apple Developer portal

### Error: "Team ID Mismatch"
- Solution: Ensure Team ID in Xcode matches:
  - Apple Developer account Team ID
  - Team ID in Firebase configuration

### App Crashes When Tapping Sign-In with Apple
- Solution: Check console logs for specific error
- Verify all Xcode configurations are correct
- Run `flutter clean` and rebuild

### Sign-In Works on Simulator but Not Device
- Solution: Check Team ID and Certificate on device
- Ensure device is signed with same Team ID
- Try signing out of iCloud and back in on device

---

## Production Setup

### Before Release to App Store

1. **Verify Certificate is current**: Not expired
2. **Test on physical iOS device**: With your Apple ID
3. **Test email hiding**: Ensure app handles private relay emails
4. **Update Build Number**: Increment for submission
5. **Verify Bundle ID**: Matches App Store configuration

### App Store Submission Checklist

- [ ] Apple Sign-In capability added to Xcode
- [ ] Entitlements file configured
- [ ] Service ID created and enabled
- [ ] Certificate generated and installed
- [ ] Team ID set in Xcode
- [ ] GoogleService-Info.plist updated
- [ ] sign_in_with_apple package in pubspec.yaml
- [ ] Tested on iOS device
- [ ] App Store listing mentions Apple Sign-In
- [ ] Privacy Policy updated (if needed)

---

## Security Best Practices

1. **Keep certificate private**: Never commit to Git
2. **Rotate certificates**: Before expiration
3. **Validate tokens**: Firebase does this automatically
4. **Handle email hiding**: Use fallback email gracefully
5. **Secure private relay email**: Don't expose to user if hidden
6. **Update entitlements**: When changing Service ID

---

## Testing Scenarios

### Happy Path
- User taps Sign in with Apple
- Enters Apple ID credentials
- Grants permission for email/name
- App creates account and navigates home

### New User (First Sign-In)
- Apple provides email and full name
- User document created with provided data
- Subsequent sign-ins retrieve same user

### Existing User
- User who previously signed in taps Sign in with Apple
- App recognizes user and loads existing account
- No duplicate user created

### Email Hiding
- User selects "Hide My Email"
- Apple provides private relay email
- App receives and uses relay email
- User can still access account

### Missing Name
- User doesn't provide full name (first time)
- App uses fallback name "Apple User"
- User can update profile later

### Device Unsupported
- Android or old iOS device
- App shows error: "Sign in with Apple not available"
- User can use other auth methods

### Network Failure
- Network error during Apple communication
- App shows error message
- User can retry

---

## References

- [Apple Sign-In Developer Docs](https://developer.apple.com/sign-in-with-apple/)
- [Sign in with Apple Documentation](https://developer.apple.com/documentation/signinwithappleframework)
- [Flutter sign_in_with_apple Package](https://pub.dev/packages/sign_in_with_apple)
- [Firebase Authentication](https://firebase.flutter.dev/docs/auth/overview)
- [Apple Developer Account](https://developer.apple.com/account/)

---

## Important Notes

### iOS Only
- Apple Sign-In is only available on iOS 13+
- Android users must use Google Sign-In or email/password
- Web users must use Google Sign-In or email/password

### First Sign-In Only
- Apple only provides email/name on first sign-in
- Subsequent sign-ins just confirm identity
- If user changes settings in Apple ID, info may change on next sign-in

### Email Hiding
- Users can hide email with private relay option
- App receives private relay email from Apple
- Email appears to be from `privateXXXX@privaterelay.appleid.com`
- User can view real email in Apple ID settings

### Privacy
- Apple strongly emphasizes privacy
- Minimal data collection required
- IDFA tracking not available via Apple Sign-In
- No cross-app tracking

---

**Last Updated**: 2026-08-28  
**Status**: ✅ Complete Setup Instructions Ready for Implementation
