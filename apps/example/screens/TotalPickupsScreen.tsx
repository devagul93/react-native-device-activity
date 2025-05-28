import React, { useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
} from "react-native";
import { DeviceActivityReportView } from "react-native-device-activity";

export default function TotalPickupsScreen() {
  const [timeRange, setTimeRange] = useState<"today" | "week" | "month">(
    "today",
  );

  const getDateRange = () => {
    const now = new Date();
    let startDate: Date;
    let endDate: Date;

    switch (timeRange) {
      case "today":
        startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        endDate = new Date(
          now.getFullYear(),
          now.getMonth(),
          now.getDate(),
          23,
          59,
          59,
        );
        break;
      case "week":
        const startOfWeek = new Date(
          now.getFullYear(),
          now.getMonth(),
          now.getDate() - now.getDay(),
        );
        const endOfWeek = new Date(
          now.getFullYear(),
          now.getMonth(),
          now.getDate() - now.getDay() + 6,
          23,
          59,
          59,
        );
        startDate = startOfWeek;
        endDate = endOfWeek;
        break;
      case "month":
        startDate = new Date(now.getFullYear(), now.getMonth(), 1);
        endDate = new Date(
          now.getFullYear(),
          now.getMonth() + 1,
          0,
          23,
          59,
          59,
        );
        break;
      default:
        startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        endDate = new Date(
          now.getFullYear(),
          now.getMonth(),
          now.getDate(),
          23,
          59,
          59,
        );
    }

    return { startDate, endDate };
  };

  const { startDate, endDate } = getDateRange();

  const handleInfoPress = () => {
    Alert.alert(
      "About Total Pickups",
      "This shows the total number of times you opened apps during the selected time period.\n\nA pickup is counted each time you tap an app icon and it opens. This metric helps you understand your overall app usage frequency.\n\nRequires iOS 16.0+ and Screen Time permission.",
      [{ text: "Got it" }],
    );
  };

  const getTimeRangeLabel = () => {
    switch (timeRange) {
      case "today":
        return "Today";
      case "week":
        return "This Week";
      case "month":
        return "This Month";
      default:
        return "Today";
    }
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Total Pickups</Text>
        <TouchableOpacity onPress={handleInfoPress} style={styles.infoButton}>
          <Text style={styles.infoButtonText}>ℹ️</Text>
        </TouchableOpacity>
      </View>

      <Text style={styles.subtitle}>Total number of times you opened apps</Text>

      {/* Time Range Selector */}
      <View style={styles.timeRangeContainer}>
        {(["today", "week", "month"] as const).map((range) => (
          <TouchableOpacity
            key={range}
            style={[
              styles.timeRangeButton,
              timeRange === range && styles.timeRangeButtonActive,
            ]}
            onPress={() => setTimeRange(range)}
          >
            <Text
              style={[
                styles.timeRangeButtonText,
                timeRange === range && styles.timeRangeButtonTextActive,
              ]}
            >
              {range.charAt(0).toUpperCase() + range.slice(1)}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Date Range Display */}
      <Text style={styles.dateRange}>
        {startDate.toLocaleDateString()} - {endDate.toLocaleDateString()}
      </Text>

      {/* Report View */}
      <View style={styles.reportContainer}>
        <DeviceActivityReportView
          style={styles.reportView}
          context="Total Pickups" // Use the Total Pickups context
          familyActivitySelection={null} // Show all apps
          from={startDate.getTime()}
          to={endDate.getTime()}
          segmentation={timeRange === "today" ? "hourly" : "daily"}
          users="all"
          devices={null}
        />
      </View>

      <View style={styles.explanationContainer}>
        <Text style={styles.explanationTitle}>What are pickups?</Text>
        <Text style={styles.explanationText}>
          A pickup is counted each time you open an app by tapping its icon.
          This includes opening from:
        </Text>
        <View style={styles.bulletPoints}>
          <Text style={styles.bulletPoint}>• Home screen</Text>
          <Text style={styles.bulletPoint}>• Spotlight search</Text>
          <Text style={styles.bulletPoint}>• Control Center</Text>
          <Text style={styles.bulletPoint}>• App switcher</Text>
          <Text style={styles.bulletPoint}>• Siri suggestions</Text>
        </View>
        <Text style={styles.explanationFooter}>
          This metric helps you understand how frequently you check your apps
          throughout the {getTimeRangeLabel().toLowerCase()}.
        </Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#f8f9fa",
  },
  header: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: 20,
    paddingTop: 20,
    paddingBottom: 8,
  },
  title: {
    fontSize: 28,
    fontWeight: "bold",
    color: "#1a1a1a",
  },
  infoButton: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: "#e9ecef",
    alignItems: "center",
    justifyContent: "center",
  },
  infoButtonText: {
    fontSize: 16,
  },
  subtitle: {
    fontSize: 16,
    color: "#6c757d",
    paddingHorizontal: 20,
    marginBottom: 24,
  },
  timeRangeContainer: {
    flexDirection: "row",
    marginHorizontal: 20,
    marginBottom: 16,
    backgroundColor: "#e9ecef",
    borderRadius: 12,
    padding: 4,
  },
  timeRangeButton: {
    flex: 1,
    paddingVertical: 12,
    alignItems: "center",
    borderRadius: 8,
  },
  timeRangeButtonActive: {
    backgroundColor: "#007AFF",
  },
  timeRangeButtonText: {
    fontSize: 16,
    fontWeight: "600",
    color: "#6c757d",
  },
  timeRangeButtonTextActive: {
    color: "white",
  },
  dateRange: {
    fontSize: 14,
    color: "#6c757d",
    textAlign: "center",
    marginBottom: 20,
  },
  reportContainer: {
    marginHorizontal: 20,
    marginBottom: 20,
    backgroundColor: "white",
    borderRadius: 16,
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
  reportView: {
    height: 300,
    borderRadius: 16,
  },
  explanationContainer: {
    marginHorizontal: 20,
    marginBottom: 40,
    padding: 20,
    backgroundColor: "white",
    borderRadius: 16,
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  explanationTitle: {
    fontSize: 18,
    fontWeight: "600",
    color: "#1a1a1a",
    marginBottom: 12,
  },
  explanationText: {
    fontSize: 14,
    color: "#6c757d",
    lineHeight: 20,
    marginBottom: 12,
  },
  bulletPoints: {
    marginLeft: 8,
    marginBottom: 12,
  },
  bulletPoint: {
    fontSize: 14,
    color: "#6c757d",
    lineHeight: 20,
  },
  explanationFooter: {
    fontSize: 14,
    color: "#6c757d",
    lineHeight: 20,
    fontStyle: "italic",
  },
});
