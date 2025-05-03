import Foundation
import SwiftData

enum DeepLinkHandler {

    static func handle(_ url: URL, context: ModelContext) {
        guard url.scheme == "billmind" else { return }

        switch url.host {
        case "sms":
            if let body = url.queryItems?["body"]?.removingPercentEncoding {
                SMSImporter.import(body, into: context)
            }
        default: break
        }
    }
}
