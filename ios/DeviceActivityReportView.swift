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
    .background(Color(.systemBackground))
  }
}

// iOS 16.0+ view with actual DeviceActivityReport
@available(iOS 16.0, *)
struct DeviceActivityReportUI: View {
  @ObservedObject var model: DeviceActivityReportViewModel

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
    .onAppear {
      // Store reportStyle in UserDefaults so the extension can access it
      if let reportStyle = model.reportStyle {
        let contextKey = "reportStyle_\(model.context)"
        userDefaults?.set(reportStyle, forKey: contextKey)
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
    self.addSubview(contentView.view)
  }

  override func layoutSubviews() {
    contentView.view.frame = bounds
  }
}
