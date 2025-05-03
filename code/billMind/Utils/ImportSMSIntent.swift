import AppIntents
import SwiftData

struct ImportSMSIntent: AppIntent {

    static var title: LocalizedStringResource = "Import SMS"

    @Parameter(title: "SMS Body") var body: String

    func perform() async throws -> some IntentResult {

        await MainActor.run {
            let context = ModelContainer.shared.mainContext
            SMSImporter.import(body, into: context)
        }

        return .result()
    }
}
