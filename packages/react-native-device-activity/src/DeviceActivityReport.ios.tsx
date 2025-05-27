import { requireNativeViewManager } from "expo-modules-core";
import React from "react";
import { DeviceActivityReportViewProps } from "./ReactNativeDeviceActivity.types";

const NativeView: React.ComponentType<DeviceActivityReportViewProps> =
  requireNativeViewManager("DeviceActivityReportViewModule");

export default function DeviceActivityReportView({
  familyActivitySelection,
  familyActivitySelectionId,
  ...otherProps
}: DeviceActivityReportViewProps) {
  // Edge case: Both props provided - warn and prioritize familyActivitySelection
  if (familyActivitySelection && familyActivitySelectionId) {
    console.warn(
      'DeviceActivityReportView: Both familyActivitySelection and familyActivitySelectionId provided. ' +
      'Using familyActivitySelection and ignoring familyActivitySelectionId. ' +
      'Please provide only one of these props.'
    );
  }

  // Edge case: Neither prop provided - warn but continue with null selection
  if (!familyActivitySelection && !familyActivitySelectionId) {
    console.warn(
      'DeviceActivityReportView: Neither familyActivitySelection nor familyActivitySelectionId provided. ' +
      'The report will show data for all activities.'
    );
  }

  // Edge case: Empty string familyActivitySelectionId - treat as undefined
  const normalizedSelectionId = familyActivitySelectionId?.trim() || undefined;

  return (
    <NativeView
      familyActivitySelection={familyActivitySelection}
      familyActivitySelectionId={normalizedSelectionId}
      {...otherProps}
    />
  );
}
