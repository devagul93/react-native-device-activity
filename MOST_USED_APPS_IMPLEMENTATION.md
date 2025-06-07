# Most Used Apps Implementation Guide

This guide explains how to implement a "Most Used Apps" feature similar to Apple's Screen Time interface using the DeviceActivityReport framework.

## Overview

The "Most Used Apps" feature displays the top applications based on usage time, complete with:
- App icons and names
- Usage duration 
- Category information
- Total usage time
- Clean, Apple-style interface
- Smart usage insights

## Architecture

The implementation consists of three main components:

### 1. Data Structure (`MostUsedAppsData`)
```swift
struct MostUsedAppsData {
  let appName: String
  let bundleIdentifier: String?
  let duration: TimeInterval
  let categoryName: String?
}
```

### 2. Report Scene (`MostUsedAppsReport`)
Processes DeviceActivity data and extracts app usage information:
- Aggregates usage time per app
- Handles both applications and web domains
- Sorts by usage duration
- Limits to top 10 apps

### 3. View (`MostUsedAppsView`)
Renders the UI with:
- Custom app icons with colors
- Usage time formatting
- Category labels
- Total time display
- Responsive layout

## Key Features

### Smart App Icons
The implementation includes intelligent app icon generation:

```swift
private func appIcon(for bundleId: String?) -> String {
  switch bundleId {
  case let id where id?.contains("instagram") == true:
    return "camera.circle.fill"
  case let id where id?.contains("twitter") == true:
    return "x.circle.fill" 
  case let id where id?.contains("reddit") == true:
    return "circle.fill"
  // ... more mappings
  default:
    return "app.circle.fill"
  }
}
```

### Time Formatting
Duration is formatted in a user-friendly way:
```swift
private func formatDuration(_ duration: TimeInterval) -> String {
  let totalMinutes = Int(duration) / 60
  let hours = totalMinutes / 60
  let minutes = totalMinutes % 60

  if hours > 0 {
    return "\(hours)h \(minutes)m"
  } else {
    return "\(minutes)m"
  }
}
```

### Color-Coded Icons
Apps get deterministic colors based on their bundle ID:
```swift
private func iconColor(for identifier: String) -> Color {
  let colors: [Color] = [
    Color(red: 0.2, green: 0.6, blue: 1.0), // Instagram-like blue
    Color(red: 0.1, green: 0.1, blue: 0.1), // X/Twitter-like black
    Color(red: 1.0, green: 0.27, blue: 0.0), // Reddit-like orange
    // ... more colors
  ]
  
  let key = bundleIdentifier ?? appName
  let index = abs(key.hashValue) % colors.count
  return colors[index]
}
```

## Usage in React Native

### Basic Implementation
```tsx
import { DeviceActivityReportView } from 'react-native-device-activity';

<DeviceActivityReportView
  context="Most Used Apps"
  familyActivitySelection={null} // Show all apps
  from={startDate.getTime()}
  to={endDate.getTime()}
  segmentation="daily"
  users="all"
  devices={null}
  style={{ height: 400 }}
/>
```

### With Time Range Selection
```tsx
const [timeRange, setTimeRange] = useState<"today" | "week" | "month">("today");

const getDateRange = () => {
  const now = new Date();
  let startDate: Date;
  
  switch (timeRange) {
    case "today":
      startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      break;
    case "week":
      // Week calculation logic
      break;
    case "month":
      startDate = new Date(now.getFullYear(), now.getMonth(), 1);
      break;
  }
  
  return { startDate, endDate: new Date() };
};

const { startDate, endDate } = getDateRange();

<DeviceActivityReportView
  context="Most Used Apps"
  from={startDate.getTime()}
  to={endDate.getTime()}
  segmentation={timeRange === "today" ? "hourly" : "daily"}
/>
```

## Customization Options

### Report Style
You can customize the appearance using the `reportStyle` prop:
```tsx
<DeviceActivityReportView
  context="Most Used Apps"
  reportStyle={{
    backgroundColor: "#1a1a1a",
    textColor: "#ffffff",
    accentColor: "#007AFF"
  }}
/>
```

### Filtering Apps
To show only specific apps, use the `familyActivitySelection` prop:
```tsx
// Show only social media apps
<DeviceActivityReportView
  context="Most Used Apps"
  familyActivitySelection={socialMediaSelectionToken}
/>
```

### Device and User Filtering
```tsx
// Show data for specific devices
<DeviceActivityReportView
  context="Most Used Apps"
  devices={[DeviceActivityReportViewDevice.iPhone]}
  users="children" // or "all"
/>
```

## Data Processing Logic

The report processes DeviceActivity data in the following steps:

1. **Data Collection**: Iterates through activity segments and categories
2. **App Aggregation**: Combines usage data for the same app across different segments
3. **Web Domain Handling**: Includes web domain usage alongside app usage
4. **Sorting**: Orders apps by total usage duration (descending)
5. **Limiting**: Shows only the top 10 most used apps
6. **Formatting**: Converts raw data into display-ready format

## Privacy Considerations

The implementation respects Apple's privacy guidelines:
- Runs in a sandboxed extension
- No network requests allowed
- Data stays within the extension's address space
- Requires proper Family Controls authorization

## Performance Optimizations

- Uses `LazyVStack` for efficient list rendering
- Limits results to top 10 apps
- Caches calculated values where appropriate
- Optimized async data processing

## Integration Steps

1. **Add the Report Files**: 
   - `MostUsedAppsReport.swift` (contains both report and view)

2. **Register the Report**: 
   Add to `DeviceActivityReport.swift`:
   ```swift
   MostUsedAppsReport { mostUsedAppsData in
     MostUsedAppsView(mostUsedAppsData: mostUsedAppsData)
   }
   ```

3. **Use in React Native**:
   ```tsx
   <DeviceActivityReportView context="Most Used Apps" />
   ```

## Common Issues and Solutions

### No Data Appearing
- Ensure Family Controls authorization is granted
- Check that the date range includes actual app usage
- Verify the `familyActivitySelection` isn't too restrictive

### App Icons Not Showing
- Bundle ID mapping might need updates for new apps
- SF Symbols availability varies by iOS version
- Fallback to generic icon is automatic

### Performance Issues
- Large date ranges can slow processing
- Consider limiting the time span for better performance
- Use appropriate segmentation (hourly/daily/weekly)

## Example Implementation

See `apps/example/screens/MostUsedAppsScreen.tsx` for a complete working example that includes:
- Time range selection
- Responsive design
- Loading states
- Error handling
- User-friendly interface

This implementation provides a robust, Apple-style "Most Used Apps" interface that seamlessly integrates with your React Native app while respecting user privacy and system constraints. 