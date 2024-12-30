//
//  ContentView.swift
//  SpotifySocialMedia
//
//  Created by Anshul Ruhil on 2024-12-27.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var spotifyManager: SpotifyManager

    var body: some View {
        VStack {
            if spotifyManager.isConnected {
                Text("Connected to Spotify!")
                    .font(.headline)
                    .padding()
            } else {
                Button(action: {
                    spotifyManager.connect()
                }) {
                    Text("Connect to Spotify")
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            if let errorMessage = spotifyManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }
}
