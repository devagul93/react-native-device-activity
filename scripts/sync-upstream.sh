#!/bin/bash

# Script to sync upstream changes and maintain git dependency compatibility
# Usage: ./scripts/sync-upstream.sh

set -e

echo "🔄 Syncing with upstream repository..."

# Fetch latest changes from upstream
echo "📥 Fetching upstream changes..."
git fetch upstream

# Check if there are new commits
NEW_COMMITS=$(git log --oneline monorepo-root-test..upstream/main)
if [ -z "$NEW_COMMITS" ]; then
    echo "✅ No new commits in upstream. Your fork is up to date!"
    exit 0
fi

echo "📋 New commits found in upstream:"
echo "$NEW_COMMITS"
echo ""

# Switch to main branch and sync
echo "🔄 Syncing main branch with upstream..."
git checkout main
git pull upstream main
git push origin main

# Create a new branch for the updated git dependency version
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
NEW_BRANCH="monorepo-root-updated-$TIMESTAMP"

echo "🌿 Creating new branch: $NEW_BRANCH"
git checkout -b "$NEW_BRANCH"

# Apply git dependency modifications
echo "🔧 Applying git dependency modifications..."

# 1. Update root package.json
echo "  📝 Updating root package.json..."
# Get the current version from the library package.json
LIBRARY_VERSION=$(node -p "require('./packages/react-native-device-activity/package.json').version")

# Update root package.json with git dependency configuration
cat > temp_package.json << EOF
{
  "name": "react-native-device-activity",
  "version": "$LIBRARY_VERSION",
  "private": false,
  "description": "Provides access to Apples DeviceActivity API",
  "main": "packages/react-native-device-activity/build/index.js",
  "types": "packages/react-native-device-activity/build/index.d.ts",
  "scripts": {
    "lint": "eslint .",
    "pre-push": "bun run typecheck && bun run lint",
    "typecheck": "cd packages/react-native-device-activity && bun run typecheck",
    "typecheck-all": "cd packages/react-native-device-activity && bun run typecheck && cd ../../apps/example && bun run typecheck",
    "build": "cd packages/react-native-device-activity && npm run build",
    "prepare": "npm run build",
    "postinstall": "husky",
    "nail-workspace-dependency-versions": "bun run scripts/nail-workspace-dependency-versions.ts"
  },
  "workspaces": [
    "packages/*",
    "apps/*"
  ],
  "keywords": [
    "react-native",
    "expo",
    "react-native-device-activity",
    "device-activity",
    "screen-time"
  ],
  "repository": {
    "url": "git+https://github.com/devagul93/react-native-device-activity.git"
  },
  "bugs": {
    "url": "https://github.com/kingstinct/react-native-device-activity/issues"
  },
  "author": "Robert Herber <robert@kingstinct.com> (https://github.com/robertherber)",
  "license": "MIT",
  "homepage": "https://github.com/kingstinct/react-native-device-activity#readme",
EOF

# Add dependencies from library package.json
node -e "
const rootPkg = JSON.parse(require('fs').readFileSync('temp_package.json', 'utf8'));
const libPkg = require('./packages/react-native-device-activity/package.json');

rootPkg.dependencies = libPkg.dependencies;
rootPkg.peerDependencies = libPkg.peerDependencies;
rootPkg.devDependencies = {
  'eslint': '8',
  'husky': '^9.1.7',
  'prettier': '^3.3.3',
  'typescript': '^5.0.0',
  ...libPkg.devDependencies
};

require('fs').writeFileSync('package.json', JSON.stringify(rootPkg, null, 2) + '\n');
"

rm temp_package.json

# 2. Copy essential files to root
echo "  📁 Copying essential files to root..."
cp packages/react-native-device-activity/app.plugin.js .
cp packages/react-native-device-activity/expo-module.config.json .
cp -r packages/react-native-device-activity/config-plugin .
cp -r packages/react-native-device-activity/ios .
cp -r packages/react-native-device-activity/targets .

# 3. Fix app.plugin.js path reference
echo "  🔧 Fixing app.plugin.js path reference..."
sed -i '' 's|require("../../package.json")|require("./package.json")|g' app.plugin.js

# 4. Fix workspace dependency in example app
echo "  🔧 Fixing workspace dependency in example app..."
sed -i '' "s|\"react-native-device-activity\": \"workspace:\*\"|\"react-native-device-activity\": \"$LIBRARY_VERSION\"|g" apps/example/package.json

# 5. Update autolinking in example app
echo "  🔧 Updating autolinking configuration..."
sed -i '' 's|"nativeModulesDir": "../.."|"nativeModulesDir": "../../packages"|g' apps/example/package.json

echo "✅ Git dependency modifications applied!"

# Commit changes
echo "💾 Committing changes..."
git add .
git commit -m "Update to upstream $(git rev-parse --short upstream/main) with git dependency compatibility

- Sync with latest upstream changes
- Apply git dependency configuration to root package.json
- Copy essential files to root level
- Fix workspace dependencies for npm compatibility
- Update autolinking configuration"

echo "🚀 Ready to push! Run:"
echo "  git push origin $NEW_BRANCH"
echo ""
echo "Then update your consuming apps to use:"
echo "  \"react-native-device-activity\": \"git+https://github.com/devagul93/react-native-device-activity.git#$NEW_BRANCH\"" 