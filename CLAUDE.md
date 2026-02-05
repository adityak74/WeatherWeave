# WeatherWeave - macOS Menu Bar Weather Wallpaper Generator

## Project Overview

WeatherWeave is a lightweight macOS menu bar application that generates stunning, AI-powered wallpapers based on your current location's weather conditions. The app operates entirely on-device using Apple Silicon, ensuring complete privacy while delivering beautiful, contextual desktop backgrounds.

### Core Concept
- **Weather-aware wallpapers**: Automatically generates wallpapers matching current weather (stormy cyberpunk for rain, golden-hour landscapes for clear skies, foggy minimalism for overcast)
- **100% local processing**: All AI generation happens on your Mac using Z-Image (MLX/Diffusers) or Draw Things, with Python dependencies bundled within the app.
- **Privacy-first**: No cloud APIs after initial location permission
- **Smart automation**: Updates on weather changes, wake from sleep, or scheduled intervals

## MVP Features

### 1. Dynamic Geolocation Weather
- CoreLocation framework integration for precise lat/long positioning
- Reverse geocoding to determine nearest city name
- Weather data from NOAA/MeteoAPI (temp, precipitation, cloud coverage, conditions)
- Automatic wallpaper generation via Z-Image-Turbo (MLX/Diffusers) or Draw Things API

### 2. Smart Rotation System
- Wallpaper updates every 30 minutes (configurable)
- Triggers on system wake from sleep
- Weather condition change detection
- Multi-monitor support using `osascript` wallpaper setter
- Intelligent caching to avoid redundant generations

### 3. Privacy & Offline Operation
- One-time location permission via macOS System Settings
- No telemetry or cloud API calls after setup
- All processing on Apple Silicon M-series GPU
- Generation time: ~15-25 seconds per image (after model download)
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
NOAA/MeteoAPI (Weather Data)
    ↓
Bundled Python Environment (Z-Image/MLX/Diffusers)
    ↓
Image Post-Processing
    ↓
osascript (Set Wallpaper)
    ↓
launchd/Timer (Scheduling)
```

### Key Components

#### 1. Location & Weather Service
- **CoreLocation Manager**: Handle location permissions and coordinates
- **Weather API Client**: Fetch from NOAA or Open-Meteo
- **Geocoding Service**: Convert coordinates to city names
- **Weather Parser**: Extract relevant conditions (temp, precipitation, clouds, time of day)

#### 2. AI Generation Layer
- **Prompt Builder**: Convert weather conditions to descriptive prompts
- **ImageGenerator**: Swift class to run Python script for AI generation. Now uses bundled Python.
- **AIModelManager**: Swift class to manage AI model download and status.
- **Python Script (`generate_image.py`)**: Executes `StableDiffusionPipeline` (MLX/Diffusers) to generate images using `zimageapp/z-image-turbo-q4` model. Supports model status check and download-only modes.
- **Draw Things Fallback**: Alternative if Z-Image not available (via HTTP API).
- **Theme Manager**: Style presets (cyberpunk, nature, abstract, minimal)

#### 3. Wallpaper Management
- **Image Cache**: Store generated wallpapers with metadata
- **Display Manager**: Multi-monitor detection and wallpaper application
- **AppleScript Bridge**: System wallpaper setter via `osascript`

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

### Phase 2: AI Integration (Days 3-4) - Completed
**Goal**: Local AI image generation from weather conditions, with bundled dependencies and in-app model management.

#### Tasks
1.  **Prompt Generation**: Implemented `PromptBuilder` class.
2.  **Z-Image Integration**: `ImageGenerator` uses `generate_image.py` to call `StableDiffusionPipeline` with `zimageapp/z-image-turbo-q4` model. Python environment is bundled.
3.  **Draw Things Fallback**: Implemented via HTTP API in `ImageGenerator`.
4.  **AI Model Management**: Implemented `AIModelManager` and UI in `SettingsView` to check model status and trigger downloads.
5.  **Python Environment Bundling**: Implemented `bundle_python_env.sh` and integrated into Xcode build phases.

**Deliverable**: Working AI generation pipeline from weather to wallpaper, with managed Python dependencies and AI models.

### Phase 3: Wallpaper Application (Day 5)
**Goal**: Apply generated images as desktop wallpapers

#### Tasks
1. **Display Detection**
2. **Wallpaper Setter**
3. **Image Processing**

**Deliverable**: Generated wallpapers automatically applied to desktop

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
│   │   ├── ImageGenerator.swift           # Z-Image/Draw Things integration (uses bundled Python)
│   │   ├── WallpaperManager.swift         # Display & wallpaper setter
│   │   └── AIModelManager.swift           # Manages AI model download & status
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
- **Python 3.10+ (for bundling)**: Required during development/build time for the `bundle_python_env.sh` script. The runtime is bundled.
- **Z-Image-Turbo (MLX/Diffusers)**: Python libraries `torch`, `diffusers`, `transformers`, `accelerate`, `safetensors`, `Pillow`, `mlx`, `mlx-lm` are bundled.
- Draw Things app (optional, for fallback)

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

### Known Challenges
1. **Model Download Size**: AI models are large (5GB+); initial download can take time. User informed via in-app UI.
2. **Wallpaper Permissions**: macOS Sonoma+ may require additional approvals.
3. **Multi-Monitor**: Each display may need individual wallpaper setting.
4. **Generation Time**: 15-25s can feel slow; consider progress indicators.
5. **Weather API Limits**: NOAA has rate limits; implement exponential backoff.

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
2.  **Add Python Bundling Build Phase (one-time setup)**:
    *   Open `WeatherWeave.xcodeproj` in Xcode.
    *   Select the `WeatherWeave` target.
    *   Go to "Build Phases".
    *   Add a "New Run Script Phase" named "Bundle Python Environment".
    *   Drag it after "Target Dependencies" and before "Compile Sources".
    *   Paste `"${PROJECT_DIR}/Scripts/bundle_python_env.sh"` into the script area and ensure "Run script only when installing" is unchecked.
3.  **Build and Run**:
    *   Select your Mac as the target device in Xcode.
    *   Press `Cmd+R` to build and run.
    *   Grant location permission when prompted.
4.  **Download AI Model**:
    *   Open the app's settings (from the menu bar icon).
    *   Navigate to the "AI Models" section.
    *   Click "Download AI Model" and wait for the download to complete (can take several minutes due to model size).
5.  Enjoy dynamic weather wallpapers!

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
- [NOAA Weather API](https://www.weather.gov/documentation/services-web-api)
- [Open-Meteo API](https://open-meteos.com/en/docs)
- [SwiftUI Menu Bar Apps](https://sarunw.com/posts/swiftui-menu-bar-app/)
- [Hugging Face `diffusers`](https://huggingface.co/docs/diffusers)
- [MLX](https://github.com/ml-explore)
- [zimageapp/z-image-turbo-q4](https://huggingface.co/zimageapp/z-image-turbo-q4)
- [Draw Things](https://drawthings.ai)

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
| 2     | 2 days   | AI Integration | Working generation pipeline with bundled dependencies & model management | ✅ Completed |
| 3     | 1 day    | Wallpaper | Auto-apply to desktop | ⏳ In Progress |
| 4     | 1 day    | Automation | Smart rotation system | ⏳ Pending |
| 5     | 1 day    | UI/Polish | Production-ready app | ⏳ Pending |

**Total**: 7 days for MVP

---

*This document serves as the complete implementation guide for WeatherWeave. Follow the phases sequentially, test thoroughly at each stage, and maintain focus on the core experience: beautiful, private, weather-aware wallpapers.*