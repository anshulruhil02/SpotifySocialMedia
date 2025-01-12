//
//  TrackCardView.swift
//  SpotifySocialMedia
//
//  Created by Anshul Ruhil on 2025-01-12.
//

import SwiftUI

struct TrackCardView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if !viewModel.topTracks.isEmpty {
                    TrackCardScrollView(title: "Your Top Tracks", tracks: viewModel.topTracks)
                } else {
                    Text("No tracks available yet. Fetching your top tracks...")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
    }
}



struct TrackCardScrollView: View {
    let title: String
    let tracks: [Track]

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 5)

            ForEach(tracks, id: \.name) { track in
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(track.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Album: \(track.album)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("Artists: \(track.artists.joined(separator: ", "))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("Popularity: \(track.popularity)")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // Add a placeholder or album art if available
                    AsyncImage(url: URL(string: "https://via.placeholder.com/100")) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        case .failure(_):
                            Color.red
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 5)
    }
}
