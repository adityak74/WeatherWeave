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
    private let timeout: TimeInterval = 60.0

    init() {}

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
        guard let resourcesPath = Bundle.main.resourceURL else {
            throw ImageGenerationError.resourcePathNotFound
        }

        let pythonExecutableURL = resourcesPath.appendingPathComponent("python/bin/python3")
        let scriptURL = resourcesPath.appendingPathComponent("generate_image.py")

        guard FileManager.default.fileExists(atPath: pythonExecutableURL.path) else {
            throw ImageGenerationError.pythonExecutableNotFound(pythonExecutableURL.path)
        }
        
        guard FileManager.default.fileExists(atPath: scriptURL.path) else {
            throw ImageGenerationError.scriptNotFound
        }

        let process = Process()
        process.executableURL = pythonExecutableURL
        process.arguments = [scriptURL.path, prompt, outputPath]

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
        // Default Draw Things API endpoint
        guard let url = URL(string: "http://127.0.0.1:7860/sdapi/v1/txt2img") else {
            throw ImageGenerationError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "prompt": prompt,
            "width": 1920,
            "height": 1080,
            "steps": 50,
            "guidance_scale": 7.5
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: payload)
        request.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ImageGenerationError.drawThingsAPIError("Invalid response from Draw Things API")
        }

        guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let images = jsonResponse["images"] as? [String],
              let base64Image = images.first else {
            throw ImageGenerationError.invalidResponse
        }

        guard let imageData = Data(base64Encoded: base64Image) else {
            throw ImageGenerationError.invalidImageData
        }

        let outputURL = URL(fileURLWithPath: outputPath)
        try imageData.write(to: outputURL)

        return outputURL
    }
}

// MARK: - Errors
enum ImageGenerationError: Error, LocalizedError {
    case scriptNotFound
    case timeout
    case generationFailed(String)
    case imageNotCreated
    case drawThingsNotImplemented
    case invalidURL
    case drawThingsAPIError(String)
    case invalidResponse
    case invalidImageData
    case resourcePathNotFound
    case pythonExecutableNotFound(String)

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
        case .invalidURL:
            return "Invalid URL for Draw Things API"
        case .drawThingsAPIError(let message):
            return "Draw Things API error: \(message)"
        case .invalidResponse:
            return "Invalid response from Draw Things API"
        case .invalidImageData:
            return "Invalid image data from Draw Things API"
        case .resourcePathNotFound:
            return "Application resource path not found."
        case .pythonExecutableNotFound(let path):
            return "Python executable not found at: \(path). Please ensure Python is bundled correctly."
        }
    }
}
