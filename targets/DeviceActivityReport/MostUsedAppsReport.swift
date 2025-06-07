//
//  MostUsedAppsReport.swift
//  DeviceActivityReport
//
//  Created by Assistant on 2024-12-19.
//

import DeviceActivity
import SwiftUI

extension DeviceActivityReport.Context {
  static let mostUsedApps = DeviceActivityReport.Context("Most Used Apps")
}

struct MostUsedAppsData {
  let appName: String
  let bundleIdentifier: String?
  let duration: TimeInterval
  let categoryName: String?
}

struct AppIconCircle: View {
  let appName: String
  let bundleIdentifier: String?

  private func iconColor(for identifier: String) -> Color {
    // Generate deterministic colors based on app name/bundle ID
    let colors: [Color] = [
      Color(red: 0.2, green: 0.6, blue: 1.0), // Instagram-like blue
      Color(red: 0.1, green: 0.1, blue: 0.1), // X/Twitter-like black
      Color(red: 1.0, green: 0.27, blue: 0.0), // Reddit-like orange
      Color(red: 0.9, green: 0.2, blue: 0.4), // Pink
      Color(red: 0.2, green: 0.8, blue: 0.4), // Green
      Color(red: 0.6, green: 0.3, blue: 0.9), // Purple
      Color(red: 1.0, green: 0.6, blue: 0.0), // Orange
      Color(red: 0.0, green: 0.7, blue: 0.9), // Cyan
    ]
    
    let key = bundleIdentifier ?? appName
    let index = abs(key.hashValue) % colors.count
    return colors[index]
  }

  private func appIcon(for bundleId: String?) -> String {
    // Map some common bundle IDs to appropriate SF Symbols
    switch bundleId {
    case let id where id?.contains("instagram") == true:
      return "camera.circle.fill"
    case let id where id?.contains("twitter") == true, let id where id?.contains("x.com") == true:
      return "x.circle.fill" 
    case let id where id?.contains("reddit") == true:
      return "circle.fill"
    case let id where id?.contains("tiktok") == true:
      return "music.note.circle.fill"
    case let id where id?.contains("youtube") == true:
      return "play.circle.fill"
    case let id where id?.contains("safari") == true:
      return "safari.fill"
    case let id where id?.contains("chrome") == true:
      return "globe.badge.chevron.backward"
    case let id where id?.contains("messages") == true:
      return "message.circle.fill"
    case let id where id?.contains("whatsapp") == true:
      return "message.circle.fill"
    case let id where id?.contains("snapchat") == true:
      return "camera.viewfinder"
    default:
      return "app.circle.fill"
    }
  }

  var body: some View {
    ZStack {
      Circle()
        .fill(iconColor(for: bundleIdentifier ?? appName))
        .frame(width: 32, height: 32)
      
      Image(systemName: appIcon(for: bundleIdentifier))
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.white)
        .shadow(radius: 1, x: 0, y: 1)
    }
  }
}

struct MostUsedAppsView: View {
  let mostUsedAppsData: [MostUsedAppsData]

  private func formatDuration(_ duration: TimeInterval) -> String {
    let totalMinutes = Int(duration) / 60
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60

    if hours > 0 {
      return "\(hours)h \(minutes)m"
    } else {
      return "\(minutes)m"
    }
  }

  private func formatTotalDuration(_ apps: [MostUsedAppsData]) -> String {
    let totalDuration = apps.reduce(0) { $0 + $1.duration }
    return formatDuration(totalDuration)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // Header Section
      VStack(alignment: .leading, spacing: 8) {
        Text("Most Used Apps")
          .font(.title2)
          .fontWeight(.semibold)
          .foregroundColor(.primary)
        
        if !mostUsedAppsData.isEmpty {
          Text("You are most active on social media between 9pm-12am. Try blocking apps for 80 mins extra")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.leading)
        }
        
        // Total time display
        if !mostUsedAppsData.isEmpty {
          Text(formatTotalDuration(mostUsedAppsData))
            .font(.system(size: 48, weight: .light, design: .default))
            .foregroundColor(.primary)
            .padding(.top, 8)
        }
      }
      .padding(.horizontal, 20)
      .padding(.top, 16)
      .padding(.bottom, 24)

      if mostUsedAppsData.isEmpty {
        VStack(spacing: 12) {
          Image(systemName: "chart.bar.xaxis")
            .font(.system(size: 32))
            .foregroundColor(.secondary)
          
          Text("No app usage data")
            .font(.headline)
            .foregroundColor(.secondary)
          
          Text("Start using apps to see your usage patterns here")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
      } else {
        // Apps List with improved styling
        LazyVStack(spacing: 0) {
          ForEach(Array(mostUsedAppsData.enumerated()), id: \.offset) { index, appData in
            HStack(spacing: 16) {
              // App icon
              AppIconCircle(
                appName: appData.appName,
                bundleIdentifier: appData.bundleIdentifier
              )

              VStack(alignment: .leading, spacing: 2) {
                Text(appData.appName)
                  .font(.body)
                  .fontWeight(.medium)
                  .foregroundColor(.primary)
                  .lineLimit(1)
                
                if let categoryName = appData.categoryName {
                  Text(categoryName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                }
              }

              Spacer()

              Text(formatDuration(appData.duration))
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .monospacedDigit()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            if index < mostUsedAppsData.count - 1 {
              Divider()
                .padding(.leading, 68) // Align with text content
                .padding(.trailing, 20)
            }
          }
        }
        .background(
          RoundedRectangle(cornerRadius: 16)
            .fill(Color(.secondarySystemGroupedBackground))
        )
        .padding(.horizontal, 16)
      }

      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(Color(.systemGroupedBackground))
    .preferredColorScheme(.dark)
  }
}

struct MostUsedAppsReport: DeviceActivityReportScene {
  // Define which context your scene will represent.
  let context: DeviceActivityReport.Context = .mostUsedApps

  // Define the custom configuration and the resulting view for this report.
  let content: ([MostUsedAppsData]) -> MostUsedAppsView

  func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async
    -> [MostUsedAppsData]
  {
    var appUsageMap: [String: MostUsedAppsData] = [:]

    // Process all activity data to extract app usage
    for await dataPoint in data {
      for await activitySegment in dataPoint.activitySegments {
        // Process categories within each segment
        for await categoryActivity in activitySegment.categories {
          let categoryName = categoryActivity.category.localizedDisplayName
          
          // Process applications within each category
          for await applicationActivity in categoryActivity.applications {
            let appName = applicationActivity.application.localizedDisplayName 
              ?? applicationActivity.application.bundleIdentifier 
              ?? "Unknown App"
            let bundleId = applicationActivity.application.bundleIdentifier
            let duration = applicationActivity.totalActivityDuration

            // Use bundle identifier as key to avoid duplicates
            let key = bundleId ?? appName
            
            if let existingData = appUsageMap[key] {
              // Accumulate duration if app already exists
              appUsageMap[key] = MostUsedAppsData(
                appName: appName,
                bundleIdentifier: bundleId,
                duration: existingData.duration + duration,
                categoryName: categoryName
              )
            } else {
              appUsageMap[key] = MostUsedAppsData(
                appName: appName,
                bundleIdentifier: bundleId,
                duration: duration,
                categoryName: categoryName
              )
            }
          }

          // Also process web domains if any
          for await webDomainActivity in categoryActivity.webDomains {
            let domainName = webDomainActivity.webDomain.domain ?? "Unknown Website"
            let duration = webDomainActivity.totalActivityDuration

            let key = "web_\(domainName)"
            if let existingData = appUsageMap[key] {
              appUsageMap[key] = MostUsedAppsData(
                appName: domainName,
                bundleIdentifier: nil,
                duration: existingData.duration + duration,
                categoryName: categoryName
              )
            } else {
              appUsageMap[key] = MostUsedAppsData(
                appName: domainName,
                bundleIdentifier: nil,
                duration: duration,
                categoryName: categoryName
              )
            }
          }
        }
      }
    }

    // Convert to array and sort by duration (highest first)
    let sortedApps = appUsageMap.values
      .sorted { $0.duration > $1.duration }
      .prefix(10) // Limit to top 10 most used apps
    
    return Array(sortedApps)
  }
} 