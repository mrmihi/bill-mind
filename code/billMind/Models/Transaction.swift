import Foundation
import SwiftData

@Model
final class Transaction: Identifiable {

    enum Category: String, CaseIterable, Identifiable, Codable {
        case food = "Food"
        case transport = "Transport"
        case shopping = "Shopping"
        case utilities = "Utilities"
        case other = "Other"
        var id: String { rawValue }
        var symbol: String {
            switch self {
            case .food: "fork.knife"
            case .transport: "car.fill"
            case .shopping: "bag.fill"
            case .utilities: "bolt.fill"
            case .other: "circle.dashed"
            }
        }
    }

    var id: UUID
    var date: Date
    var payee: String
    var amount: Double
    var categoryRaw: Category
    var cardLast4: String?
    var channel: String?
    var category: Category { categoryRaw }

    init(
        id: UUID = UUID(),
        date: Date,
        payee: String,
        amount: Double,
        cardLast4: String? = nil,
        channel: String? = nil,
        category: Category = .other
    ) {
        self.id = id
        self.date = date
        self.payee = payee
        self.amount = amount
        self.categoryRaw = category
        self.cardLast4 = cardLast4
        self.channel = channel
    }
}
