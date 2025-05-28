import React, { useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
} from "react-native";
import {
  DeviceActivityReportView,
  DeviceActivityReportStyle,
} from "react-native-device-activity";

export default function StyledTotalPickupsScreen() {
  const [selectedStyle, setSelectedStyle] = useState<
    "default" | "red" | "blue" | "large"
  >("default");

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

  const styles: Record<
    string,
    {
      style?: DeviceActivityReportStyle;
      description: string;
      background: string;
    }
  > = {
    default: {
      description: "Default styling with transparent background",
      background: "#f0f8ff",
    },
    red: {
      style: {
        textColor: { red: 255, green: 59, blue: 48, alpha: 1 },
        fontSize: 64,
        fontWeight: "heavy",
        textAlignment: "center",
      },
      description: "Large red text, heavy weight",
      background: "#fff5f5",
    },
    blue: {
      style: {
        textColor: { red: 0, green: 122, blue: 255, alpha: 1 },
        fontSize: 56,
        fontWeight: "semibold",
        fontDesign: "monospaced",
        textAlignment: "center",
      },
      description: "Blue monospaced text, semibold",
      background: "#f0f8ff",
    },
    large: {
      style: {
        textColor: { red: 52, green: 199, blue: 89, alpha: 1 },
        fontSize: 80,
        fontWeight: "black",
        fontDesign: "rounded",
        textAlignment: "center",
      },
      description: "Extra large green text, black weight",
      background: "#f0fff4",
    },
  };

  const currentConfig = styles[selectedStyle];

  return (
    <ScrollView style={stylesSheet.container}>
      <View style={stylesSheet.header}>
        <Text style={stylesSheet.title}>Styled Total Pickups</Text>
        <Text style={stylesSheet.subtitle}>
          Customize the appearance of pickup counts
        </Text>
      </View>

      {/* Style Selector */}
      <View style={stylesSheet.styleContainer}>
        <Text style={stylesSheet.sectionTitle}>Select Style:</Text>
        {Object.entries(styles).map(([key, config]) => (
          <TouchableOpacity
            key={key}
            style={[
              stylesSheet.styleButton,
              selectedStyle === key && stylesSheet.styleButtonActive,
            ]}
            onPress={() => setSelectedStyle(key as any)}
          >
            <Text
              style={[
                stylesSheet.styleButtonText,
                selectedStyle === key && stylesSheet.styleButtonTextActive,
              ]}
            >
              {key.charAt(0).toUpperCase() + key.slice(1)}
            </Text>
            <Text
              style={[
                stylesSheet.styleButtonDescription,
                selectedStyle === key &&
                  stylesSheet.styleButtonDescriptionActive,
              ]}
            >
              {config.description}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Current Style Info */}
      <View style={stylesSheet.infoContainer}>
        <Text style={stylesSheet.infoTitle}>
          Current Style: {selectedStyle}
        </Text>
        <Text style={stylesSheet.infoDescription}>
          {currentConfig.description}
        </Text>
        {currentConfig.style && (
          <View style={stylesSheet.styleDetails}>
            <Text style={stylesSheet.styleDetailText}>
              Font Size: {currentConfig.style.fontSize || 48}
            </Text>
            <Text style={stylesSheet.styleDetailText}>
              Font Weight: {currentConfig.style.fontWeight || "bold"}
            </Text>
            <Text style={stylesSheet.styleDetailText}>
              Font Design: {currentConfig.style.fontDesign || "rounded"}
            </Text>
            <Text style={stylesSheet.styleDetailText}>
              Text Color: RGB({currentConfig.style.textColor?.red || "default"},{" "}
              {currentConfig.style.textColor?.green || "default"},{" "}
              {currentConfig.style.textColor?.blue || "default"})
            </Text>
          </View>
        )}
      </View>

      {/* Report View with Custom Background */}
      <View
        style={[
          stylesSheet.reportContainer,
          { backgroundColor: currentConfig.background },
        ]}
      >
        <Text style={stylesSheet.reportLabel}>Total Pickups Today:</Text>
        <DeviceActivityReportView
          style={stylesSheet.reportView}
          context="Total Pickups"
          familyActivitySelection={null} // Show all apps
          from={startOfDay.getTime()}
          to={endOfDay.getTime()}
          segmentation="daily"
          users="all"
          devices={null}
          reportStyle={currentConfig.style}
        />
      </View>

      {/* Styling Guide */}
      <View style={stylesSheet.guideContainer}>
        <Text style={stylesSheet.guideTitle}>Styling Guide</Text>

        <View style={stylesSheet.guideSection}>
          <Text style={stylesSheet.guideSectionTitle}>
            Available Properties:
          </Text>
          <Text style={stylesSheet.guideText}>
            • textColor: RGB color (0-255) with optional alpha
          </Text>
          <Text style={stylesSheet.guideText}>
            • fontSize: Number (default: 48)
          </Text>
          <Text style={stylesSheet.guideText}>
            • fontWeight: ultraLight, thin, light, regular, medium, semibold,
            bold, heavy, black
          </Text>
          <Text style={stylesSheet.guideText}>
            • fontDesign: default, rounded, monospaced, serif
          </Text>
          <Text style={stylesSheet.guideText}>
            • textAlignment: leading, center, trailing
          </Text>
          <Text style={stylesSheet.guideText}>
            • backgroundColor: RGB color or null for transparent
          </Text>
        </View>

        <View style={stylesSheet.guideSection}>
          <Text style={stylesSheet.guideSectionTitle}>
            Transparent Background:
          </Text>
          <Text style={stylesSheet.guideText}>
            By default, the background is transparent (Color.clear) so it
            inherits the React Native view's background color. This allows you
            to set any background color on the container view.
          </Text>
        </View>

        <View style={stylesSheet.guideSection}>
          <Text style={stylesSheet.guideSectionTitle}>Example Usage:</Text>
          <View style={stylesSheet.codeContainer}>
            <Text style={stylesSheet.codeText}>
              {`<DeviceActivityReportView
  context="Total Pickups"
  reportStyle={{
    textColor: { red: 255, green: 59, blue: 48 },
    fontSize: 64,
    fontWeight: 'heavy',
    textAlignment: 'center'
  }}
  style={{ backgroundColor: '#f0f8ff' }}
/>`}
            </Text>
          </View>
        </View>
      </View>
    </ScrollView>
  );
}

const stylesSheet = StyleSheet.create({
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
  styleContainer: {
    marginHorizontal: 20,
    marginBottom: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: "600",
    color: "#1a1a1a",
    marginBottom: 12,
  },
  styleButton: {
    backgroundColor: "white",
    borderRadius: 12,
    padding: 16,
    marginBottom: 8,
    borderWidth: 2,
    borderColor: "#e9ecef",
  },
  styleButtonActive: {
    borderColor: "#007AFF",
    backgroundColor: "#f0f8ff",
  },
  styleButtonText: {
    fontSize: 16,
    fontWeight: "600",
    color: "#1a1a1a",
    marginBottom: 4,
  },
  styleButtonTextActive: {
    color: "#007AFF",
  },
  styleButtonDescription: {
    fontSize: 14,
    color: "#6c757d",
  },
  styleButtonDescriptionActive: {
    color: "#0056b3",
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
    marginBottom: 8,
  },
  styleDetails: {
    marginTop: 8,
  },
  styleDetailText: {
    fontSize: 12,
    color: "#0056b3",
    marginBottom: 2,
  },
  reportContainer: {
    marginHorizontal: 20,
    marginBottom: 20,
    borderRadius: 16,
    padding: 20,
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
  },
  reportLabel: {
    fontSize: 18,
    fontWeight: "600",
    color: "#1a1a1a",
    textAlign: "center",
    marginBottom: 16,
  },
  reportView: {
    height: 120,
    borderRadius: 12,
  },
  guideContainer: {
    marginHorizontal: 20,
    marginBottom: 40,
    padding: 16,
    backgroundColor: "white",
    borderRadius: 12,
  },
  guideTitle: {
    fontSize: 18,
    fontWeight: "600",
    color: "#1a1a1a",
    marginBottom: 16,
  },
  guideSection: {
    marginBottom: 16,
  },
  guideSectionTitle: {
    fontSize: 16,
    fontWeight: "600",
    color: "#1a1a1a",
    marginBottom: 8,
  },
  guideText: {
    fontSize: 14,
    color: "#6c757d",
    marginBottom: 4,
    lineHeight: 20,
  },
  codeContainer: {
    backgroundColor: "#f8f9fa",
    borderRadius: 8,
    padding: 12,
    marginTop: 8,
  },
  codeText: {
    fontSize: 12,
    fontFamily: "monospace",
    color: "#495057",
    lineHeight: 16,
  },
});
