import SwiftUI

struct AlbumsView: View {
    @ObservedObject var viewModel: AlbumsViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Search Albums")
                .font(.largeTitle)
                .bold()
                .padding([.leading, .top])

            // Search Bar
            HStack {
                TextField("Search albums...", text: $viewModel.searchText, onCommit: {
                    viewModel.searchAlbums()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

                Button(action: {
                    viewModel.searchAlbums()
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.blue)
                }
                .padding(.trailing)
            }
            .padding(.top)

            if viewModel.latestAlbums.isEmpty {
                Spacer()
                Text("No albums found.")
                    .foregroundColor(.gray)
                    .font(.title2)
                    .padding()
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(viewModel.latestAlbums) { album in
                            VStack {
                                // AsyncImage for album cover
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
            viewModel.onAppear()
        }
    }
}
