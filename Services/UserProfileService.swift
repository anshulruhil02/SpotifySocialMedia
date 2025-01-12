//
//  UserProfileService.swift
//  SpotifySocialMedia
//
//  Created by Anshul Ruhil on 2025-01-03.
//

import FirebaseAuth
import FirebaseFirestore
import Combine

final class UserProfileService: ObservableObject {
    static let shared = UserProfileService()

    private let db = Firestore.firestore()

    @Published var errorMessage: String?

    private init() {}

    // MARK: - Update Listening Data

    func updateListeningData(tracks: [String], albums: [String], genres: [String]) {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "No authenticated user found."
            return
        }

        // Prepare the data structure for listening data
        let listeningData: [String: Any] = [
            "tracks": tracks,
            "albums": albums,
            "genres": genres
        ]

        // Save listening data to Firestore
        db.collection("users").document(uid).setData(["listeningData": listeningData], merge: true) { error in
            if let error = error {
                self.errorMessage = "Failed to save listening data: \(error.localizedDescription)"
            } else {
                print("Listening data successfully updated for user: \(uid)")
            }
        }
    }

    // MARK: - Fetch Listening Data

    func fetchListeningData(completion: @escaping ([String], [String], [String]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "No authenticated user found."
            return
        }

        let docRef = db.collection("users").document(uid)
        docRef.getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch listening data: \(error.localizedDescription)"
                return
            }

            guard let snapshot = snapshot, snapshot.exists else {
                self.errorMessage = "No listening data found."
                return
            }

            if let listeningData = snapshot.data()?["listeningData"] as? [String: Any] {
                let tracks = listeningData["tracks"] as? [String] ?? []
                let albums = listeningData["albums"] as? [String] ?? []
                let genres = listeningData["genres"] as? [String] ?? []

                completion(tracks, albums, genres)
            } else {
                self.errorMessage = "Listening data is malformed."
            }
        }
    }
}
