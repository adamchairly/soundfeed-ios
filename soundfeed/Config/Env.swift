import Foundation

enum Env {
    private static let values: [String: Any] = {
        guard let url = Bundle.main.url(forResource: "Environment", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else {
            fatalError("Environment.plist not found — see Environment.plist.example")
        }
        return dict
    }()

    static var apiBaseURL: URL {
        guard let string = values["API_BASE_URL"] as? String,
              let url = URL(string: string) else {
            fatalError("API_BASE_URL is missing or invalid in Environment.plist")
        }
        return url
    }
}
