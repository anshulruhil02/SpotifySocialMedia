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
    func fetchTopArtists() {
        apiClient.fetchFromSpotifyAPI(endpoint: "me/top/artists?time_range=short_term&limit=10") { [weak self] json in
            guard let self = self else { return }
            guard let json = json else {
                DispatchQueue.main.async {
                    self.errorMessage = self.apiClient.errorMessage
                }
                return
            }
            
            if let items = json["items"] as? [[String: Any]] {
                let artists = items.compactMap { artist -> (String, String)? in
                    guard let name = artist["name"] as? String,
                          let images = artist["images"] as? [[String: Any]],
                          let imageUrl = images.first?["url"] as? String else {
                        return nil
                    }
                    return (name, imageUrl)
                }
                DispatchQueue.main.async {
                    self.topArtistsWithImages = artists
                    self.errorMessage = nil
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Unexpected data format for artists."
                }
            }
        }
    }
    
    /// Fetch Genres (from top artists)
    func fetchGenres() {
        apiClient.fetchFromSpotifyAPI(endpoint: "me/top/artists?time_range=short_term&limit=10") { [weak self] json in
            guard let self = self else { return }
            guard let json = json else {
                DispatchQueue.main.async {
                    self.errorMessage = self.apiClient.errorMessage
                }
                return
            }
            
            if let items = json["items"] as? [[String: Any]] {
                var genreSet = Set<String>()
                for artist in items {
                    if let artistGenres = artist["genres"] as? [String] {
                        genreSet.formUnion(artistGenres)
                    }
                }
                DispatchQueue.main.async {
                    self.genres = Array(genreSet).sorted()
                    self.errorMessage = nil
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Unexpected data format for genres."
                }
            }
        }
    }
}
