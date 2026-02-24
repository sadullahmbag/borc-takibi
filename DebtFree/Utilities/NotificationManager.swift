import Foundation
import UserNotifications

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false
    @Published var remindersEnabled = UserDefaults.standard.bool(forKey: "remindersEnabled") {
        didSet {
            UserDefaults.standard.set(remindersEnabled, forKey: "remindersEnabled")
            if remindersEnabled {
                scheduleReminders()
            } else {
                cancelAllReminders()
            }
        }
    }

    @Published var reminderTime: Date = {
        if let savedTime = UserDefaults.standard.object(forKey: "reminderTime") as? Date {
            return savedTime
        }
        // Default: 6 PM
        var components = DateComponents()
        components.hour = 18
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }() {
        didSet {
            UserDefaults.standard.set(reminderTime, forKey: "reminderTime")
            if remindersEnabled {
                scheduleReminders()
            }
        }
    }

    private init() {
        Task {
            await checkAuthorization()
        }
    }

    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
            if granted {
                print("✅ Notification permission granted")
            } else {
                print("❌ Notification permission denied")
            }
        } catch {
            print("❌ Error requesting notification authorization: \(error)")
        }
    }

    func checkAuthorization() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    func scheduleReminders() {
        guard isAuthorized && remindersEnabled else { return }

        // Cancel existing reminders first
        cancelAllReminders()

        // Extract hour and minute from reminderTime
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)

        // Schedule daily reminder
        scheduleDailyReminder(hour: components.hour ?? 18, minute: components.minute ?? 0)

        // Schedule weekly summary (every Monday at 9 AM)
        scheduleWeeklySummary()
    }

    private func scheduleDailyReminder(hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Payment Reminder"
        content.body = "Don't forget to track your debt payments today! 💪"
        content.sound = .default
        content.badge = 1

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyPaymentReminder", notificationContent: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling daily reminder: \(error)")
            } else {
                print("✅ Daily reminder scheduled for \(hour):\(String(format: "%02d", minute))")
            }
        }
    }

    private func scheduleWeeklySummary() {
        let content = UNMutableNotificationContent()
        content.title = "Weekly Summary"
        content.body = "Check out your progress this week! 📊"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = 2 // Monday
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weeklySummary", notificationContent: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling weekly summary: \(error)")
            } else {
                print("✅ Weekly summary scheduled for Mondays at 9:00 AM")
            }
        }
    }

    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ All reminders canceled")
    }

    func scheduleDebtDueReminder(for debt: Debt) {
        guard isAuthorized, let dueDate = debt.dueDate else { return }

        let content = UNMutableNotificationContent()
        content.title = "Debt Due Soon"
        content.body = "\(debt.emoji) \(debt.name) is due soon. Current balance: \(String(format: "%.2f", debt.currentAmount))"
        content.sound = .default

        // Schedule notification 3 days before due date
        let reminderDate = Calendar.current.date(byAdding: .day, value: -3, to: dueDate)!

        if reminderDate > Date() {
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "debt-\(debt.id.uuidString)", notificationContent: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error scheduling debt due reminder: \(error)")
                } else {
                    print("✅ Debt due reminder scheduled for \(debt.name)")
                }
            }
        }
    }

    func cancelDebtReminder(for debtId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["debt-\(debtId.uuidString)"])
    }

    func sendCelebrationNotification(for achievement: String) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked! 🎉"
        content.body = achievement
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, notificationContent: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
