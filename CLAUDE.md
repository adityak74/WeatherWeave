# WeatherWeave - macOS Menu Bar Weather Wallpaper Generator

## Project Overview

WeatherWeave is a lightweight macOS menu bar application that generates stunning, AI-powered wallpapers based on your current location's weather conditions. The app operates entirely on-device using Apple Silicon, ensuring complete privacy while delivering beautiful, contextual desktop backgrounds.

### Core Concept
- **Weather-aware wallpapers**: Automatically generates wallpapers matching current weather (stormy cyberpunk for rain, golden-hour landscapes for clear skies, foggy minimalism for overcast)
- **100% local processing**: All AI generation happens on your Mac using Z-Image or Draw Things
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
- Generation time: ~15-25 seconds per image
- Local storage of generated wallpapers

### 4. User Controls
- Menu bar icon with quick access
- Theme preset selection (cyberpunk, nature, abstract, minimal)
- Manual regenerate trigger
- Enable/disable auto-updates
- Weather status display
- Generated wallpaper preview gallery

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
Prompt Generator (Weather → AI Prompt)
    ↓
Z-Image/MLX or Draw Things (Local AI)
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
- **Z-Image Integration**: Primary generation via MLX/Diffusers
- **Draw Things Fallback**: Alternative if Z-Image unavailable
- **Theme Manager**: Style presets (cyberpunk, nature, abstract, minimal)

#### 3. Wallpaper Management
- **Image Cache**: Store generated wallpapers with metadata
- **Display Manager**: Multi-monitor detection and wallpaper application
- **AppleScript Bridge**: System wallpaper setter via `osascript`

#### 4. UI & Scheduling
- **Menu Bar App**: SwiftUI-based status bar interface
- **Settings Panel**: User preferences and theme selection
- **Timer Service**: 30-minute intervals, wake detection
- **Notification System**: Optional alerts for new wallpapers

## Implementation Plan

### Phase 1: Foundation (Days 1-2)
**Goal**: Basic macOS menu bar app with location and weather fetching

#### Tasks
1. **Project Setup**
   - Create Xcode SwiftUI project (macOS target, minimum macOS 13.0)
   - Configure Info.plist for location permissions
   - Set up menu bar agent (LSUIElement = YES)
   - Create basic SwiftUI menu bar interface

2. **Location Service**
   - Implement `LocationManager` class using CoreLocation
   - Request and handle location authorization
   - Get current coordinates (lat/long)
   - Implement reverse geocoding for city name
   - Error handling for location failures

3. **Weather Service**
   - Create `WeatherService` protocol
   - Implement NOAA/Open-Meteo API client
   - Parse weather response (temp, conditions, clouds, precipitation)
   - Map weather codes to semantic conditions
   - Add basic caching (5-minute minimum between API calls)

**Deliverable**: Menu bar app that displays current location and weather conditions

### Phase 2: AI Integration (Days 3-4)
**Goal**: Local AI image generation from weather conditions

#### Tasks
1. **Prompt Generation**
   - Create `PromptBuilder` class
   - Map weather conditions to descriptive prompts
     - Clear → "golden hour landscape, warm sunlight, dramatic clouds"
     - Rain → "cyberpunk cityscape, neon reflections, rain-slicked streets"
     - Cloudy → "minimalist foggy mountains, muted colors, soft light"
     - Snow → "winter wonderland, snow-covered trees, crisp air"
   - Add time-of-day variations (sunrise, day, sunset, night)
   - Implement theme modifiers (cyberpunk, nature, abstract, minimal)

2. **Z-Image Integration**
   - Research Z-Image-Turbo installation (MLX/Diffusers on Apple Silicon)
   - Create process wrapper to call Z-Image CLI/Python script
   - Pass prompt and generation parameters
   - Handle image output and errors
   - Implement timeout handling (max 60 seconds)

3. **Draw Things Fallback**
   - Research Draw Things URL scheme or API
   - Implement fallback if Z-Image not available
   - Unified `ImageGenerator` protocol

4. **Image Management**
   - Create wallpaper storage directory (~/Library/Application Support/WeatherWeave)
   - Save generated images with metadata (timestamp, weather, theme)
   - Implement gallery preview in menu

**Deliverable**: Working AI generation pipeline from weather to wallpaper

### Phase 3: Wallpaper Application (Day 5)
**Goal**: Apply generated images as desktop wallpapers

#### Tasks
1. **Display Detection**
   - Detect all connected displays using NSScreen
   - Get screen IDs and resolutions
   - Handle multi-monitor setups

2. **Wallpaper Setter**
   - Implement AppleScript wrapper for wallpaper changes
   ```applescript
   tell application "System Events"
       tell every desktop
           set picture to "/path/to/image.png"
       end tell
   end tell
   ```
   - Alternative: Use NSWorkspace private APIs (research)
   - Handle permissions (System Preferences → Privacy & Security)
   - Per-display wallpaper support

3. **Image Processing**
   - Resize/crop images to match screen resolution
   - Add optional effects (vignette, color grading)
   - Ensure image quality for Retina displays

**Deliverable**: Generated wallpapers automatically applied to desktop

### Phase 4: Automation & Scheduling (Day 6)
**Goal**: Smart, automatic wallpaper updates

#### Tasks
1. **Timer System**
   - Implement 30-minute update timer (configurable)
   - Add weather change detection (poll API, compare conditions)
   - Trigger update only if weather significantly changed
   - Debounce to avoid rapid updates

2. **Wake Detection**
   - Listen for system wake notifications
   - Trigger wallpaper update on wake from sleep
   - Handle display configuration changes

3. **Update Logic**
   - Check if current wallpaper still matches weather
   - Skip generation if weather unchanged and wallpaper recent
   - Queue generation requests to avoid overlaps
   - Show progress indicator in menu bar during generation

4. **Launch Agent**
   - Configure app to launch at login
   - Create launchd plist for startup (optional)
   - Handle app updates gracefully

**Deliverable**: Fully automated wallpaper rotation system

### Phase 5: UI & Polish (Day 7)
**Goal**: User-friendly menu bar interface and settings

#### Tasks
1. **Menu Bar UI**
   - Current weather display with icon
   - Theme selector dropdown
   - Manual "Regenerate Now" button
   - Toggle auto-updates on/off
   - Preferences window
   - Quit option

2. **Settings Panel**
   - Update interval slider (15-120 minutes)
   - Theme presets with previews
   - Custom prompt override (advanced)
   - Wallpaper gallery (view/delete previous)
   - Storage management (auto-cleanup old wallpapers)

3. **User Experience**
   - First-run onboarding (location permission, explain features)
   - Loading states during generation
   - Error messages (location denied, generation failed)
   - Optional notifications for new wallpapers
   - App icon and menu bar icon design

4. **Testing & Optimization**
   - Test on multiple Mac models (M1, M2, M3)
   - Verify memory usage and CPU impact
   - Test edge cases (no internet, location disabled)
   - Multi-monitor testing
   - Performance profiling for AI generation

**Deliverable**: Production-ready macOS menu bar app

## File Structure

```
WeatherWeave/
├── WeatherWeave.xcodeproj
├── WeatherWeave/
│   ├── App/
│   │   ├── WeatherWeaveApp.swift          # App entry point
│   │   ├── AppDelegate.swift              # Menu bar setup
│   │   └── Info.plist                     # Permissions & config
│   ├── Services/
│   │   ├── LocationManager.swift          # CoreLocation wrapper
│   │   ├── WeatherService.swift           # NOAA/Meteo API client
│   │   ├── PromptBuilder.swift            # Weather → AI prompt
│   │   ├── ImageGenerator.swift           # Z-Image/Draw Things
│   │   └── WallpaperManager.swift         # Display & wallpaper setter
│   ├── Models/
│   │   ├── WeatherCondition.swift         # Weather data model
│   │   ├── Theme.swift                    # Theme presets
│   │   └── GeneratedWallpaper.swift       # Wallpaper metadata
│   ├── Views/
│   │   ├── MenuBarView.swift              # Menu bar content
│   │   ├── SettingsView.swift             # Preferences window
│   │   └── GalleryView.swift              # Wallpaper history
│   ├── Utilities/
│   │   ├── Constants.swift                # App constants
│   │   ├── UserDefaults+Extensions.swift  # Settings storage
│   │   └── AppleScriptRunner.swift        # osascript wrapper
│   └── Resources/
│       ├── Assets.xcassets                # App icons
│       └── Localizable.strings            # i18n (future)
├── Scripts/
│   ├── generate_image.py                  # Z-Image wrapper script
│   └── install_dependencies.sh            # MLX/Diffusers setup
├── CLAUDE.md                              # This file
└── README.md                              # User documentation
```

## Dependencies & Requirements

### System Requirements
- macOS 13.0 (Ventura) or later
- Apple Silicon Mac (M1/M2/M3/M4)
- 8GB+ RAM recommended
- 5GB+ free storage for AI models

### Software Dependencies
- Xcode 15.0+
- Swift 5.9+
- Z-Image-Turbo (MLX) or Draw Things app
- Python 3.10+ (for Z-Image)
- MLX, Diffusers libraries (for Z-Image)

### API Keys & Services
- NOAA API: Free, no key required (https://api.weather.gov)
- Open-Meteo: Free, no key required (https://open-meteo.com)
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
1. **Z-Image Setup**: May require manual installation of MLX/Diffusers
2. **Wallpaper Permissions**: macOS Sonoma+ may require additional approvals
3. **Multi-Monitor**: Each display may need individual wallpaper setting
4. **Generation Time**: 15-25s can feel slow; consider progress indicators
5. **Weather API Limits**: NOAA has rate limits; implement exponential backoff

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
1. Clone repository
2. Install Z-Image-Turbo or Draw Things
3. Open `WeatherWeave.xcodeproj` in Xcode
4. Build and run (Cmd+R)
5. Grant location permission when prompted
6. Wait for first wallpaper generation (~20s)
7. Enjoy dynamic weather wallpapers!

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
- [Open-Meteo API](https://open-meteo.com/en/docs)
- [SwiftUI Menu Bar Apps](https://sarunw.com/posts/swiftui-menu-bar-app/)
- [Z-Image MLX](https://github.com/ml-explore)
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

| Phase | Duration | Focus | Deliverable |
|-------|----------|-------|-------------|
| 1 | 2 days | Foundation | Location + Weather display |
| 2 | 2 days | AI Integration | Working generation pipeline |
| 3 | 1 day | Wallpaper | Auto-apply to desktop |
| 4 | 1 day | Automation | Smart rotation system |
| 5 | 1 day | UI/Polish | Production-ready app |

**Total**: 7 days for MVP

---

*This document serves as the complete implementation guide for WeatherWeave. Follow the phases sequentially, test thoroughly at each stage, and maintain focus on the core experience: beautiful, private, weather-aware wallpapers.*
