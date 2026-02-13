import Foundation

struct Release: Identifiable, Codable {
    let id: Int
    let title: String
    let artistName: String
    let releaseDate: Date
    let coverUrl: String?
    let spotifyUrl: String?
    let releaseType: String?
    let label: String?
    let tracks: [Track]

    private static func utcFormatter(_ format: String) -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = format
        f.timeZone = TimeZone(identifier: "UTC")
        return f
    }

    private static let displayDateFormatter = utcFormatter("MMM d, yyyy")
    private static let keyFormatter = utcFormatter("yyyy-MM")
    private static let labelFormatter = utcFormatter("yyyy MMMM")

    var formattedDate: String {
        Self.displayDateFormatter.string(from: releaseDate)
    }

    var monthYearKey: String {
        Self.keyFormatter.string(from: releaseDate)
    }

    var monthYearLabel: String {
        Self.labelFormatter.string(from: releaseDate)
    }
}
