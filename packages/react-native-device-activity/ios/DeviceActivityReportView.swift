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
  @Published var familyActivitySelection = FamilyActivitySelection()
  @Published var context = "Total Activity"
  @Published var from = Date.distantPast
  @Published var to = Date.distantPast
  @Published var segmentation: String = "daily"
  @Published var reportStyle: [String: Any]?

  init() {}
}

// iOS 16.0+ specific view model with DeviceActivityFilter support
@available(iOS 16.0, *)
class DeviceActivityReportViewModel: DeviceActivityReportViewModelBase {
  @Published var devices = DeviceActivityFilter.Devices(Set<DeviceActivityData.Device.Model>())
  @Published var users: DeviceActivityFilter.Users? = .all

  // Computed property that converts to SegmentInterval
  var segment: DeviceActivityFilter.SegmentInterval {
    let interval = DateInterval(start: from, end: to)

    if self.segmentation == "hourly" {
      return .hourly(during: interval)
    } else if self.segmentation == "weekly" {
      return .weekly(during: interval)
    } else {
      return .daily(during: interval)
    }
  }

  override init() {
    super.init()
  }
}

// Fallback view for iOS 15.x
@available(iOS 15.0, *)
struct DeviceActivityReportFallbackUI: View {
  @ObservedObject var model: DeviceActivityReportViewModelBase

  var body: some View {
    VStack {
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
  }
}

// iOS 16.0+ view with actual DeviceActivityReport
@available(iOS 16.0, *)
struct DeviceActivityReportUI: View {
  @ObservedObject var model: DeviceActivityReportViewModel
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    DeviceActivityReport(
      DeviceActivityReport.Context(rawValue: model.context),  // the context of your extension
      filter: model.users != nil
        ? DeviceActivityFilter(
          segment: model.segment,
          users: model.users!,  // or .children
          devices: model.devices,
          applications: model.familyActivitySelection.applicationTokens,
          categories: model.familyActivitySelection.categoryTokens,
          webDomains: model.familyActivitySelection.webDomainTokens
            // you can decide which kind of data to show - apps, categories, and/or web domains
        )
        : DeviceActivityFilter(
          segment: model.segment,
          devices: model.devices,
          applications: model.familyActivitySelection.applicationTokens,
          categories: model.familyActivitySelection.categoryTokens,
          webDomains: model.familyActivitySelection.webDomainTokens
            // you can decide which kind of data to show - apps, categories, and/or web domains
        )
    )
    .preferredColorScheme(.dark)  // Force dark mode
    .background(Color.clear)  // Make background transparent
    .onAppear {
      // Store reportStyle in UserDefaults so the extension can access it
      if let reportStyle = model.reportStyle {
        let contextKey = "reportStyle_\(model.context)"
        // Convert to property list compatible format
        let propertyListStyle = convertToPropertyListCompatible(reportStyle)
        userDefaults?.set(propertyListStyle, forKey: contextKey)
      }
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
    if #available(iOS 16.0, *) {
      let viewModel = DeviceActivityReportViewModel()
      model = viewModel
      contentView = UIHostingController(
        rootView: AnyView(DeviceActivityReportUI(model: viewModel))
      )
    } else {
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

    // Configure for better touch pass-through and parent scrolling
    contentView.view.isUserInteractionEnabled = true
    self.isUserInteractionEnabled = true

    // For contexts that need scrolling pass-through, disable user interaction
    if #available(iOS 16.0, *), let viewModel = model as? DeviceActivityReportViewModel {
      if viewModel.context == "Most Used Apps" || viewModel.context == "App List" {
        contentView.view.isUserInteractionEnabled = false
      }
    } else if model.context == "Most Used Apps" || model.context == "App List" {
      contentView.view.isUserInteractionEnabled = false
    }

    self.addSubview(contentView.view)
  }

  override func layoutSubviews() {
    contentView.view.frame = bounds
  }

  // Override to allow touch events to pass through when not handled by the content
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    // For contexts like "Most Used Apps" and "App List", always pass touches through
    // to enable parent ScrollView scrolling
    if model.context == "Most Used Apps" || model.context == "App List" {
      return nil
    }

    let hitView = super.hitTest(point, with: event)

    // If the hit view is this view itself (not a subview), return nil to pass touch through
    if hitView == self {
      return nil
    }

    // For other DeviceActivityReport content, be more selective
    if let hitView = hitView {
      // Check if we hit the SwiftUI hosting view or its content
      if hitView == contentView.view || hitView.isDescendant(of: contentView.view) {
        // Check if it's an interactive element
        let viewDescription = String(describing: type(of: hitView))

        // Don't pass through touches for clearly interactive elements
        if viewDescription.contains("Button") || viewDescription.contains("TextField")
          || viewDescription.contains("Toggle") || viewDescription.contains("Stepper")
          || viewDescription.contains("Slider") {
          return hitView
        }

        // For non-interactive content, pass through to enable parent scrolling
        return nil
      }
    }

    return hitView
  }
}
