import Foundation
import UserNotifications
import BackgroundTasks

struct NotificationService {

    static let backgroundTaskIdentifier = "com.szekelyadam.soundfeed.release-check"

    private static let lastCheckKey = "notificationLastCheckDate"
    private static let enabledKey = "notificationsEnabled"
    private static let hourKey = "notificationHour"
    private static let minuteKey = "notificationMinute"

    static var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: enabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: enabledKey) }
    }

    static var preferredHour: Int {
        get {
            let val = UserDefaults.standard.integer(forKey: hourKey)
            return val == 0 && !UserDefaults.standard.bool(forKey: "notificationHourSet") ? 9 : val
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hourKey)
            UserDefaults.standard.set(true, forKey: "notificationHourSet")
        }
    }

    static var preferredMinute: Int {
        get { UserDefaults.standard.integer(forKey: minuteKey) }
        set { UserDefaults.standard.set(newValue, forKey: minuteKey) }
    }

    static var lastCheckDate: Date? {
        get { UserDefaults.standard.object(forKey: lastCheckKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: lastCheckKey) }
    }


    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundTaskIdentifier,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }
            handleBackgroundRefresh(refreshTask)
        }
    }

    static func scheduleBackgroundCheck() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)

        var components = DateComponents()
        components.hour = preferredHour
        components.minute = preferredMinute

        if let nextDate = Calendar.current.nextDate(
            after: Date(),
            matching: components,
            matchingPolicy: .nextTime
        ) {
            request.earliestBeginDate = nextDate
        }

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
        }
    }

    static func cancelBackgroundCheck() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: backgroundTaskIdentifier)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private static func handleBackgroundRefresh(_ task: BGAppRefreshTask) {
        let checkTask = Task {
            await checkAndNotify()
        }

        task.expirationHandler = {
            checkTask.cancel()
        }

        Task {
            await checkTask.value
            task.setTaskCompleted(success: true)
            if isEnabled {
                scheduleBackgroundCheck()
            }
        }
    }

    static func checkAndNotify() async {
        do {
            let result = try await ReleaseService().fetchReleases(page: 1, pageSize: 1, sortDescending: true)

            guard let latestRelease = result.items.first else { return }

            let checkDate = lastCheckDate ?? Date.distantPast

            if latestRelease.releaseDate > checkDate {
                await sendLocalNotification(
                    title: "New Release",
                    body: "\(latestRelease.artistName) — \(latestRelease.title)"
                )
            }

            lastCheckDate = Date()
        } catch {
        }
    }

    static func sendTestNotification() async {
        await sendLocalNotification(
            title: "New Release",
            body: "Artist Name — Album Title"
        )
    }

    private static func sendLocalNotification(title: String, body: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        try? await UNUserNotificationCenter.current().add(request)
    }
}
