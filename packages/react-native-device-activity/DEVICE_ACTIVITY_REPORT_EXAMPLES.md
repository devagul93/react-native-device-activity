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
| `"App List"` | Detailed app usage | List of apps with usage times | iOS 15.0+ | ✅ Registered |
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