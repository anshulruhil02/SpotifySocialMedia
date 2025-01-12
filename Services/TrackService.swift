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
    
    @Published var topTracks: [Track] = []
    @Published var errorMessage: String?
    
    private let apiClient = SpotifyAPIClient.shared
    
    private init() {}
    
    /// Fetch Top Tracks (Short-term)
    func fetchTopTracks() {
        apiClient.fetchFromSpotifyAPI(endpoint: "me/top/tracks?time_range=short_term&limit=30") { [weak self] json in
            guard let self = self else { return }
            guard let json = json else {
                // If `json` is nil, error has already been handled/logged in `SpotifyAPIClient`.
                DispatchQueue.main.async {
                    self.errorMessage = self.apiClient.errorMessage
                }
                return
            }
            
            if let items = json["items"] as? [[String: Any]] {
                let tracks: [Track] = items.compactMap { item in
                    let name = item["name"] as? String ?? "Unkown track!"
                    let albumDict = item["album"] as? [String: Any]
                    let albumName = albumDict?["name"] as? String ?? "Unkown Album"
                    let artistsArray = item["artists"] as? [[String: Any]] ?? []
                    let artists = artistsArray.compactMap { artistDict in
                        artistDict["name"] as? String
                    }
                    let popularity = item["popularity"] as? Int ?? 0
                    return Track(name: name, album: albumName, artists: artists, popularity: popularity)
                }
                
                DispatchQueue.main.async {
                    self.topTracks = tracks
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
