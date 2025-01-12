//
//  HomeView.swift
//  SpotifySocialMedia
//
//  Created by Anshul Ruhil on 2025-01-02.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isConnected {
                    Text("Connected to Spotify!")
                        .font(.headline)
                        .padding()
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(radius: 5)
                        .frame(height: 200)
                        .overlay(
                            VStack {
                                Text("Tracks")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text("Discover your favorite tracks")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                // "View All Tracks" Button
                                NavigationLink(destination: TrackCardView(viewModel: viewModel)) {
                                    Text("View All Tracks")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                                .padding(.horizontal)
                            }
                                .padding()
                        )
                        .padding()
                        .task {
                            await viewModel.fetchTopTracks() // Automatically fetch tracks
                        }
                    
                    HStack(spacing: 20) {
                        
                        Button(action: {
                            viewModel.fetchTopArtists()
                            //                        viewModel.saveListeningData() // Automatically save after fetching
                        }) {
                            Text("Top Artists")
                                .font(.title3)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            viewModel.fetchGenres()
                            //                        viewModel.saveListeningData() // Automatically save after fetching
                        }) {
                            Text("Top Genres")
                                .font(.title3)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            
                            if !viewModel.topArtistsWithImages.isEmpty {
                                ImageCardView(title: "Your Top Artists",
                                              items: viewModel.topArtistsWithImages)
                            }
                            
                            if !viewModel.genres.isEmpty {
                                CardView(title: "Your Top Genres",
                                         items: viewModel.genres)
                            }
                            
                            if viewModel.topTracks.isEmpty
                                && viewModel.topArtistsWithImages.isEmpty
                                && viewModel.genres.isEmpty {
                                Text("No data available yet. Fetch your top tracks, artists, and genres!")
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                        }
                    }
                } else {
                    Button(action: {
                        viewModel.connect()
                    }) {
                        Text("Connect to Spotify")
                            .font(.title)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
        }
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
            
            ForEach(items, id: \ .self) { item in
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

struct ImageCardView: View {
    let title: String
    let items: [(name: String, imageUrl: String)]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 5)
            
            ForEach(items, id: \ .name) { item in
                HStack(spacing: 10) {
                    AsyncImage(url: URL(string: item.imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        case .failure(_):
                            Color.red
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    Text(item.name)
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
