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
    func fetchTopTracks() async {
        do {
            let json = try await apiClient.fetchFromSpotifyAPI(endpoint: "me/top/tracks?time_range=short_term&limit=30")
            
            if let items = json["items"] as? [[String: Any]] {
                let tracks: [Track] = items.compactMap { item in
                    let name = item["name"] as? String ?? "Unknown track!"
                    let albumDict = item["album"] as? [String: Any]
                    let albumName = albumDict?["name"] as? String ?? "Unknown Album"
                    let artistsArray = item["artists"] as? [[String: Any]] ?? []
                    let artists = artistsArray.compactMap { artistDict in
                        artistDict["name"] as? String
                    }
                    let popularity = item["popularity"] as? Int ?? 0
                    return Track(name: name, album: albumName, artists: artists, popularity: popularity)
                }
                
                // Update the state on the main thread
                DispatchQueue.main.async {
                    self.topTracks = tracks
                    self.errorMessage = nil
                }
            } else {
                throw SpotifyAPIError.jsonParsingFailed
            }
        } catch {
            // Handle errors gracefully
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
