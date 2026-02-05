//
//  WeatherWeaveApp.swift
//  WeatherWeave
//
//  Created by WeatherWeave on 2026-02-05.
//

import SwiftUI

@main
struct WeatherWeaveApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var aiModelManager = AIModelManager()

    var body: some Scene {
        // The main menu bar item
        MenuBarExtra("WeatherWeave", systemImage: "cloud.fill") {
            MenuBarView()
                .environmentObject(aiModelManager)
        }
        .menuBarExtraStyle(.window) // Or .menu if you prefer a traditional menu

        // The settings window
        Settings {
            SettingsView()
                .environmentObject(aiModelManager)
        }
    }
}
