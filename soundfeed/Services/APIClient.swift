import Foundation
import os

final class APIClient {

    static let shared = APIClient()

    private let baseURL = Env.apiBaseURL
    private let session: URLSession
    private let decoder: JSONDecoder

    private let cookieKey = "soundfeed_uid_cookie"

    init() {
        let config = URLSessionConfiguration.default
        config.httpCookieAcceptPolicy = .never
        config.httpShouldSetCookies = false
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

    }

    private var storedCookie: String? {
        get { UserDefaults.standard.string(forKey: cookieKey) }
        set { UserDefaults.standard.set(newValue, forKey: cookieKey) }
    }

    private func extractAndStoreCookie(from response: HTTPURLResponse) {
        guard let headerFields = response.allHeaderFields as? [String: String],
              let url = response.url else { return }

        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
        if let uidCookie = cookies.first(where: { $0.name == "uid" }) {
            storedCookie = uidCookie.value
        }
    }

    public func makeRequest(path: String, method: String = "GET", queryItems: [URLQueryItem]? = nil) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidRequest
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            throw APIError.invalidRequest
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let cookie = storedCookie {
            request.setValue("uid=\(cookie)", forHTTPHeaderField: "Cookie")
        }

        return request
    }

    public func makeRequest<B: Encodable>(path: String, method: String, body: B) throws -> URLRequest {
        var request = try makeRequest(path: path, method: method)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        return request
    }

    public func perform<T: Decodable>(_ request: URLRequest) async throws -> T {

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        extractAndStoreCookie(from: httpResponse)

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        return try decoder.decode(T.self, from: data)
    }

    public func performVoid(_ request: URLRequest) async throws {

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }


        extractAndStoreCookie(from: httpResponse)

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
    }

}


enum APIError: LocalizedError {
    case invalidRequest
    case invalidResponse
    case httpError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "Invalid request URL."
        case .invalidResponse:
            return "Invalid server response."
        case .httpError(let code):
            switch code {
            case 401: return "Looks like you are not authenticated. Please try reloading the application."
            case 404: return "Did you enter the information correctly? Please try again."
            case 429: return "Too many requests. Please try again later."
            default:  return "Something went wrong. Please try again."
            }
        }
    }
}
