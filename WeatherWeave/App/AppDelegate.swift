//
//  AppDelegate.swift
//  WeatherWeave
//
//  Created by WeatherWeave on 2026-02-05.
//

import Cocoa
import SwiftUI

/// Holds strong references to programmatically opened windows so they aren't
/// released while visible, preventing crashes on close.
class WindowStore: NSObject, NSWindowDelegate {
    static let shared = WindowStore()
    private var controllers: [NSWindowController] = []

    func add(_ controller: NSWindowController) {
        controller.window?.delegate = self
        controllers.append(controller)
    }

    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        controllers.removeAll { $0.window === window }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status item in the menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "cloud.sun.fill", accessibilityDescription: "WeatherWeave")
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Create the popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 300, height: 400)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: MenuBarView())
    }

    @objc func togglePopover() {
        if let button = statusItem?.button {
            if let popover = popover {
                if popover.isShown {
                    popover.performClose(nil)
                } else {
                    popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                }
            }
        }
    }
}
