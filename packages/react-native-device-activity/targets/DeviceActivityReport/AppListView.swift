//
//  AppListView.swift
//  DeviceActivityReport
//
//  Created by Assistant on 2024-12-19.
//

import SwiftUI
import os

// Create logger for AppListView
private let appListViewLogger = Logger(
  subsystem: "ReactNativeDeviceActivity", category: "AppListView")

struct AppIconView: View {
  let appName: String

  private func iconColor(for appName: String) -> Color {
    let colors: [Color] = [.blue, .green, .orange, .red, .purple, .pink, .indigo, .teal]
    let index = abs(appName.hashValue) % colors.count
    return colors[index]
  }

  var body: some View {
    // Create attractive placeholder icons with app's first letter
    RoundedRectangle(cornerRadius: 5)
      .fill(iconColor(for: appName))
      .frame(width: 24, height: 24)
      .overlay(
        Text(String(appName.prefix(1).uppercased()))
          .font(.system(size: 12, weight: .semibold))
          .foregroundColor(.white)
      )
      .shadow(radius: 1, x: 0, y: 1)
  }
}

struct AppListView: View {
  let appUsageData: [AppUsageData]
  @State private var hasAppeared = false

  private func formatDuration(_ duration: TimeInterval) -> String {
    let hours = Int(duration) / 3600
    let minutes = Int(duration.truncatingRemainder(dividingBy: 3600)) / 60

    if hours > 0 {
      return "\(hours)h:\(String(format: "%02d", minutes))m"
    } else {
      return "\(minutes)m"
    }
  }

  var body: some View {
    appListViewLogger.log("🎨 AppListView: Rendering with \(appUsageData.count) app usage entries")

    if appUsageData.isEmpty {
      appListViewLogger.log(
        "⚠️ AppListView: Rendering EMPTY STATE - this will appear as blank or minimal content")
    } else {
      appListViewLogger.log("✅ AppListView: Rendering with data:")
      for (index, appData) in appUsageData.enumerated() {
        appListViewLogger.log(
          "   \(index + 1). \(appData.appName): \(formatDuration(appData.duration))")
      }
    }

    return VStack(alignment: .leading, spacing: 0) {
      // Header
      HStack {
        Text("BLOCKED APPS")
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundColor(.secondary)

        Spacer()

        Text("AVG TIME")
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundColor(.secondary)
      }
      .padding(.horizontal, 16)
      .padding(.top, 16)
      .padding(.bottom, 8)

      if appUsageData.isEmpty {
        // Enhanced empty state with better visibility
        VStack(spacing: 12) {
          Image(systemName: "app.badge")
            .font(.largeTitle)
            .foregroundColor(.secondary)

          Text("No App Usage Data")
            .font(.headline)
            .fontWeight(.medium)
            .foregroundColor(.primary)

          Text("No activity found for the selected apps in this time period.")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)

          Text("Possible reasons:")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.secondary)
            .padding(.top, 8)

          VStack(alignment: .leading, spacing: 4) {
            Text("• No apps selected for monitoring")
            Text("• Selected apps weren't used in this period")
            Text("• Device Activity permissions not granted")
            Text("• Time range too narrow")
          }
          .font(.caption)
          .foregroundColor(.secondary)
          .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .onAppear {
          appListViewLogger.log("👁️ AppListView: Empty state view appeared")
        }
      } else {
        VStack(spacing: 0) {
          ForEach(Array(appUsageData.enumerated()), id: \.offset) { index, appData in
            HStack(spacing: 12) {
              // App icon
              AppIconView(appName: appData.appName)

              Text(appData.appName)
                .font(.body)
                .foregroundColor(.primary)

              Spacer()

              Text(formatDuration(appData.duration))
                .font(.body)
                .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            if index < appUsageData.count - 1 {
              Divider()
                .padding(.leading, 52)  // Align with text, not icon
            }
          }
        }
        .onAppear {
          appListViewLogger.log(
            "👁️ AppListView: Data list view appeared with \(appUsageData.count) items")
        }
      }

      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(Color.clear)
    .preferredColorScheme(.dark)
    .onAppear {
      hasAppeared = true
      appListViewLogger.log(
        "👁️ AppListView: Main view appeared - hasData: \(!appUsageData.isEmpty), count: \(appUsageData.count)"
      )
    }
    .onDisappear {
      hasAppeared = false
      appListViewLogger.log("👁️ AppListView: Main view disappeared")
    }
  }
}

// Preview
#Preview {
  AppListView(appUsageData: [
    AppUsageData(appName: "Instagram", duration: 3600),  // 1 hour
    AppUsageData(appName: "Safari", duration: 1800),  // 30 minutes
    AppUsageData(appName: "Messages", duration: 900),  // 15 minutes
    AppUsageData(appName: "TikTok", duration: 2700),  // 45 minutes
  ])
}
