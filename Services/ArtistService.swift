//
//  ArtistService.swift
//  SpotifySocialMedia
//
//  Created by Anshul Ruhil on 2024-12-30.
//

import Foundation
import SpotifyiOS

final class ArtistAndGenreService: ObservableObject {
    static let shared = ArtistAndGenreService()
    
    @Published var topArtistsWithImages: [(name: String, imageUrl: String)] = []
    @Published var genres: [String] = []
    @Published var errorMessage: String?
    
    private let apiClient = SpotifyAPIClient.shared
    
    private init() {}
    
    /// Fetch Top Artists
    func fetchTopArtists() async {
        do {
            let json = try await apiClient.fetchFromSpotifyAPI(endpoint: "me/top/artists?time_range=short_term&limit=10")
            
            if let items = json["items"] as? [[String: Any]] {
                let artists = items.compactMap { artist -> (String, String)? in
                    guard let name = artist["name"] as? String,
                          let images = artist["images"] as? [[String: Any]],
                          let imageUrl = images.first?["url"] as? String else {
                        return nil
                    }
                    return (name, imageUrl)
                }
                
                // Update state on the main thread
                DispatchQueue.main.async {
                    self.topArtistsWithImages = artists
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
    
    /// Fetch Genres (from top artists)
    func fetchGenres() async {
        do {
            let json = try await apiClient.fetchFromSpotifyAPI(endpoint: "me/top/artists?time_range=short_term&limit=10")
            
            if let items = json["items"] as? [[String: Any]] {
                var genreSet = Set<String>()
                for artist in items {
                    if let artistGenres = artist["genres"] as? [String] {
                        genreSet.formUnion(artistGenres)
                    }
                }
                
                // Update state on the main thread
                DispatchQueue.main.async {
                    self.genres = Array(genreSet).sorted()
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
