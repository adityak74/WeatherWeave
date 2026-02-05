# WeatherWeave 🌤️

> A lightweight macOS menu bar app that generates stunning, AI-powered wallpapers based on your current location's weather conditions.

[![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Overview

WeatherWeave brings your desktop to life by automatically generating beautiful wallpapers that match your current weather. Stormy cyberpunk cityscapes for rainy days, golden-hour landscapes for clear skies, and foggy minimalism for overcast weather—all generated locally on your Mac using Apple Silicon.

### Key Features

- **Weather-Aware Wallpapers**: Automatically generates wallpapers matching current weather conditions
- **100% Local Processing**: All AI generation happens on your Mac using Z-Image or Draw Things
- **Privacy-First**: No cloud APIs after initial location permission—complete on-device processing
- **Smart Automation**: Updates on weather changes, wake from sleep, or scheduled intervals
- **Multiple Themes**: Choose from Cyberpunk, Nature, Abstract, or Minimal styles
- **Multi-Monitor Support**: Seamlessly works across all connected displays

## Project Structure

```
WeatherWeave/
├── WeatherWeave/
│   ├── App/                        # Application entry point
│   │   ├── WeatherWeaveApp.swift   # SwiftUI app structure
│   │   ├── AppDelegate.swift       # Menu bar setup
│   │   └── Info.plist              # App configuration & permissions
│   ├── Services/                   # Core business logic
│   │   ├── LocationManager.swift   # CoreLocation integration
│   │   ├── WeatherService.swift    # Weather API client
│   │   ├── PromptBuilder.swift     # AI prompt generation
│   │   ├── ImageGenerator.swift    # AI image generation
│   │   └── WallpaperManager.swift  # Wallpaper management
│   ├── Models/                     # Data models
│   │   ├── WeatherCondition.swift  # Weather data structure
│   │   ├── Theme.swift             # Theme definitions
│   │   └── GeneratedWallpaper.swift # Wallpaper metadata
│   ├── Views/                      # User interface
│   │   ├── MenuBarView.swift       # Main menu bar interface
│   │   ├── SettingsView.swift      # Settings panel
│   │   └── GalleryView.swift       # Wallpaper history
│   └── Utilities/                  # Helper utilities
│       ├── Constants.swift         # App constants
│       ├── UserDefaults+Extensions.swift # Settings storage
│       └── AppleScriptRunner.swift # Wallpaper setter
├── Scripts/                        # Python AI scripts
│   ├── generate_image.py           # Image generation wrapper
│   └── install_dependencies.sh     # Dependency installer
├── CLAUDE.md                       # Implementation guide
└── README.md                       # This file
```

## Requirements

### System Requirements
- macOS 13.0 (Ventura) or later
- Apple Silicon Mac (M1/M2/M3/M4)
- 8GB+ RAM recommended
- 5GB+ free storage for AI models

### Software Dependencies
- Xcode 15.0+
- Swift 5.9+
- Python 3.10+ (for AI generation)
- Z-Image-Turbo (MLX) or Draw Things app

## Installation

### 1. Clone the Repository
```bash
git clone https://github.com/adityak74/WeatherWeave.git
cd WeatherWeave
```

### 2. Install Python Dependencies
```bash
chmod +x Scripts/install_dependencies.sh
./Scripts/install_dependencies.sh
```

This script will:
- Create a Python virtual environment
- Install PyTorch with MPS support for Apple Silicon
- Install Diffusers, Transformers, and other required libraries
- Optionally install MLX for optimized performance

### 3. Open in Xcode
```bash
open WeatherWeave.xcodeproj
```

### 4. Build and Run
- Select your Mac as the target device
- Press `Cmd+R` to build and run
- Grant location permission when prompted
- Wait for first wallpaper generation (~20-30 seconds)

## Usage

### First Run
1. Launch WeatherWeave from Applications
2. Grant location permission in System Settings
3. The app icon will appear in your menu bar
4. Click the icon to access controls

### Menu Bar Controls
- **Weather Display**: Shows current weather and location
- **Theme Selector**: Choose your preferred aesthetic style
- **Generate Wallpaper**: Manually trigger new wallpaper generation
- **Gallery**: View and manage wallpaper history
- **Settings**: Configure automation and preferences
- **Quit**: Exit the application

### Settings
- **Auto-update**: Toggle automatic wallpaper updates
- **Update Interval**: Set frequency (15-120 minutes)
- **Update on Wake**: Generate new wallpaper when Mac wakes
- **Storage**: Manage wallpaper history and cleanup

## Development

### Phase 1: Foundation (Current)
- ✅ Project structure created
- ✅ Core models defined
- ✅ Location and weather services implemented
- ✅ Basic UI components created

### Phase 2: AI Integration (Next)
- ⏳ Z-Image integration
- ⏳ Prompt optimization
- ⏳ Image generation testing

### Phase 3: Wallpaper Application
- ⏳ Display detection
- ⏳ Wallpaper setter implementation
- ⏳ Multi-monitor support

### Phase 4: Automation
- ⏳ Timer system
- ⏳ Wake detection
- ⏳ Smart update logic

### Phase 5: Polish
- ⏳ UI refinement
- ⏳ Error handling
- ⏳ Performance optimization

## Architecture

```
User Location → CoreLocation → Weather API → Prompt Builder
                                                   ↓
                                          AI Generation (MLX/Diffusers)
                                                   ↓
                                          Image Post-Processing
                                                   ↓
                                       Multi-Monitor Wallpaper Setter
```

## Privacy & Security

WeatherWeave is designed with privacy as a priority:
- **One-time location permission**: Only requested once via System Settings
- **No telemetry**: Zero data collection or analytics
- **Local processing**: All AI generation happens on-device
- **No cloud APIs**: After setup, works completely offline
- **Open source**: Full transparency in code

## Troubleshooting

### Location Permission Issues
- Open System Settings → Privacy & Security → Location Services
- Ensure WeatherWeave is enabled

### Image Generation Fails
- Verify Python dependencies are installed: `source ~/.weatherweave-venv/bin/activate`
- Check available disk space (5GB+ required for models)
- Review logs in Console.app for detailed errors

### Wallpaper Not Changing
- Check System Settings → Privacy & Security → Full Disk Access
- Grant permission to WeatherWeave if requested

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Roadmap

- [ ] Complete MVP (Phases 1-5)
- [ ] Add custom prompt templates
- [ ] iCloud settings sync
- [ ] Community theme marketplace
- [ ] Animated wallpaper support
- [ ] iOS companion app

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with SwiftUI and CoreLocation
- Weather data from [Open-Meteo](https://open-meteo.com)
- AI generation powered by Stable Diffusion via MLX/Diffusers
- Inspired by the beauty of weather and nature

## Support

If you encounter issues or have questions:
- Open an issue on GitHub
- Check the [CLAUDE.md](CLAUDE.md) implementation guide
- Review the troubleshooting section above

---

Made with ☀️ by [Aditya Kumar](https://github.com/adityak74)
