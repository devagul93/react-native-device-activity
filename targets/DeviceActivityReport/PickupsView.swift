//
//  PickupsView.swift
//  DeviceActivityReport
//
//  Created by Assistant on 2024-12-19.
//

import SwiftUI

@available(iOS 16.0, *)
struct PickupsView: View {
  let appPickupData: [AppPickupData]

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Header
      HStack {
        Text("App Pickups")
          .font(.title2)
          .fontWeight(.semibold)
        Spacer()
        Text("Today")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      .padding(.horizontal)

      if appPickupData.isEmpty {
        // Empty state
        VStack(spacing: 8) {
          Image(systemName: "iphone.slash")
            .font(.system(size: 40))
            .foregroundColor(.secondary)
          Text("No pickups recorded")
            .font(.headline)
            .foregroundColor(.secondary)
          Text("App pickup data will appear here when available")
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .padding()
      } else {
        // Total pickups summary
        let totalPickups = appPickupData.reduce(0) { $0 + $1.numberOfPickups }
        
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text("Total Pickups")
              .font(.caption)
              .foregroundColor(.secondary)
            Text("\(totalPickups)")
              .font(.title)
              .fontWeight(.bold)
              .foregroundColor(.primary)
          }
          Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)

        // App list
        ScrollView {
          LazyVStack(spacing: 8) {
            ForEach(Array(appPickupData.enumerated()), id: \.offset) { index, appData in
              PickupRowView(
                appData: appData,
                rank: index + 1
              )
            }
          }
          .padding(.horizontal)
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(Color(.systemBackground))
  }
}

@available(iOS 16.0, *)
struct PickupRowView: View {
  let appData: AppPickupData
  let rank: Int

  private var formattedDuration: String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute]
    formatter.unitsStyle = .abbreviated
    formatter.zeroFormattingBehavior = .dropAll
    return formatter.string(from: appData.totalDuration) ?? "0m"
  }

  var body: some View {
    HStack(spacing: 12) {
      // Rank indicator
      Text("\(rank)")
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(.secondary)
        .frame(width: 20, alignment: .leading)

      // App info
      VStack(alignment: .leading, spacing: 2) {
        Text(appData.appName)
          .font(.body)
          .fontWeight(.medium)
          .lineLimit(1)
        
        Text(formattedDuration)
          .font(.caption)
          .foregroundColor(.secondary)
      }

      Spacer()

      // Pickup count
      VStack(alignment: .trailing, spacing: 2) {
        Text("\(appData.numberOfPickups)")
          .font(.title3)
          .fontWeight(.semibold)
          .foregroundColor(.primary)
        
        Text(appData.numberOfPickups == 1 ? "pickup" : "pickups")
          .font(.caption2)
          .foregroundColor(.secondary)
      }
    }
    .padding(.vertical, 8)
    .padding(.horizontal, 12)
    .background(Color(.systemGray6))
    .cornerRadius(8)
  }
}

@available(iOS 16.0, *)
struct PickupsView_Previews: PreviewProvider {
  static var previews: some View {
    PickupsView(appPickupData: [
      AppPickupData(appName: "Instagram", numberOfPickups: 25, totalDuration: 3600),
      AppPickupData(appName: "Messages", numberOfPickups: 18, totalDuration: 1800),
      AppPickupData(appName: "Safari", numberOfPickups: 12, totalDuration: 2400),
    ])
  }
} 