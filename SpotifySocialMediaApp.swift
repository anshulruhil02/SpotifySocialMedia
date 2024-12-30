//
//  SpotifySocialMediaApp.swift
//  SpotifySocialMedia
//
//  Created by Anshul Ruhil on 2024-12-27.
//

import SwiftUI

@main
struct SpotifySocialMediaApp: App {
    @StateObject private var spotifyManager = SpotifyManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(spotifyManager)
                .onOpenURL { url in
                    print("onOpenURL called with URL: \(url)")
                    spotifyManager.handleURL(url)
                }
        }
    }
}
