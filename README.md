<div align="center">
  <img src="./weather_weave_logo.png" alt="WeatherWeave Logo" width="200"/>

# WeatherWeave

### AI-Powered Weather Wallpapers for macOS

  <p align="center">
    A lightweight menu bar app that generates stunning wallpapers based on your current weather—completely on-device using Apple Silicon.
  </p>

[![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Development](#️-development) • [Contributing](#-contributing) • [License](#-license)

</div>

---

## 📖 Overview

WeatherWeave brings your desktop to life by automatically generating beautiful wallpapers that match your current weather. Stormy cyberpunk cityscapes for rainy days, golden-hour landscapes for clear skies, and foggy minimalism for overcast weather—all generated locally on your Mac using Apple Silicon.

### Why WeatherWeave?

- **🎨 Dynamic & Contextual**: Your wallpaper reflects the world outside your window
- **🔒 Privacy-First**: Zero cloud processing, zero data collection, 100% on-device
- **⚡ Powered by Apple Silicon**: Leverages M-series GPU for fast, efficient AI generation
- **🎯 Set and Forget**: Smart automation keeps your desktop fresh without manual intervention

## ✨ Features

- **Weather-Aware Generation**: Automatically creates wallpapers matching current weather conditions
- **100% Local AI Processing**: All generation happens on your Mac using Z-Image (MLX/Diffusers) or Draw Things
- **Complete Privacy**: No cloud APIs, no telemetry, no data collection—works entirely offline after setup
- **Smart Automation**:
  - Updates every 30 minutes (configurable)
  - Triggers on weather changes
  - Generates new wallpaper when Mac wakes from sleep
- **Multiple Theme Presets**: Choose from Cyberpunk, Nature, Abstract, or Minimal aesthetics
- **Multi-Monitor Support**: Seamlessly applies wallpapers across all connected displays
- **In-App AI Model Management**: Download and manage AI models directly from the app
- **Wallpaper Gallery**: Browse and restore previously generated wallpapers

## 📋 Requirements

### System Requirements

| Component    | Requirement                     |
| ------------ | ------------------------------- |
| **OS**       | macOS 13.0 (Ventura) or later   |
| **Hardware** | Apple Silicon Mac (M1/M2/M3/M4) |
| **RAM**      | 8GB+ recommended                |
| **Storage**  | 5GB+ free space for AI models   |

### Development Requirements

- **Xcode** 15.0+
- **Swift** 5.9+
- **Python** 3.10+ (bundled at build time)
- **Git** for version control

## 🚀 Installation

### Quick Start

1. **Clone the repository**

   ```bash
   git clone https://github.com/adityak74/WeatherWeave.git
   cd WeatherWeave
   ```

2. **Set up Python bundling** (one-time setup)

   - Open `WeatherWeave.xcodeproj` in Xcode
   - Select the `WeatherWeave` target
   - Go to **Build Phases** → Add **New Run Script Phase**
   - Name it "Bundle Python Environment"
   - Paste the following script:
     ```bash
     "${PROJECT_DIR}/Scripts/bundle_python_env.sh"
     ```
   - Ensure "Run script only when installing" is **unchecked**

3. **Build and run**

   - Select your Mac as the target device in Xcode
   - Press `Cmd+R` to build and run
   - Grant location permission when prompted

4. **Download AI models** (first run)

   - Open the app's settings from the menu bar
   - Navigate to **AI Models** section
   - Click **Download AI Model** (may take several minutes)
   - Wait for download to complete

5. **Generate your first wallpaper**
   - Click the WeatherWeave menu bar icon
   - Select **Generate Wallpaper**
   - Wait ~15-25 seconds for AI generation
   - Enjoy your weather-aware wallpaper!

## 🎯 Usage

### Getting Started

1. **Launch WeatherWeave** from Applications
2. **Grant location permission** in System Settings when prompted
3. **Wait for AI model download** (first run only, ~5GB)
4. **Click the menu bar icon** to access controls

### Menu Bar Interface

Click the ☁️ WeatherWeave icon in your menu bar to access:

| Option                    | Description                                         |
| ------------------------- | --------------------------------------------------- |
| 🌡️ **Weather Display**    | Shows current weather, temperature, and location    |
| 🎨 **Theme Selector**     | Choose from Cyberpunk, Nature, Abstract, or Minimal |
| 🖼️ **Generate Wallpaper** | Manually trigger new wallpaper generation           |
| 🖼️ **Gallery**            | Browse and restore previously generated wallpapers  |
| ⚙️ **Settings**           | Configure automation, intervals, and AI models      |
| ❌ **Quit**               | Exit WeatherWeave                                   |

### Configuration Options

**Settings Panel** provides fine-grained control:

- **Auto-Update**: Enable/disable automatic wallpaper rotation
- **Update Interval**: Set frequency (15-120 minutes)
- **Update on Wake**: Generate fresh wallpaper when Mac wakes from sleep
- **AI Model Management**: Check model status, download, or update models
- **Storage Management**: View and clean up wallpaper history
- **Theme Preference**: Set default theme for generations

### Example Prompts Generated

WeatherWeave intelligently crafts prompts based on weather:

```
☀️ Clear + Day + Cyberpunk
→ "Futuristic cityscape bathed in golden sunlight, gleaming skyscrapers,
   clear blue sky, neon accents, ultra-detailed, 8K, cinematic"

🌧️ Rain + Night + Nature
→ "Misty rainforest at night, bioluminescent plants, rain droplets,
   moody atmosphere, dark green tones, photorealistic"

❄️ Snow + Sunset + Minimal
→ "Minimalist snow-covered mountain peak at sunset, pastel pink sky,
   clean composition, serene, wabi-sabi aesthetic"
```

## 🛠️ Development

### Development Roadmap

| Phase       | Status         | Focus            | Key Deliverables                                   |
| ----------- | -------------- | ---------------- | -------------------------------------------------- |
| **Phase 1** | ✅ Complete    | Foundation       | Location services, weather API, basic UI           |
| **Phase 2** | ✅ Complete    | AI Integration   | Z-Image pipeline, model management, bundled Python |
| **Phase 3** | 🚧 In Progress | Wallpaper System | Display detection, wallpaper setter, multi-monitor |
| **Phase 4** | ⏳ Planned     | Automation       | Timer system, wake detection, smart updates        |
| **Phase 5** | ⏳ Planned     | Polish           | UI refinement, error handling, optimization        |

### Building from Source

1. **Prerequisites**

   ```bash
   # Ensure you have Xcode 15.0+ installed
   xcode-select --install

   # Verify Python 3.10+ is available
   python3 --version
   ```

2. **Clone and build**

   ```bash
   git clone https://github.com/adityak74/WeatherWeave.git
   cd WeatherWeave
   open WeatherWeave.xcodeproj
   ```

3. **Configure build phases** (see Installation section)

4. **Run tests** (when available)
   ```bash
   # Run unit tests
   xcodebuild test -scheme WeatherWeave -destination 'platform=macOS'
   ```

### Development Workflow

- **Branching**: Use feature branches (`feature/amazing-feature`)
- **Commits**: Follow [Conventional Commits](https://www.conventionalcommits.org/)
- **Testing**: Add tests for new features
- **Documentation**: Update CLAUDE.md for architectural changes

## 🏗️ Architecture

### System Flow

```
┌─────────────────┐
│  User Location  │
└────────┬────────┘
         ↓
┌─────────────────┐      ┌──────────────────┐
│  CoreLocation   │ ───→ │ Reverse Geocode  │
└────────┬────────┘      └────────┬─────────┘
         ↓                        ↓
┌─────────────────┐      ┌──────────────────┐
│  Weather API    │ ←─── │   City Name      │
│ (Open-Meteo)    │      └──────────────────┘
└────────┬────────┘
         ↓
┌─────────────────┐
│ Prompt Builder  │ ← Weather conditions + Theme
└────────┬────────┘
         ↓
┌──────────────────────────┐
│   AI Generation Engine   │
│  (Z-Image/MLX/Diffusers) │
│   Bundled Python + Model │
└──────────┬───────────────┘
           ↓
┌──────────────────────────┐
│  Image Post-Processing   │
│  (Resize, Optimize)      │
└──────────┬───────────────┘
           ↓
┌──────────────────────────┐
│ Multi-Monitor Wallpaper  │
│ Setter (osascript)       │
└──────────────────────────┘
```

### Technology Stack

- **Frontend**: SwiftUI
- **Backend Services**: CoreLocation, URLSession
- **AI Generation**: Stable Diffusion (via MLX/Diffusers)
- **Python Runtime**: Bundled virtual environment
- **AI Model**: `zimageapp/z-image-turbo-q4` (Hugging Face)
- **Wallpaper Engine**: AppleScript + NSWorkspace
- **Scheduling**: Timer + NSWorkspace wake notifications

### Project Structure

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
│   │   ├── WallpaperManager.swift  # Wallpaper management
│   │   └── AIModelManager.swift    # AI model download & status
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
├── Scripts/                        # Build & generation scripts
│   ├── generate_image.py           # Image generation wrapper
│   ├── bundle_python_env.sh        # Python environment bundler
│   └── install_dependencies.sh     # Legacy dependency installer
├── CLAUDE.md                       # Implementation guide
└── README.md                       # This file
```

## 🔒 Privacy & Security

WeatherWeave is designed with **privacy-first** principles:

| Aspect               | Implementation                                                                |
| -------------------- | ----------------------------------------------------------------------------- |
| 🔐 **Location Data** | Never leaves your device; only used for weather API calls                     |
| 📊 **Telemetry**     | Zero tracking, zero analytics, zero data collection                           |
| 💻 **AI Processing** | 100% on-device using Apple Silicon GPU                                        |
| 🌐 **Network Calls** | Only to public weather APIs (Open-Meteo); no proprietary servers              |
| 📂 **Storage**       | All wallpapers stored locally in `~/Library/Application Support/WeatherWeave` |
| 🔓 **Open Source**   | Full code transparency; audit-friendly                                        |

**Permissions Required:**

- **Location Services**: One-time authorization for weather data
- **Full Disk Access**: Optional; for wallpaper setting (or uses AppleScript as fallback)

**No Cloud Dependencies:**
After initial model download, WeatherWeave works completely offline.

## 🐛 Troubleshooting

### Location Permission Issues

- Open **System Settings** → **Privacy & Security** → **Location Services**
- Ensure WeatherWeave is enabled

### Image Generation Fails

- Verify Python dependencies are bundled (check build logs)
- Check available disk space (5GB+ required for models)
- Review logs in Console.app for detailed errors

### Wallpaper Not Changing

- Check **System Settings** → **Privacy & Security** → **Full Disk Access**
- Grant permission to WeatherWeave if requested
- Verify AppleScript permissions in **System Settings** → **Privacy & Security** → **Automation**

### Model Download Stuck

- Ensure stable internet connection
- Check Hugging Face status at [status.huggingface.co](https://status.huggingface.co)
- Try restarting the download from Settings

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

### How to Contribute

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit your changes**
   ```bash
   git commit -m 'Add some amazing feature'
   ```
4. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open a Pull Request**

### Contribution Guidelines

- Follow Swift style guidelines and SwiftUI best practices
- Add tests for new features
- Update documentation for significant changes
- Keep commits atomic and well-described
- For major changes, open an issue first to discuss

### Areas We'd Love Help With

- 🎨 UI/UX improvements and design polish
- 🧪 Writing tests and improving code coverage
- 📚 Documentation and tutorials
- 🌍 Internationalization and localization
- 🐛 Bug fixes and performance optimizations
- 💡 New theme presets and prompt templates

## 🗺️ Roadmap

### MVP (Current Focus)

- [x] Location and weather integration
- [x] AI model integration with bundled Python
- [x] In-app AI model management
- [ ] Wallpaper application system
- [ ] Smart automation and scheduling
- [ ] UI polish and error handling

### Future Enhancements

- [ ] Custom prompt templates
- [ ] Historical weather-based wallpaper browsing
- [ ] iCloud settings sync
- [ ] Community theme marketplace
- [ ] Animated wallpapers (video generation)
- [ ] Smart home integration
- [ ] iOS companion app

## 📄 License

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2025 Aditya Karnam

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

See [LICENSE](LICENSE) file for full details.

## 🙏 Acknowledgments

- **Built with** [SwiftUI](https://developer.apple.com/xcode/swiftui/) and [CoreLocation](https://developer.apple.com/documentation/corelocation)
- **Weather data** from [Open-Meteo](https://open-meteo.com) (free, no API key required)
- **AI generation** powered by [Stable Diffusion](https://github.com/Stability-AI/stablediffusion) via [MLX](https://github.com/ml-explore/mlx) and [Diffusers](https://github.com/huggingface/diffusers)
- **AI model** [zimageapp/z-image-turbo-q4](https://huggingface.co/zimageapp/z-image-turbo-q4) from Hugging Face
- **Inspired by** the beauty of weather, nature, and the power of on-device AI

## 💬 Support

### Get Help

If you encounter issues or have questions:

- 📖 Check the [Troubleshooting](#-troubleshooting) section
- 📝 Review the [CLAUDE.md](CLAUDE.md) implementation guide
- 🐛 [Open an issue](https://github.com/adityak74/WeatherWeave/issues) on GitHub
- 💬 Join discussions in [GitHub Discussions](https://github.com/adityak74/WeatherWeave/discussions)

### Stay Updated

- ⭐ Star this repo to show support
- 👀 Watch for updates and releases
- 🍴 Fork to create your own variations

---

<div align="center">
  <p>Made with ☀️ and 🌧️ by <a href="https://github.com/adityak74">Aditya Karnam</a></p>
  <p>
    <a href="https://github.com/adityak74/WeatherWeave/stargazers">⭐ Star</a> •
    <a href="https://github.com/adityak74/WeatherWeave/issues">🐛 Report Bug</a> •
    <a href="https://github.com/adityak74/WeatherWeave/issues">💡 Request Feature</a>
  </p>
</div>
