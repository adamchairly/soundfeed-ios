import Foundation

protocol AutoDismissable: AnyObject {
    var error: String? { get set }
    var successMessage: String? { get set }
}

extension AutoDismissable {
    func showSuccess(_ message: String) async {
        successMessage = message
        try? await Task.sleep(for: .seconds(2))
        successMessage = nil
    }
}
