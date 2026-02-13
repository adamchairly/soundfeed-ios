import Foundation

struct ArtistService {

    private let client = APIClient.shared

    func fetchArtists() async throws -> [Artist] {
        let request = try client.makeRequest(path: "artists")
        return try await client.perform(request)
    }

    func searchArtists(query: String) async throws -> [SearchArtist] {
        let request = try client.makeRequest(path: "artists/search", queryItems: [
            URLQueryItem(name: "query", value: query)
        ])
        return try await client.perform(request)
    }

    func addArtist(spotifyUrl: String) async throws {
        let request = try client.makeRequest(path: "artists", method: "POST", queryItems: [
            URLQueryItem(name: "artistUrl", value: spotifyUrl)
        ])
        try await client.performVoid(request)
    }

    func removeArtist(id: Int) async throws {
        let request = try client.makeRequest(path: "subscription/\(id)", method: "DELETE")
        try await client.performVoid(request)
    }
}
