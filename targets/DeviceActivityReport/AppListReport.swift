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
    -> [AppUsageData]
  {
    // Extract app names and their usage times from the data
    // Note: The data is already filtered by the DeviceActivityFilter based on 
    // familyActivitySelection tokens passed to DeviceActivityReportView
    
    var appUsageMap: [String: TimeInterval] = [:]
    
    // Process the data to extract app usage
    for dataPoint in data {
      for segment in dataPoint.activitySegments {
        for category in segment.categories {
          for application in category.applications {
            let appName = application.application.localizedDisplayName ?? "Unknown App"
            let duration = application.totalActivityDuration
            
            // Accumulate duration for each app
            appUsageMap[appName, default: 0] += duration
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