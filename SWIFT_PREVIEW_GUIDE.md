# Swift View Preview Guide for Faster Iteration

Here are the best methods to preview and iterate on your `MostUsedAppsView` Swift UI without going through the full React Native build cycle:

## Method 1: SwiftUI Previews in Xcode (⭐ Recommended)

I've already added SwiftUI previews to your `MostUsedAppsReport.swift` file. Here's how to use them:

### Steps:
1. Open your project in Xcode
2. Navigate to `packages/react-native-device-activity/targets/DeviceActivityReport/MostUsedAppsReport.swift`
3. Look for the `MostUsedAppsView_Previews` section at the bottom
4. In Xcode, press `Cmd + Option + Enter` or click "Canvas" in the top-right
5. You'll see live previews of your view with different states:
   - "With Data" - Shows the view with sample data
   - "Empty State" - Shows how it looks with no data
   - "Single App" - Shows minimal data case

### Benefits:
- ⚡ **Instant updates** - Changes appear immediately
- 🎨 **Multiple variants** - See different states side by side
- 🔄 **Interactive** - Can interact with the view in preview
- 📱 **Device simulation** - Preview on different screen sizes

### Available Previews:
```swift
struct MostUsedAppsView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      // Preview with sample data
      MostUsedAppsView(mostUsedAppsData: sampleData)
        .previewDisplayName("With Data")
      
      // Preview with empty state  
      MostUsedAppsView(mostUsedAppsData: [])
        .previewDisplayName("Empty State")
        
      // Preview with single app
      MostUsedAppsView(mostUsedAppsData: [sampleData[0]])
        .previewDisplayName("Single App")
    }
  }
}
```

## Method 2: Standalone Preview App

I've created `MostUsedAppsPreviewApp/ContentView.swift` which gives you a complete standalone app for testing.

### To use this:
1. Create a new iOS app project in Xcode
2. Replace the ContentView with the code from `MostUsedAppsPreviewApp/ContentView.swift`
3. Run the app in simulator or device
4. Use the segmented control to switch between different states

### Benefits:
- 🔧 **Full app context** - Test in a real app environment
- 🎮 **Interactive testing** - Tap, scroll, and interact freely
- 📊 **Multiple variants** - Toggle between different data states
- 🚀 **Fast iteration** - Cmd+R to rebuild and see changes

## Method 3: Hot Reload in Extension Target

### Steps:
1. Open the example app project in Xcode
2. Set your target to the DeviceActivityReport extension
3. Build and run on simulator
4. Make changes to the Swift files
5. Rebuild (Cmd+B) to see updates

### Benefits:
- 🎯 **Real context** - Test within the actual extension environment
- 🔄 **Quick feedback** - Faster than full React Native rebuild
- 📱 **Device testing** - Test on real devices easily

## Method 4: Xcode Playgrounds (Alternative)

If you want to use Playgrounds:

1. Create a new Playground in Xcode
2. Copy the view code into the playground
3. Use `PlaygroundPage.current.setLiveView()` to display

Note: This requires setting up proper framework imports.

## Quick Iteration Workflow

### Recommended Workflow:
1. **Start with SwiftUI Previews** (Method 1) for rapid visual iteration
2. **Switch to Preview App** (Method 2) for interactive testing
3. **Test in Extension** (Method 3) for final validation
4. **Deploy to React Native** when satisfied

### Typical Development Cycle:
```
┌─ Design Changes ────┐
│                     │
│  SwiftUI Previews   │ ← Start here (instant feedback)
│         ↓           │
│  Standalone App     │ ← Interactive testing  
│         ↓           │
│  Extension Testing  │ ← Real environment validation
│         ↓           │
│  React Native App   │ ← Final integration
└─────────────────────┘
```

## Pro Tips for Faster Iteration

### 1. Use Live Preview Data
I've provided realistic sample data that matches common app usage patterns:
- Instagram (1 hour)
- X/Twitter (40 minutes)  
- Reddit (30 minutes)
- YouTube (20 minutes)
- Spotify (15 minutes)

### 2. Test Multiple States
Always preview these scenarios:
- ✅ With full data (3+ apps)
- ✅ Empty state (no data)
- ✅ Single app
- ✅ Different screen sizes

### 3. Use Xcode's Canvas Features
- **Pin previews** to keep them visible while editing
- **Multiple device previews** - iPhone, iPad, different sizes
- **Dark/Light mode** - Test appearance in both themes
- **Accessibility** - Test with larger text sizes

### 4. Keyboard Shortcuts
- `Cmd + Option + Enter` - Toggle Canvas
- `Cmd + Option + P` - Refresh previews
- `Cmd + Shift + A` - Resume paused previews
- `Cmd + R` - Build and run

## Troubleshooting

### Preview Not Updating?
1. Try `Cmd + Option + P` to refresh
2. Clean build folder (`Cmd + Shift + K`)
3. Restart Xcode Canvas

### Can't See Previews?
1. Ensure you're in a `.swift` file with `PreviewProvider`
2. Check that Canvas is enabled (top-right corner)
3. Make sure the file compiles without errors

### Performance Issues?
1. Limit the number of preview variants
2. Use smaller sample datasets
3. Close other resource-intensive apps

## Sample Data for Testing

The preview includes realistic sample data:

```swift
let sampleData: [MostUsedAppsData] = [
  MostUsedAppsData(
    appName: "Instagram",
    bundleIdentifier: "com.burbn.instagram", 
    duration: 3600, // 1 hour
    categoryName: "Social Networking"
  ),
  // ... more apps
]
```

This covers the most common social media apps with realistic usage times that match typical Screen Time patterns.

## Integration Back to React Native

Once you're happy with your SwiftUI view:

1. Copy changes back to the main `MostUsedAppsReport.swift`
2. Build the React Native app
3. Test the `DeviceActivityReportView` component
4. The view should appear exactly as previewed

The preview environment uses the same code as the actual implementation, so what you see in previews is exactly what you'll get in the React Native app. 