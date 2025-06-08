import React, { useState } from "react";
import { ScrollView, StyleSheet, View } from "react-native";
import { Button, Card, Text } from "react-native-paper";

import { DeviceActivityReportView } from "../../../packages/react-native-device-activity/src";

export default function MostUsedAppsScreen() {
  const [timeRange, setTimeRange] = useState<"today" | "week" | "month">("week");

  const getDateRange = () => {
    const now = new Date();
    let startDate: Date;
    let endDate = new Date(); // Current time

    switch (timeRange) {
      case "today":
        startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        break;
      case "week":
        const dayOfWeek = now.getDay();
        const daysToSubtract = dayOfWeek === 0 ? 6 : dayOfWeek - 1; // Monday = 0
        startDate = new Date(now);
        startDate.setDate(now.getDate() - daysToSubtract);
        startDate.setHours(0, 0, 0, 0);
        break;
      case "month":
        startDate = new Date(now.getFullYear(), now.getMonth(), 1);
        break;
      default:
        startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    }

    return { startDate, endDate };
  };

  const { startDate, endDate } = getDateRange();

  const formatDateRange = () => {
    const options: Intl.DateTimeFormatOptions = {
      month: "short",
      day: "numeric",
    };

    switch (timeRange) {
      case "today":
        return "Today";
      case "week":
        return `${startDate.toLocaleDateString("en-US", options)} - ${endDate.toLocaleDateString("en-US", options)}`;
      case "month":
        return startDate.toLocaleDateString("en-US", { month: "long", year: "numeric" });
      default:
        return "Today";
    }
  };

  return (
    <ScrollView style={styles.container}>
      <Card style={styles.card}>
        <Card.Content>
          <Text style={styles.title}>Most Used Apps</Text>
          <Text style={styles.description}>
            View your most frequently used applications with daily averages, peak usage hours, 
            and intelligent behavioral insights - all in a pixel-perfect Apple Screen Time interface.
          </Text>

          {/* Time Range Picker */}
          <View style={styles.timeRangeContainer}>
            <Text style={styles.sectionTitle}>Time Range: {formatDateRange()}</Text>
            <Text style={styles.timeRangeHelp}>
              {timeRange === "today" && "See your current day's app usage patterns"}
              {timeRange === "week" && "View weekly trends and identify consistent habits"}
              {timeRange === "month" && "Analyze long-term usage patterns and major trends"}
            </Text>
            <View style={styles.buttonRow}>
              <Button
                mode={timeRange === "today" ? "contained" : "outlined"}
                onPress={() => setTimeRange("today")}
                style={styles.timeButton}
                compact
              >
                Today
              </Button>
              <Button
                mode={timeRange === "week" ? "contained" : "outlined"}
                onPress={() => setTimeRange("week")}
                style={styles.timeButton}
                compact
              >
                This Week
              </Button>
              <Button
                mode={timeRange === "month" ? "contained" : "outlined"}
                onPress={() => setTimeRange("month")}
                style={styles.timeButton}
                compact
              >
                This Month
              </Button>
            </View>
          </View>

          {/* Most Used Apps Report */}
          <View style={styles.reportContainer}>
            <DeviceActivityReportView
              style={styles.reportView}
              context="Most Used Apps"
              familyActivitySelection={null} // Show all apps
              from={startDate.getTime()}
              to={endDate.getTime()}
              segmentation={timeRange === "today" ? "hourly" : "daily"}
              users="all"
              devices={null}
            />
          </View>

          <View style={styles.infoSection}>
            <Text style={styles.infoTitle}>✨ Key Improvements:</Text>
            <Text style={styles.infoText}>
              • Daily averages instead of cumulative totals{"\n"}
              • Dynamic peak usage hour detection{"\n"}
              • Per-day calculations across time ranges{"\n"}
              • Detailed app breakdown with individual usage{"\n"}
              • Enhanced behavioral insights with context{"\n"}
              • Gradient background and refined typography{"\n"}
              • "per day" labels for clarity{"\n"}
              • Better empty state design
            </Text>
          </View>
        </Card.Content>
      </Card>

      <Card style={styles.card}>
        <Card.Content>
          <Text style={styles.subtitle}>Implementation Notes</Text>
          <Text style={styles.description}>
            This enhanced report now shows daily averages instead of cumulative totals, 
            detects peak usage hours dynamically, and provides better insights. 
            The layout is pixel-perfect to match Apple's Screen Time interface 
            with authentic app branding and intelligent behavioral recommendations.
          </Text>
          
          <Text style={styles.codeExample}>
            {`<DeviceActivityReportView
  context="Most Used Apps"
  familyActivitySelection={null}
  from={startDate.getTime()}
  to={endDate.getTime()}
  segmentation="daily"
/>`}
          </Text>
        </Card.Content>
      </Card>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: "#f5f5f5",
  },
  card: {
    marginBottom: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: "bold",
    marginBottom: 8,
    textAlign: "center",
  },
  subtitle: {
    fontSize: 18,
    fontWeight: "bold",
    marginBottom: 8,
  },
  description: {
    marginBottom: 16,
    color: "#666",
    textAlign: "center",
  },
  timeRangeContainer: {
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: "600",
    marginBottom: 8,
    textAlign: "center",
  },
  buttonRow: {
    flexDirection: "row",
    gap: 8,
    justifyContent: "center",
  },
  timeButton: {
    flex: 1,
  },
  reportContainer: {
    marginBottom: 16,
  },
  reportView: {
    height: 400,
    backgroundColor: "#1a1a1a",
    borderRadius: 12,
    overflow: "hidden",
  },
  infoSection: {
    backgroundColor: "#f8f9fa",
    padding: 16,
    borderRadius: 8,
    marginBottom: 16,
  },
  infoTitle: {
    fontSize: 16,
    fontWeight: "600",
    marginBottom: 8,
    color: "#333",
  },
  infoText: {
    color: "#666",
    lineHeight: 20,
  },
  codeExample: {
    backgroundColor: "#f0f0f0",
    padding: 12,
    borderRadius: 8,
    fontFamily: "monospace",
    fontSize: 12,
    marginTop: 8,
  },
  timeRangeHelp: {
    fontSize: 12,
    color: "#666",
    marginBottom: 8,
    textAlign: "center",
    fontStyle: "italic",
  },
}); 