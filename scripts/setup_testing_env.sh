#!/bin/bash

# Chess Tactics Master - Testing Environment Setup
# Usage: ./scripts/setup_testing_env.sh

set -e

echo "🧪 Setting up Testing Environment"
echo "=================================="
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

print_section() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Check Flutter
print_section "Checking Flutter Setup"
if ! command -v flutter &> /dev/null; then
    print_info "Flutter not found in PATH"
    exit 1
fi
FLUTTER_VERSION=$(flutter --version 2>&1 | head -1)
print_status "Flutter: $FLUTTER_VERSION"

# Check Dart
if ! command -v dart &> /dev/null; then
    print_info "Dart not found"
    exit 1
fi
print_status "Dart: $(dart --version 2>&1)"

# Check Android setup
print_section "Checking Android Setup"

if ! command -v adb &> /dev/null; then
    print_info "⚠️  adb not found (Android Debug Bridge)"
    echo "    Install Android SDK Platform Tools from:"
    echo "    https://developer.android.com/tools/releases/platform-tools"
else
    print_status "adb found"
    ADB_DEVICES=$(adb devices -l 2>&1 | wc -l)
    print_info "Connected devices: $(adb devices -l 2>&1 | tail -n +2 | grep -v "^$" | wc -l)"
fi

# Check iOS setup (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    print_section "Checking iOS Setup"

    if ! command -v xcode-select &> /dev/null; then
        print_info "⚠️  Xcode not found"
    else
        print_status "Xcode: $(xcode-select -p)"
    fi

    if ! command -v pod &> /dev/null; then
        print_info "⚠️  CocoaPods not found"
    else
        print_status "CocoaPods: $(pod --version)"
    fi
fi

# Dependencies
print_section "Installing Dependencies"
flutter pub get
print_status "Dependencies installed"

# Code generation
print_section "Generating Code"
dart run build_runner build
print_status "Code generation complete"

# Create test directories
print_section "Setting Up Test Directories"

mkdir -p test_results
mkdir -p test_results/device_logs
mkdir -p test_results/screenshots
mkdir -p test_results/performance_data

print_status "Test directories created"

# Create test environment file
print_section "Creating Test Configuration"

if [ ! -f ".env.test" ]; then
    cat > .env.test << 'EOF'
# Test Environment Configuration
# DO NOT commit this file if contains real credentials

# Firebase
FIREBASE_DEBUG_MODE=true
FIREBASE_EMULATOR_ENABLED=false

# Analytics
ANALYTICS_DEBUG_MODE=true
ANALYTICS_MOCK_MODE=false

# RevenueCat
REVENUATE_API_KEY=sk_test_xxx

# Testing
TESTING_ENABLED=true
SKIP_NETWORK_TESTS=false
MOCK_PURCHASES=false
EOF

    print_status "Created .env.test"
else
    print_status ".env.test already exists"
fi

# Test structure
print_section "Verifying Test Files"

test_files=(
    "test/services/analytics_revenue_service_test.dart"
    "integration_test/analytics_integration_test.dart"
)

for file in "${test_files[@]}"; do
    if [ -f "$file" ]; then
        print_status "Found: $file"
    else
        print_info "Missing: $file"
    fi
done

# Summary
print_section "Setup Summary"

echo ""
echo "✅ Testing environment ready!"
echo ""
echo "Next steps:"
echo ""
echo "1️⃣  Build Release APK:"
echo "   ./scripts/build_release.sh android"
echo ""
echo "2️⃣  Connect test device:"
echo "   adb devices"
echo ""
echo "3️⃣  Install APK on device:"
echo "   adb install build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "4️⃣  Run device tests:"
echo "   flutter test test/services/"
echo "   flutter drive --target=integration_test/analytics_integration_test.dart"
echo ""
echo "5️⃣  Check test results:"
echo "   cat test_results/device_logs/test_*.log"
echo ""
echo "Documentation:"
echo "  - PHASE_F_BUILD_GUIDE.md - Build instructions"
echo "  - PHASE_F_DEVICE_TESTING.md - Device testing procedures"
echo "  - PHASE_E_RELEASE_CHECKLIST.md - Release validation"
echo ""
