//
//  AlbumService.swift
//  SpotifySocialMedia
//
//  Created by Anshul Ruhil on 2024-12-30.
//

import Foundation
import SpotifyiOS


final class AlbumService: ObservableObject {
    static let shared = AlbumService()
    
    @Published var latestAlbums: [BrowseAlbum] = []
    @Published var errorMessage: String?
    
    private let apiClient = SpotifyAPIClient.shared
    
    private init() {}
    
    /// Fetch the latest album releases.
    func fetchLatestAlbums() {
        apiClient.fetchFromSpotifyAPI(endpoint: "browse/new-releases?limit=10") { [weak self] json in
            guard let self = self else { return }
            guard let json = json else {
                DispatchQueue.main.async {
                    self.errorMessage = self.apiClient.errorMessage
                }
                return
            }
            
            // Debug: Print the raw JSON response
            print("Raw JSON Response for Latest Albums: \(json)")
            
            if let albumsData = (json["albums"] as? [String: Any])?["items"] as? [[String: Any]] {
                let albumResults = albumsData.compactMap { item -> BrowseAlbum? in
                    guard let name = item["name"] as? String,
                          let artists = item["artists"] as? [[String: Any]],
                          let artistName = artists.first?["name"] as? String,
                          let images = item["images"] as? [[String: Any]],
                          let imageUrl = images.first?["url"] as? String else {
                        return nil
                    }
                    return BrowseAlbum(name: name, artistName: artistName, imageUrl: imageUrl)
                }
                
                DispatchQueue.main.async {
                    self.latestAlbums = albumResults
                    self.errorMessage = nil
                }
            } else {
                print("Unexpected data format for Latest Albums JSON: \(json)")
                DispatchQueue.main.async {
                    self.errorMessage = "Unexpected data format for latest albums."
                }
            }
        }
    }
    
    /// Search albums by query
    func searchAlbums(query: String) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        apiClient.fetchFromSpotifyAPI(endpoint: "search?q=\(encodedQuery)&type=album&limit=10") { [weak self] json in
            guard let self = self else { return }
            guard let json = json else {
                DispatchQueue.main.async {
                    self.errorMessage = self.apiClient.errorMessage
                }
                return
            }
            
            // Debug: Print the raw JSON response
            print("Raw JSON Response for Album Search: \(json)")
            
            if let albumsData = (json["albums"] as? [String: Any])?["items"] as? [[String: Any]] {
                let albumResults = albumsData.compactMap { item -> BrowseAlbum? in
                    guard let name = item["name"] as? String,
                          let artists = item["artists"] as? [[String: Any]],
                          let artistName = artists.first?["name"] as? String,
                          let images = item["images"] as? [[String: Any]],
                          let imageUrl = images.first?["url"] as? String else {
                        return nil
                    }
                    return BrowseAlbum(name: name, artistName: artistName, imageUrl: imageUrl)
                }
                
                DispatchQueue.main.async {
                    self.latestAlbums = albumResults
                    self.errorMessage = nil
                }
            } else {
                print("Unexpected data format for Album Search JSON: \(json)")
                DispatchQueue.main.async {
                    self.errorMessage = "Unexpected data format for searched albums."
                }
            }
        }
    }
}
