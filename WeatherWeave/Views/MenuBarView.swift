//
//  MenuBarView.swift
//  WeatherWeave
//
//  Created by WeatherWeave on 2026-02-05.
//

import SwiftUI

struct MenuBarView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var wallpaperManager = WallpaperManager()
    @State private var selectedTheme: Theme = .nature
    @State private var isGenerating = false
    @State private var currentWeather: WeatherCondition?
    @State private var showSettings = false
    @State private var showGallery = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            headerSection

            Divider()

            // Weather Info
            weatherSection

            Divider()

            // Theme Selector
            themeSection

            Divider()

            // Actions
            actionsSection

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
        }
        .padding()
        .frame(width: 300)
        .onAppear {
            setupLocationManager()
        }
    }

    private var headerSection: some View {
        HStack {
            Image(systemName: "cloud.sun.fill")
                .font(.title2)
                .foregroundColor(.blue)
            Text("WeatherWeave")
                .font(.headline)
            Spacer()
        }
    }

    private var weatherSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let weather = currentWeather {
                HStack {
                    Text(weather.emoji)
                    Text(weather.description)
                        .font(.subheadline)
                    Spacer()
                    Text("\(Int(weather.temperature))°F")
                        .font(.subheadline)
                }
                Text(locationManager.cityName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Fetching weather...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Theme")
                .font(.caption)
                .foregroundColor(.secondary)

            Picker("Theme", selection: $selectedTheme) {
                ForEach(Theme.allCases, id: \.self) { theme in
                    Text("\(theme.icon) \(theme.displayName)")
                        .tag(theme)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 8) {
            Button(action: generateWallpaper) {
                HStack {
                    if isGenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "sparkles")
                    }
                    Text(isGenerating ? "Generating..." : "Generate Wallpaper")
                }
                .frame(maxWidth: .infinity)
            }
            .disabled(isGenerating || currentWeather == nil)
            .buttonStyle(.borderedProminent)

            HStack {
                Button("Gallery") {
                    showGallery = true
                }
                .buttonStyle(.bordered)

                Button("Settings") {
                    showSettings = true
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private func setupLocationManager() {
        locationManager.requestAuthorization()

        // Observe location updates
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            if locationManager.authorizationStatus == .authorized ||
               locationManager.authorizationStatus == .authorizedAlways {
                fetchWeather()
            }
        }
    }

    private func fetchWeather() {
        guard let location = locationManager.location else { return }

        Task {
            do {
                let weatherService = WeatherService()
                currentWeather = try await weatherService.fetchWeather(for: location)
            } catch {
                errorMessage = "Failed to fetch weather: \(error.localizedDescription)"
            }
        }
    }

    private func generateWallpaper() {
        guard let weather = currentWeather else { return }

        isGenerating = true
        errorMessage = nil

        Task {
            do {
                let promptBuilder = PromptBuilder()
                let timeOfDay = TimeOfDay.current()
                let prompt = promptBuilder.buildPrompt(for: weather, theme: selectedTheme, timeOfDay: timeOfDay)

                let outputPath = NSTemporaryDirectory() + "wallpaper_\(Date().timeIntervalSince1970).png"
                let imageGenerator = ImageGenerator()
                let imageURL = try await imageGenerator.generateImage(prompt: prompt, outputPath: outputPath)

                let wallpaper = try wallpaperManager.saveWallpaper(imageURL: imageURL, weather: weather, theme: selectedTheme)
                try wallpaperManager.setAsWallpaper(wallpaper)

                isGenerating = false
            } catch {
                errorMessage = "Failed to generate wallpaper: \(error.localizedDescription)"
                isGenerating = false
            }
        }
    }
}

#Preview {
    MenuBarView()
}
