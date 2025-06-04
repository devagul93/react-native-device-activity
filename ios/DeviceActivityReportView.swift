//
//  DeviceActivityReport.swift
//  Pods
//
//  Created by Robert Herber on 2024-11-12.
//

import Combine
import DeviceActivity
import ExpoModulesCore
import FamilyControls
import Foundation
import SwiftUI
import os

// Create logger for DeviceActivityReportView
private let reportLogger = Logger(subsystem: "ReactNativeDeviceActivity", category: "DeviceActivityReportView")

// Helper function to convert reportStyle to property list compatible format
func convertToPropertyListCompatible(_ dict: [String: Any]) -> [String: Any] {
  var result: [String: Any] = [:]

  for (key, value) in dict {
    if let nestedDict = value as? [String: Any] {
      // Convert nested dictionaries
      result[key] = convertToPropertyListCompatible(nestedDict)
    } else if value is NSNull {
      // Convert NSNull to a string representation
      result[key] = "null"
    } else if value is String || value is NSNumber || value is Bool {
      // These are already property list compatible
      result[key] = value
    } else if let arrayValue = value as? [Any] {
      // Convert arrays recursively
      result[key] = arrayValue.map { item -> Any in
        if let dictItem = item as? [String: Any] {
          return convertToPropertyListCompatible(dictItem)
        } else if item is NSNull {
          return "null"
        } else {
          return item
        }
      }
    } else {
      // Convert other types to string representation
      result[key] = String(describing: value)
    }
  }

  return result
}

// Base view model that works on iOS 15.0+
@available(iOS 15.0, *)
class DeviceActivityReportViewModelBase: ObservableObject {
  @Published var familyActivitySelection = FamilyActivitySelection() {
    didSet {
      reportLogger.log("📊 Model: familyActivitySelection changed - Apps: \(self.familyActivitySelection.applicationTokens.count), Categories: \(self.familyActivitySelection.categoryTokens.count), Domains: \(self.familyActivitySelection.webDomainTokens.count)")
    }
  }
  @Published var context = "Total Activity" {
    didSet {
      reportLogger.log("📊 Model: context changed to '\(self.context)'")
    }
  }
  @Published var from = Date.distantPast {
    didSet {
      reportLogger.log("📊 Model: from date changed to \(self.from)")
      logTimeRangeValidation()
    }
  }
  @Published var to = Date.distantPast {
    didSet {
      reportLogger.log("📊 Model: to date changed to \(self.to)")
      logTimeRangeValidation()
    }
  }
  @Published var segmentation: String = "daily" {
    didSet {
      reportLogger.log("📊 Model: segmentation changed to '\(self.segmentation)'")
    }
  }
  @Published var reportStyle: [String: Any]? {
    didSet {
      reportLogger.log("📊 Model: reportStyle changed - \(self.reportStyle?.description ?? "nil")")
    }
  }

  private func logTimeRangeValidation() {
    let interval = to.timeIntervalSince(from)
    let hours = interval / 3600
    let days = interval / (3600 * 24)
    
    if interval > 0 {
      reportLogger.log("📅 Model: Valid time range - Duration: \(hours) hours (\(days) days)")
      if interval < 3600 {
        reportLogger.log("⚠️ Model: Very short time range (< 1 hour) - may result in blank view")
      }
    } else if interval == 0 {
      reportLogger.log("⚠️ Model: Zero time range - will definitely result in blank view")
    } else {
      reportLogger.log("❌ Model: Invalid time range - 'to' is before 'from' - will result in blank view")
    }
  }

  init() {
    reportLogger.log("🏗️ DeviceActivityReportViewModelBase: Initialized")
  }
}

// iOS 16.0+ specific view model with DeviceActivityFilter support
@available(iOS 16.0, *)
class DeviceActivityReportViewModel: DeviceActivityReportViewModelBase {
  @Published var devices = DeviceActivityFilter.Devices(Set<DeviceActivityData.Device.Model>()) {
    didSet {
      reportLogger.log("📊 Model: devices changed - \(self.devices)")
    }
  }
  @Published var users: DeviceActivityFilter.Users? = .all {
    didSet {
      reportLogger.log("📊 Model: users changed to \(self.users?.debugDescription ?? "nil")")
    }
  }

  // Computed property that converts to SegmentInterval
  var segment: DeviceActivityFilter.SegmentInterval {
    let interval = DateInterval(start: from, end: to)
    
    reportLogger.log("🔄 Model: Computing segment for interval \(interval) with segmentation '\(segmentation)'")

    if self.segmentation == "hourly" {
      reportLogger.log("✅ Model: Using hourly segmentation")
      return .hourly(during: interval)
    } else if self.segmentation == "weekly" {
      reportLogger.log("✅ Model: Using weekly segmentation")
      return .weekly(during: interval)
    } else {
      reportLogger.log("✅ Model: Using daily segmentation (default)")
      return .daily(during: interval)
    }
  }

  override init() {
    super.init()
    reportLogger.log("🏗️ DeviceActivityReportViewModel: Initialized (iOS 16.0+)")
  }
}

// Fallback view for iOS 15.x
@available(iOS 15.0, *)
struct DeviceActivityReportFallbackUI: View {
  @ObservedObject var model: DeviceActivityReportViewModelBase

  var body: some View {
    reportLogger.log("🎨 FallbackUI: Rendering fallback view for iOS 15.x")
    
    return VStack {
      Text("Device Activity Reports")
        .font(.headline)
        .padding()
      Text("Requires iOS 16.0 or later")
        .font(.subheadline)
        .foregroundColor(.secondary)
        .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.clear)
    .preferredColorScheme(.dark)
    .onAppear {
      reportLogger.log("👁️ FallbackUI: View appeared")
    }
    .onDisappear {
      reportLogger.log("👁️ FallbackUI: View disappeared")
    }
  }
}

// iOS 16.0+ view with actual DeviceActivityReport
@available(iOS 16.0, *)
struct DeviceActivityReportUI: View {
  @ObservedObject var model: DeviceActivityReportViewModel
  @Environment(\.colorScheme) var colorScheme
  @State private var hasAppeared = false

  var body: some View {
    reportLogger.log("🎨 ReportUI: Rendering DeviceActivityReport view for context '\(model.context)'")
    
    let filter = createFilter()
    reportLogger.log("🔍 ReportUI: Created filter - Apps: \(filter.applications.count), Categories: \(filter.categories.count), Domains: \(filter.webDomains.count)")
    
    return DeviceActivityReport(
      DeviceActivityReport.Context(rawValue: model.context),  // the context of your extension
      filter: filter
    )
    .preferredColorScheme(.dark) // Force dark mode
    .background(Color.clear) // Make background transparent
    .onAppear {
      reportLogger.log("👁️ ReportUI: View appeared for context '\(model.context)'")
      hasAppeared = true
      
      // Store reportStyle in UserDefaults so the extension can access it
      if let reportStyle = model.reportStyle {
        let contextKey = "reportStyle_\(model.context)"
        // Convert to property list compatible format
        let propertyListStyle = convertToPropertyListCompatible(reportStyle)
        userDefaults?.set(propertyListStyle, forKey: contextKey)
        reportLogger.log("💾 ReportUI: Stored reportStyle for context '\(model.context)'")
      }
      
      // Log current state for debugging
      logCurrentState()
    }
    .onDisappear {
      reportLogger.log("👁️ ReportUI: View disappeared for context '\(model.context)'")
      hasAppeared = false
    }
    .onChange(of: model.familyActivitySelection) { _ in
      if hasAppeared {
        reportLogger.log("🔄 ReportUI: familyActivitySelection changed while view is visible")
        logCurrentState()
      }
    }
    .onChange(of: model.from) { _ in
      if hasAppeared {
        reportLogger.log("🔄 ReportUI: from date changed while view is visible")
        logCurrentState()
      }
    }
    .onChange(of: model.to) { _ in
      if hasAppeared {
        reportLogger.log("🔄 ReportUI: to date changed while view is visible")
        logCurrentState()
      }
    }
  }
  
  private func createFilter() -> DeviceActivityFilter {
    if model.users != nil {
      reportLogger.log("🔧 ReportUI: Creating filter with users: \(model.users!)")
      return DeviceActivityFilter(
        segment: model.segment,
        users: model.users!,  // or .children
        devices: model.devices,
        applications: model.familyActivitySelection.applicationTokens,
        categories: model.familyActivitySelection.categoryTokens,
        webDomains: model.familyActivitySelection.webDomainTokens
      )
    } else {
      reportLogger.log("🔧 ReportUI: Creating filter without users")
      return DeviceActivityFilter(
        segment: model.segment,
        devices: model.devices,
        applications: model.familyActivitySelection.applicationTokens,
        categories: model.familyActivitySelection.categoryTokens,
        webDomains: model.familyActivitySelection.webDomainTokens
      )
    }
  }
  
  private func logCurrentState() {
    let hasSelection = !model.familyActivitySelection.applicationTokens.isEmpty || 
                      !model.familyActivitySelection.categoryTokens.isEmpty || 
                      !model.familyActivitySelection.webDomainTokens.isEmpty
    
    let timeInterval = model.to.timeIntervalSince(model.from)
    
    reportLogger.log("🔍 ReportUI: Current State Summary:")
    reportLogger.log("   Context: '\(model.context)'")
    reportLogger.log("   Has Selection: \(hasSelection)")
    reportLogger.log("   Apps: \(model.familyActivitySelection.applicationTokens.count)")
    reportLogger.log("   Categories: \(model.familyActivitySelection.categoryTokens.count)")
    reportLogger.log("   Domains: \(model.familyActivitySelection.webDomainTokens.count)")
    reportLogger.log("   Time Range: \(model.from) to \(model.to)")
    reportLogger.log("   Duration Hours: \(timeInterval / 3600)")
    reportLogger.log("   Segmentation: '\(model.segmentation)'")
    
    // Predict blank view scenarios
    if !hasSelection {
      reportLogger.log("⚠️ ReportUI: BLANK VIEW LIKELY - No apps, categories, or domains selected")
    }
    
    if timeInterval <= 0 {
      reportLogger.log("⚠️ ReportUI: BLANK VIEW LIKELY - Invalid time range")
    }
    
    if timeInterval < 3600 {
      reportLogger.log("⚠️ ReportUI: BLANK VIEW POSSIBLE - Very short time range")
    }
  }
}

// This view will be used as a native component. Make sure to inherit from `ExpoView`
// to apply the proper styling (e.g. border radius and shadows).
@available(iOS 15.0, *)
class DeviceActivityReportView: ExpoView {

  public let model: DeviceActivityReportViewModelBase
  private var contentView: UIHostingController<AnyView>

  required init(appContext: AppContext? = nil) {
    reportLogger.log("🏗️ DeviceActivityReportView: Initializing...")
    
    if #available(iOS 16.0, *) {
      reportLogger.log("✅ DeviceActivityReportView: Using iOS 16.0+ implementation")
      let viewModel = DeviceActivityReportViewModel()
      model = viewModel
      contentView = UIHostingController(
        rootView: AnyView(DeviceActivityReportUI(model: viewModel))
      )
    } else {
      reportLogger.log("⚠️ DeviceActivityReportView: Using iOS 15.x fallback implementation")
      model = DeviceActivityReportViewModelBase()
      contentView = UIHostingController(
        rootView: AnyView(DeviceActivityReportFallbackUI(model: model))
      )
    }

    super.init(appContext: appContext)

    clipsToBounds = true
    contentView.view.backgroundColor = .clear
    contentView.view.isOpaque = false
    contentView.overrideUserInterfaceStyle = .dark
    self.addSubview(contentView.view)
    
    reportLogger.log("✅ DeviceActivityReportView: Initialization complete")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    contentView.view.frame = bounds
    reportLogger.log("📐 DeviceActivityReportView: Layout updated - bounds: \(bounds)")
  }
}
