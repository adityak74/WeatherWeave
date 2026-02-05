//
//  WeatherCondition.swift
//  WeatherWeave
//
//  Created by WeatherWeave on 2026-02-05.
//

import Foundation

struct WeatherCondition: Codable, Equatable {
    let temperature: Double
    let precipitation: Double
    let cloudCover: Int
    let weatherCode: Int
    let timestamp: Date

    var primaryCondition: WeatherType {
        // WMO Weather interpretation codes
        // https://open-meteo.com/en/docs
        switch weatherCode {
        case 0:
            return .clear
        case 1, 2:
            return .cloudy
        case 3:
            return .cloudy
        case 45, 48:
            return .foggy
        case 51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82:
            return .rainy
        case 71, 73, 75, 77, 85, 86:
            return .snowy
        case 95, 96, 99:
            return .thunderstorm
        default:
            return cloudCover > 50 ? .cloudy : .clear
        }
    }

    var description: String {
        switch primaryCondition {
        case .clear:
            return "Clear"
        case .cloudy:
            return "Cloudy"
        case .rainy:
            return "Rainy"
        case .snowy:
            return "Snowy"
        case .thunderstorm:
            return "Thunderstorm"
        case .foggy:
            return "Foggy"
        }
    }

    var emoji: String {
        switch primaryCondition {
        case .clear:
            return "☀️"
        case .cloudy:
            return "☁️"
        case .rainy:
            return "🌧️"
        case .snowy:
            return "❄️"
        case .thunderstorm:
            return "⛈️"
        case .foggy:
            return "🌫️"
        }
    }
}

// MARK: - Weather Type
enum WeatherType: String, Codable {
    case clear
    case cloudy
    case rainy
    case snowy
    case thunderstorm
    case foggy
}
