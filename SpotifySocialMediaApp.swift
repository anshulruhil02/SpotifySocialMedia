//
//  SpotifySocialMediaApp.swift
//  SpotifySocialMedia
//
//  Created by Anshul Ruhil on 2024-12-27.
//

import SwiftUI

@main
struct SpotifySocialMediaApp: App {
    
    private var authenticationService = AuthenticationService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
            .onOpenURL { url in
                print("onOpenURL called with URL: \(url)")
                // Let AuthenticationService handle the OAuth callback
                authenticationService.handleURL(url)
            }
        }
    }
}
