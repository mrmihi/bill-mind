import UserNotifications

struct NotificationManager {
    static let center = UNUserNotificationCenter.current()

    static func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error { print("Notification auth error: \(error.localizedDescription)") }
            print("Notifications granted: \(granted)")
        }
    }

    static func schedule(for bill: Bill) {
        guard !bill.isPaid else { return }
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: bill.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        let content = UNMutableNotificationContent()
        content.title = "Bill due today"
        content.body  = "\(bill.name) (LKR \(String(format: "%.2f", bill.amount))) is due now."
        content.sound = .default

        center.add(UNNotificationRequest(identifier: bill.id.uuidString, content: content, trigger: trigger))
    }

    static func cancel(for bill: Bill) {
        center.removePendingNotificationRequests(withIdentifiers: [bill.id.uuidString])
    }
}
