import React, { useEffect, useState } from "react";
import { requireNativeViewManager } from "expo-modules-core";
import { getCachedAppUsageData } from "./index";

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
  const [cachedData, setCachedData] = useState<any>(null);
  const [showingCachedData, setShowingCachedData] = useState(false);
  
  // Use ref to track render count without causing re-renders
  const renderCountRef = React.useRef(0);
  
  // Increment render count on every render (but don't trigger re-renders)
  renderCountRef.current += 1;
  const renderCount = renderCountRef.current;

  // Try to load cached data immediately
  useEffect(() => {
    const loadCachedData = async () => {
      try {
        const cached = await getCachedAppUsageData();
        if (cached && cached.data.length > 0) {
          setCachedData(cached);
          setShowingCachedData(true);
          
          console.log("⚡ DeviceActivityReport: Showing cached data immediately", {
            count: cached.data.length,
            age: (Date.now() / 1000) - cached.timestamp,
            isStale: cached.isStale
          });
          
          // If data is stale, it will be refreshed automatically by the extension
          if (cached.isStale) {
            console.log("🔄 DeviceActivityReport: Cached data is stale, fresh data will load soon");
          }
        }
      } catch (error) {
        console.warn("DeviceActivityReport: Failed to load cached data", error);
      }
    };

    loadCachedData();
  }, [familyActivitySelectionId, from, to]);

  // Listen for when fresh data becomes available
  useEffect(() => {
    // After 2 seconds, hide the "showing cached data" indicator
    // This doesn't affect functionality, just user feedback
    if (showingCachedData) {
      const timer = setTimeout(() => {
        setShowingCachedData(false);
      }, 2000);
      
      return () => clearTimeout(timer);
    }
    return; // Explicit return for TypeScript
  }, [showingCachedData]);

  // Enhanced debugging for blank view issues
  React.useEffect(() => {
    const debugInfo = {
      renderCount,
      timestamp: new Date().toISOString(),
      context,
      hasFamilyActivitySelection: !!familyActivitySelection,
      familyActivitySelectionLength: familyActivitySelection?.length || 0,
      familyActivitySelectionId,
      familyActivitySelectionIdLength: familyActivitySelectionId?.length || 0,
      from: new Date(from || Date.now()).toISOString(),
      to: new Date(to || Date.now()).toISOString(),
      timePeriodDays: from && to ? (to - from) / (1000 * 60 * 60 * 24) : 0,
      timePeriodHours: from && to ? (to - from) / (1000 * 60 * 60) : 0,
      isValidTimeRange: from && to ? to > from : false,
      otherPropsKeys: Object.keys(otherProps).filter(key => 
        !['familyActivitySelection', 'familyActivitySelectionId', 'context', 'from', 'to'].includes(key)
      ),
      hasCachedData: !!cachedData,
      showingCachedData
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
    
  }, [familyActivitySelection, familyActivitySelectionId, context, from, to, otherProps, renderCount, cachedData, showingCachedData]);

  // Log component lifecycle
  React.useEffect(() => {
    console.log("🔄 DeviceActivityReportView: Component mounted/updated", {
      context,
      timestamp: new Date().toISOString(),
      hasCachedData: !!cachedData,
      showingCachedData
    });
    
    return () => {
      console.log("🔄 DeviceActivityReportView: Component will unmount", {
        context,
        timestamp: new Date().toISOString()
      });
    };
  }, [context, cachedData, showingCachedData]);

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
    timestamp: new Date().toISOString(),
    hasCachedData: !!cachedData,
    showingCachedData
  });

  return (
    <NativeView
      {...finalProps}
      style={[
        otherProps.style,
        // Add a subtle indicator when showing cached data
        showingCachedData && {
          borderLeftWidth: 2,
          borderLeftColor: '#00AA00',
          backgroundColor: 'rgba(0, 170, 0, 0.05)'
        }
      ]}
    />
  );
}
