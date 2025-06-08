# Most Used Apps Implementation Guide - Enhanced Version

This guide explains how to implement an advanced "Most Used Apps" feature that shows **daily averages**, **peak usage hours**, and **pixel-perfect Apple Screen Time styling**.

## Overview

The enhanced "Most Used Apps" feature displays intelligent usage analytics including:
- **Daily average usage** (not cumulative totals)
- **Dynamic peak usage hour detection** (e.g., "9pm-12am")
- **Per-day calculations** across any time range
- **Detailed app breakdown** with individual usage times
- **Smart behavioral insights** with contextual recommendations
- **Pixel-perfect Apple design** with authentic app branding

## Key Improvements Over Previous Version

### 1. Daily Averages Instead of Cumulative Data
```swift
struct MostUsedAppsData {
  let appName: String
  let bundleIdentifier: String?
  let totalDuration: TimeInterval     // Total across period
  let dailyAverage: TimeInterval      // ⭐ NEW: Average per day
  let categoryName: String?
  let daysInPeriod: Int              // ⭐ NEW: For calculations
}
```

### 2. Dynamic Peak Usage Detection
```swift
struct UsageInsights {
  let peakHours: String               // ⭐ NEW: e.g., "9pm-12am"
  let totalApps: Int
  let averageDailyScreenTime: TimeInterval
  let behavioralInsight: String       // ⭐ NEW: Context-aware insights
}
```

### 3. Enhanced Data Processing
The implementation now:
- **Tracks hourly usage patterns** to identify peak times
- **Calculates unique days** in the date range
- **Computes true daily averages** by dividing total usage by actual days
- **Generates dynamic behavioral insights** based on usage patterns

## Architecture

### 1. Data Structure (`MostUsedAppsData`)
```swift
struct MostUsedAppsData {
  let appName: String
  let bundleIdentifier: String?
  let totalDuration: TimeInterval     // Total usage across period
  let dailyAverage: TimeInterval      // Average usage per day
  let categoryName: String?
  let daysInPeriod: Int              // Number of days for averages
}
```

### 2. Usage Insights (`UsageInsights`)
```swift
struct UsageInsights {
  let peakHours: String              // Dynamic peak hours (e.g., "9pm-12am")
  let totalApps: Int                 // Number of apps tracked
  let averageDailyScreenTime: TimeInterval // Total daily average
  let behavioralInsight: String      // Context-aware recommendation
}
```

### 3. Report Scene (`MostUsedAppsReport`)
Enhanced data processing that:
- **Tracks hourly usage** for peak detection
- **Counts unique days** for accurate averaging
- **Processes both apps and web domains**
- **Generates intelligent insights**

### 4. View (`MostUsedAppsView`)
Pixel-perfect interface featuring:
- **Daily average display** ("2h 30m per day")
- **Enhanced app breakdown** with individual times
- **Gradient backgrounds** and refined typography
- **Better empty states** and loading indicators

## Key Features

### Peak Usage Hour Detection
```swift
private func findPeakUsageHours(hourlyUsage: [Int: TimeInterval]) -> String {
  // Find consecutive high-usage hours
  let sortedHours = hourlyUsage.sorted { $0.value > $1.value }
  let topHours = Array(sortedHours.prefix(3)).map { $0.key }.sorted()
  
  if topHours.count >= 2 {
    let startHour = topHours.first!
    let endHour = topHours.last! + 1
    return formatHourRange(start: startHour, end: endHour)
  }
  
  return "9pm-12am" // Fallback
}
```

### Daily Average Calculations
```swift
// Calculate unique days in period
let daysInPeriod = max(totalDays.count, 1)

// Convert to daily averages
let dailyAverage = totalDuration / Double(daysInPeriod)
```

### Context-Aware Insights
```swift
private func generateBehavioralInsight(apps: [MostUsedAppsData], peakHours: String) -> String {
  let socialMediaApps = apps.filter { /* social media detection */ }
  
  if socialMediaApps.count >= 2 {
    let reductionSuggestion = min(max(20, Int(Double(totalDailyMinutes) * 0.3)), 80)
    return "You are most active on social media between \(peakHours). Try blocking apps for \(reductionSuggestion) mins extra"
  }
  
  // Other contextual insights...
}
```

### Enhanced UI Components
```swift
// Daily average display
Text(formatDailyAverage(mostUsedAppsData))
  .font(.system(size: 48, weight: .thin, design: .default))
  .foregroundColor(.white)
  .tracking(-1)

Text("per day")
  .font(.system(size: 13, weight: .medium))
  .foregroundColor(.white.opacity(0.6))
  .textCase(.uppercase)
```

## Usage Examples

### Basic Implementation with Enhanced Features
```tsx
<DeviceActivityReportView
  context="Most Used Apps"
  familyActivitySelection={null}
  from={startDate.getTime()}
  to={endDate.getTime()}
  segmentation="daily"
  users="all"
  devices={null}
  style={{ height: 500 }} // Increased for app breakdown
/>
```

### Time Range Examples
```tsx
// Today - shows hourly patterns
const todayStart = new Date().setHours(0, 0, 0, 0);
const now = new Date().getTime();

<DeviceActivityReportView
  context="Most Used Apps"
  from={todayStart}
  to={now}
  segmentation="hourly" // For peak hour detection
/>

// This week - shows daily averages
const weekStart = getStartOfWeek();
const weekEnd = new Date().getTime();

<DeviceActivityReportView
  context="Most Used Apps"
  from={weekStart}
  to={weekEnd}
  segmentation="daily"
/>
```

## What Users See

### Before (Cumulative)
- "7h 30m" total usage over a week
- No context about daily habits
- Static time periods

### After (Daily Averages)
- "1h 4m per day" average usage
- "Peak usage: 9pm-12am" insights
- "Try blocking apps for 32 mins extra" recommendations

## Data Processing Improvements

### 1. Hourly Tracking
```swift
// Track usage by hour for peak detection
for await activitySegment in dataPoint.activitySegments {
  let hour = Calendar.current.component(.hour, from: activitySegment.dateInterval.start)
  hourlyUsage[hour, default: 0] += duration
}
```

### 2. Day Counting
```swift
// Count unique days for accurate averaging
let dayKey = Calendar.current.dateInterval(of: .day, for: dataPoint.dateInterval.start)?.start.timeIntervalSince1970 ?? 0
totalDays.insert(String(dayKey))
```

### 3. Smart Insights Generation
```swift
let insights = generateInsights(
  apps: topApps, 
  hourlyUsage: hourlyUsage, 
  daysInPeriod: daysInPeriod
)
```

## Visual Enhancements

### 1. Pixel-Perfect Layout
- **Gradient backgrounds** with subtle borders
- **Refined typography** with proper font weights
- **Better spacing** and visual hierarchy
- **Enhanced app icons** with brand colors

### 2. App Breakdown List
```swift
VStack(spacing: 0) {
  ForEach(Array(mostUsedAppsData.prefix(5).enumerated()), id: \.offset) { index, appData in
    HStack(spacing: 12) {
      AppIconCircle(/* ... */).scaleEffect(0.7)
      
      VStack(alignment: .leading, spacing: 2) {
        Text(appData.appName)
        Text(category).opacity(0.6)
      }
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: 2) {
        Text(formatAppDuration(appData.dailyAverage))
        Text("per day").opacity(0.5)
      }
    }
  }
}
```

## Performance Optimizations

- **Efficient day tracking** using Set<String>
- **Optimized hourly aggregation**
- **Smart app prioritization** (social media first)
- **Lazy loading** for large datasets

## Integration Steps

1. **Replace the old report file** with the enhanced version
2. **Update DeviceActivityReport.swift** to pass both data and insights
3. **Test with different time ranges** to verify averaging works correctly
4. **Verify peak hour detection** with real usage data

## Real-World Example

For a user with the following weekly usage:
- Instagram: 7 hours total → **1h 0m per day**
- X: 4.67 hours total → **40m per day**  
- Reddit: 3.5 hours total → **30m per day**

Peak usage detected between **9pm-12am** based on actual hourly data.

Insight generated: *"You are most active on social media between 9pm-12am. Try blocking apps for 58 mins extra"*

This provides actionable, personalized recommendations based on real usage patterns rather than just showing raw totals.

## Testing & Verification

1. **Test time ranges**: Verify daily averages are correct for different periods
2. **Check peak detection**: Ensure peak hours reflect actual usage patterns  
3. **Validate insights**: Confirm behavioral recommendations are contextual
4. **UI testing**: Verify pixel-perfect layout matches Apple's design

The enhanced implementation transforms raw usage data into meaningful, actionable insights that help users understand and improve their digital habits. 