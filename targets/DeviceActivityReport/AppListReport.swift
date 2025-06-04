//
//  AppListReport.swift
//  DeviceActivityReport
//
//  Created by Assistant on 2024-12-19.
//

import DeviceActivity
import SwiftUI
import os

// Create logger for AppListReport
private let appListLogger = Logger(subsystem: "ReactNativeDeviceActivity", category: "AppListReport")

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
    appListLogger.log("🔍 AppListReport: Starting data processing for 'App List' context...")
    let startTime = Date()

    // Extract app names and their usage times from the data
    // The data is filtered by the DeviceActivityFilter based on
    // familyActivitySelection tokens passed to DeviceActivityReportView

    var appUsageMap: [String: TimeInterval] = [:]
    var totalDataPoints = 0
    var totalActivitySegments = 0
    var totalCategories = 0
    var totalApplications = 0
    var totalWebDomains = 0
    var processingErrors = 0

    // Process all activity data to extract app usage for selected apps
    do {
      for await dataPoint in data {
        totalDataPoints += 1
        appListLogger.log("📊 AppListReport: Processing data point \(totalDataPoints)")
        
        do {
          for await activitySegment in dataPoint.activitySegments {
            totalActivitySegments += 1
            appListLogger.log("📈 AppListReport: Processing activity segment \(totalActivitySegments) from data point \(totalDataPoints)")
            
            // Process categories within each segment
            do {
              for await categoryActivity in activitySegment.categories {
                totalCategories += 1
                appListLogger.log("📂 AppListReport: Processing category \(totalCategories) in segment \(totalActivitySegments)")
                
                // Process applications within each category
                do {
                  for await applicationActivity in categoryActivity.applications {
                    totalApplications += 1
                    let appName =
                      applicationActivity.application.localizedDisplayName ?? applicationActivity
                      .application.bundleIdentifier ?? "Unknown App"
                    let duration = applicationActivity.totalActivityDuration

                    appListLogger.log("📱 AppListReport: Found app '\(appName)' with duration \(duration)s (\(duration/60) min)")

                    // Accumulate duration for each app (in case same app appears multiple times)
                    appUsageMap[appName, default: 0] += duration
                  }
                } catch {
                  processingErrors += 1
                  appListLogger.log("❌ AppListReport: Error processing applications in category \(totalCategories): \(String(describing: error))")
                }

                // Also check for web domains if any
                do {
                  for await webDomainActivity in categoryActivity.webDomains {
                    totalWebDomains += 1
                    let domainName = webDomainActivity.webDomain.domain ?? "Unknown Website"
                    let duration = webDomainActivity.totalActivityDuration

                    appListLogger.log("🌐 AppListReport: Found web domain '\(domainName)' with duration \(duration)s (\(duration/60) min)")

                    // Accumulate duration for each web domain
                    appUsageMap[domainName, default: 0] += duration
                  }
                } catch {
                  processingErrors += 1
                  appListLogger.log("❌ AppListReport: Error processing web domains in category \(totalCategories): \(String(describing: error))")
                }
              }
            } catch {
              processingErrors += 1
              appListLogger.log("❌ AppListReport: Error processing categories in segment \(totalActivitySegments): \(String(describing: error))")
            }
          }
        } catch {
          processingErrors += 1
          appListLogger.log("❌ AppListReport: Error processing activity segments in data point \(totalDataPoints): \(String(describing: error))")
        }
      }
    } catch {
      processingErrors += 1
      appListLogger.log("❌ AppListReport: Error iterating through data points: \(String(describing: error))")
    }

    let processingTime = Date().timeIntervalSince(startTime)
    
    appListLogger.log("📋 AppListReport: Data processing complete:")
    appListLogger.log("   ⏱️ Processing time: \(processingTime) seconds")
    appListLogger.log("   📊 Data points: \(totalDataPoints)")
    appListLogger.log("   📈 Activity segments: \(totalActivitySegments)")
    appListLogger.log("   📂 Categories: \(totalCategories)")
    appListLogger.log("   📱 Applications: \(totalApplications)")
    appListLogger.log("   🌐 Web domains: \(totalWebDomains)")
    appListLogger.log("   ❌ Processing errors: \(processingErrors)")
    appListLogger.log("   🗂️ Unique apps/domains found: \(appUsageMap.count)")

    // Log detailed app usage map
    if appUsageMap.isEmpty {
      appListLogger.log("⚠️ AppListReport: EMPTY USAGE MAP - This will result in a blank view!")
      appListLogger.log("   Possible causes:")
      appListLogger.log("   • No apps selected in familyActivitySelection")
      appListLogger.log("   • Selected apps weren't used in the time period")
      appListLogger.log("   • Time range is too narrow")
      appListLogger.log("   • DeviceActivity permissions not granted")
      appListLogger.log("   • Data processing errors occurred")
    } else {
      appListLogger.log("✅ AppListReport: Found usage data:")
      for (appName, duration) in appUsageMap.sorted(by: { $0.value > $1.value }) {
        let minutes = duration / 60
        appListLogger.log("   📱 \(appName): \(duration)s (\(minutes) min)")
      }
    }

    // Convert to AppUsageData array and sort by duration (highest first)
    let appUsageData = appUsageMap.map { (appName, duration) in
      AppUsageData(appName: appName, duration: duration)
    }.sorted { $0.duration > $1.duration }

    appListLogger.log("✅ AppListReport: Returning \(appUsageData.count) app usage entries to view")
    
    if appUsageData.isEmpty {
      appListLogger.log("🚨 AppListReport: RETURNING EMPTY ARRAY - VIEW WILL BE BLANK!")
    }

    return appUsageData
  }
}
