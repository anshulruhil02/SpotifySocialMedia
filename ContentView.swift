import SwiftUI

struct ContentView: View {
    
    // MARK: - ViewModels
    // We create @StateObject for each ViewModel to ensure
    // their published state survives view redraws.
    @StateObject private var homeViewModel = HomeViewModel(
        authService: AuthenticationService.shared,
        trackService: TrackService.shared,
        artistAndGenreService: ArtistAndGenreService.shared,
        userprofileService: UserProfileService.shared
    )
    
    var body: some View {
        TabView {
            // Inject the HomeViewModel into HomeView
            HomeView(viewModel: homeViewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
        }
    }
}
