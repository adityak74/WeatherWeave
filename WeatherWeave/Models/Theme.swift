//
//  Theme.swift
//  WeatherWeave
//
//  Created by WeatherWeave on 2026-02-05.
//

import Foundation

enum Theme: String, CaseIterable, Codable {
    case cyberpunk
    case nature
    case abstract
    case minimal

    var displayName: String {
        switch self {
        case .cyberpunk:
            return "Cyberpunk"
        case .nature:
            return "Nature"
        case .abstract:
            return "Abstract"
        case .minimal:
            return "Minimal"
        }
    }

    var modifier: String {
        switch self {
        case .cyberpunk:
            return "cyberpunk aesthetic, neon lights, futuristic cityscape, dramatic lighting, sci-fi atmosphere"
        case .nature:
            return "natural landscape, organic forms, photorealistic, vibrant nature, scenic beauty"
        case .abstract:
            return "abstract art, geometric shapes, bold colors, modern design, artistic composition"
        case .minimal:
            return "minimalist design, clean composition, simple forms, muted colors, serene atmosphere"
        }
    }

    var description: String {
        switch self {
        case .cyberpunk:
            return "Futuristic cityscapes with neon lights and dramatic atmosphere"
        case .nature:
            return "Beautiful natural landscapes with photorealistic detail"
        case .abstract:
            return "Modern abstract art with bold geometric shapes"
        case .minimal:
            return "Clean, simple designs with serene compositions"
        }
    }

    var icon: String {
        switch self {
        case .cyberpunk:
            return "🌃"
        case .nature:
            return "🌲"
        case .abstract:
            return "🎨"
        case .minimal:
            return "⬜"
        }
    }
}
