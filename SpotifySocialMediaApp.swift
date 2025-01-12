//
//  SpotifySocialMediaApp.swift
//  SpotifySocialMedia
//
//  Created by Anshul Ruhil on 2024-12-27.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase here, before any Auth calls are made
        FirebaseApp.configure()
        return true
    }
}

@main
struct SpotifySocialMediaApp: App {
    
    // Spotify-specific Authentication Service (for Spotify's App Remote, etc.)
    private var authenticationService = AuthenticationService.shared
    
    // Link AppDelegate to run Firebase configuration
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Initially false to avoid calling `Auth.auth()` before Firebase config
    @State private var isUserLoggedIn: Bool = false

    var body: some Scene {
        WindowGroup {
            if isUserLoggedIn {
                ContentView()
                    .onOpenURL { url in
                        print("onOpenURL called with URL: \(url)")
                        authenticationService.handleURL(url)
                    }
                    .onAppear {
                        observeAuthChanges()
                    }
            } else {
                SignInView()
                    .onOpenURL { url in
                        print("onOpenURL called with URL: \(url)")
                        authenticationService.handleURL(url)
                    }
                    .onAppear {
                        observeAuthChanges()
                    }
            }
        }
    }
    
    /// Sets up a listener that updates `isUserLoggedIn` whenever the Auth state changes.
    private func observeAuthChanges() {
        // By this point, Firebase has been configured in AppDelegate.
        Auth.auth().addStateDidChangeListener { _, user in
            // If `user` is non-nil, user is logged in; otherwise, logged out.
            isUserLoggedIn = (user != nil)
        }
    }
}
