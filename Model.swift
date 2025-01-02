//
//  Model.swift
//  SpotifySocialMedia
//
//  Created by Anshul Ruhil on 2024-12-30.
//

import Foundation

struct TopTracksResponse: Codable {
    let items: [Track]
}

struct Track: Codable {
    let name: String
    let album: Album
    let artists: [Artist]
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
