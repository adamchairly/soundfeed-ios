import Foundation

struct SyncService {

    private let client = APIClient.shared

    func getLastSynced() async throws -> Date? {
        let request = try client.makeRequest(path: "sync", method: "GET")
        return try await client.perform(request)
    }

    func syncReleases() async throws {
        let request = try client.makeRequest(path: "sync", method: "POST")
        try await client.performVoid(request)
    }
}
