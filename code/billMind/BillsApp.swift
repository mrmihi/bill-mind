import SwiftUI
import SwiftData

@main
struct BillsApp: App {

    init() { NotificationManager.requestAuthorization() }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Bill.self, Transaction.self])
    }
}
