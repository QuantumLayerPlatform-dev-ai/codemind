#!/bin/bash

# Semantic versioning script for CodeMind
# Usage: ./version.sh [major|minor|patch]

VERSION_FILE="VERSION"
CURRENT_VERSION=$(cat $VERSION_FILE)

if [ ! -f "$VERSION_FILE" ]; then
    echo "0.1.0" > $VERSION_FILE
    CURRENT_VERSION="0.1.0"
fi

IFS='.' read -r -a version_parts <<< "$CURRENT_VERSION"
major=${version_parts[0]}
minor=${version_parts[1]}
patch=${version_parts[2]}

case $1 in
    major)
        major=$((major + 1))
        minor=0
        patch=0
        ;;
    minor)
        minor=$((minor + 1))
        patch=0
        ;;
    patch|*)
        patch=$((patch + 1))
        ;;
esac

NEW_VERSION="$major.$minor.$patch"
echo $NEW_VERSION > $VERSION_FILE

echo "Version updated: $CURRENT_VERSION → $NEW_VERSION"
echo "Current milestone: $(if [ "$major" -eq 0 ]; then echo "Development (Pre-release)"; elif [ "$major" -eq 1 ]; then echo "Production Ready"; else echo "Post-Production"; fi)"

# Export for other scripts
export CODEMIND_VERSION=$NEW_VERSION