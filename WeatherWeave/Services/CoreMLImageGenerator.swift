//
//  CoreMLImageGenerator.swift
//  WeatherWeave
//
//  Core ML-based image generation using Z-Image-Turbo
//

import Foundation
import CoreML
import AppKit

class CoreMLImageGenerator: ImageGeneratorProtocol {
    private var pipeline: StableDiffusionPipeline?
    private let modelURL: URL

    enum CoreMLError: Error, LocalizedError {
        case modelNotFound
        case pipelineInitFailed(Error)
        case generationFailed(Error)
        case noImageGenerated

        var errorDescription: String? {
            switch self {
            case .modelNotFound:
                return "Core ML model not found. Please download it from Settings."
            case .pipelineInitFailed(let error):
                return "Failed to initialize pipeline: \(error.localizedDescription)"
            case .generationFailed(let error):
                return "Image generation failed: \(error.localizedDescription)"
            case .noImageGenerated:
                return "No image was generated"
            }
        }
    }

    init() {
        // Look for Core ML model in Application Support
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.modelURL = appSupport.appendingPathComponent("WeatherWeave/CoreML/ZImageTurbo-CoreML/Resources")
    }

    func generateImage(prompt: String, outputPath: String) async throws -> URL {
        // Initialize pipeline if not already done
        if pipeline == nil {
            try await initializePipeline()
        }

        guard let pipeline = pipeline else {
            throw CoreMLError.modelNotFound
        }

        // Configure generation parameters optimized for Z-Image-Turbo
        let config = StableDiffusionPipeline.Configuration(
            prompt: prompt,
            negativePrompt: "blurry, low quality, distorted, watermark, text",
            stepCount: 4,  // Z-Image-Turbo optimized for 4 steps
            seed: UInt32.random(in: 0..<UInt32.max),
            guidanceScale: 0.0,  // Turbo models work best with 0 guidance
            disableSafety: true,
            imageCount: 1
        )

        do {
            print("Generating image with Core ML...")
            print("Prompt: \(prompt)")

            let result = try await pipeline.generateImages(configuration: config)

            guard let cgImage = result.first else {
                throw CoreMLError.noImageGenerated
            }

            // Save to disk
            let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
            guard let tiffData = nsImage.tiffRepresentation,
                  let bitmapRep = NSBitmapImageRep(data: tiffData),
                  let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
                throw CoreMLError.noImageGenerated
            }

            let url = URL(fileURLWithPath: outputPath)
            try pngData.write(to: url)

            print("✅ Image generated successfully: \(outputPath)")
            return url

        } catch {
            throw CoreMLError.generationFailed(error)
        }
    }

    private func initializePipeline() async throws {
        print("Initializing Core ML pipeline...")
        print("Model location: \(modelURL.path)")

        // Check if model exists
        guard FileManager.default.fileExists(atPath: modelURL.path) else {
            throw CoreMLError.modelNotFound
        }

        // Configure Core ML
        let config = MLModelConfiguration()
        config.computeUnits = .all  // Use CPU + GPU + Neural Engine

        do {
            self.pipeline = try StableDiffusionPipeline(
                resourcesAt: modelURL,
                configuration: config,
                disableSafety: true,
                reduceMemory: false
            )
            print("✅ Core ML pipeline initialized")
        } catch {
            throw CoreMLError.pipelineInitFailed(error)
        }
    }

    func isModelDownloaded() -> Bool {
        return FileManager.default.fileExists(atPath: modelURL.path)
    }
}

// MARK: - StableDiffusionPipeline Wrapper
// This is a placeholder that mimics Apple's StableDiffusion framework
// The actual implementation will come from the ml-stable-diffusion Swift package

private class StableDiffusionPipeline {
    struct Configuration {
        let prompt: String
        let negativePrompt: String
        let stepCount: Int
        let seed: UInt32
        let guidanceScale: Float
        let disableSafety: Bool
        let imageCount: Int
    }

    init(resourcesAt url: URL, configuration: MLModelConfiguration, disableSafety: Bool, reduceMemory: Bool) throws {
        // Placeholder - will be replaced with actual Apple ml-stable-diffusion code
        throw NSError(domain: "CoreML", code: 1, userInfo: [NSLocalizedDescriptionKey: "Not yet implemented - awaiting model conversion"])
    }

    func generateImages(configuration: Configuration) async throws -> [CGImage] {
        // Placeholder - will be replaced with actual Apple ml-stable-diffusion code
        throw NSError(domain: "CoreML", code: 1, userInfo: [NSLocalizedDescriptionKey: "Not yet implemented - awaiting model conversion"])
    }
}
