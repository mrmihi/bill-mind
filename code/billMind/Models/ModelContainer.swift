import SwiftData
import Foundation

extension ModelContainer {
    static let shared: ModelContainer = {
        // 1. App‑group location
        let appGroupURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.billmind.shared")!
            .appending(path: "BillMind.store")
        // 2. Full schema
        let schema = Schema([Bill.self, Transaction.self])
        // 3. Create config *without* version, then assign
        var config = ModelConfiguration(schema: schema, url: appGroupURL)
        // 4. Build container
        return try! ModelContainer(for: schema, configurations: [config])
    }()
}
