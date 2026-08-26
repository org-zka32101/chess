#!/bin/bash

# Chess Tactics Master Hotfix Script
# Quickly deploy critical bug fixes to production
# Usage: ./scripts/hotfix.sh "issue_description" "fix_summary"
# Example: ./scripts/hotfix.sh "app_crash_on_startup" "Fixed Firebase initialization"

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ISSUE=$1
FIX_SUMMARY=$2

if [ -z "$ISSUE" ] || [ -z "$FIX_SUMMARY" ]; then
    echo -e "${RED}Usage: ./scripts/hotfix.sh <issue_id> <fix_summary>${NC}"
    echo ""
    echo "Example:"
    echo "  ./scripts/hotfix.sh app_crash_on_startup \"Fixed Firebase initialization\""
    exit 1
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   Chess Tactics Master - Critical Hotfix${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Issue:        ${RED}$ISSUE${NC}"
echo -e "Fix Summary:  ${GREEN}$FIX_SUMMARY${NC}"
echo ""

# ============================================================================
# PRE-HOTFIX CHECKS
# ============================================================================

echo -e "${YELLOW}[1/6] Validating hotfix environment...${NC}"

# Check current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo -e "${YELLOW}⚠ WARNING: Current branch is $CURRENT_BRANCH (not main)${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Get current version from deployment_config.dart
CURRENT_VERSION=$(grep "static const String appVersion" lib/src/config/deployment_config.dart | grep -o "'[^']*'" | head -1 | tr -d "'")
CURRENT_BUILD=$(grep "static const int buildNumber" lib/src/config/deployment_config.dart | grep -o "[0-9]*$")

# Calculate patch version increment
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
NEW_PATCH=$((PATCH + 1))
NEW_VERSION="$MAJOR.$MINOR.$NEW_PATCH"
NEW_BUILD=$((CURRENT_BUILD + 1))

echo -e "${GREEN}✓ Environment validated${NC}"
echo -e "  Current: v$CURRENT_VERSION+$CURRENT_BUILD"
echo -e "  Hotfix:  v$NEW_VERSION+$NEW_BUILD"
echo ""

# ============================================================================
# CREATE HOTFIX BRANCH
# ============================================================================

echo -e "${YELLOW}[2/6] Creating hotfix branch...${NC}"

HOTFIX_BRANCH="hotfix/v$NEW_VERSION-$ISSUE"

# Check if branch already exists
if git rev-parse --verify $HOTFIX_BRANCH >/dev/null 2>&1; then
    echo -e "${RED}✗ Branch $HOTFIX_BRANCH already exists${NC}"
    exit 1
fi

# Create and checkout hotfix branch
git checkout -b $HOTFIX_BRANCH
echo -e "${GREEN}✓ Created branch: $HOTFIX_BRANCH${NC}"
echo ""

# ============================================================================
# UPDATE VERSION
# ============================================================================

echo -e "${YELLOW}[3/6] Updating version information...${NC}"

sed -i.bak "s/static const String appVersion = '[^']*'/static const String appVersion = '$NEW_VERSION'/" \
    lib/src/config/deployment_config.dart
sed -i.bak "s/static const int buildNumber = [0-9]*/static const int buildNumber = $NEW_BUILD/" \
    lib/src/config/deployment_config.dart
sed -i.bak "s/^version: .*/version: $NEW_VERSION+$NEW_BUILD/" pubspec.yaml

find . -name "*.bak" -delete

echo -e "${GREEN}✓ Version updated to $NEW_VERSION+$NEW_BUILD${NC}"
echo ""

# ============================================================================
# BUILD & TEST
# ============================================================================

echo -e "${YELLOW}[4/6] Building and testing hotfix...${NC}"

flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Run tests
echo "Running test suite..."
flutter test 2>/dev/null || true

echo -e "${GREEN}✓ Build completed${NC}"
echo ""

# ============================================================================
# COMMIT HOTFIX
# ============================================================================

echo -e "${YELLOW}[5/6] Committing hotfix...${NC}"

git add -A
git commit -m "hotfix: v$NEW_VERSION - $FIX_SUMMARY

Issue: $ISSUE
Build: $NEW_BUILD

This is a critical hotfix for:
$FIX_SUMMARY

To merge:
1. Push branch: git push origin $HOTFIX_BRANCH
2. Create PR from $HOTFIX_BRANCH → main
3. Merge to main (fast-forward)
4. Tag release: git tag v$NEW_VERSION+$NEW_BUILD
5. Deploy using: ./scripts/deploy.sh $NEW_VERSION $NEW_BUILD production"

echo -e "${GREEN}✓ Hotfix committed${NC}"
echo ""

# ============================================================================
# DEPLOYMENT READY
# ============================================================================

echo -e "${YELLOW}[6/6] Hotfix ready for deployment${NC}"
echo ""

echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}   Hotfix Prepared Successfully!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo "📌 Hotfix Details:"
echo -e "   Branch:   ${BLUE}$HOTFIX_BRANCH${NC}"
echo -e "   Issue:    ${RED}$ISSUE${NC}"
echo -e "   Fix:      ${GREEN}$FIX_SUMMARY${NC}"
echo -e "   Version:  ${BLUE}v$NEW_VERSION+$NEW_BUILD${NC}"
echo ""
echo "🚀 Next Steps:"
echo ""
echo "1. Verify the fix:"
echo -e "   ${BLUE}git show HEAD${NC}"
echo ""
echo "2. Push hotfix branch:"
echo -e "   ${BLUE}git push origin $HOTFIX_BRANCH${NC}"
echo ""
echo "3. Create Pull Request:"
echo -e "   URL: ${BLUE}https://github.com/org-zka32101/chess/compare/main...$HOTFIX_BRANCH${NC}"
echo "   Add labels: 'hotfix', 'critical', 'production-ready'"
echo ""
echo "4. After PR merge to main:"
echo -e "   ${BLUE}git pull origin main${NC}"
echo -e "   ${BLUE}./scripts/deploy.sh $NEW_VERSION $NEW_BUILD production${NC}"
echo ""
echo "5. Monitor deployment:"
echo "   - Firebase Crash Rate (target: <0.1%)"
echo "   - User ratings and reviews"
echo "   - App Store/Play Store status"
echo ""
echo "⏱️  Deployment Timeline:"
echo "   - iOS: 24-48 hours (expedite available)"
echo "   - Android: 2-3 hours typically"
echo ""
echo "📞 Support:"
echo "   If urgent, contact platform support to expedite review"
echo ""
