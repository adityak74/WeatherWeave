//
//  OnDeviceModelConverter.swift
//  WeatherWeave
//
//  Converts .safetensors checkpoint to Core ML on-device (Draw Things approach)
//

import Foundation
import Combine

/// Handles on-device conversion of Stable Diffusion checkpoints to Core ML
/// Similar to how Draw Things and other apps do it
class OnDeviceModelConverter: ObservableObject {

    enum ConversionState: Equatable {
        case notStarted
        case downloading(progress: Double)
        case converting(progress: Double)
        case completed
        case error(String)

        var description: String {
            switch self {
            case .notStarted: return "Ready"
            case .downloading(let progress): return "Downloading model... \(Int(progress * 100))%"
            case .converting(let progress): return "Converting to Core ML... \(Int(progress * 100))%"
            case .completed: return "Ready"
            case .error(let msg): return "Error: \(msg)"
            }
        }
    }

    @Published var state: ConversionState = .notStarted

    private let modelName = "zimageapp/z-image-turbo-q4"
    private let safetensorsURL = "https://huggingface.co/zimageapp/z-image-turbo-q4/resolve/main/model.safetensors"
    private let cacheDirectory: URL
    private let pythonConverter: URL

    init() {
        // Set up cache directory
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.cacheDirectory = appSupport.appendingPathComponent("WeatherWeave/Models")
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

        // Python converter script location
        guard let resourcesPath = Bundle.main.resourceURL else {
            fatalError("Could not find resources path")
        }
        self.pythonConverter = resourcesPath.appendingPathComponent("convert_checkpoint.py")

        checkCachedModel()
    }

    /// Check if Core ML model is already cached
    func checkCachedModel() {
        let coremlPath = cacheDirectory.appendingPathComponent("z-image-turbo.mlmodelc")
        if FileManager.default.fileExists(atPath: coremlPath.path) {
            state = .completed
        } else {
            state = .notStarted
        }
    }

    /// Download checkpoint and convert to Core ML
    func downloadAndConvert() async throws {
        // Step 1: Download .safetensors file
        await MainActor.run { state = .downloading(progress: 0.0) }

        let checkpointPath = try await downloadCheckpoint()

        // Step 2: Convert to Core ML
        await MainActor.run { state = .converting(progress: 0.0) }

        try await convertToCoreML(checkpointPath: checkpointPath)

        // Step 3: Clean up checkpoint file (save space)
        try? FileManager.default.removeItem(at: checkpointPath)

        await MainActor.run { state = .completed }
    }

    private func downloadCheckpoint() async throws -> URL {
        guard let url = URL(string: safetensorsURL) else {
            throw ConversionError.invalidURL
        }

        let destination = cacheDirectory.appendingPathComponent("checkpoint.safetensors")

        // Use URLSession to download with progress
        let (tempURL, response) = try await URLSession.shared.download(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ConversionError.downloadFailed
        }

        // Move to permanent location
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        try FileManager.default.moveItem(at: tempURL, to: destination)

        return destination
    }

    private func convertToCoreML(checkpointPath: URL) async throws {
        // Run Python conversion script
        guard FileManager.default.fileExists(atPath: pythonConverter.path) else {
            throw ConversionError.converterNotFound
        }

        let outputPath = cacheDirectory.appendingPathComponent("z-image-turbo.mlmodelc")

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        process.arguments = [
            pythonConverter.path,
            checkpointPath.path,
            outputPath.path,
            "--compute-unit", "ALL",
            "--quantize", "6"
        ]

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        // Monitor output for progress
        let outputHandle = outputPipe.fileHandleForReading
        outputHandle.readabilityHandler = { handle in
            let data = handle.availableData
            if let output = String(data: data, encoding: .utf8) {
                self.parseConversionProgress(output)
            }
        }

        try process.run()
        process.waitUntilExit()

        outputHandle.readabilityHandler = nil

        guard process.terminationStatus == 0 else {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw ConversionError.conversionFailed(errorMessage)
        }
    }

    private func parseConversionProgress(_ output: String) {
        // Parse progress from Python script output
        // Example: "Converting layer 5/12..."
        if let match = output.range(of: #"(\d+)/(\d+)"#, options: .regularExpression) {
            let numbers = output[match].split(separator: "/")
            if numbers.count == 2,
               let current = Double(numbers[0]),
               let total = Double(numbers[1]) {
                let progress = current / total
                Task { @MainActor in
                    if case .converting = self.state {
                        self.state = .converting(progress: progress)
                    }
                }
            }
        }
    }

    func getCoreMLModelPath() -> URL? {
        let path = cacheDirectory.appendingPathComponent("z-image-turbo.mlmodelc")
        return FileManager.default.fileExists(atPath: path.path) ? path : nil
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
            return "Failed to download model checkpoint"
        case .converterNotFound:
            return "Conversion script not found in app bundle"
        case .conversionFailed(let message):
            return "Conversion failed: \(message)"
        }
    }
}
