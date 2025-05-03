//  ImportSMSIntent.swift
//  billMind

import AppIntents
import SwiftData

struct ImportSMSIntent: AppIntent {

    static var title: LocalizedStringResource = "Import SMS"

    @Parameter(title: "SMS Body") var body: String

    func perform() async throws -> some IntentResult {

        try await MainActor.run {            // ← key change
            let container = try ModelContainer(for: Bill.self)
            let context   = container.mainContext
            SMSImporter.import(body, into: context)
        }

        return .result()
    }
}
