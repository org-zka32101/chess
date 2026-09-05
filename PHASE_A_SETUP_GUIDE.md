# PHASE A: FOUNDATION - SETUP GUIDE

**Status**: 🚀 Ready to begin implementation  
**Last Updated**: 2026-08-27  
**Target**: Get app running in development environment by EOD

---

## Overview

This guide walks through setting up Chess Tactics Master for development. The app is ~80% complete at the code level but requires Firebase configuration to run properly.

### Quick Status
- ✅ Flutter project scaffold complete (111 Dart files, 18+ services)
- ✅ Firebase dependencies configured
- ✅ Riverpod state management in place
- ✅ Auth screens implemented (email, Google, Apple)
- ✅ Home screen and navigation structure ready
- ⚠️ Firebase credentials need configuration (BLOCKER)
- ⚠️ Environment setup incomplete (BLOCKER)
- ⚠️ Code generation may need running (BLOCKER)

---

## Prerequisites

### System Requirements

#### macOS (for iOS development)
```bash
# Check Flutter version
flutter --version          # Should output 3.24.0 or higher

# Check Dart version
dart --version             # Should output 3.x

# Check Xcode
xcode-select --print-path  # Should show Xcode path

# Check CocoaPods
pod --version              # Should output 1.11.0 or higher
```

#### Windows/Linux (for Android development)
```bash
# Check Flutter version
flutter --version          # Should output 3.24.0 or higher

# Check Dart version
dart --version             # Should output 3.x

# Check Android SDK
flutter doctor             # Should show green for Android SDK
```

#### All Platforms
- Git installed and configured
- IDE (VS Code, Android Studio, or Xcode)
- Terminal/command line access

---

## Step 1: Clone & Setup Repository

```bash
# Clone the repository (already done if reading this locally)
git clone https://github.com/org-zka32101/chess.git
cd chess

# Checkout development branch
git checkout claude/chess-j8fad7

# Verify you're on correct branch
git branch -v  # Should show * claude/chess-j8fad7
```

---

## Step 2: Install Dependencies

### Download Flutter packages
```bash
flutter pub get
```

**Expected Output**:
```
Running "flutter pub get" in chess...
Getting dependencies...
...
Got dependencies in X.XXs.
```

**If it fails**:
- Check internet connection
- Run `flutter pub cache repair` to clear cache
- Delete `pubspec.lock` and try again

### Verify no issues
```bash
flutter doctor
```

**Expected Output**:
```
[✓] Flutter (Channel stable, 3.24.0, ...)
[✓] Android toolchain - develop for Android devices (...)
[✓] Xcode - develop for iOS and macOS (...)
[✓] VS Code (...)
```

If anything shows ✗, follow the instructions to fix it.

---

## Step 3: Configure Environment

### Create .env file for development

```bash
# The repository includes .env file with development defaults
# Verify it exists
ls -la .env
```

**Current .env contents** (development/testing values):
```
FIREBASE_API_KEY=AIzaSyDn5Bk0Xz9W2j7K4L5M6N7O8P9Q0R1S2T
FIREBASE_APP_ID=1:234567890:web:abcdef1234567890ghij
FIREBASE_MESSAGING_SENDER_ID=234567890
FIREBASE_PROJECT_ID=yourwish-chess
FIREBASE_AUTH_DOMAIN=yourwish-chess.firebaseapp.com
FIREBASE_DATABASE_URL=https://yourwish-chess.firebaseio.com
FIREBASE_STORAGE_BUCKET=yourwish-chess.appspot.com
FIREBASE_IOS_BUNDLE_ID=com.yourwish.chess
FIREBASE_ANDROID_PACKAGE_NAME=com.yourwish.chess
```

**⚠️ IMPORTANT**: These are **NOT** real credentials. For development, they allow the app to compile and run without Firebase. For production/testing with real Firebase, you must replace these values.

---

## Step 4: Generate Code

Dart/Flutter uses code generation for several libraries. You need to run the build_runner to generate:
- Freezed immutable models (`.freezed.dart` files)
- Riverpod providers
- JSON serialization code

### Run code generation
```bash
dart run build_runner build
```

**Expected Output**:
```
[INFO] Generating build script...
[INFO] Generating build script completed, took XXX ms
[INFO] Reading cached asset graph...
[INFO] Reading cached asset graph completed, took XXX ms
[INFO] Checking for unexpected pre-existing outputs...
[INFO] Generating build script...
...
[INFO] Build completed successfully
```

**If build fails**:
```bash
# Clean and rebuild
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

**Common issues**:
- Circular dependencies → Check model imports
- Generated file conflicts → Use `--delete-conflicting-outputs`
- OutOfMemory → Increase heap: `dart run build_runner build --verbose`

---

## Step 5: Run the App

### On Android emulator
```bash
# Start Android emulator first (or connect physical device)
emulator -avd YourEmulatorName &

# Wait for emulator to start, then run
flutter run
```

### On iOS simulator
```bash
# Start iOS simulator first
open -a Simulator

# Run the app
flutter run
```

### On physical device
```bash
# Connect device and enable USB debugging

# Run the app
flutter run

# Or specify device
flutter run -d [device_id]

# List available devices
flutter devices
```

### Expected Output on Launch
```
Launching lib/main.dart on [Device Name]...
...
✓ Built [app name]
✓ Installed [app name]
Launching the app...
```

### App Should:
- ✅ Launch without crashes
- ✅ Show splash screen
- ✅ Transition to login screen
- ✅ Display "Email", "Google", "Apple Sign In" buttons
- ✅ All UI visible without errors
- ⚠️ Firebase auth likely won't work without real credentials
- ⚠️ This is EXPECTED in development

---

## Step 6: Verify Basic Functionality

Once app is running, test these flows:

### 1. Navigation Works
- [ ] App displays login screen
- [ ] No errors in console
- [ ] Buttons are responsive

### 2. Auth UI Functions (won't connect to Firebase yet)
- [ ] Can tap "Email" button
- [ ] Can tap "Google" button
- [ ] Can tap "Apple" button
- [ ] No crashes on auth attempts

### 3. Console Logs Look Good
- [ ] Should see: `✅ Firebase initialized successfully` (if Firebase works)
- [ ] Should see development logs in console
- [ ] No error spam

### 4. Hot Reload Works
- [ ] Make small code change
- [ ] Press `r` in terminal to hot reload
- [ ] Change appears immediately
- [ ] No compilation errors

---

## Step 7: Configure Real Firebase (For Testing)

When ready to test with actual Firebase:

### 1. Create Firebase Project
```bash
# Open Firebase Console
# https://console.firebase.google.com/

# Create new project (or use existing 'yourwish-chess')
# Project Name: Chess Tactics Master
# Enable Google Analytics (optional)
```

### 2. Add Firebase Apps
```bash
# In Firebase Console → Project Settings → Add App

# For Android:
# - Package name: com.yourwish.chess
# - SHA-1 fingerprint: [get from setup]
# - Download google-services.json
# - Place in: android/app/google-services.json

# For iOS:
# - Bundle ID: com.yourwish.chess
# - Download GoogleService-Info.plist
# - Place in: ios/Runner/GoogleService-Info.plist
```

### 3. Update .env with Real Credentials
```bash
# Copy real values from Firebase Console
# Project Settings → General → SDK config

# Example:
FIREBASE_API_KEY=AIzaSy...actualKeyHere...
FIREBASE_APP_ID=1:123456:ios:abcdef
# ... etc

# Keep .env in .gitignore - never commit real credentials
```

### 4. Re-run app
```bash
flutter run
```

Now Firebase auth should work!

---

## Troubleshooting

### ❌ "Cloud Firestore requires a real credential"
**Cause**: Using placeholder Firebase credentials  
**Solution**: Replace with real credentials from Firebase Console (.env file)

### ❌ "Flutter command not found"
**Cause**: Flutter SDK not in PATH  
**Solution**: 
```bash
# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"

# Or install Flutter properly
```

### ❌ "Gradle build failed"
**Cause**: Android SDK issues  
**Solution**: 
```bash
flutter clean
cd android && gradlew clean
cd ..
flutter pub get
flutter run
```

### ❌ "Pod install failed"
**Cause**: iOS dependency issues  
**Solution**:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter run
```

### ❌ "Code generation failed"
**Cause**: Conflicting or corrupted generated files  
**Solution**:
```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### ❌ "App crashes on startup"
**Cause**: Multiple possible issues  
**Solution**:
1. Check console for specific error
2. Run `flutter doctor -v` to verify setup
3. Try `flutter clean && flutter pub get`
4. Check for recent changes that broke something

### ❌ "Hot reload not working"
**Cause**: Compilation error in changes  
**Solution**: 
1. Check console for error details
2. Revert problematic change
3. Run full build: `flutter run --no-fast-start`

---

## Development Workflow

### Daily Development
```bash
# Start emulator
emulator -avd YourEmulator &

# Navigate to project
cd /path/to/chess

# Get latest code
git pull origin claude/chess-j8fad7

# Run app
flutter run

# Make changes in your editor
# Hot reload with 'r' in terminal
# Or hot restart with 'R'
```

### Creating a Feature Branch
```bash
# Update development branch
git checkout claude/chess-j8fad7
git pull origin claude/chess-j8fad7

# Create feature branch
git checkout -b feat/my-feature

# Make changes...
# Commit changes
git add .
git commit -m "feat: Description of changes"

# Push to GitHub
git push -u origin feat/my-feature

# Create Pull Request on GitHub
```

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/services/chess_engine_test.dart

# Run integration tests
cd integration_test
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart
```

### Code Quality
```bash
# Format code
dart format lib/

# Check linting
dart analyze lib/

# Fix linting issues
dart fix --apply

# Run full analysis
dart analyze --fatal-infos
```

---

## Environment Breakdown

### .env File Structure

**Firebase Config Section**
```
# These should match your Firebase project credentials
FIREBASE_API_KEY=...
FIREBASE_APP_ID=...
FIREBASE_MESSAGING_SENDER_ID=...
FIREBASE_PROJECT_ID=yourwish-chess
FIREBASE_AUTH_DOMAIN=yourwish-chess.firebaseapp.com
FIREBASE_DATABASE_URL=https://yourwish-chess.firebaseio.com
FIREBASE_STORAGE_BUCKET=yourwish-chess.appspot.com
```

**Platform Config Section**
```
# iOS app identifier
FIREBASE_IOS_BUNDLE_ID=com.yourwish.chess

# Android app identifier
FIREBASE_ANDROID_PACKAGE_NAME=com.yourwish.chess
```

**Development Config Section**
```
# Enable debug logging
ENABLE_DEBUG_LOGS=true

# Use mock data instead of Firebase
ENABLE_MOCK_DATA=false

# Show developer menu
ENABLE_DEV_MENU=true
```

### Modifying .env

```bash
# Edit .env file
nano .env

# Or use your editor (VS Code, etc.)
code .env

# Changes take effect on app restart
# No rebuild needed, .env is loaded at runtime
```

---

## Next Steps After Setup

Once app is running successfully:

1. **Verify Phase A Checklist**
   - [ ] App launches without errors
   - [ ] All screens navigate correctly
   - [ ] Firebase integration working (or gracefully fails)
   - [ ] No lint/analysis errors

2. **Begin Implementation**
   - Start with Priority 1 tasks (see PHASE_A_IMPLEMENTATION_ASSESSMENT.md)
   - Focus on Firebase config first if real data needed
   - Then move to UI polish

3. **Code Review**
   - Push changes to feature branch
   - Create pull request
   - Ensure CI/CD pipeline passes

4. **Testing**
   - Write unit tests for new code
   - Test on real device if possible
   - Check performance with DevTools

---

## Resources

### Official Documentation
- [Flutter Docs](https://flutter.dev/docs)
- [Dart Docs](https://dart.dev/guides)
- [Firebase for Flutter](https://firebase.flutter.dev)
- [Riverpod Docs](https://riverpod.dev)

### Project Documentation
- [CLAUDE.md](./CLAUDE.md) - Project guide and technical reference
- [PHASE_A_IMPLEMENTATION_ASSESSMENT.md](./scratchpad/PHASE_A_IMPLEMENTATION_ASSESSMENT.md) - Detailed implementation plan
- Online Multiplayer Design: `online-multiplayer-detailed-design.md`

### Community
- [Flutter Community Slack](https://flutter.dev/community)
- [Dart Discourse](https://discourse.dart.dev)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

---

## Support & Questions

### If you're stuck:
1. Check console output for specific error
2. Search this guide's troubleshooting section
3. Check project's GitHub issues
4. Ask in team chat or open a discussion

### Reporting Issues
When reporting bugs, include:
- Error message (full console output)
- Steps to reproduce
- Device/platform (iOS, Android, emulator)
- Flutter/Dart versions
- Any recent changes

---

## Summary

**Status**: Ready to run ✅  
**Current Step**: Complete steps 1-5 above to get app running  
**Expected Time**: 15-30 minutes  
**Blocker Resolution**: Firebase credentials (can use placeholders for initial development)  
**Next**: Move to PHASE_A tasks once app is running

**Good luck! 🚀**

---

**Last Updated**: 2026-08-27  
**Maintained By**: Claude (AI Developer)  
**Questions?**: Check CLAUDE.md or project GitHub issues
