//
//  CoreMLImageGenerator.swift
//  WeatherWeave
//
//  Core ML-based image generation using Apple's ml-stable-diffusion
//

import Foundation
import CoreML
import AppKit
import StableDiffusion

class CoreMLImageGenerator: ImageGeneratorProtocol {
    private var pipeline: StableDiffusionPipeline?
    private let modelDirectory: URL

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
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.modelDirectory = appSupport.appendingPathComponent("WeatherWeave/Models/CoreML")
    }

    func generateImage(prompt: String, outputPath: String) async throws -> URL {
        if pipeline == nil {
            try await initializePipeline()
        }

        guard let pipeline = pipeline else {
            throw CoreMLError.modelNotFound
        }

        var config = StableDiffusionPipeline.Configuration(prompt: prompt)
        config.negativePrompt = "blurry, low quality, distorted, watermark, text"
        config.stepCount = 12
        config.seed = UInt32.random(in: 0..<UInt32.max)
        config.guidanceScale = 7.5
        config.disableSafety = true
        config.imageCount = 1

        print("Generating image with Core ML...")
        print("Prompt: \(prompt)")

        let images: [CGImage?] = try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let result = try pipeline.generateImages(configuration: config) { _ in true }
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }

        guard let firstOptional = images.first, let cgImage = firstOptional else {
            throw CoreMLError.noImageGenerated
        }

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
    }

    private func initializePipeline() async throws {
        print("Initializing Core ML pipeline from: \(modelDirectory.path)")

        // Check for key model component, not just the directory
        let textEncoderPath = modelDirectory.appendingPathComponent("TextEncoder.mlmodelc")
        guard FileManager.default.fileExists(atPath: textEncoderPath.path) else {
            print("Model check failed — TextEncoder.mlmodelc not found at: \(textEncoderPath.path)")
            // Clean up empty/partial directory so the user can retry download
            if FileManager.default.fileExists(atPath: modelDirectory.path) {
                try? FileManager.default.removeItem(at: modelDirectory)
            }
            throw CoreMLError.modelNotFound
        }

        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndGPU

        do {
            self.pipeline = try StableDiffusionPipeline(
                resourcesAt: modelDirectory,
                controlNet: [],
                configuration: config,
                disableSafety: true,
                reduceMemory: true
            )
            print("✅ Core ML pipeline initialized")
        } catch {
            throw CoreMLError.pipelineInitFailed(error)
        }
    }

    func isModelDownloaded() -> Bool {
        let textEncoderPath = modelDirectory.appendingPathComponent("TextEncoder.mlmodelc")
        return FileManager.default.fileExists(atPath: textEncoderPath.path)
    }
}
