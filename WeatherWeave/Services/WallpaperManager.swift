//
//  WallpaperManager.swift
//  WeatherWeave
//
//  Created by WeatherWeave on 2026-02-05.
//

import Foundation
import AppKit
import Combine

class WallpaperManager: ObservableObject {
    @Published var currentWallpaper: GeneratedWallpaper?
    @Published var wallpaperHistory: [GeneratedWallpaper] = []

    private let storageDirectory: URL
    private let appleScriptRunner: AppleScriptRunner

    init() {
        // Setup storage directory
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        storageDirectory = appSupport.appendingPathComponent("WeatherWeave/Wallpapers", isDirectory: true)

        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: storageDirectory, withIntermediateDirectories: true)

        appleScriptRunner = AppleScriptRunner()

        loadHistory()
    }

    func saveWallpaper(imageURL: URL, weather: WeatherCondition, theme: Theme) throws -> GeneratedWallpaper {
        let filename = "wallpaper_\(Date().timeIntervalSince1970).png"
        let destination = storageDirectory.appendingPathComponent(filename)

        try FileManager.default.copyItem(at: imageURL, to: destination)

        let wallpaper = GeneratedWallpaper(
            id: UUID(),
            imageURL: destination,
            weather: weather,
            theme: theme,
            timestamp: Date()
        )

        wallpaperHistory.insert(wallpaper, at: 0)
        currentWallpaper = wallpaper
        saveHistory()

        return wallpaper
    }

    func setAsWallpaper(_ wallpaper: GeneratedWallpaper) throws {
        let screens = NSScreen.screens

        for screen in screens {
            try appleScriptRunner.setWallpaper(imagePath: wallpaper.imageURL.path, for: screen)
        }

        currentWallpaper = wallpaper
    }

    func deleteWallpaper(_ wallpaper: GeneratedWallpaper) throws {
        try FileManager.default.removeItem(at: wallpaper.imageURL)
        wallpaperHistory.removeAll { $0.id == wallpaper.id }
        saveHistory()

        if currentWallpaper?.id == wallpaper.id {
            currentWallpaper = nil
        }
    }

    func cleanupOldWallpapers(keepCount: Int = 10) {
        let toDelete = wallpaperHistory.dropFirst(keepCount)

        for wallpaper in toDelete {
            try? deleteWallpaper(wallpaper)
        }
    }

    private func loadHistory() {
        let historyURL = storageDirectory.appendingPathComponent("history.json")

        guard let data = try? Data(contentsOf: historyURL) else { return }

        let decoder = JSONDecoder()
        wallpaperHistory = (try? decoder.decode([GeneratedWallpaper].self, from: data)) ?? []
    }

    private func saveHistory() {
        let historyURL = storageDirectory.appendingPathComponent("history.json")

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        guard let data = try? encoder.encode(wallpaperHistory) else { return }
        try? data.write(to: historyURL)
    }
}
