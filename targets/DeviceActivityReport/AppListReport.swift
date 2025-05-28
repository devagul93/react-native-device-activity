//
//  AppListReport.swift
//  DeviceActivityReport
//
//  Created by Assistant on 2024-12-19.
//

import DeviceActivity
import SwiftUI

extension DeviceActivityReport.Context {
  static let appList = DeviceActivityReport.Context("App List")
}

struct AppUsageData {
  let appName: String
  let duration: TimeInterval
}

struct AppListReport: DeviceActivityReportScene {
  // Define which context your scene will represent.
  let context: DeviceActivityReport.Context = .appList

  // Define the custom configuration and the resulting view for this report.
  let content: ([AppUsageData]) -> AppListView

  func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async
    -> [AppUsageData] {
    // Extract app names and their usage times from the data
    // The data is filtered by the DeviceActivityFilter based on
    // familyActivitySelection tokens passed to DeviceActivityReportView

    var appUsageMap: [String: TimeInterval] = [:]

    // Process all activity data to extract app usage for selected apps
    for await dataPoint in data {
      for await activitySegment in dataPoint.activitySegments {
        // Process categories within each segment
        for await categoryActivity in activitySegment.categories {
          // Process applications within each category
          for await applicationActivity in categoryActivity.applications {
            let appName = applicationActivity.application.localizedDisplayName ?? 
                         applicationActivity.application.bundleIdentifier ?? "Unknown App"
            let duration = applicationActivity.totalActivityDuration

            // Accumulate duration for each app (in case same app appears multiple times)
            appUsageMap[appName, default: 0] += duration
          }
          
          // Also check for web domains if any
          for await webDomainActivity in categoryActivity.webDomains {
            let domainName = webDomainActivity.webDomain.domain ?? "Unknown Website"
            let duration = webDomainActivity.totalActivityDuration
            
            // Accumulate duration for each web domain
            appUsageMap[domainName, default: 0] += duration
          }
        }
      }
    }

    // Convert to AppUsageData array and sort by duration (highest first)
    let appUsageData = appUsageMap.map { (appName, duration) in
      AppUsageData(appName: appName, duration: duration)
    }.sorted { $0.duration > $1.duration }

    return appUsageData
  }
}
