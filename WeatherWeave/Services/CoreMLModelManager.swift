//
//  CoreMLModelManager.swift
//  WeatherWeave
//
//  Manages Core ML model downloading and caching
//

import Foundation
import Combine

class CoreMLModelManager: ObservableObject {
    enum ModelStatus: String {
        case notDownloaded = "Not Downloaded"
        case downloading = "Downloading..."
        case downloaded = "Downloaded"
        case error = "Error"
    }

    @Published var modelStatus: ModelStatus = .notDownloaded
    @Published var downloadProgress: Double = 0.0

    let modelName = "Z-Image-Turbo Core ML"
    private let modelURL: URL
    private let downloadURL: String

    // This will be updated to point to GitHub Releases once we upload the model
    private let githubReleaseURL = "https://github.com/adityak74/WeatherWeave/releases/download/v1.0-coreml/ZImageTurbo-CoreML.zip"

    init() {
        // Model will be stored in Application Support
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let weatherWeaveDir = appSupport.appendingPathComponent("WeatherWeave/CoreML")

        // Create directory if needed
        try? FileManager.default.createDirectory(at: weatherWeaveDir, withIntermediateDirectories: true)

        self.modelURL = weatherWeaveDir.appendingPathComponent("ZImageTurbo-CoreML")
        self.downloadURL = githubReleaseURL

        checkModelStatus()
    }

    func checkModelStatus() {
        let resourcesPath = modelURL.appendingPathComponent("Resources")

        if FileManager.default.fileExists(atPath: resourcesPath.path) {
            modelStatus = .downloaded
        } else {
            modelStatus = .notDownloaded
        }
    }

    func downloadModel() {
        guard modelStatus != .downloading else { return }

        modelStatus = .downloading
        downloadProgress = 0.0

        Task {
            do {
                try await downloadAndExtractModel()
                await MainActor.run {
                    self.modelStatus = .downloaded
                    self.downloadProgress = 1.0
                }
            } catch {
                await MainActor.run {
                    self.modelStatus = .error
                    self.downloadProgress = 0.0
                }
                print("Error downloading model: \(error.localizedDescription)")
            }
        }
    }

    private func downloadAndExtractModel() async throws {
        guard let url = URL(string: downloadURL) else {
            throw NSError(domain: "CoreMLModelManager", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Invalid download URL"])
        }

        // Download the ZIP file
        let (tempURL, response) = try await URLSession.shared.download(from: url, delegate: DownloadProgressDelegate(manager: self))

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "CoreMLModelManager", code: 2,
                         userInfo: [NSLocalizedDescriptionKey: "Download failed"])
        }

        // Extract ZIP
        let zipURL = tempURL
        let extractURL = modelURL.deletingLastPathComponent()

        try FileManager.default.unzipItem(at: zipURL, to: extractURL)

        // Clean up
        try? FileManager.default.removeItem(at: tempURL)
    }

    func deleteModel() throws {
        try FileManager.default.removeItem(at: modelURL)
        modelStatus = .notDownloaded
        downloadProgress = 0.0
    }
}

// MARK: - Download Progress Delegate
private class DownloadProgressDelegate: NSObject, URLSessionDownloadDelegate {
    weak var manager: CoreMLModelManager?

    init(manager: CoreMLModelManager) {
        self.manager = manager
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.manager?.downloadProgress = progress
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // File downloaded successfully
    }
}

// MARK: - FileManager Extension for ZIP extraction
extension FileManager {
    func unzipItem(at sourceURL: URL, to destinationURL: URL) throws {
        // For now, use system unzip command
        // In production, consider using a library like ZIPFoundation
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-o", sourceURL.path, "-d", destinationURL.path]

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw NSError(domain: "FileManager", code: 3,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to extract ZIP file"])
        }
    }
}
