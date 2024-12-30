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
    let images: [Image]
}

struct Artist: Codable {
    let name: String
}

struct Image: Codable {
    let url: String
}
