//
//  GeneratedWallpaper.swift
//  WeatherWeave
//
//  Created by WeatherWeave on 2026-02-05.
//

import Foundation

struct GeneratedWallpaper: Codable, Identifiable, Equatable {
    let id: UUID
    let imageURL: URL
    let weather: WeatherCondition
    let theme: Theme
    let timestamp: Date

    var displayName: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return "\(weather.description) - \(theme.displayName) - \(formatter.string(from: timestamp))"
    }

    var fileSize: String {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: imageURL.path),
              let size = attributes[.size] as? Int64 else {
            return "Unknown"
        }

        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}
