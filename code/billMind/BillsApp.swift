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
        .commands { BillMindCommands() }
        #endif
        
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
        
        // Extra windows for macOS multi-window support
        WindowGroup("Add Bill", id: "addBill") {
            AddBillView()
        }
        .modelContainer(ModelContainer.shared)
        
        WindowGroup("Add Transaction", id: "addTransaction") {
            AddTransactionView()
        }
        .modelContainer(ModelContainer.shared)
        #endif
    }
}

#if os(macOS)
// macOS-specific global command definitions
struct BillMindCommands: Commands {
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        // Replace default File > New menu
        CommandGroup(replacing: .newItem) {
            Button("New Bill") { openWindow(id: "addBill") }
                .keyboardShortcut("n")

            Button("New Transaction") { openWindow(id: "addTransaction") }
                .keyboardShortcut("t")
        }

        CommandMenu("Windows") {
            Button("Show Analytics") { openWindow(id: "analytics") }
                .keyboardShortcut("a", modifiers: [.command, .option])
            Button("Receipt Scanner") { openWindow(id: "scanner") }
        }
    }
}
#endif
