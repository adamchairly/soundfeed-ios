import SwiftUI
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}

@main
struct SoundfeedApp: App {
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    private let notificationDelegate = NotificationDelegate()

    init() {
        NotificationService.registerBackgroundTask()
        if NotificationService.isEnabled {
            NotificationService.scheduleBackgroundCheck()
        }
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(appTheme.colorScheme)
        }
    }
}
