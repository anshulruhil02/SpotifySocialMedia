//
//  HomeView.swift
//  SpotifySocialMedia
//
//  Created by Anshul Ruhil on 2025-01-02.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var selectedTab: String = "Tracks" // Default tab

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isConnected {
                    Text("Connected to Spotify!")
                        .font(.headline)
                        .padding()
                    VStack{
                        
                        // Tab Picker
                        Picker("Tabs", selection: $selectedTab) {
                            Text("Tracks").tag("Tracks")
                            Text("Artists").tag("Artists")
                            Text("Genres").tag("Genres")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        
                        // Content based on selected tab
                        if selectedTab == "Tracks" {
                            TrackCardView(viewModel: viewModel)
                        }
                        else if selectedTab == "Artists" {
                            if !viewModel.topArtistsWithImages.isEmpty {
                                ImageCardView(title: "Your Top Artists", items: viewModel.topArtistsWithImages)
                            } else {
                                Text("No artists available yet. Fetching your top artists...")
                                    .foregroundColor(.gray)
                                    .padding()
//                                    .task {
//                                        viewModel.fetchTopArtists()
//                                    }
                            }
                        } else if selectedTab == "Genres" {
                            if !viewModel.genres.isEmpty {
                                CardView(title: "Your Top Genres", items: viewModel.genres)
                            } else {
                                Text("No genres available yet. Fetching your top genres...")
                                    .foregroundColor(.gray)
                                    .padding()
//                                    .task {
//                                        viewModel.fetchGenres()
//                                    }
                            }
                        }
                    }
                    .task {
                        await viewModel.fetchTopTracks()
                        await viewModel.fetchTopArtists()
                        await viewModel.fetchGenres()
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
        ScrollView{
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
}

struct ImageCardView: View {
    let title: String
    let items: [(name: String, imageUrl: String)]
    
    var body: some View {
        ScrollView{
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
}
