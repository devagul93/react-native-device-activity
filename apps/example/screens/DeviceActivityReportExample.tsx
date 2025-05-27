import React, { useState, useEffect } from "react";
import {
  View,
  ScrollView,
  StyleSheet,
  Alert,
  NativeSyntheticEvent,
} from "react-native";
import {
  DeviceActivityReportView,
  DeviceActivitySelectionViewPersisted,
  setFamilyActivitySelectionId,
  getFamilyActivitySelectionId,
  useDeviceActivityReportWithId,
  ActivitySelectionMetadata,
} from "react-native-device-activity";
import { Button, Text, Title, Card } from "react-native-paper";

const SELECTION_ID = "report-example-selection";
const INVALID_SELECTION_ID = "non-existent-selection";

export function DeviceActivityReportExample() {
  const [hasSelection, setHasSelection] = useState(false);
  const [showPicker, setShowPicker] = useState(false);
  const [testCase, setTestCase] = useState<
    "valid" | "invalid" | "both" | "neither"
  >("valid");

  // Using the convenience hook
  const hookSelection = useDeviceActivityReportWithId(SELECTION_ID);

  // Check if we have a stored selection
  useEffect(() => {
    const storedSelection = getFamilyActivitySelectionId(SELECTION_ID);
    setHasSelection(!!storedSelection);
  }, []);

  const handleSelectionChange = (selection: any) => {
    const { applicationCount, categoryCount, webDomainCount } =
      selection.nativeEvent;
    const hasAnySelection =
      applicationCount > 0 || categoryCount > 0 || webDomainCount > 0;
    setHasSelection(hasAnySelection);
    setShowPicker(false);
  };

  const clearSelection = () => {
    setFamilyActivitySelectionId({
      id: SELECTION_ID,
      familyActivitySelection: "", // Empty selection
    });
    setHasSelection(false);
  };

  const renderTestCase = () => {
    const commonProps = {
      context: "Total Activity",
      segmentation: "daily" as const,
      from: Date.now() - 7 * 24 * 60 * 60 * 1000, // Last 7 days
      to: Date.now(),
      style: styles.reportView,
    };

    switch (testCase) {
      case "valid":
        return (
          <DeviceActivityReportView
            familyActivitySelectionId={SELECTION_ID}
            {...commonProps}
          />
        );

      case "invalid":
        return (
          <DeviceActivityReportView
            familyActivitySelectionId={INVALID_SELECTION_ID}
            {...commonProps}
          />
        );

      case "both":
        return (
          <DeviceActivityReportView
            familyActivitySelection={hookSelection}
            familyActivitySelectionId={SELECTION_ID}
            {...commonProps}
          />
        );

      case "neither":
        return <DeviceActivityReportView {...commonProps} />;

      default:
        return null;
    }
  };

  return (
    <ScrollView style={styles.container}>
      <Title style={styles.title}>DeviceActivityReport with SelectionId</Title>

      <Card style={styles.card}>
        <Card.Content>
          <Text style={styles.subtitle}>Selection Status</Text>
          <Text>Has stored selection: {hasSelection ? "✅" : "❌"}</Text>
          <Text>Hook selection: {hookSelection ? "✅" : "❌"}</Text>

          <View style={styles.buttonRow}>
            <Button
              mode="outlined"
              onPress={() => setShowPicker(true)}
              style={styles.button}
            >
              {hasSelection ? "Change Selection" : "Create Selection"}
            </Button>

            {hasSelection && (
              <Button
                mode="outlined"
                onPress={clearSelection}
                style={styles.button}
              >
                Clear Selection
              </Button>
            )}
          </View>
        </Card.Content>
      </Card>

      <Card style={styles.card}>
        <Card.Content>
          <Text style={styles.subtitle}>Test Cases</Text>
          <Text style={styles.description}>
            Select different test cases to see edge case handling:
          </Text>

          <View style={styles.testCaseButtons}>
            <Button
              mode={testCase === "valid" ? "contained" : "outlined"}
              onPress={() => setTestCase("valid")}
              style={styles.testButton}
            >
              Valid ID
            </Button>

            <Button
              mode={testCase === "invalid" ? "contained" : "outlined"}
              onPress={() => setTestCase("invalid")}
              style={styles.testButton}
            >
              Invalid ID
            </Button>

            <Button
              mode={testCase === "both" ? "contained" : "outlined"}
              onPress={() => setTestCase("both")}
              style={styles.testButton}
            >
              Both Props
            </Button>

            <Button
              mode={testCase === "neither" ? "contained" : "outlined"}
              onPress={() => setTestCase("neither")}
              style={styles.testButton}
            >
              Neither Prop
            </Button>
          </View>

          <Text style={styles.testCaseDescription}>
            {testCase === "valid" &&
              "Uses familyActivitySelectionId with valid stored selection"}
            {testCase === "invalid" &&
              "Uses familyActivitySelectionId with non-existent ID (check console)"}
            {testCase === "both" &&
              "Provides both props - should warn and use familyActivitySelection"}
            {testCase === "neither" &&
              "Provides neither prop - should warn but show all activities"}
          </Text>
        </Card.Content>
      </Card>

      <Card style={styles.card}>
        <Card.Content>
          <Text style={styles.subtitle}>DeviceActivityReport</Text>
          {renderTestCase()}
        </Card.Content>
      </Card>

      {showPicker && (
        <Card style={styles.card}>
          <Card.Content>
            <Text style={styles.subtitle}>Select Apps/Categories</Text>
            <DeviceActivitySelectionViewPersisted
              familyActivitySelectionId={SELECTION_ID}
              onSelectionChange={handleSelectionChange}
              style={styles.pickerView}
              includeEntireCategory
            />
            <Button
              mode="outlined"
              onPress={() => setShowPicker(false)}
              style={styles.button}
            >
              Cancel
            </Button>
          </Card.Content>
        </Card>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
  },
  title: {
    marginBottom: 16,
    textAlign: "center",
  },
  card: {
    marginBottom: 16,
  },
  subtitle: {
    fontSize: 16,
    fontWeight: "bold",
    marginBottom: 8,
  },
  description: {
    marginBottom: 12,
    color: "#666",
  },
  buttonRow: {
    flexDirection: "row",
    marginTop: 12,
    gap: 8,
  },
  button: {
    flex: 1,
  },
  testCaseButtons: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8,
    marginBottom: 8,
  },
  testButton: {
    flex: 1,
    minWidth: "45%",
  },
  testCaseDescription: {
    fontSize: 12,
    color: "#666",
    fontStyle: "italic",
  },
  reportView: {
    height: 200,
    backgroundColor: "#f5f5f5",
    borderRadius: 8,
    marginVertical: 8,
  },
  pickerView: {
    height: 300,
    backgroundColor: "#f5f5f5",
    borderRadius: 8,
    marginVertical: 8,
  },
});
