# Fork Maintenance Guide

This document explains how to keep your fork up to date with upstream changes while maintaining git dependency compatibility.

## Overview

This fork has been modified to work as a git dependency by:
- Configuring the root `package.json` to expose the library
- Copying essential files to the root level
- Fixing workspace dependencies for npm compatibility
- Adding build scripts that run automatically during installation

## Tracking Upstream Changes

### 1. Check for New Upstream Changes

```bash
# Fetch latest changes from upstream
git fetch upstream

# Check what's new in upstream
git log --oneline monorepo-root-test..upstream/main

# See detailed changes
git diff monorepo-root-test..upstream/main
```

### 2. Automated Sync (Recommended)

Use the provided script to automatically sync and apply git dependency modifications:

```bash
./scripts/sync-upstream.sh
```

This script will:
- Fetch upstream changes
- Create a new branch with timestamp
- Apply all necessary git dependency modifications
- Commit the changes
- Provide instructions for pushing and updating consuming apps

### 3. Manual Sync Process

If you prefer to do it manually:

#### Step 1: Sync main branch
```bash
git checkout main
git pull upstream main
git push origin main
```

#### Step 2: Create new branch
```bash
git checkout -b monorepo-root-updated-$(date +%Y%m%d)
```

#### Step 3: Apply git dependency modifications

1. **Update root package.json**:
   - Change name to `react-native-device-activity`
   - Set `private: false`
   - Add `main` and `types` fields
   - Add build and prepare scripts
   - Copy dependencies from library package.json

2. **Copy essential files to root**:
   ```bash
   cp packages/react-native-device-activity/app.plugin.js .
   cp packages/react-native-device-activity/expo-module.config.json .
   cp -r packages/react-native-device-activity/config-plugin .
   cp -r packages/react-native-device-activity/ios .
   cp -r packages/react-native-device-activity/targets .
   ```

3. **Fix app.plugin.js path reference**:
   ```bash
   sed -i '' 's|require("../../package.json")|require("./package.json")|g' app.plugin.js
   ```

4. **Fix workspace dependency in example app**:
   ```bash
   # Replace workspace:* with actual version
   sed -i '' 's|"workspace:\*"|"0.4.31"|g' apps/example/package.json
   ```

5. **Update autolinking configuration**:
   ```bash
   sed -i '' 's|"nativeModulesDir": "../.."|"nativeModulesDir": "../../packages"|g' apps/example/package.json
   ```

#### Step 4: Commit and push
```bash
git add .
git commit -m "Update to upstream with git dependency compatibility"
git push origin monorepo-root-updated-$(date +%Y%m%d)
```

## Updating Consuming Apps

When you create a new branch with upstream changes:

1. **Update the git dependency in your consuming app's package.json**:
   ```json
   {
     "dependencies": {
       "react-native-device-activity": "git+https://github.com/devagul93/react-native-device-activity.git#monorepo-root-updated-20241225"
     }
   }
   ```

2. **Clear cache and reinstall**:
   ```bash
   rm -rf node_modules package-lock.json
   npm install
   ```

## Branch Strategy

- `main`: Synced with upstream, no git dependency modifications
- `monorepo-root-test`: Your current working git dependency branch
- `monorepo-root-updated-YYYYMMDD`: New branches created when syncing upstream

## Monitoring Upstream

Set up notifications for the upstream repository:
1. Go to https://github.com/kingstinct/react-native-device-activity
2. Click "Watch" → "Custom" → "Releases"
3. You'll get notified of new releases

## Testing Changes

Before updating consuming apps, test the new branch:

1. **Test the build process**:
   ```bash
   npm run build
   ```

2. **Test in a sample project**:
   ```bash
   # In a test project
   npm install git+https://github.com/devagul93/react-native-device-activity.git#new-branch-name
   ```

3. **Verify the library works as expected**

## Troubleshooting

### Build Failures
- Ensure all devDependencies are properly copied to root package.json
- Check that the prepare script is correctly configured

### Workspace Dependency Errors
- Ensure all `workspace:*` references are replaced with actual versions
- Check that no workspace protocol remains in any package.json files

### Import Errors
- Verify that main and types fields point to the correct build output
- Ensure the build directory is created during the prepare script 