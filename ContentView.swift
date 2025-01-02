import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill") 
                    Text("Home")
                }

            AlbumsView()
                .tabItem {
                    Image(systemName: "music.note.list")
                    Text("Albums")
                }
        }
    }
}
