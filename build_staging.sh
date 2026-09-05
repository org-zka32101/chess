#!/bin/bash
# Chess Tactics Master - Staging Build Script
# Builds staging APK and IPA with environment-specific configuration

set -e

STAGING_ENV=.env.staging

echo "Loading staging environment from $STAGING_ENV"
if [ -f "$STAGING_ENV" ]; then
    source "$STAGING_ENV"
else
    echo "Error: $STAGING_ENV not found"
    exit 1
fi

# Validate required environment variables
if [ -z "$ENVIRONMENT" ] || [ -z "$FIREBASE_PROJECT" ] || [ -z "$REVENUECAT_KEY" ]; then
    echo "Error: Required environment variables not set"
    echo "  ENVIRONMENT=$ENVIRONMENT"
    echo "  FIREBASE_PROJECT=$FIREBASE_PROJECT"
    echo "  REVENUECAT_KEY=$REVENUECAT_KEY"
    exit 1
fi

# Validate RevenueCat key format (pk_test_xxx or pk_live_xxx)
if ! [[ "$REVENUECAT_KEY" =~ ^pk_(test|live)_ ]]; then
    echo "Error: Invalid REVENUECAT_KEY format (must be pk_test_xxx or pk_live_xxx)"
    exit 1
fi

echo "Environment validation passed"
echo "  ENVIRONMENT=$ENVIRONMENT"
echo "  FIREBASE_PROJECT=$FIREBASE_PROJECT"
echo "  REVENUECAT_KEY=${REVENUECAT_KEY:0:10}... (truncated)"

echo "Building Android staging release..."
flutter build apk \
  --release \
  --dart-define=ENVIRONMENT=$ENVIRONMENT \
  --dart-define=FIREBASE_PROJECT=$FIREBASE_PROJECT \
  --dart-define=REVENUECAT_KEY=$REVENUECAT_KEY

echo "Building iOS staging release..."
flutter build ios \
  --release \
  --dart-define=ENVIRONMENT=$ENVIRONMENT \
  --dart-define=FIREBASE_PROJECT=$FIREBASE_PROJECT \
  --dart-define=REVENUECAT_KEY=$REVENUECAT_KEY

echo ""
echo "✓ Staging builds complete!"
echo "  Android: build/app/outputs/apk/release/app-release.apk"
echo "  iOS: build/ios/iphoneos/Runner.app"
