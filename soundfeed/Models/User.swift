import Foundation

struct User: Codable {
    let recoveryCode: String
    let email: String?
    let emailNotifications: Bool
}
