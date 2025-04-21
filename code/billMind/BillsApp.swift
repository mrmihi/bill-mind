import SwiftUI
import SwiftData

@main
struct BillsApp: App {
    init() { NotificationManager.requestAuthorization() }
    var body: some Scene {
        WindowGroup { ContentView() }
            .modelContainer(for: Bill.self)
    }
}
