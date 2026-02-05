//
//  SettingsView.swift
//  WeatherWeave
//
//  Created by WeatherWeave on 2026-02-05.
//

import SwiftUI
import Combine

struct SettingsView: View {
    @AppStorage("updateInterval") private var updateInterval: Double = 30.0
    @AppStorage("autoUpdate") private var autoUpdate: Bool = true
    @AppStorage("updateOnWake") private var updateOnWake: Bool = true
    @AppStorage("maxStoredWallpapers") private var maxStoredWallpapers: Int = 10
    @AppStorage("showNotifications") private var showNotifications: Bool = false

    @EnvironmentObject var aiModelManager: AIModelManager

    var body: some View {
        Form {
            Section("Automation") {
                Toggle("Auto-update wallpaper", isOn: $autoUpdate)
                    .help("Automatically generate new wallpapers based on weather changes")

                HStack {
                    Text("Update interval")
                    Spacer()
                    Text("\(Int(updateInterval)) min")
                        .foregroundColor(.secondary)
                }
                Slider(value: $updateInterval, in: 15...120, step: 15)
                    .disabled(!autoUpdate)

                Toggle("Update on wake", isOn: $updateOnWake)
                    .help("Generate new wallpaper when computer wakes from sleep")
            }

            Section("Notifications") {
                Toggle("Show notifications", isOn: $showNotifications)
                    .help("Display notifications when new wallpapers are generated")
            }

            Section("Storage") {
                HStack {
                    Text("Keep last")
                    Spacer()
                    Text("\(maxStoredWallpapers) wallpapers")
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(
                    get: { Double(maxStoredWallpapers) },
                    set: { maxStoredWallpapers = Int($0) }
                ), in: 5...50, step: 5)

                Button("Clean up old wallpapers now") {
                    cleanupWallpapers()
                }
                .buttonStyle(.bordered)
            }

            Section("AI Models") {
                LabeledContent("Model", value: aiModelManager.modelName)
                LabeledContent("Status", value: aiModelManager.modelStatus.rawValue)

                if aiModelManager.modelStatus == .downloading {
                    ProgressView {
                        Text("Downloading model... This may take several minutes.")
                    }
                    .progressViewStyle(.linear)
                }

                Button {
                    if aiModelManager.modelStatus == .downloading {
                        // TODO: Implement cancel download functionality
                    } else {
                        aiModelManager.downloadModel()
                    }
                } label: {
                    Text(aiModelManager.modelStatus == .downloading ? "Downloading..." : "Download AI Model")
                }
                .buttonStyle(.borderedProminent)
                .disabled(aiModelManager.modelStatus == .downloaded || aiModelManager.modelStatus == .downloading)
            }

            Section("About") {
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("Build", value: "1")

                Link("View on GitHub", destination: URL(string: "https://github.com/adityak74/WeatherWeave")!)
            }
        }
        .formStyle(.grouped)
        .frame(width: 450, height: 500) // Increased height to accommodate new section
        .navigationTitle("Settings")
    }

    private func cleanupWallpapers() {
        // TODO: Implement cleanup logic
    }
}

#Preview {
    SettingsView()
        .environmentObject(AIModelManager()) // Provide for preview
}
