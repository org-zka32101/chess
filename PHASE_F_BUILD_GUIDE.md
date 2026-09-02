# Phase F Build Guide - APK & IPA Generation

## Overview

This guide provides step-by-step instructions for building release APK and IPA files for Chess Tactics Master, enabling device testing and app store submission.

**Status**: Phase F (Testing & Release)
**Date**: 2026-09-02
**Target**: Release APK/IPA for device testing

---

## Prerequisites

### System Requirements
- **macOS** (for iOS builds only)
- **Linux/macOS** (for Android builds)
- **Disk Space**: 10GB+ free
- **RAM**: 8GB+ recommended

### Required Software
```bash
# Flutter SDK (latest stable)
flutter --version  # >= 3.24.0

# Dart (included with Flutter)
dart --version    # >= 3.x

# Android dependencies
# - Java Development Kit (JDK 11+)
# - Android SDK (API 34+)
# - Android Studio or command-line tools

# iOS dependencies (macOS only)
# - Xcode (latest)
# - CocoaPods

# Build tools
git
bash
```

### Environment Setup

```bash
# Verify Flutter installation
flutter doctor

# Ensure all plugins available
flutter pub get

# Generate code (Riverpod, Freezed, Hive)
dart run build_runner build

# Update Android Gradle wrapper (if needed)
cd android
./gradlew --version
cd ..
```

---

## Android APK Build

### 1. Build Configuration

#### Check Version Numbers
```bash
# View current version
grep "^version:" pubspec.yaml

# Current: 1.0.0+1
# Increment for releases: 1.0.0+2, 1.0.1+3, etc.
```

#### Update Build Numbers (if releasing new version)
```bash
# Edit pubspec.yaml
nano pubspec.yaml
# Change: version: 1.0.0+1 → version: 1.0.1+2

# Edit android/app/build.gradle
nano android/app/build.gradle
# Change:
#   versionCode = 2  (increment)
#   versionName = "1.0.1"
```

### 2. Build Release APK

```bash
# Clean previous builds
flutter clean

# Get latest dependencies
flutter pub get

# Generate code
dart run build_runner build

# Build release APK
flutter build apk --release

# Output location:
# build/app/outputs/flutter-apk/app-release.apk
```

#### Build with Specific Settings
```bash
# Build with split APKs for smaller download
flutter build apk --release --split-per-abi

# Outputs:
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# build/app/outputs/flutter-apk/app-x86-release.apk
# build/app/outputs/flutter-apk/app-x86_64-release.apk
```

### 3. Build App Bundle (for Play Store)

```bash
# Build AAB for Google Play Store
flutter build appbundle --release

# Output location:
# build/app/outputs/bundle/release/app-release.aab

# Test AAB locally using bundletool
# See: https://developer.android.com/studio/command-line/bundletool
```

### 4. Verify APK

```bash
# Check APK details
aapt dump badging build/app/outputs/flutter-apk/app-release.apk

# Check APK size
du -h build/app/outputs/flutter-apk/app-release.apk

# Validate APK with bundletool
bundletool validate --bundle-path=build/app/outputs/bundle/release/app-release.aab
```

### 5. Install APK on Device

```bash
# Connect Android device and verify
adb devices

# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Install split APKs (if built with split-per-abi)
adb install-multiple \
  build/app/outputs/flutter-apk/app-arm64-v8a-release.apk \
  build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk

# Launch app
adb shell am start -n com.yourwish.chess_tactics_master/.MainActivity

# View logs
adb logcat
```

---

## iOS IPA Build

### 1. iOS Build Configuration

#### Check Version Numbers
```bash
# View iOS-specific version settings
cat ios/Runner/Info.plist | grep -A 2 "CFBundleShortVersionString"

# Should match pubspec.yaml version
```

#### Update iOS Settings (if needed)
```bash
# Edit iOS bundle settings
open ios/Runner.xcworkspace

# Or via command line
plutil -replace CFBundleShortVersionString -string "1.0.1" \
  ios/Runner/Info.plist
plutil -replace CFBundleVersion -string "2" \
  ios/Runner/Info.plist
```

### 2. Build Release IPA

```bash
# Clean previous builds
flutter clean

# Get latest dependencies
flutter pub get

# Generate code
dart run build_runner build

# Build release IPA
flutter build ios --release

# Output location (built product):
# build/ios/iphoneos/Runner.app

# To generate IPA file:
flutter build ipa --release

# Output location (IPA):
# build/ios/ipa/chess_tactics_master.ipa
```

### 3. Build for TestFlight

```bash
# Build with beta version
flutter build ipa --release --build-number=2

# This creates IPA ready for TestFlight submission
# See: https://developer.apple.com/testflight/
```

### 4. Build with Custom Provisioning

```bash
# If custom signing certificate needed
flutter build ios --release \
  --no-codesign

# Then use Xcode to sign:
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -derivedDataPath ios/build \
  -archivePath ios/build/Runner.xcarchive \
  archive

xcodebuild -exportArchive \
  -archivePath ios/build/Runner.xcarchive \
  -exportOptionsPlist ios/ExportOptions.plist \
  -exportPath ios/build/ipa
```

### 5. Install on Device via Xcode

```bash
# Connect iOS device
# Open Xcode workspace
open ios/Runner.xcworkspace

# Select device in Xcode
# Product → Run (⌘R)

# Or install IPA via command line
# Requires Apple Configurator or similar tool
```

---

## Build Scripts

### Automated Build Script

**File**: `scripts/build_release.sh`

```bash
#!/bin/bash
set -e

echo "🏗️  Chess Tactics Master - Release Build"
echo "=========================================="

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get build type
BUILD_TYPE=${1:-android}

# Functions
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

# Verify Flutter installation
print_info "Verifying Flutter installation..."
if ! command -v flutter &> /dev/null; then
    print_error "Flutter not found. Please install Flutter."
    exit 1
fi
print_status "Flutter found: $(flutter --version | head -1)"

# Clean and prepare
print_info "Cleaning previous builds..."
flutter clean
print_status "Clean complete"

# Get dependencies
print_info "Installing dependencies..."
flutter pub get
print_status "Dependencies installed"

# Generate code
print_info "Generating code (Riverpod, Freezed, Hive)..."
dart run build_runner build
print_status "Code generation complete"

# Build for specified platform
if [ "$BUILD_TYPE" == "android" ] || [ "$BUILD_TYPE" == "apk" ]; then
    print_info "Building Android APK..."
    flutter build apk --release
    APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    print_status "APK built successfully"
    print_status "Location: $APK_PATH"
    print_status "Size: $APK_SIZE"
    
    # Show installation command
    echo ""
    print_info "To install on device:"
    echo "  adb install $APK_PATH"
    
elif [ "$BUILD_TYPE" == "aab" ] || [ "$BUILD_TYPE" == "bundle" ]; then
    print_info "Building Android App Bundle..."
    flutter build appbundle --release
    AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
    AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
    print_status "App Bundle built successfully"
    print_status "Location: $AAB_PATH"
    print_status "Size: $AAB_SIZE"
    
elif [ "$BUILD_TYPE" == "ios" ] || [ "$BUILD_TYPE" == "ipa" ]; then
    print_info "Building iOS IPA..."
    flutter build ipa --release
    IPA_PATH="build/ios/ipa/chess_tactics_master.ipa"
    IPA_SIZE=$(du -h "$IPA_PATH" | cut -f1)
    print_status "IPA built successfully"
    print_status "Location: $IPA_PATH"
    print_status "Size: $IPA_SIZE"
    
else
    print_error "Unknown build type: $BUILD_TYPE"
    echo "Usage: ./scripts/build_release.sh [android|aab|ios]"
    exit 1
fi

echo ""
print_status "Build complete!"
```

### Split APK Build Script

**File**: `scripts/build_split_apks.sh`

```bash
#!/bin/bash
set -e

echo "🏗️  Building Split APKs (per ABI)"
echo "=================================="

flutter clean
flutter pub get
dart run build_runner build

print_info() {
    echo "ℹ️  $1"
}

print_status() {
    echo "✓ $1"
}

print_info "Building split APKs..."
flutter build apk --release --split-per-abi

APK_DIR="build/app/outputs/flutter-apk"
print_status "Split APKs built:"
ls -lh "$APK_DIR"/*release.apk | awk '{print "  " $9 " (" $5 ")"}'

echo ""
print_info "To install all split APKs:"
echo "  adb install-multiple \\"
ls "$APK_DIR"/*release.apk | awk '{print "    \\" $0 " \\"}'
```

---

## CI/CD Integration

### GitHub Actions - Build Workflow

**File**: `.github/workflows/build-release.yml`

```yaml
name: Build Release Binaries

on:
  push:
    branches: [main]
    tags: ['v*']
  workflow_dispatch:

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Generate code
        run: dart run build_runner build
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Build App Bundle
        run: flutter build appbundle --release
      
      - name: Upload APK artifact
        uses: actions/upload-artifact@v3
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk
      
      - name: Upload AAB artifact
        uses: actions/upload-artifact@v3
        with:
          name: app-release.aab
          path: build/app/outputs/bundle/release/app-release.aab

  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Generate code
        run: dart run build_runner build
      
      - name: Build IPA
        run: flutter build ipa --release
      
      - name: Upload IPA artifact
        uses: actions/upload-artifact@v3
        with:
          name: chess_tactics_master.ipa
          path: build/ios/ipa/chess_tactics_master.ipa
```

---

## Build Verification Checklist

### Pre-Build
- [ ] All changes committed to git
- [ ] Branch is up to date with main
- [ ] Version numbers updated (if new release)
- [ ] All tests passing locally
- [ ] Code analysis passes (`dart analyze`)
- [ ] Code formatting correct (`dart format`)

### Post-Build (Android)
- [ ] APK file exists and is > 50MB (typical Flutter app)
- [ ] APK size is reasonable (< 200MB)
- [ ] APK installs on test device without errors
- [ ] App launches successfully
- [ ] No crash logs in Logcat
- [ ] Firebase initialization successful
- [ ] Analytics logging functional

### Post-Build (iOS)
- [ ] IPA file exists and is > 50MB
- [ ] IPA installs on test device via Xcode
- [ ] App launches successfully
- [ ] No console errors
- [ ] Firebase initialization successful
- [ ] Analytics logging functional

---

## Troubleshooting Build Issues

### Issue: "Flutter not found"
```bash
# Verify Flutter in PATH
echo $PATH

# Add Flutter to PATH if needed
export PATH="$PATH:/path/to/flutter/bin"

# Or install Flutter:
# See: https://flutter.dev/docs/get-started/install
```

### Issue: "Gradle build failed"
```bash
# Clean Gradle cache
cd android
./gradlew clean
./gradlew -v
cd ..

# Rebuild
flutter build apk --release
```

### Issue: "CocoaPods dependency error"
```bash
# Update CocoaPods
sudo gem install cocoapods

# Clean iOS build
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..

# Rebuild
flutter build ipa --release
```

### Issue: "Java version mismatch"
```bash
# Check Java version
java -version

# Requires Java 11+
# Update if needed via JAVA_HOME:
export JAVA_HOME=/path/to/java/11
```

### Issue: "Code generation failed"
```bash
# Clean and rebuild code generation
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

---

## Build Output Locations

### Android
- **APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **Split APKs**: `build/app/outputs/flutter-apk/app-*-release.apk`
- **App Bundle**: `build/app/outputs/bundle/release/app-release.aab`

### iOS
- **IPA**: `build/ios/ipa/chess_tactics_master.ipa`
- **Archive**: `build/ios/iphoneos/Runner.app`

---

## Next Steps: Device Testing

After building APK/IPA:

1. **Install on Test Devices**
   - Follow device-specific installation instructions
   - Document device OS versions and specs

2. **Execute Test Suite**
   - Follow PHASE_F_DEVICE_TESTING.md procedures
   - Complete 14 test categories
   - Log all results

3. **Report Issues**
   - Create GitHub issues for any failures
   - Include device info, steps to reproduce, logs

4. **Security Audit**
   - Follow PHASE_E_RELEASE_CHECKLIST.md security section
   - Code review, network security, data protection

5. **App Store Submission**
   - Follow PHASE_F_RELEASE_CHECKLIST.md store section
   - Prepare screenshots, descriptions, metadata

---

## Build Performance Tips

### Faster Builds
```bash
# Skip Dart code generation if no changes
flutter build apk --release --no-enable-dart-compilation

# Use local engine for development
# See: https://github.com/flutter/flutter/wiki/Local-Engine

# Enable Gradle parallel builds
# In android/gradle.properties:
# org.gradle.parallel=true
# org.gradle.workers.max=8
```

### Smaller APK Size
```bash
# Remove unused resources
flutter build apk --release --shrink

# Split APKs by ABI (smaller per-device downloads)
flutter build apk --release --split-per-abi

# Enable R8 code shrinking
# In android/app/build.gradle:
# release {
#     shrinkResources true
# }
```

---

**Status**: ✅ Build Guide Complete
**Next**: Execute device testing per PHASE_F_DEVICE_TESTING.md
