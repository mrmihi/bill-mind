import SwiftUI
import SwiftData
import CloudKit

@main
struct BillsApp: App {
    
    init() {
        NotificationManager.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(ModelContainer.shared)
        
        #if os(macOS)
        Settings {
            SettingsView()
        }
        
        WindowGroup("Bill Analytics", id: "analytics") {
            AnalyticsView()
        }
        .modelContainer(ModelContainer.shared)
        
        WindowGroup("Receipt Scanner", id: "scanner") {
            ReceiptScannerView()
        }
        .modelContainer(ModelContainer.shared)
        #endif
    }
}
