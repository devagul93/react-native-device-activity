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
    // Note: Since PickupsReport is already marked with @available(iOS 16.0, *),
    // we can include it directly here. The availability check is handled at the type level.
    PickupsReport { appPickupData in
      PickupsView(appPickupData: appPickupData)
    }

    // Add the total pickups report (iOS 16.0+)
    TotalPickupsReport { totalPickups in
      TotalPickupsView(totalPickups: totalPickups)
    }

    // Add more reports here...
  }
}
