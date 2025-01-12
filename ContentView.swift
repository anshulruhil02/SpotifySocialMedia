import SwiftUI

struct ContentView: View {
    
    // MARK: - ViewModels
    // We create @StateObject for each ViewModel to ensure
    // their published state survives view redraws.
    @StateObject private var homeViewModel = HomeViewModel(
        authService: AuthenticationService.shared,
        trackService: TrackService.shared,
        artistService: ArtistService.shared,
        userprofileService: UserProfileService.shared
    )
    
    @StateObject private var albumsViewModel = AlbumsViewModel(
        albumService: AlbumService.shared
    )
    
    var body: some View {
        TabView {
            // Inject the HomeViewModel into HomeView
            HomeView(viewModel: homeViewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            // Inject the AlbumsViewModel into AlbumsView
            AlbumsView(viewModel: albumsViewModel)
                .tabItem {
                    Image(systemName: "music.note.list")
                    Text("Albums")
                }
        }
    }
}
