const getAppGroupFromExpoConfig = require("react-native-device-activity/config-plugin/getAppGroupFromExpoConfig");

/** @type {import('@kingstinct/expo-apple-targets/build/config-plugin').ConfigFunction} */
module.exports = (config) => {
  const appGroup = getAppGroupFromExpoConfig(config);

  return {
    // Since device-activity-report isn't supported, we'll use app-intent as a base
    // and rely on the existing Info.plist for the correct extension point
    type: "app-intent",
    entitlements: {
      "com.apple.developer.family-controls": true,
      "com.apple.security.application-groups": [appGroup],
    },
    deploymentTarget: "15.0",
    frameworks: ["DeviceActivity", "SwiftUI"],
  };
}; 