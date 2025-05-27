import React from "react";
import { Text, View } from "react-native";
import { DeviceActivityReportViewProps } from "./ReactNativeDeviceActivity.types";

export default function DeviceActivityReportView({
  familyActivitySelection,
  familyActivitySelectionId,
  style,
  children,
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

  return (
    <View style={style}>
      <Text>DeviceActivityReport is only available on iOS 16.0+</Text>
      {children}
    </View>
  );
}
