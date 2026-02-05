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

    @StateObject private var modelConverter = OnDeviceModelConverter()
    @State private var showConversionError = false
    @State private var conversionError: String?

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

            Section("Core ML Model") {
                LabeledContent("Model", value: modelConverter.modelName)
                LabeledContent("Status", value: modelConverter.state.description)

                switch modelConverter.state {
                case .downloading(let progress):
                    ProgressView(value: progress) {
                        Text("Downloading checkpoint from Hugging Face...")
                    } currentValueLabel: {
                        Text("\(Int(progress * 100))%")
                    }

                case .converting(let progress):
                    ProgressView(value: progress) {
                        Text("Converting to Core ML (this may take 2-3 minutes)...")
                    } currentValueLabel: {
                        Text("\(Int(progress * 100))%")
                    }

                case .error(let message):
                    Text("Error: \(message)")
                        .font(.caption)
                        .foregroundColor(.red)

                default:
                    EmptyView()
                }

                Button {
                    Task {
                        do {
                            try await modelConverter.downloadAndConvert()
                        } catch {
                            conversionError = error.localizedDescription
                            showConversionError = true
                        }
                    }
                } label: {
                    Text(buttonLabel)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isButtonDisabled)

                if modelConverter.state == .completed {
                    Text("✅ Model ready! Generate wallpapers at <1 second.")
                        .font(.caption)
                        .foregroundColor(.green)

                    Text("First-time setup: Complete! All future generations will be instant.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                if modelConverter.state == .notStarted {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("First Time Setup:")
                            .font(.caption)
                            .fontWeight(.semibold)

                        Text("• Download: ~5GB (2-5 minutes)")
                        Text("• Convert: 2-3 minutes (one-time)")
                        Text("• Total: ~5-8 minutes")
                        Text("• After: <1 second generation forever!")
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
            }

            Section("About") {
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("Build", value: "1")

                Link("View on GitHub", destination: URL(string: "https://github.com/adityak74/WeatherWeave")!)
            }
        }
        .formStyle(.grouped)
        .frame(width: 500, height: 600)
        .navigationTitle("Settings")
        .alert("Conversion Error", isPresented: $showConversionError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(conversionError ?? "Unknown error occurred during conversion")
        }
    }

    private var buttonLabel: String {
        switch modelConverter.state {
        case .downloading: return "Downloading..."
        case .converting: return "Converting..."
        case .completed: return "Model Ready"
        case .error: return "Retry Download"
        case .notStarted: return "Download & Convert Model"
        }
    }

    private var isButtonDisabled: Bool {
        switch modelConverter.state {
        case .downloading, .converting, .completed:
            return true
        case .notStarted, .error:
            return false
        }
    }

    private func cleanupWallpapers() {
        // TODO: Implement cleanup logic
    }
}

#Preview {
    SettingsView()
}
