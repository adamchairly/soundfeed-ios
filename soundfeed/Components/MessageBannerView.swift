import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "checkmark")
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            .padding(.top, 8)
    }
}

extension View {
    func toast(message: String?) -> some View {
        overlay(alignment: .top) {
            if let message {
                ToastView(message: message)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(duration: 0.3), value: message)
            }
        }
        .animation(.spring(duration: 0.3), value: message)
    }

    func errorAlert(error: Binding<String?>) -> some View {
        alert(
            "Error",
            isPresented: Binding(
                get: { error.wrappedValue != nil },
                set: { if !$0 { error.wrappedValue = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            if let message = error.wrappedValue {
                Text(message)
            }
        }
    }
}
