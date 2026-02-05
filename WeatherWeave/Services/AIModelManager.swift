//
//  AIModelManager.swift
//  WeatherWeave
//
//  Created by WeatherWeave on 2026-02-05.
//

import Foundation
import Combine

import Foundation
import Combine
import AppKit // For Process

class AIModelManager: ObservableObject {
    enum ModelStatus: String, CaseIterable {
        case unknown = "Unknown"
        case notDownloaded = "Not Downloaded"
        case downloading = "Downloading..."
        case downloaded = "Downloaded"
        case error = "Error"
    }

    @Published var modelStatus: ModelStatus = .unknown
    // Removed downloadProgress as real-time tracking from diffusers is complex

    let modelName = "zimageapp/z-image-turbo-q4"

    private let pythonScriptPath: URL
    private let pythonExecutablePath: URL

    init() {
        guard let resourcesPath = Bundle.main.resourceURL else {
            fatalError("Application resource path not found.")
        }
        self.pythonExecutablePath = resourcesPath.appendingPathComponent("python/bin/python3")
        self.pythonScriptPath = resourcesPath.appendingPathComponent("generate_image.py")
        
        checkModelStatus()
    }

    func checkModelStatus() {
        modelStatus = .unknown
        Task {
            do {
                let output = try await runPythonScript(with: ["--check-model"])
                if output.contains("DOWNLOADED") {
                    await MainActor.run { self.modelStatus = .downloaded }
                } else if output.contains("NOT_DOWNLOADED") {
                    await MainActor.run { self.modelStatus = .notDownloaded }
                } else {
                    await MainActor.run { self.modelStatus = .error }
                    print("Unexpected output for check-model: \(output)")
                }
            } catch {
                await MainActor.run { self.modelStatus = .error }
                print("Error checking model status: \(error.localizedDescription)")
            }
        }
    }

    func downloadModel() {
        guard modelStatus != .downloading else { return } // Prevent multiple simultaneous downloads
        
        modelStatus = .downloading
        Task {
            do {
                _ = try await runPythonScript(with: ["--download-model"])
                await MainActor.run { self.modelStatus = .downloaded }
            } catch {
                await MainActor.run { self.modelStatus = .error }
                print("Error downloading model: \(error.localizedDescription)")
            }
        }
    }
    
    private func runPythonScript(with arguments: [String]) async throws -> String {
        guard FileManager.default.fileExists(atPath: pythonExecutablePath.path) else {
            throw AIModelManagerError.pythonExecutableNotFound(pythonExecutablePath.path)
        }
        guard FileManager.default.fileExists(atPath: pythonScriptPath.path) else {
            throw AIModelManagerError.scriptNotFound(pythonScriptPath.path)
        }

        let process = Process()
        process.executableURL = pythonExecutablePath
        process.arguments = [pythonScriptPath.path] + arguments

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        return try await withCheckedThrowingContinuation { continuation in
            process.terminationHandler = { p in
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

                let output = String(data: outputData, encoding: .utf8) ?? ""
                let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
                
                if p.terminationStatus == 0 {
                    continuation.resume(returning: output)
                } else {
                    continuation.resume(throwing: AIModelManagerError.pythonScriptFailed(status: Int(p.terminationStatus), output: output, errorOutput: errorOutput))
                }
            }
            
            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

enum AIModelManagerError: Error, LocalizedError {
    case pythonExecutableNotFound(String)
    case scriptNotFound(String)
    case pythonScriptFailed(status: Int, output: String, errorOutput: String)

    var errorDescription: String? {
        switch self {
        case .pythonExecutableNotFound(let path):
            return "Python executable not found at: \(path). Please ensure Python is bundled correctly."
        case .scriptNotFound(let path):
            return "Python script not found at: \(path)."
        case .pythonScriptFailed(let status, let output, let errorOutput):
            return "Python script failed with status \(status).\nOutput: \(output)\nError: \(errorOutput)"
        }
    }
}
