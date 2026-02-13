import Foundation

struct SearchArtist: Codable, Identifiable, Hashable {
    let name: String
    let imageUrl: String?
    let spotifyUrl: String?

    var id: String { spotifyUrl ?? name }
}
