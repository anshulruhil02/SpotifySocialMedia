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
    private(set) var accessToken: String? // Define the access token

    @Published var isConnected = false
    @Published var errorMessage: String?
    @Published var topTracks: [String] = []

    private let requiredScopes: [String] = [
        "user-top-read", // Access to user’s top tracks
        "user-read-email", // Access to user’s email
        "user-read-private" // Access to user’s private details
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
            self.accessToken = token // Assign the access token
            appRemote.connect()
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            self.errorMessage = errorDescription
        }
    }

    // MARK: - Fetch Top Tracks

    func fetchTopTracks() {
        guard let token = accessToken else {
            print("No access token available")
            self.errorMessage = "Authentication required to fetch tracks."
            return
        }

        let url = URL(string: "https://api.spotify.com/v1/me/top/tracks?time_range=short_term&limit=10")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching top tracks: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch top tracks."
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

                    if let items = json["items"] as? [[String: Any]] {
                        let trackNames = items.compactMap { track in
                            return track["name"] as? String
                        }
                        DispatchQueue.main.async {
                            self.topTracks = trackNames
                            self.errorMessage = nil
                        }
                    } else {
                        print("Unexpected JSON format: \(json)")
                        DispatchQueue.main.async {
                            self.errorMessage = "Unexpected data format."
                        }
                    }
                } else {
                    print("Failed to parse JSON into dictionary")
                    DispatchQueue.main.async {
                        self.errorMessage = "Unexpected JSON structure."
                    }
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to parse track data."
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
        appRemote.userAPI?.delegate = self // Set the delegate for the user API
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
}
