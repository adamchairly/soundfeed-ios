import Foundation

struct ReleaseService {

    private let client = APIClient.shared

    func fetchReleases(page: Int = 1, pageSize: Int = 20, sortDescending: Bool = true) async throws -> PageResult<Release> {
        let request = try client.makeRequest(path: "release", queryItems: [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)"),
            URLQueryItem(name: "sortDescending", value: "\(sortDescending)")
        ])
        return try await client.perform(request)
    }

    func dismissRelease(id: Int) async throws {
        let request = try client.makeRequest(path: "release/\(id)", method: "DELETE")
        try await client.performVoid(request)
    }
}
