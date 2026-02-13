import SwiftUI

struct AppHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            HStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 42)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemGroupedBackground))

            content
        }
    }
}

extension View {
    func withAppHeader() -> some View {
        modifier(AppHeaderModifier())
    }
}
