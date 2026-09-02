#!/bin/bash
set -e

# Chess Tactics Master - Release Build Script
# Usage: ./scripts/build_release.sh [android|aab|ios|all]

echo "🏗️  Chess Tactics Master - Release Build"
echo "=========================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_section() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

get_timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

# Verify Flutter installation
print_section "1. Verifying Flutter Installation"
if ! command -v flutter &> /dev/null; then
    print_error "Flutter not found. Please install Flutter."
    echo "  See: https://flutter.dev/docs/get-started/install"
    exit 1
fi

FLUTTER_VERSION=$(flutter --version 2>&1 | head -1)
print_status "Flutter found"
echo "  $FLUTTER_VERSION"

# Verify Dart installation
if ! command -v dart &> /dev/null; then
    print_error "Dart not found"
    exit 1
fi

DART_VERSION=$(dart --version 2>&1 | head -1)
print_status "Dart found"
echo "  $DART_VERSION"

# Get pubspec version
PUBSPEC_VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}')
print_status "App version: $PUBSPEC_VERSION"

# Clean previous builds
print_section "2. Cleaning Previous Builds"
print_info "Running flutter clean..."
flutter clean
print_status "Clean complete"

# Get dependencies
print_section "3. Installing Dependencies"
print_info "Running flutter pub get..."
flutter pub get
print_status "Dependencies installed"

# Generate code
print_section "4. Generating Code"
print_info "Running build_runner for Riverpod, Freezed, Hive..."
dart run build_runner build
print_status "Code generation complete"

# Analyze code
print_section "5. Analyzing Code"
print_info "Running dart analyze..."
if dart analyze lib/ 2>&1 | grep -q "error"; then
    print_error "Code analysis found errors. Aborting build."
    dart analyze lib/
    exit 1
fi
print_status "Code analysis passed"

# Format check
print_info "Checking code formatting..."
if ! dart format --set-exit-if-changed lib/ --dry-run 2>&1 > /dev/null; then
    print_error "Code formatting issues found. Run: dart format lib/"
    exit 1
fi
print_status "Code formatting OK"

# Build for specified platform
case "$BUILD_TYPE" in
    android|apk)
        print_section "6. Building Android APK"
        print_info "Building release APK (single binary)..."
        START_TIME=$(date +%s)
        flutter build apk --release
        END_TIME=$(date +%s)
        BUILD_TIME=$((END_TIME - START_TIME))

        APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
        if [ -f "$APK_PATH" ]; then
            APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
            print_status "APK built successfully in ${BUILD_TIME}s"
            echo "  📦 Location: $APK_PATH"
            echo "  📊 Size: $APK_SIZE"
            echo ""
            print_info "To install on device:"
            echo "  adb install $APK_PATH"
            echo ""
            print_info "To launch app:"
            echo "  adb shell am start -n com.yourwish.chess_tactics_master/.MainActivity"
        else
            print_error "APK file not found at expected location"
            exit 1
        fi
        ;;

    split)
        print_section "6. Building Split APKs (per ABI)"
        print_info "Building split APKs..."
        START_TIME=$(date +%s)
        flutter build apk --release --split-per-abi
        END_TIME=$(date +%s)
        BUILD_TIME=$((END_TIME - START_TIME))

        APK_DIR="build/app/outputs/flutter-apk"
        print_status "Split APKs built successfully in ${BUILD_TIME}s"
        echo ""
        echo "  APKs by architecture:"
        ls -lh "$APK_DIR"/*release.apk 2>/dev/null | awk '{printf "    %s (%s)\n", $9, $5}'
        echo ""
        print_info "To install all split APKs:"
        echo "  adb install-multiple \\"
        ls "$APK_DIR"/*release.apk 2>/dev/null | awk '{printf "    %s \\\n", $0}'
        ;;

    aab|bundle)
        print_section "6. Building Android App Bundle"
        print_info "Building App Bundle for Play Store..."
        START_TIME=$(date +%s)
        flutter build appbundle --release
        END_TIME=$(date +%s)
        BUILD_TIME=$((END_TIME - START_TIME))

        AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
        if [ -f "$AAB_PATH" ]; then
            AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
            print_status "App Bundle built successfully in ${BUILD_TIME}s"
            echo "  📦 Location: $AAB_PATH"
            echo "  📊 Size: $AAB_SIZE"
            echo ""
            print_info "Next steps:"
            echo "  1. Upload to Google Play Console"
            echo "  2. Run Play Store tests"
        else
            print_error "App Bundle file not found"
            exit 1
        fi
        ;;

    ios|ipa)
        print_section "6. Building iOS IPA"
        if [[ ! "$OSTYPE" == "darwin"* ]]; then
            print_error "iOS builds require macOS. Current OS: $OSTYPE"
            exit 1
        fi

        print_info "Building IPA for TestFlight..."
        START_TIME=$(date +%s)
        flutter build ipa --release
        END_TIME=$(date +%s)
        BUILD_TIME=$((END_TIME - START_TIME))

        IPA_PATH="build/ios/ipa/chess_tactics_master.ipa"
        if [ -f "$IPA_PATH" ]; then
            IPA_SIZE=$(du -h "$IPA_PATH" | cut -f1)
            print_status "IPA built successfully in ${BUILD_TIME}s"
            echo "  📦 Location: $IPA_PATH"
            echo "  📊 Size: $IPA_SIZE"
            echo ""
            print_info "Next steps:"
            echo "  1. Upload to TestFlight"
            echo "  2. Configure testers"
            echo "  3. Run device tests"
        else
            print_error "IPA file not found"
            exit 1
        fi
        ;;

    all)
        print_section "6. Building All Binaries"

        # Build Android APK
        print_info "Building Android APK..."
        flutter build apk --release
        APK_SIZE=$(du -h "build/app/outputs/flutter-apk/app-release.apk" | cut -f1)
        print_status "Android APK: $APK_SIZE"

        # Build Android AAB
        print_info "Building Android App Bundle..."
        flutter build appbundle --release
        AAB_SIZE=$(du -h "build/app/outputs/bundle/release/app-release.aab" | cut -f1)
        print_status "Android AAB: $AAB_SIZE"

        # Build iOS IPA if on macOS
        if [[ "$OSTYPE" == "darwin"* ]]; then
            print_info "Building iOS IPA..."
            flutter build ipa --release
            IPA_SIZE=$(du -h "build/ios/ipa/chess_tactics_master.ipa" | cut -f1)
            print_status "iOS IPA: $IPA_SIZE"
        else
            print_info "Skipping iOS build (requires macOS)"
        fi
        ;;

    *)
        print_error "Unknown build type: $BUILD_TYPE"
        echo ""
        echo "Usage: ./scripts/build_release.sh [TYPE]"
        echo ""
        echo "Build types:"
        echo "  android    Build single Android APK"
        echo "  split      Build split APKs per architecture"
        echo "  aab        Build Android App Bundle for Play Store"
        echo "  ios        Build iOS IPA for TestFlight"
        echo "  all        Build all binaries (requires macOS for iOS)"
        echo ""
        exit 1
        ;;
esac

# Summary
print_section "Build Complete!"
echo "📋 Summary:"
echo "  Build type: $BUILD_TYPE"
echo "  App version: $PUBSPEC_VERSION"
echo "  Build date: $(get_timestamp)"
echo "  Flutter: $FLUTTER_VERSION"
echo ""
print_info "Next steps:"
echo "  1. Install binary on test device(s)"
echo "  2. Run device testing (see PHASE_F_DEVICE_TESTING.md)"
echo "  3. Execute security audit"
echo "  4. Prepare app store submission"
echo ""
