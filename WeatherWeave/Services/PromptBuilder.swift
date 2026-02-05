//
//  PromptBuilder.swift
//  WeatherWeave
//
//  Created by WeatherWeave on 2026-02-05.
//

import Foundation

class PromptBuilder {
    func buildPrompt(for weather: WeatherCondition, theme: Theme, timeOfDay: TimeOfDay) -> String {
        let basePrompt = buildBasePrompt(for: weather, timeOfDay: timeOfDay)
        let themeModifier = theme.modifier

        return "\(basePrompt), \(themeModifier), ultra-detailed, 8K, high quality wallpaper"
    }

    private func buildBasePrompt(for weather: WeatherCondition, timeOfDay: TimeOfDay) -> String {
        let condition = weather.primaryCondition

        switch (condition, timeOfDay) {
        case (.clear, .sunrise):
            return "Golden sunrise landscape, warm orange and pink sky, dramatic clouds, peaceful atmosphere"
        case (.clear, .day):
            return "Bright sunny landscape, clear blue sky, vibrant colors, beautiful scenery"
        case (.clear, .sunset):
            return "Golden hour sunset, warm sunlight, dramatic clouds, rich colors"
        case (.clear, .night):
            return "Clear starry night sky, milky way, celestial beauty, peaceful darkness"

        case (.cloudy, .day):
            return "Overcast sky, soft diffused light, muted colors, calm atmosphere"
        case (.cloudy, .night):
            return "Cloudy night sky, moody atmosphere, soft moonlight breaking through clouds"
        case (.cloudy, _):
            return "Minimalist foggy landscape, soft light, muted palette, serene"

        case (.rainy, .day):
            return "Rain-soaked landscape, wet reflections, gray skies, atmospheric mood"
        case (.rainy, .night):
            return "Rainy night cityscape, neon reflections on wet streets, moody atmosphere"
        case (.rainy, _):
            return "Rainy scene, water droplets, atmospheric precipitation, moody lighting"

        case (.snowy, .day):
            return "Winter wonderland, snow-covered landscape, crisp white snow, bright daylight"
        case (.snowy, .night):
            return "Snowy night scene, moonlit snow, peaceful winter atmosphere, soft blue tones"
        case (.snowy, _):
            return "Winter landscape, snow-covered trees and ground, serene cold atmosphere"

        case (.thunderstorm, .day):
            return "Dramatic storm clouds, lightning in distance, turbulent atmosphere, powerful weather"
        case (.thunderstorm, .night):
            return "Lightning storm at night, dramatic electrical discharge, dark stormy sky"
        case (.thunderstorm, _):
            return "Thunderstorm scene, dramatic clouds, lightning, powerful atmospheric conditions"

        case (.foggy, _):
            return "Misty fog rolling over landscape, mysterious atmosphere, soft diffused light, minimal visibility"
        }
    }
}

// MARK: - Time of Day
enum TimeOfDay {
    case sunrise
    case day
    case sunset
    case night

    static func current() -> TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<7:
            return .sunrise
        case 7..<17:
            return .day
        case 17..<19:
            return .sunset
        default:
            return .night
        }
    }
}
