//
//  OnDeviceModelConverter.swift
//  WeatherWeave
//
//  Downloads Apple's pre-converted Core ML Stable Diffusion model
//  from Hugging Face file by file
//

import Foundation
import Combine

class OnDeviceModelConverter: ObservableObject {

    enum ConversionState: Equatable {
        case notStarted
        case downloading(progress: Double)
        case converting(progress: Double)
        case completed
        case error(String)

        var description: String {
            switch self {
            case .notStarted: return "Not Downloaded"
            case .downloading(let progress): return "Downloading... \(Int(progress * 100))%"
            case .converting: return "Installing..."
            case .completed: return "Ready"
            case .error(let msg): return "Error: \(msg)"
            }
        }
    }

    @Published var state: ConversionState = .notStarted

    public let modelName = "Stable Diffusion 2.1 (Core ML)"

    private let repoID = "apple/coreml-stable-diffusion-2-1-base"
    private let repoSubPath = "split_einsum/compiled"
    private let cacheDirectory: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.cacheDirectory = appSupport.appendingPathComponent("WeatherWeave/Models")
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        checkCachedModel()
    }

    func checkCachedModel() {
        let textEncoderPath = cacheDirectory.appendingPathComponent("CoreML/TextEncoder.mlmodelc")
        if FileManager.default.fileExists(atPath: textEncoderPath.path) {
            state = .completed
        } else {
            state = .notStarted
        }
    }

    func downloadAndConvert() async throws {
        await MainActor.run { state = .downloading(progress: 0.0) }

        let destination = cacheDirectory.appendingPathComponent("CoreML")
        try? FileManager.default.removeItem(at: destination)
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)

        let files = try await listAllFiles()
        let totalFiles = Double(files.count)

        for (index, file) in files.enumerated() {
            let relativePath = String(file.path.dropFirst(repoSubPath.count + 1))
            let localURL = destination.appendingPathComponent(relativePath)
            try await downloadFile(hfPath: file.path, to: localURL)

            let progress = Double(index + 1) / totalFiles
            await MainActor.run { self.state = .downloading(progress: progress) }
        }

        await MainActor.run { state = .completed }
    }

    // MARK: - Private

    private struct HFFile: Codable {
        let type: String
        let path: String
        let size: Int?
    }

    private func listAllFiles() async throws -> [HFFile] {
        let urlString = "https://huggingface.co/api/models/\(repoID)/tree/main/\(repoSubPath)?recursive=1"
        guard let url = URL(string: urlString) else {
            throw ConversionError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("WeatherWeave/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ConversionError.downloadFailed
        }

        let files = try JSONDecoder().decode([HFFile].self, from: data)
        return files.filter { $0.type == "file" }
    }

    private func downloadFile(hfPath: String, to localURL: URL) async throws {
        let encodedPath = hfPath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? hfPath
        let urlString = "https://huggingface.co/\(repoID)/resolve/main/\(encodedPath)"
        guard let url = URL(string: urlString) else {
            throw ConversionError.invalidURL
        }

        let parentDir = localURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)

        var request = URLRequest(url: url)
        request.setValue("WeatherWeave/1.0", forHTTPHeaderField: "User-Agent")

        let (tempURL, response) = try await URLSession.shared.download(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ConversionError.downloadFailed
        }

        if FileManager.default.fileExists(atPath: localURL.path) {
            try FileManager.default.removeItem(at: localURL)
        }
        try FileManager.default.moveItem(at: tempURL, to: localURL)
    }

    func getCoreMLModelPath() -> URL? {
        let path = cacheDirectory.appendingPathComponent("CoreML")
        return FileManager.default.fileExists(atPath: path.path) ? path : nil
    }
}

// MARK: - FileManager ZIP extraction (kept for compatibility)
extension FileManager {
    func unzipItem(at sourceURL: URL, to destinationURL: URL) throws {
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

// MARK: - Errors
enum ConversionError: Error, LocalizedError {
    case invalidURL
    case downloadFailed
    case converterNotFound
    case conversionFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid model URL"
        case .downloadFailed:
            return "Failed to download model from Hugging Face"
        case .converterNotFound:
            return "Converter not found"
        case .conversionFailed(let message):
            return "Installation failed: \(message)"
        }
    }
}
