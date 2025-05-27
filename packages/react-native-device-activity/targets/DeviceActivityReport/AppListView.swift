//
//  AppListView.swift
//  DeviceActivityReport
//
//  Created by Assistant on 2024-12-19.
//

import SwiftUI

struct AppListView: View {
  let appUsageData: [AppUsageData]
  
  private func formatDuration(_ duration: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.day, .hour, .minute]
    formatter.unitsStyle = .abbreviated
    formatter.zeroFormattingBehavior = .dropAll
    
    return formatter.string(from: duration) ?? "0m"
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      if appUsageData.isEmpty {
        Text("No app usage data")
          .font(.subheadline)
          .foregroundColor(.secondary)
          .padding()
      } else {
        Text("App Usage")
          .font(.headline)
          .padding(.horizontal)
          .padding(.top)
        
        ScrollView {
          LazyVStack(alignment: .leading, spacing: 4) {
            ForEach(Array(appUsageData.enumerated()), id: \.offset) { index, appData in
              HStack {
                VStack(alignment: .leading, spacing: 2) {
                  Text(appData.appName)
                    .font(.body)
                    .fontWeight(.medium)
                  
                  Text(formatDuration(appData.duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Optional: Add a visual indicator for usage amount
                Circle()
                  .fill(colorForUsage(appData.duration))
                  .frame(width: 8, height: 8)
              }
              .padding(.horizontal)
              .padding(.vertical, 4)
              
              if index < appUsageData.count - 1 {
                Divider()
                  .padding(.horizontal)
              }
            }
          }
        }
        .padding(.bottom)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(Color(.systemBackground))
  }
  
  private func colorForUsage(_ duration: TimeInterval) -> Color {
    let minutes = duration / 60
    
    if minutes < 30 {
      return .green
    } else if minutes < 120 {
      return .orange
    } else {
      return .red
    }
  }
}

// Preview
#Preview {
  AppListView(appUsageData: [
    AppUsageData(appName: "Instagram", duration: 3600), // 1 hour
    AppUsageData(appName: "Safari", duration: 1800),    // 30 minutes
    AppUsageData(appName: "Messages", duration: 900),   // 15 minutes
    AppUsageData(appName: "TikTok", duration: 2700),    // 45 minutes
  ])
} 