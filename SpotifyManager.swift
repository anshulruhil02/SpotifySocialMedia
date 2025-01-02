import SpotifyiOS

struct BrowseAlbum: Identifiable {
    let id = UUID()
    let name: String
    let artistName: String
    let imageUrl: String
}

class SpotifyManager: NSObject, ObservableObject, SPTAppRemoteDelegate, SPTAppRemoteUserAPIDelegate {
    static let shared = SpotifyManager()

    private let SpotifyClientID = "871e04894c794ef3bbd977be57a5f36f"
    private let SpotifyRedirectURL = URL(string: "spotify-socialmedia://spotify-login-callback")!

    private lazy var configuration: SPTConfiguration = {
        let config = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURL)
        config.playURI = ""
        return config
    }()

    private var appRemote: SPTAppRemote?
    private(set) var accessToken: String?

    @Published var isConnected = false
    @Published var errorMessage: String?
    @Published var topTracks: [String] = []
    @Published var topArtistsWithImages: [(name: String, imageUrl: String)] = []
    @Published var genres: [String] = [] // New variable for genres
    @Published var latestAlbums: [BrowseAlbum] = [] // New variable for latest albums

    private let requiredScopes: [String] = [
        "user-top-read",
        "user-read-email",
        "user-read-private"
    ]

    override init() {
        super.init()
        appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote?.delegate = self
    }

    func connect() {
        guard let appRemote = appRemote else { return }
        if appRemote.isConnected {
            self.isConnected = true
            return
        }

        appRemote.authorizeAndPlayURI("", asRadio: false, additionalScopes: requiredScopes) { success in
            if success {
                print("Authorization successful")
            } else {
                print("Authorization failed")
            }
        }
    }

    func disconnect() {
        appRemote?.disconnect()
        isConnected = false
    }

    func handleURL(_ url: URL) {
        guard let appRemote = appRemote else { return }
        let parameters = appRemote.authorizationParameters(from: url)
        if let token = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = token
            self.accessToken = token
            appRemote.connect()
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            self.errorMessage = errorDescription
        }
    }

    // MARK: - Fetch Genres

    func fetchGenres() {
        fetchFromSpotifyAPI(endpoint: "me/top/artists?time_range=short_term&limit=10") { [weak self] json in
            guard let self = self else { return }
            if let items = json["items"] as? [[String: Any]] {
                var genreSet = Set<String>() // Use a set to avoid duplicates
                for artist in items {
                    if let artistGenres = artist["genres"] as? [String] {
                        genreSet.formUnion(artistGenres)
                    }
                }
                DispatchQueue.main.async {
                    self.genres = Array(genreSet).sorted()
                    self.errorMessage = nil
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Unexpected data format for genres."
                }
            }
        }
    }

    // MARK: - Fetch Top Tracks

    func fetchTopTracks() {
        fetchFromSpotifyAPI(endpoint: "me/top/tracks?time_range=short_term&limit=10") { [weak self] json in
            guard let self = self else { return }
            if let items = json["items"] as? [[String: Any]] {
                let trackNames = items.compactMap { $0["name"] as? String }
                DispatchQueue.main.async {
                    self.topTracks = trackNames
                    self.errorMessage = nil
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Unexpected data format for tracks."
                }
            }
        }
    }

    // MARK: - Fetch Top Artists

    func fetchTopArtists() {
        fetchFromSpotifyAPI(endpoint: "me/top/artists?time_range=short_term&limit=10") { [weak self] json in
            guard let self = self else { return }
            if let items = json["items"] as? [[String: Any]] {
                let artists = items.compactMap { artist -> (String, String)? in
                    guard let name = artist["name"] as? String,
                          let images = artist["images"] as? [[String: Any]],
                          let imageUrl = images.first?["url"] as? String else {
                        return nil
                    }
                    return (name, imageUrl)
                }
                DispatchQueue.main.async {
                    self.topArtistsWithImages = artists
                    self.errorMessage = nil
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Unexpected data format for artists."
                }
            }
        }
    }
    func fetchLatestAlbums() {
        fetchFromSpotifyAPI(endpoint: "browse/new-releases?limit=10") { [weak self] json in
            guard let self = self else { return }
            
            // Debug: Print the raw JSON response
            print("Raw JSON Response for Latest Albums: \(json)")
            
            if let albumsData = (json["albums"] as? [String: Any])?["items"] as? [[String: Any]] {
                let albumResults = albumsData.compactMap { item -> BrowseAlbum? in
                    guard let name = item["name"] as? String,
                          let artists = item["artists"] as? [[String: Any]],
                          let artistName = artists.first?["name"] as? String,
                          let images = item["images"] as? [[String: Any]],
                          let imageUrl = images.first?["url"] as? String else {
                        return nil
                    }
                    return BrowseAlbum(name: name, artistName: artistName, imageUrl: imageUrl)
                }
                
                DispatchQueue.main.async {
                    self.latestAlbums = albumResults
                    self.errorMessage = nil
                }
            } else {
                // Debug: Print error if the data format is unexpected
                print("Unexpected data format for Latest Albums JSON: \(json)")
                
                DispatchQueue.main.async {
                    self.errorMessage = "Unexpected data format for latest albums."
                }
            }
        }
    }
    
    func searchAlbums(query: String) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        fetchFromSpotifyAPI(endpoint: "search?q=\(encodedQuery)&type=album&limit=10") { [weak self] json in
            guard let self = self else { return }

            // Debug: Print the raw JSON response
            print("Raw JSON Response for Album Search: \(json)")

            if let albumsData = (json["albums"] as? [String: Any])?["items"] as? [[String: Any]] {
                let albumResults = albumsData.compactMap { item -> BrowseAlbum? in
                    guard let name = item["name"] as? String,
                          let artists = item["artists"] as? [[String: Any]],
                          let artistName = artists.first?["name"] as? String,
                          let images = item["images"] as? [[String: Any]],
                          let imageUrl = images.first?["url"] as? String else {
                        return nil
                    }
                    return BrowseAlbum(name: name, artistName: artistName, imageUrl: imageUrl)
                }

                DispatchQueue.main.async {
                    self.latestAlbums = albumResults
                    self.errorMessage = nil
                }
            } else {
                // Debug: Print error if the data format is unexpected
                print("Unexpected data format for Album Search JSON: \(json)")

                DispatchQueue.main.async {
                    self.errorMessage = "Unexpected data format for searched albums."
                }
            }
        }
    }




    // MARK: - Generic Spotify API Fetcher

    private func fetchFromSpotifyAPI(endpoint: String, completion: @escaping ([String: Any]) -> Void) {
        guard let token = accessToken else {
            print("No access token available")
            DispatchQueue.main.async {
                self.errorMessage = "Authentication required to fetch data."
            }
            return
        }

        let url = URL(string: "https://api.spotify.com/v1/\(endpoint)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch data."
                }
                return
            }

            guard let data = data else {
                print("No data received from Spotify API")
                DispatchQueue.main.async {
                    self.errorMessage = "No data received."
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Raw JSON Response: \(json)")
                    completion(json)
                } else {
                    print("Failed to parse JSON into dictionary")
                    DispatchQueue.main.async {
                        self.errorMessage = "Unexpected JSON structure."
                    }
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to parse data."
                }
            }
        }
        task.resume()
    }

    // MARK: - SPTAppRemoteDelegate Methods

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("Spotify App Remote connected successfully!")
        self.isConnected = true
        self.errorMessage = nil
        appRemote.userAPI?.delegate = self
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("Spotify App Remote failed to connect: \(error?.localizedDescription ?? "Unknown error")")
        self.errorMessage = "Failed to connect to Spotify. Please try again."
        self.isConnected = false
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("Spotify App Remote disconnected: \(error?.localizedDescription ?? "Unknown error")")
        self.errorMessage = "Disconnected from Spotify. Please reconnect."
        self.isConnected = false
    }

    // MARK: - SPTAppRemoteUserAPIDelegate Methods

    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {
        print("User capabilities received: \(capabilities.canPlayOnDemand)")
    }

    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didFailWithError error: Error) {
        print("User API error: \(error.localizedDescription)")
        self.errorMessage = "Failed to fetch user data."
    }

    func clearData() {
        DispatchQueue.main.async {
            self.topTracks.removeAll()
            self.topArtistsWithImages.removeAll()
            self.genres.removeAll()
        }
    }
}
