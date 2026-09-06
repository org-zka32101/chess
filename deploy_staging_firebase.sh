#!/bin/bash
# Chess Tactics Master - Firebase Staging Deployment Script
# Configures Firebase staging project and deploys functions/rules

set -e

PROJECT_ID="chess-staging"

echo "Chess Tactics Master - Firebase Staging Deployment"
echo "===================================================="
echo ""

# Step 1: Create project
echo "Step 1: Creating Firebase staging project (if needed)..."
if firebase projects:list --quiet | grep -q "^$PROJECT_ID$"; then
    echo "✓ Project $PROJECT_ID already exists"
else
    echo "Creating new project $PROJECT_ID..."
    if ! firebase projects:create $PROJECT_ID --quiet; then
        echo "Error: Failed to create Firebase project $PROJECT_ID"
        echo "Verify you have permission to create projects and Firebase CLI is authenticated"
        exit 1
    fi
    echo "✓ Project $PROJECT_ID created successfully"
fi
echo ""

# Step 2: Deploy Firestore rules
echo "Step 2: Deploying Firestore security rules to staging..."
firebase deploy --only firestore:rules --project $PROJECT_ID
echo "✓ Firestore rules deployed"
echo ""

# Step 3: Deploy Cloud Functions
echo "Step 3: Deploying Cloud Functions to staging..."
firebase deploy --only functions --project $PROJECT_ID
echo "✓ Cloud Functions deployed"
echo ""

# Step 4: Manual configuration instructions
echo "Step 4: Manual Firebase Console Configuration Required"
echo "========================================================"
echo "Project: $PROJECT_ID"
echo "Go to: https://console.firebase.google.com/project/$PROJECT_ID"
echo ""
echo "Enable these services:"
echo "  [ ] Authentication"
echo "      - Email/Password"
echo "      - Google Sign-In"
echo "      - Apple Sign-In"
echo "  [ ] Firestore Database"
echo "  [ ] Realtime Database"
echo "  [ ] Cloud Storage"
echo "  [ ] Analytics"
echo "  [ ] Crashlytics"
echo ""
echo "Configure these settings:"
echo "  [ ] CORS settings for API access"
echo "  [ ] API key restrictions"
echo "  [ ] Storage bucket permissions"
echo ""

# Step 5: Update .env.staging
echo "Step 5: Updating environment configuration..."
echo "Retrieve Firebase configuration from:"
echo "  https://console.firebase.google.com/project/$PROJECT_ID/settings/general"
echo ""
echo "Update .env.staging with:"
echo "  - FIREBASE_API_KEY"
echo "  - FIREBASE_AUTH_DOMAIN"
echo "  - FIREBASE_DATABASE_URL"
echo "  - FIREBASE_PROJECT_ID"
echo "  - FIREBASE_STORAGE_BUCKET"
echo ""

echo "✓ Firebase staging deployment complete!"
echo ""
echo "Next: Configure RevenueCat sandbox and build staging APK/IPA"
