import Foundation

struct Artist: Identifiable, Hashable, Codable {
    let id: Int
    let name: String
    let spotifyId: String
    let spotifyUrl: String
    let imageUrl: String?
}
