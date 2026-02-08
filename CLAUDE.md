# WeatherWeave - macOS Menu Bar Weather Wallpaper Generator

## Project Overview

WeatherWeave is a lightweight macOS menu bar application that generates stunning, AI-powered wallpapers based on your current location's weather conditions. The app operates entirely on-device using Apple Silicon, ensuring complete privacy while delivering beautiful, contextual desktop backgrounds.

### Core Concept
- **Weather-aware wallpapers**: Automatically generates wallpapers matching current weather (stormy cyberpunk for rain, golden-hour landscapes for clear skies, foggy minimalism for overcast)
- **100% local processing**: All AI generation happens on your Mac using native Core ML (apple/ml-stable-diffusion). No Python required.
- **Privacy-first**: No cloud APIs after initial location permission
- **Smart automation**: Updates on weather changes, wake from sleep, or scheduled intervals

## MVP Features

### 1. Dynamic Geolocation Weather
- CoreLocation framework integration for precise lat/long positioning
- Reverse geocoding to determine nearest city name
- Weather data from NOAA/MeteoAPI (temp, precipitation, cloud coverage, conditions)
- Automatic wallpaper generation via Core ML pipeline (Stable Diffusion 2.1)

### 2. Smart Rotation System
- Wallpaper updates every 30 minutes (configurable)
- Triggers on system wake from sleep
- Weather condition change detection
- Multi-monitor support using `NSWorkspace.setDesktopImageURL`
- Intelligent caching to avoid redundant generations

### 3. Privacy & Offline Operation
- One-time location permission via macOS System Settings
- No telemetry or cloud API calls after setup
- All processing on Apple Silicon M-series GPU
- Generation time: ~30-60 seconds first run (pipeline load), faster after warm-up
- Local storage of generated wallpapers
- **In-app AI Model Management**: Users can download and manage the necessary AI models directly from the app's settings.

### 4. User Controls
- Menu bar icon with quick access
- Theme preset selection (cyberpunk, nature, abstract, minimal)
- Manual regenerate trigger
- Enable/disable auto-updates
- Weather status display
- Generated wallpaper preview gallery
- **AI Model Status & Download**: Within settings, view model status and trigger download.

## Technical Architecture

### Tech Stack
```
SwiftUI (Menu Bar App)
    ↓
CoreLocation (Geolocation)
    ↓
Reverse Geocoding (City Name)
    ↓
Open-Meteo (Weather Data)
    ↓
apple/ml-stable-diffusion (Core ML, native Swift)
    ↓
Image Post-Processing
    ↓
NSWorkspace (Set Wallpaper)
    ↓
Timer (Scheduling)
```

### Key Components

#### 1. Location & Weather Service
- **CoreLocation Manager**: Handle location permissions and coordinates
- **Weather API Client**: Fetch from NOAA or Open-Meteo
- **Geocoding Service**: Convert coordinates to city names
- **Weather Parser**: Extract relevant conditions (temp, precipitation, clouds, time of day)

#### 2. AI Generation Layer
- **Prompt Builder**: Convert weather conditions to descriptive prompts
- **CoreMLImageGenerator**: Swift class using `StableDiffusionPipeline` from apple/ml-stable-diffusion
- **OnDeviceModelConverter**: Downloads `apple/coreml-stable-diffusion-2-1-base` (split_einsum/compiled) from Hugging Face file-by-file (~4.3GB), installs to `~/Library/Application Support/WeatherWeave/Models/CoreML/`
- **Theme Manager**: Style presets (cyberpunk, nature, abstract, minimal)

#### 3. Wallpaper Management
- **Image Cache**: Store generated wallpapers with metadata
- **Display Manager**: Multi-monitor detection and wallpaper application
- **NSWorkspace**: System wallpaper setter via `setDesktopImageURL(_:for:options:)`

#### 4. UI & Scheduling
- **Menu Bar App**: SwiftUI-based status bar interface
- **Settings Panel**: User preferences, theme selection, and AI Model management.
- **Timer Service**: 30-minute intervals, wake detection
- **Notification System**: Optional alerts for new wallpapers

## Implementation Plan

### Phase 1: Foundation (Days 1-2) - Completed
**Goal**: Basic macOS menu bar app with location and weather fetching

#### Tasks
1. **Project Setup**
2. **Location Service**
3. **Weather Service**

**Deliverable**: Menu bar app that displays current location and weather conditions

### Phase 2: AI Integration (Days 3-4) - ✅ Completed
**Goal**: Native Core ML image generation from weather conditions.

#### Completed Tasks
1.  **Prompt Generation**: ✅ `PromptBuilder` with weather-aware prompts
2.  **Core ML Integration**: ✅ `CoreMLImageGenerator` uses `apple/ml-stable-diffusion` Swift package
    - Model: `apple/coreml-stable-diffusion-2-1-base` (split_einsum/compiled, ~4.3GB)
    - Downloaded file-by-file from Hugging Face API via `OnDeviceModelConverter`
    - Stored at `~/Library/Application Support/WeatherWeave/Models/CoreML/`
    - Pipeline config: `cpuAndGPU`, `reduceMemory: true`, 12 steps
3.  **Model Management**: ✅ UI in `SettingsView` with real download progress
4.  **Wallpaper setter**: ✅ `NSWorkspace.setDesktopImageURL` (no AppleScript needed)
5.  **Window management**: ✅ `WindowStore` holds NSWindowController references to prevent close crashes

**Architecture Decision**: Native Core ML, no Python runtime
- **App size**: ~50MB (model downloaded separately at first run)
- **Model**: 4.3GB one-time download, cached permanently
- **Generation**: 30-60s (pipeline load + inference), faster after warm-up

**Deliverable**: Production-ready Core ML pipeline matching industry apps like Draw Things.

### Phase 3: Wallpaper Application (Day 5) - ✅ Completed
**Goal**: Apply generated images as desktop wallpapers

#### Completed Tasks
1. **Display Detection**: ✅ Multi-monitor support via `NSScreen.screens`
2. **Wallpaper Setter**: ✅ `NSWorkspace.setDesktopImageURL` (AppleScript removed)
3. **Image Processing**: ✅ Wallpaper caching and management
4. **Storage**: ✅ `WallpaperManager` for history and metadata
5. **Window Management**: ✅ `WindowStore` in AppDelegate prevents close crashes

**Deliverable**: ✅ Generated wallpapers automatically applied to desktop with gallery support

### Phase 4: Automation & Scheduling (Day 6)
**Goal**: Smart, automatic wallpaper updates

#### Tasks
1. **Timer System**
2. **Wake Detection**
3. **Update Logic**
4. **Launch Agent**

**Deliverable**: Fully automated wallpaper rotation system

### Phase 5: UI & Polish (Day 7)
**Goal**: User-friendly menu bar interface and settings

#### Tasks
1. **Menu Bar UI**
2. **Settings Panel**
3. **User Experience**
4. **Testing & Optimization**

**Deliverable**: Production-ready macOS menu bar app

## File Structure

```
WeatherWeave/
├── WeatherWeave.xcodeproj
├── WeatherWeave/
│   ├── App/
│   │   ├── WeatherWeaveApp.swift          # App entry point, AIModelManager setup
│   │   ├── AppDelegate.swift              # Menu bar setup (NSApplicationDelegateAdaptor)
│   │   └── Info.plist                     # Permissions & config
│   ├── Services/
│   │   ├── LocationManager.swift          # CoreLocation wrapper
│   │   ├── WeatherService.swift           # NOAA/Meteo API client
│   │   ├── PromptBuilder.swift            # Weather → AI prompt
│   │   ├── ImageGenerator.swift           # Legacy (not used; kept for reference)
│   │   ├── CoreMLImageGenerator.swift     # Active: ml-stable-diffusion pipeline
│   │   ├── OnDeviceModelConverter.swift   # Downloads model from Hugging Face
│   │   ├── WallpaperManager.swift         # Display & wallpaper setter (NSWorkspace)
│   │   └── AIModelManager.swift           # Legacy model manager (not active)
│   ├── Models/
│   │   ├── WeatherCondition.swift         # Weather data model
│   │   ├── Theme.swift                    # Theme presets
│   │   └── GeneratedWallpaper.swift       # Wallpaper metadata
│   ├── Views/
│   │   ├── MenuBarView.swift              # Menu bar content
│   │   ├── SettingsView.swift             # Preferences window (includes AI Model management)
│   │   └── GalleryView.swift              # Wallpaper history
│   ├── Utilities/
│   │   ├── Constants.swift                # App constants
│   │   ├── UserDefaults+Extensions.swift  # Settings storage
│   │   └── AppleScriptRunner.swift        # osascript wrapper
│   └── Resources/
│       ├── Assets.xcassets                # App icons
│       └── Localizable.strings            # i18n (future)
│       └── python/                        # Bundled Python environment (after build)
│       └── generate_image.py              # Copied Python script (after build)
├── Scripts/
│   ├── generate_image.py                  # Z-Image wrapper script (source)
│   ├── install_dependencies.sh            # Old: now replaced by bundled environment
│   └── bundle_python_env.sh               # Script to bundle Python env into .app
├── CLAUDE.md                              # This file
└── README.md                              # User documentation
```

## Dependencies & Requirements

### System Requirements
- macOS 13.0 (Ventura) or later
- Apple Silicon Mac (M1/M2/M3/M4)
- 8GB+ RAM recommended
- 5GB+ free storage for AI models (downloaded via app settings)

### Software Dependencies
- Xcode 15.0+
- Swift 5.9+
- **Core ML**: Built-in (macOS 13.0+)
- **Python 3.10+ (bundled)**: For on-device model conversion
  - `torch`, `safetensors`, `diffusers`, `coremltools`
  - Bundled with app, users don't install anything
- **Z-Image-Turbo Model**: Downloaded on first use from Hugging Face (~5GB)

### API Keys & Services
- NOAA API: Free, no key required (https://api.weather.gov)
- Open-Meteo: Free, no key required (https://open-meteos.com)
- Alternative: Apple WeatherKit (requires Apple Developer account)

### Permissions
- Location Services (one-time authorization)
- Full Disk Access (if using NSWorkspace wallpaper APIs)
- Accessibility (if using AppleScript for wallpaper)

## Development Notes

### Best Practices
1. **Error Handling**: Gracefully handle location denied, network failures, AI generation errors
2. **Performance**: Cache aggressively, debounce API calls, queue AI generations
3. **Battery Life**: Respect system sleep, avoid unnecessary background processing
4. **Privacy**: Never send location/weather data to external servers beyond weather API
5. **User Control**: Always allow manual override and disable automation

### Known Challenges (Resolved)
1. ~~**Generation Time**: 15-25s can feel slow~~ → ✅ <1s with Core ML
2. ~~**Large App Size**: Python bundle was 700MB~~ → ✅ 50MB with Core ML
3. **Model Download**: 5GB initial download (2-5 min, one-time)
4. **First Conversion**: 2-3 min on-device conversion (one-time, shows progress)
5. **Wallpaper Permissions**: macOS Sonoma+ may require additional approvals
6. **Multi-Monitor**: Each display handled individually
7. **Weather API Limits**: NOAA has rate limits; exponential backoff implemented

### Future Enhancements (Post-MVP)
- Custom prompt templates
- Historical weather-based wallpaper browsing
- Sync settings via iCloud
- Community theme marketplace
- Integration with other weather services
- Animated wallpapers (video generation)
- Smart home integration (adapt lighting to wallpaper)
- iOS companion app (manual trigger from phone)

## Getting Started

### Quick Setup
1.  **Clone repository**:
    ```bash
    git clone https://github.com/adityak74/WeatherWeave.git
    cd WeatherWeave
    ```
2.  **Open in Xcode** — Swift Package Manager will resolve `apple/ml-stable-diffusion` automatically.
3.  **Build and Run** (`Cmd+R`). Grant location permission when prompted.
4.  **Download AI Model** (first run only):
    *   Click the menu bar icon → **Settings**
    *   Under **Core ML Model**, click **Download & Convert Model**
    *   Wait for the ~4.3 GB download to complete (progress shown per-file)
    *   Status will change to **Ready**
5.  Click **Generate Wallpaper** and enjoy!

### Development Workflow
1. Start with Phase 1 (location + weather)
2. Test each component independently
3. Iterate on prompt quality in Phase 2
4. Optimize performance in Phase 4
5. Polish UI in Phase 5
6. Beta test with multiple users

## Resources

### Documentation
- [CoreLocation Framework](https://developer.apple.com/documentation/corelocation)
- [Open-Meteo API](https://open-meteo.com/en/docs)
- [SwiftUI Menu Bar Apps](https://sarunw.com/posts/swiftui-menu-bar-app/)
- [apple/ml-stable-diffusion](https://github.com/apple/ml-stable-diffusion)
- [apple/coreml-stable-diffusion-2-1-base](https://huggingface.co/apple/coreml-stable-diffusion-2-1-base)

### Example Prompts
```
Clear + Day + Cyberpunk:
"Futuristic cityscape bathed in golden sunlight, gleaming skyscrapers,
clear blue sky, neon accents, ultra-detailed, 8K, cinematic"

Rain + Night + Nature:
"Misty rainforest at night, bioluminescent plants, rain droplets,
moody atmosphere, dark green tones, photorealistic"

Snow + Sunset + Minimal:
"Minimalist snow-covered mountain peak at sunset, pastel pink sky,
clean composition, serene, wabi-sabi aesthetic"
```

## Timeline Summary

| Phase | Duration | Focus | Deliverable | Status |
|-------|----------|-------|-------------|--------|
| 1     | 2 days   | Foundation | Location + Weather display | ✅ Completed |
| 2     | 2 days   | AI Integration | Core ML generation pipeline | ✅ Completed |
| 3     | 1 day    | Wallpaper | Auto-apply to desktop | ✅ Completed |
| 4     | 1 day    | Automation | Smart rotation system | ⏳ Next |
| 5     | 1 day    | UI/Polish | Production-ready app | 🔄 In Progress |

**Total**: 5 days completed, 2 days remaining for MVP

## Recent Updates

### End-to-End Pipeline Working (Feb 2026)
- Full generation flow: location → weather → prompt → Core ML → wallpaper applied
- Model: `apple/coreml-stable-diffusion-2-1-base` split_einsum/compiled (~4.3GB)
- Download: file-by-file via HuggingFace API with progress tracking
- Generation: `cpuAndGPU` + `reduceMemory: true` + 12 steps (~30-60s)
- Wallpaper setter: `NSWorkspace.setDesktopImageURL` (no AppleScript permissions needed)
- Settings/Gallery: open as `NSWindow` via `WindowStore` (no close crash)

### Key Architecture Facts
- **App binary**: ~50MB (model downloaded separately at first run)
- **Model storage**: `~/Library/Application Support/WeatherWeave/Models/CoreML/`
- **No Python**: pure Swift + Core ML
- **Deployment target**: macOS 13.1+

---

*This document serves as the complete implementation guide for WeatherWeave. Follow the phases sequentially, test thoroughly at each stage, and maintain focus on the core experience: beautiful, private, weather-aware wallpapers.*