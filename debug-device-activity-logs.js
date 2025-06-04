#!/usr/bin/env node

/**
 * Debug script for DeviceActivityReport blank view issues
 * 
 * Run this script to capture and analyze logs from the DeviceActivityReport
 * to help identify why views might be appearing blank.
 * 
 * Usage: node debug-device-activity-logs.js
 */

console.log(`
🔍 DeviceActivityReport Debug Log Analysis
==========================================

To debug blank view issues, watch for these key log patterns:

📊 React Component Logs (Console):
----------------------------------
• "📊 DeviceActivityReportView Render Debug:" - Component render info
• "⚠️ DeviceActivityReportView: No activity selection provided" - Missing selection
• "⚠️ DeviceActivityReportView: Empty string familyActivitySelectionId" - Invalid ID
• "⚠️ DeviceActivityReportView: Very short time period" - Time range issues
• "🎯 DeviceActivityReportView: Passing props to native view" - Final props sent

🔧 Swift Module Logs (Xcode Console):
-------------------------------------
• "🔧 DeviceActivityReportView: Setting [prop] prop" - Property setters
• "⚠️ DeviceActivityReportView: familyActivitySelectionId is nil or empty" - Missing selection
• "⚠️ DeviceActivityReportView: No stored selection found" - Invalid selection ID
• "✅ DeviceActivityReportView: Successfully loaded selection" - Valid selection loaded

📊 View Model Logs (Xcode Console):
----------------------------------
• "📊 Model: familyActivitySelection changed" - Selection updates
• "📅 Model: Valid time range" - Time range validation
• "⚠️ Model: Very short time range" - Time range warnings
• "❌ Model: Invalid time range" - Time range errors

🎨 View Rendering Logs (Xcode Console):
--------------------------------------
• "🎨 ReportUI: Rendering DeviceActivityReport view" - View rendering start
• "🔍 ReportUI: Current State Summary" - Current state details
• "⚠️ ReportUI: BLANK VIEW LIKELY" - Predictions of blank views
• "👁️ ReportUI: View appeared" - View lifecycle events

📋 Data Processing Logs (Xcode Console):
----------------------------------------
• "🔍 AppListReport: Starting data processing" - Data processing start
• "📊 AppListReport: Processing data point" - Data iteration
• "📱 AppListReport: Found app" - Individual app data found
• "⚠️ AppListReport: EMPTY USAGE MAP" - No data found (causes blank view)
• "🚨 AppListReport: RETURNING EMPTY ARRAY" - Empty result (causes blank view)

🎨 View Display Logs (Xcode Console):
------------------------------------
• "🎨 AppListView: Rendering with [N] app usage entries" - View rendering
• "⚠️ AppListView: Rendering EMPTY STATE" - Empty state rendering
• "👁️ AppListView: Empty state view appeared" - Empty state shown
• "👁️ AppListView: Data list view appeared" - Data view shown

🚨 BLANK VIEW INDICATORS:
========================
Look for these patterns that indicate a blank view:

1. Empty Selection:
   ⚠️ "No activity selection provided"
   ⚠️ "familyActivitySelectionId is nil or empty"
   ⚠️ "No stored selection found"

2. Invalid Time Range:
   ❌ "Invalid time range"
   ⚠️ "Very short time range"
   ⚠️ "Zero time range"

3. No Data Found:
   ⚠️ "EMPTY USAGE MAP"
   🚨 "RETURNING EMPTY ARRAY"
   ⚠️ "BLANK VIEW LIKELY"

4. Empty View Rendering:
   ⚠️ "Rendering EMPTY STATE"
   👁️ "Empty state view appeared"

💡 DEBUGGING STEPS:
==================

1. Check React logs first:
   • Open browser/Metro console
   • Look for React component debug logs
   • Verify props are being passed correctly

2. Check Swift logs:
   • Open Xcode console
   • Filter by "ReactNativeDeviceActivity"
   • Follow the log sequence from props → model → view → data

3. Identify the failure point:
   • Props not passed? → React component issue
   • Selection not loaded? → Storage/ID issue
   • No data processed? → DeviceActivity permissions/data issue
   • Empty view rendered? → Data processing issue

4. Common fixes:
   • Ensure valid familyActivitySelectionId
   • Check DeviceActivity permissions
   • Verify time range is reasonable (> 1 hour, not in future)
   • Ensure selected apps were actually used

📱 To enable detailed logging in Xcode:
--------------------------------------
1. Open your iOS project in Xcode
2. Run the app on simulator/device
3. Open Console tab (View → Debug Area → Show Debug Area)
4. Filter by "ReactNativeDeviceActivity" to see all logs
5. Look for the patterns above to identify the issue

🔄 For real-time debugging:
--------------------------
1. Add this to your React component:
   useEffect(() => {
     console.log('DeviceActivityReport props:', { familyActivitySelectionId, context, from, to });
   }, [familyActivitySelectionId, context, from, to]);

2. Check logs every time the view renders
3. Compare working vs non-working scenarios
4. Look for differences in the log patterns

Good luck debugging! 🐛🔍
`);

// Helper functions for log analysis
const logPatterns = {
  blankViewIndicators: [
    'No activity selection provided',
    'familyActivitySelectionId is nil or empty',
    'No stored selection found',
    'Invalid time range',
    'Very short time range',
    'Zero time range',
    'EMPTY USAGE MAP',
    'RETURNING EMPTY ARRAY',
    'BLANK VIEW LIKELY',
    'Rendering EMPTY STATE',
    'Empty state view appeared'
  ],
  
  successIndicators: [
    'Successfully loaded selection',
    'Valid time range',
    'Found app',
    'Data list view appeared',
    'Returning [N] app usage entries'
  ]
};

function analyzeLogLine(line) {
  const isBlankIndicator = logPatterns.blankViewIndicators.some(pattern => 
    line.includes(pattern)
  );
  
  const isSuccessIndicator = logPatterns.successIndicators.some(pattern => 
    line.includes(pattern)
  );
  
  if (isBlankIndicator) {
    return { type: 'warning', message: line };
  } else if (isSuccessIndicator) {
    return { type: 'success', message: line };
  }
  
  return { type: 'info', message: line };
}

console.log('\n📖 Example log analysis function available:');
console.log('Run analyzeLogLine("your log message here") to classify log importance\n');

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { logPatterns, analyzeLogLine };
} 