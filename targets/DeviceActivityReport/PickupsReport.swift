//
//  PickupsReport.swift
//  DeviceActivityReport
//
//  Created by Assistant on 2024-12-19.
//

import DeviceActivity
import SwiftUI

@available(iOS 16.0, *)
extension DeviceActivityReport.Context {
  static let pickups = DeviceActivityReport.Context("Pickups")
}

@available(iOS 16.0, *)
struct AppPickupData {
  let appName: String
  let numberOfPickups: Int
  let totalDuration: TimeInterval
}

@available(iOS 16.0, *)
struct PickupsReport: DeviceActivityReportScene {
  // Define which context your scene will represent.
  let context: DeviceActivityReport.Context = .pickups

  // Define the custom configuration and the resulting view for this report.
  let content: ([AppPickupData]) -> PickupsView

  func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async
    -> [AppPickupData] {
    // Extract app names and their pickup counts from the data
    // Note: The data is already filtered by the DeviceActivityFilter based on
    // familyActivitySelection tokens passed to DeviceActivityReportView

    var appPickupMap: [String: (pickups: Int, duration: TimeInterval)] = [:]

    // Process the data to extract app pickup information
    for await dataPoint in data {
      for await segment in dataPoint.activitySegments {
        for await category in segment.categories {
          for await application in category.applications {
            let appName = application.application.localizedDisplayName ?? "Unknown App"
            let pickups = application.numberOfPickups
            let duration = application.totalActivityDuration

            // Accumulate pickups and duration for each app
            let existing = appPickupMap[appName] ?? (pickups: 0, duration: 0)
            appPickupMap[appName] = (
              pickups: existing.pickups + pickups,
              duration: existing.duration + duration
            )
          }
        }
      }
    }

    // Convert to AppPickupData array and sort by number of pickups (highest first)
    let appPickupData = appPickupMap.map { (appName, data) in
      AppPickupData(
        appName: appName,
        numberOfPickups: data.pickups,
        totalDuration: data.duration
      )
    }.sorted { $0.numberOfPickups > $1.numberOfPickups }

    return appPickupData
  }
}
