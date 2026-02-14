import Foundation

@Observable
final class AddArtistViewModel: AutoDismissable {

    private let artistService = ArtistService()

    var artists: [Artist] = []
    var searchResults: [SearchArtist] = []
    var searchQuery: String = "" {
        didSet { debounceSearch() }
    }

    var isLoading = false
    var isSearching = false
    var error: String?
    var successMessage: String?

    private var searchTask: Task<Void, Never>?

    private func debounceSearch() {
        searchTask?.cancel()
        let query = searchQuery.trimmingCharacters(in: .whitespaces)

        guard !query.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }

        isSearching = true
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            await performSearch(query: query)
        }
    }

    func loadArtists() async {
        isLoading = true
        error = nil
        do {
            artists = try await artistService.fetchArtists()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    private func performSearch(query: String) async {
        error = nil
        do {
            let results = try await artistService.searchArtists(query: query)
            guard !Task.isCancelled else { return }
            searchResults = results
        } catch {
            guard !Task.isCancelled else { return }
            self.error = error.localizedDescription
        }
        isSearching = false
    }

    func addArtist(spotifyUrl: String) async {
        error = nil
        successMessage = nil
        do {
            try await artistService.addArtist(spotifyUrl: spotifyUrl)
            searchResults = []
            searchQuery = ""
            await loadArtists()
            await showSuccess("Artist added.")
        } catch {
            self.error = error.localizedDescription
        }
    }

    func removeArtist(id: Int) async {
        let backup = artists
        artists.removeAll { $0.id == id }

        do {
            try await artistService.removeArtist(id: id)
        } catch {
            artists = backup
            self.error = error.localizedDescription
        }
    }
}
