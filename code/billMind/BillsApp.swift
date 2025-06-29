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
        
        // Menu-bar extra for quick actions
        MenuBarExtra("billMind", systemImage: "tray.full") {
            MenuBarContent()
        }
        .menuBarExtraStyle(.window)
        
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

// Content used inside the menu-bar extra
private struct MenuBarContent: View {
    @Environment(\.openWindow) private var openWindow
    var body: some View {
        VStack {
            Button("New Bill") { openWindow(id: "addBill") }
            Button("New Transaction") { openWindow(id: "addTransaction") }
            Divider()
            Button("Show Analytics") { openWindow(id: "analytics") }
            Button("Open Main Window") { NSApp.activate(ignoringOtherApps: true) }
            Divider()
            Button("Quit billMind") { NSApp.terminate(nil) }
        }
        .padding(8)
    }
}
#endif
