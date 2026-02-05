//
//  AppleScriptRunner.swift
//  WeatherWeave
//
//  Created by WeatherWeave on 2026-02-05.
//

import Foundation
import AppKit

class AppleScriptRunner {
    enum AppleScriptError: Error, LocalizedError {
        case scriptFailed(String)
        case executionFailed

        var errorDescription: String? {
            switch self {
            case .scriptFailed(let message):
                return "AppleScript failed: \(message)"
            case .executionFailed:
                return "AppleScript execution failed"
            }
        }
    }

    func setWallpaper(imagePath: String, for screen: NSScreen? = nil) throws {
        let script: String

        if let _ = screen {
            // Set wallpaper for specific screen
            script = """
            tell application "System Events"
                tell current desktop
                    set picture to "\(imagePath)"
                end tell
            end tell
            """
        } else {
            // Set wallpaper for all screens
            script = """
            tell application "System Events"
                tell every desktop
                    set picture to "\(imagePath)"
                end tell
            end tell
            """
        }

        try executeAppleScript(script)
    }

    func setWallpaperForAllDisplays(imagePath: String) throws {
        let script = """
        tell application "System Events"
            tell every desktop
                set picture to "\(imagePath)"
            end tell
        end tell
        """

        try executeAppleScript(script)
    }

    private func executeAppleScript(_ script: String) throws {
        var error: NSDictionary?

        guard let appleScript = NSAppleScript(source: script) else {
            throw AppleScriptError.executionFailed
        }

        let output = appleScript.executeAndReturnError(&error)

        if let error = error {
            let errorMessage = error[NSAppleScript.errorMessage] as? String ?? "Unknown error"
            throw AppleScriptError.scriptFailed(errorMessage)
        }

        // Check if execution was successful
        if output.descriptorType == typeNull {
            // Script executed but returned nothing (which is fine for setters)
            return
        }
    }

    // Alternative method using NSWorkspace (may require additional permissions)
    func setWallpaperUsingWorkspace(imageURL: URL, for screen: NSScreen) throws {
        let workspace = NSWorkspace.shared

        // This method is more straightforward but may require additional permissions
        // and is less reliable across different macOS versions
        try workspace.setDesktopImageURL(imageURL, for: screen, options: [:])
    }

    func setWallpaperForAllDisplaysUsingWorkspace(imageURL: URL) throws {
        let workspace = NSWorkspace.shared
        let screens = NSScreen.screens

        for screen in screens {
            try workspace.setDesktopImageURL(imageURL, for: screen, options: [:])
        }
    }
}
