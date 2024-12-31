import SpotifyiOS

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
    @Published var topArtists: [String] = [] // New variable for top artists

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
                let artistNames = items.compactMap { $0["name"] as? String }
                DispatchQueue.main.async {
                    self.topArtists = artistNames
                    self.errorMessage = nil
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Unexpected data format for artists."
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
            self.topArtists.removeAll()
        }
    }

}
