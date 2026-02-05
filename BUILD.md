# WeatherWeave Build Instructions

## Prerequisites

### System Requirements
- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- Apple Silicon Mac (M1/M2/M3/M4) recommended
- 8GB+ RAM
- 5GB+ free storage for AI models (downloaded via app settings)

### Software Requirements
- Xcode Command Line Tools
- **Python 3.10 or later**: Required during build time for the bundling script.
- Git

## Build Steps

### 1. Clone the Repository

```bash
git clone https://github.com/adityak74/WeatherWeave.git
cd WeatherWeave
```

### 2. Open the Project in Xcode

```bash
open WeatherWeave.xcodeproj
```

Alternatively, launch Xcode and open the project:
- File → Open
- Navigate to `WeatherWeave.xcodeproj`
- Click Open

### 3. Add Python Bundling Build Phase (One-Time Setup)

This step integrates the Python environment bundling directly into your Xcode build process.

1.  **Select Project and Target**: In the Project Navigator (left pane), select the `WeatherWeave` project. Then, in the main editor area, select the `WeatherWeave` target.
2.  **Navigate to Build Phases**: Click on the "Build Phases" tab.
3.  **Add New Run Script Phase**:
    *   Click the `+` button in the top left of the "Build Phases" pane.
    *   Select "New Run Script Phase".
4.  **Configure Script**:
    *   Rename the new phase to "Bundle Python Environment".
    *   Drag this phase to appear **after "Target Dependencies"** and **before "Compile Sources"**.
    *   In the script text area, paste: `"${PROJECT_DIR}/Scripts/bundle_python_env.sh"`
    *   Ensure "Run script only when installing" is **unchecked**.

### 4. Configure Code Signing (Optional)

For development builds, you may need to configure code signing:

1. Select the WeatherWeave project in the navigator
2. Select the WeatherWeave target
3. Go to "Signing & Capabilities"
4. Select your development team or use "Sign to Run Locally"

### 5. Build the Project

**Option A: Build from Xcode**
- Select the "WeatherWeave" scheme
- Choose "My Mac" as the destination
- Press `Cmd+B` to build. The Python environment will be bundled during this process.

**Option B: Build from Command Line**
```bash
xcodebuild -scheme WeatherWeave -configuration Debug build
```

### 6. Run the Application

**Option A: Run from Xcode**
- Press `Cmd+R` to build and run
- The app icon will appear in your menu bar

**Option B: Run from Command Line**
```bash
xcodebuild -scheme WeatherWeave -configuration Debug run
```

**Option C: Run the Built App**
```bash
open ~/Library/Developer/Xcode/DerivedData/WeatherWeave-*/Build/Products/Debug/WeatherWeave.app
```

## First Launch & AI Model Download

When you first launch WeatherWeave:

1.  **Location Permission**: The app will request location permission.
    *   Open System Settings → Privacy & Security → Location Services
    *   Enable WeatherWeave
2.  **Menu Bar Icon**: Click the cloud icon in your menu bar to access controls.
3.  **Download AI Model**:
    *   Open the app's settings (from the menu bar icon).
    *   Navigate to the "AI Models" section.
    *   Click "Download AI Model" and wait for the download to complete. This can take several minutes due to the size of the model files (several gigabytes). A progress indicator will be shown.
4.  Once the model is downloaded, you can trigger wallpaper generation.

## Build Configurations

### Debug Build
- Includes debugging symbols
- Slower performance
- Detailed logging enabled

```bash
xcodebuild -scheme WeatherWeave -configuration Debug build
```

### Release Build
- Optimized for performance
- Smaller binary size
- Minimal logging

```bash
xcodebuild -scheme WeatherWeave -configuration Release build
```

## Troubleshooting

### Python Not Found During Build (Bundling Script Error)

The `bundle_python_env.sh` script requires `python3` (version 3.10 or later) to be available in your system's PATH during the Xcode build process.

*   **Solution**: Ensure Python 3.10+ is installed (e.g., via Homebrew: `brew install python@3.10`) and that it's correctly configured in your shell's PATH.

### Build Fails with "No such module"

Ensure all Swift files are included in the target:
1. Select a file in Project Navigator
2. Check "Target Membership" in File Inspector
3. Ensure "WeatherWeave" is checked

### Location Permission Not Working

Check Info.plist has location usage descriptions:
```bash
cat WeatherWeave/App/Info.plist | grep -A 1 "NSLocation"
```

### Code Signing Issues

For local development, disable sandboxing temporarily:
1. Select WeatherWeave target
2. Go to "Signing & Capabilities"
3. Remove "App Sandbox" capability (for testing only)

## Development Workflow

### Making Changes

1. Make code changes in Xcode
2. Build with `Cmd+B` to check for errors
3. Run with `Cmd+R` to test
4. Use `Cmd+.` to stop the app

### Testing Location Services

Use Xcode's location simulation:
1. Run the app in Xcode
2. Debug → Simulate Location → Choose a city
3. The app will use the simulated location

### Debugging

- Set breakpoints by clicking line numbers
- Use `print()` statements for logging
- Check Console.app for system logs
- Use Instruments for performance profiling

## Clean Build

If you encounter build issues, perform a clean build:

**From Xcode:**
- Product → Clean Build Folder (`Cmd+Shift+K`)

**From Command Line:**
```bash
xcodebuild -scheme WeatherWeave clean
```

## Distribution

### Creating a Release Build

```bash
xcodebuild -scheme WeatherWeave -configuration Release -archivePath ./build/WeatherWeave.xcarchive archive
```

### Exporting for Distribution

```bash
xcodebuild -exportArchive -archivePath ./build/WeatherWeave.xcarchive -exportPath ./build/Release -exportOptionsPlist ExportOptions.plist
```

## Project Structure

```
WeatherWeave/
├── WeatherWeave.xcodeproj/        # Xcode project file
│   ├── project.pbxproj            # Project configuration
│   └── xcshareddata/              # Shared schemes
├── WeatherWeave/                  # Source code
│   ├── App/                       # App entry point
│   ├── Services/                  # Business logic
│   │   └── AIModelManager.swift   # Manages AI model download & status
│   ├── Models/                    # Data models
│   ├── Views/                     # UI components
│   ├── Utilities/                 # Helpers
│   ├── Resources/                 # Assets
│   │   ├── python/                # Bundled Python environment (after build)
│   │   └── generate_image.py      # Bundled Python script (after build)
│   └── WeatherWeave.entitlements  # App capabilities
├── Scripts/                       # Build/automation scripts
│   ├── generate_image.py          # Z-Image wrapper script (source version)
│   └── bundle_python_env.sh       # Script to bundle Python env into .app
├── BUILD.md                       # This file
└── README.md                      # Project overview
```

## Additional Resources

- [Xcode Documentation](https://developer.apple.com/xcode/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [CoreLocation Framework](https://developer.apple.com/documentation/corelocation)
- [Hugging Face `diffusers`](https://huggingface.co/docs/diffusers)
- [MLX](https://github.com/ml-explore)
- [zimageapp/z-image-turbo-q4](https://huggingface.co/zimageapp/z-image-turbo-q4)
- [Draw Things](https://drawthings.ai)

## Support

For build issues or questions:
- Check the troubleshooting section above
- Review the [main README](README.md)
- Check the [implementation guide](CLAUDE.md)
- Open an issue on GitHub

---

**Last Updated**: 2026-02-05
**Xcode Version**: 15.0+
**macOS Version**: 13.0+