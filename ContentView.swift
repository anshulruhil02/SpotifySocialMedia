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

                Button(action: {
                    spotifyManager.fetchTopTracks()
                }) {
                    Text("Fetch Top Tracks")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom)

                if !spotifyManager.topTracks.isEmpty {
                    Text("Your Top Tracks")
                        .font(.headline)
                        .padding(.bottom, 5)

                    List(spotifyManager.topTracks, id: \.self) { track in
                        Text(track)
                            .padding(.vertical, 5)
                    }
                } else {
                    Text("No tracks available yet. Fetch your top tracks!")
                        .foregroundColor(.gray)
                        .padding()
                }
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
