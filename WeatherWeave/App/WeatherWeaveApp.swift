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

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
