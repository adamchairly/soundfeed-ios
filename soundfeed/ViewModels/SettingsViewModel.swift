import Foundation

@Observable
final class SettingsViewModel {

    private let userService = UserService()
    private let syncService = SyncService()

    var recoveryCode: String = ""
    var recoveryInput: String = ""
    var email: String = ""
    var emailNotifications: Bool = false

    var isLoading = false
    var error: String?
    var successMessage: String?
    var lastSynced: Date?
    var isSyncing = false

    func loadUser() async {
        isLoading = true
        error = nil
        do {
            let user = try await userService.fetchUser()
            recoveryCode = user.recoveryCode
            email = user.email ?? ""
            emailNotifications = user.emailNotifications
        } catch is CancellationError {
            // Ignore task cancellation 
        } catch {
            self.error = error.localizedDescription
            await dismissMessageAfterDelay()
        }
        isLoading = false
    }
    
    func loadSync() async {
        do {
            lastSynced = try await syncService.getLastSynced()
        } catch {
            // Silently fail for sync
        }
    }

    func recover() async {
        guard !recoveryInput.isEmpty else { return }
        error = nil
        successMessage = nil
        do {
            try await userService.recover(code: recoveryInput)
            successMessage = "Account recovered successfully."
            recoveryInput = ""
            await loadUser()
            await dismissMessageAfterDelay()
        } catch {
            self.error = error.localizedDescription
            await dismissMessageAfterDelay()
        }
    }

    func saveEmail() async {
        error = nil
        successMessage = nil
        do {
            try await userService.updateEmailSettings(email: email, enabled: emailNotifications)
            successMessage = "Email saved."
            await dismissMessageAfterDelay()
        } catch {
            self.error = error.localizedDescription
            await dismissMessageAfterDelay()
        }
    }

    func toggleNotifications(_ enabled: Bool) async {
        emailNotifications = enabled
        error = nil
        successMessage = nil
        do {
            try await userService.updateEmailSettings(email: email, enabled: enabled)
        } catch {
            emailNotifications = !enabled
            self.error = error.localizedDescription
            await dismissMessageAfterDelay()
        }
    }
    
    private func dismissMessageAfterDelay() async {
        try? await Task.sleep(for: .seconds(3))
        successMessage = nil
        error = nil
    }
    
    func syncReleases() async {
        guard !isSyncing else { return }
        isSyncing = true
        error = nil
        successMessage = nil

        do {
            try await syncService.syncReleases()
            await loadSync()
            successMessage = "Sync completed successfully."
            await dismissMessageAfterDelay()
        } catch is CancellationError {
            // Ignore
        } catch {
            self.error = error.localizedDescription
            await dismissMessageAfterDelay()
        }

        isSyncing = false
    }
}
