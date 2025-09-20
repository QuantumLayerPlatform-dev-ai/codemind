#!/bin/bash

# GitHub Container Registry Login Script
# Usage: ./ghcr-login.sh

set -e

REGISTRY="ghcr.io"
REPO_OWNER="quantumlayerplatform-dev-ai"

echo "🔐 GitHub Container Registry Login"
echo "=================================="

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ GITHUB_TOKEN environment variable not set"
    echo ""
    echo "Please create a GitHub Personal Access Token with 'write:packages' scope:"
    echo "1. Go to https://github.com/settings/tokens"
    echo "2. Click 'Generate new token (classic)'"
    echo "3. Select 'write:packages' scope"
    echo "4. Copy the token and run:"
    echo "   export GITHUB_TOKEN=your_token_here"
    echo "   ./scripts/ghcr-login.sh"
    exit 1
fi

if [ -z "$GITHUB_USERNAME" ]; then
    echo "❌ GITHUB_USERNAME environment variable not set"
    echo ""
    echo "Please set your GitHub username:"
    echo "   export GITHUB_USERNAME=your_username"
    echo "   ./scripts/ghcr-login.sh"
    exit 1
fi

echo "🔑 Logging into GHCR as $GITHUB_USERNAME..."
echo $GITHUB_TOKEN | docker login $REGISTRY -u $GITHUB_USERNAME --password-stdin

if [ $? -eq 0 ]; then
    echo "✅ Successfully logged into $REGISTRY"
    echo ""
    echo "You can now build and push images:"
    echo "   ./scripts/build-and-deploy.sh patch"
    echo ""
    echo "Images will be pushed to:"
    echo "   📦 $REGISTRY/$REPO_OWNER/codemind-api"
    echo "   📦 $REGISTRY/$REPO_OWNER/codemind-frontend"
else
    echo "❌ Failed to login to $REGISTRY"
    exit 1
fi