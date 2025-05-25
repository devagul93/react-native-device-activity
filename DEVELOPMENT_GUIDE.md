# Development Guide

This guide explains how to develop and add new features to the `react-native-device-activity` library while maintaining git dependency compatibility.

## Development Environment Setup

```bash
# Set up the development environment
./scripts/dev-workflow.sh setup
```

This will:
- Install dependencies in the library package
- Install root-level dependencies
- Prepare the environment for development

## Development Workflow

### 1. Making Changes to the Library

All development happens in the `packages/react-native-device-activity/` directory:

```
packages/react-native-device-activity/
├── src/                          # TypeScript source files
├── ios/                          # iOS native code (Swift)
├── targets/                      # iOS App Extensions
├── config-plugin/               # Expo config plugin helpers
├── app.plugin.js               # Main Expo config plugin
├── expo-module.config.json     # Expo module configuration
└── package.json                # Library package configuration
```

### 2. Types of Changes and Workflows

#### A. Adding New TypeScript/JavaScript Code

**Example: Adding a new function or component**

1. **Add your code** in `packages/react-native-device-activity/src/`:
   ```typescript
   // packages/react-native-device-activity/src/NewFeature.ts
   export const newFeature = () => {
     // Your implementation
   };
   ```

2. **Export it** in `packages/react-native-device-activity/src/index.ts`:
   ```typescript
   export { newFeature } from './NewFeature';
   ```

3. **Build and test**:
   ```bash
   ./scripts/dev-workflow.sh build
   ./scripts/dev-workflow.sh test-example
   ```

#### B. Adding New iOS Swift Files

**Example: Adding a new native module or view**

1. **Add Swift files** in `packages/react-native-device-activity/ios/`:
   ```swift
   // packages/react-native-device-activity/ios/NewNativeModule.swift
   import ExpoModulesCore
   
   public class NewNativeModule: Module {
     public func definition() -> ModuleDefinition {
       Name("NewNativeModule")
       
       Function("newNativeFunction") {
         // Your implementation
       }
     }
   }
   ```

2. **Update the podspec** if needed in `packages/react-native-device-activity/ios/ReactNativeDeviceActivity.podspec`

3. **Add TypeScript bindings** in `packages/react-native-device-activity/src/`:
   ```typescript
   // packages/react-native-device-activity/src/NewNativeModule.ts
   import ReactNativeDeviceActivityModule from './ReactNativeDeviceActivityModule';
   
   export function newNativeFunction() {
     return ReactNativeDeviceActivityModule.newNativeFunction();
   }
   ```

4. **Build, sync, and test**:
   ```bash
   ./scripts/dev-workflow.sh build
   ./scripts/dev-workflow.sh sync    # Important: syncs iOS files to root
   ./scripts/dev-workflow.sh test-example
   ```

#### C. Adding New iOS App Extension Targets

**Example: Adding a new Screen Time extension**

1. **Create target directory** in `packages/react-native-device-activity/targets/`:
   ```
   packages/react-native-device-activity/targets/NewExtension/
   ├── NewExtension.swift
   ├── Info.plist
   └── expo-target.config.js
   ```

2. **Add the Swift implementation**:
   ```swift
   // packages/react-native-device-activity/targets/NewExtension/NewExtension.swift
   import DeviceActivity
   
   @main
   struct NewExtension: DeviceActivityMonitor {
     // Your extension implementation
   }
   ```

3. **Configure the target** in `expo-target.config.js`:
   ```javascript
   const { createExpoTargetConfig } = require('../../config-plugin/createExpoTargetConfig');
   
   module.exports = createExpoTargetConfig({
     type: 'app-extension',
     name: 'NewExtension',
     bundleIdentifier: 'com.yourapp.NewExtension',
     // ... other configuration
   });
   ```

4. **Update Info.plist** with appropriate extension configuration

5. **Build, sync, and test**:
   ```bash
   ./scripts/dev-workflow.sh build
   ./scripts/dev-workflow.sh sync    # Important: syncs targets to root
   ./scripts/dev-workflow.sh test-example
   ```

#### D. Modifying Expo Config Plugin

**Example: Adding new configuration options**

1. **Update config plugin files** in `packages/react-native-device-activity/config-plugin/`

2. **Modify the main plugin** in `packages/react-native-device-activity/app.plugin.js`

3. **Update TypeScript types** if needed in `packages/react-native-device-activity/src/ReactNativeDeviceActivity.types.ts`

4. **Sync and test**:
   ```bash
   ./scripts/dev-workflow.sh sync    # Important: syncs config plugin to root
   ./scripts/dev-workflow.sh test-example
   ```

### 3. Testing Your Changes

#### Local Testing in Example App

```bash
# Test in the included example app
./scripts/dev-workflow.sh test-example
cd apps/example
npm run ios
```

#### Testing in External Consuming App

1. **Create a development branch**:
   ```bash
   ./scripts/dev-workflow.sh publish-branch
   git push origin dev-YYYYMMDD-HHMMSS
   ```

2. **Update your consuming app** to use the development branch:
   ```json
   {
     "dependencies": {
       "react-native-device-activity": "git+https://github.com/devagul93/react-native-device-activity.git#dev-YYYYMMDD-HHMMSS"
     }
   }
   ```

3. **Clear cache and reinstall**:
   ```bash
   rm -rf node_modules package-lock.json
   npm install
   ```

### 4. Version Management

When you make changes, consider updating the version in `packages/react-native-device-activity/package.json`:

```json
{
  "version": "0.4.32"  // Increment appropriately
}
```

The sync process will automatically update the root package.json version.

### 5. Committing Changes

```bash
# Commit your development changes
./scripts/dev-workflow.sh commit
```

This will:
- Build the library
- Sync changes to root level
- Commit with your message

### 6. Publishing Development Branches

```bash
# Create a new branch for testing in consuming apps
./scripts/dev-workflow.sh publish-branch
git push origin dev-YYYYMMDD-HHMMSS
```

## Important Notes

### File Synchronization

The key to this workflow is understanding that changes in `packages/react-native-device-activity/` need to be synced to the root level for git dependency compatibility:

- **TypeScript/JavaScript**: Built files go to `packages/react-native-device-activity/build/`
- **iOS files**: Copied to root `ios/` directory
- **Targets**: Copied to root `targets/` directory
- **Config plugin**: Copied to root `config-plugin/` and `app.plugin.js`

### Always Sync After Changes

After making changes to:
- iOS Swift files
- App Extension targets
- Config plugin files
- Expo module configuration

Always run:
```bash
./scripts/dev-workflow.sh sync
```

### Testing Strategy

1. **Unit tests**: Add tests in `packages/react-native-device-activity/src/`
2. **Example app**: Test basic functionality
3. **Real consuming app**: Test full integration
4. **iOS device**: Test native functionality and extensions

### Branch Strategy for Development

- `monorepo-root-test`: Your main git dependency branch
- `dev-YYYYMMDD-HHMMSS`: Development branches for testing new features
- `feature/feature-name`: Feature development branches (optional)

## Common Development Scenarios

### Adding a New Screen Time API

1. Add Swift implementation in `ios/`
2. Add TypeScript bindings in `src/`
3. Update types in `ReactNativeDeviceActivity.types.ts`
4. Build, sync, and test
5. Create development branch for testing

### Adding a New App Extension

1. Create target directory in `targets/`
2. Implement Swift extension
3. Configure `expo-target.config.js`
4. Update config plugin if needed
5. Sync, test, and publish development branch

### Modifying Existing Functionality

1. Make changes in appropriate files
2. Update tests if needed
3. Build and test locally
4. Create development branch for external testing

This workflow ensures that your development changes are properly built, synced, and ready for testing in consuming applications while maintaining the git dependency compatibility. 