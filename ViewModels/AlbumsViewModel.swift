//
//  AlbumsViewModel.swift
//  SpotifySocialMedia
//
//  Created by Anshul Ruhil on 2025-01-03.
//

import SwiftUI
import Combine

final class AlbumsViewModel: ObservableObject {
    // Services
    private let albumService: AlbumService
    
    // Published properties for the UI
    @Published var latestAlbums: [BrowseAlbum] = []
    @Published var errorMessage: String?
    
    // Used to store any Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // Search query
    @Published var searchText: String = ""
    
    init(albumService: AlbumService) {
        self.albumService = albumService
        
        // Observe changes in albumService
        albumService.$latestAlbums
            .receive(on: DispatchQueue.main)
            .assign(to: &$latestAlbums)
        
        albumService.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] err in
                self?.errorMessage = err
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    func onAppear() {
        fetchLatestAlbums()
    }
    
    func fetchLatestAlbums() {
        albumService.fetchLatestAlbums()
    }
    
    func searchAlbums() {
        guard !searchText.isEmpty else { return }
        albumService.searchAlbums(query: searchText)
    }
}
