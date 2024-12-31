import SwiftUI

struct ContentView: View {
    @EnvironmentObject var spotifyManager: SpotifyManager

    var body: some View {
        VStack {
            if spotifyManager.isConnected {
                Text("Connected to Spotify!")
                    .font(.headline)
                    .padding()

                HStack(spacing: 20) {
                    Button(action: {
                        // Clear all data and fetch top tracks
                        spotifyManager.clearData()
                        spotifyManager.fetchTopTracks()
                    }) {
                        Text("Fetch Top Tracks")
                            .font(.title3)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        // Clear all data and fetch top artists
                        spotifyManager.clearData()
                        spotifyManager.fetchTopArtists()
                    }) {
                        Text("Fetch Top Artists")
                            .font(.title3)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom, 20)

                ScrollView {
                    VStack(spacing: 20) {
                        if !spotifyManager.topTracks.isEmpty {
                            CardView(title: "Your Top Tracks", items: spotifyManager.topTracks)
                        }

                        if !spotifyManager.topArtists.isEmpty {
                            CardView(title: "Your Top Artists", items: spotifyManager.topArtists)
                        }

                        if spotifyManager.topTracks.isEmpty && spotifyManager.topArtists.isEmpty {
                            Text("No data available yet. Fetch your top tracks and artists!")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
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

struct CardView: View {
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 5)

            ForEach(items, id: \.self) { item in
                HStack {
                    Text(item)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.vertical, 5)

                    Spacer()
                }
                .padding(.horizontal)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 5)
    }
}
