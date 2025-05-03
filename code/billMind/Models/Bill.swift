import Foundation
import SwiftData

@Model
final class Bill: Identifiable {
    enum Category: String, CaseIterable, Identifiable, Codable {
        case general = "General"
        case utilities = "Utilities"
        case rent = "Rent"
        case entertainment = "Entertainment"
        case groceries = "Groceries"
        var id: String { rawValue }
        var symbol: String {
            switch self {
            case .general: "doc.text"
            case .utilities: "bolt.fill"
            case .rent: "house.fill"
            case .entertainment: "gamecontroller.fill"
            case .groceries: "cart.fill"
            }
        }
    }

    enum PaymentMode: String, CaseIterable, Identifiable, Codable {
        case cash = "Cash"
        case card = "Card"
        case bank = "Bank Transfer"
        case other = "Other"
        var id: String { rawValue }
    }

    enum Frequency: String, CaseIterable, Identifiable, Codable {
        case none = "One‑off"
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
        var id: String { rawValue }
    }

    var id: UUID
    var name: String
    var date: Date
    var amount: Double
    var categoryRaw: Category
    var paymentModeRaw: PaymentMode
    var frequencyRaw: Frequency? = Bill.Frequency.none
    var isPaid: Bool
    var paidDate: Date?
    var receiptData: Data?

    var category: Category { categoryRaw }
    var paymentMode: PaymentMode { paymentModeRaw }
    var frequency: Frequency { frequencyRaw ?? .none }
    var isOverdue: Bool { !isPaid && date < .now }
    var hasReceipt: Bool { receiptData != nil }

    init(
        id: UUID = UUID(),
        name: String,
        date: Date,
        amount: Double,
        category: Category = .general,
        paymentMode: PaymentMode = .cash,
        frequency: Frequency = .none,
        receiptData: Data? = nil,
        isPaid: Bool = false,
        paidDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.date = date
        self.amount = amount
        self.categoryRaw = category
        self.paymentModeRaw = paymentMode
        self.frequencyRaw = frequency
        self.receiptData = receiptData
        self.isPaid = isPaid
        self.paidDate = paidDate
    }

    func nextDate() -> Date? {
        let cal = Calendar.current
        switch frequencyRaw ?? .none {
        case .none: return nil
        case .daily: return cal.date(byAdding: .day, value: 1, to: date)
        case .weekly: return cal.date(byAdding: .weekOfYear, value: 1, to: date)
        case .monthly: return cal.date(byAdding: .month, value: 1, to: date)
        case .yearly: return cal.date(byAdding: .year, value: 1, to: date)
        }
    }
}
