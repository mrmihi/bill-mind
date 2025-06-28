import SwiftData
import Foundation

extension ModelContainer {
    static let shared: ModelContainer = {
        // 1. Shared app-group location (if entitlement present)
        let schema = Schema([Bill.self, Transaction.self])

        if let groupURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.billmind.shared") {
            let url = groupURL.appending(path: "BillMind.store")
            let config = ModelConfiguration(schema: schema, url: url)
            return try! ModelContainer(for: schema, configurations: [config])
        }

        // 2. Fallback to default documents directory (e.g., when the target
        //    doesn't have the entitlement, such as first-run on watchOS).
        return try! ModelContainer(for: schema)
    }()
}

extension ModelContext {
    func fetchOne<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> T? {
        try fetch(descriptor).first
    }
}

