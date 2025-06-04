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

struct AppUsageData: Equatable {
  let appName: String
  let duration: TimeInterval
  
  static func == (lhs: AppUsageData, rhs: AppUsageData) -> Bool {
    return lhs.appName == rhs.appName && abs(lhs.duration - rhs.duration) < 1.0
  }
}

// MARK: - Shared Cache Constants
private let DEVICE_ACTIVITY_CACHE_KEY = "cached_app_usage_data"
private let CACHE_TIMESTAMP_KEY = "cached_app_usage_timestamp"
private let CACHE_SELECTION_ID_KEY = "cached_selection_id"
private let CACHE_TIME_RANGE_KEY = "cached_time_range"

// MARK: - Cache Helper Functions
private func generateCacheKey(selectionId: String?, timeRange: String) -> String {
  let selection = selectionId ?? "all_apps"
  return "\(DEVICE_ACTIVITY_CACHE_KEY)_\(selection)_\(timeRange)"
}

private func cacheAppUsageData(_ data: [AppUsageData], selectionId: String?, timeRange: String) {
  guard let userDefaults = userDefaults else { return }
  
  let cacheKey = generateCacheKey(selectionId: selectionId, timeRange: timeRange)
  
  // Convert to serializable format
  let cacheData = data.map { app in
    [
      "appName": app.appName,
      "duration": app.duration
    ]
  }
  
  // Store cached data
  userDefaults.set(cacheData, forKey: cacheKey)
  userDefaults.set(Date().timeIntervalSince1970, forKey: "\(cacheKey)_timestamp")
  userDefaults.set(selectionId ?? "", forKey: "\(cacheKey)_selection")
  
  // Also store as "latest" for immediate access
  userDefaults.set(cacheData, forKey: "latest_app_usage_data")
  userDefaults.set(Date().timeIntervalSince1970, forKey: "latest_app_usage_timestamp")
  
  appListLogger.log("💾 Extension: Cached \(data.count) apps to shared storage (key: \(cacheKey))")
}

private func getCachedAppUsageData(selectionId: String?, timeRange: String) -> ([AppUsageData], Date?)? {
  guard let userDefaults = userDefaults else { return nil }
  
  let cacheKey = generateCacheKey(selectionId: selectionId, timeRange: timeRange)
  
  guard let cacheData = userDefaults.array(forKey: cacheKey) as? [[String: Any]],
        let timestamp = userDefaults.object(forKey: "\(cacheKey)_timestamp") as? TimeInterval else {
    return nil
  }
  
  let appUsageData = cacheData.compactMap { dict -> AppUsageData? in
    guard let appName = dict["appName"] as? String,
          let duration = dict["duration"] as? TimeInterval else { return nil }
    return AppUsageData(appName: appName, duration: duration)
  }
  
  return (appUsageData, Date(timeIntervalSince1970: timestamp))
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

    // Generate cache identifiers
    let timeRange = "current" // You could make this more specific based on actual time range
    let selectionId = userDefaults?.string(forKey: "current_selection_id") // Store this when setting selection
    
    // Check for cached data first
    if let (cachedData, cacheTimestamp) = getCachedAppUsageData(selectionId: selectionId, timeRange: timeRange),
       let timestamp = cacheTimestamp {
      let cacheAge = Date().timeIntervalSince(timestamp)
      
      // Return cached data if less than 30 seconds old
      if cacheAge < 30 && !cachedData.isEmpty {
        appListLogger.log("⚡ AppListReport: Returning cached data (age: \(cacheAge)s, count: \(cachedData.count))")
        
        // Process fresh data in background
        Task {
          let freshData = await processFreshData(data: data, startTime: startTime)
          if freshData.count != cachedData.count || freshData != cachedData {
            cacheAppUsageData(freshData, selectionId: selectionId, timeRange: timeRange)
            appListLogger.log("🔄 AppListReport: Updated cache with fresh data (\(freshData.count) apps)")
          }
        }
        
        return cachedData
      }
    }

    // Process fresh data
    let freshData = await processFreshData(data: data, startTime: startTime)
    
    // Cache the fresh data
    cacheAppUsageData(freshData, selectionId: selectionId, timeRange: timeRange)
    
    return freshData
  }
  
  private func processFreshData(data: DeviceActivityResults<DeviceActivityData>, startTime: Date) async -> [AppUsageData] {
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
