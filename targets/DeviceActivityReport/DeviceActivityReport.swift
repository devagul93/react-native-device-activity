//
//  DeviceActivityReport.swift
//  DeviceActivityReport
//
//  Created by Robert Herber on 2024-11-10.
//

import DeviceActivity
import SwiftUI

@main
struct DeviceActivityReportUI: DeviceActivityReportExtension {
  var body: some DeviceActivityReportScene {
    // Create a report for each DeviceActivityReport.Context that your app supports.
    TotalActivityReport { totalActivity in
      TotalActivityView(totalActivity: totalActivity)
    }

    // Add the new app list report
    AppListReport { appUsageData in
      AppListView(appUsageData: appUsageData)
    }

    // Add the pickups report (iOS 16.0+)
    if #available(iOS 16.0, *) {
      PickupsReport { appPickupData in
        PickupsView(appPickupData: appPickupData)
      }
    }
    // Add more reports here...
  }
}
