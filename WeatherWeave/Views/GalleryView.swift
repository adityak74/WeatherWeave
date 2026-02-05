//
//  GalleryView.swift
//  WeatherWeave
//
//  Created by WeatherWeave on 2026-02-05.
//

import SwiftUI
import AppKit

struct GalleryView: View {
    @ObservedObject var wallpaperManager: WallpaperManager
    @State private var selectedWallpaper: GeneratedWallpaper?

    let columns = [
        GridItem(.adaptive(minimum: 150))
    ]

    var body: some View {
        VStack {
            if wallpaperManager.wallpaperHistory.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(wallpaperManager.wallpaperHistory) { wallpaper in
                            WallpaperThumbnail(wallpaper: wallpaper)
                                .onTapGesture {
                                    selectedWallpaper = wallpaper
                                }
                                .contextMenu {
                                    Button("Set as wallpaper") {
                                        setAsWallpaper(wallpaper)
                                    }
                                    Button("Show in Finder") {
                                        showInFinder(wallpaper)
                                    }
                                    Divider()
                                    Button("Delete", role: .destructive) {
                                        deleteWallpaper(wallpaper)
                                    }
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(width: 600, height: 500)
        .navigationTitle("Wallpaper Gallery")
        .sheet(item: $selectedWallpaper) { wallpaper in
            WallpaperDetailView(wallpaper: wallpaper)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No wallpapers yet")
                .font(.headline)
            Text("Generate your first weather wallpaper from the menu bar")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func setAsWallpaper(_ wallpaper: GeneratedWallpaper) {
        do {
            try wallpaperManager.setAsWallpaper(wallpaper)
        } catch {
            print("Failed to set wallpaper: \(error)")
        }
    }

    private func showInFinder(_ wallpaper: GeneratedWallpaper) {
        NSWorkspace.shared.selectFile(wallpaper.imageURL.path, inFileViewerRootedAtPath: "")
    }

    private func deleteWallpaper(_ wallpaper: GeneratedWallpaper) {
        do {
            try wallpaperManager.deleteWallpaper(wallpaper)
        } catch {
            print("Failed to delete wallpaper: \(error)")
        }
    }
}

struct WallpaperThumbnail: View {
    let wallpaper: GeneratedWallpaper

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let image = NSImage(contentsOf: wallpaper.imageURL) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 100)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 100)
                    .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(wallpaper.weather.emoji)
                    Text(wallpaper.theme.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                }

                Text(wallpaper.timestamp, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct WallpaperDetailView: View {
    let wallpaper: GeneratedWallpaper
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            if let image = NSImage(contentsOf: wallpaper.imageURL) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 800, maxHeight: 600)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Weather:")
                    Text("\(wallpaper.weather.emoji) \(wallpaper.weather.description)")
                        .fontWeight(.semibold)
                    Spacer()
                }

                HStack {
                    Text("Theme:")
                    Text("\(wallpaper.theme.icon) \(wallpaper.theme.displayName)")
                        .fontWeight(.semibold)
                    Spacer()
                }

                HStack {
                    Text("Created:")
                    Text(wallpaper.timestamp, style: .date)
                        .fontWeight(.semibold)
                    Spacer()
                }

                HStack {
                    Text("File size:")
                    Text(wallpaper.fileSize)
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
            .padding()

            HStack {
                Button("Close") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()
            }
            .padding()
        }
        .frame(width: 900, height: 750)
    }
}

#Preview {
    GalleryView(wallpaperManager: WallpaperManager())
}
