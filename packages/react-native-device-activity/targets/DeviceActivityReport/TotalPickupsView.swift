//
//  TotalPickupsView.swift
//  DeviceActivityReport
//
//  Created by Assistant on 2024-12-19.
//

import SwiftUI

@available(iOS 16.0, *)
struct TotalPickupsView: View {
  let totalPickups: Int

  var body: some View {
    Text("\(totalPickups)")
      .font(.system(size: 48, weight: .bold, design: .rounded))
      .foregroundColor(.primary)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color(.systemBackground))
  }
}

@available(iOS 16.0, *)
struct TotalPickupsView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      TotalPickupsView(totalPickups: 42)
        .previewDisplayName("42 Pickups")
      
      TotalPickupsView(totalPickups: 0)
        .previewDisplayName("0 Pickups")
      
      TotalPickupsView(totalPickups: 1)
        .previewDisplayName("1 Pickup")
    }
  }
} 