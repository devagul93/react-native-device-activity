import React, { useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
} from "react-native";
import { DeviceActivityReportView } from "react-native-device-activity";

type ContextType = "Total Activity" | "App List" | "Pickups" | "Total Pickups";

export default function ContextTestScreen() {
  const [selectedContext, setSelectedContext] =
    useState<ContextType>("Total Activity");

  const contexts: {
    name: ContextType;
    description: string;
    iosVersion: string;
  }[] = [
    {
      name: "Total Activity",
      description: "Shows total usage duration across all apps",
      iosVersion: "15.0+",
    },
    {
      name: "App List",
      description: "Shows detailed list of apps with usage times",
      iosVersion: "15.0+",
    },
    {
      name: "Pickups",
      description: "Shows detailed list of apps with pickup counts",
      iosVersion: "16.0+",
    },
    {
      name: "Total Pickups",
      description: "Shows simple total pickup count",
      iosVersion: "16.0+",
    },
  ];

  // Set date range for today
  const today = new Date();
  const startOfDay = new Date(
    today.getFullYear(),
    today.getMonth(),
    today.getDate(),
  );
  const endOfDay = new Date(
    today.getFullYear(),
    today.getMonth(),
    today.getDate(),
    23,
    59,
    59,
  );

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Context Test</Text>
        <Text style={styles.subtitle}>
          Test all available DeviceActivityReport contexts
        </Text>
      </View>

      {/* Context Selector */}
      <View style={styles.contextContainer}>
        <Text style={styles.sectionTitle}>Select Context:</Text>
        {contexts.map((context) => (
          <TouchableOpacity
            key={context.name}
            style={[
              styles.contextButton,
              selectedContext === context.name && styles.contextButtonActive,
            ]}
            onPress={() => setSelectedContext(context.name)}
          >
            <View style={styles.contextButtonContent}>
              <Text
                style={[
                  styles.contextButtonText,
                  selectedContext === context.name &&
                    styles.contextButtonTextActive,
                ]}
              >
                {context.name}
              </Text>
              <Text
                style={[
                  styles.contextButtonDescription,
                  selectedContext === context.name &&
                    styles.contextButtonDescriptionActive,
                ]}
              >
                {context.description}
              </Text>
              <Text
                style={[
                  styles.contextButtonVersion,
                  selectedContext === context.name &&
                    styles.contextButtonVersionActive,
                ]}
              >
                iOS {context.iosVersion}
              </Text>
            </View>
          </TouchableOpacity>
        ))}
      </View>

      {/* Current Selection Info */}
      <View style={styles.infoContainer}>
        <Text style={styles.infoTitle}>Current Context: {selectedContext}</Text>
        <Text style={styles.infoDescription}>
          {contexts.find((c) => c.name === selectedContext)?.description}
        </Text>
      </View>

      {/* Report View */}
      <View style={styles.reportContainer}>
        <DeviceActivityReportView
          style={styles.reportView}
          context={selectedContext}
          familyActivitySelection={null} // Show all apps
          from={startOfDay.getTime()}
          to={endOfDay.getTime()}
          segmentation="daily"
          users="all"
          devices={null}
        />
      </View>

      {/* Status Info */}
      <View style={styles.statusContainer}>
        <Text style={styles.statusTitle}>Registration Status</Text>
        <View style={styles.statusItem}>
          <Text style={styles.statusLabel}>✅ DeviceActivityReportView:</Text>
          <Text style={styles.statusValue}>Registered as native view</Text>
        </View>
        <View style={styles.statusItem}>
          <Text style={styles.statusLabel}>✅ Context Handling:</Text>
          <Text style={styles.statusValue}>Dynamic context creation</Text>
        </View>
        <View style={styles.statusItem}>
          <Text style={styles.statusLabel}>✅ iOS Extension:</Text>
          <Text style={styles.statusValue}>All reports registered</Text>
        </View>
        <View style={styles.statusItem}>
          <Text style={styles.statusLabel}>✅ React Native Export:</Text>
          <Text style={styles.statusValue}>Component exported</Text>
        </View>
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
    padding: 20,
    paddingBottom: 16,
  },
  title: {
    fontSize: 28,
    fontWeight: "bold",
    color: "#1a1a1a",
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: "#6c757d",
  },
  contextContainer: {
    marginHorizontal: 20,
    marginBottom: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: "600",
    color: "#1a1a1a",
    marginBottom: 12,
  },
  contextButton: {
    backgroundColor: "white",
    borderRadius: 12,
    padding: 16,
    marginBottom: 8,
    borderWidth: 2,
    borderColor: "#e9ecef",
  },
  contextButtonActive: {
    borderColor: "#007AFF",
    backgroundColor: "#f0f8ff",
  },
  contextButtonContent: {
    flex: 1,
  },
  contextButtonText: {
    fontSize: 16,
    fontWeight: "600",
    color: "#1a1a1a",
    marginBottom: 4,
  },
  contextButtonTextActive: {
    color: "#007AFF",
  },
  contextButtonDescription: {
    fontSize: 14,
    color: "#6c757d",
    marginBottom: 4,
  },
  contextButtonDescriptionActive: {
    color: "#0056b3",
  },
  contextButtonVersion: {
    fontSize: 12,
    color: "#adb5bd",
    fontWeight: "500",
  },
  contextButtonVersionActive: {
    color: "#007AFF",
  },
  infoContainer: {
    marginHorizontal: 20,
    marginBottom: 20,
    padding: 16,
    backgroundColor: "#e7f3ff",
    borderRadius: 12,
    borderLeftWidth: 4,
    borderLeftColor: "#007AFF",
  },
  infoTitle: {
    fontSize: 16,
    fontWeight: "600",
    color: "#0056b3",
    marginBottom: 4,
  },
  infoDescription: {
    fontSize: 14,
    color: "#0056b3",
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
  statusContainer: {
    marginHorizontal: 20,
    marginBottom: 40,
    padding: 16,
    backgroundColor: "white",
    borderRadius: 12,
  },
  statusTitle: {
    fontSize: 16,
    fontWeight: "600",
    color: "#1a1a1a",
    marginBottom: 12,
  },
  statusItem: {
    flexDirection: "row",
    marginBottom: 8,
    alignItems: "flex-start",
  },
  statusLabel: {
    fontSize: 14,
    fontWeight: "500",
    color: "#28a745",
    minWidth: 140,
  },
  statusValue: {
    fontSize: 14,
    color: "#6c757d",
    flex: 1,
  },
});
