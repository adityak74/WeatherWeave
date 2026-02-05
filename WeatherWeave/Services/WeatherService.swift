//
//  WeatherService.swift
//  WeatherWeave
//
//  Created by WeatherWeave on 2026-02-05.
//

import Foundation
import CoreLocation
import Combine

protocol WeatherServiceProtocol {
    func fetchWeather(for location: CLLocation) async throws -> WeatherCondition
}

class WeatherService: WeatherServiceProtocol {
    private let baseURL = "https://api.open-meteo.com/v1/forecast"
    private var lastFetchTime: Date?
    private var cachedWeather: WeatherCondition?
    private let cacheInterval: TimeInterval = 300 // 5 minutes

    func fetchWeather(for location: CLLocation) async throws -> WeatherCondition {
        // Check cache
        if let cached = cachedWeather,
           let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < cacheInterval {
            return cached
        }

        // Build URL
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: "\(location.coordinate.latitude)"),
            URLQueryItem(name: "longitude", value: "\(location.coordinate.longitude)"),
            URLQueryItem(name: "current", value: "temperature_2m,precipitation,cloud_cover,weather_code"),
            URLQueryItem(name: "temperature_unit", value: "fahrenheit"),
            URLQueryItem(name: "timezone", value: "auto")
        ]

        guard let url = components?.url else {
            throw WeatherError.invalidURL
        }

        // Fetch data
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw WeatherError.invalidResponse
        }

        // Parse response
        let decoder = JSONDecoder()
        let weatherResponse = try decoder.decode(OpenMeteoResponse.self, from: data)

        let condition = WeatherCondition(
            temperature: weatherResponse.current.temperature_2m,
            precipitation: weatherResponse.current.precipitation,
            cloudCover: weatherResponse.current.cloud_cover,
            weatherCode: weatherResponse.current.weather_code,
            timestamp: Date()
        )

        // Cache result
        cachedWeather = condition
        lastFetchTime = Date()

        return condition
    }
}

// MARK: - API Response Models
struct OpenMeteoResponse: Codable {
    let current: CurrentWeather
}

struct CurrentWeather: Codable {
    let temperature_2m: Double
    let precipitation: Double
    let cloud_cover: Int
    let weather_code: Int
}

// MARK: - Errors
enum WeatherError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid weather API URL"
        case .invalidResponse:
            return "Invalid response from weather service"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
