//
//  Model.swift
//  SpotifySocialMedia
//
//  Created by Anshul Ruhil on 2024-12-30.
//

import Foundation
import FirebaseFirestore


struct TopTracksResponse: Codable {
    let items: [Track]
}

struct Track: Codable {
    let name: String
    let album: String
    let artists: [String]
    let popularity: Int
}

struct Album: Codable {
    let name: String
    let images: [ImageArtist]
}

struct Artist: Codable {
    let name: String
}

struct ImageArtist: Codable {
    let url: String
}

struct BrowseAlbum: Identifiable {
    let id = UUID()
    let name: String
    let artistName: String
    let imageUrl: String
}

struct UserProfile: Codable, Identifiable {
    @DocumentID var id: String?  // same as the user UID
    var username: String
    var spotifyID: String?
    
    var topTracks: [String]
    var topArtists: [String]
    var genres: [String]
}
