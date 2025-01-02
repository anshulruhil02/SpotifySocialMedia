import SwiftUI

struct AlbumsView: View {
    @EnvironmentObject var spotifyManager: SpotifyManager
    @State private var searchText: String = "" // Search query text

    var body: some View {
        VStack(alignment: .leading) {
            Text("Search Albums")
                .font(.largeTitle)
                .bold()
                .padding([.leading, .top])

            // Search Bar
            HStack {
                TextField("Search albums...", text: $searchText, onCommit: {
                    if !searchText.isEmpty {
                        spotifyManager.searchAlbums(query: searchText)
                    }
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

                Button(action: {
                    if !searchText.isEmpty {
                        spotifyManager.searchAlbums(query: searchText)
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.blue)
                }
                .padding(.trailing)
            }
            .padding(.top)

            if spotifyManager.latestAlbums.isEmpty {
                Spacer()
                Text("No albums found.")
                    .foregroundColor(.gray)
                    .font(.title2)
                    .padding()
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(spotifyManager.latestAlbums) { album in
                            VStack {
                                AsyncImage(url: URL(string: album.imageUrl)) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 150, height: 150)
                                            .cornerRadius(10)
                                    } else if phase.error != nil {
                                        Color.red // Error state
                                            .frame(width: 150, height: 150)
                                            .cornerRadius(10)
                                    } else {
                                        Color.gray // Placeholder
                                            .frame(width: 150, height: 150)
                                            .cornerRadius(10)
                                    }
                                }

                                Text(album.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .padding(.top, 5)

                                Text(album.artistName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(1)
                                    .padding(.bottom, 5)
                            }
                            .frame(width: 160)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
            spotifyManager.fetchLatestAlbums()
        }
    }
}
