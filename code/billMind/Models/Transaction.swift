import SwiftData
import Foundation

@Model
final class Transaction: Identifiable {

    enum Category: String, CaseIterable, Identifiable, Codable {
        case food = "Food"      , transport = "Transport"
        case shopping = "Shopping", utilities = "Utilities"
        case other = "Other"
        var id: String { rawValue }
        var symbol: String {
            switch self {
            case .food:       "fork.knife"
            case .transport:  "car.fill"
            case .shopping:   "bag.fill"
            case .utilities:  "bolt.fill"
            case .other:      "circle.dashed"
            }
        }
    }

    var id: UUID
    var date: Date
    var payee: String
    var amount: Double
    var categoryRaw: Category

    var category: Category { categoryRaw }

    init(id: UUID = UUID(),
         date: Date,
         payee: String,
         amount: Double,
         category: Category = .other) {
        self.id = id
        self.date = date
        self.payee = payee
        self.amount = amount
        self.categoryRaw = category
    }
}
