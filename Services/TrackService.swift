//
//  TrackService.swift
//  SpotifySocialMedia
//
//  Created by Anshul Ruhil on 2024-12-30.
//

import Foundation
import SpotifyiOS

final class TrackService: ObservableObject {
    static let shared = TrackService()
    
    @Published var topTracks: [String] = []
    @Published var errorMessage: String?
    
    private let apiClient = SpotifyAPIClient.shared
    
    private init() {}
    
    /// Fetch Top Tracks (Short-term)
    func fetchTopTracks() {
        apiClient.fetchFromSpotifyAPI(endpoint: "me/top/tracks?time_range=short_term&limit=10") { [weak self] json in
            guard let self = self else { return }
            guard let json = json else {
                // If `json` is nil, error has already been handled/logged in `SpotifyAPIClient`.
                DispatchQueue.main.async {
                    self.errorMessage = self.apiClient.errorMessage
                }
                return
            }
            
            if let items = json["items"] as? [[String: Any]] {
                let trackNames = items.compactMap { $0["name"] as? String }
                DispatchQueue.main.async {
                    self.topTracks = trackNames
                    self.errorMessage = nil
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Unexpected data format for tracks."
                }
            }
        }
    }
}
