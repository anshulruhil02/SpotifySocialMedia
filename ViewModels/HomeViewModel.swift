//
//  HomeViewModel.swift
//  SpotifySocialMedia
//
//  Created by Anshul Ruhil on 2025-01-03.
//

import SwiftUI
import Combine

final class HomeViewModel: ObservableObject {
    // MARK: - Services
    private let authService: AuthenticationService
    private let trackService: TrackService
    private let artistService: ArtistService
    private let userprofileService: UserProfileService

    // MARK: - Published Properties (UI State)
    @Published var isConnected: Bool = false
    @Published var errorMessage: String?

    // These come from the trackService and artistService, but we store them locally for simpler binding
    @Published var topTracks: [Track] = []
    @Published var topArtistsWithImages: [(name: String, imageUrl: String)] = []
    @Published var genres: [String] = []

    // MARK: - Initializer with Dependency Injection
    init(authService: AuthenticationService,
         trackService: TrackService,
         artistService: ArtistService,
         userprofileService: UserProfileService   )
    {
        self.authService = authService
        self.trackService = trackService
        self.artistService = artistService
        self.userprofileService = userprofileService
        
        // Sync initial states
        self.isConnected = authService.isConnected
        self.errorMessage = authService.errorMessage
        
        // Observe changes from the services in real-time
        observeServices()
    }

    // MARK: - Observing Services
    private func observeServices() {
        // Whenever authService updates isConnected or errorMessage, reflect it here
        authService.$isConnected
            .receive(on: DispatchQueue.main)
            .assign(to: &$isConnected)

        authService.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: &$errorMessage)

        // TrackService Observations
        trackService.$topTracks
            .receive(on: DispatchQueue.main)
            .assign(to: &$topTracks)

        trackService.$errorMessage
            .compactMap { $0 } // Only use non-nil errors
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorText in
                self?.errorMessage = errorText
            }
            .store(in: &cancellables)

        // ArtistService Observations
        artistService.$topArtistsWithImages
            .receive(on: DispatchQueue.main)
            .assign(to: &$topArtistsWithImages)

        artistService.$genres
            .receive(on: DispatchQueue.main)
            .assign(to: &$genres)

        artistService.$errorMessage
            .compactMap { $0 } // Only use non-nil errors
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorText in
                self?.errorMessage = errorText
            }
            .store(in: &cancellables)
        
        userprofileService.$errorMessage
            .compactMap { $0 } // Only use non-nil errors
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorText in
                self?.errorMessage = errorText
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    func connect() {
        authService.connect()
    }

    func disconnect() {
        authService.disconnect()
    }

    func fetchTopTracks() {
        clearData()
        trackService.fetchTopTracks()
    }

    func fetchTopArtists() {
        clearData()
        artistService.fetchTopArtists()
    }

    func fetchGenres() {
        clearData()
        artistService.fetchGenres()
    }
    
//    func saveListeningData() {
//        userprofileService.updateListeningData(
//                tracks: topTracks,
//                albums: topArtistsWithImages.map { $0.name },  // Add album handling later
//                genres: genres
//            )
//        }

    func clearData() {
        // Clears local state from published properties
        topTracks.removeAll()
        topArtistsWithImages.removeAll()
        genres.removeAll()
    }

    // MARK: - Combine
    private var cancellables = Set<AnyCancellable>()
}
