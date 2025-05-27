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

  // Get reportStyle from UserDefaults
  private var reportStyle: [String: Any]? {
    let contextKey = "reportStyle_Total Pickups"
    return userDefaults?.dictionary(forKey: contextKey)
  }

  var body: some View {
    Text("\(totalPickups)")
      .font(getFont())
      .foregroundColor(getTextColor())
      .multilineTextAlignment(getTextAlignment())
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: getFrameAlignment())
      .background(getBackgroundColor())
  }

  private func getFont() -> Font {
    let fontSize = reportStyle?["fontSize"] as? Double ?? 48.0
    let fontWeight = getFontWeight()
    let fontDesign = getFontDesign()

    return .system(size: fontSize, weight: fontWeight, design: fontDesign)
  }

  private func getFontWeight() -> Font.Weight {
    guard let weightString = reportStyle?["fontWeight"] as? String else {
      return .bold
    }

    switch weightString {
    case "ultraLight": return .ultraLight
    case "thin": return .thin
    case "light": return .light
    case "regular": return .regular
    case "medium": return .medium
    case "semibold": return .semibold
    case "bold": return .bold
    case "heavy": return .heavy
    case "black": return .black
    default: return .bold
    }
  }

  private func getFontDesign() -> Font.Design {
    guard let designString = reportStyle?["fontDesign"] as? String else {
      return .rounded
    }

    switch designString {
    case "default": return .default
    case "rounded": return .rounded
    case "monospaced": return .monospaced
    case "serif": return .serif
    default: return .rounded
    }
  }

  private func getTextColor() -> Color {
    guard let colorDict = reportStyle?["textColor"] as? [String: Any],
      let red = colorDict["red"] as? Double,
      let green = colorDict["green"] as? Double,
      let blue = colorDict["blue"] as? Double
    else {
      return .primary
    }

    let alpha = colorDict["alpha"] as? Double ?? 1.0
    return Color(.sRGB, red: red / 255.0, green: green / 255.0, blue: blue / 255.0, opacity: alpha)
  }

  private func getTextAlignment() -> TextAlignment {
    guard let alignmentString = reportStyle?["textAlignment"] as? String else {
      return .center
    }

    switch alignmentString {
    case "leading": return .leading
    case "center": return .center
    case "trailing": return .trailing
    default: return .center
    }
  }

  private func getFrameAlignment() -> Alignment {
    guard let alignmentString = reportStyle?["textAlignment"] as? String else {
      return .center
    }

    switch alignmentString {
    case "leading": return .leading
    case "center": return .center
    case "trailing": return .trailing
    default: return .center
    }
  }

  private func getBackgroundColor() -> Color {
    // Check if backgroundColor is explicitly set to null or has alpha 0 for transparency
    if let backgroundColorDict = reportStyle?["backgroundColor"] as? [String: Any] {
      if let red = backgroundColorDict["red"] as? Double,
        let green = backgroundColorDict["green"] as? Double,
        let blue = backgroundColorDict["blue"] as? Double {
        let alpha = backgroundColorDict["alpha"] as? Double ?? 1.0
        return Color(
          .sRGB, red: red / 255.0, green: green / 255.0, blue: blue / 255.0, opacity: alpha)
      }
    }

    // Default to transparent background so React Native background shows through
    return Color.clear
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

      TotalPickupsView(totalPickups: 25)
        .previewDisplayName("25 Pickups")
    }
  }
}
