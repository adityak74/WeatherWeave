//
//  Constants.swift
//  WeatherWeave
//
//  Created by WeatherWeave on 2026-02-05.
//

import Foundation

enum Constants {
    // App Information
    static let appName = "WeatherWeave"
    static let appVersion = "1.0.0"
    static let appBuild = "1"

    // API Endpoints
    static let weatherAPIBaseURL = "https://api.open-meteo.com/v1/forecast"

    // Timing
    static let defaultUpdateInterval: TimeInterval = 1800 // 30 minutes
    static let weatherCacheInterval: TimeInterval = 300 // 5 minutes
    static let imageGenerationTimeout: TimeInterval = 60 // 60 seconds

    // Storage
    static let maxStoredWallpapers = 10
    static let wallpaperDirectoryName = "WeatherWeave/Wallpapers"

    // Image Generation
    static let defaultImageWidth = 3840
    static let defaultImageHeight = 2160
    static let imageFormat = "png"

    // User Defaults Keys
    enum UserDefaultsKeys {
        static let selectedTheme = "selectedTheme"
        static let autoUpdate = "autoUpdate"
        static let updateInterval = "updateInterval"
        static let updateOnWake = "updateOnWake"
        static let showNotifications = "showNotifications"
        static let maxStoredWallpapers = "maxStoredWallpapers"
        static let lastUpdateTime = "lastUpdateTime"
        static let lastWeatherCondition = "lastWeatherCondition"
    }

    // Notifications
    enum NotificationIdentifiers {
        static let wallpaperGenerated = "wallpaperGenerated"
        static let generationFailed = "generationFailed"
    }
}
