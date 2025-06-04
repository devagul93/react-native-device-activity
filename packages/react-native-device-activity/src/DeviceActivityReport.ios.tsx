import { requireNativeViewManager } from "expo-modules-core";
import React from "react";

import { DeviceActivityReportViewProps } from "./ReactNativeDeviceActivity.types";

const NativeView: React.ComponentType<DeviceActivityReportViewProps> =
  requireNativeViewManager("DeviceActivityReportViewModule");

export default function DeviceActivityReportView({
  familyActivitySelection,
  familyActivitySelectionId,
  context,
  from,
  to,
  ...otherProps
}: DeviceActivityReportViewProps) {
  // Use ref to track render count without causing re-renders
  const renderCountRef = React.useRef(0);
  
  // Increment render count on every render (but don't trigger re-renders)
  renderCountRef.current += 1;
  const renderCount = renderCountRef.current;
  
  // Enhanced debugging for blank view issues - Now safe to include renderCount
  React.useEffect(() => {
    const debugInfo = {
      renderCount,
      timestamp: new Date().toISOString(),
      context,
      hasFamilyActivitySelection: !!familyActivitySelection,
      familyActivitySelectionLength: familyActivitySelection?.length || 0,
      familyActivitySelectionId,
      familyActivitySelectionIdLength: familyActivitySelectionId?.length || 0,
      from: from ? new Date(from).toISOString() : "undefined",
      to: to ? new Date(to).toISOString() : "undefined",
      timePeriodHours: from && to ? (to - from) / (1000 * 60 * 60) : "undefined",
      timePeriodDays: from && to ? (to - from) / (1000 * 60 * 60 * 24) : "undefined",
      isValidTimeRange: from && to ? from < to : "undefined",
      otherPropsKeys: Object.keys(otherProps),
    };
    
    console.log("📊 DeviceActivityReportView Render Debug:", debugInfo);
    
    // Log potential issues
    if (!familyActivitySelection && !familyActivitySelectionId) {
      console.warn("⚠️ DeviceActivityReportView: No activity selection provided - this may cause blank views");
    }
    
    if (familyActivitySelectionId === "") {
      console.warn("⚠️ DeviceActivityReportView: Empty string familyActivitySelectionId - this may cause blank views");
    }
    
    if (from && to) {
      const hoursDiff = (to - from) / (1000 * 60 * 60);
      if (hoursDiff < 1) {
        console.warn("⚠️ DeviceActivityReportView: Very short time period (< 1 hour) - may not have enough data");
      } else if (hoursDiff > 24 * 7) {
        console.log("ℹ️ DeviceActivityReportView: Long time period (> 1 week) - processing may take time");
      }
    }
    
  }, [familyActivitySelection, familyActivitySelectionId, context, from, to, otherProps]); // Safe: renderCount not in dependencies

  // Log component lifecycle
  React.useEffect(() => {
    console.log("🔄 DeviceActivityReportView: Component mounted/updated", {
      context,
      timestamp: new Date().toISOString()
    });
    
    return () => {
      console.log("🔄 DeviceActivityReportView: Component will unmount", {
        context,
        timestamp: new Date().toISOString()
      });
    };
  }, [context]);

  // Edge case: Both props provided - warn and prioritize familyActivitySelection
  if (familyActivitySelection && familyActivitySelectionId) {
    console.warn(
      "DeviceActivityReportView: Both familyActivitySelection and familyActivitySelectionId provided. " +
        "Using familyActivitySelection and ignoring familyActivitySelectionId. " +
        "Please provide only one of these props.",
    );
  }

  // Edge case: Neither prop provided - warn but continue with null selection
  if (!familyActivitySelection && !familyActivitySelectionId) {
    console.warn(
      "DeviceActivityReportView: Neither familyActivitySelection nor familyActivitySelectionId provided. " +
        "The report will show data for all activities. This may result in a blank view if no apps are monitored.",
    );
  }

  // Validate time range
  if (from && to && from >= to) {
    console.error(
      "DeviceActivityReportView: Invalid time range - 'from' must be before 'to'. " +
        `Got from: ${new Date(from)}, to: ${new Date(to)}`,
    );
  }

  // Validate context
  if (context && !["App List", "Total Activity", "Pickups"].includes(context)) {
    console.warn(
      `DeviceActivityReportView: Unknown context '${context}'. ` +
        "Supported contexts: 'App List', 'Total Activity', 'Pickups'",
    );
  }

  // Edge case: Empty string familyActivitySelectionId - treat as undefined
  const normalizedSelectionId = familyActivitySelectionId?.trim() || undefined;
  
  // Final props to pass to native view
  const finalProps = {
    familyActivitySelection,
    familyActivitySelectionId: normalizedSelectionId,
    context,
    from,
    to,
    ...otherProps
  };
  
  console.log("🎯 DeviceActivityReportView: Passing props to native view:", {
    hasFamilyActivitySelection: !!finalProps.familyActivitySelection,
    familyActivitySelectionId: finalProps.familyActivitySelectionId,
    context: finalProps.context,
    fromDate: finalProps.from ? new Date(finalProps.from).toISOString() : undefined,
    toDate: finalProps.to ? new Date(finalProps.to).toISOString() : undefined,
    renderCount,
    timestamp: new Date().toISOString()
  });

  return (
    <NativeView
      {...finalProps}
    />
  );
}
