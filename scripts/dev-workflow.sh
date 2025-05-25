#!/bin/bash

# Development workflow script for react-native-device-activity
# Usage: ./scripts/dev-workflow.sh [command]

set -e

COMMAND=${1:-help}

case $COMMAND in
  "setup")
    echo "🔧 Setting up development environment..."
    
    # Install dependencies in the library package
    echo "📦 Installing library dependencies..."
    cd packages/react-native-device-activity
    npm install
    cd ../..
    
    # Install root dependencies
    echo "📦 Installing root dependencies..."
    bun install
    
    echo "✅ Development environment ready!"
    echo ""
    echo "Next steps:"
    echo "  1. Make changes in packages/react-native-device-activity/"
    echo "  2. Run './scripts/dev-workflow.sh build' to build"
    echo "  3. Run './scripts/dev-workflow.sh sync' to sync changes to root"
    echo "  4. Test in example app or consuming project"
    ;;
    
  "build")
    echo "🔨 Building library..."
    cd packages/react-native-device-activity
    npm run build
    cd ../..
    echo "✅ Library built successfully!"
    ;;
    
  "sync")
    echo "🔄 Syncing library changes to root level..."
    
    # Get the current version from the library package.json
    LIBRARY_VERSION=$(node -p "require('./packages/react-native-device-activity/package.json').version")
    echo "📋 Library version: $LIBRARY_VERSION"
    
    # Update root package.json version
    node -e "
    const pkg = require('./package.json');
    pkg.version = '$LIBRARY_VERSION';
    require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
    "
    
    # Copy/update essential files to root
    echo "  📁 Copying essential files to root..."
    cp packages/react-native-device-activity/app.plugin.js .
    cp packages/react-native-device-activity/expo-module.config.json .
    
    # Copy directories (remove and recreate to handle deletions)
    echo "  📁 Syncing config-plugin..."
    rm -rf config-plugin
    cp -r packages/react-native-device-activity/config-plugin .
    
    echo "  📁 Syncing iOS files..."
    rm -rf ios
    cp -r packages/react-native-device-activity/ios .
    
    echo "  📁 Syncing targets..."
    rm -rf targets
    cp -r packages/react-native-device-activity/targets .
    
    # Fix app.plugin.js path reference
    echo "  🔧 Fixing app.plugin.js path reference..."
    sed -i '' 's|require("../../package.json")|require("./package.json")|g' app.plugin.js
    
    echo "✅ Library changes synced to root level!"
    ;;
    
  "test-example")
    echo "🧪 Testing in example app..."
    cd apps/example
    
    # Ensure the example app uses the local version
    echo "  📝 Updating example app to use local library..."
    node -e "
    const pkg = require('./package.json');
    const libVersion = require('../../packages/react-native-device-activity/package.json').version;
    pkg.dependencies['react-native-device-activity'] = libVersion;
    require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
    "
    
    echo "  📦 Installing example app dependencies..."
    npm install
    
    echo "  🔨 Building example app..."
    npm run prebuild
    
    echo "✅ Example app ready for testing!"
    echo "Run 'cd apps/example && npm run ios' to test on iOS"
    ;;
    
  "commit")
    echo "💾 Committing development changes..."
    
    # Build and sync first
    ./scripts/dev-workflow.sh build
    ./scripts/dev-workflow.sh sync
    
    # Stage all changes
    git add .
    
    # Check if there are changes to commit
    if git diff --staged --quiet; then
      echo "ℹ️  No changes to commit"
      exit 0
    fi
    
    # Get commit message
    echo "Enter commit message:"
    read -r COMMIT_MESSAGE
    
    if [ -z "$COMMIT_MESSAGE" ]; then
      echo "❌ Commit message cannot be empty"
      exit 1
    fi
    
    git commit -m "$COMMIT_MESSAGE"
    echo "✅ Changes committed!"
    ;;
    
  "publish-branch")
    echo "🚀 Creating new development branch for git dependency..."
    
    # Build and sync first
    ./scripts/dev-workflow.sh build
    ./scripts/dev-workflow.sh sync
    
    # Create new branch with timestamp
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    NEW_BRANCH="dev-$TIMESTAMP"
    
    echo "🌿 Creating branch: $NEW_BRANCH"
    git checkout -b "$NEW_BRANCH"
    
    # Commit changes
    git add .
    git commit -m "Development changes - $(date)

- Updated library with latest development changes
- Synced all files to root for git dependency compatibility
- Ready for testing in consuming applications"
    
    echo "✅ Development branch created: $NEW_BRANCH"
    echo ""
    echo "To push and use in consuming apps:"
    echo "  git push origin $NEW_BRANCH"
    echo ""
    echo "Then update consuming apps to use:"
    echo "  \"react-native-device-activity\": \"git+https://github.com/devagul93/react-native-device-activity.git#$NEW_BRANCH\""
    ;;
    
  "help"|*)
    echo "🛠️  React Native Device Activity Development Workflow"
    echo ""
    echo "Commands:"
    echo "  setup           - Set up development environment"
    echo "  build           - Build the library"
    echo "  sync            - Sync library changes to root level"
    echo "  test-example    - Test changes in the example app"
    echo "  commit          - Build, sync, and commit changes"
    echo "  publish-branch  - Create a new branch for git dependency testing"
    echo "  help            - Show this help message"
    echo ""
    echo "Typical workflow:"
    echo "  1. ./scripts/dev-workflow.sh setup"
    echo "  2. Make changes in packages/react-native-device-activity/"
    echo "  3. ./scripts/dev-workflow.sh build"
    echo "  4. ./scripts/dev-workflow.sh test-example"
    echo "  5. ./scripts/dev-workflow.sh commit"
    echo "  6. ./scripts/dev-workflow.sh publish-branch"
    ;;
esac 