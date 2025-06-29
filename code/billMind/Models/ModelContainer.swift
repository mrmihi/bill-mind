import SwiftData
import Foundation

extension ModelContainer {
    static let shared: ModelContainer = {
        let schema = Schema([Bill.self, Transaction.self])

        if let groupURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.billmind.shared") {
            let url = groupURL.appending(path: "BillMind.store")
            let config = ModelConfiguration(schema: schema, url: url)
            return try! ModelContainer(for: schema, configurations: [config])
        }
        return try! ModelContainer(for: schema)
    }()
}

extension ModelContext {
    func fetchOne<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> T? {
        try fetch(descriptor).first
    }
}

