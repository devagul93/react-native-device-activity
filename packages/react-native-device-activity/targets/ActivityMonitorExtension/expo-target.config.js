const {
  createConfig,
} = require("react-native-device-activity/config-plugin/createExpoTargetConfig");

module.exports = (config) => {
  const baseConfig = createConfig("device-activity-monitor")(config);

  // Override the bundle identifier to use .ActivityMonitor
  return {
    ...baseConfig,
    bundleIdentifier: ".ActivityMonitor",
  };
};
