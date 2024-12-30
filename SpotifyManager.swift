//
//  SpotifyManager.swift
//  SpotifySocialMedia
//
//  Created by Anshul Ruhil on 2024-12-30.
//

import SpotifyiOS

class SpotifyManager: NSObject, ObservableObject, SPTAppRemoteDelegate {
    static let shared = SpotifyManager()
    
    private let SpotifyClientID = "871e04894c794ef3bbd977be57a5f36f"
    private let SpotifyRedirectURL = URL(string: "spotify-socialmedia://spotify-login-callback")!
    
    private var appRemote: SPTAppRemote?
    
    @Published var isConnected = false
    @Published var errorMessage: String?

    override init() {
        super.init()
        appRemote = SPTAppRemote(configuration: SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURL), logLevel: .debug)
        appRemote?.delegate = self
    }
    
    func connect() {
        guard let appRemote = appRemote else { return }
        if appRemote.isConnected {
            self.isConnected = true
            return
        }
        appRemote.authorizeAndPlayURI("")
    }
    
    func disconnect() {
        appRemote?.disconnect()
        isConnected = false
    }
    
    func handleURL(_ url: URL) {
        guard let appRemote = appRemote else { return }
        let parameters = appRemote.authorizationParameters(from: url)
        if let accessToken = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = accessToken
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
}
