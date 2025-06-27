import SwiftUI

/// Handles URL scheme for opening specific windows in the app
struct URLHandler {
    /// Process a URL and perform the appropriate action
    /// - Parameter url: The URL to process
    /// - Returns: True if the URL was handled, false otherwise
    static func handle(_ url: URL) -> Bool {
        guard url.scheme == "billmind" else { return false }

        // Extract the path component (e.g., "bills" from "billmind://bills")
        let path = url.host ?? ""

        switch path {
        case "bills":
            #if os(macOS)
            // On macOS, open a new window with the Bills view
            openWindow(id: "bills")
            #else
            // On iOS/iPadOS, navigate to the Bills tab
            navigateToBillsTab()
            #endif
            return true

        case "transactions":
            #if os(macOS)
            // On macOS, open a new window with the Transactions view
            openWindow(id: "transactions")
            #else
            // On iOS/iPadOS, navigate to the Transactions tab
            navigateToTransactionsTab()
            #endif
            return true

        default:
            return false
        }
    }

    #if os(macOS)
    /// Open a window with the specified ID
    /// - Parameter id: The ID of the window to open
    private static func openWindow(id: String) {
        // Use the OpenWindowAction to open a window with the specified ID
        NSApp.sendAction(Selector(("openWindow:")), to: nil, from: id)
    }
    #else
    /// Navigate to the Bills tab
    private static func navigateToBillsTab() {
        // This would be implemented for iOS/iPadOS
        // to programmatically select the Bills tab
    }

    /// Navigate to the Transactions tab
    private static func navigateToTransactionsTab() {
        // This would be implemented for iOS/iPadOS
        // to programmatically select the Transactions tab
    }
    #endif
}

// Extension to make the URL handler available to the app
extension BillsApp {
    /// Handle a URL opened by the system
    /// - Parameter url: The URL to handle
    func handleURL(_ url: URL) {
        _ = URLHandler.handle(url)
    }
}
