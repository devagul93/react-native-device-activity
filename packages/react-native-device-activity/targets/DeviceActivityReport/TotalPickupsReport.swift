//
//  TotalPickupsReport.swift
//  DeviceActivityReport
//
//  Created by Assistant on 2024-12-19.
//

import DeviceActivity
import SwiftUI

@available(iOS 16.0, *)
extension DeviceActivityReport.Context {
  static let totalPickups = DeviceActivityReport.Context("Total Pickups")
}

@available(iOS 16.0, *)
struct TotalPickupsReport: DeviceActivityReportScene {
  // Define which context your scene will represent.
  let context: DeviceActivityReport.Context = .totalPickups

  // Define the custom configuration and the resulting view for this report.
  let content: (Int) -> TotalPickupsView

  func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> Int {
    // Calculate the total number of pickups across all apps
    // Note: The data is already filtered by the DeviceActivityFilter based on
    // familyActivitySelection tokens passed to DeviceActivityReportView

    var totalPickups = 0

    // Process the data to extract total pickup count
    for await dataPoint in data {
      for await segment in dataPoint.activitySegments {
        for await category in segment.categories {
          for await application in category.applications {
            totalPickups += application.numberOfPickups
          }
        }
      }
    }

    return totalPickups
  }
} 