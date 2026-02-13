import Foundation

struct Track: Identifiable, Hashable, Codable {
    var id: Int { trackNumber }
    let title: String
    let trackNumber: Int
}
