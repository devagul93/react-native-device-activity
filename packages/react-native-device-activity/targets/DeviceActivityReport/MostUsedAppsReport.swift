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
  let totalDuration: TimeInterval // Total usage across the period
  let dailyAverage: TimeInterval  // Average per day
  let categoryName: String?
  let daysInPeriod: Int          // Number of days to calculate averages
}

struct UsageInsights {
  let peakHours: String          // e.g., "9pm-12am"
  let totalApps: Int             // Number of apps used
  let averageDailyScreenTime: TimeInterval
  let behavioralInsight: String  // Custom insight text
}

struct AppUsageInfo {
  let totalDuration: TimeInterval
  let appName: String
  let bundleId: String?
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
      return Color(red: 0.91, green: 0.26, blue: 0.59) // Instagram gradient pink
    case id.contains("twitter") || id.contains("x.com") || name.contains("twitter") || name == "x":
      return Color(red: 0.0, green: 0.0, blue: 0.0) // X (Twitter) black
    case id.contains("reddit") || name.contains("reddit"):
      return Color(red: 1.0, green: 0.27, blue: 0.0) // Reddit orange #FF4500
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
        .frame(width: 40, height: 40) // Slightly larger for better visibility
        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
      
      Image(systemName: appIcon(for: bundleIdentifier, appName: appName))
        .font(.system(size: 20, weight: .medium))
        .foregroundColor(.white)
        .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 1)
    }
  }
}

struct MostUsedAppsView: View {
  let mostUsedAppsData: [MostUsedAppsData]
  let insights: UsageInsights

  private func formatDailyAverage(_ apps: [MostUsedAppsData]) -> String {
    let totalDailyAverage = apps.reduce(0) { $0 + $1.dailyAverage }
    let totalMinutes = Int(totalDailyAverage) / 60
    
    if totalMinutes >= 60 {
      let hours = totalMinutes / 60
      let minutes = totalMinutes % 60
      return "\(hours)h \(minutes)m"
    } else {
      return "\(totalMinutes)m"
    }
  }

  private func formatAppDuration(_ duration: TimeInterval) -> String {
    let minutes = Int(duration) / 60
    if minutes >= 60 {
      let hours = minutes / 60
      let remainingMinutes = minutes % 60
      if remainingMinutes == 0 {
        return "\(hours)h"
      } else {
        return "\(hours)h \(remainingMinutes)m"
      }
    } else {
      return "\(minutes)m"
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      // Main card with exact Apple Screen Time styling
      VStack(alignment: .leading, spacing: 0) {
        // Header with title and time period indicator
        VStack(alignment: .leading, spacing: 10) {
          HStack {
            Text("Most Used Apps")
              .font(.system(size: 17, weight: .semibold))
              .foregroundColor(.white)
            
            Spacer()
            
            // Time period indicator dots
            HStack(spacing: 4) {
              Circle()
                .fill(.white.opacity(0.8))
                .frame(width: 6, height: 6)
              Circle()
                .fill(.white.opacity(0.3))
                .frame(width: 6, height: 6)
              Circle()
                .fill(.white.opacity(0.3))
                .frame(width: 6, height: 6)
            }
          }
          
          if !mostUsedAppsData.isEmpty {
            Text(insights.behavioralInsight)
              .font(.system(size: 13, weight: .regular))
              .foregroundColor(.white.opacity(0.85))
              .lineLimit(2)
              .fixedSize(horizontal: false, vertical: true)
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        
        Spacer(minLength: 16)
        
        // Main usage display
        HStack(alignment: .bottom, spacing: 0) {
          VStack(alignment: .leading, spacing: 4) {
            if !mostUsedAppsData.isEmpty {
              // Daily average time (large display)
              Text(formatDailyAverage(mostUsedAppsData))
                .font(.system(size: 48, weight: .thin, design: .default))
                .foregroundColor(.white)
                .tracking(-1)
              
              Text("per day")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .textCase(.uppercase)
                .tracking(0.5)
            }
          }
          
          Spacer()
          
          // App icons in horizontal layout - exactly like Apple
          if !mostUsedAppsData.isEmpty {
            HStack(spacing: 12) {
              ForEach(Array(mostUsedAppsData.prefix(3).enumerated()), id: \.offset) { index, appData in
                AppIconCircle(
                  appName: appData.appName,
                  bundleIdentifier: appData.bundleIdentifier
                )
              }
            }
          }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
      }
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(
            LinearGradient(
              gradient: Gradient(colors: [
                Color(red: 0.12, green: 0.12, blue: 0.12),
                Color(red: 0.08, green: 0.08, blue: 0.08)
              ]),
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .overlay(
            RoundedRectangle(cornerRadius: 16)
              .stroke(Color.white.opacity(0.1), lineWidth: 1)
          )
          .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
      )
      .padding(.horizontal, 16)

      // Detailed app breakdown (optional, can be toggled)
      if !mostUsedAppsData.isEmpty && mostUsedAppsData.count > 1 {
        VStack(spacing: 0) {
          ForEach(Array(mostUsedAppsData.prefix(5).enumerated()), id: \.offset) { index, appData in
            HStack(spacing: 12) {
              AppIconCircle(
                appName: appData.appName,
                bundleIdentifier: appData.bundleIdentifier
              )
              .scaleEffect(0.7)
              
              VStack(alignment: .leading, spacing: 2) {
                Text(appData.appName)
                  .font(.system(size: 14, weight: .medium))
                  .foregroundColor(.white)
                  .lineLimit(1)
                
                if let category = appData.categoryName {
                  Text(category)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
                }
              }
              
              Spacer()
              
              VStack(alignment: .trailing, spacing: 2) {
                Text(formatAppDuration(appData.dailyAverage))
                  .font(.system(size: 14, weight: .medium))
                  .foregroundColor(.white)
                
                Text("per day")
                  .font(.system(size: 11, weight: .regular))
                  .foregroundColor(.white.opacity(0.5))
              }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            
            if index < min(mostUsedAppsData.count - 1, 4) {
              Divider()
                .background(Color.white.opacity(0.1))
                .padding(.horizontal, 20)
            }
          }
        }
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
            .overlay(
              RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
        )
        .padding(.horizontal, 16)
        .padding(.top, 12)
      }

      // Empty state with improved design
      if mostUsedAppsData.isEmpty {
        VStack(spacing: 16) {
          Image(systemName: "apps.iphone")
            .font(.system(size: 40, weight: .ultraLight))
            .foregroundColor(.white.opacity(0.5))
          
          Text("No App Usage")
            .font(.system(size: 17, weight: .medium))
            .foregroundColor(.white.opacity(0.8))
          
          Text("App usage data will appear here when available")
            .font(.system(size: 13, weight: .regular))
            .foregroundColor(.white.opacity(0.6))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .background(
          RoundedRectangle(cornerRadius: 16)
            .fill(Color(red: 0.1, green: 0.1, blue: 0.1))
            .overlay(
              RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
        )
        .padding(.horizontal, 16)
      }
      
      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(Color.clear)
    .preferredColorScheme(.dark)
  }
}

struct MostUsedAppsReport: DeviceActivityReportScene {
  // Define which context your scene will represent.
  let context: DeviceActivityReport.Context = .mostUsedApps

  // Define the custom configuration and the resulting view for this report.
  let content: (([MostUsedAppsData], UsageInsights)) -> MostUsedAppsView

  func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async
    -> ([MostUsedAppsData], UsageInsights)
  {
    var appUsageMap: [String: AppUsageInfo] = [:]
    var hourlyUsage: [Int: TimeInterval] = [:] // Hour (0-23) -> Total usage
    var totalDays: Set<String> = []
    
    // Process all activity data to extract app usage and time patterns
    for await dataPoint in data {
      for await activitySegment in dataPoint.activitySegments {
        // Track unique days for calculating averages
        let dayKey = Calendar.current.dateInterval(of: .day, for: activitySegment.dateInterval.start)?.start.timeIntervalSince1970 ?? 0
        totalDays.insert(String(dayKey))
        
        // Extract hour for peak usage analysis
        let hour = Calendar.current.component(.hour, from: activitySegment.dateInterval.start)
        
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
              appUsageMap[key] = AppUsageInfo(
                totalDuration: existingData.totalDuration + duration,
                appName: appName,
                bundleId: bundleId,
                categoryName: categoryName
              )
            } else {
              appUsageMap[key] = AppUsageInfo(
                totalDuration: duration,
                appName: appName,
                bundleId: bundleId,
                categoryName: categoryName
              )
            }
            
            // Track hourly usage for peak analysis
            hourlyUsage[hour, default: 0] += duration
          }

          // Also process web domains if any
          for await webDomainActivity in categoryActivity.webDomains {
            let domainName = webDomainActivity.webDomain.domain ?? "Unknown Website"
            let duration = webDomainActivity.totalActivityDuration

            let key = "web_\(domainName)"
            if let existingData = appUsageMap[key] {
              appUsageMap[key] = AppUsageInfo(
                totalDuration: existingData.totalDuration + duration,
                appName: domainName,
                bundleId: nil,
                categoryName: categoryName
              )
            } else {
              appUsageMap[key] = AppUsageInfo(
                totalDuration: duration,
                appName: domainName,
                bundleId: nil,
                categoryName: categoryName
              )
            }
            
            // Track hourly usage for peak analysis
            hourlyUsage[hour, default: 0] += duration
          }
        }
      }
    }

    // Calculate the number of days in the period (minimum 1)
    let daysInPeriod = max(totalDays.count, 1)
    
    // Convert to MostUsedAppsData with daily averages
    let allApps = appUsageMap.map { (key, value) in
      MostUsedAppsData(
        appName: value.appName,
        bundleIdentifier: value.bundleId,
        totalDuration: value.totalDuration,
        dailyAverage: value.totalDuration / Double(daysInPeriod),
        categoryName: value.categoryName,
        daysInPeriod: daysInPeriod
      )
    }
    
    // Separate social media and other apps, sort by daily average
    let socialMediaApps = allApps.filter { app in
      app.categoryName?.lowercased().contains("social") == true ||
      app.appName.lowercased().contains("instagram") ||
      app.appName.lowercased().contains("twitter") ||
      app.appName.lowercased().contains("reddit") ||
      app.appName.lowercased().contains("facebook") ||
      app.appName.lowercased().contains("tiktok") ||
      app.appName.lowercased().contains("snapchat") ||
      app.appName.lowercased().contains("x")
    }.sorted { $0.dailyAverage > $1.dailyAverage }
    
    let otherApps = allApps.filter { app in
      !socialMediaApps.contains { $0.appName == app.appName }
    }.sorted { $0.dailyAverage > $1.dailyAverage }
    
    // Prioritize social media apps first, then add others
    var finalApps: [MostUsedAppsData] = []
    finalApps.append(contentsOf: socialMediaApps.prefix(3)) // Top 3 social media
    finalApps.append(contentsOf: otherApps.prefix(7)) // Up to 7 other apps
    
    let topApps = Array(finalApps.prefix(10))
    
    // Generate usage insights
    let insights = generateInsights(apps: topApps, hourlyUsage: hourlyUsage, daysInPeriod: daysInPeriod)
    
    return (topApps, insights)
  }
  
  private func generateInsights(apps: [MostUsedAppsData], hourlyUsage: [Int: TimeInterval], daysInPeriod: Int) -> UsageInsights {
    // Find peak usage hours
    let peakHours = findPeakUsageHours(hourlyUsage: hourlyUsage)
    
    // Calculate total daily average
    let totalDailyAverage = apps.reduce(0) { $0 + $1.dailyAverage }
    
    // Generate behavioral insight
    let behavioralInsight = generateBehavioralInsight(apps: apps, peakHours: peakHours)
    
    return UsageInsights(
      peakHours: peakHours,
      totalApps: apps.count,
      averageDailyScreenTime: totalDailyAverage,
      behavioralInsight: behavioralInsight
    )
  }
  
  private func findPeakUsageHours(hourlyUsage: [Int: TimeInterval]) -> String {
    // Find the hour with maximum usage
    guard let maxHour = hourlyUsage.max(by: { $0.value < $1.value })?.key else {
      return "9pm-12am" // Default fallback
    }
    
    // Group consecutive high-usage hours
    let sortedHours = hourlyUsage.sorted { $0.value > $1.value }
    let topHours = Array(sortedHours.prefix(3)).map { $0.key }.sorted()
    
    if topHours.count >= 2 {
      let startHour = topHours.first!
      let endHour = topHours.last! + 1
      return formatHourRange(start: startHour, end: endHour)
    } else {
      return formatHourRange(start: maxHour, end: maxHour + 3)
    }
  }
  
  private func formatHourRange(start: Int, end: Int) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "ha"
    
    let startDate = Calendar.current.date(bySettingHour: start, minute: 0, second: 0, of: Date()) ?? Date()
    let endDate = Calendar.current.date(bySettingHour: end % 24, minute: 0, second: 0, of: Date()) ?? Date()
    
    let startStr = formatter.string(from: startDate).lowercased()
    let endStr = formatter.string(from: endDate).lowercased()
    
    return "\(startStr)-\(endStr)"
  }
  
  private func generateBehavioralInsight(apps: [MostUsedAppsData], peakHours: String) -> String {
    let totalDailyMinutes = Int(apps.reduce(0) { $0 + $1.dailyAverage }) / 60
    
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
    
    if socialMediaApps.count >= 2 {
      let reductionSuggestion = min(max(20, Int(Double(totalDailyMinutes) * 0.3)), 80)
      return "You are most active on social media between \(peakHours). Try blocking apps for \(reductionSuggestion) mins extra"
    } else if totalDailyMinutes > 180 {
      return "High daily usage detected between \(peakHours). Breaking sessions into smaller chunks can improve focus"
    } else if totalDailyMinutes > 90 {
      return "Peak usage between \(peakHours). You might benefit from scheduled app-free periods"
    } else {
      return "Healthy digital habits maintained. Peak activity: \(peakHours)"
    }
  }
}

// MARK: - SwiftUI Previews for Fast Iteration
#if DEBUG
struct MostUsedAppsView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      // Preview with sample data
      MostUsedAppsView(mostUsedAppsData: sampleData, insights: sampleInsights)
        .frame(height: 500)
        .previewDisplayName("With Data")
        .preferredColorScheme(.dark)
      
      // Preview with empty state
      MostUsedAppsView(mostUsedAppsData: [], insights: emptyInsights)
        .frame(height: 400)
        .previewDisplayName("Empty State")
        .preferredColorScheme(.dark)
      
      // Preview with single app
      MostUsedAppsView(mostUsedAppsData: [sampleData[0]], insights: singleAppInsights)
        .frame(height: 400)
        .previewDisplayName("Single App")
        .preferredColorScheme(.dark)
    }
  }
  
  // Sample data for previews
  static let sampleData: [MostUsedAppsData] = [
    MostUsedAppsData(
      appName: "Instagram",
      bundleIdentifier: "com.burbn.instagram",
      totalDuration: 25200, // 7 hours total
      dailyAverage: 3600, // 1 hour per day
      categoryName: "Social Networking",
      daysInPeriod: 7
    ),
    MostUsedAppsData(
      appName: "X",
      bundleIdentifier: "com.twitter.twitter",
      totalDuration: 16800, // 4.67 hours total
      dailyAverage: 2400, // 40 minutes per day
      categoryName: "Social Networking",
      daysInPeriod: 7
    ),
    MostUsedAppsData(
      appName: "Reddit",
      bundleIdentifier: "com.reddit.reddit",
      totalDuration: 12600, // 3.5 hours total
      dailyAverage: 1800, // 30 minutes per day
      categoryName: "Social Networking",
      daysInPeriod: 7
    ),
    MostUsedAppsData(
      appName: "YouTube",
      bundleIdentifier: "com.google.ios.youtube",
      totalDuration: 8400, // 2.33 hours total
      dailyAverage: 1200, // 20 minutes per day
      categoryName: "Entertainment",
      daysInPeriod: 7
    ),
    MostUsedAppsData(
      appName: "Spotify",
      bundleIdentifier: "com.spotify.client",
      totalDuration: 6300, // 1.75 hours total
      dailyAverage: 900, // 15 minutes per day
      categoryName: "Music",
      daysInPeriod: 7
    )
  ]
  
  static let sampleInsights = UsageInsights(
    peakHours: "9pm-12am",
    totalApps: 5,
    averageDailyScreenTime: 6900, // 1h 55m per day
    behavioralInsight: "You are most active on social media between 9pm-12am. Try blocking apps for 58 mins extra"
  )
  
  static let emptyInsights = UsageInsights(
    peakHours: "9pm-12am",
    totalApps: 0,
    averageDailyScreenTime: 0,
    behavioralInsight: "No usage data available"
  )
  
  static let singleAppInsights = UsageInsights(
    peakHours: "9pm-12am",
    totalApps: 1,
    averageDailyScreenTime: 3600,
    behavioralInsight: "Moderate usage patterns. Peak activity: 9pm-12am"
  )
}

// Preview for AppIconCircle component
struct AppIconCircle_Previews: PreviewProvider {
  static var previews: some View {
    HStack(spacing: 16) {
      AppIconCircle(appName: "Instagram", bundleIdentifier: "com.burbn.instagram")
      AppIconCircle(appName: "X", bundleIdentifier: "com.twitter.twitter")
      AppIconCircle(appName: "Reddit", bundleIdentifier: "com.reddit.reddit")
      AppIconCircle(appName: "YouTube", bundleIdentifier: "com.google.ios.youtube")
      AppIconCircle(appName: "Spotify", bundleIdentifier: "com.spotify.client")
    }
    .padding()
    .background(Color.black)
    .previewDisplayName("App Icons")
  }
}
#endif 