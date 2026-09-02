#!/bin/bash
set -e

# Chess Tactics Master - Split APK Build Script
# Builds separate APKs for each CPU architecture
# Usage: ./scripts/build_split_apks.sh

echo "🏗️  Building Split APKs (per ABI)"
echo "=================================="
echo ""

# Color codes
RED='\033[0;31m'
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

# Clean
print_section "Cleaning"
flutter clean
print_status "Clean complete"

# Dependencies
print_section "Installing Dependencies"
flutter pub get
print_status "Dependencies installed"

# Code generation
print_section "Generating Code"
dart run build_runner build
print_status "Code generation complete"

# Build split APKs
print_section "Building Split APKs"
print_info "This will create separate APKs for each architecture..."
echo ""

START_TIME=$(date +%s)
flutter build apk --release --split-per-abi
END_TIME=$(date +%s)
BUILD_TIME=$((END_TIME - START_TIME))

# Display results
print_section "Build Results"

APK_DIR="build/app/outputs/flutter-apk"
echo ""
echo "Split APKs by architecture:"
echo ""

# Array to store APK info
declare -a APK_FILES
declare -a APK_SIZES
declare -a APK_NAMES

# Collect APK information
i=0
total_size=0
while IFS= read -r file; do
    filename=$(basename "$file")
    size=$(du -h "$file" | cut -f1)
    size_bytes=$(du "$file" | cut -f1)

    APK_FILES[$i]="$file"
    APK_SIZES[$i]="$size"
    APK_NAMES[$i]="$filename"

    # Extract architecture
    if [[ "$filename" =~ arm64-v8a ]]; then
        arch="ARM64 (64-bit) - Most modern Android devices"
    elif [[ "$filename" =~ armeabi-v7a ]]; then
        arch="ARM (32-bit) - Older Android devices"
    elif [[ "$filename" =~ x86_64 ]]; then
        arch="x86-64 (Intel 64-bit) - Emulators & some tablets"
    elif [[ "$filename" =~ x86 ]]; then
        arch="x86 (Intel 32-bit) - Older emulators"
    else
        arch="Universal"
    fi

    printf "  %-40s %-10s  %s\n" "$filename" "$size" "$arch"

    i=$((i + 1))
done < <(ls "$APK_DIR"/*release.apk 2>/dev/null | sort)

echo ""
echo "Total build time: ${BUILD_TIME}s"
echo ""

# Installation instructions
print_section "Installation Options"

echo ""
echo "Option 1: Install all split APKs (for single device)"
echo "  adb install-multiple \\"
ls "$APK_DIR"/*release.apk 2>/dev/null | sort | awk '{printf "    %s \\\n", $0}'
echo ""

echo "Option 2: Install specific APK (ARM64 recommended for modern devices)"
arm64_apk=$(ls "$APK_DIR"/*arm64-v8a*release.apk 2>/dev/null | head -1)
if [ -n "$arm64_apk" ]; then
    echo "  adb install \"$arm64_apk\""
fi
echo ""

echo "Option 3: List available devices"
echo "  adb devices"
echo ""

echo "Option 4: Launch app after install"
echo "  adb shell am start -n com.yourwish.chess_tactics_master/.MainActivity"
echo ""

# Benefits explanation
print_section "Benefits of Split APKs"
echo ""
echo "✓ Smaller download size (users get only their arch's APK)"
echo "✓ Faster installation"
echo "✓ Better performance (native code optimized for device)"
echo "✓ Reduced storage usage"
echo ""
echo "Use for Play Store distribution!"
echo ""

print_status "Split APK build complete!"
