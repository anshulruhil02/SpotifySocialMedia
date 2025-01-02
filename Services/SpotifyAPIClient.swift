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
    
    // We'll store the access token here so all services can use the same instance or inject it as needed.
    var accessToken: String?
    
    // A placeholder for returning errors if you want to store them at the client level
    // (In practice, you'd likely handle errors at each service or pass them via a callback.)
    var errorMessage: String?
    
    private init() {}
    
    /// Generic method to fetch data from Spotify's Web API.
    /// - Parameters:
    ///   - endpoint: The endpoint (relative to "https://api.spotify.com/v1/").
    ///   - completion: Returns a dictionary on success or handles error states.
    func fetchFromSpotifyAPI(endpoint: String,
                             completion: @escaping ([String: Any]?) -> Void) {
        
        guard let token = accessToken else {
            print("No access token available")
            self.errorMessage = "Authentication required to fetch data."
            completion(nil)
            return
        }
        
        let urlString = "https://api.spotify.com/v1/\(endpoint)"
        guard let url = URL(string: urlString) else {
            print("Invalid endpoint URL: \(urlString)")
            self.errorMessage = "Invalid URL."
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                self.errorMessage = "Failed to fetch data."
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received from Spotify API")
                self.errorMessage = "No data received."
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data,
                                                               options: []) as? [String: Any] {
                    print("Raw JSON Response (\(endpoint)): \(json)")
                    completion(json)
                } else {
                    print("Failed to parse JSON into dictionary")
                    self.errorMessage = "Unexpected JSON structure."
                    completion(nil)
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                self.errorMessage = "Failed to parse data."
                completion(nil)
            }
        }
        task.resume()
    }
}
