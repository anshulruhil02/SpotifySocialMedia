//
//  AuthenticationService.swift
//  SpotifySocialMedia
//
//  Created by Anshul Ruhil on 2024-12-30.
//

import Foundation
import SpotifyiOS

final class AuthenticationService: NSObject, SPTAppRemoteDelegate, SPTAppRemoteUserAPIDelegate {
    
    static let shared = AuthenticationService()
    
    private let SpotifyClientID = "871e04894c794ef3bbd977be57a5f36f"
    private let SpotifyRedirectURL = URL(string: "spotify-socialmedia://spotify-login-callback")!
    
    private lazy var configuration: SPTConfiguration = {
        let config = SPTConfiguration(clientID: SpotifyClientID,
                                      redirectURL: SpotifyRedirectURL)
        config.playURI = ""
        return config
    }()
    
    private var appRemote: SPTAppRemote?
    
    // Observed states (or inject your own Observables/Publishers as needed)
    @Published var isConnected: Bool = false
    @Published var errorMessage: String?
    
    private let requiredScopes: [String] = [
        "user-top-read",
        "user-read-email",
        "user-read-private"
    ]
    
    override private init() {
        super.init()
        appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote?.delegate = self
    }
    
    /// Initiate connection / authorization flow.
    func connect() {
        guard let appRemote = appRemote else { return }
        if appRemote.isConnected {
            self.isConnected = true
            return
        }
        
        appRemote.authorizeAndPlayURI("", asRadio: false, additionalScopes: requiredScopes) { success in
            if success {
                print("Authorization successful")
            } else {
                print("Authorization failed")
            }
        }
    }
    
    /// Disconnect from Spotify
    func disconnect() {
        appRemote?.disconnect()
        isConnected = false
    }
    
    /// Handle the callback URL and extract the access token
    func handleURL(_ url: URL) {
        guard let appRemote = appRemote else { return }
        let parameters = appRemote.authorizationParameters(from: url)
        if let token = parameters?[SPTAppRemoteAccessTokenKey] {
            // Store token in the `SpotifyAPIClient`
            SpotifyAPIClient.shared.accessToken = token
            
            // Configure the SPTAppRemote
            appRemote.connectionParameters.accessToken = token
            appRemote.connect()
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            self.errorMessage = errorDescription
        }
    }
    
    // MARK: - SPTAppRemoteDelegate Methods
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("Spotify App Remote connected successfully!")
        self.isConnected = true
        self.errorMessage = nil
        appRemote.userAPI?.delegate = self
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("Spotify App Remote failed to connect: \(error?.localizedDescription ?? "Unknown error")")
        self.errorMessage = "Failed to connect to Spotify. Please try again."
        self.isConnected = false
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("Spotify App Remote disconnected: \(error?.localizedDescription ?? "Unknown error")")
        self.errorMessage = "Disconnected from Spotify. Please reconnect."
        self.isConnected = false
    }
    
    // MARK: - SPTAppRemoteUserAPIDelegate Methods
    
    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {
        print("User capabilities received: \(capabilities.canPlayOnDemand)")
    }

    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didFailWithError error: Error) {
        print("User API error: \(error.localizedDescription)")
        self.errorMessage = "Failed to fetch user data."
    }
}
