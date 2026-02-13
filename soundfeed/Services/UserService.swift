import Foundation

struct UserService {

    private let client = APIClient.shared

    func fetchUser() async throws -> User {
        let request = try client.makeRequest(path: "user")
        return try await client.perform(request)
    }

    func recover(code: String) async throws {
        struct Body: Encodable { let recoveryCode: String }
        let request = try client.makeRequest(path: "user", method: "POST", body: Body(recoveryCode: code))
        try await client.performVoid(request)
    }

    func updateEmailSettings(email: String, enabled: Bool) async throws {
        struct Body: Encodable { let email: String; let enabled: Bool }
        let request = try client.makeRequest(path: "email", method: "PATCH", body: Body(email: email, enabled: enabled))
        try await client.performVoid(request)
    }
}
