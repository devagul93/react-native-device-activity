# DeviceActivityReportView with SelectionId Support

This document demonstrates how to use the new `familyActivitySelectionId` prop with `DeviceActivityReportView`, including edge case handling.

## Basic Usage

### Option 1: Using Stored Selection ID (New)
```typescript
import React from 'react';
import { DeviceActivityReportView, setFamilyActivitySelectionId } from 'react-native-device-activity';

// First, store a selection with an ID
const storeSelection = () => {
  setFamilyActivitySelectionId({
    id: 'my-report-selection',
    familyActivitySelection: mySerializedSelection
  });
};

// Then use it in the report
const MyReport = () => (
  <DeviceActivityReportView
    familyActivitySelectionId="my-report-selection"
    context="Total Activity"
    segmentation="daily"
    style={{ flex: 1 }}
  />
);
```

### Option 2: Using Direct Selection (Existing)
```typescript
const MyReport = () => (
  <DeviceActivityReportView
    familyActivitySelection={mySerializedSelection}
    context="Total Activity"
    segmentation="daily"
    style={{ flex: 1 }}
  />
);
```

## Using the Convenience Hook

```typescript
import React from 'react';
import { DeviceActivityReportView, useDeviceActivityReportWithId } from 'react-native-device-activity';

const MyReportWithHook = ({ selectionId }: { selectionId: string }) => {
  const selection = useDeviceActivityReportWithId(selectionId);
  
  return (
    <DeviceActivityReportView
      familyActivitySelection={selection}
      context="Total Activity"
      segmentation="daily"
      style={{ flex: 1 }}
    />
  );
};
```

## App List Report Example

The App List report displays detailed information about app usage, showing each app with its usage time in a clean, organized list format. This report is perfect for creating blocked apps screens or detailed usage breakdowns similar to iOS Settings > Screen Time.

**Features:**
- Shows app names with colorful icons (first letter of app name)
- Displays usage time in "Xh:XXm" format (e.g., "1h:50m", "24m")
- Header shows "BLOCKED APPS" and "AVG TIME"
- Apps are sorted by usage time (highest first)
- Supports both selected apps and all apps on device

```tsx
import React, { useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { DeviceActivityReportView } from 'react-native-device-activity';

export default function AppListReportExample() {
  const [familyActivitySelection, setFamilyActivitySelection] = useState<string | null>(null);

  // Set date range for today
  const today = new Date();
  const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());
  const endOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 23, 59, 59);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>App Usage Details</Text>
      
      <DeviceActivityReportView
        style={styles.reportView}
        context="App List"  // Use the App List context
        familyActivitySelection={familyActivitySelection}
        from={startOfDay.getTime()}
        to={endOfDay.getTime()}
        segmentation="daily"
        users="all"
        devices={null} // All devices
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 16,
    textAlign: 'center',
  },
  reportView: {
    flex: 1,
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 0, // No padding to let the native view handle its own layout
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
});
```

### Blocked Apps Report

Create a blocked apps screen similar to iOS Screen Time restrictions:

```tsx
import React, { useState } from 'react';
import { View, Text, StyleSheet, Button } from 'react-native';
import { 
  DeviceActivityReportView, 
  DeviceActivitySelectionView,
  useDeviceActivityReportWithId 
} from 'react-native-device-activity';

export default function BlockedAppsReport() {
  const [showSelection, setShowSelection] = useState(false);
  const familyActivitySelection = useDeviceActivityReportWithId('blocked-apps');

  const today = new Date();
  const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());
  const endOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 23, 59, 59);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Screen Time Restrictions</Text>
      
      <Button
        title={familyActivitySelection ? "Change Blocked Apps" : "Select Apps to Block"}
        onPress={() => setShowSelection(!showSelection)}
      />

      {showSelection && (
        <DeviceActivitySelectionView
          style={styles.selectionView}
          familyActivitySelectionId="blocked-apps"
          headerText="Select apps to block"
          footerText="These apps will be restricted during scheduled times"
          onSelectionChange={(event) => {
            console.log('Blocked apps selection changed:', event.nativeEvent);
            setShowSelection(false);
          }}
        />
      )}

      {familyActivitySelection && (
        <DeviceActivityReportView
          style={styles.reportView}
          context="App List"
          familyActivitySelectionId="blocked-apps"
          from={startOfDay.getTime()}
          to={endOfDay.getTime()}
          segmentation="daily"
          users="all"
          devices={null}
        />
      )}

      {!familyActivitySelection && (
        <View style={styles.placeholderView}>
          <Text style={styles.placeholderText}>
            No apps selected for blocking
          </Text>
          <Text style={styles.placeholderSubtext}>
            Select apps above to see their usage details
          </Text>
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 16,
    textAlign: 'center',
  },
  selectionView: {
    height: 300,
    marginVertical: 16,
    backgroundColor: 'white',
    borderRadius: 12,
  },
  reportView: {
    flex: 1,
    backgroundColor: 'white',
    borderRadius: 12,
    marginTop: 16,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  placeholderView: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'white',
    borderRadius: 12,
    marginTop: 16,
    padding: 32,
  },
  placeholderText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#6c757d',
    textAlign: 'center',
    marginBottom: 8,
  },
  placeholderSubtext: {
    fontSize: 14,
    color: '#adb5bd',
    textAlign: 'center',
  },
});
```

### Weekly App Usage Report

View app usage patterns over a week using the App List context:

```tsx
import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { DeviceActivityReportView } from 'react-native-device-activity';

export default function WeeklyAppUsageReport() {
  const [familyActivitySelection, setFamilyActivitySelection] = useState<string | null>(null);

  // Get the last 7 days
  const today = new Date();
  const sevenDaysAgo = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000);

  return (
    <ScrollView style={styles.container}>
      <Text style={styles.title}>Weekly App Usage</Text>
      <Text style={styles.subtitle}>Past 7 days usage breakdown</Text>
      
      <DeviceActivityReportView
        style={styles.reportView}
        context="App List"
        familyActivitySelection={familyActivitySelection}
        from={sevenDaysAgo.getTime()}
        to={today.getTime()}
        segmentation="daily"  // Shows daily breakdown within the week
        users="all"
        devices={null}
      />
      
      <View style={styles.infoBox}>
        <Text style={styles.infoTitle}>Understanding Your Usage</Text>
        <Text style={styles.infoText}>
          • Apps are sorted by total usage time{'\n'}
          • Time format: hours and minutes (e.g., 2h:30m){'\n'}
          • Includes both active usage and background time{'\n'}
          • Data is averaged across selected time period
        </Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    textAlign: 'center',
    marginVertical: 16,
    color: '#1c1c1e',
  },
  subtitle: {
    fontSize: 16,
    color: '#6c757d',
    textAlign: 'center',
    marginBottom: 20,
  },
  reportView: {
    height: 400, // Fixed height for scrollable content
    backgroundColor: 'white',
    marginHorizontal: 16,
    borderRadius: 16,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.15,
    shadowRadius: 6,
    elevation: 8,
  },
  infoBox: {
    backgroundColor: '#e3f2fd',
    margin: 16,
    padding: 20,
    borderRadius: 12,
    borderLeftWidth: 4,
    borderLeftColor: '#2196f3',
  },
  infoTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#1565c0',
    marginBottom: 8,
  },
  infoText: {
    fontSize: 14,
    color: '#424242',
    lineHeight: 20,
  },
});
```

### App List vs Other Contexts

Compare different report contexts to understand their use cases:

```tsx
import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { DeviceActivityReportView } from 'react-native-device-activity';

type ReportContext = 'App List' | 'Total Activity' | 'Pickups' | 'Total Pickups';

export default function ReportContextComparison() {
  const [activeContext, setActiveContext] = useState<ReportContext>('App List');
  const [familyActivitySelection, setFamilyActivitySelection] = useState<string | null>(null);

  const today = new Date();
  const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());
  const endOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 23, 59, 59);

  const contexts: Array<{
    key: ReportContext;
    title: string;
    description: string;
  }> = [
    {
      key: 'App List',
      title: 'App List',
      description: 'Detailed list of apps with usage times and icons'
    },
    {
      key: 'Total Activity',
      title: 'Total Activity',
      description: 'Simple total screen time across all apps'
    },
    {
      key: 'Pickups',
      title: 'Pickups',
      description: 'List of apps with pickup counts (how many times opened)'
    },
    {
      key: 'Total Pickups',
      title: 'Total Pickups',
      description: 'Total number of app pickups'
    }
  ];

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Report Context Comparison</Text>
      
      {/* Context Selector */}
      <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.contextSelector}>
        {contexts.map(({ key, title, description }) => (
          <TouchableOpacity
            key={key}
            style={[
              styles.contextButton,
              activeContext === key && styles.contextButtonActive
            ]}
            onPress={() => setActiveContext(key)}
          >
            <Text style={[
              styles.contextButtonText,
              activeContext === key && styles.contextButtonTextActive
            ]}>
              {title}
            </Text>
          </TouchableOpacity>
        ))}
      </ScrollView>

      {/* Context Description */}
      <View style={styles.descriptionBox}>
        <Text style={styles.descriptionText}>
          {contexts.find(c => c.key === activeContext)?.description}
        </Text>
      </View>
      
      {/* Report View */}
      <DeviceActivityReportView
        style={styles.reportView}
        context={activeContext}
        familyActivitySelection={familyActivitySelection}
        from={startOfDay.getTime()}
        to={endOfDay.getTime()}
        segmentation="daily"
        users="all"
        devices={null}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 16,
    textAlign: 'center',
  },
  contextSelector: {
    marginBottom: 16,
  },
  contextButton: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    marginRight: 8,
    backgroundColor: '#e9ecef',
    borderRadius: 20,
    minWidth: 100,
    alignItems: 'center',
  },
  contextButtonActive: {
    backgroundColor: '#007AFF',
  },
  contextButtonText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#6c757d',
  },
  contextButtonTextActive: {
    color: 'white',
  },
  descriptionBox: {
    backgroundColor: '#fff3cd',
    padding: 12,
    borderRadius: 8,
    marginBottom: 16,
    borderLeftWidth: 4,
    borderLeftColor: '#ffc107',
  },
  descriptionText: {
    fontSize: 14,
    color: '#856404',
    fontStyle: 'italic',
  },
  reportView: {
    flex: 1,
    backgroundColor: 'white',
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
});
```

### App List Features

The App List context provides rich functionality:

**Visual Features:**
- **Colorful App Icons**: Each app gets a unique colored icon with the first letter of its name
- **Usage Time Display**: Shows time in readable format (e.g., "2h:15m", "45m")
- **Clean Headers**: "BLOCKED APPS" and "AVG TIME" headers for clarity
- **Sorted List**: Apps automatically sorted by usage time (highest first)

**Data Features:**
- **Application Tokens**: Properly extracts all apps from FamilyActivitySelection
- **Web Domains**: Includes web usage if selected in FamilyActivityPicker
- **Time Aggregation**: Combines usage across multiple sessions
- **Fallback Handling**: Gracefully handles apps without tokens

**Use Cases:**
- Screen Time restriction interfaces
- Parental control apps
- Digital wellness dashboards
- Usage analytics screens
- App blocking confirmation views

## Edge Cases and Error Handling

### 1. Both Props Provided
```typescript
// ❌ This will show a warning and use familyActivitySelection
<DeviceActivityReportView
  familyActivitySelection={mySelection}
  familyActivitySelectionId="my-id"  // This will be ignored
  style={{ flex: 1 }}
/>
```

**Console Output:**
```
⚠️ DeviceActivityReportView: Both familyActivitySelection and familyActivitySelectionId provided. 
Using familyActivitySelection and ignoring familyActivitySelectionId. 
Please provide only one of these props.
```

### 2. Neither Props Provided
```typescript
// ⚠️ This will show a warning but still work (shows all activities)
<DeviceActivityReportView
  context="Total Activity"
  style={{ flex: 1 }}
/>
```

**Console Output:**
```
⚠️ DeviceActivityReportView: Neither familyActivitySelection nor familyActivitySelectionId provided. 
The report will show data for all activities.
```

### 3. Non-existent Selection ID
```typescript
// ⚠️ This will show a warning and use empty selection
<DeviceActivityReportView
  familyActivitySelectionId="non-existent-id"
  style={{ flex: 1 }}
/>
```

**Console Output (iOS):**
```
⚠️ DeviceActivityReportView: No stored selection found for ID 'non-existent-id'. 
Using empty selection. Available IDs: ["existing-id-1", "existing-id-2"]
```

### 4. Empty or Whitespace Selection ID
```typescript
// ⚠️ These will be treated as undefined
<DeviceActivityReportView familyActivitySelectionId="" />
<DeviceActivityReportView familyActivitySelectionId="   " />
<DeviceActivityReportView familyActivitySelectionId={null} />
```

### 5. Hook with Invalid ID
```typescript
const MyComponent = () => {
  const selection1 = useDeviceActivityReportWithId(''); // Returns null, shows warning
  const selection2 = useDeviceActivityReportWithId('non-existent'); // Returns null, shows warning
  
  return (
    <DeviceActivityReportView
      familyActivitySelection={selection1 || selection2}
      style={{ flex: 1 }}
    />
  );
};
```

## Complete Example with Error Handling

```typescript
import React, { useState, useEffect } from 'react';
import { View, Alert } from 'react-native';
import { 
  DeviceActivityReportView, 
  DeviceActivitySelectionViewPersisted,
  setFamilyActivitySelectionId,
  getFamilyActivitySelectionId,
  useDeviceActivityReportWithId
} from 'react-native-device-activity';

const SELECTION_ID = 'my-app-selection';

const ReportScreen = () => {
  const [hasSelection, setHasSelection] = useState(false);
  
  // Check if we have a stored selection
  useEffect(() => {
    const storedSelection = getFamilyActivitySelectionId(SELECTION_ID);
    setHasSelection(!!storedSelection);
  }, []);
  
  const handleSelectionChange = (event) => {
    const { applicationCount, categoryCount, webDomainCount } = event.nativeEvent;
    const hasAnySelection = applicationCount > 0 || categoryCount > 0 || webDomainCount > 0;
    setHasSelection(hasAnySelection);
  };
  
  if (!hasSelection) {
    return (
      <View style={{ flex: 1 }}>
        <DeviceActivitySelectionViewPersisted
          familyActivitySelectionId={SELECTION_ID}
          onSelectionChange={handleSelectionChange}
          style={{ flex: 1 }}
        />
      </View>
    );
  }
  
  return (
    <DeviceActivityReportView
      familyActivitySelectionId={SELECTION_ID}
      context="Total Activity"
      segmentation="daily"
      from={Date.now() - 7 * 24 * 60 * 60 * 1000} // Last 7 days
      to={Date.now()}
      style={{ flex: 1 }}
    />
  );
};

export default ReportScreen;
```

## Migration Guide

### From Direct Selection to Stored Selection

**Before:**
```typescript
const [selection, setSelection] = useState<string | null>(null);

// ... selection logic

<DeviceActivityReportView
  familyActivitySelection={selection}
  style={{ flex: 1 }}
/>
```

**After:**
```typescript
// Store the selection once
useEffect(() => {
  if (selection) {
    setFamilyActivitySelectionId({
      id: 'my-selection',
      familyActivitySelection: selection
    });
  }
}, [selection]);

// Use the stored selection
<DeviceActivityReportView
  familyActivitySelectionId="my-selection"
  style={{ flex: 1 }}
/>
```

## Best Practices

1. **Use meaningful IDs**: Choose descriptive IDs like `'social-media-apps'` instead of `'selection1'`
2. **Handle missing selections**: Always check if a selection exists before using it
3. **Consistent naming**: Use the same ID across your app for the same logical selection
4. **Error boundaries**: Wrap components in error boundaries to handle unexpected failures
5. **Validation**: Validate selection IDs at runtime, especially if they come from user input

## TypeScript Support

The new prop is fully typed:

```typescript
interface DeviceActivityReportViewProps {
  familyActivitySelection?: string | null;
  familyActivitySelectionId?: string;  // New prop
  // ... other props
}

// Hook return type
const useDeviceActivityReportWithId: (selectionId: string) => string | null;
```

## Pickups Report Example

The Pickups report shows the number of times each app was picked up (opened) throughout the day. This is useful for understanding app usage patterns and digital wellness insights.

**Note**: The Pickups report requires iOS 16.0+ and uses the `numberOfPickups` property from `DeviceActivityData.ApplicationActivity`.

```tsx
import React, { useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { DeviceActivityReportView } from 'react-native-device-activity';

export default function PickupsReportExample() {
  const [familyActivitySelection, setFamilyActivitySelection] = useState<string | null>(null);

  // Set date range for today
  const today = new Date();
  const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());
  const endOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 23, 59, 59);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>App Pickups Today</Text>
      
      <DeviceActivityReportView
        style={styles.reportView}
        context="Pickups"  // Use the new Pickups context
        familyActivitySelection={familyActivitySelection}
        from={startOfDay.getTime()}
        to={endOfDay.getTime()}
        segmentation="daily"
        users="all"
        devices={null} // All devices
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 16,
    textAlign: 'center',
  },
  reportView: {
    flex: 1,
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
});

### Weekly Pickups Report

You can also view pickup data for a weekly period:

```tsx
import React, { useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { DeviceActivityReportView } from 'react-native-device-activity';

export default function WeeklyPickupsReport() {
  const [familyActivitySelection, setFamilyActivitySelection] = useState<string | null>(null);

  // Set date range for this week
  const today = new Date();
  const startOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay());
  const endOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() + 6, 23, 59, 59);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>App Pickups This Week</Text>
      
      <DeviceActivityReportView
        style={styles.reportView}
        context="Pickups"
        familyActivitySelection={familyActivitySelection}
        from={startOfWeek.getTime()}
        to={endOfWeek.getTime()}
        segmentation="daily"  // Daily breakdown within the week
        users="all"
        devices={null}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 16,
    textAlign: 'center',
  },
  reportView: {
    flex: 1,
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
});
```

### Filtered Pickups Report

You can also filter the pickup data to specific apps by providing a `familyActivitySelection`:

```tsx
import React, { useState } from 'react';
import { View, Text, StyleSheet, Button } from 'react-native';
import { 
  DeviceActivityReportView, 
  DeviceActivitySelectionView,
  useDeviceActivityReportWithId 
} from 'react-native-device-activity';

export default function FilteredPickupsReport() {
  const [showSelection, setShowSelection] = useState(false);
  const familyActivitySelection = useDeviceActivityReportWithId('social-apps');

  const today = new Date();
  const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());
  const endOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 23, 59, 59);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Social Media Pickups Today</Text>
      
      <Button
        title={familyActivitySelection ? "Change Apps" : "Select Apps"}
        onPress={() => setShowSelection(!showSelection)}
      />

      {showSelection && (
        <DeviceActivitySelectionView
          style={styles.selectionView}
          familyActivitySelectionId="social-apps"
          headerText="Select social media apps to track"
          footerText="Choose the apps you want to monitor for pickup data"
          onSelectionChange={(event) => {
            console.log('Selection changed:', event.nativeEvent);
            setShowSelection(false);
          }}
        />
      )}

      {familyActivitySelection && (
        <DeviceActivityReportView
          style={styles.reportView}
          context="Pickups"
          familyActivitySelectionId="social-apps"
          from={startOfDay.getTime()}
          to={endOfDay.getTime()}
          segmentation="daily"
          users="all"
          devices={null}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 16,
    textAlign: 'center',
  },
  selectionView: {
    height: 300,
    marginVertical: 16,
    backgroundColor: 'white',
    borderRadius: 12,
  },
  reportView: {
    flex: 1,
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
});
```

### Understanding Pickup Data

The Pickups report provides valuable insights into digital wellness:

- **Total Pickups**: The total number of times apps were opened throughout the day
- **App Rankings**: Apps are sorted by pickup count (highest first)
- **Usage Duration**: Shows both pickup count and total time spent in each app
- **Behavioral Patterns**: Helps identify which apps are opened most frequently vs. used for longest duration

**Key Insights:**
- High pickup count with low duration might indicate habitual checking behavior
- Low pickup count with high duration suggests focused usage sessions
- Comparing pickup patterns across different time periods can reveal usage trends

**Privacy Note**: All pickup data is processed locally on the device and follows Apple's privacy guidelines for Screen Time data.

## Total Pickups Report Example

The Total Pickups report shows a simple, focused view of the total number of app pickups across all selected apps, similar to the Total Activity report but for pickup counts instead of duration.

**Note**: The Total Pickups report requires iOS 16.0+ and uses the `numberOfPickups` property from `DeviceActivityData.ApplicationActivity`.

```tsx
import React, { useState } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { DeviceActivityReportView } from 'react-native-device-activity';

export default function TotalPickupsReportExample() {
  const [familyActivitySelection, setFamilyActivitySelection] = useState<string | null>(null);

  // Set date range for today
  const today = new Date();
  const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());
  const endOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 23, 59, 59);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Total App Pickups Today</Text>
      
      <DeviceActivityReportView
        style={styles.reportView}
        context="Total Pickups"  // Use the Total Pickups context
        familyActivitySelection={familyActivitySelection}
        from={startOfDay.getTime()}
        to={endOfDay.getTime()}
        segmentation="daily"
        users="all"
        devices={null} // All devices
      />
      
      <Text style={styles.description}>
        This shows the total number of times you opened apps today.
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 16,
    textAlign: 'center',
  },
  reportView: {
    flex: 1,
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
    marginBottom: 16,
  },
  description: {
    fontSize: 14,
    color: '#6c757d',
    textAlign: 'center',
    fontStyle: 'italic',
  },
});
```

### Comparing Total Pickups vs Detailed Pickups

You can use both contexts to provide different levels of detail:

```tsx
import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { DeviceActivityReportView } from 'react-native-device-activity';

export default function PickupsComparisonExample() {
  const [viewMode, setViewMode] = useState<'total' | 'detailed'>('total');
  const [familyActivitySelection, setFamilyActivitySelection] = useState<string | null>(null);

  const today = new Date();
  const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());
  const endOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 23, 59, 59);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>App Pickups Analysis</Text>
      
      {/* View Mode Toggle */}
      <View style={styles.toggleContainer}>
        <TouchableOpacity
          style={[styles.toggleButton, viewMode === 'total' && styles.toggleButtonActive]}
          onPress={() => setViewMode('total')}
        >
          <Text style={[styles.toggleText, viewMode === 'total' && styles.toggleTextActive]}>
            Total Count
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.toggleButton, viewMode === 'detailed' && styles.toggleButtonActive]}
          onPress={() => setViewMode('detailed')}
        >
          <Text style={[styles.toggleText, viewMode === 'detailed' && styles.toggleTextActive]}>
            Detailed List
          </Text>
        </TouchableOpacity>
      </View>
      
      <DeviceActivityReportView
        style={styles.reportView}
        context={viewMode === 'total' ? 'Total Pickups' : 'Pickups'}
        familyActivitySelection={familyActivitySelection}
        from={startOfDay.getTime()}
        to={endOfDay.getTime()}
        segmentation="daily"
        users="all"
        devices={null}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 16,
    textAlign: 'center',
  },
  toggleContainer: {
    flexDirection: 'row',
    backgroundColor: '#e9ecef',
    borderRadius: 12,
    padding: 4,
    marginBottom: 16,
  },
  toggleButton: {
    flex: 1,
    paddingVertical: 12,
    alignItems: 'center',
    borderRadius: 8,
  },
  toggleButtonActive: {
    backgroundColor: '#007AFF',
  },
  toggleText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#6c757d',
  },
  toggleTextActive: {
    color: 'white',
  },
  reportView: {
    flex: 1,
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
});
```

### Available Report Contexts

The library now supports multiple report contexts for different types of insights:

| Context | Description | Data Shown | iOS Version | Registration Status |
|---------|-------------|------------|-------------|-------------------|
| `"Total Activity"` | Total usage duration | Time spent across all apps | iOS 15.0+ | ✅ Registered |
| `"App List"` | Detailed app usage with visual list | App names with colorful icons, usage times in "Xh:XXm" format, "BLOCKED APPS"/"AVG TIME" headers | iOS 15.0+ | ✅ Registered |
| `"Pickups"` | Detailed pickup analysis | List of apps with pickup counts | iOS 16.0+ | ✅ Registered |
| `"Total Pickups"` | Simple pickup summary | Total pickup count across apps | iOS 16.0+ | ✅ Registered |

**✅ All contexts are properly registered and should work automatically with the `DeviceActivityReportView` component.**

### Module Registration Status

The pickup-related views are properly integrated into the Expo module system:

1. **DeviceActivityReportView** - ✅ Registered as native view manager
2. **Context Handling** - ✅ Dynamic context creation via `DeviceActivityReport.Context(rawValue: model.context)`
3. **iOS Extension** - ✅ Both `PickupsReport` and `TotalPickupsReport` registered in `DeviceActivityReportUI`
4. **React Native Export** - ✅ `DeviceActivityReportView` exported from main index

Choose the context that best fits your UI and user experience needs.

## Report Styling (iOS 16.0+)

### Customizing Total Pickups Appearance

The "Total Pickups" context supports custom styling through the `reportStyle` prop. This allows you to customize the appearance of the pickup count number to match your app's design.

#### Basic Styling Example

```tsx
import { DeviceActivityReportView } from 'react-native-device-activity';

function StyledTotalPickups() {
  const today = new Date();
  const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());
  const endOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 23, 59, 59);

  return (
    <View style={{ backgroundColor: '#f0f8ff', borderRadius: 12, padding: 20 }}>
      <Text style={{ textAlign: 'center', marginBottom: 10 }}>Today's Pickups</Text>
      <DeviceActivityReportView
        style={{ height: 80 }}
        context="Total Pickups"
        familyActivitySelection={null}
        from={startOfDay.getTime()}
        to={endOfDay.getTime()}
        segmentation="daily"
        users="all"
        devices={null}
        reportStyle={{
          textColor: { red: 255, green: 59, blue: 48, alpha: 1 },
          fontSize: 64,
          fontWeight: 'heavy',
          fontDesign: 'rounded',
          textAlignment: 'center',
          // backgroundColor is transparent by default
        }}
      />
    </View>
  );
}
```

#### Available Style Properties

```typescript
interface DeviceActivityReportStyle {
  // Text color (RGB 0-255, alpha 0-1)
  textColor?: {
    red: number;
    green: number;
    blue: number;
    alpha?: number;
  };
  
  // Font size (default: 48)
  fontSize?: number;
  
  // Font weight options
  fontWeight?: 'ultraLight' | 'thin' | 'light' | 'regular' | 'medium' | 
               'semibold' | 'bold' | 'heavy' | 'black';
  
  // Font design options
  fontDesign?: 'default' | 'rounded' | 'monospaced' | 'serif';
  
  // Text alignment
  textAlignment?: 'leading' | 'center' | 'trailing';
  
  // Background color (null for transparent)
  backgroundColor?: {
    red: number;
    green: number;
    blue: number;
    alpha?: number;
  } | null;
}
```

#### Style Examples

**Large Red Text:**
```tsx
<DeviceActivityReportView
  context="Total Pickups"
  reportStyle={{
    textColor: { red: 255, green: 59, blue: 48 },
    fontSize: 72,
    fontWeight: 'heavy',
    textAlignment: 'center'
  }}
/>
```

**Blue Monospaced Font:**
```tsx
<DeviceActivityReportView
  context="Total Pickups"
  reportStyle={{
    textColor: { red: 0, green: 122, blue: 255, alpha: 0.8 },
    fontSize: 56,
    fontWeight: 'semibold',
    fontDesign: 'monospaced',
    textAlignment: 'center'
  }}
/>
```

**Custom Background Color:**
```tsx
<DeviceActivityReportView
  context="Total Pickups"
  reportStyle={{
    textColor: { red: 255, green: 255, blue: 255 },
    fontSize: 48,
    fontWeight: 'bold',
    backgroundColor: { red: 52, green: 199, blue: 89, alpha: 1 }
  }}
/>
```

**Transparent Background (Default):**
```tsx
// The background is transparent by default, allowing the container's background to show through
<View style={{ backgroundColor: '#f0f8ff', borderRadius: 12 }}>
  <DeviceActivityReportView
    context="Total Pickups"
    reportStyle={{
      textColor: { red: 0, green: 0, blue: 0 },
      fontSize: 48,
      fontWeight: 'bold'
      // No backgroundColor specified = transparent
    }}
  />
</View>
```

#### Responsive Design

You can create responsive designs by adjusting styles based on device characteristics:

```tsx
import { Dimensions } from 'react-native';

function ResponsiveTotalPickups() {
  const { width } = Dimensions.get('window');
  const isTablet = width > 768;
  
  return (
    <DeviceActivityReportView
      context="Total Pickups"
      reportStyle={{
        fontSize: isTablet ? 80 : 56,
        fontWeight: isTablet ? 'black' : 'bold',
        textColor: { red: 52, green: 199, blue: 89 }
      }}
    />
  );
}
```

#### Notes

- Styling only applies to the "Total Pickups" context
- The background is transparent by default, allowing React Native container backgrounds to show through
- Colors use RGB values from 0-255, with optional alpha from 0-1
- Font sizes are in points (similar to CSS px)
- Changes to `reportStyle` are passed to the DeviceActivityReport extension via UserDefaults 