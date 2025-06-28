import SwiftUI
import SwiftData

@main
struct BillsWatchApp: App {
    var body: some Scene {
        WindowGroup {
            NextBillView()
                .modelContainer(ModelContainer.shared)
        }
    }
} 