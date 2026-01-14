#!/bin/bash
# Script to publish and test the real orb
# Run this after authenticating with: circleci setup

set -e

echo "======================================"
echo "Publishing and Testing Real Orb"
echo "======================================"
echo ""

# Check if authenticated
if ! circleci diagnostic &>/dev/null; then
    echo "❌ Not authenticated with CircleCI"
    echo ""
    echo "Please run: circleci setup"
    echo "Get your token from: https://app.circleci.com/settings/user/tokens"
    echo ""
    exit 1
fi

echo "✓ CircleCI CLI authenticated"
echo ""

# Step 1: Pack the orb (already done, but ensure it's fresh)
echo "Step 1: Packing orb..."
circleci orb pack src > orb.yml
echo "✓ Orb packed ($(wc -l < orb.yml) lines)"
echo ""

# Step 2: Validate
echo "Step 2: Validating orb..."
circleci orb validate orb.yml
echo "✓ Orb validated"
echo ""

# Step 3: Create orb (first time only, will error if exists)
echo "Step 3: Creating orb (if not exists)..."
circleci orb create agrasth/artifactory-orb-v2 || echo "→ Orb already exists (OK)"
echo ""

# Step 4: Publish dev version
echo "Step 4: Publishing dev version..."
DEV_VERSION="dev:test$(date +%s)"
circleci orb publish orb.yml "agrasth/artifactory-orb-v2@${DEV_VERSION}"
echo "✓ Published as: agrasth/artifactory-orb-v2@${DEV_VERSION}"
echo ""

# Step 5: Update config
echo "Step 5: Updating config to use published orb..."
sed "s/@dev:test1/@${DEV_VERSION}/g" .circleci/config-test-real-orb.yml > .circleci/config.yml
echo "✓ Config updated"
echo ""

# Step 6: Commit and push
echo "Step 6: Committing and pushing..."
git add .circleci/config.yml
git commit -m "Test real orb version ${DEV_VERSION}"
git push
echo "✓ Pushed to GitHub"
echo ""

echo "======================================"
echo "✓ Done!"
echo "======================================"
echo ""
echo "Your pipeline will now test the REAL orb!"
echo ""
echo "View at: https://app.circleci.com/pipelines/github/agrasth/artifactory-orb-v2"
echo ""
echo "Published version: agrasth/artifactory-orb-v2@${DEV_VERSION}"
echo ""

