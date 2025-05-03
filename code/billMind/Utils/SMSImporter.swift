import Foundation
import SwiftData

enum SMSImporter {

    static func `import`(_ text: String, into context: ModelContext) {
        print("[Importer] got text: \(text)")

        let hnbPattern =
        #/[*]{2}(\d{4}) :(.+?)\s+\(.*?\)\s+LKR\s+([\d,]+\.\d{2}) \((\d{2}-[A-Za-z]{3}-\d{4}) (\d{2}:\d{2}:\d{2}) [AP]M\)/#

        let cardPattern =
            #/card ending #(\d{4}).*?Purchase at ([A-Z0-9 ]+).*?for LKR ([\d,]+\.\d{2}) on (\d{2})\/(\d{2})\/(\d{2}) (\d{2}:\d{2}) ([AP]M)/#

        var payee = "Unknown"
        var amount: Double = 0
        var date = Date()
        var last4: String?
        var channel: String?

        if let m = text.firstMatch(of: hnbPattern) {
            last4 = String(m.output.1)
            payee = m.output.2.trimmingCharacters(in: .whitespaces)
            amount = Self.double(from: String(m.output.3))
            date = Self.date(
                fromDay: String(m.output.4),
                time: String(m.output.5)
            )
            channel = "VC"
        } else if let m = text.firstMatch(of: cardPattern) {
            last4 = String(m.output.1)
            payee = m.output.2.capitalized
            amount = Self.double(from: String(m.output.3))
            date = Self.date(
                d: String(m.output.4),
                m: String(m.output.5),
                y: String(m.output.6),
                time: String(m.output.7),
                ampm: String(m.output.8)
            )
            channel = "Card"
        } else {
            print("[Importer] no pattern matched")
            return
        }

        let txn = Transaction(
            date: date,
            payee: payee,
            amount: amount,
            cardLast4: last4,
            channel: channel,
            category: .other,
        )
        context.insert(txn)

        // Try to find an unpaid bill tied to this card
        if let last4 = last4 {
            let descriptor = FetchDescriptor<Bill>(
                predicate: #Predicate { $0.cardLast4 == last4 && !$0.isPaid }
            )
            if let bill = try? context.fetch(descriptor).first {
                // Existing bill -> add to running balance
                bill.amount += amount
            } else {
                // No bill yet -> create one due end‑of‑month
                if let due = Calendar.current.date(
                    from: DateComponents(
                        year:  Calendar.current.component(.year,  from: date),
                        month: Calendar.current.component(.month, from: date),
                        day:   Calendar.current.range(of: .day, in: .month, for: date)!.count,
                        hour:  23, minute: 59)
                ) {
                    let newBill = Bill(
                        name: "Credit Card \(last4)",
                        date: due,
                        amount: amount,
                        category: .utilities,          // pick any category you like
                        paymentMode: .card,
                        frequency: .monthly,           // recurring if you want
                        cardLast4: last4
                    )
                    context.insert(newBill)
                    NotificationManager.schedule(for: newBill)
                }
            }
        }


        do {
            try context.save()
            print("[Importer] saved OK")
        } catch { print("[Importer] save error:", error) }
    }

    private static func double(from s: String) -> Double {
        Double(s.replacingOccurrences(of: ",", with: "")) ?? 0
    }

    private static func date(fromDay day: String, time: String) -> Date {
        let fmt = DateFormatter()
        fmt.locale = .init(identifier: "en_US_POSIX")
        fmt.timeZone = .current
        fmt.dateFormat = "dd-MMM-yyyy HH:mm:ss"
        return fmt.date(from: "\(day) \(time)") ?? .now
    }

    private static func date(
        d: String,
        m: String,
        y: String,
        time: String,
        ampm: String
    ) -> Date {
        let fmt = DateFormatter()
        fmt.locale = .init(identifier: "en_US_POSIX")
        fmt.timeZone = .current
        fmt.dateFormat = "dd/MM/yy hh:mm a"
        return fmt.date(from: "\(d)/\(m)/\(y) \(time) \(ampm)") ?? .now
    }
}
