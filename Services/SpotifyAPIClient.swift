//
//  SpotifyAPIClient.swift
//  SpotifySocialMedia
//
//  Created by Anshul Ruhil on 2024-12-30.
//

import Foundation
import SpotifyiOS

final class SpotifyAPIClient {
    static let shared = SpotifyAPIClient()
    
    var accessToken: String?
    
    private init() {}
    
    /// Generic method to fetch data from Spotify's Web API.
    /// - Parameter endpoint: The endpoint (relative to "https://api.spotify.com/v1/").
    /// - Returns: A dictionary on success, or throws an error on failure.
    func fetchFromSpotifyAPI(endpoint: String) async throws -> [String: Any] {
        guard let token = accessToken else {
            throw SpotifyAPIError.authenticationRequired
        }
        
        let urlString = "https://api.spotify.com/v1/\(endpoint)"
        guard let url = URL(string: urlString) else {
            throw SpotifyAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Validate HTTP response
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw SpotifyAPIError.invalidResponse(statusCode: httpResponse.statusCode)
        }
        
        // Parse JSON
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw SpotifyAPIError.jsonParsingFailed
        }
        
        print("Raw JSON Response (\(endpoint)): \(json)")
        return json
    }
}

/// Enum to handle Spotify API-specific errors.
enum SpotifyAPIError: Error, LocalizedError {
    case authenticationRequired
    case invalidURL
    case invalidResponse(statusCode: Int)
    case jsonParsingFailed
    
    var errorDescription: String? {
        switch self {
        case .authenticationRequired:
            return "Authentication required to fetch data."
        case .invalidURL:
            return "Invalid endpoint URL."
        case .invalidResponse(let statusCode):
            return "Invalid response from the server. Status code: \(statusCode)."
        case .jsonParsingFailed:
            return "Failed to parse JSON response."
        }
    }
}
