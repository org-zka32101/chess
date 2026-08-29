# Build Validation Guide - Phase D

## 🚨 Critical Discovery

The project currently **lacks Android and iOS native directories**. This is normal for early-stage development but **required for release**. This guide covers both validation and setup.

---

## Pre-Build Checklist

### Environment Setup
- [ ] Flutter SDK installed (3.24.0+)
- [ ] Dart SDK installed (3.0.0+)
- [ ] CocoaPods installed (macOS/iOS)
- [ ] Android SDK configured (API 24+)
- [ ] Xcode installed (macOS)
- [ ] Android Studio installed (or CLI tools)

### Project Setup
- [ ] `pubspec.yaml` valid and complete
- [ ] All dependencies defined
- [ ] No conflicting dependency versions
- [ ] `analysis_options.yaml` properly configured

---

## Stage 2A: Dependency Validation

### Current Dependencies (Valid ✅)

```yaml
Core Framework:
  flutter: SDK ✓
  dart: >=3.0.0 <4.0.0 ✓

State Management:
  riverpod: ^2.4.0 ✓
  flutter_riverpod: ^2.4.0 ✓

Firebase (26 packages total):
  firebase_core: ^2.24.0 ✓
  firebase_auth: ^4.16.0 ✓
  cloud_firestore: ^4.14.0 ✓
  firebase_database: ^10.2.0 ✓
  firebase_storage: ^11.5.0 ✓
  firebase_analytics: ^10.7.0 ✓
  firebase_crashlytics: ^3.3.0 ✓

Chess Engine:
  chess: ^0.7.2 ✓

UI/Assets:
  flutter_lottie: ^2.7.0 ✓
  google_fonts: ^6.1.0 ✓
  flutter_svg: ^2.0.0 ✓

Local Storage:
  sqflite: ^2.3.0 ✓
  path_provider: ^2.1.1 ✓

Code Generation:
  freezed: ^2.4.1 (dev) ✓
  json_serializable: ^6.7.1 (dev) ✓
  riverpod_generator: ^2.3.0 (dev) ✓
```

### Dependency Validation Commands

```bash
# Check pubspec.yaml syntax
dart pub get

# Check for outdated packages
dart pub outdated

# Check for dependency conflicts
dart pub deps --format=compact

# Check for security vulnerabilities
dart pub audit
```

---

## Stage 2B: Code Quality Checks

### Linting Configuration
- [x] `analysis_options.yaml` present (194 lint rules configured)
- [x] Flutter lints included
- [x] Comprehensive error and style rules

### Pre-Build Code Quality Commands

```bash
# Analyze code for errors/warnings
dart analyze lib/

# Format code to standard
dart format lib/

# Check formatting without modifying
dart format --output=none --set-exit-if-changed lib/

# Generate code (Riverpod, Freezed, JSON)
dart run build_runner build --delete-conflicting-outputs
```

### Expected Results
```
Code Format:       ✅ PASS
Analyzer Warnings: ⚠️  Review needed
Build Output:      🔄 Generates:
  - generated/ (Riverpod code)
  - **/*.freezed.dart (data models)
  - **/*.g.dart (JSON serialization)
```

---

## Stage 2C: Pub Dependencies Validation

### Required Steps

```bash
# 1. Clean previous dependencies
flutter clean

# 2. Get fresh dependencies
flutter pub get

# 3. Verify no conflicts
dart pub deps
```

### What Gets Pulled

```
Direct:              32 packages
  Firebase:          7 core packages + 20 plugins
  Flutter:           Core SDK
  Riverpod:          2 packages
  Chess Engine:      1 package
  UI Libraries:      3 packages
  
Transitive:          150+ packages (automatic)
  HTTP, JSON parsing, native bindings, etc.

Size Impact:
  pubspec.lock:      ~5-10 MB
  pub-cache:         ~500 MB (first time)
  Build artifacts:   ~200-400 MB (per platform)
```

---

## Stage 2D: Native Build Setup (CRITICAL)

### ⚠️ Current Status: Android & iOS Directories Missing

The Flutter project is missing the native build directories. This must be done before building for release.

### Option A: Using `flutter create` (Recommended)

```bash
# Create new Flutter project structure
flutter create --org com.yourwish.chess --project-name chess_tactics_master .

# Or just initialize native directories
flutter create . --platforms android,ios
```

### Option B: Manual Setup

#### Initialize Android Build

```bash
# Navigate to project root
cd /home/user/chess

# Create Android directory structure
mkdir -p android/app/src/main/kotlin/com/yourwish/chess
mkdir -p android/app/src/main/res/values

# Android configuration needed:
# - android/build.gradle (root)
# - android/app/build.gradle
# - android/app/src/main/AndroidManifest.xml
# - android/local.properties
# - android/gradle.properties
```

#### Initialize iOS Build

```bash
# Create iOS directory structure
mkdir -p ios/Runner

# iOS configuration needed:
# - ios/Podfile
# - ios/Runner/GeneratedPluginRegistrant.swift
# - ios/Runner.xcodeproj/
# - ios/Runner.xcworkspace/
```

### Option C: From Git History (If Available)

```bash
# If native directories were committed before
git checkout -- android/ ios/
```

---

## Stage 2E: Build Validation Steps

### Step 1: Clean Build Environment

```bash
# Remove previous build artifacts
flutter clean
rm -rf build/
rm -rf .dart_tool/

# Fresh pub get
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Step 2: Analyze Code

```bash
# Run static analysis
dart analyze lib/ --no-pub

# Expected: No errors, review warnings
```

### Step 3: Format Code

```bash
# Format all Dart files
dart format lib/ test/

# Check if formatting needed
dart format --output=none --set-exit-if-changed lib/
```

### Step 4: Build for Debug (All Platforms)

#### iOS Debug Build
```bash
flutter build ios --debug --verbose

# Expected: 
# - XCode build succeeds
# - App creates Runner.app
# - Size: ~100-150 MB
```

#### Android Debug Build
```bash
flutter build apk --debug --verbose

# Expected:
# - Gradle build succeeds
# - Creates app-debug.apk
# - Size: ~50-80 MB
```

### Step 5: Build for Release

#### iOS Release Build
```bash
flutter build ios --release --verbose

# Expected:
# - XCode build succeeds
# - Creates Runner.app
# - Size: ~80-120 MB (compressed)
```

#### Android Release Build
```bash
flutter build apk --release --verbose

# Expected:
# - Gradle build succeeds
# - Creates app-release.apk
# - Size: ~30-50 MB (compressed)
```

#### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release

# Expected:
# - Gradle build succeeds
# - Creates app-release.aab
# - Size: ~20-40 MB (base bundle)
```

---

## Build Output Checklist

### Android Build Outputs

```
build/app/outputs/apk/
├── debug/
│   └── app-debug.apk          (Unoptimized, for testing)
└── release/
    └── app-release.apk        (Optimized, for Play Store)

build/app/outputs/bundle/
└── release/
    └── app-release.aab        (Recommended for Play Store)
```

### iOS Build Outputs

```
build/ios/Release/
├── Runner.app/                (App bundle)
├── Runner.app.dSYM/          (Debug symbols)
└── iphoneos/                  (Platform-specific build)
```

---

## Performance Baseline

### Build Times (Expected)

| Build Type | Time | Notes |
|-----------|------|-------|
| **Debug APK** | 30-60s | First build slower due to gradle setup |
| **Release APK** | 60-90s | Includes optimization passes |
| **App Bundle** | 45-75s | Play Store format |
| **iOS Debug** | 40-80s | First build slower |
| **iOS Release** | 60-120s | Includes bitcode compilation |

### Binary Sizes (Expected)

| Format | Uncompressed | Compressed | Notes |
|--------|--------------|-----------|-------|
| **Android APK (Debug)** | 80-120 MB | 60-80 MB | Includes debug symbols |
| **Android APK (Release)** | 50-70 MB | 30-45 MB | Optimized, minified |
| **App Bundle** | 40-60 MB | 20-35 MB | Play Store compressed |
| **iOS App** | 100-150 MB | 80-100 MB | Includes frameworks |

### Memory Startup

- **Cold Start**: < 3 seconds
- **Hot Start**: < 1 second
- **Warm Start**: < 500ms
- **Memory on Launch**: 50-100 MB

---

## Troubleshooting Build Failures

### Common Issues & Fixes

#### 1. "Unresolved reference" errors
```bash
# Solution
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter clean
flutter pub get
```

#### 2. Gradle sync failures (Android)
```bash
# Solution
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### 3. Pod install failures (iOS)
```bash
# Solution
cd ios
rm Podfile.lock
rm -rf Pods/
cd ..
flutter pub get
flutter clean
flutter pub get
```

#### 4. Kotlin version conflicts
```bash
# Update android/build.gradle
android {
  compileSdkVersion 34  // Update to latest
  ndkVersion "25.1.8937393"
}
```

#### 5. Null safety issues
```bash
# Ensure all dependencies support null safety
dart pub upgrade

# Check pubspec.yaml has minimum versions
flutter pub get
```

---

## Pre-Release Build Checklist

### Before submitting to stores:

- [ ] All tests passing (`flutter test`)
- [ ] No analyzer warnings (`dart analyze lib/`)
- [ ] Code formatted (`dart format lib/`)
- [ ] App builds for release (both platforms)
- [ ] No compilation warnings
- [ ] App icon properly configured
- [ ] Splash screen configured
- [ ] Minimum OS versions met
- [ ] Signing certificates valid
- [ ] Bundle identifiers correct
- [ ] Build numbers incremented

---

## Build Configuration Files Needed

### iOS (ios/Runner/Info.plist)
```xml
<key>CFBundleVersion</key>
<string>1</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>UIApplicationSupportedInterfaceOrientations</key>
<array>
  <string>UIInterfaceOrientationPortrait</string>
  <string>UIInterfaceOrientationLandscapeLeft</string>
  <string>UIInterfaceOrientationLandscapeRight</string>
</array>
```

### Android (android/app/build.gradle)
```gradle
android {
  compileSdk 34
  
  defaultConfig {
    applicationId = "com.yourwish.chess"
    minSdkVersion 24
    targetSdkVersion 34
    versionCode 1
    versionName "1.0.0"
  }
}
```

---

## Commands Summary

```bash
# Pre-build checks
dart analyze lib/
dart format lib/

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Build for testing
flutter build apk --debug
flutter build ios --debug

# Build for release
flutter build apk --release
flutter build appbundle --release
flutter build ios --release

# Verify outputs
ls build/app/outputs/apk/release/
ls build/app/outputs/bundle/release/
ls build/ios/Release/
```

---

## Next Steps After Build Validation

1. ✅ Code quality confirmed
2. ✅ Dependencies validated
3. ✅ Builds successful
4. 📍 **Stage 3: Device Testing**
5. 📍 **Stage 4: Security Audit**
6. 📍 **Stage 5: Submission Preparation**

---

**Status:** Stage 2 Ready  
**Last Updated:** 2026-08-29  
**Phase:** D - Release Readiness
