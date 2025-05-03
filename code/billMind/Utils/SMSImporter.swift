import Foundation
import SwiftData

enum SMSImporter {

    static func `import`(_ text: String, into context: ModelContext) {
        print("[Importer] got text: \(text)")
        let amountPattern = #/LKR\s+([\d,]+(?:\.\d+)?)/#
        let datePattern   = #/(\d{4}-\d{2}-\d{2})/#
        guard
            let amountMatch = text.firstMatch(of: amountPattern),
            let dateMatch   = text.firstMatch(of: datePattern)
        else {
            print("[Importer] regex miss");   return
        }
        let amountString = amountMatch.output.1.replacingOccurrences(of: ",", with: "")
        guard let amount = Double(amountString) else {
            print("[Importer] bad amount");   return
        }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale     = .init(identifier: "en_US_POSIX")
        df.timeZone   = TimeZone(secondsFromGMT: 0)

        guard let date = df.date(from: String(dateMatch.output.1)) else {
            print("[Importer] bad date");     return
        }

        let txn = Transaction(date: date,
                              payee: "SMS Payee",
                              amount: amount,
                              category: .other)
        context.insert(txn)
        do    { try context.save(); print("[Importer] saved OK") }
        catch { print("[Importer] save error:", error) }
    }
}
