import SwiftUI

// Standalone preview app for MostUsedAppsView
// This allows you to iterate quickly on the UI design

struct MostUsedAppsData {
  let appName: String
  let bundleIdentifier: String?
  let duration: TimeInterval
  let categoryName: String?
}

// Copy your AppIconCircle and MostUsedAppsView code here from the main file
// This gives you a fast iteration environment

struct AppIconCircle: View {
  let appName: String
  let bundleIdentifier: String?

  private func iconColor(for identifier: String, appName: String) -> Color {
    let id = (bundleIdentifier?.lowercased() ?? "")
    let name = appName.lowercased()
    
    switch true {
    case id.contains("instagram") || name.contains("instagram"):
      return Color(red: 0.91, green: 0.26, blue: 0.59)
    case id.contains("twitter") || id.contains("x.com") || name.contains("twitter") || name == "x":
      return Color(red: 0.1, green: 0.1, blue: 0.1)
    case id.contains("reddit") || name.contains("reddit"):
      return Color(red: 1.0, green: 0.27, blue: 0.0)
    default:
      let key = bundleIdentifier ?? appName
      let colors: [Color] = [
        Color(red: 0.2, green: 0.6, blue: 1.0),
        Color(red: 0.9, green: 0.3, blue: 0.3),
        Color(red: 0.3, green: 0.8, blue: 0.3),
        Color(red: 0.8, green: 0.6, blue: 0.2)
      ]
      let index = abs(key.hashValue) % colors.count
      return colors[index]
    }
  }

  private func appIcon(for bundleIdentifier: String?, appName: String) -> String {
    let id = (bundleIdentifier?.lowercased() ?? "")
    let name = appName.lowercased()
    
    switch true {
    case id.contains("instagram") || name.contains("instagram"):
      return "camera.fill"
    case id.contains("twitter") || id.contains("x.com") || name.contains("twitter") || name == "x":
      return "x.circle.fill"
    case id.contains("reddit") || name.contains("reddit"):
      return "circle.fill"
    default:
      return "app.fill"
    }
  }

  var body: some View {
    ZStack {
      Circle()
        .fill(iconColor(for: bundleIdentifier ?? appName, appName: appName))
        .frame(width: 36, height: 36)
        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
      
      Image(systemName: appIcon(for: bundleIdentifier, appName: appName))
        .font(.system(size: 18, weight: .medium))
        .foregroundColor(.white)
        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 0.5)
    }
  }
}

struct MostUsedAppsView: View {
  let mostUsedAppsData: [MostUsedAppsData]

  private func formatTotalDuration(_ apps: [MostUsedAppsData]) -> String {
    let totalDuration = apps.reduce(0) { $0 + $1.duration }
    let totalMinutes = Int(totalDuration) / 60
    return "\(totalMinutes)mins"
  }

  var body: some View {
    VStack(spacing: 0) {
      VStack(alignment: .leading, spacing: 0) {
        VStack(alignment: .leading, spacing: 8) {
          HStack {
            Text("Most Used Apps")
              .font(.system(size: 18, weight: .semibold))
              .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 6) {
              Circle()
                .fill(.white.opacity(0.8))
                .frame(width: 4, height: 4)
              Circle()
                .fill(.white.opacity(0.4))
                .frame(width: 4, height: 4)
              Circle()
                .fill(.white.opacity(0.4))
                .frame(width: 4, height: 4)
            }
          }
          
          if !mostUsedAppsData.isEmpty {
            Text("Your peak usage appears to be between 9pm-12am, with social media being your primary focus during these hours.")
              .font(.system(size: 14, weight: .regular))
              .foregroundColor(.white.opacity(0.8))
              .multilineTextAlignment(.leading)
              .lineLimit(nil)
              .fixedSize(horizontal: false, vertical: true)
          }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        
        HStack(alignment: .bottom) {
          if !mostUsedAppsData.isEmpty {
            Text(formatTotalDuration(mostUsedAppsData))
              .font(.system(size: 72, weight: .ultraLight))
              .foregroundColor(.white)
              .monospacedDigit()
              .tracking(-2)
          }
          
          Spacer()
          
          if !mostUsedAppsData.isEmpty {
            HStack(spacing: 8) {
              ForEach(Array(mostUsedAppsData.prefix(3).enumerated()), id: \.offset) { index, appData in
                AppIconCircle(
                  appName: appData.appName,
                  bundleIdentifier: appData.bundleIdentifier
                )
              }
            }
          }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .padding(.top, 12)
      }
      .background(
        RoundedRectangle(cornerRadius: 20)
          .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
          .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
      )
      .padding(.horizontal, 16)
      
      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(Color.black)
    .preferredColorScheme(.dark)
  }
}

struct ContentView: View {
  @State private var selectedVariant = 0
  let variants = ["With Data", "Empty State", "Single App", "Icons Only"]
  
  let sampleData: [MostUsedAppsData] = [
    MostUsedAppsData(
      appName: "Instagram",
      bundleIdentifier: "com.burbn.instagram",
      duration: 3600,
      categoryName: "Social Networking"
    ),
    MostUsedAppsData(
      appName: "X",
      bundleIdentifier: "com.twitter.twitter",
      duration: 2400,
      categoryName: "Social Networking"
    ),
    MostUsedAppsData(
      appName: "Reddit",
      bundleIdentifier: "com.reddit.reddit",
      duration: 1800,
      categoryName: "Social Networking"
    )
  ]
  
  var body: some View {
    VStack {
      Picker("Variant", selection: $selectedVariant) {
        ForEach(0..<variants.count, id: \.self) { index in
          Text(variants[index]).tag(index)
        }
      }
      .pickerStyle(SegmentedPickerStyle())
      .padding()
      
      switch selectedVariant {
      case 0:
        MostUsedAppsView(mostUsedAppsData: sampleData)
      case 1:
        MostUsedAppsView(mostUsedAppsData: [])
      case 2:
        MostUsedAppsView(mostUsedAppsData: [sampleData[0]])
      case 3:
        HStack(spacing: 16) {
          ForEach(Array(sampleData.enumerated()), id: \.offset) { _, appData in
            VStack {
              AppIconCircle(
                appName: appData.appName,
                bundleIdentifier: appData.bundleIdentifier
              )
              Text(appData.appName)
                .font(.caption)
                .foregroundColor(.white)
            }
          }
        }
        .padding()
        .background(Color.black)
      default:
        MostUsedAppsView(mostUsedAppsData: sampleData)
      }
    }
    .background(Color.black)
  }
}

// Remove @main since this is just a content view file
// In a real app, you'd have a separate App.swift file with @main 