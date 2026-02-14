import SwiftUI

extension Color {
    static func buttonTint(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(.systemGray3) : Color(.darkGray)
    }
}
