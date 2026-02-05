//
//  UserDefaults+Extensions.swift
//  WeatherWeave
//
//  Created by WeatherWeave on 2026-02-05.
//

import Foundation

extension UserDefaults {
    // MARK: - Theme
    var selectedTheme: Theme {
        get {
            guard let rawValue = string(forKey: Constants.UserDefaultsKeys.selectedTheme),
                  let theme = Theme(rawValue: rawValue) else {
                return .nature
            }
            return theme
        }
        set {
            set(newValue.rawValue, forKey: Constants.UserDefaultsKeys.selectedTheme)
        }
    }

    // MARK: - Auto Update
    var autoUpdate: Bool {
        get {
            if object(forKey: Constants.UserDefaultsKeys.autoUpdate) == nil {
                return true // Default to true
            }
            return bool(forKey: Constants.UserDefaultsKeys.autoUpdate)
        }
        set {
            set(newValue, forKey: Constants.UserDefaultsKeys.autoUpdate)
        }
    }

    // MARK: - Update Interval
    var updateInterval: TimeInterval {
        get {
            let interval = double(forKey: Constants.UserDefaultsKeys.updateInterval)
            return interval > 0 ? interval : Constants.defaultUpdateInterval
        }
        set {
            set(newValue, forKey: Constants.UserDefaultsKeys.updateInterval)
        }
    }

    // MARK: - Update on Wake
    var updateOnWake: Bool {
        get {
            if object(forKey: Constants.UserDefaultsKeys.updateOnWake) == nil {
                return true // Default to true
            }
            return bool(forKey: Constants.UserDefaultsKeys.updateOnWake)
        }
        set {
            set(newValue, forKey: Constants.UserDefaultsKeys.updateOnWake)
        }
    }

    // MARK: - Show Notifications
    var showNotifications: Bool {
        get {
            bool(forKey: Constants.UserDefaultsKeys.showNotifications)
        }
        set {
            set(newValue, forKey: Constants.UserDefaultsKeys.showNotifications)
        }
    }

    // MARK: - Max Stored Wallpapers
    var maxStoredWallpapers: Int {
        get {
            let count = integer(forKey: Constants.UserDefaultsKeys.maxStoredWallpapers)
            return count > 0 ? count : Constants.maxStoredWallpapers
        }
        set {
            set(newValue, forKey: Constants.UserDefaultsKeys.maxStoredWallpapers)
        }
    }

    // MARK: - Last Update Time
    var lastUpdateTime: Date? {
        get {
            object(forKey: Constants.UserDefaultsKeys.lastUpdateTime) as? Date
        }
        set {
            set(newValue, forKey: Constants.UserDefaultsKeys.lastUpdateTime)
        }
    }

    // MARK: - Last Weather Condition
    func saveLastWeatherCondition(_ condition: WeatherCondition) {
        if let encoded = try? JSONEncoder().encode(condition) {
            set(encoded, forKey: Constants.UserDefaultsKeys.lastWeatherCondition)
        }
    }

    func loadLastWeatherCondition() -> WeatherCondition? {
        guard let data = data(forKey: Constants.UserDefaultsKeys.lastWeatherCondition),
              let condition = try? JSONDecoder().decode(WeatherCondition.self, from: data) else {
            return nil
        }
        return condition
    }
}
