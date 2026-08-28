# Google Sign-In Setup Guide

Complete setup instructions for implementing Google Sign-In in Chess Tactics Master.

## Overview

Google Sign-In allows users to authenticate using their Google account. This guide covers all setup steps needed for both Android and iOS platforms.

## Prerequisites

- Google Cloud Console access (https://console.cloud.google.com)
- Firebase project already created
- Android and/or iOS development environment configured

---

## Step 1: Configure Google Cloud Console

### 1.1 Create OAuth 2.0 Credentials

1. Go to Google Cloud Console: https://console.cloud.google.com
2. Select your Chess Tactics Master project
3. Navigate to: **APIs & Services** → **Credentials**
4. Click **Create Credentials** → **OAuth 2.0 Client IDs**

### 1.2 Create Android Credentials

1. Choose **Application type**: Android
2. Fill in:
   - Package name: `com.example.chessmaster` (or your actual package name)
   - SHA-1 certificate fingerprint: (see Step 2 below)
3. Click **Create**
4. Download the OAuth 2.0 Client ID (you'll get the certificate fingerprint from Step 2)

### 1.3 Create iOS Credentials

1. Choose **Application type**: iOS
2. Fill in:
   - Bundle ID: `com.example.chessmaster` (or your actual bundle ID)
3. Click **Create**
4. Note the **iOS URL Scheme** for later use

---

## Step 2: Get Android SHA-1 Certificate Fingerprint

The SHA-1 fingerprint is needed to register your Android app with Google.

### For Debug Key (Development)

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Look for the line starting with `SHA1:` in the output.

### For Release Key (Production)

```bash
keytool -list -v -keystore /path/to/your/release.keystore -alias releasekey -storepass YOUR_STOREPASS -keypass YOUR_KEYPASS
```

### Register with Google Cloud

1. Go back to Google Cloud Console → Credentials
2. Find your Android OAuth client
3. Click to edit
4. Add the SHA-1 fingerprint
5. Save changes

---

## Step 3: Configure Android App

### 3.1 Update android/app/build.gradle

Ensure your package name matches Google Cloud config:

```gradle
android {
    defaultConfig {
        applicationId "com.example.chessmaster"
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### 3.2 Download google-services.json

1. Go to Firebase Console → Project Settings
2. Download `google-services.json`
3. Place in: `android/app/google-services.json`

### 3.3 Update Android Manifest

Verify `android/app/src/main/AndroidManifest.xml` has:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### 3.4 Build and Test

```bash
flutter pub get
flutter run
```

Test Google Sign-In on Android device or emulator.

---

## Step 4: Configure iOS App

### 4.1 Update Bundle ID

In Xcode:
1. Open `ios/Runner.xcworkspace`
2. Select Runner project
3. Set **Bundle ID** to match Google Cloud config (e.g., `com.example.chessmaster`)

### 4.2 Configure URL Scheme

In Xcode:
1. Select Runner → Targets → Runner
2. Go to **Info** tab
3. Expand **URL Types**
4. Add new URL Type with:
   - **Identifier**: `com.googleusercontent.apps.[your-client-id]`
   - **URL Schemes**: `com.googleusercontent.apps.[your-client-id]`

Where `[your-client-id]` is from your iOS OAuth 2.0 credentials.

### 4.3 Download GoogleService-Info.plist

1. Go to Firebase Console → Project Settings
2. Download `GoogleService-Info.plist`
3. In Xcode: Drag & drop into `ios/Runner/` folder
4. Select "Copy items if needed"

### 4.4 Update Podfile

Ensure `ios/Podfile` has:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

### 4.5 Build and Test

```bash
flutter pub get
cd ios && pod update && cd ..
flutter run -d ios
```

Test Google Sign-In on iOS simulator or device.

---

## Step 5: Verify pubspec.yaml Dependencies

Ensure these are in `pubspec.yaml`:

```yaml
dependencies:
  google_sign_in: ^6.2.0
  firebase_auth: ^4.16.0
  firebase_core: ^2.24.0
```

Run: `flutter pub get`

---

## Step 6: Test Google Sign-In

### Android Testing

1. Run app on Android device/emulator
2. Go to Login screen
3. Tap "Sign in with Google"
4. Select Google account or sign in
5. Grant permissions when prompted
6. App should authenticate and navigate to home screen

### iOS Testing

1. Run app on iOS simulator/device
2. Go to Login screen
3. Tap "Sign in with Google"
4. Web browser opens with Google Sign-In
5. Select Google account
6. Grant permissions when prompted
7. Return to app (should be authenticated)

---

## Troubleshooting

### Android Issues

**Error**: "10: API_PROJECT_SETUP_REQUIRED"
- Solution: Verify SHA-1 fingerprint is registered in Google Cloud

**Error**: "12: DEVELOPER_ERROR"
- Solution: Check package name matches in Google Cloud and app

**Error**: "Sign in cancelled"
- Normal behavior when user cancels the sign-in flow

### iOS Issues

**Error**: "Could not connect to service"
- Solution: Verify URL Scheme is configured correctly in Xcode

**Error**: "Invalid Client" in Safari
- Solution: Check GoogleService-Info.plist is added to Xcode project

**Error**: "App not configured"
- Solution: Ensure Bundle ID matches in Google Cloud Console

---

## Production Setup

### Before Release to App Store/Play Store

1. **Get Production Keystore SHA-1** (see Step 2)
2. **Register with Google Cloud** using production SHA-1
3. **Test on physical devices** before release
4. **Update GoogleService-Info.plist** and google-services.json if needed for production

### Release Checklist

- [ ] Android SHA-1 registered in Google Cloud
- [ ] iOS Bundle ID and URL Scheme configured
- [ ] GoogleService-Info.plist in Xcode
- [ ] google-services.json in android/app/
- [ ] google_sign_in package version pinned in pubspec.yaml
- [ ] Google Sign-In tested on physical Android device
- [ ] Google Sign-In tested on physical iOS device
- [ ] Error handling verified
- [ ] No hardcoded credentials in code

---

## Security Best Practices

1. **Never commit credentials**: Keep google-services.json and GoogleService-Info.plist private
2. **Use separate OAuth apps**: Separate OAuth credentials for dev/staging/production
3. **Validate ID tokens**: Firebase automatically validates ID tokens from Google
4. **Handle exceptions**: Catch and log errors appropriately
5. **Test error scenarios**: Network failures, user cancellations, invalid accounts

---

## Testing Scenarios

### Happy Path
- User taps Google Sign-In
- Selects Google account
- App authenticates and creates user
- Navigation to home screen

### User Cancellation
- User taps Google Sign-In
- Taps "Cancel"
- App handles gracefully, no error shown
- User remains on login screen

### Network Failure
- Network error during Google authentication
- App shows error message
- User can retry

### Existing User
- User with existing account signs in with Google
- App retrieves existing user data
- No duplicate user created

---

## References

- [Google Sign-In Documentation](https://developers.google.com/identity)
- [Flutter Google Sign-In Package](https://pub.dev/packages/google_sign_in)
- [Firebase Authentication](https://firebase.flutter.dev/docs/auth/overview)
- [Google Cloud Console](https://console.cloud.google.com)

---

## Support

For issues or questions about Google Sign-In setup:
1. Check the troubleshooting section above
2. Review Flutter package documentation
3. Check Firebase documentation
4. Contact Google Cloud support if credentials issue

---

**Last Updated**: 2026-08-28  
**Status**: ✅ Complete Setup Instructions Ready for Implementation
