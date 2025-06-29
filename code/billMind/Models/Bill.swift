import Foundation
import SwiftData
import CloudKit

@Model
final class Bill: Identifiable {
    enum Category: String, CaseIterable, Identifiable, Codable {
        case general = "General"
        case utilities = "Utilities"
        case rent = "Rent"
        case entertainment = "Entertainment"
        case groceries = "Groceries"
        case healthcare = "Healthcare"
        case transportation = "Transportation"
        case insurance = "Insurance"
        case education = "Education"
        case dining = "Dining"
        
        var id: String { rawValue }
        var symbol: String {
            switch self {
            case .general: "doc.text"
            case .utilities: "bolt.fill"
            case .rent: "house.fill"
            case .entertainment: "gamecontroller.fill"
            case .groceries: "cart.fill"
            case .healthcare: "cross.fill"
            case .transportation: "car.fill"
            case .insurance: "shield.fill"
            case .education: "book.fill"
            case .dining: "fork.knife"
            }
        }
        
        var color: String {
            switch self {
            case .general: "gray"
            case .utilities: "blue"
            case .rent: "purple"
            case .entertainment: "pink"
            case .groceries: "green"
            case .healthcare: "red"
            case .transportation: "orange"
            case .insurance: "indigo"
            case .education: "teal"
            case .dining: "yellow"
            }
        }
    }

    enum PaymentMode: String, CaseIterable, Identifiable, Codable {
        case cash = "Cash"
        case card = "Card"
        case bank = "Bank Transfer"
        case digital = "Digital Payment"
        case check = "Check"
        case other = "Other"
        var id: String { rawValue }
    }

    enum Frequency: String, CaseIterable, Identifiable, Codable {
        case none = "One‑off"
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
        case custom = "Custom"
        var id: String { rawValue }
    }
    
    enum Status: String, CaseIterable, Identifiable, Codable {
        case pending = "Pending"
        case paid = "Paid"
        case overdue = "Overdue"
        case cancelled = "Cancelled"
        case disputed = "Disputed"
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
    var cardLast4: String?
    var notes: String?
    var tags: [String] = []
    var statusRaw: Status = Bill.Status.pending
    var reminderDays: Int = 1
    var customFrequencyDays: Int?
    var lastModified: Date = Date()
    var cloudKitRecordID: String?
    var receiptAnnotations: Data?
    
    var category: Category { categoryRaw }
    var paymentMode: PaymentMode { paymentModeRaw }
    var frequency: Frequency { frequencyRaw ?? .none }
    var status: Status { statusRaw }
    var isOverdue: Bool { !isPaid && date < .now && status == .pending }
    var hasReceipt: Bool { receiptData != nil }
    var hasAnnotations: Bool { receiptAnnotations != nil }
    var daysUntilDue: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
    }

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
        paidDate: Date? = nil,
        cardLast4: String? = nil,
        notes: String? = nil,
        tags: [String] = [],
        status: Status = .pending,
        reminderDays: Int = 1,
        customFrequencyDays: Int? = nil
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
        self.cardLast4 = cardLast4
        self.notes = notes
        self.tags = tags
        self.statusRaw = status
        self.reminderDays = reminderDays
        self.customFrequencyDays = customFrequencyDays
        self.lastModified = Date()
    }

    func nextDate() -> Date? {
        let cal = Calendar.current
        switch frequencyRaw ?? .none {
        case .none: return nil
        case .daily: return cal.date(byAdding: .day, value: 1, to: date)
        case .weekly: return cal.date(byAdding: .weekOfYear, value: 1, to: date)
        case .monthly: return cal.date(byAdding: .month, value: 1, to: date)
        case .yearly: return cal.date(byAdding: .year, value: 1, to: date)
        case .custom:
            guard let customDays = customFrequencyDays else { return nil }
            return cal.date(byAdding: .day, value: customDays, to: date)
        }
    }
    
    func markAsPaid() {
        isPaid = true
        paidDate = Date()
        statusRaw = .paid
        lastModified = Date()
        NotificationManager.cancel(for: self)
    }
    
    func markAsUnpaid() {
        isPaid = false
        paidDate = nil
        statusRaw = .pending
        lastModified = Date()
        NotificationManager.schedule(for: self)
    }
    
    func updateStatus(_ newStatus: Status) {
        statusRaw = newStatus
        lastModified = Date()
        
        if newStatus == .paid && !isPaid {
            markAsPaid()
        } else if newStatus == .pending && isPaid {
            markAsUnpaid()
        }
    }
}
