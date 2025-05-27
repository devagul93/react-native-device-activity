//
//  AppListReport.swift
//  DeviceActivityReport
//
//  Created by Assistant on 2024-12-19.
//

import DeviceActivity
import SwiftUI
import FamilyControls

extension DeviceActivityReport.Context {
  static let appList = DeviceActivityReport.Context("App List")
}

struct AppUsageData {
  let appName: String
  let duration: TimeInterval
  let appToken: ApplicationToken?
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

    var appUsageMap: [String: (duration: TimeInterval, token: ApplicationToken?)] = [:]

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
            let token = applicationActivity.application.token

            // Accumulate duration for each app (in case same app appears multiple times)
            if let existing = appUsageMap[appName] {
              appUsageMap[appName] = (duration: existing.duration + duration, token: token)
            } else {
              appUsageMap[appName] = (duration: duration, token: token)
            }
          }
          
          // Also check for web domains if any
          for await webDomainActivity in categoryActivity.webDomains {
            let domainName = webDomainActivity.webDomain.domain ?? "Unknown Website"
            let duration = webDomainActivity.totalActivityDuration
            
            // Accumulate duration for each web domain (no token for web domains)
            if let existing = appUsageMap[domainName] {
              appUsageMap[domainName] = (duration: existing.duration + duration, token: nil)
            } else {
              appUsageMap[domainName] = (duration: duration, token: nil)
            }
          }
        }
      }
    }

    // Convert to AppUsageData array and sort by duration (highest first)
    let appUsageData = appUsageMap.map { (appName, data) in
      AppUsageData(appName: appName, duration: data.duration, appToken: data.token)
    }.sorted { $0.duration > $1.duration }

    return appUsageData
  }
}
