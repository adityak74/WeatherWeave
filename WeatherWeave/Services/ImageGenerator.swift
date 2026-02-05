//
//  ImageGenerator.swift
//  WeatherWeave
//
//  Created by WeatherWeave on 2026-02-05.
//

import Foundation
import AppKit

protocol ImageGeneratorProtocol {
    func generateImage(prompt: String, outputPath: String) async throws -> URL
}

class ImageGenerator: ImageGeneratorProtocol {
    private let scriptsPath: String
    private let timeout: TimeInterval = 60.0

    init(scriptsPath: String = "~/WeatherWeave/Scripts") {
        self.scriptsPath = (scriptsPath as NSString).expandingTildeInPath
    }

    func generateImage(prompt: String, outputPath: String) async throws -> URL {
        // First try Z-Image
        do {
            return try await generateWithZImage(prompt: prompt, outputPath: outputPath)
        } catch {
            print("Z-Image generation failed: \(error.localizedDescription)")
            // Fallback to Draw Things
            return try await generateWithDrawThings(prompt: prompt, outputPath: outputPath)
        }
    }

    private func generateWithZImage(prompt: String, outputPath: String) async throws -> URL {
        let scriptPath = "\(scriptsPath)/generate_image.py"

        guard FileManager.default.fileExists(atPath: scriptPath) else {
            throw ImageGenerationError.scriptNotFound
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        process.arguments = [scriptPath, prompt, outputPath]

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()

        // Wait for completion with timeout
        let deadline = Date().addingTimeInterval(timeout)
        while process.isRunning && Date() < deadline {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }

        if process.isRunning {
            process.terminate()
            throw ImageGenerationError.timeout
        }

        guard process.terminationStatus == 0 else {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw ImageGenerationError.generationFailed(errorMessage)
        }

        let outputURL = URL(fileURLWithPath: outputPath)
        guard FileManager.default.fileExists(atPath: outputPath) else {
            throw ImageGenerationError.imageNotCreated
        }

        return outputURL
    }

    private func generateWithDrawThings(prompt: String, outputPath: String) async throws -> URL {
        // TODO: Implement Draw Things integration via URL scheme or API
        // For now, throw an error indicating this is not yet implemented
        throw ImageGenerationError.drawThingsNotImplemented
    }
}

// MARK: - Errors
enum ImageGenerationError: Error, LocalizedError {
    case scriptNotFound
    case timeout
    case generationFailed(String)
    case imageNotCreated
    case drawThingsNotImplemented

    var errorDescription: String? {
        switch self {
        case .scriptNotFound:
            return "Image generation script not found"
        case .timeout:
            return "Image generation timed out"
        case .generationFailed(let message):
            return "Image generation failed: \(message)"
        case .imageNotCreated:
            return "Generated image file not found"
        case .drawThingsNotImplemented:
            return "Draw Things integration not yet implemented"
        }
    }
}
