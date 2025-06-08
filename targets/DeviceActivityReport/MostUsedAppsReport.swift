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

  private func iconColor(for identifier: String, appName: String) -> Color {
    // Use actual app brand colors when possible
    let id = (bundleIdentifier?.lowercased() ?? "")
    let name = appName.lowercased()
    
    switch true {
    case id.contains("instagram") || name.contains("instagram"):
      return Color(red: 0.91, green: 0.26, blue: 0.59) // Instagram brand pink/purple
    case id.contains("twitter") || id.contains("x.com") || name.contains("twitter") || name == "x":
      return Color(red: 0.1, green: 0.1, blue: 0.1) // X (Twitter) dark/black
    case id.contains("reddit") || name.contains("reddit"):
      return Color(red: 1.0, green: 0.27, blue: 0.0) // Reddit orange
    case id.contains("facebook") || name.contains("facebook"):
      return Color(red: 0.23, green: 0.35, blue: 0.6) // Facebook blue
    case id.contains("tiktok") || name.contains("tiktok"):
      return Color(red: 1.0, green: 0.0, blue: 0.31) // TikTok red
    case id.contains("snapchat") || name.contains("snapchat"):
      return Color(red: 1.0, green: 0.98, blue: 0.0) // Snapchat yellow
    case id.contains("whatsapp") || name.contains("whatsapp"):
      return Color(red: 0.15, green: 0.68, blue: 0.38) // WhatsApp green
    case id.contains("youtube") || name.contains("youtube"):
      return Color(red: 1.0, green: 0.0, blue: 0.0) // YouTube red
    case id.contains("spotify") || name.contains("spotify"):
      return Color(red: 0.11, green: 0.73, blue: 0.33) // Spotify green
    case id.contains("netflix") || name.contains("netflix"):
      return Color(red: 0.9, green: 0.0, blue: 0.0) // Netflix red
    case id.contains("discord") || name.contains("discord"):
      return Color(red: 0.35, green: 0.4, blue: 0.9) // Discord purple
    case id.contains("telegram") || name.contains("telegram"):
      return Color(red: 0.0, green: 0.6, blue: 0.9) // Telegram blue
    default:
      // Fallback to deterministic colors
      let fallbackColors: [Color] = [
        Color(red: 0.2, green: 0.6, blue: 1.0), // Blue
        Color(red: 0.9, green: 0.2, blue: 0.4), // Pink
        Color(red: 0.2, green: 0.8, blue: 0.4), // Green
        Color(red: 0.6, green: 0.3, blue: 0.9), // Purple
        Color(red: 1.0, green: 0.6, blue: 0.0), // Orange
        Color(red: 0.0, green: 0.7, blue: 0.9), // Cyan
      ]
      let key = identifier
      let index = abs(key.hashValue) % fallbackColors.count
      return fallbackColors[index]
    }
  }

  private func appIcon(for bundleId: String?, appName: String) -> String {
    // More comprehensive app detection using both bundle ID and app name
    let id = bundleId?.lowercased() ?? ""
    let name = appName.lowercased()
    
    switch true {
    case id.contains("instagram") || name.contains("instagram"):
      return "camera.circle.fill"
    case id.contains("twitter") || id.contains("x.com") || name.contains("twitter") || name == "x":
      return "xmark.circle.fill"
    case id.contains("reddit") || name.contains("reddit"):
      return "bubble.left.and.bubble.right.fill"
    case id.contains("tiktok") || name.contains("tiktok"):
      return "music.note.circle.fill"
    case id.contains("youtube") || name.contains("youtube"):
      return "play.circle.fill"
    case id.contains("facebook") || name.contains("facebook"):
      return "person.2.circle.fill"
    case id.contains("snapchat") || name.contains("snapchat"):
      return "camera.viewfinder"
    case id.contains("whatsapp") || name.contains("whatsapp"):
      return "message.circle.fill"
    case id.contains("telegram") || name.contains("telegram"):
      return "paperplane.circle.fill"
    case id.contains("discord") || name.contains("discord"):
      return "gamecontroller.fill"
    case id.contains("safari") || name.contains("safari"):
      return "safari.fill"
    case id.contains("chrome") || name.contains("chrome"):
      return "globe.circle.fill"
    case id.contains("maps") || name.contains("maps"):
      return "map.circle.fill"
    case id.contains("spotify") || name.contains("spotify"):
      return "music.circle.fill"
    case id.contains("netflix") || name.contains("netflix"):
      return "tv.circle.fill"
    default:
      return "app.circle.fill"
    }
  }

  var body: some View {
    ZStack {
      Circle()
        .fill(iconColor(for: bundleIdentifier ?? appName, appName: appName))
        .frame(width: 36, height: 36) // Slightly larger to match screenshot
        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
      
      Image(systemName: appIcon(for: bundleIdentifier, appName: appName))
        .font(.system(size: 18, weight: .medium))
        .foregroundColor(.white)
        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 0.5)
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
    let totalMinutes = Int(totalDuration) / 60
    return "\(totalMinutes)mins"
  }

    private func generateBehavioralInsight(_ apps: [MostUsedAppsData]) -> String {
    let totalDuration = apps.reduce(0) { $0 + $1.duration }
    let totalMinutes = Int(totalDuration) / 60
    
    // Check if majority are social media apps
    let socialMediaApps = apps.filter { app in
      app.categoryName?.lowercased().contains("social") == true ||
      app.appName.lowercased().contains("instagram") ||
      app.appName.lowercased().contains("twitter") ||
      app.appName.lowercased().contains("reddit") ||
      app.appName.lowercased().contains("facebook") ||
      app.appName.lowercased().contains("tiktok") ||
      app.appName.lowercased().contains("snapchat") ||
      app.appName.lowercased().contains("x")
    }
    
    // Generate insights matching the screenshot style
    if socialMediaApps.count >= (apps.count * 2) / 3 && totalMinutes > 60 {
      let reductionSuggestion = min(max(30, Int(Double(totalMinutes) * 0.7)), 120)
      return "You are most active on social media between 9pm-12am. Try blocking apps for \(reductionSuggestion) mins extra"
    } else if socialMediaApps.count >= apps.count / 2 {
      return "Most of your usage is social media. Consider setting evening limits to improve sleep quality"
    } else if totalMinutes > 180 {
      return "High daily usage detected. Breaking sessions into smaller chunks can improve focus"
    } else if totalMinutes > 90 {
      return "Moderate usage patterns. You might benefit from scheduled app-free periods"
    } else {
      return "Healthy digital habits maintained. Continue monitoring for optimal balance"
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      // Main content container with rounded corners like screenshot
      VStack(alignment: .leading, spacing: 0) {
        // Header Section
        VStack(alignment: .leading, spacing: 10) {
          Text("Most Used Apps")
            .font(.system(size: 18, weight: .semibold, design: .default))
            .foregroundColor(.white)
            .padding(.bottom, 4)
          
          if !mostUsedAppsData.isEmpty {
            Text(generateBehavioralInsight(mostUsedAppsData))
              .font(.system(size: 14, weight: .regular, design: .default))
              .foregroundColor(.white.opacity(0.8))
              .multilineTextAlignment(.leading)
              .lineLimit(nil)
              .fixedSize(horizontal: false, vertical: true)
              .padding(.bottom, 8)
          }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        
        // Large time display - exactly like screenshot
        if !mostUsedAppsData.isEmpty {
          HStack {
            Spacer()
            Text(formatTotalDuration(mostUsedAppsData))
              .font(.system(size: 72, weight: .ultraLight, design: .default))
              .foregroundColor(.white)
              .monospacedDigit()
              .tracking(-2) // Tighter letter spacing
            Spacer()
          }
          .padding(.vertical, 12)
        }
        
        // App icons section - horizontal layout matching screenshot
        if !mostUsedAppsData.isEmpty {
          HStack(spacing: 0) {
            ForEach(Array(mostUsedAppsData.prefix(3).enumerated()), id: \.offset) { index, appData in
              VStack(spacing: 6) {
                // App icon - sized to match screenshot
                AppIconCircle(
                  appName: appData.appName,
                  bundleIdentifier: appData.bundleIdentifier
                )
                .scaleEffect(1.1)
                
                // App name below icon - small text
                Text(appData.appName)
                  .font(.system(size: 12, weight: .medium, design: .default))
                  .foregroundColor(.white.opacity(0.9))
                  .lineLimit(1)
                  .multilineTextAlignment(.center)
                  .truncationMode(.tail)
              }
              .frame(maxWidth: .infinity)
            }
          }
          .padding(.horizontal, 32)
          .padding(.bottom, 24)
        }
      }
      .background(
        // Rounded rectangle background matching screenshot
        RoundedRectangle(cornerRadius: 20)
          .fill(
            LinearGradient(
              gradient: Gradient(colors: [
                Color.black.opacity(0.92),
                Color.black.opacity(0.88)
              ]),
              startPoint: .top,
              endPoint: .bottom
            )
          )
          .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
      )
      .padding(.horizontal, 20)
      .padding(.vertical, 12)

      // Empty state - minimal, matching dark theme
      if mostUsedAppsData.isEmpty {
        VStack(spacing: 16) {
          Image(systemName: "chart.bar.xaxis")
            .font(.system(size: 32))
            .foregroundColor(.white.opacity(0.6))
          
          Text("No Usage Data")
            .font(.system(size: 18, weight: .medium, design: .default))
            .foregroundColor(.white.opacity(0.8))
          
          Text("App usage will appear here when available")
            .font(.system(size: 14, weight: .regular, design: .default))
            .foregroundColor(.white.opacity(0.6))
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .background(
          RoundedRectangle(cornerRadius: 16)
            .fill(Color.black.opacity(0.9))
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
      }
      
      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(Color.clear) // Transparent background to let parent handle styling
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